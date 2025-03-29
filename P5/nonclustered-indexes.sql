USE DMDD_Group10
GO
------------------ Below are at least 3 non-clustered indexes. Adjust as desired:-----------------------

-- 1) Index on MEMBER last_name for faster lookups
CREATE NONCLUSTERED INDEX idx_Member_LastName
ON MEMBER(last_name);

-- 2) Index on BOOK title
CREATE NONCLUSTERED INDEX idx_Book_Title
ON BOOK(title);

-- 3) Index on [TRANSACTION] due_date
CREATE NONCLUSTERED INDEX idx_Transaction_DueDate
ON [TRANSACTION](due_date);

-- 4) Index on MEMBER(email) for faster lookups by email address.
CREATE NONCLUSTERED INDEX idx_Member_Email
ON MEMBER(email);

-- 5) Index on [TRANSACTION](member_id) for quick filtering of transactions by member.
CREATE NONCLUSTERED INDEX idx_Transaction_MemberID
ON [TRANSACTION](member_id);

-- 6) Index on FEEDBACK(book_id) to speed up aggregations and filtering of feedback by book.
CREATE NONCLUSTERED INDEX idx_Feedback_BookID
ON FEEDBACK(book_id);

-- Check that indexes were created:
SELECT name, index_id, object_id
FROM sys.indexes
WHERE name LIKE 'idx_%';


