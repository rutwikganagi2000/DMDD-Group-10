USE DMDD_Group10;

-- Insert data into LIBRARY table
INSERT INTO LIBRARY (name, location, phone, email, working_hours)
VALUES
('Snell Library', '360 Huntington Ave, Boston, MA 02115', '617-373-8778', 'ill@northeastern.edu', 'Mon-Thu 8am-10pm, Fri 8am-9pm, Sat 11am-9pm, Sun 11am-10pm'),
('F. W. Olin Library', '5000 MacArthur Blvd, Oakland, CA 94613', '510-430-2196', 'fwolin@northeastern.edu', 'Mon-Thu 8am-10pm, Fri 8am-9pm, Sat 11am-9pm, Sun 11am-10pm'),
('Northeastern University Health Sciences Library', '101 Medical Plaza, Boston, MA 02115', '617-555-1010', 'healthlibrary@northeastern.edu', 'Mon-Fri: 8am-8pm; Sat: 10am-4pm; Sun: Closed'),
('Northeastern University Silicon Valley Library', '123 Tech Way, San Jose, CA 95112', '408-555-9876', 'siliconvalleylibrary@northeastern.edu', 'Mon-Fri: 9am-6pm; Sat: 10am-4pm; Sun: Closed'),
('Northeastern University London Library', '50 City Rd, London, EC1Y 1AB, UK', '020-7946-1234', 'londonlibrary@northeastern.ac.uk', 'Mon-Fri: 9am-5pm; Sat-Sun: Closed'),
('Northeastern University Charlotte Library', '400 Trade St, Charlotte, NC 28202', '704-555-1234', 'charlottelibrary@northeastern.edu', 'Mon-Fri: 8am-6pm; Sat-Sun: Closed'),
('Northeastern University Arlington Library', '1501 N Royal St, Arlington, VA 22209', '703-555-5678', 'arlingtonlibrary@northeastern.edu', 'Mon-Fri: 8am-8pm; Sat: 10am-4pm; Sun: Closed'),
('Northeastern University Burlington Library', '1200 Maple St, Burlington, MA 01803', '781-555-7890', 'burlingtonlibrary@northeastern.edu', 'Mon-Fri: 9am-5pm; Sat-Sun: Closed'),
('Northeastern University Seattle Library', '500 Pine St, Seattle, WA 98101', '206-555-2468', 'seattlelibrary@northeastern.edu', 'Mon-Fri: 9am-6pm; Sat: 10am-4pm; Sun: Closed'),
('Northeastern University Toronto Library', '100 King St W, Toronto, ON M5X 1A9, Canada', '416-555-1357', 'torontolibrary@northeastern.edu', 'Mon-Fri: 9am-5pm; Sat-Sun: Closed');
GO

-- Insert data into MEMBER table
INSERT INTO MEMBER (first_name, last_name, email, phone, join_date)
VALUES 
('John', 'Smith', 'john.smith@email.com', '555-111-2222', '2020-03-15'),
('Sarah', 'Johnson', 'sarah.j@email.com', '555-222-3333', '2019-07-22'),
('Michael', 'Williams', 'mwilliams@email.com', '555-333-4444', '2021-01-10'),
('Emily', 'Brown', 'emily.brown@email.com', '555-444-5555', '2018-11-05'),
('David', 'Jones', 'david.jones@email.com', '555-555-6666', '2022-02-28'),
('Jessica', 'Garcia', 'jgarcia@email.com', '555-666-7777', '2020-09-17'),
('Robert', 'Miller', 'rmiller@email.com', '555-777-8888', '2021-05-03'),
('Jennifer', 'Davis', 'jdavis@email.com', '555-888-9999', '2019-12-20'),
('William', 'Rodriguez', 'wrodriguez@email.com', '555-999-0000', '2022-04-11'),
('Amanda', 'Martinez', 'amartinez@email.com', '555-000-1111', '2020-08-07'),
('Thomas', 'Wilson', 'twilson@email.com', '555-112-2233', '2021-11-15'),
('Elizabeth', 'Anderson', 'eanderson@email.com', '555-223-3344', '2019-03-29');
GO

