USE master;
GO

IF EXISTS (SELECT name FROM sys.databases WHERE name = 'DMDD_Group10')
BEGIN
    ALTER DATABASE DMDD_Group10 SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DMDD_Group10;
END
GO
-- Create database if it doesn't exist
DROP DATABASE IF EXISTS DMDD_Group10;
CREATE DATABASE DMDD_Group10;
GO 

USE DMDD_Group10;
GO
-- Drop all tables if they exist (in reverse order of creation to handle foreign key constraints)
DROP TABLE IF EXISTS FINE;
DROP TABLE IF EXISTS FEEDBACK;
DROP TABLE IF EXISTS RESERVATION;
DROP TABLE IF EXISTS COPY;
DROP TABLE IF EXISTS [TRANSACTION];
DROP TABLE IF EXISTS BOOK_AUTHOR;
DROP TABLE IF EXISTS BOOK;
DROP TABLE IF EXISTS GENRE;
DROP TABLE IF EXISTS STAFF;
DROP TABLE IF EXISTS MEMBER;
DROP TABLE IF EXISTS MEMBERSHIP;
DROP TABLE IF EXISTS LIBRARY;
DROP TABLE IF EXISTS AUTHOR;
DROP TABLE IF EXISTS PUBLISHER;



-- Create LIBRARY table
CREATE TABLE LIBRARY (
    library_id INT PRIMARY KEY IDENTITY(1,1),
    name VARCHAR(100) NOT NULL,
    location VARCHAR(255) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(100) NOT NULL,
    working_hours VARCHAR(100) NOT NULL
);

-- Create MEMBER table
CREATE TABLE MEMBER (
    member_id INT PRIMARY KEY IDENTITY(1,1),
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    join_date DATE NOT NULL
);

-- Create AUTHOR table
CREATE TABLE AUTHOR (
    author_id INT PRIMARY KEY IDENTITY(1,1),
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    date_of_birth DATE,
    nationality VARCHAR(50) NOT NULL
);

-- Create PUBLISHER table
CREATE TABLE PUBLISHER (
    publisher_id INT PRIMARY KEY IDENTITY(1,1),
    name VARCHAR(100) NOT NULL,
    address VARCHAR(255),
    phone_number VARCHAR(20),
    email VARCHAR(100) NOT NULL
);

-- Create GENRE table
CREATE TABLE GENRE (
    genre_id INT PRIMARY KEY IDENTITY(1,1),
    genre_type VARCHAR(50) NOT NULL,
    description TEXT,
    popularity_score DECIMAL(3,1),
    created_date DATE NOT NULL,
    CONSTRAINT chk_popularity_score CHECK (popularity_score >= 0 AND popularity_score <= 10)
);

-- Create BOOK table
CREATE TABLE BOOK (
    book_id INT PRIMARY KEY IDENTITY(1,1),
    library_id INT NOT NULL,
    genre_id INT NOT NULL,
    publisher_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    isbn VARCHAR(20) NOT NULL,
    publication_date DATE NOT NULL,
    CONSTRAINT FK_Book_Library FOREIGN KEY (library_id) REFERENCES LIBRARY(library_id),
    CONSTRAINT FK_Book_Genre FOREIGN KEY (genre_id) REFERENCES GENRE(genre_id),
    CONSTRAINT FK_Book_Publisher FOREIGN KEY (publisher_id) REFERENCES PUBLISHER(publisher_id)
);

-- Create BOOK_AUTHOR junction table
CREATE TABLE BOOK_AUTHOR (
    book_id INT NOT NULL,
    author_id INT NOT NULL,
    author_role VARCHAR(50) NOT NULL,
    contribution_percentage DECIMAL(5,2),
    special_acknowledgement TEXT,
    PRIMARY KEY (book_id, author_id),
    CONSTRAINT FK_BookAuthor_Book FOREIGN KEY (book_id) REFERENCES BOOK(book_id),
    CONSTRAINT FK_BookAuthor_Author FOREIGN KEY (author_id) REFERENCES AUTHOR(author_id),
    CONSTRAINT chk_contribution_percentage CHECK (contribution_percentage > 0 AND contribution_percentage <= 100)
);

-- Create STAFF table
CREATE TABLE STAFF (
    staff_id INT PRIMARY KEY IDENTITY(1,1),
    library_id INT NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    role VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    CONSTRAINT FK_Staff_Library FOREIGN KEY (library_id) REFERENCES LIBRARY(library_id)
);

