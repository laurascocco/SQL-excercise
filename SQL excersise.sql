CREATE DATABASE	LAURASCOCCO;

USE LAURASCOCCO;

-- I create the table Product

CREATE TABLE Product (
    ProductID INT,		-- PRIMARY KEY	
    ProductName VARCHAR(50),
    ProductCategory VARCHAR(50),
    Available BIT,
	CONSTRAINT PK_Product PRIMARY KEY (ProductID)
);

INSERT INTO Product -- (ProductID, ProductName, ProductCategory, Available)
VALUES
(1, 'Barbie', 'Doll', 1),
(2, 'Mermaid', 'Doll', 1),
(3, 'Lego', 'Building Blocks', 1),
(4, 'Dollhouse Furniture Set', 'Doll', 1),
(5, 'Pokemon cards', 'CCG', 1),
(6, 'The Last of Us 2', 'Videogames', 1),
(7, 'Magic cards', 'CCG', 1),
(8, 'Red Dead Redemption 2', 'Videogames', 1),
(9, 'Playstation 5', 'Console', 1),
(10, 'Dinosaur Puzzle', 'Puzzle Games', 0),
(11, 'Xbox360', 'Console', 1),
(12, 'Red Dead Redemption 1', 'Videogames', 1),
(13, 'The Last of Us 1', 'Videogames', 1),
(14, 'Nintendo Switch', 'Console', 1);

SELECT *
FROM Product

-- I create the Region table

CREATE TABLE Region (
    StateID INT, -- PRIMARY KEY
    StateName VARCHAR(25),
    RegionID INT,
	CONSTRAINT PK_Region PRIMARY KEY (StateID)
);

INSERT INTO Region -- (StateID, StateName, RegionID)
VALUES 
(1, 'Europe', NULL),
(2, 'North America', NULL),
(3, 'Asia', NULL),
(4, 'Italy', 1),
(5, 'Spain', 1),
(6, 'France', 1),
(7, 'Canada', 2),
(8, 'China', 3),
(9, 'Japan', 3);

SELECT *
FROM Region


-- I create the Sales table

CREATE TABLE Sales (
    SalesID INT, -- PRIMARY KEY
    ProductID INT,
    StateID INT,
    OrderDate DATE,
    Quantity INT,
    UnitPrice DECIMAL(10, 2),
    SalesAmount DECIMAL(10, 2),
	CONSTRAINT PK_Sales PRIMARY KEY (SalesID),
	CONSTRAINT FK_Sales_Product FOREIGN KEY (ProductID) REFERENCES Product(ProductID),
	CONSTRAINT FK_Sales_Region FOREIGN KEY (StateID) REFERENCES Region(StateID)
);

INSERT INTO Sales -- (SalesID, ProductID, StateID, OrderDate, Quantity, UnitPrice, SalesAmount)
VALUES 
(1, 1, 5, '2022-03-15', 2, 10, 20),
(2, 3, 6, '2022-05-20', 1, 20.5, 25.5),
(3, 5, 7, '2022-08-10', 3, 3.5, 10.5),
(4, 6, 8, '2022-11-05', 1, 60, 60),
(5, 9, 8, '2023-02-28', 1, 500, 500),
(6, 11, 8, '2023-05-12', 2, 200.5, 401),
(7, 2, 9, '2023-08-03', 1, 15.5, 15.5),
(8, 13, 4, '2023-10-22', 1, 50, 50),
(9, 14, 4, '2023-12-18', 1, 300.5, 300.5),
(10, 7, 5, '2023-02-08', 2, 6, 12),
(11, 4, 6, '2023-05-17', 1, 30, 30),
(12, 14, 5, '2024-01-29', 2, 300.5, 601),
(13, 6, 4, '2022-10-15', 1, 60, 60);

SELECT *
FROM Sales


-- 1) Verify that the fields defined as PK are unique.

SELECT ProductID, COUNT(*) AS Counting
FROM Product
GROUP BY ProductID
HAVING COUNT(*) > 1;

-- Since the result is an empty table, it means that no data has been inserted more than once, indicating uniqueness.

SELECT StateID, COUNT(*) AS Counting
FROM Region
GROUP BY StateID
HAVING COUNT(*) > 1;

SELECT SalesID, COUNT(*) AS Counting
FROM Sales
GROUP BY SalesID
HAVING COUNT(*) > 1;

/*
2) Expose the list of transactions indicating in the result set the document code, the date,
the product name, the product category, the state name, the sales region name,
and a boolean field based on whether more than 180 days have passed since the sales date or not
(>180 -> True, <= 180 -> False)
*/

-- self join

