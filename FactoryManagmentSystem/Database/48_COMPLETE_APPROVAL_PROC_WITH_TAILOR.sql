-- =============================================
-- RECREATE sp_ApproveOrderAndCreateProduction WITH TAILOR ASSIGNMENT
-- This version includes the missing tailor assignment logic
-- Date: December 17, 2025
-- =============================================

USE GarmentsFactoryDB;
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
        DECLARE @ProductCount INT = 0;

        -- Validate Owner/Approver exists and is active
        IF @OwnerID > 0 AND NOT EXISTS (SELECT 1 FROM Employee WHERE EmployeeID = @OwnerID AND IsActive = 1)
        BEGIN
            SELECT 'Error' AS Result, 
                   'Approver Employee ID ' + CAST(@OwnerID AS NVARCHAR) + ' not found or inactive.' AS Message, 
                   NULL AS ProductionOrderID;
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Get Order details from OrderApproval
        SELECT @OrderType = OrderType, @OrderID = OrderID
        FROM OrderApproval
        WHERE ApprovalID = @ApprovalID;

        IF @OrderType IS NULL OR @OrderID IS NULL
        BEGIN
            SELECT 'Error' AS Result,
                   'Approval ID ' + CAST(@ApprovalID AS NVARCHAR) + ' not found.' AS Message,
                   NULL AS ProductionOrderID;
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Create material check table
        CREATE TABLE #MaterialCheck (
            ProductID INT,
            ProductName NVARCHAR(100),
            QuantityOrdered INT,
            RawMaterialID INT,
            RawMaterialName NVARCHAR(200),
            RequiredQuantity DECIMAL(18,2),
            AvailableQuantity DECIMAL(18,2),
            IsAvailable BIT
        );

        -- Populate material requirements based on order type
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

        SET @ProductCount = @@ROWCOUNT;

        IF @ProductCount = 0
        BEGIN
            SELECT 'Error' AS Result,
                   'Cannot approve ' + @OrderType + ' #' + CAST(@OrderID AS NVARCHAR) + ': No products/items found. Please add items to the order first.' AS Message,
                   NULL AS ProductionOrderID;
            DROP TABLE #MaterialCheck;
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Check material availability
        UPDATE mc
        SET mc.RawMaterialID = pmr.RawMaterialID,
            mc.RawMaterialName = rm.MaterialName,
            mc.RequiredQuantity = pmr.QuantityRequired * mc.QuantityOrdered,
            mc.AvailableQuantity = rm.Quantity,
            mc.IsAvailable = CASE 
                WHEN rm.Quantity >= (pmr.QuantityRequired * mc.QuantityOrdered) THEN 1 
                ELSE 0 
            END
        FROM #MaterialCheck mc
        LEFT JOIN ProductMaterialRequirement pmr ON mc.ProductID = pmr.ProductID
        LEFT JOIN RawMaterial rm ON pmr.RawMaterialID = rm.RawMaterialID
        WHERE pmr.RawMaterialID IS NOT NULL;

        SELECT @InsufficientCount = COUNT(*)
        FROM #MaterialCheck
        WHERE IsAvailable = 0 AND RawMaterialID IS NOT NULL;

        IF @InsufficientCount > 0
        BEGIN
            SELECT 'Error' AS Result,
                   'Insufficient raw materials for this order. ' + CAST(@InsufficientCount AS NVARCHAR) + ' material(s) have insufficient stock.' AS Message,
                   NULL AS ProductionOrderID;
            DROP TABLE #MaterialCheck;
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Deduct raw materials from stock
        DECLARE @RawMaterialID INT, @RequiredQty DECIMAL(18,2);
        DECLARE material_cursor CURSOR FOR
        SELECT DISTINCT mc.RawMaterialID, mc.RequiredQuantity
        FROM #MaterialCheck mc
        WHERE mc.RawMaterialID IS NOT NULL AND mc.RequiredQuantity > 0;

        OPEN material_cursor;
        FETCH NEXT FROM material_cursor INTO @RawMaterialID, @RequiredQty;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            UPDATE RawMaterial
            SET Quantity = Quantity - @RequiredQty
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

        -- Get first product and quantity for production order
        SELECT TOP 1 @ProductID = ProductID, @QuantityOrdered = QuantityOrdered
        FROM (
            SELECT soi.ProductID, soi.Quantity AS QuantityOrdered
            FROM SalesOrderItem soi
            WHERE soi.SalesOrderID = @OrderID AND @OrderType = 'SalesOrder'
            UNION ALL
            SELECT di.ProductID, di.Quantity
            FROM DealItem di
            WHERE di.DealID = @OrderID AND @OrderType = 'Deal'
        ) AS Items
        WHERE ProductID IS NOT NULL;

        IF @ProductID IS NULL
        BEGIN
            SELECT 'Error' AS Result,
                   'No product found for production order creation.' AS Message,
                   NULL AS ProductionOrderID;
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Create ProductionOrder
        DECLARE @CreatedBy INT = CASE WHEN @OwnerID = 0 THEN NULL ELSE @OwnerID END;

        INSERT INTO ProductionOrder (ProductID, QuantityOrdered, Status, Priority, CreatedByEmployeeID, CreatedDate, StartDate)
        VALUES (@ProductID, @QuantityOrdered, 'Pending', 'Normal', @CreatedBy, GETDATE(), GETDATE());

        SET @ProductionOrderID = SCOPE_IDENTITY();

        -- *** ADDED: Assign tailors to production order ***
        IF @TailorIDs IS NOT NULL AND LEN(@TailorIDs) > 0
        BEGIN
            EXEC sp_AssignTailorsToProductionOrder
                @ProductionOrderID = @ProductionOrderID,
                @TailorIDs = @TailorIDs,
                @ProductID = @ProductID,
                @QuantityOrdered = @QuantityOrdered;
        END

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

PRINT '✓ sp_ApproveOrderAndCreateProduction recreated with tailor assignment logic'
GO
