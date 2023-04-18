-- Check if the database 'Libray' is null
IF DB_ID('Library') IS NULL
	BEGIN 
		-- Create the database
		CREATE DATABASE Library;  
	END
GO 
-- Use the database
USE Library;

GO
-- Drop all existing tables
DROP TABLE IF EXISTS Reader;
DROP TABLE IF EXISTS Book;
DROP TABLE IF EXISTS Author;
-- Dropp all existing views
DROP VIEW IF EXISTS RentedBooks;
DROP VIEW IF EXISTS AuthorBooks;
DROP VIEW IF EXISTS Total;
-- Drop all existing procedures
DROP PROCEDURE IF EXISTS ReaderBooks;
DROP PROCEDURE IF EXISTS ReturnBooks;

GO
-- Create our first table with the book author(s)
CREATE TABLE Author(
	id INT IDENTITY(1,1) PRIMARY KEY,
	FullName nvarchar(25),
);
-- Create a table to hold our different books
CREATE TABLE Book(
	id INT IDENTITY(1,1) PRIMARY KEY,
	Title NVARCHAR(50) UNIQUE NOT NULL, -- We can only have one row of each book
	Released DateTime DEFAULT CURRENT_TIMESTAMP, -- Automate the timestamp by default
	Price int,
	Author_Id INT FOREIGN KEY REFERENCES Author(id) -- Refer to the amount of authors
);
-- Create the table to store customers/reader
CREATE TABLE Reader(
	id INT IDENTITY(1,1) PRIMARY KEY,
	FirstName NVARCHAR(25) NOT NULL,
	Borrowed DateTime DEFAULT CURRENT_TIMESTAMP,
	PhoneNumber NVARCHAR(8) NOT NULL, 
	Book_Id INT FOREIGN KEY REFERENCES Book(id)
);

GO
-- Insert authors to the 'author' table
INSERT INTO Author (FullName) VALUES ('J. K. Rowling');
INSERT INTO Author (FullName) VALUES ('Harper Lee');
INSERT INTO Author (FullName) VALUES ('F. Scott Fitzgerald');
INSERT INTO Author (FullName) VALUES ('Jane Austen');
INSERT INTO Author (FullName) VALUES ('J.D. Salinger');

-- Insert Books to the 'Book' table
INSERT INTO Book (Title, Price, Author_Id) VALUES ('Harry Potter and the Philosophers Stone', 162, 1);
INSERT INTO Book (Title, Price, Author_Id) VALUES ('To Kill a Mockingbird', 280, 2);
INSERT INTO Book (Title, Price, Author_Id) VALUES ('The Great Gatsby', 185, 3);
INSERT INTO Book (Title, Price, Author_Id) VALUES ('Pride and Prejudice', 180, 4);
INSERT INTO Book (Title, Price, Author_Id) VALUES ('The Catcher in the Rye', 140, 5);
INSERT INTO Book (Title, Price, Author_Id) VALUES ('Harry Potter and the chamber of secrets', 215, 1);

-- Insert Readers to the 'Reader' table
INSERT INTO Reader(FirstName, PhoneNumber, Book_Id) VALUES ('Sebastian', '91231247', 1);
INSERT INTO Reader(FirstName, PhoneNumber, Book_Id) VALUES ('Sebastian', '91231247', 6);
INSERT INTO Reader(FirstName, PhoneNumber, Book_Id) VALUES ('Mads', '92736224', 2);
INSERT INTO Reader(FirstName, PhoneNumber, Book_Id) VALUES ('Mathias', '12681681', 3);
INSERT INTO Reader(FirstName, PhoneNumber, Book_Id) VALUES ('Mark', '52683552', 4);
INSERT INTO Reader(FirstName, PhoneNumber, Book_Id) VALUES ('Navn', '12345678', 5);

GO
-- Create a view to store the book-author, book-title, reader/customer and the timestamp the book was borrowed
CREATE VIEW RentedBooks AS
	SELECT Author.FullName as Auth, Book.Title as Title, Reader.FirstName AS Customer, Reader.Borrowed As Borrowed From Author
	JOIN Book ON Book.Author_Id = Author.id
	JOIN Reader ON Book.id = Reader.Book_Id;

GO
-- Use the 'RentedBooks' view 
SELECT * FROM RentedBooks;

GO
/* 
 * Create a view to check how many books each author has published
 * The 'DISTINCT' isn't relevant since we don't have multiple authors
*/
CREATE VIEW AuthorBooks AS
	SELECT DISTINCT Author.FullName As Auth, STRING_AGG(Book.Title, ', ') AS Titles FROM Author
	JOIN Book ON Book.Author_Id = Author.id
	GROUP BY Author.FullName;

GO
-- Use 'AuthorBooks' view
SELECT * FROM AuthorBooks;

GO 

CREATE PROCEDURE ReaderBooks 
	@Customer NVARCHAR(25) AS
	SELECT * FROM RentedBooks WHERE Customer = @Customer
	-- Delete every book borrowed between 13 and 14 since it's happy hour and they get the book for free :) Could be params
	DELETE FROM Reader Where Borrowed BETWEEN '13:00' AND '14:00';
GO

EXEC ReaderBooks @Customer = 'Sebastian';

GO

CREATE PROCEDURE ReturnBooks AS
	-- Remove the relation between Reader and Books
	UPDATE Reader SET Book_Id = NULL;
GO

EXEC ReturnBooks;

GO

CREATE VIEW Total AS
SELECT -- Select the total amount of rows and give it a alias
	(SELECT COUNT(*) FROM Author) AS Authors,
	(SELECT COUNT(*) FROM Book) AS Books,
	(SELECT COUNT(*) FROM Reader) AS Readers;

GO

SELECT * FROM Total;