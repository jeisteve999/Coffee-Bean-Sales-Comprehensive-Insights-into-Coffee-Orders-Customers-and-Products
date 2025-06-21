-- ========================================
-- Data Orders, Products, and Customers Setup
-- Database: Projects
-- Script Date: 10/05/2025 1:36:20 PM
-- ========================================

USE [Projects];
GO

-- ========================================
-- 1. Create Data_orders Table
-- ========================================

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

CREATE TABLE [dbo].[Data_orders] (
    [Order_ID] VARCHAR(50) NOT NULL,
    [Order_Date] DATE NOT NULL,
    [Customer_ID] VARCHAR(50) NOT NULL,
    [Product_ID] VARCHAR(50) NOT NULL,
    [Quantity] INT NOT NULL,
    [Customer_Name] VARCHAR(50) NULL,
    [Email] VARCHAR(100) NULL,
    [Country] VARCHAR(100) NULL,
    [Coffee_Type] VARCHAR(50) NULL,
    [Roast_Type] VARCHAR(50) NULL,
    [Size] VARCHAR(50) NULL,
    [Unit_Price] MONEY NULL,
    [Sales] MONEY NULL,
    CONSTRAINT PK_Data_orders PRIMARY KEY CLUSTERED ([Order_ID] ASC)
        WITH (
            PAD_INDEX = OFF,
            STATISTICS_NORECOMPUTE = OFF,
            IGNORE_DUP_KEY = OFF,
            ALLOW_ROW_LOCKS = ON,
            ALLOW_PAGE_LOCKS = ON,
            OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF
        ) ON [PRIMARY]
) ON [PRIMARY];
GO

-- ========================================
-- 2. Clean Data in Data_products (Remove Double Quotes)
-- ========================================
-- (Ensure the table Data_products exists before running these updates.)

UPDATE Data_products
SET 
    Order_id = REPLACE(Order_id, '"', ''),
    Order_date = REPLACE(Order_date, '"', ''),
    Customer_ID = REPLACE(Customer_ID, '"', '');
GO

-- ========================================
-- 3. Alter Data_products Table Columns to Proper Data Types
-- ========================================

ALTER TABLE Data_products
ALTER COLUMN Roast_Type VARCHAR(50);
GO

ALTER TABLE Data_products
ALTER COLUMN Size VARCHAR(50);
GO

ALTER TABLE Data_products
ALTER COLUMN Unit_price VARCHAR(50);
GO

ALTER TABLE Data_products
ALTER COLUMN Price_per_100g VARCHAR(50);
GO

ALTER TABLE Data_products
ALTER COLUMN Profit VARCHAR(50);
GO

-- ========================================
-- 4. Update Data_products to Remove Extra Double Quotes in Various Columns
-- ========================================

UPDATE Data_products
SET
    Product_id = REPLACE(Product_id, '"', ''),
    Cofee_type = REPLACE(Cofee_type, '"', ''),
    Size = REPLACE(Size, '"', ''),
    Unit_price = REPLACE(Unit_price, '"', ''),
    Price_per_100g = REPLACE(Price_per_100g, '"', ''),
    Profit = REPLACE(Profit, '"', '');
GO

UPDATE Data_products
SET Roast_Type = REPLACE(Roast_Type, '"', '');
GO

UPDATE Data_products
SET Country = REPLACE(Country, '"', '');
GO

-- ========================================
-- 5. Create Data_products Table
-- ========================================

CREATE TABLE Data_products (
    Product_id VARCHAR(50) NOT NULL PRIMARY KEY,
    Cofee_type VARCHAR(50) NOT NULL,  -- This column will be renamed to Coffee_type
    Roast_Type VARCHAR(10) NOT NULL,
    Size VARCHAR(10) NOT NULL,
    Unit_price MONEY NOT NULL,
    Price_per_100g DECIMAL(10, 4) NOT NULL,
    Profit DECIMAL(10, 5) NOT NULL
);
GO

-- Rename column Cofee_type to Coffee_type
EXEC sp_rename 'Data_products.Cofee_type', 'Coffee_type', 'COLUMN';
GO

-- Alter Profit column precision
ALTER TABLE Data_products
ALTER COLUMN Profit DECIMAL(10, 8);
GO

-- ========================================
-- 6. Review Table Definitions via INFORMATION_SCHEMA
-- ========================================

SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Data_orders'
ORDER BY COLUMN_NAME;
GO

SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Data_customers'
ORDER BY COLUMN_NAME;
GO

-- ========================================
-- 7. Select Data_customers Records with Leading Double Quotes
-- ========================================
-- (Adjust column names as defined in your table.)
SELECT * 
FROM Data_customers
WHERE 
    Customer_id LIKE '"%' OR
    Customer_Name LIKE '"%' OR
    Email LIKE '"%' OR
    Phone_Number LIKE '"%' OR
    Address_Line_1 LIKE '"%' OR
    City LIKE '"%' OR
    Country LIKE '"%' OR
    Post_Code LIKE '"%' OR
    Loyalty_Card LIKE '"%';
GO

-- ========================================
-- 8. Create Data_customers Table
-- ========================================
-- Corrected table definition with proper column names and closing parenthesis.
CREATE TABLE Data_customers (
    Customer_id VARCHAR(50) NOT NULL PRIMARY KEY,
    Customer_Name VARCHAR(50) NOT NULL,
    Email VARCHAR(50) NOT NULL,
    Phone_Number VARCHAR(50) NOT NULL,
    Address_Line_1 VARCHAR(50) NOT NULL,
    City VARCHAR(50) NOT NULL,
    Country VARCHAR(50) NOT NULL,
    Post_Code VARCHAR(10) NULL,
    Loyalty_Card VARCHAR(10) NOT NULL
);
GO

