-- ================================================================================
-- PRODUCTION ORDER MANAGEMENT - STORED PROCEDURES
-- ================================================================================
-- Execute this script in SQL Server Management Studio (SSMS)
-- Make sure you're connected to GarmentsFactoryDB database
-- Matches ProductionOrder and ProductionOrderItem table structure from 01_CreateDatabase.sql
-- ================================================================================

USE GarmentsFactoryDB;
GO

-- ================================================================================
-- 1. GET ALL PRODUCTION ORDERS (For Browse Tab)
-- ================================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetAllProductionOrders')
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
        -- Employee Information (Created By - Tailor)
        CONCAT(e.FirstName, ' ', e.LastName) AS CreatedByName,
        e.Specialization AS TailorSpecialization,
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
    ORDER BY po.CreatedDate DESC;
END
GO

PRINT 'sp_GetAllProductionOrders created successfully.';
GO

-- ================================================================================
-- 2. GET PRODUCTION ORDER BY ID (For Details/Update)
-- ================================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetProductionOrderById')
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
        e.Specialization AS TailorSpecialization,
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
    WHERE po.ProductionOrderID = @ProductionOrderID;
END
GO

PRINT 'sp_GetProductionOrderById created successfully.';
GO

-- ================================================================================
-- 3. CREATE PRODUCTION ORDER (For Add Tab)
-- ================================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_CreateProductionOrder')
    DROP PROCEDURE sp_CreateProductionOrder;
GO

CREATE PROCEDURE sp_CreateProductionOrder
    @ProductID INT,
    @QuantityOrdered INT,
    @StartDate DATE = NULL,
    @ExpectedEndDate DATE = NULL,
    @Priority NVARCHAR(20) = 'Normal',
    @Notes NVARCHAR(500) = NULL,
    @CreatedByEmployeeID INT = NULL,
    @ProductionOrderID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validate product exists
        IF NOT EXISTS (SELECT 1 FROM Product WHERE ProductID = @ProductID)
        BEGIN
            RAISERROR('Product not found.', 16, 1);
            RETURN;
        END
        
        -- Validate employee exists if provided
        IF @CreatedByEmployeeID IS NOT NULL 
           AND NOT EXISTS (SELECT 1 FROM Employee WHERE EmployeeID = @CreatedByEmployeeID)
        BEGIN
            RAISERROR('Employee not found.', 16, 1);
            RETURN;
        END
        
        -- Set default dates if not provided
        IF @StartDate IS NULL
            SET @StartDate = CAST(GETDATE() AS DATE);
            
        -- Insert Production Order
        INSERT INTO ProductionOrder (
            ProductID,
            QuantityOrdered,
            QuantityCompleted,
            StartDate,
            ExpectedEndDate,
            Status,
            Priority,
            Notes,
            CreatedByEmployeeID,
            CreatedDate
        )
        VALUES (
            @ProductID,
            @QuantityOrdered,
            0,
            @StartDate,
            @ExpectedEndDate,
            'Pending',
            @Priority,
            @Notes,
            @CreatedByEmployeeID,
            GETDATE()
        );
        
        SET @ProductionOrderID = SCOPE_IDENTITY();
        
        COMMIT TRANSACTION;
        
        PRINT 'Production Order created successfully with ID: ' + CAST(@ProductionOrderID AS NVARCHAR);
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

PRINT 'sp_CreateProductionOrder created successfully.';
GO

-- ================================================================================
-- 4. UPDATE PRODUCTION ORDER (For Update Tab)
-- ================================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_UpdateProductionOrder')
    DROP PROCEDURE sp_UpdateProductionOrder;
GO

