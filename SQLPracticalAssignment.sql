CREATE DATABASE BookstoreDB;

\c bookstoredb

CREATE TABLE Books(
    BookID SERIAL PRIMARY KEY,
    Title VARCHAR(100) NOT NULL,
    Author VARCHAR(50) NOT NULL,
    Genre VARCHAR(30) NOT NULL,
    Price NUMERIC(5, 2) CHECK(Price >= 0),
    QuantityInStock INT CHECK(QuantityInStock >= 0)
);
INSERT INTO Books(Title, Author, Genre, Price, QuantityInStock)
    VALUES
    ('Les Miserables', 'Victor Hugo', 'Historical fiction', 19.99, 40),
    ('The Hunchback of Notre-Dame', 'Victor Hugo', 'Romantism', 24.99, 35),
    ('Pere Goriot', 'Honore de Balzac', 'Realism', 29.99, 10),
    ('The Count of Monte Cristo', 'Alexandre Dumas', 'Adventure novel', 14.99, 35),
    ('1984', 'George Orwell', 'Dystopian', 34.99, 16),
    ('One Hundred Years of Solitude', 'Gabriel Garcia Marquez', 'Magical Realism', 22.99, 19),
    ('The Picture of Dorian Gray', 'Oscar Wilde', 'Philosophical Fiction', 18.99, 5),
    ('Fahrenheit 451', 'Ray Bradbury', 'Dystopian', 27.99, 25),
    ('The Divine Comedy', 'Dante Alighieri ', 'Epic Poetry', 32.99, 33),
    ('Madame Bovary', 'Gustave Flaubert', 'Tragedy', 16.99, 40);

CREATE TABLE Customers(
    CustomerID SERIAL PRIMARY KEY,
    Name VARCHAR(35) NOT NULL,
    Email VARCHAR(100) UNIQUE,
    Phone VARCHAR(20)
);
INSERT INTO Customers(Name, Email, Phone)
    VALUES
    ('Emily', 'emilyy@gmail.com', '123-456-7890'),
    ('Elizabeth', 'liz_s@gmail.com', '987-654-3210'),
    ('Samuel', 'sam_325@gmail.com', '555-123-4567'),
    ('Dante', 'dantemiller@gmail.com', '777-888-9999'),
    ('Alice', 'alicesmith@gmail.com', '444-555-6666');

CREATE TABLE Sales (
    SaleID SERIAL PRIMARY KEY,
    BookID INT REFERENCES Books(BookID) ON DELETE SET NULL,
    CustomerID INT REFERENCES Customers(CustomerID) ON DELETE SET NULL,
    DateOfSale DATE,
    QuantitySold INT CHECK(QuantitySold > 0),
    TotalPrice NUMERIC(5, 2) CHECK (TotalPrice >= 0)
);
INSERT INTO Sales (BookID, CustomerID, DateOfSale, QuantitySold, TotalPrice)
    VALUES
    (1, 1, '2023-09-09', 4, 50.50),
    (3, 2, '2023-08-18', 5, 16.0),
    (5, 3, '2023-01-01', 1, 35.90),
    (7, 4, '2023-12-21', 2, 24.90),
    (9, 5, '2023-04-04', 7, 61.16);

SELECT
    Books.Title AS TitleOfBook,
    Customers.Name AS NameOfCustomer,
    Sales.DateOfSale AS DateOfSale
FROM
    Sales
    JOIN Books ON Sales.BookID = Books.BookID
    JOIN Customers ON Sales.CustomerID = Customers.CustomerID;

SELECT
    Books.Genre,
    COALESCE(SUM(Sales.TotalPrice), 0) AS TotalRPice
FROM
    Books
    LEFT JOIN Sales ON Books.BookID = Sales.BookID
GROUP BY
    Books.Genre;


CREATE OR REPLACE FUNCTION update_quantity_in_stock()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE Books
    SET QuantityInStock = QuantityInStock - NEW.QuantitySold
    WHERE BookID = NEW.BookID;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER quantity_update_trigger
AFTER INSERT ON Sales
FOR EACH ROW
EXECUTE FUNCTION update_quantity_in_stock();
