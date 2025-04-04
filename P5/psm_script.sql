USE DMDD_Group10;
GO

-- UDFS



-- 1. Given a transaction_id, returns the late fee based on how many days overdue the book is (e.g. $1.00/day). If not overdue or not returned yet, returns 0.00.

CREATE FUNCTION fn_CalculateLateFee(@TransactionID INT)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @DueDate DATE, @ReturnDate DATE;
    DECLARE @DaysOverdue INT = 0;
    DECLARE @Fee DECIMAL(10,2) = 0.00;

    SELECT @DueDate = due_date, @ReturnDate = return_date
    FROM [TRANSACTION]
    WHERE transaction_id = @TransactionID;

    IF @ReturnDate IS NOT NULL AND @ReturnDate > @DueDate
    BEGIN
        SET @DaysOverdue = DATEDIFF(DAY, @DueDate, @ReturnDate);
        SET @Fee = @DaysOverdue * 1.00;  -- $1 per overdue day
    END

    RETURN @Fee;
END;
GO

-- Test / Execution:
SELECT dbo.fn_CalculateLateFee(7) AS LateFee;
-- (Assuming transaction_id=7 is overdue or returned late.)

GO
---------------

-- 2. Returns the number of days since a membership’s registration_date. If not found, returns NULL.

CREATE FUNCTION fn_GetMembershipDuration(@MembershipID INT)
RETURNS INT
AS
BEGIN
    DECLARE @RegistrationDate DATE, @Duration INT;
    SELECT @RegistrationDate = registration_date
    FROM MEMBERSHIP
    WHERE member_library_id = @MembershipID;

    IF @RegistrationDate IS NULL
        RETURN NULL;

    SET @Duration = DATEDIFF(DAY, @RegistrationDate, GETDATE());
    RETURN @Duration;
END;
GO

-- Test / Execution:
SELECT dbo.fn_GetMembershipDuration(1) AS DurationDays;
GO
---------------------------------------

--- 3. A table-valued function returning all authors for a given book_id.

CREATE FUNCTION fn_GetBookAuthors(@BookID INT)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        A.author_id,
        A.first_name,
        A.last_name,
        BA.author_role,
        BA.contribution_percentage,
        BA.special_acknowledgement
    FROM BOOK_AUTHOR AS BA
    JOIN AUTHOR AS A ON BA.author_id = A.author_id
    WHERE BA.book_id = @BookID
);
GO

-- Test / Execution:
SELECT * FROM dbo.fn_GetBookAuthors(1);
GO
-------4. Returns the average (1-5) rating for a given book_id from the FEEDBACK table. If no feedback, returns NULL.

CREATE FUNCTION fn_GetAverageBookRating(@BookID INT)
RETURNS DECIMAL(4,2)
AS
BEGIN
    DECLARE @AvgRating DECIMAL(4,2);

    SELECT @AvgRating = AVG(CAST(rating AS DECIMAL(4,2)))
    FROM FEEDBACK
    WHERE book_id = @BookID;

    RETURN @AvgRating;
END;
GO

-- Test / Execution:
SELECT dbo.fn_GetAverageBookRating(1) AS AvgRating;

GO







USE DMDD_Group10
GO
----------------------------VIEWS----------------------

-- 1. Displays book info, including library, genre, and publisher details.

CREATE OR ALTER VIEW vw_BookInformation
AS
SELECT 
    B.book_id,
    B.title,
    B.isbn,
    L.name AS library_name,
    G.genre_type,
    P.name AS publisher_name,
    B.publication_date
FROM BOOK B
JOIN LIBRARY L ON B.library_id = L.library_id
JOIN GENRE G ON B.genre_id = G.genre_id
JOIN PUBLISHER P ON B.publisher_id = P.publisher_id;
GO

-- Test:
SELECT * FROM vw_BookInformation;
GO


