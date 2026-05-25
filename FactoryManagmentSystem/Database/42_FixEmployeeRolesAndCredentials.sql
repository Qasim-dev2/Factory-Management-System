-- ================================================================================
-- FIX EMPLOYEE ROLES AND SAMPLE EMPLOYEES
-- Ensures roles match the login screen options
-- ================================================================================

USE GarmentsFactoryDB;
GO

PRINT '==================== FIXING EMPLOYEE ROLES ====================';
GO

-- ================================================================================
-- STEP 1: Update or Add Required Roles
-- ================================================================================
PRINT 'Step 1: Updating Employee Roles...';
GO

-- Check and update existing roles or insert new ones
-- Required roles: Salesperson, Tailor, Sales Manager, Production Manager, Delivery Person

-- Salesperson (RoleID 1)
IF NOT EXISTS (SELECT 1 FROM EmployeeRole WHERE RoleName = 'Salesperson')
BEGIN
    IF EXISTS (SELECT 1 FROM EmployeeRole WHERE RoleID = 1)
        UPDATE EmployeeRole SET RoleName = 'Salesperson', Description = 'Sales staff responsible for customer relations and orders' WHERE RoleID = 1;
    ELSE
        INSERT INTO EmployeeRole (RoleName, Description, IsActive) VALUES ('Salesperson', 'Sales staff responsible for customer relations and orders', 1);
    PRINT '✅ Salesperson role added/updated';
END
ELSE
    PRINT '⚠️ Salesperson role already exists';

-- Tailor (RoleID 2)
IF NOT EXISTS (SELECT 1 FROM EmployeeRole WHERE RoleName = 'Tailor')
BEGIN
    IF EXISTS (SELECT 1 FROM EmployeeRole WHERE RoleID = 2)
        UPDATE EmployeeRole SET RoleName = 'Tailor', Description = 'Production worker responsible for garment stitching' WHERE RoleID = 2;
    ELSE
        INSERT INTO EmployeeRole (RoleName, Description, IsActive) VALUES ('Tailor', 'Production worker responsible for garment stitching', 1);
    PRINT '✅ Tailor role added/updated';
END
ELSE
    PRINT '⚠️ Tailor role already exists';

-- Sales Manager (RoleID 3)
IF NOT EXISTS (SELECT 1 FROM EmployeeRole WHERE RoleName = 'Sales Manager')
BEGIN
    IF EXISTS (SELECT 1 FROM EmployeeRole WHERE RoleID = 3)
        UPDATE EmployeeRole SET RoleName = 'Sales Manager', Description = 'Manager responsible for sales department' WHERE RoleID = 3;
    ELSE
        INSERT INTO EmployeeRole (RoleName, Description, IsActive) VALUES ('Sales Manager', 'Manager responsible for sales department', 1);
    PRINT '✅ Sales Manager role added/updated';
END
ELSE
    PRINT '⚠️ Sales Manager role already exists';

-- Production Manager (RoleID 4)
IF NOT EXISTS (SELECT 1 FROM EmployeeRole WHERE RoleName = 'Production Manager')
BEGIN
    IF EXISTS (SELECT 1 FROM EmployeeRole WHERE RoleID = 4)
        UPDATE EmployeeRole SET RoleName = 'Production Manager', Description = 'Manager responsible for production department' WHERE RoleID = 4;
    ELSE
        INSERT INTO EmployeeRole (RoleName, Description, IsActive) VALUES ('Production Manager', 'Manager responsible for production department', 1);
    PRINT '✅ Production Manager role added/updated';
END
ELSE
    PRINT '⚠️ Production Manager role already exists';

-- Delivery Person (RoleID 5)
IF NOT EXISTS (SELECT 1 FROM EmployeeRole WHERE RoleName = 'Delivery Person')
BEGIN
    IF EXISTS (SELECT 1 FROM EmployeeRole WHERE RoleID = 5)
        UPDATE EmployeeRole SET RoleName = 'Delivery Person', Description = 'Staff responsible for order deliveries' WHERE RoleID = 5;
    ELSE
        INSERT INTO EmployeeRole (RoleName, Description, IsActive) VALUES ('Delivery Person', 'Staff responsible for order deliveries', 1);
    PRINT '✅ Delivery Person role added/updated';
END
ELSE
    PRINT '⚠️ Delivery Person role already exists';
GO

-- Show current roles
PRINT '';
PRINT 'Current Employee Roles:';
SELECT RoleID, RoleName, Description FROM EmployeeRole ORDER BY RoleID;
GO

-- ================================================================================
-- STEP 2: Get Role IDs for inserting sample employees
-- ================================================================================
PRINT '';
PRINT 'Step 2: Adding Sample Employees...';
GO

DECLARE @SalespersonRoleID INT, @TailorRoleID INT, @SalesManagerRoleID INT, @ProductionManagerRoleID INT, @DeliveryPersonRoleID INT;

SELECT @SalespersonRoleID = RoleID FROM EmployeeRole WHERE RoleName = 'Salesperson';
SELECT @TailorRoleID = RoleID FROM EmployeeRole WHERE RoleName = 'Tailor';
SELECT @SalesManagerRoleID = RoleID FROM EmployeeRole WHERE RoleName = 'Sales Manager';
SELECT @ProductionManagerRoleID = RoleID FROM EmployeeRole WHERE RoleName = 'Production Manager';
SELECT @DeliveryPersonRoleID = RoleID FROM EmployeeRole WHERE RoleName = 'Delivery Person';

