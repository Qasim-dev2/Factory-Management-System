/*******************************************************************************
 * UPDATE EMPLOYEE TABLE - Remove Unused Columns
 * GarmentsFactoryDB
 * 
 * Purpose: Remove Specialization, PieceRate, TotalPiecesCompleted, ShiftType
 *          and update all related stored procedures
 * 
 * Columns Being Removed:
 * - Specialization
 * - PieceRate
 * - TotalPiecesCompleted
 * - ShiftType
 * 
 * Procedures Being Updated:
 * - sp_GetAvailableTailors
 * - sp_GetTailorsForAssignment
 * - sp_GetAllProductionOrders
 * - sp_GetProductionOrderById
 * 
 * Created: December 14, 2025
 ******************************************************************************/

USE GarmentsFactoryDB;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

PRINT '============================================================================';
PRINT 'UPDATING EMPLOYEE TABLE STRUCTURE';
PRINT 'Timestamp: ' + CONVERT(VARCHAR, GETDATE(), 120);
PRINT '============================================================================';
PRINT '';

-- ============================================================================
-- STEP 1: Drop the columns from Employee table
-- ============================================================================
PRINT '-- STEP 1: Removing columns from Employee table...';

-- Drop Specialization column
IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Employee') AND name = 'Specialization')
BEGIN
    ALTER TABLE Employee DROP COLUMN Specialization;
    PRINT '  Dropped column: Specialization';
END

-- Drop PieceRate column
IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Employee') AND name = 'PieceRate')
BEGIN
    ALTER TABLE Employee DROP COLUMN PieceRate;
    PRINT '  Dropped column: PieceRate';
END

-- Drop TotalPiecesCompleted column
IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Employee') AND name = 'TotalPiecesCompleted')
BEGIN
    ALTER TABLE Employee DROP COLUMN TotalPiecesCompleted;
    PRINT '  Dropped column: TotalPiecesCompleted';
END

-- Drop ShiftType column
IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Employee') AND name = 'ShiftType')
BEGIN
    ALTER TABLE Employee DROP COLUMN ShiftType;
    PRINT '  Dropped column: ShiftType';
END

PRINT '';
PRINT 'Employee table columns updated successfully.';
PRINT '';

-- ============================================================================
-- STEP 2: Update sp_GetAvailableTailors
-- ============================================================================
PRINT '-- STEP 2: Updating sp_GetAvailableTailors...';

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'sp_GetAvailableTailors')
    DROP PROCEDURE sp_GetAvailableTailors;
GO

CREATE PROCEDURE sp_GetAvailableTailors
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        e.EmployeeID,
        CONCAT(e.FirstName, ' ', e.LastName) AS TailorName,
        e.Phone,
        e.Email,
        d.DepartmentName,
        r.RoleName,
        (SELECT COUNT(*) FROM TailorAssignment WHERE TailorID = e.EmployeeID AND Status IN ('Assigned', 'In Progress')) AS ActiveAssignments
    FROM Employee e
    LEFT JOIN Department d ON e.DepartmentID = d.DepartmentID
    LEFT JOIN EmployeeRole r ON e.RoleID = r.RoleID
    WHERE e.IsActive = 1
        AND r.RoleName = 'Tailor'
    ORDER BY e.FirstName, e.LastName;
END
GO

PRINT '  sp_GetAvailableTailors updated successfully.';
PRINT '';

-- ============================================================================
-- STEP 3: Update sp_GetTailorsForAssignment
-- ============================================================================
PRINT '-- STEP 3: Updating sp_GetTailorsForAssignment...';

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'sp_GetTailorsForAssignment')
    DROP PROCEDURE sp_GetTailorsForAssignment;
GO

CREATE PROCEDURE sp_GetTailorsForAssignment
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        e.EmployeeID,
        CONCAT(e.FirstName, ' ', e.LastName) AS FullName,
        e.Phone,
        e.Email,
        d.DepartmentName,
        r.RoleName
    FROM Employee e
    LEFT JOIN Department d ON e.DepartmentID = d.DepartmentID
    LEFT JOIN EmployeeRole r ON e.RoleID = r.RoleID
    WHERE e.IsActive = 1
        AND r.RoleName = 'Tailor'
    ORDER BY e.FirstName, e.LastName;
END
GO

PRINT '  sp_GetTailorsForAssignment updated successfully.';
PRINT '';

-- ============================================================================
-- STEP 4: Update sp_GetAllProductionOrders
-- ============================================================================
PRINT '-- STEP 4: Updating sp_GetAllProductionOrders...';

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'sp_GetAllProductionOrders')
    DROP PROCEDURE sp_GetAllProductionOrders;
GO