-- Create COPY table
CREATE TABLE COPY (
    copy_id INT PRIMARY KEY IDENTITY(1,1),
    book_id INT NOT NULL,
    condition VARCHAR(20) NOT NULL,
    purchase_date DATE NOT NULL,
    availability_status VARCHAR(20) NOT NULL,
    CONSTRAINT FK_Copy_Book FOREIGN KEY (book_id) REFERENCES BOOK(book_id),
    CONSTRAINT chk_condition CHECK (condition IN ('New', 'Good', 'Fair', 'Poor', 'Damaged')),
    CONSTRAINT chk_availability_status CHECK (availability_status IN ('Available', 'Unavailable', 'Reserved'))
);

-- Create TRANSACTION table
CREATE TABLE [TRANSACTION] (
    transaction_id INT PRIMARY KEY IDENTITY(1,1),
    member_id INT NOT NULL,
    copy_id INT NOT NULL,
    staff_id INT NOT NULL,
    borrow_date DATE NOT NULL,
    due_date DATE NOT NULL,
    return_date DATE,
    transaction_status VARCHAR(20) NOT NULL,
    CONSTRAINT FK_Transaction_Member FOREIGN KEY (member_id) REFERENCES MEMBER(member_id),
    CONSTRAINT FK_Transaction_Copy FOREIGN KEY (copy_id) REFERENCES COPY(copy_id),
    CONSTRAINT FK_Transaction_Staff FOREIGN KEY (staff_id) REFERENCES STAFF(staff_id),
    CONSTRAINT chk_transaction_status CHECK (transaction_status IN ('Active', 'Completed', 'Overdue', 'Lost'))
);

-- Create RESERVATION table
CREATE TABLE RESERVATION (
    reservation_id INT PRIMARY KEY IDENTITY(1,1),
    member_id INT NOT NULL,
    book_id INT NOT NULL,
    staff_id INT NOT NULL,
    reservation_date DATE NOT NULL,
    reservation_status VARCHAR(20) NOT NULL,
    CONSTRAINT FK_Reservation_Member FOREIGN KEY (member_id) REFERENCES MEMBER(member_id),
    CONSTRAINT FK_Reservation_Book FOREIGN KEY (book_id) REFERENCES BOOK(book_id),
    CONSTRAINT FK_Reservation_Staff FOREIGN KEY (staff_id) REFERENCES STAFF(staff_id),
    CONSTRAINT chk_reservation_status CHECK (reservation_status IN ('Pending', 'Fulfilled', 'Cancelled', 'Expired'))
);

-- Create FEEDBACK table
CREATE TABLE FEEDBACK (
    feedback_id INT PRIMARY KEY IDENTITY(1,1),
    book_id INT NOT NULL,
    member_id INT NOT NULL,
    feedback_date DATE NOT NULL,
    rating INT NOT NULL,
    comment TEXT,
    CONSTRAINT FK_Feedback_Book FOREIGN KEY (book_id) REFERENCES BOOK(book_id),
    CONSTRAINT FK_Feedback_Member FOREIGN KEY (member_id) REFERENCES MEMBER(member_id),
    CONSTRAINT chk_rating CHECK (rating >= 1 AND rating <= 5)
);

-- Create FINE table
CREATE TABLE FINE (
    fine_id INT PRIMARY KEY IDENTITY(1,1),
    transaction_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    issue_date DATE NOT NULL,
    payment_status VARCHAR(20) NOT NULL,
    CONSTRAINT FK_Fine_Transaction FOREIGN KEY (transaction_id) REFERENCES [TRANSACTION](transaction_id),
    CONSTRAINT chk_amount CHECK (amount > 0),
    CONSTRAINT chk_payment_status CHECK (payment_status IN ('Paid', 'Unpaid', 'Waived'))
);


CREATE TABLE MEMBERSHIP (
    member_library_id INT PRIMARY KEY IDENTITY(1,1),  -- Use IDENTITY for auto-increment in SQL Server
    library_id INT NOT NULL,
    member_id INT NOT NULL,
    registration_date DATE NOT NULL,
    membership_status VARCHAR(20) NOT NULL,
    CONSTRAINT chk_membership_status CHECK (membership_status IN ('Active', 'Expired', 'Suspended', 'Pending')),
    CONSTRAINT FK_Membership_Member FOREIGN KEY (member_id) REFERENCES MEMBER(member_id),
    CONSTRAINT FK_Membership_Library FOREIGN KEY (library_id) REFERENCES LIBRARY(library_id)
);
