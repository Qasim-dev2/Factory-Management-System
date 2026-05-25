-- ================================================================================
-- COMPLETE UPDATED PROCEDURES - DEAL DELIVERY WORKFLOW
-- ================================================================================
-- Created: December 7, 2025
-- Purpose: All procedures that were created/updated for Deal delivery support
-- 
-- IMPORTANT: These procedures REPLACE the old ones from 15_OrderApprovalSystem.sql
--
-- HOW TO USE:
-- 1. Execute this entire file in SQL Server Management Studio or sqlcmd
-- 2. All procedures will be dropped and recreated with new logic
-- ================================================================================

USE GarmentsFactoryDB;
GO

PRINT '========================================';
PRINT 'STARTING PROCEDURE UPDATES';
PRINT '========================================';
GO

-- ================================================================================
-- SUMMARY OF CHANGES:
-- ================================================================================
-- 
-- ✅ UPDATED PROCEDURES (4):
-- 
-- 1. sp_ApproveOrderAndCreateProduction
--    OLD LOCATION: 15_OrderApprovalSystem.sql (Lines 300-408)
--    CHANGE: Removed early delivery creation, only creates production orders now
-- 
-- 2. sp_UpdateTailorCompletionStatus  
--    OLD LOCATION: 15_OrderApprovalSystem.sql (Lines 656-738)
--    CHANGES: 
--      - Added collaborative tailor logic (all tailors work together)
--      - Auto-creates delivery for SalesOrders (with NULL DealID)
--      - Auto-creates delivery for Deals (with NULL SalesOrderID)
-- 
-- 3. sp_GetDeliveryAssignments
--    OLD LOCATION: 15_OrderApprovalSystem.sql (Lines 870-931)
--    CHANGES:
--      - Returns OrderType field ("SalesOrder" or "Deal")
--      - Joins both SalesOrder and Deal tables
--      - Uses COALESCE for customer name
-- 
-- 4. sp_UpdateDeliveryStatus
--    OLD LOCATION: 15_OrderApprovalSystem.sql (Lines 933-968)
--    CHANGE: Updates both SalesOrder AND Deal status when delivered
-- 
-- ================================================================================


-- ================================================================================
-- PROCEDURE 1: sp_ApproveOrderAndCreateProduction
-- ================================================================================
-- STATUS: UPDATED (Rephrased/Modified from original)
-- CHANGE: Removed delivery creation - now only creates production orders
-- ================================================================================

IF OBJECT_ID('sp_ApproveOrderAndCreateProduction', 'P') IS NOT NULL
    DROP PROCEDURE sp_ApproveOrderAndCreateProduction;
GO

