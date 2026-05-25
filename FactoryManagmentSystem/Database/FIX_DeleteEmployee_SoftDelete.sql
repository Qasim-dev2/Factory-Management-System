-- =============================================
-- FIX: sp_DeleteEmployee - Change to Soft Delete
-- Issue: Hard delete fails due to foreign key constraints
-- Solution: Set IsActive = 0 instead of DELETE
-- =============================================

USE GarmentsFactoryDB;
GO

-- Drop existing procedure
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_DeleteEmployee')
BEGIN
    DROP PROCEDURE sp_DeleteEmployee;
    PRINT '✓ Dropped old sp_DeleteEmployee';
END
GO

-- Create updated procedure with SOFT DELETE
CREATE PROCEDURE sp_DeleteEmployee
    @EmployeeID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- Soft delete: Set IsActive = 0 instead of deleting
        -- This preserves historical data and referential integrity
        UPDATE Employee
        SET IsActive = 0
        WHERE EmployeeID = @EmployeeID;
        
        -- Return number of rows affected
        SELECT @@ROWCOUNT AS RowsAffected;
        
        PRINT '✓ Employee soft deleted (IsActive = 0)';
    END TRY
    BEGIN CATCH
        -- Return 0 if error occurs
        SELECT 0 AS RowsAffected;
        
        PRINT '✗ Error soft deleting employee: ' + ERROR_MESSAGE();
    END CATCH
END
GO

PRINT '';
PRINT '========================================';
PRINT '✓ sp_DeleteEmployee Fixed!';
PRINT '========================================';
PRINT 'Changes:';
PRINT '  - Changed from DELETE to soft delete (IsActive = 0)';
PRINT '  - Preserves historical data';
PRINT '  - Avoids foreign key constraint errors';
PRINT '  - Still returns RowsAffected for C# compatibility';
PRINT '';
GO

-- Test the procedure
PRINT 'Testing sp_DeleteEmployee...';
GO

-- Get a test employee ID (avoid critical employees)
DECLARE @TestEmployeeID INT;
SELECT TOP 1 @TestEmployeeID = EmployeeID 
FROM Employee 
WHERE IsActive = 1 
  AND RoleID NOT IN (1) -- Not Owner
ORDER BY EmployeeID DESC;

IF @TestEmployeeID IS NOT NULL
BEGIN
    PRINT 'Test Employee ID: ' + CAST(@TestEmployeeID AS NVARCHAR(10));
    
    -- Test soft delete
    EXEC sp_DeleteEmployee @EmployeeID = @TestEmployeeID;
    
    -- Verify employee is now inactive
    SELECT 
        EmployeeID,
        FirstName + ' ' + LastName AS FullName,
        IsActive,
        CASE WHEN IsActive = 0 THEN '✓ Successfully soft deleted' ELSE '✗ Still active' END AS Status
    FROM Employee
    WHERE EmployeeID = @TestEmployeeID;
    
    -- Reactivate for testing purposes
    UPDATE Employee SET IsActive = 1 WHERE EmployeeID = @TestEmployeeID;
    PRINT '✓ Test employee reactivated';
END
ELSE
BEGIN
    PRINT '⚠ No test employee found';
END
GO
