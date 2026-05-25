-- ================================================================================
-- INSERT TEST SALESPERSON FOR TESTING sp_GetSalespersonsForOrder
-- ================================================================================
-- This script inserts a test salesperson to verify the procedure works
-- ================================================================================

USE GarmentsFactoryDB;
GO

-- Insert test salesperson (RoleID = 3 is Salesperson, DepartmentID = 2 is Sales)
-- Check if salesperson role exists first
IF NOT EXISTS (SELECT * FROM EmployeeRole WHERE RoleName = 'Salesperson')
BEGIN
    INSERT INTO EmployeeRole (RoleName, Description, IsActive)
    VALUES ('Salesperson', 'Sales staff responsible for customer relations and orders', 1);
    PRINT 'Salesperson role created.';
END

-- Insert test salesperson employee
INSERT INTO Employee (FirstName, LastName, Email, Phone, DepartmentID, RoleID, Salary, IsActive)
VALUES 
    ('Ali', 'Hassan', 'ali.hassan@factory.com', '0300-1234567', 2, 
     (SELECT RoleID FROM EmployeeRole WHERE RoleName = 'Salesperson'), 
     40000, 1),
    ('Fatima', 'Khan', 'fatima.khan@factory.com', '0301-2345678', 2, 
     (SELECT RoleID FROM EmployeeRole WHERE RoleName = 'Salesperson'), 
     42000, 1),
    ('Usman', 'Ahmed', 'usman.ahmed@factory.com', '0302-3456789', 2, 
     (SELECT RoleID FROM EmployeeRole WHERE RoleName = 'Salesperson'), 
     38000, 1);

PRINT 'Test salespersons inserted successfully.';
GO

-- Test the procedure
EXEC sp_GetSalespersonsForOrder;
GO