CREATE PROCEDURE sp_UpdateProductionOrder
    @ProductionOrderID INT,
    @ProductID INT = NULL,
    @QuantityOrdered INT = NULL,
    @QuantityCompleted INT = NULL,
    @StartDate DATE = NULL,
    @ExpectedEndDate DATE = NULL,
    @ActualEndDate DATE = NULL,
    @Status NVARCHAR(50) = NULL,
    @Priority NVARCHAR(20) = NULL,
    @Notes NVARCHAR(500) = NULL,
    @CreatedByEmployeeID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validate production order exists
        IF NOT EXISTS (SELECT 1 FROM ProductionOrder WHERE ProductionOrderID = @ProductionOrderID)
        BEGIN
            RAISERROR('Production Order not found.', 16, 1);
            RETURN;
        END
        
        -- Validate product exists if provided
        IF @ProductID IS NOT NULL 
           AND NOT EXISTS (SELECT 1 FROM Product WHERE ProductID = @ProductID)
        BEGIN
            RAISERROR('Product not found.', 16, 1);
            RETURN;
        END
        
        -- Validate employee exists if provided
        IF @CreatedByEmployeeID IS NOT NULL 
           AND NOT EXISTS (SELECT 1 FROM Employee WHERE EmployeeID = @CreatedByEmployeeID)
        BEGIN
            RAISERROR('Employee not found.', 16, 1);
            RETURN;
        END
        
        -- Auto-set ActualEndDate if status is Completed
        IF @Status = 'Completed' AND @ActualEndDate IS NULL
        BEGIN
            SET @ActualEndDate = CAST(GETDATE() AS DATE);
        END
        
        -- Update Production Order
        UPDATE ProductionOrder
        SET 
            ProductID = ISNULL(@ProductID, ProductID),
            QuantityOrdered = ISNULL(@QuantityOrdered, QuantityOrdered),
            QuantityCompleted = ISNULL(@QuantityCompleted, QuantityCompleted),
            StartDate = ISNULL(@StartDate, StartDate),
            ExpectedEndDate = ISNULL(@ExpectedEndDate, ExpectedEndDate),
            ActualEndDate = ISNULL(@ActualEndDate, ActualEndDate),
            Status = ISNULL(@Status, Status),
            Priority = ISNULL(@Priority, Priority),
            Notes = ISNULL(@Notes, Notes),
            CreatedByEmployeeID = ISNULL(@CreatedByEmployeeID, CreatedByEmployeeID),
            UpdatedDate = GETDATE()
        WHERE ProductionOrderID = @ProductionOrderID;
        
        COMMIT TRANSACTION;
        
        PRINT 'Production Order updated successfully.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

PRINT 'sp_UpdateProductionOrder created successfully.';
GO

-- ================================================================================
-- 5. DELETE PRODUCTION ORDER (For Delete Tab)
-- ================================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_DeleteProductionOrder')
    DROP PROCEDURE sp_DeleteProductionOrder;
GO

CREATE PROCEDURE sp_DeleteProductionOrder
    @ProductionOrderID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validate production order exists
        IF NOT EXISTS (SELECT 1 FROM ProductionOrder WHERE ProductionOrderID = @ProductionOrderID)
        BEGIN
            RAISERROR('Production Order not found.', 16, 1);
            RETURN;
        END
        
        -- Delete related ProductionOrderItems (CASCADE will handle this)
        -- Delete related TailorTasks if any
        DELETE FROM TailorTask WHERE ProductionOrderID = @ProductionOrderID;
        
        -- Delete related StockUsage if any
        DELETE FROM StockUsage WHERE ProductionOrderID = @ProductionOrderID;
        
        -- Delete Production Order
        DELETE FROM ProductionOrder WHERE ProductionOrderID = @ProductionOrderID;
        
        COMMIT TRANSACTION;
        
        PRINT 'Production Order deleted successfully.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

PRINT 'sp_DeleteProductionOrder created successfully.';
GO

-- ================================================================================
-- 6. SEARCH PRODUCTION ORDERS (For Search/Filter)
-- ================================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_SearchProductionOrders')
    DROP PROCEDURE sp_SearchProductionOrders;
GO

CREATE PROCEDURE sp_SearchProductionOrders
    @SearchTerm NVARCHAR(100) = NULL,
    @Status NVARCHAR(50) = NULL,
    @Priority NVARCHAR(20) = NULL,
    @StartDate DATE = NULL,
    @EndDate DATE = NULL,
    @CreatedByEmployeeID INT = NULL
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
        po.Status,
        po.Priority,
        p.ProductName,
        p.Category,
        CONCAT(e.FirstName, ' ', e.LastName) AS CreatedByName,
        (po.QuantityOrdered - po.QuantityCompleted) AS RemainingQuantity
    FROM ProductionOrder po
    INNER JOIN Product p ON po.ProductID = p.ProductID
    LEFT JOIN Employee e ON po.CreatedByEmployeeID = e.EmployeeID
    WHERE 
        (@SearchTerm IS NULL OR 
         p.ProductName LIKE '%' + @SearchTerm + '%' OR
         p.Category LIKE '%' + @SearchTerm + '%' OR
         CAST(po.ProductionOrderID AS NVARCHAR) LIKE '%' + @SearchTerm + '%')
        AND (@Status IS NULL OR po.Status = @Status)
        AND (@Priority IS NULL OR po.Priority = @Priority)
        AND (@StartDate IS NULL OR CAST(po.StartDate AS DATE) >= @StartDate)
        AND (@EndDate IS NULL OR CAST(po.StartDate AS DATE) <= @EndDate)
        AND (@CreatedByEmployeeID IS NULL OR po.CreatedByEmployeeID = @CreatedByEmployeeID)
    ORDER BY po.CreatedDate DESC;
