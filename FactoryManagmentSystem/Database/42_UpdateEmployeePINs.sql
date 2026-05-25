-- Update existing employees with PINs
USE GarmentsFactoryDB;
GO

PRINT 'Updating existing employees with PINs...';
GO

-- Update Salesperson
UPDATE Employee SET PIN = '1234' WHERE Username = 'salesperson';
PRINT '✅ Salesperson PIN: 1234';

-- Update Tailor
UPDATE Employee SET PIN = '2345' WHERE Username = 'tailor';
PRINT '✅ Tailor PIN: 2345';

-- Update Sales Manager
UPDATE Employee SET PIN = '3456' WHERE Username = 'manager';
PRINT '✅ Sales Manager PIN: 3456';

-- Update Production Manager
UPDATE Employee SET PIN = '4567' WHERE Username = 'production';
PRINT '✅ Production Manager PIN: 4567';

-- Update Delivery Person
UPDATE Employee SET PIN = '5678' WHERE Username = 'delivery';
PRINT '✅ Delivery Person PIN: 5678';

PRINT '';
PRINT '==================== PINs UPDATED ====================';
PRINT '';
PRINT '📋 LOGIN CREDENTIALS:';
PRINT '---------------------------------------------------';
PRINT '👤 Owner (Hardcoded)       : owner / 0000';
PRINT '👤 Salesperson            : salesperson / 1234';
PRINT '👤 Tailor                 : tailor / 2345';
PRINT '👤 Sales Manager          : manager / 3456';
PRINT '👤 Production Manager     : production / 4567';
PRINT '👤 Delivery Person        : delivery / 5678';
PRINT '---------------------------------------------------';
GO

-- Verify
SELECT 
    e.EmployeeID,
    CONCAT(e.FirstName, ' ', e.LastName) as FullName,
    er.RoleName as Role,
    e.Username,
    e.PIN
FROM Employee e
LEFT JOIN EmployeeRole er ON e.RoleID = er.RoleID
WHERE e.Username IS NOT NULL AND e.Username != 'owner'
ORDER BY e.RoleID;
GO