CREATE PROCEDURE sp_GetAllProductionOrders
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        po.ProductionOrderID,
        po.ProductID,
        po.QuantityOrdered,
        po.QuantityCompleted,
        po.StartDate,
        po.ExpectedEndDate,
        po.ActualEndDate,
        po.Status,
        po.Priority,
        po.Notes,
        po.CreatedByEmployeeID,
        po.CreatedDate,
        po.UpdatedDate,
        -- Product Information
        p.ProductName,
        p.Category,
        p.SKU,
        p.SalePrice,
        -- Employee Information (Created By)
        CONCAT(e.FirstName, ' ', e.LastName) AS CreatedByName,
        r.RoleName AS EmployeeRole,
        -- Calculated Fields
        (po.QuantityOrdered - po.QuantityCompleted) AS RemainingQuantity,
        CASE
            WHEN po.QuantityOrdered > 0 THEN
                (CAST(po.QuantityCompleted AS FLOAT) / po.QuantityOrdered * 100)
            ELSE 0
        END AS CompletionPercentage
    FROM ProductionOrder po
    INNER JOIN Product p ON po.ProductID = p.ProductID
    LEFT JOIN Employee e ON po.CreatedByEmployeeID = e.EmployeeID
    LEFT JOIN EmployeeRole r ON e.RoleID = r.RoleID
    ORDER BY po.CreatedDate DESC;
END
GO

PRINT '  sp_GetAllProductionOrders updated successfully.';
PRINT '';

-- ============================================================================
-- STEP 5: Update sp_GetProductionOrderById
-- ============================================================================
PRINT '-- STEP 5: Updating sp_GetProductionOrderById...';

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'sp_GetProductionOrderById')
    DROP PROCEDURE sp_GetProductionOrderById;
GO

CREATE PROCEDURE sp_GetProductionOrderById
    @ProductionOrderID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        po.ProductionOrderID,
        po.ProductID,
        po.QuantityOrdered,
        po.QuantityCompleted,
        po.StartDate,
        po.ExpectedEndDate,
        po.ActualEndDate,
        po.Status,
        po.Priority,
        po.Notes,
        po.CreatedByEmployeeID,
        po.CreatedDate,
        po.UpdatedDate,
        -- Product Information
        p.ProductName,
        p.Category,
        p.Brand,
        p.SKU,
        p.SalePrice,
        p.Material,
        -- Employee Information
        CONCAT(e.FirstName, ' ', e.LastName) AS CreatedByName,
        e.Phone AS CreatedByPhone,
        e.Email AS CreatedByEmail,
        r.RoleName AS EmployeeRole,
        d.DepartmentName,
        -- Calculated Fields
        (po.QuantityOrdered - po.QuantityCompleted) AS RemainingQuantity,
        CASE
            WHEN po.QuantityOrdered > 0 THEN
                (CAST(po.QuantityCompleted AS FLOAT) / po.QuantityOrdered * 100)
            ELSE 0
        END AS CompletionPercentage
    FROM ProductionOrder po
    INNER JOIN Product p ON po.ProductID = p.ProductID
    LEFT JOIN Employee e ON po.CreatedByEmployeeID = e.EmployeeID
    LEFT JOIN EmployeeRole r ON e.RoleID = r.RoleID
    LEFT JOIN Department d ON e.DepartmentID = d.DepartmentID
    WHERE po.ProductionOrderID = @ProductionOrderID;
END
GO

PRINT '  sp_GetProductionOrderById updated successfully.';
PRINT '';

-- ============================================================================
-- VERIFICATION: Check Employee table structure
-- ============================================================================
PRINT '============================================================================';
PRINT 'VERIFICATION - Updated Employee Table Structure';
PRINT '============================================================================';

SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE,
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'Employee'
ORDER BY ORDINAL_POSITION;

PRINT '';
PRINT '============================================================================';
PRINT 'UPDATE COMPLETED SUCCESSFULLY';
PRINT 'Timestamp: ' + CONVERT(VARCHAR, GETDATE(), 120);
PRINT '============================================================================';
PRINT '';
PRINT 'Changes Made:';
PRINT '  ✓ Removed Specialization column from Employee table';
PRINT '  ✓ Removed PieceRate column from Employee table';
PRINT '  ✓ Removed TotalPiecesCompleted column from Employee table';
PRINT '  ✓ Removed ShiftType column from Employee table';
PRINT '  ✓ Updated sp_GetAvailableTailors procedure';
PRINT '  ✓ Updated sp_GetTailorsForAssignment procedure';
PRINT '  ✓ Updated sp_GetAllProductionOrders procedure';
PRINT '  ✓ Updated sp_GetProductionOrderById procedure';
PRINT '';
PRINT 'Your system is now updated and ready to use!';

GO

/*******************************************************************************
 * END OF UPDATE SCRIPT
 ******************************************************************************/
