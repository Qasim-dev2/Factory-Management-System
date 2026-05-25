-- =============================================
-- FIX TAILOR ASSIGNMENT TO INCLUDE PRODUCTID
-- Updates sp_ApproveOrderAndCreateProduction to assign tailors with ProductID
-- Date: December 17, 2025
-- =============================================

USE GarmentsFactoryDB;
GO

PRINT '======================================='
PRINT 'FIXING TAILOR ASSIGNMENT PROCEDURE'
PRINT '======================================='
PRINT ''

-- First, update existing NULL ProductIDs in TailorAssignment
UPDATE ta
SET ta.ProductID = po.ProductID
FROM TailorAssignment ta
INNER JOIN ProductionOrder po ON ta.ProductionOrderID = po.ProductionOrderID
WHERE ta.ProductID IS NULL AND po.ProductID IS NOT NULL;

PRINT '✓ Updated existing TailorAssignment records: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' records'
PRINT ''

-- Now add the tailor assignment logic to the approval procedure
-- This adds a section at the end to process @TailorIDs and create assignments

-- We'll create a helper procedure first
IF OBJECT_ID('sp_AssignTailorsToProductionOrder', 'P') IS NOT NULL
    DROP PROCEDURE sp_AssignTailorsToProductionOrder;
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE sp_AssignTailorsToProductionOrder
    @ProductionOrderID INT,
    @TailorIDs NVARCHAR(500),
    @ProductID INT,
    @QuantityOrdered INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Parse comma-separated tailor IDs and create assignments
    IF @TailorIDs IS NOT NULL AND LEN(@TailorIDs) > 0
    BEGIN
        DECLARE @TailorID INT;
        DECLARE @Pos INT;
        DECLARE @TailorIDString NVARCHAR(10);
        DECLARE @RemainingIDs NVARCHAR(500) = @TailorIDs + ',';
        
        WHILE CHARINDEX(',', @RemainingIDs) > 0
        BEGIN
            SET @Pos = CHARINDEX(',', @RemainingIDs);
            SET @TailorIDString = LEFT(@RemainingIDs, @Pos - 1);
            SET @TailorID = CAST(@TailorIDString AS INT);
            
            -- Insert tailor assignment
            INSERT INTO TailorAssignment (
                TailorID,
                ProductionOrderID,
                ProductID,
                QuantityAssigned,
                AssignedDate,
                Status
            )
            VALUES (
                @TailorID,
                @ProductionOrderID,
                @ProductID,
                @QuantityOrdered,
                GETDATE(),
                'Assigned'
            );
            
            SET @RemainingIDs = STUFF(@RemainingIDs, 1, @Pos, '');
        END
    END
END
GO

PRINT '✓ Created sp_AssignTailorsToProductionOrder helper procedure'
PRINT ''

-- Now update the main approval procedure to call this helper
-- We need to add the call right after ProductionOrder is created

PRINT 'To complete the fix, the sp_ApproveOrderAndCreateProduction procedure'
PRINT 'needs to be updated to call sp_AssignTailorsToProductionOrder.'
PRINT ''
PRINT 'Add this code after "SET @ProductionOrderID = SCOPE_IDENTITY();":'
PRINT ''
PRINT '    -- Assign tailors to production order'
PRINT '    IF @TailorIDs IS NOT NULL AND LEN(@TailorIDs) > 0'
PRINT '    BEGIN'
PRINT '        EXEC sp_AssignTailorsToProductionOrder'
PRINT '            @ProductionOrderID = @ProductionOrderID,'
PRINT '            @TailorIDs = @TailorIDs,'
PRINT '            @ProductID = @ProductID,'
PRINT '            @QuantityOrdered = @QuantityOrdered;'
PRINT '    END'
PRINT ''
PRINT '======================================='
PRINT 'TAILOR ASSIGNMENT FIX READY'
PRINT '======================================='

GO
