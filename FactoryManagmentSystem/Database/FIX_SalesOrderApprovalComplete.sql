-- =============================================
-- COMPREHENSIVE FIX: Sales Order Approval System
-- =============================================
-- This script fixes ALL issues with Sales Order approval and raw material management
--
-- ROOT CAUSE ANALYSIS:
-- 1. sp_UpdateSalesOrder: C# code passes @OrderItemsXML but procedure doesn't accept it
-- 2. sp_CheckMaterialsForOrder: Returns empty data (no material breakdown)
-- 3. sp_ApproveOrderAndCreateProduction: Already fixed to deduct materials
-- 4. Foreign Key Issues: Employee validation missing for soft-deleted employees
-- 5. No transaction safety during approval process
--
-- BUSINESS RULES IMPLEMENTED:
-- ✓ Validate employee exists and IsActive = 1
-- ✓ Check raw material availability BEFORE approval
-- ✓ Block approval if ANY material is insufficient
-- ✓ Deduct raw materials ONLY after successful approval
-- ✓ Atomic operations with proper TRANSACTION handling
-- ✓ Return meaningful error messages with material names + shortage amounts
--
-- Execute this script in SQL Server Management Studio (SSMS)
-- Make sure you're connected to GarmentsFactoryDB database
-- =============================================

USE GarmentsFactoryDB;
GO

PRINT '';
PRINT '========================================';
PRINT '🔧 SALES ORDER APPROVAL - COMPREHENSIVE FIX';
PRINT '========================================';
PRINT '';

-- =============================================
-- ISSUE #1: Fix sp_UpdateSalesOrder Parameter Mismatch
-- =============================================
PRINT '📝 Fixing sp_UpdateSalesOrder parameter mismatch...';

IF OBJECT_ID('sp_UpdateSalesOrder', 'P') IS NOT NULL
    DROP PROCEDURE sp_UpdateSalesOrder;
GO

CREATE PROCEDURE sp_UpdateSalesOrder
    @SalesOrderID INT,
    @OrderDate DATETIME = NULL,
    @Status NVARCHAR(60) = NULL,
    @RetailerID INT = NULL,
    @ShippingAddress NVARCHAR(1000) = NULL,
    @DiscountPercentage DECIMAL(5,2) = NULL,
    @SubTotal DECIMAL(18,2) = NULL,
    @DiscountAmount DECIMAL(18,2) = NULL,
    @TotalAmount DECIMAL(18,2) = NULL,
    @SalesRepID INT = NULL,
    @OrderItemsXML XML = NULL  -- NEW: Added to match C# code
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validate Sales Order exists
        IF NOT EXISTS (SELECT 1 FROM SalesOrder WHERE SalesOrderID = @SalesOrderID)
        BEGIN
            RAISERROR('Sales Order not found.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Validate Employee if provided (must be Active)
        IF @SalesRepID IS NOT NULL
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM Employee WHERE EmployeeID = @SalesRepID AND IsActive = 1)
            BEGIN
                RAISERROR('Sales Representative not found or inactive.', 16, 1);
                ROLLBACK TRANSACTION;
                RETURN;
            END
        END
        
        -- Validate Retailer if provided
        IF @RetailerID IS NOT NULL
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM Retailer WHERE RetailerID = @RetailerID)
            BEGIN
                RAISERROR('Retailer not found.', 16, 1);
                ROLLBACK TRANSACTION;
                RETURN;
            END
        END
        
        -- Update Sales Order
        UPDATE SalesOrder
        SET OrderDate = ISNULL(@OrderDate, OrderDate),
            Status = ISNULL(@Status, Status),
            RetailerID = ISNULL(@RetailerID, RetailerID),
            ShippingAddress = ISNULL(@ShippingAddress, ShippingAddress),
            DiscountPercentage = ISNULL(@DiscountPercentage, DiscountPercentage),
            SubTotal = ISNULL(@SubTotal, SubTotal),
            DiscountAmount = ISNULL(@DiscountAmount, DiscountAmount),
            TotalAmount = ISNULL(@TotalAmount, TotalAmount),
            SalesRepID = CASE WHEN @SalesRepID IS NOT NULL THEN @SalesRepID ELSE SalesRepID END,
            UpdatedDate = GETDATE()
        WHERE SalesOrderID = @SalesOrderID;
        
        -- Handle Order Items if XML provided
        IF @OrderItemsXML IS NOT NULL
        BEGIN
            -- Delete existing items
            DELETE FROM SalesOrderItem WHERE SalesOrderID = @SalesOrderID;
            
            -- Insert new items from XML
            INSERT INTO SalesOrderItem (SalesOrderID, ProductID, Quantity, UnitPrice)
            SELECT 
                @SalesOrderID,
                Item.value('(ProductID)[1]', 'INT'),
                Item.value('(Quantity)[1]', 'INT'),
                Item.value('(UnitPrice)[1]', 'DECIMAL(18,2)')
            FROM @OrderItemsXML.nodes('/Items/Item') AS Items(Item);
            
            -- Recalculate Total Amount
            UPDATE SalesOrder
            SET TotalAmount = (
                SELECT ISNULL(SUM(Quantity * UnitPrice), 0)
                FROM SalesOrderItem
                WHERE SalesOrderID = @SalesOrderID
            ),
            SubTotal = (
                SELECT ISNULL(SUM(Quantity * UnitPrice), 0)
                FROM SalesOrderItem
                WHERE SalesOrderID = @SalesOrderID
            )
            WHERE SalesOrderID = @SalesOrderID;
        END
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