-- Salesperson
IF NOT EXISTS (SELECT 1 FROM Employee WHERE Username = 'salesperson')
BEGIN
    INSERT INTO Employee (FirstName, LastName, RoleID, Phone, Email, HireDate, Salary, Username, PIN, IsActive)
    VALUES ('John', 'Smith', @SalespersonRoleID, '0300-1234567', 'john.smith@factory.com', GETDATE(), 35000, 'salesperson', '1234', 1);
    PRINT '✅ Salesperson added (Username: salesperson, PIN: 1234)';
END
ELSE
BEGIN
    UPDATE Employee SET RoleID = @SalespersonRoleID, PIN = '1234', IsActive = 1 WHERE Username = 'salesperson';
    PRINT '⚠️ Salesperson updated with correct RoleID';
END

-- Tailor
IF NOT EXISTS (SELECT 1 FROM Employee WHERE Username = 'tailor')
BEGIN
    INSERT INTO Employee (FirstName, LastName, RoleID, Phone, Email, HireDate, Salary, Username, PIN, IsActive)
    VALUES ('Ali', 'Ahmed', @TailorRoleID, '0300-2345678', 'ali.ahmed@factory.com', GETDATE(), 30000, 'tailor', '2345', 1);
    PRINT '✅ Tailor added (Username: tailor, PIN: 2345)';
END
ELSE
BEGIN
    UPDATE Employee SET RoleID = @TailorRoleID, PIN = '2345', IsActive = 1 WHERE Username = 'tailor';
    PRINT '⚠️ Tailor updated with correct RoleID';
END

-- Sales Manager
IF NOT EXISTS (SELECT 1 FROM Employee WHERE Username = 'salesmanager')
BEGIN
    INSERT INTO Employee (FirstName, LastName, RoleID, Phone, Email, HireDate, Salary, Username, PIN, IsActive)
    VALUES ('Sarah', 'Khan', @SalesManagerRoleID, '0300-3456789', 'sarah.khan@factory.com', GETDATE(), 50000, 'salesmanager', '3456', 1);
    PRINT '✅ Sales Manager added (Username: salesmanager, PIN: 3456)';
END
ELSE
BEGIN
    UPDATE Employee SET RoleID = @SalesManagerRoleID, PIN = '3456', IsActive = 1 WHERE Username = 'salesmanager';
    PRINT '⚠️ Sales Manager updated with correct RoleID';
END

-- Production Manager
IF NOT EXISTS (SELECT 1 FROM Employee WHERE Username = 'productionmanager')
BEGIN
    INSERT INTO Employee (FirstName, LastName, RoleID, Phone, Email, HireDate, Salary, Username, PIN, IsActive)
    VALUES ('Hassan', 'Ali', @ProductionManagerRoleID, '0300-4567890', 'hassan.ali@factory.com', GETDATE(), 55000, 'productionmanager', '4567', 1);
    PRINT '✅ Production Manager added (Username: productionmanager, PIN: 4567)';
END
ELSE
BEGIN
    UPDATE Employee SET RoleID = @ProductionManagerRoleID, PIN = '4567', IsActive = 1 WHERE Username = 'productionmanager';
    PRINT '⚠️ Production Manager updated with correct RoleID';
END

-- Delivery Person
IF NOT EXISTS (SELECT 1 FROM Employee WHERE Username = 'deliveryperson')
BEGIN
    INSERT INTO Employee (FirstName, LastName, RoleID, Phone, Email, HireDate, Salary, Username, PIN, IsActive)
    VALUES ('Ahmed', 'Raza', @DeliveryPersonRoleID, '0300-5678901', 'ahmed.raza@factory.com', GETDATE(), 28000, 'deliveryperson', '5678', 1);
    PRINT '✅ Delivery Person added (Username: deliveryperson, PIN: 5678)';
END
ELSE
BEGIN
    UPDATE Employee SET RoleID = @DeliveryPersonRoleID, PIN = '5678', IsActive = 1 WHERE Username = 'deliveryperson';
    PRINT '⚠️ Delivery Person updated with correct RoleID';
END
GO

-- ================================================================================
-- STEP 3: Verify all employees with login credentials
-- ================================================================================
PRINT '';
PRINT '==================== VERIFICATION ====================';
PRINT '';

SELECT 
    e.EmployeeID,
    e.FirstName,
    e.LastName,
    er.RoleName as Role,
    e.Username,
    e.PIN,
    CASE WHEN ISNULL(e.IsActive, 1) = 1 THEN 'Active' ELSE 'Inactive' END as Status
FROM Employee e
LEFT JOIN EmployeeRole er ON e.RoleID = er.RoleID
WHERE e.Username IS NOT NULL
ORDER BY er.RoleID;
GO

PRINT '';
PRINT '📋 LOGIN CREDENTIALS:';
PRINT '---------------------------------------------------';
PRINT '👔 Owner (Hardcoded)       : owner / 0000';
PRINT '🛍️ Salesperson            : salesperson / 1234';
PRINT '✂️ Tailor                 : tailor / 2345';
PRINT '📊 Sales Manager          : salesmanager / 3456';
PRINT '⚙️ Production Manager     : productionmanager / 4567';
PRINT '🚚 Delivery Person        : deliveryperson / 5678';
PRINT '---------------------------------------------------';
GO