--2. Shows all members who have at least one "Active" membership status.
CREATE OR ALTER VIEW vw_ActiveMembers
AS
SELECT 
    M.member_id,
    M.first_name,
    M.last_name,
    M.email,
    M.phone,
    Mem.membership_status,
    Mem.registration_date,
    L.name AS library_name
FROM MEMBER M
JOIN MEMBERSHIP Mem ON M.member_id = Mem.member_id
JOIN LIBRARY L ON Mem.library_id = L.library_id
WHERE Mem.membership_status = 'Active';
GO

-- Test:
SELECT * FROM vw_ActiveMembers;
GO

--3. Lists all overdue transactions with member name (via fn_GetFullMemberName) and book info.
CREATE OR ALTER VIEW vw_OverdueTransactions
AS
SELECT 
    T.transaction_id,
    T.member_id,
    M.first_name + ' ' + M.last_name AS member_name,
    T.copy_id,
    B.title AS book_title,
    T.borrow_date,
    T.due_date,
    T.return_date,
    T.transaction_status
FROM [TRANSACTION] T
JOIN COPY C ON T.copy_id = C.copy_id
JOIN BOOK B ON C.book_id = B.book_id
JOIN MEMBER M ON T.member_id = M.member_id
WHERE T.transaction_status = 'Overdue';
GO

-- Test:
SELECT * FROM vw_OverdueTransactions;
GO


--4. Shows feedback from members, including average rating for each book.

CREATE OR ALTER VIEW vw_MemberFeedback
AS
SELECT 
    F.feedback_id,
    F.book_id,
    B.title AS book_title,
    F.member_id,
    M.first_name + ' ' + M.last_name AS member_name,
    F.feedback_date,
    F.rating,
    F.comment,
    dbo.fn_GetAverageBookRating(F.book_id) AS average_rating_for_book
FROM FEEDBACK F
JOIN BOOK B ON F.book_id = B.book_id
JOIN MEMBER M ON F.member_id = M.member_id;
GO

-- Test:
SELECT * FROM vw_MemberFeedback;
GO

--5 . Shows staff details along with their library name.

CREATE OR ALTER VIEW vw_StaffDetails
AS
SELECT 
    S.staff_id,
    S.first_name,
    S.last_name,
    S.role,
    S.email,
    S.phone,
    L.name AS library_name
FROM STAFF S
JOIN LIBRARY L ON S.library_id = L.library_id;
GO

-- Test:
SELECT * FROM vw_StaffDetails;

GO

-- more ComplexViews for reports

-- 6. This view groups borrowing transactions by year and month, reporting total borrows and the average loan duration. It helps visualize seasonal borrowing patterns and overall trends.
CREATE OR ALTER VIEW vw_BorrowingTrends AS
SELECT 
    DATEPART(YEAR, borrow_date) AS BorrowYear,
    DATEPART(MONTH, borrow_date) AS BorrowMonth,
    COUNT(transaction_id) AS TotalBorrows,
    AVG(DATEDIFF(DAY, borrow_date, due_date)) AS AvgLoanDuration
FROM [TRANSACTION]
GROUP BY DATEPART(YEAR, borrow_date), DATEPART(MONTH, borrow_date);
GO

SELECT * from vw_BorrowingTrends

GO


-- 7. This view aggregates overdue transactions by year and month, including the total number of overdue transactions and the sum of fines. It’s useful for tracking overdue trends and the financial impact of late returns.
CREATE OR ALTER VIEW vw_OverdueStatistics AS
SELECT 
    DATEPART(YEAR, T.due_date) AS DueYear,
    DATEPART(MONTH, T.due_date) AS DueMonth,
    COUNT(T.transaction_id) AS OverdueTransactions,
    ISNULL(SUM(F.amount), 0) AS TotalFines
FROM [TRANSACTION] T
LEFT JOIN FINE F ON T.transaction_id = F.transaction_id
WHERE T.transaction_status = 'Overdue'
GROUP BY DATEPART(YEAR, T.due_date), DATEPART(MONTH, T.due_date);
GO

Select * from vw_OverdueStatistics

GO


