USE [northwind-pubs];
GO
SELECT c.name, tbl.name as table_name, c.is_masked, c.masking_function
FROM sys.masked_columns AS c
JOIN sys.tables AS tbl
    ON c.[object_id] = tbl.[object_id]
WHERE is_masked = 1;
GO

EXECUTE AS USER = 'HumanResources';
SELECT * FROM dbo.employees;
SELECT * FROM dbo.Customers;
SELECT * FROM dbo.Suppliers;
GO
REVERT;
GO

EXECUTE AS USER = 'Financial';
SELECT * FROM dbo.employees;
SELECT * FROM dbo.Customers;
SELECT * FROM dbo.Suppliers;
GO
REVERT;
GO

