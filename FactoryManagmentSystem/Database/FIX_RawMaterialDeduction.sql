-- =============================================
-- FIX: Raw Material Deduction on Order Approval
-- =============================================
-- This script updates sp_ApproveOrderAndCreateProduction to automatically
-- deduct raw materials from stock when orders are approved
-- 
-- ISSUE: Raw materials were not being deducted when orders were approved
-- FIX: Added material deduction logic using the MaterialCheck temp table
-- 
-- Execute this script in SQL Server Management Studio (SSMS)
-- Make sure you're connected to GarmentsFactoryDB database
-- =============================================

USE GarmentsFactoryDB;
GO

PRINT '========================================';
PRINT 'FIXING RAW MATERIAL DEDUCTION ON ORDER APPROVAL';
PRINT '========================================';
PRINT '';

-- Drop existing procedure
IF OBJECT_ID('sp_ApproveOrderAndCreateProduction', 'P') IS NOT NULL
BEGIN
    DROP PROCEDURE sp_ApproveOrderAndCreateProduction;
    PRINT '✓ Dropped old sp_ApproveOrderAndCreateProduction';
END
GO

-- Recreate procedure with material deduction logic
CREATE PROCEDURE sp_ApproveOrderAndCreateProduction
    @ApprovalID INT,
    @OwnerID INT,
    @TailorIDs NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @OrderType NVARCHAR(50), @OrderID INT, @ProductionOrderID INT = NULL;
        DECLARE @InsufficientCount INT = 0;
        DECLARE @ProductID INT, @QuantityOrdered INT;

        -- Get order details
        SELECT @OrderType = OrderType, @OrderID = OrderID
        FROM OrderApproval WHERE ApprovalID = @ApprovalID;

        IF @OrderType IS NULL
        BEGIN
            SELECT 'Error' AS Result, 'Approval request not found.' AS Message, NULL AS ProductionOrderID;
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Check materials availability
        CREATE TABLE #MaterialCheck (
            ProductID INT,
            ProductName NVARCHAR(100),
            QuantityOrdered INT,
            RawMaterialID INT,
            MaterialName NVARCHAR(100),
            RequiredQuantity DECIMAL(18,2),
            AvailableQuantity DECIMAL(18,2),
            Unit NVARCHAR(20),
            Status NVARCHAR(20)
        );

        -- Get products based on order type
        IF @OrderType = 'SalesOrder'
        BEGIN
            INSERT INTO #MaterialCheck (ProductID, ProductName, QuantityOrdered)
            SELECT soi.ProductID, p.ProductName, soi.Quantity
            FROM SalesOrderItem soi
            JOIN Product p ON soi.ProductID = p.ProductID
            WHERE soi.SalesOrderID = @OrderID;
        END
        ELSE IF @OrderType = 'Deal'
        BEGIN
            INSERT INTO #MaterialCheck (ProductID, ProductName, QuantityOrdered)
            SELECT di.ProductID, p.ProductName, di.Quantity
            FROM DealItem di
            JOIN Product p ON di.ProductID = p.ProductID
            WHERE di.DealID = @OrderID;
        END

        -- Check material requirements
        UPDATE mc
        SET
            mc.RawMaterialID = pmr.RawMaterialID,
            mc.MaterialName = rm.MaterialName,
            mc.RequiredQuantity = pmr.QuantityRequired * mc.QuantityOrdered,
            mc.AvailableQuantity = rm.Quantity,
            mc.Unit = rm.Unit,
            mc.Status = CASE
                WHEN rm.Quantity >= (pmr.QuantityRequired * mc.QuantityOrdered) THEN 'Available'
                ELSE 'Insufficient'
            END
        FROM #MaterialCheck mc
        LEFT JOIN ProductMaterialRequirement pmr ON mc.ProductID = pmr.ProductID
        LEFT JOIN RawMaterial rm ON pmr.RawMaterialID = rm.RawMaterialID;

        -- Count insufficient materials
        SELECT @InsufficientCount = COUNT(*) FROM #MaterialCheck WHERE Status = 'Insufficient';

        -- If materials are insufficient, return error
        IF @InsufficientCount > 0
        BEGIN
            SELECT 'Error' AS Result,
                   'Cannot approve order. ' + CAST(@InsufficientCount AS NVARCHAR) + ' material(s) insufficient.' AS Message,
                   NULL AS ProductionOrderID;
            DROP TABLE #MaterialCheck;
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Get first product and quantity for production order
        SELECT TOP 1 @ProductID = ProductID, @QuantityOrdered = QuantityOrdered
        FROM #MaterialCheck;

        -- Check if ProductID was found
        IF @ProductID IS NULL
        BEGIN
            SELECT 'Error' AS Result,
                   'Cannot create production order. No products found in the order.' AS Message,
                   NULL AS ProductionOrderID;
            DROP TABLE #MaterialCheck;
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- **CRITICAL FIX: Deduct raw materials from stock BEFORE dropping the MaterialCheck table**
        -- Deduct materials based on BOM (Bill of Materials)
        DECLARE @RawMaterialID INT, @RequiredQty DECIMAL(18,2);
        DECLARE material_cursor CURSOR FOR
        SELECT DISTINCT mc.RawMaterialID, mc.RequiredQuantity
        FROM #MaterialCheck mc
        WHERE mc.RawMaterialID IS NOT NULL;

        OPEN material_cursor;
        FETCH NEXT FROM material_cursor INTO @RawMaterialID, @RequiredQty;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            -- Deduct the required quantity from raw material stock
            UPDATE RawMaterial
            SET Quantity = Quantity - @RequiredQty,
                UpdatedDate = GETDATE()
            WHERE RawMaterialID = @RawMaterialID;

            FETCH NEXT FROM material_cursor INTO @RawMaterialID, @RequiredQty;
        END

        CLOSE material_cursor;
        DEALLOCATE material_cursor;

        DROP TABLE #MaterialCheck;

        -- Update approval record
        UPDATE OrderApproval
        SET Status = 'Approved',
            ApprovedBy = @OwnerID,
            ApprovalDate = GETDATE(),
            ApprovalStatus = 'Approved'
        WHERE ApprovalID = @ApprovalID;

        -- Update order status
        IF @OrderType = 'SalesOrder'
        BEGIN
            UPDATE SalesOrder SET Status = 'Approved', UpdatedDate = GETDATE() WHERE SalesOrderID = @OrderID;
        END
        ELSE IF @OrderType = 'Deal'
        BEGIN
            UPDATE Deal SET Status = 'Approved', UpdatedDate = GETDATE() WHERE DealID = @OrderID;
        END

        -- Create ProductionOrder (handle ownerID = 0 by setting it to NULL)
        DECLARE @CreatedBy INT = CASE WHEN @OwnerID = 0 THEN NULL ELSE @OwnerID END;
        
        INSERT INTO ProductionOrder (ProductID, QuantityOrdered, Status, Priority, CreatedByEmployeeID, CreatedDate, StartDate)
        VALUES (@ProductID, @QuantityOrdered, 'Pending', 'Normal', @CreatedBy, GETDATE(), GETDATE());

        SET @ProductionOrderID = SCOPE_IDENTITY();

        -- Assign tailors if provided
        IF @TailorIDs IS NOT NULL AND @TailorIDs != ''
        BEGIN
            DECLARE @TailorID INT;
            DECLARE @Pos INT;
            DECLARE @TailorList NVARCHAR(500) = @TailorIDs;

            WHILE LEN(@TailorList) > 0
            BEGIN
                SET @Pos = CHARINDEX(',', @TailorList);
                IF @Pos = 0
                BEGIN
                    SET @TailorID = CAST(@TailorList AS INT);
                    SET @TailorList = '';
                END
                ELSE
                BEGIN
                    SET @TailorID = CAST(LEFT(@TailorList, @Pos - 1) AS INT);
                    SET @TailorList = SUBSTRING(@TailorList, @Pos + 1, LEN(@TailorList));
                END

                -- Create assignment with ProductionOrderID and ProductID
                IF @OrderType = 'SalesOrder'
                BEGIN
                    INSERT INTO TailorAssignment (TailorID, ProductionOrderID, SalesOrderID, ProductID, QuantityAssigned, AssignedDate, Status)
                    VALUES (@TailorID, @ProductionOrderID, @OrderID, @ProductID, @QuantityOrdered, GETDATE(), 'Incomplete');
                END
                ELSE IF @OrderType = 'Deal'
                BEGIN
                    INSERT INTO TailorAssignment (TailorID, ProductionOrderID, DealID, ProductID, QuantityAssigned, AssignedDate, Status)
                    VALUES (@TailorID, @ProductionOrderID, @OrderID, @ProductID, @QuantityOrdered, GETDATE(), 'Incomplete');
                END
            END
        END

        COMMIT TRANSACTION;

        SELECT 'Success' AS Result, 'Order approved and production order created successfully. Raw materials deducted from stock.' AS Message, @ProductionOrderID AS ProductionOrderID;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SELECT 'Error' AS Result, ERROR_MESSAGE() AS Message, NULL AS ProductionOrderID;
    END CATCH
END
GO

PRINT '';
PRINT '✓ sp_ApproveOrderAndCreateProduction recreated with material deduction';
PRINT '';
PRINT '========================================';
PRINT 'FIX COMPLETE!';
PRINT '========================================';
PRINT '';
PRINT 'WHAT CHANGED:';
PRINT '1. Added cursor to loop through materials in #MaterialCheck';
PRINT '2. Deducts raw material quantities from RawMaterial table';
PRINT '3. Updates UpdatedDate for affected materials';
PRINT '4. Deduction happens BEFORE creating production order';
PRINT '';
PRINT 'TESTING:';
PRINT '1. Create a sales order or deal';
PRINT '2. Approve it through Owner Dashboard';
PRINT '3. Check RawMaterial table - quantities should be deducted';
PRINT '4. Verify in Raw Material Management view';
PRINT '';
GO