-- 8. This view combines member details with key activity metrics—membership duration, total transactions, total reservations, and average feedback rating. It gives a comprehensive picture of each member’s engagement.

CREATE OR ALTER VIEW vw_MemberActivitySummary AS
SELECT 
    M.member_id,
    M.first_name,
    M.last_name,
    DATEDIFF(DAY, Mem.registration_date, GETDATE()) AS MembershipDurationDays,
    (SELECT COUNT(*) FROM [TRANSACTION] T WHERE T.member_id = M.member_id) AS TotalTransactions,
    (SELECT COUNT(*) FROM RESERVATION R WHERE R.member_id = M.member_id) AS TotalReservations,
    (SELECT AVG(CAST(F.rating AS DECIMAL(4,2))) 
     FROM FEEDBACK F 
     WHERE F.member_id = M.member_id) AS AvgRating
FROM MEMBER M
JOIN MEMBERSHIP Mem ON M.member_id = Mem.member_id;
GO

select * from vw_MemberActivitySummary

GO


--9 This view aggregates performance metrics per book, including total borrows, average ratings, total reservations, total fines collected, and the date when the book was last borrowe

CREATE OR ALTER VIEW vw_BookPerformanceSummary AS
SELECT
    B.book_id,
    B.title,
    L.name AS LibraryName,
    COUNT(DISTINCT T.transaction_id) AS TotalBorrows,
    COUNT(F.feedback_id) AS NumberOfRatings,
    AVG(CAST(F.rating AS DECIMAL(4,2))) AS AverageRating,
    COUNT(DISTINCT R.reservation_id) AS TotalReservations,
    ISNULL(SUM(FINE.amount), 0) AS TotalFines,
    MAX(T.borrow_date) AS LastBorrowedDate
FROM BOOK B
JOIN LIBRARY L ON B.library_id = L.library_id
LEFT JOIN COPY C ON B.book_id = C.book_id
LEFT JOIN [TRANSACTION] T ON C.copy_id = T.copy_id
LEFT JOIN FEEDBACK F ON B.book_id = F.book_id
LEFT JOIN RESERVATION R ON B.book_id = R.book_id
LEFT JOIN FINE ON T.transaction_id = FINE.transaction_id
GROUP BY B.book_id, B.title, L.name;
GO


select * from vw_BookPerformanceSummary

GO

--10 It aggregates key data such as total books, member count (via memberships), total transactions (including overdue counts), average loan duration, and the total fines collected.

CREATE OR ALTER VIEW vw_LibraryOperationsDashboard AS
SELECT
    L.library_id,
    L.name AS LibraryName,
    COUNT(DISTINCT B.book_id) AS TotalBooks,
    (SELECT COUNT(*) FROM MEMBERSHIP M WHERE M.library_id = L.library_id) AS TotalMembers,
    COUNT(DISTINCT T.transaction_id) AS TotalTransactions,
    SUM(CASE WHEN T.transaction_status = 'Overdue' THEN 1 ELSE 0 END) AS OverdueTransactions,
    AVG(DATEDIFF(DAY, T.borrow_date, T.due_date)) AS AvgLoanDuration,
    ISNULL(SUM(F.amount), 0) AS TotalFinesCollected
FROM LIBRARY L
LEFT JOIN BOOK B ON L.library_id = B.library_id
LEFT JOIN COPY C ON B.book_id = C.book_id
LEFT JOIN [TRANSACTION] T ON C.copy_id = T.copy_id
LEFT JOIN FINE F ON T.transaction_id = F.transaction_id
GROUP BY L.library_id, L.name;
GO


select * from vw_LibraryOperationsDashboard







USE DMDD_Group10
GO
------------------TRIGGERS----------------------

-- 1. After UPDATE on [TRANSACTION]. If transaction_status changes to 'Completed' and the book is returned late, automatically insert a Fine using UDF: fn_CalculateLateFee.

