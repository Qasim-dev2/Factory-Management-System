-- =============================================
-- UPDATE SAMPLE EMPLOYEES DATA
-- Fill NULL fields with proper values
-- Keep LastLogin as NULL
-- Garments Factory Management System
-- Date: December 17, 2025
-- =============================================

USE GarmentsFactoryDB;
GO

PRINT '🔄 Updating employee data with complete information...';
PRINT '';

-- =============================================
-- DEPARTMENT 1: SALES EMPLOYEES
-- =============================================

PRINT '📌 UPDATING DEPARTMENT 1: SALES';

-- Sales Manager - Ahmad Khan
UPDATE Employee SET 
    EmergencyContact = '0300-9999998',
    CNIC = '12345-6789012-3',
    Address = 'Karachi, Pakistan'
WHERE FirstName = 'Ahmad' AND LastName = 'Khan' AND DepartmentID = 1 AND Position = 'Sales Manager';

-- Salesperson 1 - Ali Ahmed
UPDATE Employee SET 
    EmergencyContact = '0300-1111110',
    CNIC = '12345-6789013-3',
    Address = 'Karachi, Pakistan'
WHERE FirstName = 'Ali' AND LastName = 'Ahmed' AND DepartmentID = 1 AND Position = 'Sales Person' AND EmployeeID > 10;

-- Salesperson 2 - Fatima Hassan
UPDATE Employee SET 
    EmergencyContact = '0300-3333332',
    CNIC = '12345-6789014-3',
    Address = 'Lahore, Pakistan'
WHERE FirstName = 'Fatima' AND LastName = 'Hassan' AND DepartmentID = 1 AND Position = 'Sales Person';

-- Salesperson 3 - Hira Malik
UPDATE Employee SET 
    EmergencyContact = '0300-4444443',
    CNIC = '12345-6789015-3',
    Address = 'Islamabad, Pakistan'
WHERE FirstName = 'Hira' AND LastName = 'Malik' AND DepartmentID = 1 AND Position = 'Sales Person';

PRINT '   ✅ Updated Sales Department';

-- =============================================
-- DEPARTMENT 2: PRODUCTION EMPLOYEES
-- =============================================

PRINT '';
PRINT '📌 UPDATING DEPARTMENT 2: PRODUCTION';

-- Production Manager - Hassan Ahmed
UPDATE Employee SET 
    EmergencyContact = '0300-5555554',
    CNIC = '12345-6789016-3',
    Address = 'Karachi, Pakistan'
WHERE FirstName = 'Hassan' AND LastName = 'Ahmed' AND DepartmentID = 2 AND Position = 'Production Manager';

-- Tailor 1 - Zain Ali
UPDATE Employee SET 
    EmergencyContact = '0300-6666665',
    CNIC = '12345-6789017-3',
    Address = 'Karachi, Pakistan'
WHERE FirstName = 'Zain' AND LastName = 'Ali' AND DepartmentID = 2 AND Position = 'Tailor' AND EmployeeID > 10;

-- Tailor 2 - Bilal Hassan
UPDATE Employee SET 
    EmergencyContact = '0300-7777776',
    CNIC = '12345-6789018-3',
    Address = 'Lahore, Pakistan'
WHERE FirstName = 'Bilal' AND LastName = 'Hassan' AND DepartmentID = 2 AND Position = 'Tailor';

-- Tailor 3 - Aisha Khan
UPDATE Employee SET 
    EmergencyContact = '0300-8888887',
    CNIC = '12345-6789019-3',
    Address = 'Karachi, Pakistan'
WHERE FirstName = 'Aisha' AND LastName = 'Khan' AND DepartmentID = 2 AND Position = 'Tailor';

-- Tailor 4 - Samir Hassan
UPDATE Employee SET 
    EmergencyContact = '0300-9999998',
    CNIC = '12345-6789020-3',
    Address = 'Islamabad, Pakistan'
WHERE FirstName = 'Samir' AND LastName = 'Hassan' AND DepartmentID = 2 AND Position = 'Tailor';

PRINT '   ✅ Updated Production Department';

-- =============================================
-- DEPARTMENT 3: DELIVERY EMPLOYEES
-- =============================================

PRINT '';
PRINT '📌 UPDATING DEPARTMENT 3: DELIVERY';

-- Delivery Person 1 - Muhammad Khan
UPDATE Employee SET 
    EmergencyContact = '0300-1010100',
    CNIC = '12345-6789021-3',
    Address = 'Karachi, Pakistan'
WHERE FirstName = 'Muhammad' AND LastName = 'Khan' AND DepartmentID = 3 AND Position = 'Delivery Person' AND EmployeeID > 15;

-- Delivery Person 2 - Ahmed Ali
UPDATE Employee SET 
    EmergencyContact = '0300-1111111',
    CNIC = '12345-6789022-3',
    Address = 'Lahore, Pakistan'
WHERE FirstName = 'Ahmed' AND LastName = 'Ali' AND DepartmentID = 3 AND Position = 'Delivery Person' AND EmployeeID > 15;

-- Delivery Person 3 - Hassan Malik
UPDATE Employee SET 
    EmergencyContact = '0300-1212120',
    CNIC = '12345-6789023-3',
    Address = 'Islamabad, Pakistan'
WHERE FirstName = 'Hassan' AND LastName = 'Malik' AND DepartmentID = 3 AND Position = 'Delivery Person';

PRINT '   ✅ Updated Delivery Department';

PRINT '';
PRINT '========================================';
PRINT '✅ ALL EMPLOYEE DATA UPDATED';
PRINT '========================================';
PRINT '';

-- Verification
PRINT '📋 VERIFICATION - Updated Data:';
PRINT '';
SELECT 
    EmployeeID,
    FirstName + ' ' + LastName AS FullName,
    Position,
    DepartmentID,
    RoleID,
    Phone,
    Email,
    Address,
    EmergencyContact,
    CNIC,
    LastLogin,
    Username,
    PIN
FROM Employee
WHERE EmployeeID >= 11 AND IsActive = 1
ORDER BY DepartmentID, EmployeeID;

GO
