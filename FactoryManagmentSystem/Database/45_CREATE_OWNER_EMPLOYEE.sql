-- =============================================
-- CREATE OWNER EMPLOYEE RECORD
-- Fix the missing owner employee issue
-- Date: December 17, 2025
-- =============================================

USE GarmentsFactoryDB;
GO

PRINT '======================================='
PRINT 'CREATE OWNER EMPLOYEE RECORD'
PRINT '======================================='
PRINT ''

-- Check if owner employee already exists
IF NOT EXISTS (SELECT 1 FROM Employee WHERE EmployeeID = 1 AND RoleID = 1)
BEGIN
    -- Insert owner employee record
    SET IDENTITY_INSERT Employee ON;
    
    INSERT INTO Employee (
        EmployeeID,
        FirstName,
        LastName,
        Email,
        Phone,
        DepartmentID,
        RoleID,
        Salary,
        JoinDate,
        Address,
        EmergencyContact,
        CNIC,
        IsActive,
        CreatedDate,
        Username,
        PIN,
        Position
    )
    VALUES (
        1,                              -- EmployeeID = 1 for Owner
        'System',                       -- FirstName
        'Owner',                        -- LastName
        'owner@garmentsfactory.com',    -- Email
        '0300-0000000',                 -- Phone
        1,                              -- DepartmentID (Sales)
        1,                              -- RoleID (Owner)
        0.00,                           -- Salary (owner doesn't have salary)
        '2020-01-01',                   -- JoinDate
        'Factory Head Office',          -- Address
        '0300-0000000',                 -- EmergencyContact
        '00000-0000000-0',              -- CNIC
        1,                              -- IsActive
        GETDATE(),                      -- CreatedDate
        'owner',                        -- Username
        '0000',                         -- PIN
        'Factory Owner'                 -- Position
    );
    
    SET IDENTITY_INSERT Employee OFF;
    
    PRINT '✓ Owner employee record created (EmployeeID = 1)'
    PRINT '  Username: owner'
    PRINT '  PIN: 0000 (hardcoded in application)'
    PRINT ''
END
ELSE
BEGIN
    PRINT '⚠ Owner employee record already exists (EmployeeID = 1)'
    PRINT ''
END

-- Verify
SELECT 
    EmployeeID,
    FirstName + ' ' + LastName AS Name,
    RoleID,
    Email,
    Phone,
    IsActive
FROM Employee
WHERE EmployeeID = 1;

PRINT ''
PRINT '======================================='
PRINT 'OWNER EMPLOYEE RECORD READY'
PRINT '======================================='
PRINT 'Now owner (EmployeeID = 1) can approve orders'
PRINT '======================================='

GO