PRINT '✅ sp_UpdateSalesOrder fixed - now accepts @OrderItemsXML parameter';
GO

-- =============================================
-- ISSUE #2: Fix sp_CheckMaterialsForOrder to Return Material Details
-- =============================================
PRINT '📝 Fixing sp_CheckMaterialsForOrder to show material breakdown...';

IF OBJECT_ID('sp_CheckMaterialsForOrder', 'P') IS NOT NULL
    DROP PROCEDURE sp_CheckMaterialsForOrder;
GO

CREATE PROCEDURE sp_CheckMaterialsForOrder
    @OrderType NVARCHAR(50),  -- 'SalesOrder' or 'Deal'
    @OrderID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Create temp table for material check
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
    
    -- Get products from order
    IF @OrderType = 'SalesOrder'
    BEGIN
        INSERT INTO #MaterialCheck (ProductID, ProductName, QuantityOrdered)
        SELECT 
            soi.ProductID,
            p.ProductName,
            soi.Quantity
        FROM SalesOrderItem soi
        INNER JOIN Product p ON soi.ProductID = p.ProductID
        WHERE soi.SalesOrderID = @OrderID;
    END
    ELSE IF @OrderType = 'Deal'
    BEGIN
        INSERT INTO #MaterialCheck (ProductID, ProductName, QuantityOrdered)
        SELECT 
            di.ProductID,
            p.ProductName,
            di.Quantity
        FROM DealItem di
        INNER JOIN Product p ON di.ProductID = p.ProductID
        WHERE di.DealID = @OrderID;
    END
    
    -- Calculate material requirements
    UPDATE mc
    SET 
        mc.RawMaterialID = pmr.RawMaterialID,
        mc.MaterialName = rm.MaterialName,
        mc.RequiredQuantity = pmr.QuantityRequired * mc.QuantityOrdered,
        mc.AvailableQuantity = rm.Quantity,
        mc.Unit = rm.Unit,
        mc.Status = CASE 
            WHEN rm.Quantity >= (pmr.QuantityRequired * mc.QuantityOrdered) THEN 'Sufficient'
            ELSE 'Insufficient'
        END
    FROM #MaterialCheck mc
    LEFT JOIN ProductMaterialRequirement pmr ON mc.ProductID = pmr.ProductID
    LEFT JOIN RawMaterial rm ON pmr.RawMaterialID = rm.RawMaterialID
    WHERE pmr.RawMaterialID IS NOT NULL;
    
    -- Return material breakdown (CRITICAL: This was missing)
    SELECT 
        ProductName,
        MaterialName,
        RequiredQuantity,
        AvailableQuantity,
        Unit,
        Status,
        CASE 
            WHEN Status = 'Insufficient' 
            THEN (RequiredQuantity - AvailableQuantity) 
            ELSE 0 
        END AS Shortage
    FROM #MaterialCheck
    WHERE RawMaterialID IS NOT NULL
    ORDER BY Status DESC, ProductName;
    
    -- Return overall status
    IF EXISTS (SELECT 1 FROM #MaterialCheck WHERE Status = 'Insufficient')
    BEGIN
        DECLARE @InsufficientCount INT = (SELECT COUNT(*) FROM #MaterialCheck WHERE Status = 'Insufficient');
        SELECT 
            'Insufficient' AS OverallStatus, 
            CAST(@InsufficientCount AS NVARCHAR) + ' material(s) are insufficient for production' AS Message;
    END
    ELSE
    BEGIN
        SELECT 
            'Sufficient' AS OverallStatus, 
            'All materials are available for production' AS Message;
    END
    
    DROP TABLE #MaterialCheck;
END
GO

PRINT '✅ sp_CheckMaterialsForOrder fixed - now returns material breakdown';
GO

-- =============================================
-- ISSUE #3: Create New sp_ApproveSalesOrder with Full Validation
-- =============================================
PRINT '📝 Creating sp_ApproveSalesOrder with comprehensive validation...';

IF OBJECT_ID('sp_ApproveSalesOrder', 'P') IS NOT NULL
    DROP PROCEDURE sp_ApproveSalesOrder;
GO

CREATE PROCEDURE sp_ApproveSalesOrder
    @SalesOrderID INT,
    @ApprovedByEmployeeID INT,
    @Notes NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- ========================================
        -- STEP 1: Validation
        -- ========================================
        
        -- Validate Sales Order exists
        IF NOT EXISTS (SELECT 1 FROM SalesOrder WHERE SalesOrderID = @SalesOrderID)
        BEGIN
            RAISERROR('Sales Order #%d not found.', 16, 1, @SalesOrderID);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Validate Employee exists and is active
        IF NOT EXISTS (SELECT 1 FROM Employee WHERE EmployeeID = @ApprovedByEmployeeID AND IsActive = 1)
        BEGIN
            RAISERROR('Employee ID %d not found or inactive. Cannot approve order.', 16, 1, @ApprovedByEmployeeID);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Check if order is already approved
        DECLARE @CurrentStatus NVARCHAR(60);
        SELECT @CurrentStatus = Status FROM SalesOrder WHERE SalesOrderID = @SalesOrderID;
        
        IF @CurrentStatus IN ('Approved', 'InProduction', 'Completed', 'Delivered')
        BEGIN
            RAISERROR('Sales Order #%d is already %s. Cannot re-approve.', 16, 1, @SalesOrderID, @CurrentStatus);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- ========================================
        -- STEP 2: Check Raw Material Availability
        -- ========================================
        
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
        
        -- Get products from Sales Order
        INSERT INTO #MaterialCheck (ProductID, ProductName, QuantityOrdered)
        SELECT 
            soi.ProductID,
            p.ProductName,
            soi.Quantity
        FROM SalesOrderItem soi
        INNER JOIN Product p ON soi.ProductID = p.ProductID
        WHERE soi.SalesOrderID = @SalesOrderID;
        
        -- Check if order has items
        IF NOT EXISTS (SELECT 1 FROM #MaterialCheck)
        BEGIN
            RAISERROR('Sales Order #%d has no items. Cannot approve.', 16, 1, @SalesOrderID);
            DROP TABLE #MaterialCheck;
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Calculate material requirements
        UPDATE mc
        SET 
            mc.RawMaterialID = pmr.RawMaterialID,
            mc.MaterialName = rm.MaterialName,
            mc.RequiredQuantity = pmr.QuantityRequired * mc.QuantityOrdered,
            mc.AvailableQuantity = rm.Quantity,
            mc.Unit = rm.Unit,
            mc.Status = CASE 
                WHEN rm.Quantity >= (pmr.QuantityRequired * mc.QuantityOrdered) THEN 'Sufficient'
                ELSE 'Insufficient'
            END
        FROM #MaterialCheck mc
        LEFT JOIN ProductMaterialRequirement pmr ON mc.ProductID = pmr.ProductID
        LEFT JOIN RawMaterial rm ON pmr.RawMaterialID = rm.RawMaterialID
        WHERE pmr.RawMaterialID IS NOT NULL;
        
        -- Check for insufficient materials
        DECLARE @InsufficientCount INT = (SELECT COUNT(*) FROM #MaterialCheck WHERE Status = 'Insufficient');
        
        IF @InsufficientCount > 0
        BEGIN
            -- Build detailed error message
            DECLARE @ErrorMsg NVARCHAR(MAX) = 'APPROVAL BLOCKED: Insufficient raw materials.' + CHAR(13) + CHAR(10);
            
            SELECT @ErrorMsg = @ErrorMsg + 
                '• ' + MaterialName + ': Need ' + 
                CAST(RequiredQuantity AS NVARCHAR) + ' ' + Unit + 
                ', Available: ' + CAST(AvailableQuantity AS NVARCHAR) + ' ' + Unit +
                ', Shortage: ' + CAST((RequiredQuantity - AvailableQuantity) AS NVARCHAR) + ' ' + Unit + 
                CHAR(13) + CHAR(10)
            FROM #MaterialCheck
            WHERE Status = 'Insufficient';
            
            DROP TABLE #MaterialCheck;
            RAISERROR(@ErrorMsg, 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- ========================================
        -- STEP 3: Deduct Raw Materials
        -- ========================================
        
        DECLARE @RawMaterialID INT, @RequiredQty DECIMAL(18,2);
        DECLARE material_cursor CURSOR FOR
        SELECT DISTINCT RawMaterialID, RequiredQuantity
        FROM #MaterialCheck
        WHERE RawMaterialID IS NOT NULL;
        
        OPEN material_cursor;
        FETCH NEXT FROM material_cursor INTO @RawMaterialID, @RequiredQty;
        
        WHILE @@FETCH_STATUS = 0
        BEGIN
            -- Deduct material from stock
            UPDATE RawMaterial
            SET Quantity = Quantity - @RequiredQty,
                UpdatedDate = GETDATE()
            WHERE RawMaterialID = @RawMaterialID;
            
            -- Log stock usage
            INSERT INTO StockUsage (RawMaterialID, QuantityUsed, UsedBy, UsageDate, Purpose)
            VALUES (
                @RawMaterialID,
                @RequiredQty,
                @ApprovedByEmployeeID,
                GETDATE(),
                'Sales Order #' + CAST(@SalesOrderID AS NVARCHAR) + ' Approval'
            );
            
            FETCH NEXT FROM material_cursor INTO @RawMaterialID, @RequiredQty;
        END
        
        CLOSE material_cursor;
        DEALLOCATE material_cursor;
        
        DROP TABLE #MaterialCheck;
        
        -- ========================================
        -- STEP 4: Update Order Status
        -- ========================================
        
        UPDATE SalesOrder
        SET Status = 'Approved',
            UpdatedDate = GETDATE()
        WHERE SalesOrderID = @SalesOrderID;
        
        -- Update OrderApproval if exists
        UPDATE OrderApproval
        SET Status = 'Approved',
            ApprovedBy = @ApprovedByEmployeeID,
            ApprovalDate = GETDATE(),
            ApprovalNotes = @Notes
        WHERE OrderType = 'SalesOrder' 
          AND OrderID = @SalesOrderID 
          AND Status = 'Pending';
        
        COMMIT TRANSACTION;
        
        -- Return success message
        SELECT 
            'Success' AS Result, 
            'Sales Order #' + CAST(@SalesOrderID AS NVARCHAR) + ' approved successfully. Raw materials deducted from stock.' AS Message;
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        SELECT 
            'Error' AS Result,
            ERROR_MESSAGE() AS Message;
    END CATCH
END
GO

PRINT '✅ sp_ApproveSalesOrder created with full validation and material deduction';
GO

-- =============================================
-- ISSUE #4: Enhance sp_ApproveOrderAndCreateProduction with Better Error Handling
-- =============================================
PRINT '📝 Enhancing sp_ApproveOrderAndCreateProduction error messages...';

-- This procedure was already fixed in the previous script, but let's ensure it has comprehensive error messages
IF OBJECT_ID('sp_ApproveOrderAndCreateProduction', 'P') IS NOT NULL
    DROP PROCEDURE sp_ApproveOrderAndCreateProduction;
GO

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

        -- Validate Owner/Approver exists and is active
        IF @OwnerID > 0 AND NOT EXISTS (SELECT 1 FROM Employee WHERE EmployeeID = @OwnerID AND IsActive = 1)
        BEGIN
            SELECT 'Error' AS Result, 'Approver Employee ID ' + CAST(@OwnerID AS NVARCHAR) + ' not found or inactive.' AS Message, NULL AS ProductionOrderID;
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Get order details
        SELECT @OrderType = OrderType, @OrderID = OrderID
        FROM OrderApproval WHERE ApprovalID = @ApprovalID;

        IF @OrderType IS NULL
        BEGIN
            SELECT 'Error' AS Result, 'Approval request #' + CAST(@ApprovalID AS NVARCHAR) + ' not found.' AS Message, NULL AS ProductionOrderID;
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

        -- If materials are insufficient, return detailed error
        IF @InsufficientCount > 0
        BEGIN
            DECLARE @MaterialError NVARCHAR(MAX) = 'Cannot approve: ' + CAST(@InsufficientCount AS NVARCHAR) + ' material(s) insufficient. ';
            
            SELECT @MaterialError = @MaterialError + 
                MaterialName + ' (Need: ' + CAST(RequiredQuantity AS NVARCHAR) + ', Available: ' + CAST(AvailableQuantity AS NVARCHAR) + '), '
            FROM #MaterialCheck
            WHERE Status = 'Insufficient';
            
            SELECT 'Error' AS Result, @MaterialError AS Message, NULL AS ProductionOrderID;
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

        -- CRITICAL: Deduct raw materials from stock
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

                -- Validate tailor exists and is active
                IF NOT EXISTS (SELECT 1 FROM Employee WHERE EmployeeID = @TailorID AND IsActive = 1)
                    CONTINUE; -- Skip invalid tailors

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

        SELECT 'Success' AS Result, 'Order approved, materials deducted, and production order created successfully.' AS Message, @ProductionOrderID AS ProductionOrderID;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SELECT 'Error' AS Result, ERROR_MESSAGE() AS Message, NULL AS ProductionOrderID;
    END CATCH
END
GO

PRINT '✅ sp_ApproveOrderAndCreateProduction enhanced with better validation';
GO

-- =============================================
-- VERIFICATION QUERIES
-- =============================================
PRINT '';
PRINT '========================================';
PRINT '✅ ALL FIXES APPLIED SUCCESSFULLY!';
PRINT '========================================';
PRINT '';
PRINT 'WHAT WAS FIXED:';
PRINT '1. ✅ sp_UpdateSalesOrder - Now accepts @OrderItemsXML parameter';
PRINT '2. ✅ sp_CheckMaterialsForOrder - Now returns material breakdown';
PRINT '3. ✅ sp_ApproveSalesOrder - New procedure with full validation';
PRINT '4. ✅ sp_ApproveOrderAndCreateProduction - Enhanced error messages';
PRINT '5. ✅ Employee validation added (IsActive = 1 check)';
PRINT '6. ✅ Raw material deduction logic implemented';
PRINT '7. ✅ Atomic transactions with proper ROLLBACK';
PRINT '8. ✅ Meaningful error messages with material details';
PRINT '';
PRINT 'TESTING STEPS:';
PRINT '1. Try updating a Sales Order (should work now)';
PRINT '2. Check materials for an order (should show breakdown)';
PRINT '3. Try approving with insufficient materials (should fail with details)';
PRINT '4. Approve with sufficient materials (should deduct stock)';
PRINT '5. Verify RawMaterial.Quantity decreases after approval';
PRINT '';
PRINT 'VERIFICATION QUERIES:';
PRINT '';
PRINT '-- Check procedures exist:';
PRINT 'SELECT name FROM sys.procedures WHERE name IN (';
PRINT '  ''sp_UpdateSalesOrder'', ''sp_CheckMaterialsForOrder'',';
PRINT '  ''sp_ApproveSalesOrder'', ''sp_ApproveOrderAndCreateProduction''';
PRINT ') ORDER BY name;';
PRINT '';
PRINT '-- Test material check:';
PRINT 'EXEC sp_CheckMaterialsForOrder @OrderType = ''SalesOrder'', @OrderID = 2;';
PRINT '';
PRINT '-- View raw material stock:';
PRINT 'SELECT MaterialName, Quantity, MinimumStock FROM RawMaterial WHERE IsActive = 1;';
PRINT '';
GO
