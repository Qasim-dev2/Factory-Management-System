-- ================================================================================
-- EMPLOYEE MODULE - STORED PROCEDURES
-- ================================================================================
-- Execute this script in SSMS after creating the database tables
-- These procedures handle all CRUD operations for the Employee module
-- ================================================================================

USE GarmentsFactoryDB;
GO

-- ================================================================================
-- 1. GET ALL EMPLOYEES (with pagination and search)
-- ================================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetEmployees')
    DROP PROCEDURE sp_GetEmployees;
GO

CREATE PROCEDURE sp_GetEmployees
    @PageNumber INT = 1,
    @PageSize INT = 10,
    @SearchTerm NVARCHAR(100) = ''
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @Offset INT = (@PageNumber - 1) * @PageSize;
    
    -- Get total count
    DECLARE @TotalCount INT;
    SELECT @TotalCount = COUNT(*)
    FROM Employee e
    WHERE (@SearchTerm = '' OR 
           e.FirstName LIKE '%' + @SearchTerm + '%' OR 
           e.LastName LIKE '%' + @SearchTerm + '%' OR
           e.Email LIKE '%' + @SearchTerm + '%' OR
           e.Phone LIKE '%' + @SearchTerm + '%' OR
           e.CNIC LIKE '%' + @SearchTerm + '%');
    
    -- Get paginated data
    SELECT 
        e.EmployeeID,
        e.FirstName,
        e.LastName,
        e.Email,
        e.Phone,
        e.CNIC,
        e.Address,
        e.EmergencyContact,
        e.DepartmentID,
        d.DepartmentName,
        e.RoleID,
        r.RoleName AS Position,
        e.ShiftType,
        e.Salary,
        e.JoinDate,
        e.Notes,
        -- Salesperson fields
        e.CommissionRate,
        e.SalesTarget,
        e.TotalSales,
        e.SalesRegion,
        -- Tailor fields
        e.Specialization,
        e.PieceRate,
        e.TotalPiecesCompleted,
        -- System fields
        e.IsActive,
        e.CreatedDate,
        @TotalCount AS TotalCount
    FROM Employee e
    INNER JOIN Department d ON e.DepartmentID = d.DepartmentID
    INNER JOIN EmployeeRole r ON e.RoleID = r.RoleID
    WHERE (@SearchTerm = '' OR 
           e.FirstName LIKE '%' + @SearchTerm + '%' OR 
           e.LastName LIKE '%' + @SearchTerm + '%' OR
           e.Email LIKE '%' + @SearchTerm + '%' OR
           e.Phone LIKE '%' + @SearchTerm + '%' OR
           e.CNIC LIKE '%' + @SearchTerm + '%')
    ORDER BY e.EmployeeID DESC
    OFFSET @Offset ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END
GO

-- ================================================================================
-- 2. GET EMPLOYEE BY ID
-- ================================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetEmployeeById')
    DROP PROCEDURE sp_GetEmployeeById;
GO

CREATE PROCEDURE sp_GetEmployeeById
    @EmployeeID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        e.EmployeeID,
        e.FirstName,
        e.LastName,
        e.Email,
        e.Phone,
        e.CNIC,
        e.Address,
        e.EmergencyContact,
        e.DepartmentID,
        d.DepartmentName,
        e.RoleID,
        r.RoleName AS Position,
        e.ShiftType,
        e.Salary,
        e.JoinDate,
        e.Notes,
        -- Salesperson fields
        e.CommissionRate,
        e.SalesTarget,
        e.TotalSales,
        e.SalesRegion,
        -- Tailor fields
        e.Specialization,
        e.PieceRate,
        e.TotalPiecesCompleted,
        -- System fields
        e.IsActive,
        e.CreatedDate,
        e.UpdatedDate
    FROM Employee e
    INNER JOIN Department d ON e.DepartmentID = d.DepartmentID
    INNER JOIN EmployeeRole r ON e.RoleID = r.RoleID
    WHERE e.EmployeeID = @EmployeeID;
END
GO

-- ================================================================================
-- 3. ADD NEW EMPLOYEE
-- ================================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_AddEmployee')
    DROP PROCEDURE sp_AddEmployee;
GO

CREATE PROCEDURE sp_AddEmployee
    @FirstName NVARCHAR(50),
    @LastName NVARCHAR(50),
    @Email NVARCHAR(100) = NULL,
    @Phone NVARCHAR(20) = NULL,
    @CNIC NVARCHAR(15) = NULL,
    @Address NVARCHAR(500) = NULL,
    @EmergencyContact NVARCHAR(100) = NULL,
    @DepartmentID INT,
    @RoleID INT,
    @ShiftType NVARCHAR(20) = NULL,
    @Salary DECIMAL(18,2) = 0,
    @JoinDate DATE = NULL,
    @Notes NVARCHAR(1000) = NULL,
    -- Salesperson fields
    @CommissionRate DECIMAL(5,2) = NULL,
    @SalesTarget DECIMAL(18,2) = NULL,
    @SalesRegion NVARCHAR(100) = NULL,
    -- Tailor fields
    @Specialization NVARCHAR(100) = NULL,
    @PieceRate DECIMAL(18,2) = NULL,
    @NewEmployeeID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Set default JoinDate if not provided
        IF @JoinDate IS NULL
            SET @JoinDate = GETDATE();
        
        INSERT INTO Employee (
            FirstName, LastName, Email, Phone, CNIC, Address, EmergencyContact,
            DepartmentID, RoleID, ShiftType, Salary, JoinDate, Notes,
            CommissionRate, SalesTarget, TotalSales, SalesRegion,
            Specialization, PieceRate, TotalPiecesCompleted,
            IsActive, CreatedDate
        )
        VALUES (
            @FirstName, @LastName, @Email, @Phone, @CNIC, @Address, @EmergencyContact,
            @DepartmentID, @RoleID, @ShiftType, @Salary, @JoinDate, @Notes,
            @CommissionRate, @SalesTarget, 0, @SalesRegion,
            @Specialization, @PieceRate, 0,
            1, GETDATE()
        );
        
        SET @NewEmployeeID = SCOPE_IDENTITY();
        
        COMMIT TRANSACTION;
        
        SELECT 'SUCCESS' AS Status, 'Employee added successfully.' AS Message, @NewEmployeeID AS EmployeeID;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SELECT 'ERROR' AS Status, ERROR_MESSAGE() AS Message, 0 AS EmployeeID;
    END CATCH
