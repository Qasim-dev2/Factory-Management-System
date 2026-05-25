-- ================================================================================
-- FIX DELIVERY WORKFLOW - ADD DEAL SUPPORT
-- ================================================================================
-- This script:
-- 1. Adds DealID column to Delivery table
-- 2. Adds delivery-related columns to Deal table
-- 3. Updates stored procedures to handle both SalesOrders and Deals
-- ================================================================================

USE GarmentsFactoryDB;
GO

-- ================================================================================
-- STEP 1: ALTER TABLES
-- ================================================================================

-- Add DealID to Delivery table
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Delivery') AND name = 'DealID')
BEGIN
    ALTER TABLE Delivery
    ADD DealID INT NULL;
    
    -- Add foreign key constraint
    ALTER TABLE Delivery
    ADD CONSTRAINT FK_Delivery_Deal FOREIGN KEY (DealID) REFERENCES Deal(DealID);
    
    PRINT 'Added DealID column to Delivery table';
END
GO

-- Add delivery-related columns to Deal table if they don't exist
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Deal') AND name = 'DeliveryAddress')
BEGIN
    ALTER TABLE Deal
    ADD DeliveryAddress NVARCHAR(500) NULL,
        City NVARCHAR(100) NULL,
        Province NVARCHAR(100) NULL;
    
    PRINT 'Added delivery columns to Deal table';
END
GO

-- ================================================================================
-- STEP 2: UPDATE sp_UpdateTailorCompletionStatus
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
        
        -- Update ALL tailor assignments for this production order (they work together)
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
        
        -- If status changed to Complete, update production and create delivery
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
            
            -- AUTOMATICALLY CREATE DELIVERY when production is completed
            -- Get order details from OrderApproval
            SELECT 
                @OrderType = oa.OrderType,
                @SalesOrderID = CASE WHEN oa.OrderType = 'SalesOrder' THEN oa.OrderID ELSE NULL END,
                @DealID = CASE WHEN oa.OrderType = 'Deal' THEN oa.OrderID ELSE NULL END
            FROM OrderApproval oa
            WHERE oa.ProductionOrderID = @ProductionOrderID
            AND oa.Status = 'Approved';
            
            -- Create delivery for BOTH SalesOrders AND Deals
            IF @SalesOrderID IS NOT NULL
            BEGIN
                -- Check if delivery doesn't already exist for SalesOrder
                IF NOT EXISTS (SELECT 1 FROM Delivery WHERE SalesOrderID = @SalesOrderID AND DealID IS NULL)
                BEGIN
                    -- Create delivery record for SalesOrder
                    INSERT INTO Delivery (
                        SalesOrderID,
                        DealID,
                        DeliveryAddress,
                        City,
                        Province,
                        Status,
                        ReceiverName,
                        ReceiverPhone,
                        CreatedDate
                    )
                    SELECT 
                        so.SalesOrderID,
                        NULL,
                        so.ShippingAddress,
                        ret.City,
                        ret.Province,
                        'Pending',
                        ret.ContactPerson,
                        ret.Phone,
                        GETDATE()
                    FROM SalesOrder so
                    JOIN Retailer ret ON so.RetailerID = ret.RetailerID
                    WHERE so.SalesOrderID = @SalesOrderID;
                    
                    SET @DeliveryID = SCOPE_IDENTITY();
                    
                    -- Update SalesOrder status
                    UPDATE SalesOrder
                    SET Status = 'ReadyForDelivery',
                        UpdatedDate = GETDATE()
                    WHERE SalesOrderID = @SalesOrderID;
                END
            END
            ELSE IF @DealID IS NOT NULL
            BEGIN
                -- Check if delivery doesn't already exist for Deal
                IF NOT EXISTS (SELECT 1 FROM Delivery WHERE DealID = @DealID AND SalesOrderID IS NULL)
                BEGIN
                    -- Create delivery record for Deal
                    INSERT INTO Delivery (
                        SalesOrderID,
                        DealID,
                        DeliveryAddress,
                        City,
                        Province,
                        Status,
                        ReceiverName,
                        ReceiverPhone,
                        CreatedDate
                    )
                    SELECT 
                        NULL,
                        d.DealID,
                        ISNULL(d.DeliveryAddress, 'Not specified'),
                        ISNULL(d.City, 'Not specified'),
                        ISNULL(d.Province, 'Not specified'),
                        'Pending',
                        d.ContactPerson,
                        d.Phone,
                        GETDATE()
                    FROM Deal d
                    WHERE d.DealID = @DealID;
                    
                    SET @DeliveryID = SCOPE_IDENTITY();
                    
                    -- Update Deal status
                    UPDATE Deal
                    SET Status = 'ReadyForDelivery',
                        UpdatedDate = GETDATE()
                    WHERE DealID = @DealID;
                END
            END
        END
        
        COMMIT TRANSACTION;
        
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

