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
