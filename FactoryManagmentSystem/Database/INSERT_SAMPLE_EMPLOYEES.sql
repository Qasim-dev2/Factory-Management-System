-- =============================================
-- INSERT SAMPLE EMPLOYEES
-- Garments Factory Management System
-- Date: December 17, 2025
-- =============================================

USE GarmentsFactoryDB;
GO

PRINT '🔄 Starting employee data insertion...';
PRINT '';

-- =============================================
-- DEPARTMENT 1: SALES EMPLOYEES
-- =============================================

PRINT '📌 DEPARTMENT 1: SALES (1 Manager + 3 Salespersons)';

-- Sales Manager
INSERT INTO Employee (FirstName, LastName, Position, Phone, Email, DepartmentID, RoleID, Salary, JoinDate, Address, IsActive, CreatedDate, Username, PIN)
VALUES ('Ahmad', 'Khan', 'Sales Manager', '0300-1111111', 'ahmad.khan@factory.com', 1, 2, 80000, '2025-01-01', 'Karachi, Pakistan', 1, GETDATE(), 'ahmad_khan', '1234');

-- Salesperson 1
INSERT INTO Employee (FirstName, LastName, Position, Phone, Email, DepartmentID, RoleID, Salary, JoinDate, Address, IsActive, CreatedDate, Username, PIN)
VALUES ('Ali', 'Ahmed', 'Sales Person', '0300-2222222', 'ali.ahmed@factory.com', 1, 3, 40000, '2025-01-05', 'Karachi, Pakistan', 1, GETDATE(), 'ali_ahmed', '1234');

-- Salesperson 2
INSERT INTO Employee (FirstName, LastName, Position, Phone, Email, DepartmentID, RoleID, Salary, JoinDate, Address, IsActive, CreatedDate, Username, PIN)
VALUES ('Fatima', 'Hassan', 'Sales Person', '0300-3333333', 'fatima.hassan@factory.com', 1, 3, 40000, '2025-01-10', 'Lahore, Pakistan', 1, GETDATE(), 'fatima_hassan', '1234');

-- Salesperson 3
INSERT INTO Employee (FirstName, LastName, Position, Phone, Email, DepartmentID, RoleID, Salary, JoinDate, Address, IsActive, CreatedDate, Username, PIN)
VALUES ('Hira', 'Malik', 'Sales Person', '0300-4444444', 'hira.malik@factory.com', 1, 3, 40000, '2025-01-15', 'Islamabad, Pakistan', 1, GETDATE(), 'hira_malik', '1234');

PRINT '   ✅ Added 1 Sales Manager + 3 Sales Persons';

-- =============================================
-- DEPARTMENT 2: PRODUCTION EMPLOYEES
-- =============================================

PRINT '';
PRINT '📌 DEPARTMENT 2: PRODUCTION (1 Manager + 4 Tailors)';

-- Production Manager
INSERT INTO Employee (FirstName, LastName, Position, Phone, Email, DepartmentID, RoleID, Salary, JoinDate, Address, IsActive, CreatedDate, Username, PIN)
VALUES ('Hassan', 'Ahmed', 'Production Manager', '0300-5555555', 'hassan.ahmed@factory.com', 2, 4, 75000, '2025-01-01', 'Karachi, Pakistan', 1, GETDATE(), 'hassan_ahmed', '1234');

-- Tailor 1
INSERT INTO Employee (FirstName, LastName, Position, Phone, Email, DepartmentID, RoleID, Salary, JoinDate, Address, IsActive, CreatedDate, Username, PIN)
VALUES ('Zain', 'Ali', 'Tailor', '0300-6666666', 'zain.ali@factory.com', 2, 5, 35000, '2025-01-05', 'Karachi, Pakistan', 1, GETDATE(), 'zain_ali', '1234');

-- Tailor 2
INSERT INTO Employee (FirstName, LastName, Position, Phone, Email, DepartmentID, RoleID, Salary, JoinDate, Address, IsActive, CreatedDate, Username, PIN)
VALUES ('Bilal', 'Hassan', 'Tailor', '0300-7777777', 'bilal.hassan@factory.com', 2, 5, 32000, '2025-01-10', 'Lahore, Pakistan', 1, GETDATE(), 'bilal_hassan', '1234');

