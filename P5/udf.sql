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
SELECT dbo.fn_CalculateLateFee(3) AS LateFee;
-- (Assuming transaction_id=3 is overdue or returned late.)

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

-------5. Returns Full Name

CREATE FUNCTION fn_GetFullMemberName(@MemberID INT)
RETURNS VARCHAR(101)
AS
BEGIN
    DECLARE @FullName VARCHAR(101);
    SELECT @FullName = M.first_name + ' ' + M.last_name
    FROM MEMBER AS M
    WHERE M.member_id = @MemberID;
    RETURN @FullName;
END;
GO

-- Test / Execution:
SELECT dbo.fn_GetFullMemberName(1) AS FullName;

GO
-------------------












