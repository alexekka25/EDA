CREATE DATABASE library;

use library;

CREATE TABLE publisher (
    publisher_PublisherName VARCHAR(255) PRIMARY KEY,
    publisher_PublisherAddress VARCHAR(255),
    publisher_PublisherPhone VARCHAR(15)
);


CREATE TABLE borrower (
    borrower_CardNo INT PRIMARY KEY,
    borrower_BorrowerName VARCHAR(255),
    borrower_BorrowerAddress VARCHAR(255),
    borrower_BorrowerPhone VARCHAR(15)
);

CREATE TABLE library_branch (
    library_branch_BranchID INT PRIMARY KEY AUTO_INCREMENT,
    library_branch_BranchName VARCHAR(255),
    library_branch_BranchAddress VARCHAR(255)
);

CREATE TABLE book (
    book_BookID INT PRIMARY KEY,
    book_Title VARCHAR(255),
    book_PublisherName VARCHAR(255),
    FOREIGN KEY (book_PublisherName)
        REFERENCES publisher (publisher_PublisherName)
        ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE authors (
    book_authors_AuthorID INT PRIMARY KEY AUTO_INCREMENT,
    book_authors_BookID INT,
    book_authors_AuthorName VARCHAR(255),
    FOREIGN KEY (book_authors_BookID)
        REFERENCES book (book_BookID)
        ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE book_copies (
    book_copies_CopiesID INT PRIMARY KEY AUTO_INCREMENT,
    book_copies_BookID INT,
    book_copies_BranchID INT,
    book_copies_No_Of_Copies INT,
    FOREIGN KEY (book_copies_BookID)
        REFERENCES book (book_BookID)
        ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (book_copies_BranchID)
        REFERENCES library_branch (library_branch_BranchID)
        ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE book_loans (
    book_loans_LoansID INT PRIMARY KEY AUTO_INCREMENT,
    book_loans_BookID INT,
    book_loans_BranchID INT,
    book_loans_CardNo INT,
    book_loans_DateOut VARCHAR(20),
    book_loans_DueDate VARCHAR(20),
    FOREIGN KEY (book_loans_BookID)
        REFERENCES book (book_BookID)
        ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (book_loans_BranchID)
        REFERENCES library_branch (library_branch_BranchID)
        ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (book_loans_CardNo)
        REFERENCES borrower (borrower_CardNo)
        ON UPDATE CASCADE ON DELETE CASCADE
);

SELECT * FROM book;
SELECT * FROM borrower;
SELECT * FROM library_branch;
SELECT * FROM authors;
SELECT * FROM book_copies ;
SELECT * FROM publisher;
SELECT * FROM BOOK_LOANS;

SET SQL_SAFE_UPDATES = 0;

UPDATE book_loans
SET book_loans_DateOut = STR_TO_DATE(book_loans_DateOut, '%m/%d/%y'),
    book_loans_DueDate = STR_TO_DATE(book_loans_DueDate, '%m/%d/%y');

------------------------------

--- 1 Question ----
SELECT BOOK_COPIES_BOOKID,book_copies_No_Of_Copies,book_copies_BranchID,SUM(book_copies_No_Of_Copies)
FROM BOOK_COPIES
GROUP BY BOOK_COPIES_BOOKID,book_copies_No_Of_Copies,book_copies_BranchID
HAVING book_copies_BranchID = 1 AND BOOK_COPIES_BOOKID = 20
;


SELECT book_copies_No_Of_Copies
FROM book_copies
JOIN book ON book_copies.book_copies_BookID = book.book_BookID
JOIN library_branch ON book_copies.book_copies_BranchID = library_branch.library_branch_BranchID
WHERE book.book_Title = 'The Lost Tribe'
AND library_branch.library_branch_BranchName = 'Sharpstown';



--- 2 Question ----

SELECT library_branch_BranchName, SUM(book_copies_No_Of_Copies) AS num_copies
FROM book_copies
JOIN book ON book_copies.book_copies_BookID = book.book_BookID
JOIN library_branch ON book_copies.book_copies_BranchID = library_branch.library_branch_BranchID
WHERE book.book_Title = 'The Lost Tribe'
GROUP BY library_branch_BranchName;


SELECT book_copies_BranchID,book_copies_BookID,SUM(book_copies_No_Of_Copies)
FROM BOOK_COPIES
GROUP BY book_copies_BranchID,book_copies_BookID
 HAVING book_copies_BookID = 20
;


---- 3 Question -----

SELECT borrower_BorrowerName
FROM borrower
LEFT JOIN book_loans ON borrower.borrower_CardNo = book_loans.book_loans_CardNo
WHERE book_loans.book_loans_CardNo IS NULL;


---- 4 Question ----
SELECT book.book_Title, borrower.borrower_BorrowerName, borrower.borrower_BorrowerAddress
FROM book_loans
JOIN book ON book_loans.book_loans_BookID = book.book_BookID
JOIN borrower ON book_loans.book_loans_CardNo = borrower.borrower_CardNo
JOIN library_branch ON book_loans.book_loans_BranchID = library_branch.library_branch_BranchID
WHERE library_branch.library_branch_BranchName = 'Sharpstown'
AND book_loans.book_loans_DueDate = '2018-02-03';

SELECT b.book_Title, br.borrower_BorrowerName, br.borrower_BorrowerAddress
FROM book_loans bl
JOIN book b ON bl.book_loans_BookID = b.book_BookID
JOIN library_branch lb ON bl.book_loans_BranchID = lb.library_branch_BranchID
JOIN borrower br ON bl.book_loans_CardNo = br.borrower_CardNo
WHERE lb.library_branch_BranchName = 'Sharpstown' AND bl.book_loans_DueDate = '2018-02-03';

---- 5 Question----

SELECT * FROM library_branch;
SELECT * FROM BOOK_LOANS;

SELECT library_branch_BranchName, COUNT(*) AS total_books_loaned
FROM book_loans
JOIN library_branch ON book_loans.book_loans_BranchID = library_branch.library_branch_BranchID
GROUP BY library_branch_BranchName;


---- 6 Question ----

SELECT borrower_BorrowerName, borrower_BorrowerAddress, COUNT(*) AS num_books_checked_out
FROM book_loans
JOIN borrower ON book_loans.book_loans_CardNo = borrower.borrower_CardNo
GROUP BY borrower_BorrowerName, borrower_BorrowerAddress
HAVING COUNT(*) > 5;


---- 7 Question ----


SELECT book.book_Title, COUNT(book_copies.book_copies_CopiesID) AS num_copies
FROM book
JOIN authors ON book.book_BookID = authors.book_authors_BookID
JOIN authors AS author1 ON authors.book_authors_AuthorID = author1.book_authors_AuthorID
JOIN authors AS author2 ON author1.book_authors_AuthorID = author2.book_authors_AuthorID
JOIN book_copies ON book.book_BookID = book_copies.book_copies_BookID
JOIN library_branch ON book_copies.book_copies_BranchID = library_branch.library_branch_BranchID
WHERE author1.book_authors_AuthorName = 'Stephen King'
AND library_branch.library_branch_BranchName = 'Central'
GROUP BY book.book_Title;


SELECT b.book_Title, bc.book_copies_No_Of_Copies
FROM book b
JOIN authors ba ON b.book_BookID = ba.book_authors_BookID
JOIN book_copies bc ON b.book_BookID = bc.book_copies_BookID
JOIN library_branch lb ON bc.book_copies_BranchID = lb.library_branch_BranchID
WHERE ba.book_authors_AuthorName = 'Stephen King' AND lb.library_branch_BranchName = 'Central';