-- Insert data into AUTHOR table
INSERT INTO AUTHOR (first_name, last_name, date_of_birth, nationality)
VALUES 
('Jane', 'Austen', '1775-12-16', 'British'),
('Ernest', 'Hemingway', '1899-07-21', 'American'),
('Gabriel', 'Garc a M rquez', '1927-03-06', 'Colombian'),
('Haruki', 'Murakami', '1949-01-12', 'Japanese'),
('Chimamanda', 'Adichie', '1977-09-15', 'Nigerian'),
('Stephen', 'King', '1947-09-21', 'American'),
('J.K.', 'Rowling', '1965-07-31', 'British'),
('Toni', 'Morrison', '1931-02-18', 'American'),
('Margaret', 'Atwood', '1939-11-18', 'Canadian'),
('Paulo', 'Coelho', '1947-08-24', 'Brazilian');
GO

-- Insert data into PUBLISHER table
INSERT INTO PUBLISHER (name, address, phone_number, email)
VALUES 
('Penguin Random House', '1745 Broadway, New York, NY 10019', '212-782-9000', 'info@penguinrandomhouse.com'),
('HarperCollins', '195 Broadway, New York, NY 10007', '212-207-7000', 'contact@harpercollins.com'),
('Simon & Schuster', '1230 Avenue of the Americas, New York, NY 10020', '212-698-7000', 'info@simonandschuster.com'),
('Macmillan Publishers', '120 Broadway, New York, NY 10271', '646-307-5151', 'info@macmillan.com'),
('Hachette Book Group', '1290 Avenue of the Americas, New York, NY 10104', '212-364-1100', 'contact@hachettebookgroup.com'),
('Oxford University Press', 'Great Clarendon Street, Oxford OX2 6DP, UK', '+44-1865-353535', 'info@oup.com'),
('Scholastic', '557 Broadway, New York, NY 10012', '212-343-6100', 'scholastic@scholastic.com'),
('Wiley', '111 River Street, Hoboken, NJ 07030', '201-748-6000', 'info@wiley.com'),
('Pearson Education', '221 River Street, Hoboken, NJ 07030', '201-236-7000', 'info@pearson.com'),
('McGraw-Hill Education', '1325 Avenue of the Americas, New York, NY 10019', '646-766-2000', 'customer.service@mheducation.com');
GO

-- Insert data into GENRE table
INSERT INTO GENRE (genre_type, description, popularity_score, created_date)
VALUES 
('Fiction', 'Narrative works created from imagination', 8.5, '2018-01-15'),
('Non-Fiction', 'Works based on facts and real events', 7.2, '2018-01-15'),
('Mystery', 'Stories focused on solving a crime or puzzle', 8.0, '2018-02-20'),
('Science Fiction', 'Speculative fiction dealing with advanced science and technology', 7.8, '2018-02-21'),
('Fantasy', 'Works involving magical or supernatural elements', 8.3, '2018-03-05'),
('Biography', 'Account of a person''s life written by someone else', 6.5, '2018-03-10'),
('History', 'Works focused on past events', 6.8, '2018-04-12'),
('Romance', 'Stories centered on romantic relationships', 7.5, '2018-05-15'),
('Self-Help', 'Books offering advice for personal improvement', 6.2, '2018-06-20'),
('Poetry', 'Literary works with rhythmic qualities of language', 5.5, '2018-07-25');
GO

-- Insert data into BOOK table
INSERT INTO BOOK (library_id, genre_id, publisher_id, title, isbn, publication_date)
VALUES 
(1, 1, 1, 'Pride and Prejudice', '9780141439518', '1813-01-28'),
(2, 3, 6, 'The Old Man and the Sea', '9780684801223', '1952-09-01'),
(1, 1, 3, 'One Hundred Years of Solitude', '9780060883287', '1967-05-30'),
(3, 4, 2, 'Norwegian Wood', '9780375704024', '1987-09-04'),
(4, 1, 5, 'Americanah', '9780307455925', '2013-05-14'),
(5, 5, 7, 'The Shining', '9780307743657', '1977-01-28'),
(6, 5, 7, 'Harry Potter and the Philosopher''s Stone', '9780747532743', '1997-06-26'),
(7, 1, 3, 'Beloved', '9781400033416', '1987-09-02'),
(8, 4, 1, 'The Handmaid''s Tale', '9780385490818', '1985-06-01'),
(9, 1, 2, 'The Alchemist', '9780062315007', '1988-04-25'),
(10, 2, 9, 'Sapiens: A Brief History of Humankind', '9780062316097', '2011-02-10'),
(1, 8, 5, 'The Notebook', '9780553816716', '1996-10-01');
GO