CREATE OR ALTER TRIGGER trg_Transaction_AutoFine
ON [TRANSACTION]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Insert a fine for each updated row that meets conditions
    INSERT INTO FINE (transaction_id, amount, issue_date, payment_status)
    SELECT 
        i.transaction_id,
        dbo.fn_CalculateLateFee(i.transaction_id),
        GETDATE(),
        'Unpaid'
    FROM inserted i
    JOIN deleted d ON i.transaction_id = d.transaction_id
    WHERE 
        d.transaction_status IN ('Active','Overdue')
        AND i.transaction_status = 'Completed'
        AND i.return_date IS NOT NULL
        AND i.return_date > i.due_date; -- Book was returned late
END;
GO

-- How to test:
-- 1) Pick an "Active" transaction that is overdue.
-- 2) Update it to "Completed" with a return_date > due_date.
-- Example:
UPDATE [TRANSACTION]
SET return_date = DATEADD(DAY, 5, due_date), transaction_status = 'Completed'
WHERE transaction_id = 3;  -- triggers fine insertion if overdue
SELECT * FROM FINE WHERE transaction_id = 3;

GO

----2. After UPDATE on RESERVATION. If reservation_status changes to 'Fulfilled', automatically mark one copy of that book as 'Reserved' (if an Available copy exists).

-- We need a temp table #TempBookIDs, so let's define it in the trigger:
-- For the sake of demonstration, define a temporary table inside the trigger:
--   CREATE TABLE #TempBookIDs (book_id INT);

-- Full version with local temp table inside the trigger:
CREATE OR ALTER TRIGGER trg_Reservation_FulfillCopy
ON RESERVATION
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Create a temporary table to hold the affected book_ids
    CREATE TABLE #TempBookIDs (book_id INT);

    INSERT INTO #TempBookIDs (book_id)
    SELECT i.book_id
    FROM inserted i
    JOIN deleted d ON i.reservation_id = d.reservation_id
    WHERE d.reservation_status <> 'Fulfilled'
      AND i.reservation_status = 'Fulfilled';

    DECLARE @BookID INT;
    DECLARE c CURSOR LOCAL FAST_FORWARD FOR
    SELECT book_id FROM #TempBookIDs;

    OPEN c;
    FETCH NEXT FROM c INTO @BookID;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        ;WITH CTE AS (
            SELECT TOP (1) copy_id
            FROM COPY
            WHERE book_id = @BookID
              AND availability_status = 'Available'
            ORDER BY purchase_date DESC
        )
        UPDATE COPY
        SET availability_status = 'Reserved'
        WHERE copy_id IN (SELECT copy_id FROM CTE);

        FETCH NEXT FROM c INTO @BookID;
    END

    CLOSE c;
    DEALLOCATE c;
END;
GO



-- Test:
UPDATE RESERVATION
SET reservation_status = 'Fulfilled'
WHERE reservation_id = 1; -- Will try to reserve an available copy for book_id=3
SELECT * FROM COPY WHERE book_id = 3;
GO

--3. After UPDATE on COPY. If condition changes to 'Damaged', automatically set availability_status to 'Unavailable'.


CREATE TRIGGER trg_Copy_Condition
ON COPY
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE COPY
    SET availability_status = 'Unavailable'
    FROM COPY C
    JOIN inserted i ON C.copy_id = i.copy_id
    JOIN deleted d ON i.copy_id = d.copy_id
    WHERE d.condition <> 'Damaged'
      AND i.condition = 'Damaged';
END;
GO

-- Test:
UPDATE COPY
SET condition = 'Damaged'
WHERE copy_id = 2; -- Then see if availability_status is set to 'Unavailable'.
SELECT * FROM COPY WHERE copy_id = 2;
GO

--4.  After UPDATE on MEMBERSHIP. If membership status changes from 'Active' to 'Suspended', check if the user has any overdue transactions. If they do, we leave it as is. If not, we might revert them back or do some logic. This is just an example of additional checks.

