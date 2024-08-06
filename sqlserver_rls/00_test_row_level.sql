USE [northwind-pubs];
GO
SELECT DISTINCT(Country) FROM [dbo].[Employees];
GO

-- Create Test Users
CREATE USER HumanResourcesUK WITHOUT LOGIN;
GO
CREATE USER HumanResourcesUSA WITHOUT LOGIN;
GO

-- Create Security Schema
CREATE SCHEMA Security;
GO
  
-- Create Security Functions
CREATE FUNCTION Security.human_resource_filter(@Country AS nvarchar(15))
    RETURNS TABLE
WITH SCHEMABINDING
AS  
    RETURN SELECT 1 AS human_resource_filter_result
WHERE @Country like ( SELECT CASE
    WHEN USER_NAME() = 'HumanResourcesUK' THEN 'UK'
    WHEN USER_NAME() = 'HumanResourcesUSA' THEN 'USA'
    ELSE '%'
END);
GO


-- Create Security Policies
CREATE SECURITY POLICY CountryFilter
ADD FILTER PREDICATE Security.human_resource_filter(Country)
ON [dbo].[Employees]
WITH (STATE = ON);
GO


-- GRANT SELECT to user
GRANT SELECT ON [dbo].[Employees] TO HumanResourcesUK;
GRANT SELECT ON [dbo].[Employees] TO HumanResourcesUSA;
GRANT SELECT ON Security.human_resource_filter TO HumanResourcesUK;
GRANT SELECT ON Security.human_resource_filter TO HumanResourcesUSA;
GO


EXECUTE AS USER = 'HumanResourcesUK';
SELECT * FROM [dbo].[Employees];
REVERT;

EXECUTE AS USER = 'HumanResourcesUSA';
SELECT * FROM [dbo].[Employees];
REVERT;



-- ALTER SECURITY POLICY CountryFilter
-- WITH (STATE = OFF);
-- GO
-- DROP USER HumanResourcesUK;
-- DROP USER HumanResourcesUSA;

-- DROP SECURITY POLICY CountryFilter;
-- DROP TABLE Sales.Orders;
-- DROP FUNCTION Security.human_resource_filter;
-- DROP SCHEMA Security;
-- GO