-- ================================================================================
-- STEP 3: UPDATE sp_GetDeliveryAssignments
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
        
        -- Order details (SalesOrder or Deal)
        CASE 
            WHEN d.SalesOrderID IS NOT NULL THEN 'SalesOrder'
            WHEN d.DealID IS NOT NULL THEN 'Deal'
        END AS OrderType,
        
        -- SalesOrder details
        so.OrderDate AS SalesOrderDate,
        so.TotalAmount AS SalesOrderAmount,
        
        -- Deal details
        de.CreatedDate AS DealDate,
        de.EstimatedValue AS DealAmount,
        
        -- Customer details (Retailer or Deal Client)
        COALESCE(ret.CompanyName, de.ClientName) AS CustomerName,
        COALESCE(ret.Phone, de.Phone) AS CustomerPhone,
        COALESCE(ret.ContactPerson, de.ContactPerson) AS ContactPerson,
        
        -- Delivery person
        CONCAT(e.FirstName, ' ', e.LastName) AS DeliveryPersonName
        
    FROM Delivery d
    LEFT JOIN SalesOrder so ON d.SalesOrderID = so.SalesOrderID
    LEFT JOIN Retailer ret ON so.RetailerID = ret.RetailerID
    LEFT JOIN Deal de ON d.DealID = de.DealID
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

-- ================================================================================
-- STEP 4: UPDATE sp_UpdateDeliveryStatus
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
        -- Update SalesOrder or Deal status
        IF @NewStatus = 'Delivered'
        BEGIN
            -- Update SalesOrder if exists
            UPDATE so
            SET Status = 'Delivered',
                UpdatedDate = GETDATE()
            FROM SalesOrder so
            JOIN Delivery d ON so.SalesOrderID = d.SalesOrderID
            WHERE d.DeliveryID = @DeliveryID AND d.SalesOrderID IS NOT NULL;
            
            -- Update Deal if exists
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

-- ================================================================================
-- STEP 5: UPDATE sp_ApproveOrderAndCreateProduction
-- ================================================================================
-- Don't create delivery during approval - only after tailors complete
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
        
        -- Update original order status (NO DELIVERY CREATED HERE - only after tailors complete)
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

PRINT '========================================';
PRINT 'DELIVERY WORKFLOW FIXES COMPLETE!';
PRINT '';
PRINT 'Changes Made:';
PRINT '  1. Added DealID column to Delivery table';
PRINT '  2. Added delivery columns to Deal table';
PRINT '  3. Updated sp_UpdateTailorCompletionStatus';
PRINT '     - Multiple tailors work together (shared status)';
PRINT '     - Creates delivery for BOTH SalesOrders and Deals';
PRINT '  4. Updated sp_GetDeliveryAssignments (handles Deals)';
PRINT '  5. Updated sp_UpdateDeliveryStatus (handles Deals)';
PRINT '  6. Updated sp_ApproveOrderAndCreateProduction';
PRINT '     - NO delivery created during approval';
PRINT '     - Delivery only created when tailors complete';
PRINT '';
PRINT 'NEW WORKFLOW:';
PRINT '  1. Owner approves order → Goes to Tailor Tasks';
PRINT '  2. Tailors work together (shared status)';
PRINT '  3. When completed → Delivery auto-created';
PRINT '  4. Delivery person updates status';
PRINT '========================================';
GO