CREATE TRIGGER trg_MembershipStatusChange
ON MEMBERSHIP
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Example logic:
    -- If membership changes from 'Active' to 'Suspended', 
    -- but the member has NO overdue transactions, revert to 'Active'.

    UPDATE MEMBERSHIP
    SET membership_status = 'Active'
    FROM MEMBERSHIP M
    JOIN inserted i ON M.member_library_id = i.member_library_id
    JOIN deleted d ON i.member_library_id = d.member_library_id
    WHERE d.membership_status = 'Active'
      AND i.membership_status = 'Suspended'
      AND NOT EXISTS (
          SELECT 1
          FROM [TRANSACTION] T
          WHERE T.member_id = M.member_id
            AND T.transaction_status = 'Overdue'
      );
END;
GO

-- Test:
-- 1) Suppose membership_id=1 is Active, but the member has no Overdue transactions.
-- 2) Try updating it to Suspended:
UPDATE MEMBERSHIP
SET membership_status = 'Suspended'
WHERE member_library_id = 1;
-- The trigger will revert it to 'Active' if no Overdue transactions exist.
SELECT * FROM MEMBERSHIP WHERE member_library_id=1;

GO


--5. After INSERT on FEEDBACK. If rating < 3, we insert a record into a hypothetical LOW_RATING_LOG table or just raise a notice. Here we’ll do a simple example that logs to a table (assuming it exists). If not, just demonstrate logic.
CREATE TABLE LOW_RATING_LOG (
    log_id INT PRIMARY KEY IDENTITY(1,1),
    feedback_id INT,
    member_id INT,
    book_id INT,
    rating INT,
    comment VARCHAR(MAX),
    logged_date DATETIME
);
GO

ALTER TABLE FEEDBACK
ALTER COLUMN comment VARCHAR(MAX);

GO

CREATE TRIGGER trg_FeedbackInsert
ON FEEDBACK
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- If you want to log negative feedback to a separate table, do:
    INSERT INTO LOW_RATING_LOG(feedback_id, member_id, book_id, rating, comment, logged_date)
    SELECT 
        i.feedback_id,
        i.member_id,
        i.book_id,
        i.rating,
        i.comment,
        GETDATE()
    FROM inserted i
    WHERE i.rating < 3;  -- threshold for "low" rating
END;
GO

-- Test:
INSERT INTO FEEDBACK (book_id, member_id, feedback_date, rating, comment)
VALUES (1, 2, GETDATE(), 2, 'Not my favorite book');
SELECT * FROM LOW_RATING_LOG;  -- Should have a new entry
GO








USE DMDD_Group10
GO

------------------------------STORED PROCEDURES---------------------------------

-- 1. Inserts a new BOOK record, returning the new book_id as output.
CREATE OR ALTER PROCEDURE sp_AddNewBook
    @LibraryID INT,
    @GenreID INT,
    @PublisherID INT,
    @Title VARCHAR(255),
    @ISBN VARCHAR(20),
    @PublicationDate DATE,
    @NewBookID INT OUTPUT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        SET NOCOUNT ON;

        INSERT INTO BOOK (library_id, genre_id, publisher_id, title, isbn, publication_date)
        VALUES (@LibraryID, @GenreID, @PublisherID, @Title, @ISBN, @PublicationDate);

        SET @NewBookID = SCOPE_IDENTITY();

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR('Error adding new book: %s', @ErrorSeverity, @ErrorState, @ErrorMessage);
    END CATCH
END;
GO

-- Test:
DECLARE @BookID INT;
EXEC sp_AddNewBook 
    @LibraryID = 1,
    @GenreID = 2,
    @PublisherID = 3,
    @Title = 'Test Book',
    @ISBN = '999-1234567890',
    @PublicationDate = '2025-01-01',
    @NewBookID = @BookID OUTPUT;
SELECT @BookID AS 'NewlyCreatedBookID';
GO