END
GO

PRINT 'sp_SearchProductionOrders created successfully.';
GO

-- ================================================================================
-- 7. GET PRODUCTION ORDER STATISTICS (For Dashboard)
-- ================================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetProductionOrderStatistics')
    DROP PROCEDURE sp_GetProductionOrderStatistics;
GO

CREATE PROCEDURE sp_GetProductionOrderStatistics
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        COUNT(*) AS TotalOrders,
        ISNULL(SUM(CASE WHEN Status = 'Pending' THEN 1 ELSE 0 END), 0) AS PendingOrders,
        ISNULL(SUM(CASE WHEN Status = 'InProgress' THEN 1 ELSE 0 END), 0) AS InProgressOrders,
        ISNULL(SUM(CASE WHEN Status = 'Completed' THEN 1 ELSE 0 END), 0) AS CompletedOrders,
        ISNULL(SUM(CASE WHEN Status = 'Cancelled' THEN 1 ELSE 0 END), 0) AS CancelledOrders,
        ISNULL(SUM(QuantityOrdered), 0) AS TotalQuantityOrdered,
        ISNULL(SUM(QuantityCompleted), 0) AS TotalQuantityCompleted,
        ISNULL(SUM(QuantityOrdered - QuantityCompleted), 0) AS TotalRemainingQuantity,
        ISNULL(AVG(CASE 
            WHEN QuantityOrdered > 0 THEN 
                (CAST(QuantityCompleted AS FLOAT) / QuantityOrdered * 100)
            ELSE 0 
        END), 0) AS AverageCompletionPercentage,
        ISNULL(SUM(CASE WHEN CAST(StartDate AS DATE) = CAST(GETDATE() AS DATE) THEN 1 ELSE 0 END), 0) AS TodayOrders,
        ISNULL(SUM(CASE WHEN Priority = 'Urgent' THEN 1 ELSE 0 END), 0) AS UrgentOrders
    FROM ProductionOrder;
END
GO

PRINT 'sp_GetProductionOrderStatistics created successfully.';
GO

-- ================================================================================
-- 8. GET ALL PRODUCTION ORDER ITEMS BY ORDER ID
-- ================================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetProductionOrderItems')
    DROP PROCEDURE sp_GetProductionOrderItems;
GO

CREATE PROCEDURE sp_GetProductionOrderItems
    @ProductionOrderID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        poi.ProductionOrderItemID,
        poi.ProductionOrderID,
        poi.RawMaterialID,
        poi.QuantityRequired,
        poi.QuantityUsed,
        -- Raw Material Information
        rm.MaterialName,
        rm.Category,
        rm.Unit,
        rm.Quantity AS AvailableStock,
        rm.UnitPrice,
        -- Calculated Fields
        (poi.QuantityRequired - poi.QuantityUsed) AS RemainingQuantity,
        (poi.QuantityRequired * rm.UnitPrice) AS TotalCost
    FROM ProductionOrderItem poi
    INNER JOIN RawMaterial rm ON poi.RawMaterialID = rm.RawMaterialID
    WHERE poi.ProductionOrderID = @ProductionOrderID
    ORDER BY poi.ProductionOrderItemID;
END
GO

PRINT 'sp_GetProductionOrderItems created successfully.';
GO

-- ================================================================================
-- 9. ADD PRODUCTION ORDER ITEM
-- ================================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_AddProductionOrderItem')
    DROP PROCEDURE sp_AddProductionOrderItem;
GO

CREATE PROCEDURE sp_AddProductionOrderItem
    @ProductionOrderID INT,
    @RawMaterialID INT,
    @QuantityRequired DECIMAL(18,2),
    @ProductionOrderItemID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validate production order exists
        IF NOT EXISTS (SELECT 1 FROM ProductionOrder WHERE ProductionOrderID = @ProductionOrderID)
        BEGIN
            RAISERROR('Production Order not found.', 16, 1);
            RETURN;
        END
        
        -- Validate raw material exists
        IF NOT EXISTS (SELECT 1 FROM RawMaterial WHERE RawMaterialID = @RawMaterialID)
        BEGIN
            RAISERROR('Raw Material not found.', 16, 1);
            RETURN;
        END
        
        -- Insert Production Order Item
        INSERT INTO ProductionOrderItem (
            ProductionOrderID,
            RawMaterialID,
            QuantityRequired,
            QuantityUsed
        )
        VALUES (
            @ProductionOrderID,
            @RawMaterialID,
            @QuantityRequired,
            0
        );
        
        SET @ProductionOrderItemID = SCOPE_IDENTITY();
        
        COMMIT TRANSACTION;
        
        PRINT 'Production Order Item added successfully.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