-- ========================================
-- 9. Delete Data_customers Records with Leading Double Quotes
-- ========================================

DELETE FROM Data_customers
WHERE 
    Customer_id LIKE '"%' OR
    Customer_Name LIKE '"%' OR
    Email LIKE '"%' OR
    Phone_Number LIKE '"%' OR
    Address_Line_1 LIKE '"%' OR
    City LIKE '"%' OR
    Country LIKE '"%' OR
    Post_Code LIKE '"%' OR
    Loyalty_Card LIKE '"%';
GO

-- ========================================
-- 10. Alter Data_orders: Ensure Order_Date is DATE Type
-- ========================================
ALTER TABLE [dbo].[Data_orders]
ALTER COLUMN Order_Date DATE;
GO

-- ========================================
-- 11. List Foreign Key Relationships
-- ========================================

SELECT 
    fk.name AS Foreign_Key_Name,
    tp.name AS Parent_Table,
    cp.name AS Parent_Column,
    tr.name AS Referenced_Table,
    cr.name AS Referenced_Column
FROM 
    sys.foreign_keys fk
INNER JOIN 
    sys.foreign_key_columns fkc ON fk.object_id = fkc.constraint_object_id
INNER JOIN 
    sys.tables tp ON fkc.parent_object_id = tp.object_id
INNER JOIN 
    sys.columns cp ON fkc.parent_object_id = cp.object_id AND fkc.parent_column_id = cp.column_id
INNER JOIN 
    sys.tables tr ON fkc.referenced_object_id = tr.object_id
INNER JOIN 
    sys.columns cr ON fkc.referenced_object_id = cr.object_id AND fkc.referenced_column_id = cr.column_id
ORDER BY fk.name;
GO

-- ========================================
-- 12. Drop a Foreign Key Constraint from Data_orders
-- ========================================
ALTER TABLE Data_orders
DROP CONSTRAINT fk_customer;
GO

-- ========================================
-- 13. Final Data Review for Tables in Projects Database
-- ========================================
USE Projects;
GO
SELECT * FROM Data_orders;
SELECT * FROM Data_customers;
SELECT * FROM Data_products;
GO

-- ========================================
-- 14. Update Default Values in Data_customers
-- ========================================

UPDATE Data_customers
SET Email = 'notiene@correo.com'
WHERE Email IS NULL OR LTRIM(RTRIM(Email)) = '';
GO

UPDATE Data_customers
SET Phone_Number = '0'
WHERE Phone_Number IS NULL OR LTRIM(RTRIM(Phone_Number)) = '';
GO

-- ========================================
-- 15. Standardize Coffee and Roast Types in Data_products
-- ========================================

UPDATE Data_products
SET Coffee_type = 'Arabica'
WHERE Coffee_type = 'ARA';
GO

UPDATE Data_products
SET Coffee_type = 'Robusta'
WHERE Coffee_type = 'Rob';
GO

UPDATE Data_products
SET Coffee_type = 'Liberica'
WHERE Coffee_type = 'Lib';
GO

UPDATE Data_products
SET Coffee_type = 'Excelsa'
WHERE Coffee_type = 'Exc';
GO

UPDATE Data_products
SET Roast_Type = 'Dark Roast'
WHERE Roast_Type = 'D';
GO

UPDATE Data_products
SET Roast_Type = 'Medium Roast'
WHERE Roast_Type = 'M';
GO

UPDATE Data_products
SET Roast_Type = 'Light Roast'
WHERE Roast_Type = 'L';
GO

-- ========================================
-- 16. Dynamic SQL: Remove Double Quotes from All VARCHAR/CHAR Columns 
-- in a Specified Table (olist_order_items_dataset)
-- ========================================
DECLARE @sql NVARCHAR(MAX) = '';
DECLARE @table NVARCHAR(128) = 'olist_order_items_dataset';

SELECT @sql += '
UPDATE ' + QUOTENAME(@table) + '
SET ' + QUOTENAME(COLUMN_NAME) + ' = REPLACE(' + QUOTENAME(COLUMN_NAME) + ', ''"'', '''')
WHERE ' + QUOTENAME(COLUMN_NAME) + ' LIKE ''%"%'';'
    + CHAR(13)
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = @table AND DATA_TYPE IN ('varchar', 'char');
    
-- Print the dynamic SQL for review
PRINT @sql;

-- Uncomment the next line to execute the generated SQL (after review)
-- EXEC sp_executesql @sql;
GO

-- ========================================
-- 17. Analyze Duplicate Order Item IDs in olist_order_items_dataset
-- ========================================
SELECT "order_item_id", COUNT(*) AS Occurrences
FROM olist_order_items_dataset
GROUP BY "order_item_id"
HAVING COUNT(*) > 1;
GO

-- ========================================
-- 18. Review Column Names in olist_order_items_dataset (dbo Schema)
-- ========================================
SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'olist_order_items_dataset'
  AND TABLE_SCHEMA = 'dbo';
GO

-- ========================================
-- 19. Update olist_customers_dataset: Remove Double Quotes from order_id
-- ========================================
UPDATE [dbo].[olist_customers_dataset]
SET "order_id" = REPLACE("order_id", '"', '');
GO

-- ========================================
-- 20. Sample Queries on olist_order_items_dataset Based on order_id / order_item_id
-- ========================================
SELECT * 
FROM olist_order_items_dataset
WHERE "order_id" = '0008288aa423d2a3f00fcb17cd7d8719';
GO

SELECT * 
FROM olist_order_items_dataset
WHERE "order_item_id" = '0008288aa423d2a3f00fcb17cd7d8719';
GO