--2. Creates a new transaction for borrowing a book (if a copy is Available). Marks that copy as Unavailable. Returns new transaction_id.
CREATE OR ALTER PROCEDURE sp_BorrowBook
    @MemberID INT,
    @BookID INT,
    @StaffID INT,
    @NewTransactionID INT OUTPUT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        SET NOCOUNT ON;

    -- Find an available copy of the requested book
        DECLARE @CopyID INT;
        SELECT TOP 1 @CopyID = copy_id
        FROM COPY
        WHERE book_id = @BookID
          AND availability_status = 'Available'
        ORDER BY purchase_date DESC;

        IF @CopyID IS NULL
        BEGIN
            RAISERROR('No available copy for this book. Please reserve the book to borrow it when available', 16, 1);
            RETURN;
        END
 -- Mark the copy as Unavailable
        UPDATE COPY
        SET availability_status = 'Unavailable'
        WHERE copy_id = @CopyID;

-- Create a new transaction (14-day due date from today)
        INSERT INTO [TRANSACTION] (member_id, copy_id, staff_id, borrow_date, due_date, return_date, transaction_status)
        VALUES (@MemberID, @CopyID, @StaffID, GETDATE(), DATEADD(DAY,14,GETDATE()), NULL, 'Active');

        SET @NewTransactionID = SCOPE_IDENTITY();

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
    
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR('Error borrowing book: %s', @ErrorSeverity, @ErrorState, @ErrorMessage);
    END CATCH
END;
GO

-- Test:
DECLARE @TransID INT;
EXEC sp_BorrowBook 
    @MemberID = 1,
    @BookID = 2,
    @StaffID = 1,
    @NewTransactionID = @TransID OUTPUT;
SELECT @TransID AS 'NewTransactionID';
GO


--3. Marks a transaction as Completed, sets return_date=GETDATE(), calculates late fee via fn_CalculateLateFee, and sets the copy’s availability back to Available if not damaged. Returns the @LateFee.


-- 1) Update the transaction's return_date and mark as Completed.
CREATE OR ALTER PROCEDURE sp_ReturnBook
    @TransactionID INT,
    @LateFee DECIMAL(10,2) OUTPUT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        SET NOCOUNT ON;

        UPDATE [TRANSACTION]
        SET return_date = GETDATE(),
            transaction_status = 'Completed'
        WHERE transaction_id = @TransactionID;

-- 2) Get the copy_id associated with the transaction.
        DECLARE @CopyID INT;
        SELECT @CopyID = copy_id
        FROM [TRANSACTION]
        WHERE transaction_id = @TransactionID;


-- 3) Get the condition of the copy.
        DECLARE @Condition VARCHAR(20);
        SELECT @Condition = [condition]
        FROM COPY
        WHERE copy_id = @CopyID;

        IF @Condition <> 'Damaged'
        BEGIN
-- 4) Check if a pending reservation exists for this book.
            DECLARE @BookID INT;
            SELECT @BookID = book_id
            FROM COPY
            WHERE copy_id = @CopyID;

            DECLARE @ReservationID INT;
            SELECT TOP 1 @ReservationID = reservation_id 
            FROM RESERVATION
            WHERE book_id = @BookID 
              AND reservation_status = 'Pending'
            ORDER BY reservation_date ASC;

            IF @ReservationID IS NOT NULL
            BEGIN
-- Set the copy's status to Reserved.
                UPDATE COPY SET availability_status = 'Available' WHERE copy_id = @CopyID;

-- Update the reservation to Fulfilled.
                UPDATE RESERVATION SET reservation_status = 'Fulfilled' WHERE reservation_id = @ReservationID;
            END
            ELSE
            BEGIN

-- No pending reservation: set copy to Available.
                UPDATE COPY SET availability_status = 'Available' WHERE copy_id = @CopyID;
            END
        END
 -- 5) Calculate the late fee using the UDF.
        SELECT @LateFee = dbo.fn_CalculateLateFee(@TransactionID);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR('Error returning book: %s', @ErrorSeverity, @ErrorState, @ErrorMessage);
    END CATCH
END;
GO

-- Test:
DECLARE @Fee DECIMAL(10,2);
EXEC sp_ReturnBook @TransactionID = 11, @LateFee = @Fee OUTPUT;
SELECT @Fee AS 'LateFee';
GO