-- Insert data into MEMBERSHIP table
INSERT INTO MEMBERSHIP (library_id, member_id, registration_date, membership_status)
VALUES 
(1, 1, '2020-03-15', 'Active'),
(1, 2, '2019-07-22', 'Active'),
(2, 3, '2021-01-10', 'Active'),
(3, 4, '2018-11-05', 'Expired'),
(2, 5, '2022-02-28', 'Active'),
(4, 6, '2020-09-17', 'Suspended'),
(5, 7, '2021-05-03', 'Active'),
(6, 8, '2019-12-20', 'Active'),
(7, 9, '2022-04-11', 'Pending'),
(8, 10, '2020-08-07', 'Active'),
(9, 11, '2021-11-15', 'Active'),
(10, 12, '2019-03-29', 'Expired');
GO

-- Insert data into BOOK_AUTHOR table
INSERT INTO BOOK_AUTHOR (book_id, author_id, author_role, contribution_percentage, special_acknowledgement)
VALUES 
(1, 1, 'Primary Author', 100.00, NULL),
(2, 2, 'Primary Author', 100.00, NULL),
(3, 3, 'Primary Author', 100.00, 'Winner of Nobel Prize in Literature'),
(4, 4, 'Primary Author', 100.00, NULL),
(5, 5, 'Primary Author', 100.00, NULL),
(6, 6, 'Primary Author', 100.00, NULL),
(7, 7, 'Primary Author', 100.00, NULL),
(8, 8, 'Primary Author', 100.00, 'Winner of Pulitzer Prize'),
(9, 9, 'Primary Author', 100.00, NULL),
(10, 10, 'Primary Author', 100.00, NULL);
GO

-- Insert data into STAFF table
INSERT INTO STAFF (library_id, first_name, last_name, role, email, phone)
VALUES 
(1, 'Patricia', 'Wilson', 'Head Librarian', 'pwilson@library.org', '555-121-2323'),
(1, 'Richard', 'Moore', 'Reference Librarian', 'rmoore@library.org', '555-131-2424'),
(2, 'Susan', 'Taylor', 'Library Assistant', 'staylor@library.org', '555-141-2525'),
(3, 'James', 'Anderson', 'Library Technician', 'janderson@library.org', '555-151-2626'),
(4, 'Lisa', 'Thomas', 'Head Librarian', 'lthomas@library.org', '555-161-2727'),
(5, 'Mark', 'Jackson', 'Reference Librarian', 'mjackson@library.org', '555-171-2828'),
(6, 'Karen', 'White', 'Library Assistant', 'kwhite@library.org', '555-181-2929'),
(7, 'Daniel', 'Harris', 'Library Technician', 'dharris@library.org', '555-191-3030'),
(8, 'Nancy', 'Martin', 'Head Librarian', 'nmartin@library.org', '555-212-3131'),
(9, 'Paul', 'Thompson', 'Reference Librarian', 'pthompson@library.org', '555-232-3232'),
(10, 'Laura', 'Garcia', 'Library Assistant', 'lgarcia@library.org', '555-242-3333');
GO

-- Insert data into COPY table
INSERT INTO COPY (book_id, [condition], purchase_date, availability_status)
VALUES 
(1, 'Good', '2019-06-15', 'Available'),
(1, 'Fair', '2017-03-22', 'Available'),
(2, 'Good', '2020-01-10', 'Available'),
(3, 'New', '2022-02-05', 'Reserved'),
(4, 'Good', '2021-07-18', 'Available'),
(5, 'Poor', '2018-09-12', 'Available'),
(6, 'Good', '2019-11-30', 'Unavailable'),
(7, 'New', '2022-03-15', 'Available'),
(8, 'Fair', '2020-05-22', 'Available'),
(9, 'Good', '2021-04-14', 'Reserved'),
(10, 'New', '2022-01-08', 'Available'),
(11, 'Good', '2021-08-19', 'Available'),
(12, 'Fair', '2020-10-25', 'Available');
GO