SELECT 
    r1.StateName AS StateName,
    r2.StateName AS RegionName
FROM 
	Region r1
	JOIN Region r2 
	ON r1.RegionID = r2.StateID;


SELECT
    s.SalesID,
    s.OrderDate,
    p.ProductName,
    p.ProductCategory,
    r1.StateName AS StateName,
    r2.StateName AS RegionName,
    CASE WHEN DATEDIFF(DAY, s.OrderDate, GETDATE()) > 180 THEN 1 
	ELSE 0 
	END AS MoreThan180Days
FROM 
	Sales AS s
	JOIN Product AS p
	ON s.ProductID = p.ProductID
	JOIN Region r1 
	ON s.StateID = r1.StateID
	JOIN Region r2 
	ON r1.RegionID = r2.StateID
ORDER BY 
	MoreThan180Days DESC, s.OrderDate;

-- 3) Expose the list of only sold products, and for each of these, the total revenue per year.

SELECT
    p.ProductID,
    p.ProductName,
	p.ProductCategory, 
    YEAR(s.OrderDate) AS SalesYear,
    SUM(s.SalesAmount) AS TotalAmount
FROM 
	Product AS p
	JOIN Sales AS s
	ON p.ProductID = s.ProductID
GROUP BY
    p.ProductID, p.ProductName, p.ProductCategory, YEAR(s.OrderDate)
ORDER BY
	p.ProductID, YEAR(s.OrderDate), TotalAmount;

-- 4) Expose the total revenue per state per year. Order the result by date and by descending revenue.

SELECT
    r.StateName,
    YEAR(s.OrderDate) AS SalesYear,
    SUM(s.SalesAmount) AS TotalAmount
FROM 
	Sales AS s
	JOIN Region AS r
	ON s.StateID = r.StateID
GROUP BY
    r.StateName, YEAR(s.OrderDate)
ORDER BY
    SalesYear DESC, TotalAmount DESC;


-- 5) What is the category of items most in demand in the market?

SELECT TOP 1
    p.ProductCategory,
    COUNT(*) AS NumberSales
FROM 
	Product AS p
	JOIN Sales AS s
	ON p.ProductID = s.ProductID
GROUP BY
    p.ProductCategory
ORDER BY
    NumberSales DESC;

-- 6)	What are, if any, the unsold products? Two different solution approaches.

-- FIRST APPROACH

SELECT * -- when I perform a join, all the attributes of both Product and Sales are displayed.
FROM 
	Product AS p
	LEFT JOIN Sales AS s
	ON p.ProductID = s.ProductID
WHERE
    s.SalesID IS NULL;

-- SECOND APPROACH

SELECT *
FROM 
	Product AS p
WHERE p.ProductID NOT IN 
	(
    SELECT ProductID		-- Independent nested query (which also functions on its own)
    FROM Sales
);

-- 7) Expose the list of products with their respective last sale date (the most recent sales date).

SELECT
    p.ProductID,
    p.ProductName,
    MAX(s.OrderDate) AS LastSaleDate
FROM 
	Product AS p
	LEFT JOIN Sales AS s
	ON p.ProductID = s.ProductID
GROUP BY
    p.ProductID, p.ProductName
HAVING
    MAX(s.OrderDate) IS NOT NULL;

-- Other way

SELECT
    p.ProductID,
    p.ProductName,
    s1.OrderDate AS LastSaleDate
FROM 
    Product AS p
	JOIN Sales AS s1
	ON p.ProductID = s1.ProductID
WHERE
    s1.OrderDate = (SELECT MAX(s2.OrderDate) FROM Sales AS s2 WHERE s2.ProductID = p.ProductID);

-- 8) Creation of a view on products to expose a "denormalized version" of useful information (product code, product name, category name)

CREATE VIEW Product2 AS (
SELECT
    p.ProductID,
    p.ProductName,
    p.ProductCategory
FROM 
	Product AS p
	);

SELECT *
FROM Product2

-- 9) Create a view to return a "denormalized" version of geographic information

CREATE VIEW InfoGeo AS (
SELECT
    R1.StateID,
    R1.StateName,
    R2.StateName AS RegionName
FROM 
	Region R1
	JOIN Region R2 
	ON R1.RegionID = R2.StateID);

SELECT *
FROM InfoGeo

-- Creation of a denormalized view with Sales to establish a connection in Power Query between the two views above

CREATE VIEW Sales2 AS (
SELECT
    SalesID,
    ProductID,
	StateID,
    Quantity,
    UnitPrice,
    SalesAmount,
	OrderDate
FROM 
    Sales);

SELECT *
FROM Sales2