-- Tailor 3
INSERT INTO Employee (FirstName, LastName, Position, Phone, Email, DepartmentID, RoleID, Salary, JoinDate, Address, IsActive, CreatedDate, Username, PIN)
VALUES ('Aisha', 'Khan', 'Tailor', '0300-8888888', 'aisha.khan@factory.com', 2, 5, 32000, '2025-01-15', 'Karachi, Pakistan', 1, GETDATE(), 'aisha_khan', '1234');

-- Tailor 4
INSERT INTO Employee (FirstName, LastName, Position, Phone, Email, DepartmentID, RoleID, Salary, JoinDate, Address, IsActive, CreatedDate, Username, PIN)
VALUES ('Samir', 'Hassan', 'Tailor', '0300-9999999', 'samir.hassan@factory.com', 2, 5, 31000, '2025-01-20', 'Islamabad, Pakistan', 1, GETDATE(), 'samir_hassan', '1234');

PRINT '   ✅ Added 1 Production Manager + 4 Tailors';

-- =============================================
-- DEPARTMENT 3: DELIVERY EMPLOYEES
-- =============================================

PRINT '';
PRINT '📌 DEPARTMENT 3: DELIVERY (1 Coordinator + 2 Drivers)';

-- Delivery Person / Coordinator
INSERT INTO Employee (FirstName, LastName, Position, Phone, Email, DepartmentID, RoleID, Salary, JoinDate, Address, IsActive, CreatedDate, Username, PIN)
VALUES ('Muhammad', 'Khan', 'Delivery Person', '0300-1010101', 'muhammad.khan@factory.com', 3, 6, 35000, '2025-01-01', 'Karachi, Pakistan', 1, GETDATE(), 'muhammad_khan', '1234');

-- Delivery Driver 1
INSERT INTO Employee (FirstName, LastName, Position, Phone, Email, DepartmentID, RoleID, Salary, JoinDate, Address, IsActive, CreatedDate, Username, PIN)
VALUES ('Ahmed', 'Ali', 'Delivery Person', '0300-1111112', 'ahmed.driver@factory.com', 3, 6, 30000, '2025-01-05', 'Lahore, Pakistan', 1, GETDATE(), 'ahmed_driver', '1234');

-- Delivery Driver 2
INSERT INTO Employee (FirstName, LastName, Position, Phone, Email, DepartmentID, RoleID, Salary, JoinDate, Address, IsActive, CreatedDate, Username, PIN)
VALUES ('Hassan', 'Malik', 'Delivery Person', '0300-1212121', 'hassan.driver@factory.com', 3, 6, 30000, '2025-01-10', 'Islamabad, Pakistan', 1, GETDATE(), 'hassan_malik', '1234');

PRINT '   ✅ Added 1 Delivery Coordinator + 2 Delivery Drivers';

PRINT '';
PRINT '========================================';
PRINT '✅ ALL 12 EMPLOYEES INSERTED';
PRINT '========================================';
PRINT '';

-- Verification Queries
PRINT '📋 VERIFICATION:';
PRINT '';
PRINT '✅ TOTAL EMPLOYEE COUNT:';
SELECT COUNT(*) AS TotalEmployees FROM Employee WHERE IsActive = 1;

PRINT '';
PRINT '✅ EMPLOYEES BY DEPARTMENT:';
SELECT 
    (SELECT DepartmentName FROM Department WHERE DepartmentID = e.DepartmentID) AS Department,
    COUNT(*) AS EmployeeCount,
    STRING_AGG(FirstName + ' ' + LastName + ' (' + [Position] + ')', ', ') AS Employees
FROM Employee e
WHERE IsActive = 1
GROUP BY DepartmentID
ORDER BY DepartmentID;

PRINT '';
PRINT '✅ EMPLOYEES WITH ROLES:';
SELECT 
    e.EmployeeID,
    e.FirstName + ' ' + e.LastName AS FullName,
    e.Position,
    (SELECT DepartmentName FROM Department WHERE DepartmentID = e.DepartmentID) AS Department,
    (SELECT RoleName FROM Role WHERE RoleID = e.RoleID) AS Role,
    e.Salary,
    e.Username
FROM Employee e
WHERE e.IsActive = 1
ORDER BY e.DepartmentID, e.EmployeeID;

GO