END
GO

-- ================================================================================
-- 4. UPDATE EMPLOYEE
-- ================================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_UpdateEmployee')
    DROP PROCEDURE sp_UpdateEmployee;
GO

CREATE PROCEDURE sp_UpdateEmployee
    @EmployeeID INT,
    @FirstName NVARCHAR(50),
    @LastName NVARCHAR(50),
    @Email NVARCHAR(100) = NULL,
    @Phone NVARCHAR(20) = NULL,
    @CNIC NVARCHAR(15) = NULL,
    @Address NVARCHAR(500) = NULL,
    @EmergencyContact NVARCHAR(100) = NULL,
    @DepartmentID INT,
    @RoleID INT,
    @ShiftType NVARCHAR(20) = NULL,
    @Salary DECIMAL(18,2) = 0,
    @JoinDate DATE = NULL,
    @Notes NVARCHAR(1000) = NULL,
    -- Salesperson fields
    @CommissionRate DECIMAL(5,2) = NULL,
    @SalesTarget DECIMAL(18,2) = NULL,
    @TotalSales DECIMAL(18,2) = NULL,
    @SalesRegion NVARCHAR(100) = NULL,
    -- Tailor fields
    @Specialization NVARCHAR(100) = NULL,
    @PieceRate DECIMAL(18,2) = NULL,
    @TotalPiecesCompleted INT = NULL,
    @IsActive BIT = 1
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        UPDATE Employee
        SET 
            FirstName = @FirstName,
            LastName = @LastName,
            Email = @Email,
            Phone = @Phone,
            CNIC = @CNIC,
            Address = @Address,
            EmergencyContact = @EmergencyContact,
            DepartmentID = @DepartmentID,
            RoleID = @RoleID,
            ShiftType = @ShiftType,
            Salary = @Salary,
            JoinDate = @JoinDate,
            Notes = @Notes,
            CommissionRate = @CommissionRate,
            SalesTarget = @SalesTarget,
            TotalSales = ISNULL(@TotalSales, TotalSales),
            SalesRegion = @SalesRegion,
            Specialization = @Specialization,
            PieceRate = @PieceRate,
            TotalPiecesCompleted = ISNULL(@TotalPiecesCompleted, TotalPiecesCompleted),
            IsActive = @IsActive,
            UpdatedDate = GETDATE()
        WHERE EmployeeID = @EmployeeID;
        
        COMMIT TRANSACTION;
        
        SELECT 'SUCCESS' AS Status, 'Employee updated successfully.' AS Message;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SELECT 'ERROR' AS Status, ERROR_MESSAGE() AS Message;
    END CATCH
END
GO

-- ================================================================================
-- 5. DELETE EMPLOYEE (Soft Delete)
-- ================================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_DeleteEmployee')
    DROP PROCEDURE sp_DeleteEmployee;
GO

CREATE PROCEDURE sp_DeleteEmployee
    @EmployeeID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Soft delete by setting IsActive to 0
        UPDATE Employee
        SET IsActive = 0, UpdatedDate = GETDATE()
        WHERE EmployeeID = @EmployeeID;
        
        COMMIT TRANSACTION;
        
        SELECT 'SUCCESS' AS Status, 'Employee deleted successfully.' AS Message;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SELECT 'ERROR' AS Status, ERROR_MESSAGE() AS Message;
    END CATCH
END
GO

-- ================================================================================
-- 6. GET ALL DEPARTMENTS (for dropdown)
-- ================================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetDepartments')
    DROP PROCEDURE sp_GetDepartments;
GO

CREATE PROCEDURE sp_GetDepartments
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        DepartmentID,
        DepartmentName,
        Description
    FROM Department
    WHERE IsActive = 1
    ORDER BY DepartmentName;
END
GO

-- ================================================================================
-- 7. GET ALL EMPLOYEE ROLES (for dropdown)
-- ================================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetEmployeeRoles')
    DROP PROCEDURE sp_GetEmployeeRoles;
GO

CREATE PROCEDURE sp_GetEmployeeRoles
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        RoleID,
        RoleName,
        Description
    FROM EmployeeRole
    WHERE IsActive = 1
    ORDER BY RoleName;
END
GO

-- ================================================================================
-- STORED PROCEDURES CREATED SUCCESSFULLY!
-- ================================================================================
PRINT '========================================';
PRINT 'EMPLOYEE STORED PROCEDURES CREATED!';
PRINT 'Total Procedures: 7';
PRINT '1. sp_GetEmployees';
PRINT '2. sp_GetEmployeeById';
PRINT '3. sp_AddEmployee';
PRINT '4. sp_UpdateEmployee';
PRINT '5. sp_DeleteEmployee';
PRINT '6. sp_GetDepartments';
PRINT '7. sp_GetEmployeeRoles';
PRINT '========================================';
GO
