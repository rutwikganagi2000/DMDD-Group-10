USE DMDD_Group10
GO
----------------------------VIEWS----------------------

-- 1. Displays book info, including library, genre, and publisher details.

CREATE VIEW vw_BookInformation
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
CREATE VIEW vw_ActiveMembers
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
CREATE VIEW vw_OverdueTransactions
AS
SELECT 
    T.transaction_id,
    T.member_id,
    dbo.fn_GetFullMemberName(T.member_id) AS member_name,
    T.copy_id,
    B.title AS book_title,
    T.borrow_date,
    T.due_date,
    T.return_date,
    T.transaction_status
FROM [TRANSACTION] T
JOIN COPY C ON T.copy_id = C.copy_id
JOIN BOOK B ON C.book_id = B.book_id
WHERE T.transaction_status = 'Overdue';
GO

-- Test:
SELECT * FROM vw_OverdueTransactions;
GO


--4. Shows feedback from members, including average rating for each book.

CREATE VIEW vw_MemberFeedback
AS
SELECT 
    F.feedback_id,
    F.book_id,
    B.title AS book_title,
    F.member_id,
    dbo.fn_GetFullMemberName(F.member_id) AS member_name,
    F.feedback_date,
    F.rating,
    F.comment,
    dbo.fn_GetAverageBookRating(F.book_id) AS average_rating_for_book
FROM FEEDBACK F
JOIN BOOK B ON F.book_id = B.book_id;
GO

-- Test:
SELECT * FROM vw_MemberFeedback;
GO

--5 . Shows staff details along with their library name.

CREATE VIEW vw_StaffDetails
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
