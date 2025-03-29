USE DMDD_Group10
GO

------------------------------STORED PROCEDURES---------------------------------

-- 1. Inserts a new BOOK record, returning the new book_id as output.
CREATE PROCEDURE sp_AddNewBook
    @LibraryID INT,
    @GenreID INT,
    @PublisherID INT,
    @Title VARCHAR(255),
    @ISBN VARCHAR(20),
    @PublicationDate DATE,
    @NewBookID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO BOOK (library_id, genre_id, publisher_id, title, isbn, publication_date)
    VALUES (@LibraryID, @GenreID, @PublisherID, @Title, @ISBN, @PublicationDate);

    SET @NewBookID = SCOPE_IDENTITY();
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
CREATE PROCEDURE sp_BorrowBook
    @MemberID INT,
    @BookID INT,
    @StaffID INT,
    @NewTransactionID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    -- Find an available copy of the requested book
    DECLARE @CopyID INT;
    SELECT TOP 1 @CopyID = copy_id
    FROM COPY
    WHERE book_id = @BookID
      AND availability_status = 'Available'
    ORDER BY purchase_date DESC;  -- e.g., pick the newest copy

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

CREATE PROCEDURE sp_ReturnBook
    @TransactionID INT,
    @LateFee DECIMAL(10,2) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    -- 1) Update the transaction's return_date and mark as Completed.
    UPDATE [TRANSACTION]
    SET 
        return_date = GETDATE(),
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
        ORDER BY reservation_date ASC;  -- Oldest reservation first

        IF @ReservationID IS NOT NULL
        BEGIN

            -- Set the copy's status to Reserved.
            UPDATE COPY
            SET availability_status = 'Available'
            WHERE copy_id = @CopyID;

            -- Update the reservation to Fulfilled.
            UPDATE RESERVATION
            SET reservation_status = 'Fulfilled'
            WHERE reservation_id = @ReservationID;

            
        END
        ELSE
        BEGIN
            -- No pending reservation: set copy to Available.
            UPDATE COPY
            SET availability_status = 'Available'
            WHERE copy_id = @CopyID;
        END
    END

    -- 5) Calculate the late fee using the UDF.
    SELECT @LateFee = dbo.fn_CalculateLateFee(@TransactionID);
END;
GO

-- Test:
DECLARE @Fee DECIMAL(10,2);
EXEC sp_ReturnBook @TransactionID =11, @LateFee = @Fee OUTPUT;
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
CREATE PROCEDURE sp_UpdateMembershipStatus
    @MembershipID INT,
    @NewStatus VARCHAR(20),
    @OldStatus VARCHAR(20) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT @OldStatus = membership_status
    FROM MEMBERSHIP
    WHERE member_library_id = @MembershipID;

    UPDATE MEMBERSHIP
    SET membership_status = @NewStatus
    WHERE member_library_id = @MembershipID;
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

--------------------


-- 6. Returns all transactions for a member, plus the total count as an output parameter.

CREATE PROCEDURE sp_GetMemberTransactionHistory
    @MemberID INT,
    @TotalTransactions INT OUTPUT
AS
BEGIN
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
END;
GO

-- Test:
DECLARE @Count INT;
EXEC sp_GetMemberTransactionHistory 
    @MemberID = 1,
    @TotalTransactions = @Count OUTPUT;
SELECT @Count AS 'TotalTransactionsForMember1';
GO






