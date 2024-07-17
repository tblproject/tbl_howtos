USE [northwind-pubs];
GO

-- Create Test Users
CREATE USER HumanResources WITHOUT LOGIN;
GO
CREATE USER Financial WITHOUT LOGIN;
GO

-- Asign roles to users
ALTER ROLE db_datareader ADD MEMBER HumanResources;
ALTER ROLE db_datareader ADD MEMBER Financial;

-- Grant UNMASK permissions
GRANT UNMASK ON dbo.employees TO HumanResources;
GRANT UNMASK ON dbo.Customers TO Financial;
GRANT UNMASK ON dbo.Suppliers TO Financial;
GO
