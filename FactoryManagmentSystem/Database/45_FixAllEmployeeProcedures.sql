-- ================================================================================
-- Script: 45_FixAllEmployeeProcedures.sql
-- Purpose: Update ALL employee procedures to match cleaned table
-- Date: December 9, 2025
-- ================================================================================

USE GarmentsFactoryDB;
GO

PRINT '========================================';
PRINT 'Fixing ALL Employee Procedures';
PRINT '========================================';
PRINT '';

-- ================================================================================
-- 1. sp_GetEmployees (Paginated List)
-- ================================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetEmployees')
BEGIN
    DROP PROCEDURE sp_GetEmployees;
    PRINT '✓ Dropped old sp_GetEmployees';
END
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
           e.CNIC LIKE '%' + @SearchTerm + '%' OR
           e.Username LIKE '%' + @SearchTerm + '%');
    
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
        e.Salary,
        e.JoinDate,
        e.Username,
        e.PIN,
        e.IsActive,
        e.CreatedDate,
        e.LastLogin,
        @TotalCount AS TotalCount
    FROM Employee e
    INNER JOIN Department d ON e.DepartmentID = d.DepartmentID
    INNER JOIN EmployeeRole r ON e.RoleID = r.RoleID
    WHERE (@SearchTerm = '' OR 
           e.FirstName LIKE '%' + @SearchTerm + '%' OR 
           e.LastName LIKE '%' + @SearchTerm + '%' OR
           e.Email LIKE '%' + @SearchTerm + '%' OR
           e.Phone LIKE '%' + @SearchTerm + '%' OR
           e.CNIC LIKE '%' + @SearchTerm + '%' OR
           e.Username LIKE '%' + @SearchTerm + '%')
    ORDER BY e.EmployeeID DESC
    OFFSET @Offset ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END
GO
PRINT '✓ Created sp_GetEmployees';
PRINT '';

-- ================================================================================
-- 2. sp_GetEmployeeById
-- ================================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetEmployeeById')
BEGIN
    DROP PROCEDURE sp_GetEmployeeById;
    PRINT '✓ Dropped old sp_GetEmployeeById';
END
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
        e.Salary,
        e.JoinDate,
        e.Username,
        e.PIN,
        e.IsActive,
        e.CreatedDate,
        e.LastLogin
    FROM Employee e
    INNER JOIN Department d ON e.DepartmentID = d.DepartmentID
    INNER JOIN EmployeeRole r ON e.RoleID = r.RoleID
    WHERE e.EmployeeID = @EmployeeID;
END
GO
PRINT '✓ Created sp_GetEmployeeById';
PRINT '';

-- ================================================================================
-- 3. sp_DeleteEmployee (Soft Delete)
-- ================================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_DeleteEmployee')
BEGIN
    DROP PROCEDURE sp_DeleteEmployee;
    PRINT '✓ Dropped old sp_DeleteEmployee';
END
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
        SET IsActive = 0
        WHERE EmployeeID = @EmployeeID;
        
        COMMIT TRANSACTION;
        
        SELECT 'SUCCESS' AS Status, 'Employee deactivated successfully.' AS Message;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        SELECT 'ERROR' AS Status, ERROR_MESSAGE() AS Message;
    END CATCH
END
GO
PRINT '✓ Created sp_DeleteEmployee';
PRINT '';

PRINT '========================================';
PRINT 'All Employee Procedures Fixed!';
PRINT '========================================';
PRINT '';
PRINT 'Updated Procedures:';
PRINT '1. sp_GetEmployees - Returns only valid columns';
PRINT '2. sp_GetEmployeeById - Returns only valid columns';
PRINT '3. sp_DeleteEmployee - Soft delete (IsActive = 0)';
PRINT '4. sp_AddEmployee - Already updated in previous script';
PRINT '5. sp_UpdateEmployee - Already updated in previous script';
PRINT '';
GO