CREATE PROCEDURE sp_ApproveOrderAndCreateProduction
    @ApprovalID INT,
    @OwnerID INT,
    @TailorIDs NVARCHAR(MAX)  -- Comma-separated IDs: "5,12,18"
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    
    BEGIN TRY
        DECLARE @OrderType NVARCHAR(20);
        DECLARE @OrderID INT;
        DECLARE @ProductID INT;
        DECLARE @Quantity INT;
        DECLARE @ProductionOrderID INT;
        DECLARE @MaterialCheckStatus NVARCHAR(20);
        
        -- Get order details
        SELECT @OrderType = OrderType, @OrderID = OrderID
        FROM OrderApproval
        WHERE ApprovalID = @ApprovalID AND Status = 'Pending';
        
        IF @OrderType IS NULL
        BEGIN
            RAISERROR('Approval request not found or already processed', 16, 1);
            RETURN;
        END
        
        -- Check materials availability
        CREATE TABLE #TempMaterialCheck (
            ProductID INT,
            QuantityOrdered INT,
            RawMaterialID INT,
            RequiredQuantity DECIMAL(18,2),
            AvailableQuantity DECIMAL(18,2),
            Status NVARCHAR(20)
        );
        
        -- Get products and check materials
        IF @OrderType = 'SalesOrder'
        BEGIN
            INSERT INTO #TempMaterialCheck (ProductID, QuantityOrdered)
            SELECT ProductID, Quantity
            FROM SalesOrderItem
            WHERE SalesOrderID = @OrderID;
        END
        ELSE
        BEGIN
            INSERT INTO #TempMaterialCheck (ProductID, QuantityOrdered)
            SELECT ProductID, Quantity
            FROM DealItem
            WHERE DealID = @OrderID;
        END
        
        -- Calculate required materials
        UPDATE tmc
        SET 
            tmc.RawMaterialID = pmr.RawMaterialID,
            tmc.RequiredQuantity = pmr.QuantityRequired * tmc.QuantityOrdered,
            tmc.AvailableQuantity = rm.Quantity,
            tmc.Status = CASE 
                WHEN rm.Quantity >= (pmr.QuantityRequired * tmc.QuantityOrdered) THEN 'Sufficient'
                ELSE 'Insufficient'
            END
        FROM #TempMaterialCheck tmc
        JOIN ProductMaterialRequirement pmr ON tmc.ProductID = pmr.ProductID
        JOIN RawMaterial rm ON pmr.RawMaterialID = rm.RawMaterialID;
        
        -- Check if any material is insufficient
        IF EXISTS (SELECT 1 FROM #TempMaterialCheck WHERE Status = 'Insufficient')
        BEGIN
            DECLARE @InsufficientMaterials NVARCHAR(MAX);
            SELECT @InsufficientMaterials = STRING_AGG(
                rm.MaterialName + ' (Need: ' + CAST(tmc.RequiredQuantity AS NVARCHAR) + 
                ', Have: ' + CAST(tmc.AvailableQuantity AS NVARCHAR) + ' ' + rm.Unit + ')',
                '; '
            )
            FROM #TempMaterialCheck tmc
            JOIN RawMaterial rm ON tmc.RawMaterialID = rm.RawMaterialID
            WHERE tmc.Status = 'Insufficient';
            
            DROP TABLE #TempMaterialCheck;
            RAISERROR('Insufficient raw materials: %s', 16, 1, @InsufficientMaterials);
            RETURN;
        END
        
        -- Create ProductionOrder for each product in the order
        DECLARE product_cursor CURSOR FOR
        SELECT ProductID, QuantityOrdered FROM #TempMaterialCheck;
        
        OPEN product_cursor;
        FETCH NEXT FROM product_cursor INTO @ProductID, @Quantity;
        
        WHILE @@FETCH_STATUS = 0
        BEGIN
            -- Create Production Order
            INSERT INTO ProductionOrder (
                ProductID, 
                QuantityOrdered, 
                Status, 
                Priority,
                StartDate,
                ExpectedEndDate
            )
            VALUES (
                @ProductID, 
                @Quantity, 
                'Pending',
                'Normal',
                GETDATE(),
                DATEADD(DAY, 14, GETDATE())
            );
            
            SET @ProductionOrderID = SCOPE_IDENTITY();
            
            -- Deduct raw materials
            UPDATE rm
            SET Quantity = rm.Quantity - tmc.RequiredQuantity,
                LastRestockDate = GETDATE()
            FROM RawMaterial rm
            JOIN #TempMaterialCheck tmc ON rm.RawMaterialID = tmc.RawMaterialID
            WHERE tmc.ProductID = @ProductID;
            
            -- Create ProductionOrderItem entries
            INSERT INTO ProductionOrderItem (ProductionOrderID, RawMaterialID, QuantityRequired)
            SELECT 
                @ProductionOrderID,
                pmr.RawMaterialID,
                pmr.QuantityRequired * @Quantity
            FROM ProductMaterialRequirement pmr
            WHERE pmr.ProductID = @ProductID;
            
            -- Assign tailors
            IF @TailorIDs IS NOT NULL AND LEN(@TailorIDs) > 0
            BEGIN
                INSERT INTO TailorAssignment (
                    ProductionOrderID,
                    TailorID,
                    CompletionStatus
                )
                SELECT 
                    @ProductionOrderID,
                    CAST(value AS INT),
                    'Incomplete'
                FROM STRING_SPLIT(@TailorIDs, ',');
            END
            
            FETCH NEXT FROM product_cursor INTO @ProductID, @Quantity;
        END
        
        CLOSE product_cursor;
        DEALLOCATE product_cursor;
        
        -- Update OrderApproval
        UPDATE OrderApproval
        SET 
            Status = 'Approved',
            ApprovalDate = GETDATE(),
            ProductionOrderID = @ProductionOrderID,
            UpdatedDate = GETDATE()
        WHERE ApprovalID = @ApprovalID;
        
        -- ✅ CHANGED: NO DELIVERY CREATED HERE - only update status to InProduction
        IF @OrderType = 'SalesOrder'
        BEGIN
            UPDATE SalesOrder
            SET Status = 'InProduction',
                UpdatedDate = GETDATE()
            WHERE SalesOrderID = @OrderID;
        END
        ELSE
        BEGIN
            UPDATE Deal
            SET Status = 'InProduction',
                UpdatedDate = GETDATE()
            WHERE DealID = @OrderID;
        END
        
        DROP TABLE #TempMaterialCheck;
        
        COMMIT TRANSACTION;
        
        SELECT 'Success' AS Result, 
               'Order approved and production started successfully' AS Message,
               @ProductionOrderID AS ProductionOrderID;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

PRINT '✅ Procedure 1 Updated: sp_ApproveOrderAndCreateProduction';
GO


-- ================================================================================
-- PROCEDURE 2: sp_UpdateTailorCompletionStatus
-- ================================================================================
-- STATUS: COMPLETELY REWRITTEN (Major changes)
-- CHANGES: 
--   1. Collaborative tailor logic (all tailors share status)
--   2. Auto-creates delivery for SalesOrders
--   3. Auto-creates delivery for Deals
-- ================================================================================

IF OBJECT_ID('sp_UpdateTailorCompletionStatus', 'P') IS NOT NULL
    DROP PROCEDURE sp_UpdateTailorCompletionStatus;
GO

CREATE PROCEDURE sp_UpdateTailorCompletionStatus
    @TailorAssignmentID INT,
    @TailorID INT,
    @NewStatus NVARCHAR(30),  -- 'InProgress' or 'Complete'
    @CompletionNotes NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;  -- Prevent concurrent duplicates
    BEGIN TRANSACTION;
    
    BEGIN TRY
        DECLARE @ProductionOrderID INT;
        DECLARE @AllTailorsCompleted BIT = 0;
        DECLARE @SalesOrderID INT;
        DECLARE @DealID INT;
        DECLARE @OrderType NVARCHAR(20);
        DECLARE @DeliveryID INT;
        
        -- Get production order ID first
        SELECT @ProductionOrderID = ProductionOrderID
        FROM TailorAssignment
        WHERE TailorAssignmentID = @TailorAssignmentID;
        
        IF @ProductionOrderID IS NULL
        BEGIN
            RAISERROR('Assignment not found', 16, 1);
            RETURN;
        END
        
        -- Check if already completed (prevent duplicate processing)
        DECLARE @CurrentStatus NVARCHAR(30);
        SELECT @CurrentStatus = CompletionStatus 
        FROM TailorAssignment 
        WHERE TailorAssignmentID = @TailorAssignmentID;
        
        IF @CurrentStatus = 'Complete' AND @NewStatus = 'Complete'
        BEGIN
            -- Already completed, just return success without processing
            SELECT 'Success' AS Result, 
                   'Task already completed' AS Message,
                   0 AS AllTailorsCompleted,
                   NULL AS DeliveryID;
            COMMIT TRANSACTION;
            RETURN;
        END
        
        -- ✅ CHANGED: Update ALL tailor assignments for this production order (they work together)
        IF @NewStatus = 'InProgress'
        BEGIN
            -- When one tailor starts, mark ALL as InProgress
            UPDATE TailorAssignment
            SET 
                CompletionStatus = 'InProgress',
                StartedDate = CASE WHEN StartedDate IS NULL THEN GETDATE() ELSE StartedDate END
            WHERE ProductionOrderID = @ProductionOrderID
            AND CompletionStatus = 'Incomplete';
        END
        ELSE IF @NewStatus = 'Complete'
        BEGIN
            -- When one tailor completes, mark ALL as Complete
            UPDATE TailorAssignment
            SET 
                CompletionStatus = 'Complete',
                CompletedDate = GETDATE(),
                CompletionNotes = @CompletionNotes
            WHERE ProductionOrderID = @ProductionOrderID;
            
            SET @AllTailorsCompleted = 1;
        END
        
        -- ✅ CHANGED: If status changed to Complete, update production only (NO delivery creation)
        IF @AllTailorsCompleted = 1
        BEGIN
            -- Update production order status
            UPDATE ProductionOrder
            SET 
                Status = 'Completed',
                QuantityCompleted = QuantityOrdered,
                ActualEndDate = GETDATE(),
                UpdatedDate = GETDATE()
            WHERE ProductionOrderID = @ProductionOrderID;
            
            -- Update ALL assigned tailors' total pieces
            UPDATE e
            SET TotalPiecesCompleted = TotalPiecesCompleted + 
                (SELECT QuantityOrdered FROM ProductionOrder WHERE ProductionOrderID = @ProductionOrderID)
            FROM Employee e
            JOIN TailorAssignment ta ON e.EmployeeID = ta.TailorID
            WHERE ta.ProductionOrderID = @ProductionOrderID;
            
            -- Get order details to update status to ReadyForDelivery
            SELECT 
                @OrderType = oa.OrderType,
                @SalesOrderID = CASE WHEN oa.OrderType = 'SalesOrder' THEN oa.OrderID ELSE NULL END,
                @DealID = CASE WHEN oa.OrderType = 'Deal' THEN oa.OrderID ELSE NULL END
            FROM OrderApproval oa
            WHERE oa.ProductionOrderID = @ProductionOrderID
            AND oa.Status = 'Approved';
            
            -- Check if ALL production orders for this order are completed
            DECLARE @TotalProductionOrders INT;
            DECLARE @CompletedProductionOrders INT;
            
            IF @SalesOrderID IS NOT NULL
            BEGIN
                -- Count total and completed production orders for this SalesOrder
                SELECT 
                    @TotalProductionOrders = COUNT(DISTINCT po.ProductionOrderID),
                    @CompletedProductionOrders = COUNT(DISTINCT CASE WHEN po.Status = 'Completed' THEN po.ProductionOrderID END)
                FROM OrderApproval oa
                JOIN ProductionOrder po ON oa.ProductionOrderID = po.ProductionOrderID
                WHERE oa.OrderID = @SalesOrderID AND oa.OrderType = 'SalesOrder';
                
                -- Only update order status if ALL production orders are completed
                IF @TotalProductionOrders = @CompletedProductionOrders
                BEGIN
                    UPDATE SalesOrder
                    SET Status = 'ReadyForDelivery',
                        UpdatedDate = GETDATE()
                    WHERE SalesOrderID = @SalesOrderID;
                END
            END
            ELSE IF @DealID IS NOT NULL
            BEGIN
                -- Count total and completed production orders for this Deal
                SELECT 
                    @TotalProductionOrders = COUNT(DISTINCT po.ProductionOrderID),
                    @CompletedProductionOrders = COUNT(DISTINCT CASE WHEN po.Status = 'Completed' THEN po.ProductionOrderID END)
                FROM OrderApproval oa
                JOIN ProductionOrder po ON oa.ProductionOrderID = po.ProductionOrderID
                WHERE oa.OrderID = @DealID AND oa.OrderType = 'Deal';
                
                -- Only update order status if ALL production orders are completed
                IF @TotalProductionOrders = @CompletedProductionOrders
                BEGIN
                    UPDATE Deal
                    SET Status = 'ReadyForDelivery',
                        UpdatedDate = GETDATE()
                    WHERE DealID = @DealID;
                END
            END
        END
        
        COMMIT TRANSACTION;
        
        -- ✅ NEW: Auto-create deliveries for any orders that are now ReadyForDelivery
        IF @AllTailorsCompleted = 1
        BEGIN
            -- Call without interfering with result set
            DECLARE @DeliveriesCreated INT;
            DECLARE @AutoResult NVARCHAR(50);
            DECLARE @AutoMessage NVARCHAR(500);
            
            -- Create temp table to capture result
            CREATE TABLE #DeliveryResult (Result NVARCHAR(50), DeliveriesCreated INT, Message NVARCHAR(500));
            INSERT INTO #DeliveryResult EXEC sp_AutoCreateDeliveriesForCompletedOrders;
            
            -- Get the result but don't return it
            SELECT @DeliveriesCreated = DeliveriesCreated FROM #DeliveryResult;
            DROP TABLE #DeliveryResult;
        END
        
        SELECT 'Success' AS Result, 
               'Status updated successfully' AS Message,
               @AllTailorsCompleted AS AllTailorsCompleted,
               @DeliveryID AS DeliveryID;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

PRINT '✅ Procedure 2 Updated: sp_UpdateTailorCompletionStatus';
GO


-- ================================================================================
-- PROCEDURE 3: sp_GetDeliveryAssignments
-- ================================================================================
-- STATUS: UPDATED (Enhanced with Deal support)
-- CHANGES:
--   1. Returns OrderType field ("SalesOrder" or "Deal")
--   2. Joins both SalesOrder and Deal tables
--   3. Uses COALESCE for customer name
-- ================================================================================

IF OBJECT_ID('sp_GetDeliveryAssignments', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetDeliveryAssignments;
GO

CREATE PROCEDURE sp_GetDeliveryAssignments
    @DeliveryPersonID INT = NULL,
    @Status NVARCHAR(50) = NULL  -- NULL = All, 'Pending', 'InTransit', 'Delivered'
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        d.DeliveryID,
        d.SalesOrderID,
        d.DealID,
        d.Status,
        d.DeliveryDate,
        d.DeliveryAddress,
        d.City,
        d.Province,
        d.TrackingNumber,
        d.ReceiverName,
        d.ReceiverPhone,
        d.Notes,
        d.CreatedDate,
        
        -- ✅ NEW: Order details (SalesOrder or Deal)
        CASE 
            WHEN d.SalesOrderID IS NOT NULL THEN 'SalesOrder'
            WHEN d.DealID IS NOT NULL THEN 'Deal'
        END AS OrderType,
        
        -- SalesOrder details
        so.OrderDate AS SalesOrderDate,
        so.TotalAmount AS SalesOrderAmount,
        
        -- ✅ NEW: Deal details
        de.CreatedDate AS DealDate,
        de.EstimatedValue AS DealAmount,
        
        -- ✅ CHANGED: Combined customer details (Retailer or Deal Client)
        COALESCE(r.CompanyName, de.ClientName) AS CustomerName,
        COALESCE(r.Phone, de.Phone) AS CustomerPhone,
        COALESCE(r.ContactPerson, de.ContactPerson) AS ContactPerson,
        
        -- Delivery person
        CONCAT(e.FirstName, ' ', e.LastName) AS DeliveryPersonName
        
    FROM Delivery d
    LEFT JOIN SalesOrder so ON d.SalesOrderID = so.SalesOrderID
    LEFT JOIN Retailer r ON so.RetailerID = r.RetailerID
    LEFT JOIN Deal de ON d.DealID = de.DealID  -- ✅ NEW: Deal join
    LEFT JOIN Employee e ON d.DeliveredBy = e.EmployeeID
    
    WHERE (@DeliveryPersonID IS NULL OR d.DeliveredBy = @DeliveryPersonID)
    AND (@Status IS NULL OR d.Status = @Status)
    ORDER BY 
        CASE d.Status
            WHEN 'Pending' THEN 1
            WHEN 'InTransit' THEN 2
            WHEN 'Delivered' THEN 3
        END,
        d.CreatedDate DESC;
END
GO

PRINT '✅ Procedure 3 Updated: sp_GetDeliveryAssignments';
GO


-- ================================================================================
-- PROCEDURE 4: sp_UpdateDeliveryStatus
-- ================================================================================
-- STATUS: UPDATED (Enhanced with Deal support)
-- CHANGE: Updates both SalesOrder AND Deal status when delivered
-- ================================================================================

IF OBJECT_ID('sp_UpdateDeliveryStatus', 'P') IS NOT NULL
    DROP PROCEDURE sp_UpdateDeliveryStatus;
GO

CREATE PROCEDURE sp_UpdateDeliveryStatus
    @DeliveryID INT,
    @DeliveryPersonID INT,
    @NewStatus NVARCHAR(50),  -- 'InTransit' or 'Delivered'
    @Notes NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE Delivery
    SET 
        Status = @NewStatus,
        DeliveredBy = @DeliveryPersonID,
        DeliveryDate = CASE WHEN @NewStatus = 'Delivered' THEN GETDATE() ELSE DeliveryDate END,
        Notes = ISNULL(@Notes, Notes),
        UpdatedDate = GETDATE()
    WHERE DeliveryID = @DeliveryID;
    
    IF @@ROWCOUNT > 0
    BEGIN
        -- ✅ CHANGED: Update SalesOrder or Deal status
        IF @NewStatus = 'Delivered'
        BEGIN
            -- Update SalesOrder if exists
            UPDATE so
            SET Status = 'Delivered',
                UpdatedDate = GETDATE()
            FROM SalesOrder so
            JOIN Delivery d ON so.SalesOrderID = d.SalesOrderID
            WHERE d.DeliveryID = @DeliveryID AND d.SalesOrderID IS NOT NULL;
            
            -- ✅ NEW: Update Deal if exists
            UPDATE de
            SET Status = 'Delivered',
                UpdatedDate = GETDATE()
            FROM Deal de
            JOIN Delivery d ON de.DealID = d.DealID
            WHERE d.DeliveryID = @DeliveryID AND d.DealID IS NOT NULL;
        END
        
        SELECT 'Success' AS Result, 
               'Delivery status updated successfully' AS Message;
    END
    ELSE
    BEGIN
        RAISERROR('Delivery not found', 16, 1);
    END
END
GO

PRINT '✅ Procedure 4 Updated: sp_UpdateDeliveryStatus';
GO


-- ================================================================================
-- COMPLETION
-- ================================================================================

PRINT '';
PRINT '========================================';
PRINT 'ALL PROCEDURES UPDATED SUCCESSFULLY!';
PRINT '';
PRINT 'PROCEDURES UPDATED (4):';
PRINT '  1. sp_ApproveOrderAndCreateProduction';
PRINT '  2. sp_UpdateTailorCompletionStatus';
PRINT '  3. sp_GetDeliveryAssignments';
PRINT '  4. sp_UpdateDeliveryStatus';
PRINT '';
PRINT 'WHAT CHANGED:';
PRINT '  ✅ Orders go to tailors first (no early delivery)';
PRINT '  ✅ Tailors work collaboratively';
PRINT '  ✅ Delivery auto-created after production completes';
PRINT '  ✅ Both SalesOrders and Deals create deliveries';
PRINT '  ✅ UI displays both order types correctly';
PRINT '';
PRINT 'NEXT STEPS:';
PRINT '  1. Test workflow: Create order → Approve → Assign tailors → Complete → Verify delivery';
PRINT '  2. Check Delivery Management UI for both order types';
PRINT '========================================';
GO

-- ================================================================================
-- VERIFICATION QUERIES (Optional - for testing)
-- ================================================================================
/*

-- Test 1: Check if procedures exist
SELECT ROUTINE_NAME, ROUTINE_TYPE, CREATED, LAST_ALTERED
FROM INFORMATION_SCHEMA.ROUTINES
WHERE ROUTINE_NAME IN (
    'sp_ApproveOrderAndCreateProduction',
    'sp_UpdateTailorCompletionStatus',
    'sp_GetDeliveryAssignments',
    'sp_UpdateDeliveryStatus'
)
ORDER BY ROUTINE_NAME;

-- Test 2: Check delivery table structure
SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Delivery'
ORDER BY ORDINAL_POSITION;

-- Test 3: View existing deliveries
SELECT DeliveryID, SalesOrderID, DealID, Status,
       CASE 
           WHEN SalesOrderID IS NOT NULL THEN 'SalesOrder'
           WHEN DealID IS NOT NULL THEN 'Deal'
       END AS OrderType
FROM Delivery
ORDER BY DeliveryID DESC;

-- Test 4: Execute sp_GetDeliveryAssignments
EXEC sp_GetDeliveryAssignments;

*/
