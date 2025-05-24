-- PROJECT: Coffee Sales Analysis (Second Project)

-- STEP 1: Create Database Context
USE projects;
GO

-- STEP 2: Create Tables

-- 2.1 Customers Table
CREATE TABLE Data_customers(
	Customer_id varchar(50) NOT NULL,
	Customer_Name varchar(50) NULL,
	Email varchar(50) NULL,
	Phone_Number varchar(50) NULL,
	Address_Line_1 varchar(50) NULL,
	City varchar(50) NULL,
	Country varchar(50) NULL,
	Post_Code varchar(50) NULL,
	Loyalty_Card varchar(50) NULL,
 CONSTRAINT pk_customer_id PRIMARY KEY (Customer_id)
);
GO

-- 2.2 Products Table
CREATE TABLE Data_products(
	Product_id varchar(50) NOT NULL,
	Coffee_type varchar(50) NOT NULL,
	Roast_Type varchar(50) NULL,
	Size decimal(10, 2) NULL,
	Unit_price decimal(10, 3) NULL,
	Price_per_100g decimal(10, 3) NULL,
	Profit decimal(10, 8) NULL,
 CONSTRAINT PK_Data_products PRIMARY KEY (Product_id)
);
GO

-- 2.3 Orders Table
CREATE TABLE Data_orders(
	Order_ID varchar(50) NULL,
	Order_Date date NULL,
	Customer_ID varchar(50) NULL,
	Product_ID varchar(50) NULL,
	Quantity int NULL
);
GO

-- STEP 3: Clean Data

UPDATE Data_customers
SET Email = 'notiene@correo.com'
WHERE Email IS NULL OR LTRIM(RTRIM(Email)) = '';

UPDATE Data_customers
SET Phone_Number = '0'
WHERE Phone_Number IS NULL OR LTRIM(RTRIM(Phone_Number)) = '';

UPDATE Data_products
SET Coffee_type = 'Arabica'
WHERE Coffee_type = 'ARA';

UPDATE Data_products
SET Roast_Type = 'Dark Roast'
WHERE Roast_Type = 'D';

UPDATE Data_products
SET Roast_Type = 'Medium Roast'
WHERE Roast_Type = 'M';

UPDATE Data_products
SET Roast_Type = 'Light Roast'
WHERE Roast_Type = 'L';

-- STEP 4: Add Indexes

CREATE NONCLUSTERED INDEX idx_country_loyalty_Card
ON Data_customers (Country, Loyalty_Card);

CREATE NONCLUSTERED INDEX idx_order_date
ON Data_orders (order_date);

CREATE NONCLUSTERED INDEX idx_Customer_id
ON Data_customers (Customer_id);

CREATE NONCLUSTERED INDEX idx_Orders_product
ON Data_orders (Product_id);

-- STEP 5: Add Foreign Keys

ALTER TABLE Data_orders
ADD CONSTRAINT fk_customer_id FOREIGN KEY (Customer_id)
REFERENCES Data_customers(Customer_id);

ALTER TABLE Data_orders
ADD CONSTRAINT fk_product_id FOREIGN KEY (Product_id)
REFERENCES Data_products(Product_id);

-- STEP 6: Sample Queries

SELECT * FROM Data_customers;
SELECT * FROM Data_products;
SELECT * FROM Data_orders;

-- STEP 7: Joins

-- 7.1 Left Join
SELECT DC.Customer_Name, DC.City, DC.Country, DO.Order_ID, DO.Order_Date, DO.Quantity
FROM Data_customers AS DC
LEFT JOIN Data_orders AS DO ON DC.Customer_id = DO.Customer_id;

-- 7.2 Right Join
SELECT DO.Order_ID, DO.Order_Date, DO.Product_ID, DO.Quantity, DC.Customer_Name, DC.City, DC.Country  
FROM Data_orders AS DO
RIGHT JOIN Data_customers AS DC ON DO.Customer_id = DC.Customer_id;

-- 7.3 Inner Join
SELECT DO.Order_ID, DO.Order_Date, DO.Product_ID, DO.Quantity, DP.Coffee_type, DP.Roast_Type, DP.Unit_price, DP.Price_per_100g, DP.Profit 
FROM Data_orders AS DO
INNER JOIN Data_products AS DP ON DO.Product_id = DP.Product_id;

