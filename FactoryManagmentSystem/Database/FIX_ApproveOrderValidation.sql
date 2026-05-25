-- =============================================
-- FIX: sp_ApproveOrderAndCreateProduction
-- Issue: "No products found in the order" error
-- Root Cause: Empty #MaterialCheck table or products without ProductMaterialRequirement
-- =============================================

USE GarmentsFactoryDB;
GO

PRINT '🔧 Fixing sp_ApproveOrderAndCreateProduction - Better error handling...';

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
        DECLARE @ProductCount INT = 0;  -- ✅ Added to track products found

        -- Validate Owner/Approver exists and is active
        IF @OwnerID > 0 AND NOT EXISTS (SELECT 1 FROM Employee WHERE EmployeeID = @OwnerID AND IsActive = 1)
        BEGIN
            SELECT 'Error' AS Result, 
                   'Approver Employee ID ' + CAST(@OwnerID AS NVARCHAR) + ' not found or inactive.' AS Message, 
                   NULL AS ProductionOrderID;
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Get order details
        SELECT @OrderType = OrderType, @OrderID = OrderID
        FROM OrderApproval WHERE ApprovalID = @ApprovalID;

        IF @OrderType IS NULL
        BEGIN
            SELECT 'Error' AS Result, 
                   'Approval request #' + CAST(@ApprovalID AS NVARCHAR) + ' not found.' AS Message, 
                   NULL AS ProductionOrderID;
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

        -- ✅ Get products based on order type
        IF @OrderType = 'SalesOrder'
        BEGIN
            INSERT INTO #MaterialCheck (ProductID, ProductName, QuantityOrdered)
            SELECT soi.ProductID, p.ProductName, soi.Quantity
            FROM SalesOrderItem soi
            JOIN Product p ON soi.ProductID = p.ProductID
            WHERE soi.SalesOrderID = @OrderID;
            
            -- ✅ Check if order has any items
            SELECT @ProductCount = COUNT(*) FROM #MaterialCheck;
            
            IF @ProductCount = 0
            BEGIN
                SELECT 'Error' AS Result,
                       'Cannot approve Sales Order #' + CAST(@OrderID AS NVARCHAR) + ': No products/items found. Please add items to the order first.' AS Message,
                       NULL AS ProductionOrderID;
                DROP TABLE #MaterialCheck;
                ROLLBACK TRANSACTION;
                RETURN;
            END
        END
        ELSE IF @OrderType = 'Deal'
        BEGIN
            INSERT INTO #MaterialCheck (ProductID, ProductName, QuantityOrdered)
            SELECT di.ProductID, p.ProductName, di.Quantity
            FROM DealItem di
            JOIN Product p ON di.ProductID = p.ProductID
            WHERE di.DealID = @OrderID;
            
            -- ✅ Check if deal has any items
            SELECT @ProductCount = COUNT(*) FROM #MaterialCheck;
            
            IF @ProductCount = 0
            BEGIN
                SELECT 'Error' AS Result,
                       'Cannot approve Deal #' + CAST(@OrderID AS NVARCHAR) + ': No products/items found. Please add items to the deal first.' AS Message,
                       NULL AS ProductionOrderID;
                DROP TABLE #MaterialCheck;
                ROLLBACK TRANSACTION;
                RETURN;
            END
        END

        -- ✅ Check material requirements for products
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
        LEFT JOIN RawMaterial rm ON pmr.RawMaterialID = rm.RawMaterialID
        WHERE pmr.RawMaterialID IS NOT NULL;

        -- ✅ Check if products have Bill of Materials defined
        DECLARE @ProductsWithoutBOM INT;
        SELECT @ProductsWithoutBOM = COUNT(*)
        FROM #MaterialCheck
        WHERE RawMaterialID IS NULL;
        
        IF @ProductsWithoutBOM > 0
        BEGIN
            DECLARE @ProductsNoBOM NVARCHAR(MAX) = '';
            SELECT @ProductsNoBOM = @ProductsNoBOM + ProductName + ', '
            FROM #MaterialCheck
            WHERE RawMaterialID IS NULL;
            
            -- Remove trailing comma
            SET @ProductsNoBOM = LEFT(@ProductsNoBOM, LEN(@ProductsNoBOM) - 1);
            
            SELECT 'Error' AS Result,
                   'Cannot approve: ' + CAST(@ProductsWithoutBOM AS NVARCHAR) + ' product(s) do not have Bill of Materials (BOM) defined: ' + @ProductsNoBOM + 
                   '. Please define material requirements in ProductMaterialRequirement table first.' AS Message,
                   NULL AS ProductionOrderID;
            DROP TABLE #MaterialCheck;
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Count insufficient materials (only check items that have materials defined)
        SELECT @InsufficientCount = COUNT(*) 
        FROM #MaterialCheck 
        WHERE Status = 'Insufficient' AND RawMaterialID IS NOT NULL;

        -- If materials are insufficient, return detailed error
        IF @InsufficientCount > 0
        BEGIN
            DECLARE @MaterialError NVARCHAR(MAX) = 'Cannot approve: ' + CAST(@InsufficientCount AS NVARCHAR) + ' material(s) insufficient. ';
            
            SELECT @MaterialError = @MaterialError + 
                MaterialName + ' (Need: ' + CAST(RequiredQuantity AS NVARCHAR) + ' ' + Unit + 
                ', Available: ' + CAST(AvailableQuantity AS NVARCHAR) + ' ' + Unit + '), '
            FROM #MaterialCheck
            WHERE Status = 'Insufficient' AND RawMaterialID IS NOT NULL;
            
            SELECT 'Error' AS Result, @MaterialError AS Message, NULL AS ProductionOrderID;
            DROP TABLE #MaterialCheck;
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Get first product and quantity for production order
        SELECT TOP 1 @ProductID = ProductID, @QuantityOrdered = QuantityOrdered
        FROM #MaterialCheck
        WHERE ProductID IS NOT NULL;

        -- ✅ This should never happen now (because we checked earlier), but just in case
        IF @ProductID IS NULL
        BEGIN
            SELECT 'Error' AS Result,
                   'Cannot create production order. No valid products found in the order.' AS Message,
                   NULL AS ProductionOrderID;
            DROP TABLE #MaterialCheck;
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- ✅ CRITICAL: Deduct raw materials from stock
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

            -- ✅ Optional: Log the deduction (if StockUsage table exists)
            IF OBJECT_ID('StockUsage', 'U') IS NOT NULL
            BEGIN
                INSERT INTO StockUsage (RawMaterialID, QuantityUsed, UsageType, UsageDate, ReferenceType, ReferenceID)
                VALUES (@RawMaterialID, @RequiredQty, 'Production', GETDATE(), @OrderType, @OrderID);
            END

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
                    SET @TailorID = CAST(SUBSTRING(@TailorList, 1, @Pos - 1) AS INT);
                    SET @TailorList = SUBSTRING(@TailorList, @Pos + 1, LEN(@TailorList));
                END

                -- ✅ Validate tailor is active before assigning
                IF EXISTS (SELECT 1 FROM Employee WHERE EmployeeID = @TailorID AND IsActive = 1)
                BEGIN
                    INSERT INTO TailorAssignment (ProductionOrderID, TailorEmployeeID, AssignedDate, Status)
                    VALUES (@ProductionOrderID, @TailorID, GETDATE(), 'Assigned');
                END
            END
        END

        -- Link production order back to approval
        UPDATE OrderApproval SET ProductionOrderID = @ProductionOrderID WHERE ApprovalID = @ApprovalID;

        COMMIT TRANSACTION;
        
        SELECT 
            'Success' AS Result, 
            'Order approved successfully. Production order #' + CAST(@ProductionOrderID AS NVARCHAR) + ' created.' AS Message,
            @ProductionOrderID AS ProductionOrderID;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        SELECT 
            'Error' AS Result,
            ERROR_MESSAGE() AS Message,
            NULL AS ProductionOrderID;
    END CATCH
END
GO

PRINT '✅ sp_ApproveOrderAndCreateProduction fixed - better validation and error messages';
GO

PRINT '';
PRINT '📝 Summary of fixes:';
PRINT '   1. Check if order has items BEFORE checking materials';
PRINT '   2. Check if products have Bill of Materials (BOM) defined';
PRINT '   3. Clear error messages indicating exactly what''s missing';
PRINT '   4. Validate tailors are active before assignment';
PRINT '   5. Optional StockUsage logging';
GO
