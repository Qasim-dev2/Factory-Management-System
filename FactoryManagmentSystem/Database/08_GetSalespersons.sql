-- ================================================================================
-- GET SALESPERSONS FOR SALES ORDER
-- ================================================================================
-- Purpose: Fetch active salespersons for sales order creation dropdown
-- Used by: CreateOrderDialog.xaml.cs, SalesOrdersManagementView.xaml.cs
-- 
-- Business Logic:
--   - Joins Employee table with EmployeeRole table to filter by RoleName = 'Salesperson'
--   - Joins with Department table to get DepartmentName
--   - Only returns active employees (IsActive = 1)
--   - Returns concatenated full name for display in dropdown
--
-- Returns:
--   - EmployeeID: Primary key for saving to SalesOrder.SalesRepID
--   - FullName: FirstName + LastName for dropdown display
--   - Email: Contact information
--   - Phone: Contact information
--   - Department: Department name from Department table
-- ================================================================================

USE GarmentsFactoryDB;
GO

CREATE PROCEDURE sp_GetSalespersonsForOrder
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        e.EmployeeID,
        CONCAT(e.FirstName, ' ', e.LastName) AS FullName,
        e.Email,
        e.Phone,
        d.DepartmentName AS Department
    FROM Employee e
    INNER JOIN EmployeeRole r ON e.RoleID = r.RoleID
    INNER JOIN Department d ON e.DepartmentID = d.DepartmentID
    WHERE r.RoleName = 'Salesperson'
        AND e.IsActive = 1
    ORDER BY e.FirstName, e.LastName;
END;
GO

PRINT 'Stored procedure sp_GetSalespersonsForOrder created successfully.';
GO

-- Test the procedure
-- EXEC sp_GetSalespersonsForOrder;
-- GO