--4 . Creates a new reservation, defaulting status to Pending. Returns new reservation_id.


CREATE OR ALTER PROCEDURE sp_ReserveBook
    @MemberID INT,
    @BookID INT,
    @StaffID INT,
    @NewReservationID INT OUTPUT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        SET NOCOUNT ON;
    -- Check if any copy of the book is available.
        IF EXISTS (
           SELECT 1 
           FROM COPY 
           WHERE book_id = @BookID 
             AND availability_status = 'Available'
        )
        BEGIN
           RAISERROR('Book is already available; please borrow it instead of reserving.', 16, 1);
           RETURN;
        END
-- Check if there's already a pending reservation for this book.
        IF EXISTS (
           SELECT 1 
           FROM RESERVATION 
           WHERE book_id = @BookID 
             AND reservation_status = 'Pending'
        )
        BEGIN
           RAISERROR('This book is already reserved. Please wait for your turn.', 16, 1);
           RETURN;
        END

-- If no copy is available and no pending reservation exists, create a pending reservation.
        INSERT INTO RESERVATION (member_id, book_id, staff_id, reservation_date, reservation_status)
        VALUES (@MemberID, @BookID, @StaffID, GETDATE(), 'Pending');

        SET @NewReservationID = SCOPE_IDENTITY();

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR('Error reserving book: %s', @ErrorSeverity, @ErrorState, @ErrorMessage);
    END CATCH
END;
GO

-- Test:
DECLARE @ResID INT;
EXEC sp_ReserveBook 
    @MemberID = 2,
    @BookID = 6,
    @StaffID = 2,
    @NewReservationID = @ResID OUTPUT;
SELECT @ResID AS 'NewReservationID';
GO



--5. Updates a membership record’s status. Returns the old status as output.


CREATE OR ALTER PROCEDURE sp_UpdateMembershipStatus
    @MembershipID INT,
    @NewStatus VARCHAR(20),
    @OldStatus VARCHAR(20) OUTPUT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        SET NOCOUNT ON;

        SELECT @OldStatus = membership_status
        FROM MEMBERSHIP
        WHERE member_library_id = @MembershipID;

        UPDATE MEMBERSHIP
        SET membership_status = @NewStatus
        WHERE member_library_id = @MembershipID;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR('Error updating membership status: %s', @ErrorSeverity, @ErrorState, @ErrorMessage);
    END CATCH
END;
GO

-- Test:
DECLARE @Old VARCHAR(20);
EXEC sp_UpdateMembershipStatus 
    @MembershipID = 1,
    @NewStatus = 'Suspended',
    @OldStatus = @Old OUTPUT;
SELECT @Old AS 'OldMembershipStatus';
GO



-- 6. Returns all transactions for a member, plus the total count as an output parameter.

CREATE OR ALTER PROCEDURE sp_GetMemberTransactionHistory
    @MemberID INT,
    @TotalTransactions INT OUTPUT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        SET NOCOUNT ON;

-- Return the transaction list

        SELECT 
            T.transaction_id,
            T.borrow_date,
            T.due_date,
            T.return_date,
            T.transaction_status,
            B.title AS book_title
        FROM [TRANSACTION] T
        JOIN COPY C ON T.copy_id = C.copy_id
        JOIN BOOK B ON C.book_id = B.book_id
        WHERE T.member_id = @MemberID;

 -- Count

        SELECT @TotalTransactions = COUNT(*)
        FROM [TRANSACTION]
        WHERE member_id = @MemberID;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR('Error retrieving member transaction history: %s', @ErrorSeverity, @ErrorState, @ErrorMessage);
    END CATCH
END;
GO

-- Test:
DECLARE @Count INT;
EXEC sp_GetMemberTransactionHistory 
    @MemberID = 1,
    @TotalTransactions = @Count OUTPUT;
SELECT @Count AS 'TotalTransactionsForMember1';
GO