PRINT 'sp_AddProductionOrderItem created successfully.';
GO

-- ================================================================================
-- 10. UPDATE PRODUCTION ORDER ITEM
-- ================================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_UpdateProductionOrderItem')
    DROP PROCEDURE sp_UpdateProductionOrderItem;
GO

CREATE PROCEDURE sp_UpdateProductionOrderItem
    @ProductionOrderItemID INT,
    @RawMaterialID INT = NULL,
    @QuantityRequired DECIMAL(18,2) = NULL,
    @QuantityUsed DECIMAL(18,2) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validate item exists
        IF NOT EXISTS (SELECT 1 FROM ProductionOrderItem WHERE ProductionOrderItemID = @ProductionOrderItemID)
        BEGIN
            RAISERROR('Production Order Item not found.', 16, 1);
            RETURN;
        END
        
        -- Validate raw material exists if provided
        IF @RawMaterialID IS NOT NULL 
           AND NOT EXISTS (SELECT 1 FROM RawMaterial WHERE RawMaterialID = @RawMaterialID)
        BEGIN
            RAISERROR('Raw Material not found.', 16, 1);
            RETURN;
        END
        
        -- Update Production Order Item
        UPDATE ProductionOrderItem
        SET 
            RawMaterialID = ISNULL(@RawMaterialID, RawMaterialID),
            QuantityRequired = ISNULL(@QuantityRequired, QuantityRequired),
            QuantityUsed = ISNULL(@QuantityUsed, QuantityUsed)
        WHERE ProductionOrderItemID = @ProductionOrderItemID;
        
        COMMIT TRANSACTION;
        
        PRINT 'Production Order Item updated successfully.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

PRINT 'sp_UpdateProductionOrderItem created successfully.';
GO

-- ================================================================================
-- 11. DELETE PRODUCTION ORDER ITEM
-- ================================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_DeleteProductionOrderItem')
    DROP PROCEDURE sp_DeleteProductionOrderItem;
GO

CREATE PROCEDURE sp_DeleteProductionOrderItem
    @ProductionOrderItemID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validate item exists
        IF NOT EXISTS (SELECT 1 FROM ProductionOrderItem WHERE ProductionOrderItemID = @ProductionOrderItemID)
        BEGIN
            RAISERROR('Production Order Item not found.', 16, 1);
            RETURN;
        END
        
        -- Delete Production Order Item
        DELETE FROM ProductionOrderItem WHERE ProductionOrderItemID = @ProductionOrderItemID;
        
        COMMIT TRANSACTION;
        
        PRINT 'Production Order Item deleted successfully.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

PRINT 'sp_DeleteProductionOrderItem created successfully.';
GO

-- ================================================================================
-- STORED PROCEDURES CREATION COMPLETE!
-- ================================================================================
PRINT '';
PRINT '========================================';
PRINT 'PRODUCTION ORDER MANAGEMENT PROCEDURES CREATED SUCCESSFULLY!';
PRINT 'Total Procedures: 11';
PRINT '';
PRINT 'Procedures Created:';
PRINT '1. sp_GetAllProductionOrders - Get all production orders with details';
PRINT '2. sp_GetProductionOrderById - Get single production order';
PRINT '3. sp_CreateProductionOrder - Create new production order';
PRINT '4. sp_UpdateProductionOrder - Update existing production order';
PRINT '5. sp_DeleteProductionOrder - Delete production order';
PRINT '6. sp_SearchProductionOrders - Search/filter production orders';
PRINT '7. sp_GetProductionOrderStatistics - Get dashboard statistics';
PRINT '8. sp_GetProductionOrderItems - Get items for a production order';
PRINT '9. sp_AddProductionOrderItem - Add raw material to production order';
PRINT '10. sp_UpdateProductionOrderItem - Update production order item';
PRINT '11. sp_DeleteProductionOrderItem - Delete production order item';
PRINT '';
PRINT 'KEY FEATURES:';
PRINT '- Production orders created by Tailors (not salespersons)';
PRINT '- Products our company manufactures';
PRINT '- Raw material tracking through ProductionOrderItems';
PRINT '- Status tracking: Pending, InProgress, Completed, Cancelled';
PRINT '- Priority levels: Low, Normal, High, Urgent';
PRINT '';
PRINT 'Next Step: Execute this script in SSMS';
PRINT 'Then we will create the ProductionOrderDataService in C#.';
PRINT '========================================';
GO