-- 7.4 Full Join
SELECT * FROM Data_orders AS DO
JOIN Data_customers AS DC ON DO.Customer_id = DC.Customer_id
JOIN Data_products AS DP ON DO.Product_id = DP.Product_id;

-- STEP 8: Analysis Queries

-- 8.1 Total Price by Coffee Type
SELECT Coffee_type, SUM(Unit_price) AS Total_Price
FROM Data_products
GROUP BY Coffee_type
ORDER BY Total_Price ASC;

-- 8.2 Most Profitable Coffee
SELECT Coffee_type, Unit_price, Profit
FROM Data_products
GROUP BY Coffee_type, Unit_price, Profit
ORDER BY Profit DESC, Coffee_type;

-- 8.3 Most Ordered Coffee
SELECT DP.Coffee_type, SUM(DO.Quantity) AS Total_ordered 
FROM Data_products AS DP
LEFT JOIN Data_orders AS DO ON DP.Product_id = DO.Product_ID
GROUP BY DP.Coffee_type;

-- 8.4 Customers by Country
SELECT Country, COUNT(*) AS Total_Customers
FROM Data_customers
GROUP BY Country;

-- 8.5 Coffee Type Price (JSON)
SELECT 
    (SELECT Coffee_type, SUM(Unit_price) AS Total
     FROM Data_products
     GROUP BY Coffee_type
     FOR JSON AUTO) AS Coffee_type_price,
    (SELECT Country, COUNT(*) AS Total_Customers
     FROM Data_customers
     GROUP BY Country
     FOR JSON AUTO) AS Customers_Location;

-- 8.6 Profit Margin per Country
SELECT DC.Country, SUM(DP.Profit) as total_profit 
FROM Data_orders DO 
JOIN Data_customers DC ON DO.Customer_id = DC.Customer_id
JOIN Data_products DP ON DO.Product_id = DP.Product_id 
GROUP BY DC.Country 
ORDER BY total_profit DESC;

-- 8.7 Monthly Sales Trends
SELECT FORMAT(DO.Order_date, 'yyyy-MM') AS Month, 
       DATENAME(MONTH, DO.Order_date) + ' ' + CAST(YEAR(DO.Order_date) as varchar) as month_name, 
       SUM(DP.Unit_price * DO.quantity) as total_sales
FROM Data_orders DO 
JOIN Data_products DP ON DO.Product_id = DP.Product_id 
GROUP BY FORMAT(DO.Order_date, 'yyyy-MM'), DATENAME(MONTH, Order_date), YEAR(DO.Order_date) 
ORDER BY FORMAT(DO.Order_date, 'yyyy-MM');

-- STEP 9: Validations

-- 9.1 Orders with Non-Matching Customers
SELECT DISTINCT Customer_id
FROM Data_orders
WHERE Customer_id NOT IN (
    SELECT Customer_id FROM Data_customers
);

-- STEP 10: Stored Procedures

-- 10.1 Sales by Month
CREATE PROCEDURE Sales_type_cofee
AS
BEGIN 
    SELECT FORMAT(Order_date, 'MMM yyyy') AS Mes_año,
           SUM(DO.Quantity * DP.Unit_price) AS Total_Ventas
    FROM Data_orders DO 
    JOIN Data_products DP ON DO.Product_id = DP.Product_id
    GROUP BY FORMAT(DO.Order_Date, 'MMM yyyy')
    ORDER BY MIN(Order_date);
END;
GO
EXEC Sales_type_cofee;

-- 10.2 Sales by Coffee Type per Month
CREATE PROCEDURE Sales_by_coffee_type
AS
BEGIN 
    SELECT FORMAT(Order_date, 'MMM yyyy') AS Mes_año,
           DP.Coffee_type AS Coffee_type,
           SUM(DO.Quantity * DP.Unit_price) AS Total_Ventas
    FROM Data_orders DO
    JOIN Data_products DP ON DO.Product_id = DP.Product_id
    GROUP BY FORMAT(Order_date, 'MMM yyyy'), DP.Coffee_type
    ORDER BY MIN(Order_date), DP.Coffee_type;
END;
GO
EXEC Sales_by_coffee_type;

