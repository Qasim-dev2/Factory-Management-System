-- ================================================================================
-- ADD SAMPLE EMPLOYEES FOR EACH ROLE
-- Username + 4-digit PIN for login
-- ================================================================================

USE GarmentsFactoryDB;
GO

PRINT '==================== ADDING SAMPLE EMPLOYEES ====================';
GO

-- First, check what roles exist
SELECT RoleID, RoleName FROM EmployeeRole;
GO

-- Add sample employees for each role (one per role)
-- Format: Username = role name, PIN = 1234, 2345, 3456, etc.

-- Role 1: Salesperson
IF NOT EXISTS (SELECT 1 FROM Employee WHERE Username = 'salesperson')
BEGIN
    INSERT INTO Employee (FirstName, LastName, RoleID, Phone, Email, HireDate, Salary, Username, PIN, IsActive)
    VALUES ('John', 'Smith', 1, '0300-1234567', 'john.smith@factory.com', GETDATE(), 35000, 'salesperson', '1234', 1);
    PRINT '✅ Salesperson added (Username: salesperson, PIN: 1234)';
END

-- Role 2: Tailor
IF NOT EXISTS (SELECT 1 FROM Employee WHERE Username = 'tailor')
BEGIN
    INSERT INTO Employee (FirstName, LastName, RoleID, Phone, Email, HireDate, Salary, Username, PIN, IsActive)
    VALUES ('Ali', 'Ahmed', 2, '0300-2345678', 'ali.ahmed@factory.com', GETDATE(), 30000, 'tailor', '2345', 1);
    PRINT '✅ Tailor added (Username: tailor, PIN: 2345)';
END

-- Role 3: Sales Manager
IF NOT EXISTS (SELECT 1 FROM Employee WHERE Username = 'salesmanager')
BEGIN
    INSERT INTO Employee (FirstName, LastName, RoleID, Phone, Email, HireDate, Salary, Username, PIN, IsActive)
    VALUES ('Sarah', 'Khan', 3, '0300-3456789', 'sarah.khan@factory.com', GETDATE(), 50000, 'salesmanager', '3456', 1);
    PRINT '✅ Sales Manager added (Username: salesmanager, PIN: 3456)';
END

-- Role 4: Production Manager
IF NOT EXISTS (SELECT 1 FROM Employee WHERE Username = 'productionmanager')
BEGIN
    INSERT INTO Employee (FirstName, LastName, RoleID, Phone, Email, HireDate, Salary, Username, PIN, IsActive)
    VALUES ('Hassan', 'Ali', 4, '0300-4567890', 'hassan.ali@factory.com', GETDATE(), 55000, 'productionmanager', '4567', 1);
    PRINT '✅ Production Manager added (Username: productionmanager, PIN: 4567)';
END

-- Role 5: Delivery Person
IF NOT EXISTS (SELECT 1 FROM Employee WHERE Username = 'deliveryperson')
BEGIN
    INSERT INTO Employee (FirstName, LastName, RoleID, Phone, Email, HireDate, Salary, Username, PIN, IsActive)
    VALUES ('Ahmed', 'Raza', 5, '0300-5678901', 'ahmed.raza@factory.com', GETDATE(), 28000, 'deliveryperson', '5678', 1);
    PRINT '✅ Delivery Person added (Username: deliveryperson, PIN: 5678)';
END

PRINT '';
PRINT '==================== SAMPLE EMPLOYEES ADDED ====================';
PRINT '';
PRINT '📋 LOGIN CREDENTIALS:';
PRINT '---------------------------------------------------';
PRINT '👤 Owner (Hardcoded)       : owner / 0000';
PRINT '👤 Salesperson            : salesperson / 1234';
PRINT '👤 Tailor                 : tailor / 2345';
PRINT '👤 Sales Manager          : salesmanager / 3456';
PRINT '👤 Production Manager     : productionmanager / 4567';
PRINT '👤 Delivery Person        : deliveryperson / 5678';
PRINT '---------------------------------------------------';
GO

-- Verify all employees
SELECT 
    e.EmployeeID,
    e.FirstName,
    e.LastName,
    er.RoleName as Role,
    e.Username,
    e.PIN,
    e.IsActive
FROM Employee e
LEFT JOIN EmployeeRole er ON e.RoleID = er.RoleID
WHERE e.Username IS NOT NULL
ORDER BY e.RoleID;
GO