-- Insert data into TRANSACTION table
INSERT INTO [TRANSACTION] (member_id, copy_id, staff_id, borrow_date, due_date, return_date, transaction_status)
VALUES 
(1, 1, 1, '2023-01-15', '2023-02-15', '2023-02-10', 'Completed'),
(2, 3, 2, '2023-02-05', '2023-03-05', '2023-03-02', 'Completed'),
(3, 5, 3, '2023-03-10', '2023-04-10', NULL, 'Active'),
(4, 7, 4, '2023-01-20', '2023-02-20', '2023-03-01', 'Overdue'),
(5, 9, 5, '2023-04-05', '2023-05-05', NULL, 'Active'),
(6, 11, 6, '2023-02-25', '2023-03-25', '2023-03-20', 'Completed'),
(7, 2, 7, '2023-03-15', '2023-04-15', NULL, 'Active'),
(8, 4, 8, '2023-02-10', '2023-03-10', '2023-04-05', 'Overdue'),
(9, 6, 9, '2023-04-01', '2023-05-01', NULL, 'Active'),
(10, 8, 10, '2023-01-05', '2023-02-05', NULL, 'Lost');
GO

-- Insert data into RESERVATION table
INSERT INTO RESERVATION (member_id, book_id, staff_id, reservation_date, reservation_status)
VALUES 
(1, 3, 1, '2023-04-01', 'Pending'),
(2, 9, 2, '2023-03-25', 'Pending'),
(3, 6, 3, '2023-03-15', 'Cancelled'),
(4, 1, 4, '2023-02-10', 'Fulfilled'),
(5, 7, 5, '2023-04-05', 'Pending'),
(6, 2, 6, '2023-03-01', 'Expired'),
(7, 10, 7, '2023-04-10', 'Pending'),
(8, 5, 8, '2023-03-20', 'Fulfilled'),
(9, 8, 9, '2023-02-15', 'Cancelled'),
(10, 4, 10, '2023-04-02', 'Pending');
GO

-- Insert data into FEEDBACK table
INSERT INTO FEEDBACK (book_id, member_id, feedback_date, rating, comment)
VALUES 
(1, 1, '2023-02-12', 5, 'A timeless classic that never gets old!'),
(2, 2, '2023-03-04', 4, 'A beautiful story about perseverance.'),
(3, 4, '2023-01-10', 5, 'One of the greatest novels ever written.'),
(4, 6, '2023-03-22', 3, 'I found it a bit slow, but the writing is beautiful.'),
(5, 8, '2023-04-06', 5, 'A powerful exploration of identity and belonging.'),
(6, 3, '2023-02-20', 4, 'Genuinely scary and psychologically complex.'),
(7, 5, '2023-03-18', 5, 'Magical and captivating from start to finish.'),
(8, 7, '2023-01-25', 5, 'A profound and moving masterpiece.'),
(9, 9, '2023-02-28', 4, 'Disturbing but thought-provoking.'),
(10, 10, '2023-04-03', 5, 'Life-changing wisdom in a simple story.');
GO

-- Insert data into FINE table
INSERT INTO FINE (transaction_id, amount, issue_date, payment_status)
VALUES 
(4, 5.00, '2023-03-02', 'Paid'),
(8, 10.00, '2023-04-06', 'Unpaid'),
(10, 25.00, '2023-02-06', 'Unpaid'),
(1, 2.50, '2023-02-16', 'Waived'),
(2, 3.00, '2023-03-06', 'Paid'),
(3, 7.50, '2023-04-11', 'Unpaid'),
(5, 4.00, '2023-05-06', 'Unpaid'),
(6, 2.00, '2023-03-26', 'Paid'),
(7, 6.00, '2023-04-16', 'Unpaid'),
(9, 8.00, '2023-05-02', 'Unpaid');
GO

-- Insert default member users
INSERT INTO USER_AUTH (username, password, role, user_id)
VALUES
('john_smith', 'password123', 'member', 1),
('sarah_j', 'pass', 'member', 2),
('mwilliams', 'mikepass', 'member', 3),
('emily_b', 'emilypass', 'member', 4),
('david_j', 'davidpass', 'member', 5);
GO

-- Insert default staff users
INSERT INTO USER_AUTH (username, password, role, user_id)
VALUES
('pwilson', '12345', 'staff', 1),
('rmoore', '123', 'staff', 2),
('staylor', 'staffpass3', 'staff', 3),
('janderson', 'staffpass4', 'staff', 4),
('lthomas', 'staffpass5', 'staff', 5);