-- ================================================================================
-- INSERT TAILOR EMPLOYEES FOR PRODUCTION ORDER MANAGEMENT
-- ================================================================================
-- Execute this script in SQL Server Management Studio (SSMS)
-- This will add tailor employees to the Employee table
-- ================================================================================

USE GarmentsFactoryDB;
GO

-- First, let's check what roles exist
PRINT '=== Checking Employee Roles ===';
SELECT RoleID, RoleName FROM EmployeeRole;
GO

-- Check if Tailor role exists, if not create it
IF NOT EXISTS (SELECT 1 FROM EmployeeRole WHERE RoleName = 'Tailor')
BEGIN
    INSERT INTO EmployeeRole (RoleName, Description, IsActive)
    VALUES ('Tailor', 'Production worker responsible for garment stitching', 1);
    PRINT 'Tailor role created successfully.';
END
ELSE
BEGIN
    PRINT 'Tailor role already exists.';
END
GO

-- Get the RoleID for Tailor
DECLARE @TailorRoleID INT;
SELECT @TailorRoleID = RoleID FROM EmployeeRole WHERE RoleName = 'Tailor';
PRINT 'Tailor RoleID: ' + CAST(@TailorRoleID AS NVARCHAR);
GO

-- Check existing employees
PRINT '';
PRINT '=== Existing Employees ===';
SELECT 
    e.EmployeeID,
    e.FirstName,
    e.LastName,
    e.DepartmentID,
    e.RoleID,
    r.RoleName,
    e.Specialization
FROM Employee e
LEFT JOIN EmployeeRole r ON e.RoleID = r.RoleID
WHERE e.IsActive = 1;
GO

-- Now insert tailor employees if none exist
DECLARE @TailorRoleID INT;
DECLARE @ProductionDeptID INT = 1; -- Assuming Production Department ID is 1

SELECT @TailorRoleID = RoleID FROM EmployeeRole WHERE RoleName = 'Tailor';

-- Check if tailors already exist
IF NOT EXISTS (SELECT 1 FROM Employee WHERE RoleID = @TailorRoleID AND IsActive = 1)
BEGIN
    PRINT '';
    PRINT '=== Inserting Tailor Employees ===';
    
    -- Insert Tailor 1
    INSERT INTO Employee (
        FirstName, LastName, Email, Phone, 
        DepartmentID, RoleID, 
        Specialization, PieceRate, TotalPiecesCompleted,
        ShiftType, Salary, JoinDate, IsActive
    )
    VALUES 
    (
        'Ali', 'Hassan', 'ali.hassan@factory.com', '0300-1111111',
        @ProductionDeptID, @TailorRoleID,
        'Shirts & T-Shirts', 50.00, 0,
        'Morning', 35000.00, CAST(GETDATE() AS DATE), 1
    );
    PRINT 'Tailor 1 (Ali Hassan) inserted successfully.';
    
    -- Insert Tailor 2
    INSERT INTO Employee (
        FirstName, LastName, Email, Phone, 
        DepartmentID, RoleID, 
        Specialization, PieceRate, TotalPiecesCompleted,
        ShiftType, Salary, JoinDate, IsActive
    )
    VALUES 
    (
        'Fatima', 'Khan', 'fatima.khan@factory.com', '0300-2222222',
        @ProductionDeptID, @TailorRoleID,
        'Pants & Trousers', 60.00, 0,
        'Morning', 38000.00, CAST(GETDATE() AS DATE), 1
    );
    PRINT 'Tailor 2 (Fatima Khan) inserted successfully.';
    
    -- Insert Tailor 3
    INSERT INTO Employee (
        FirstName, LastName, Email, Phone, 
        DepartmentID, RoleID, 
        Specialization, PieceRate, TotalPiecesCompleted,
        ShiftType, Salary, JoinDate, IsActive
    )
    VALUES 
    (
        'Munneb', 'Ali', 'munneb.ali@factory.com', '0300-3333333',
        @ProductionDeptID, @TailorRoleID,
        'Kurtas & Traditional Wear', 55.00, 0,
        'Evening', 36000.00, CAST(GETDATE() AS DATE), 1
    );
    PRINT 'Tailor 3 (Munneb Ali) inserted successfully.';
    
    -- Insert Tailor 4
    INSERT INTO Employee (
        FirstName, LastName, Email, Phone, 
        DepartmentID, RoleID, 
        Specialization, PieceRate, TotalPiecesCompleted,
        ShiftType, Salary, JoinDate, IsActive
    )
    VALUES 
    (
        'Usman', 'Ahmed', 'usman.ahmed@factory.com', '0300-4444444',
        @ProductionDeptID, @TailorRoleID,
        'Jackets & Coats', 70.00, 0,
        'Morning', 42000.00, CAST(GETDATE() AS DATE), 1
    );
    PRINT 'Tailor 4 (Usman Ahmed) inserted successfully.';
    
    PRINT '';
    PRINT 'All tailor employees inserted successfully!';
END
ELSE
BEGIN
    PRINT '';
    PRINT 'Tailor employees already exist in the database.';
END
GO

-- Verify the inserted tailors
PRINT '';
PRINT '=== Verifying Tailor Employees ===';
SELECT 
    e.EmployeeID,
    CONCAT(e.FirstName, ' ', e.LastName) AS FullName,
    e.Email,
    e.Phone,
    e.Specialization,
    e.PieceRate,
    e.Salary,
    e.ShiftType,
    r.RoleName
FROM Employee e
INNER JOIN EmployeeRole r ON e.RoleID = r.RoleID
WHERE r.RoleName = 'Tailor' AND e.IsActive = 1
ORDER BY e.EmployeeID;
GO

PRINT '';
PRINT '========================================';
PRINT 'TAILOR EMPLOYEES SETUP COMPLETE!';
PRINT 'Execute this script in SSMS to add tailors to your database.';
PRINT 'Then restart your application to see them in the dropdown.';
PRINT '========================================';
