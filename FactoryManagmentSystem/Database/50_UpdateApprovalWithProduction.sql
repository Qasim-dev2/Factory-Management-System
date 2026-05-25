-- Update sp_ApproveOrderAndCreateProduction to create ProductionOrder and properly link TailorAssignments
-- This procedure now:
-- 1. Creates a ProductionOrder record
-- 2. Links TailorAssignments to the ProductionOrder
-- 3. Includes ProductID in TailorAssignment
-- 4. Sets initial status to 'Incomplete' instead of 'Assigned'

DROP PROCEDURE IF EXISTS sp_ApproveOrderAndCreateProduction;
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

        -- Create ProductionOrder
        INSERT INTO ProductionOrder (ProductID, QuantityOrdered, Status, Priority, CreatedByEmployeeID, CreatedDate, StartDate)
        VALUES (@ProductID, @QuantityOrdered, 'Pending', 'Normal', @OwnerID, GETDATE(), GETDATE());

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

        SELECT 'Success' AS Result, 'Order approved and production order created successfully.' AS Message, @ProductionOrderID AS ProductionOrderID;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SELECT 'Error' AS Result, ERROR_MESSAGE() AS Message, NULL AS ProductionOrderID;
    END CATCH
END
GO
