-- ================================================================================
-- STOCK USAGE MANAGEMENT - STORED PROCEDURES
-- ================================================================================
-- Execute this script in SQL Server Management Studio (SSMS)
-- Make sure you're connected to GarmentsFactoryDB database
-- This tracks raw material consumption by tailors on production orders
-- ================================================================================

USE GarmentsFactoryDB;
GO

-- ================================================================================
-- 1. GET ALL STOCK USAGE RECORDS (For Browse/History)
-- ================================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetAllStockUsage')
    DROP PROCEDURE sp_GetAllStockUsage;
GO

CREATE PROCEDURE sp_GetAllStockUsage
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        su.StockUsageID,
        su.EmployeeID,
        (e.FirstName + ' ' + e.LastName) AS EmployeeName,
        su.ProductionOrderID,
        po.ProductionOrderID AS OrderNumber,
        su.RawMaterialID,
        rm.MaterialName,
        rm.Category AS MaterialCategory,
        rm.Unit,
        su.QuantityUsed,
        (su.QuantityUsed * rm.UnitPrice) AS TotalCost,
        su.UsageDate,
        su.Notes
    FROM StockUsage su
    INNER JOIN Employee e ON su.EmployeeID = e.EmployeeID
    INNER JOIN ProductionOrder po ON su.ProductionOrderID = po.ProductionOrderID
    INNER JOIN RawMaterial rm ON su.RawMaterialID = rm.RawMaterialID
    ORDER BY su.UsageDate DESC;
END
GO

PRINT 'sp_GetAllStockUsage created successfully.';
GO

-- ================================================================================
-- 2. GET STOCK USAGE BY ID
-- ================================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetStockUsageById')
    DROP PROCEDURE sp_GetStockUsageById;
GO

CREATE PROCEDURE sp_GetStockUsageById
    @StockUsageID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        su.StockUsageID,
        su.EmployeeID,
        (e.FirstName + ' ' + e.LastName) AS EmployeeName,
        su.ProductionOrderID,
        po.ProductionOrderID AS OrderNumber,
        su.RawMaterialID,
        rm.MaterialName,
        rm.Category AS MaterialCategory,
        rm.Unit,
        su.QuantityUsed,
        (su.QuantityUsed * rm.UnitPrice) AS TotalCost,
        su.UsageDate,
        su.Notes
    FROM StockUsage su
    INNER JOIN Employee e ON su.EmployeeID = e.EmployeeID
    INNER JOIN ProductionOrder po ON su.ProductionOrderID = po.ProductionOrderID
    INNER JOIN RawMaterial rm ON su.RawMaterialID = rm.RawMaterialID
    WHERE su.StockUsageID = @StockUsageID;
END
GO

PRINT 'sp_GetStockUsageById created successfully.';
GO

-- ================================================================================
-- 3. RECORD STOCK USAGE (Tailor uses materials)
-- ================================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_RecordStockUsage')
    DROP PROCEDURE sp_RecordStockUsage;
GO

CREATE PROCEDURE sp_RecordStockUsage
    @EmployeeID INT,
    @ProductionOrderID INT,
    @RawMaterialID INT,
    @QuantityUsed DECIMAL(18,2),
    @Notes NVARCHAR(500) = NULL,
    @StockUsageID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validate employee exists and is a tailor
        IF NOT EXISTS (SELECT 1 FROM Employee e 
                      INNER JOIN EmployeeRole r ON e.RoleID = r.RoleID 
                      WHERE e.EmployeeID = @EmployeeID AND r.RoleName = 'Tailor')
        BEGIN
            RAISERROR('Employee not found or is not a tailor.', 16, 1);
            RETURN;
        END
        
        -- Validate production order exists
        IF NOT EXISTS (SELECT 1 FROM ProductionOrder WHERE ProductionOrderID = @ProductionOrderID)
        BEGIN
            RAISERROR('Production order not found.', 16, 1);
            RETURN;
        END
        
        -- Validate raw material exists and is active
        IF NOT EXISTS (SELECT 1 FROM RawMaterial WHERE RawMaterialID = @RawMaterialID AND IsActive = 1)
        BEGIN
            RAISERROR('Raw material not found or is inactive.', 16, 1);
            RETURN;
        END
        
        -- Validate quantity
        IF @QuantityUsed <= 0
        BEGIN
            RAISERROR('Quantity used must be greater than zero.', 16, 1);
            RETURN;
        END
        
        -- Check if sufficient stock is available
        DECLARE @AvailableQuantity DECIMAL(18,2);
        SELECT @AvailableQuantity = Quantity 
        FROM RawMaterial 
        WHERE RawMaterialID = @RawMaterialID;
        
        IF @AvailableQuantity < @QuantityUsed
        BEGIN
            DECLARE @ErrorMsg NVARCHAR(200);
            SET @ErrorMsg = 'Insufficient stock. Available: ' + CAST(@AvailableQuantity AS NVARCHAR(20)) + 
                          ', Required: ' + CAST(@QuantityUsed AS NVARCHAR(20));
            RAISERROR(@ErrorMsg, 16, 1);
            RETURN;
        END
        
        -- Record stock usage
        INSERT INTO StockUsage (
            EmployeeID,
            ProductionOrderID,
            RawMaterialID,
            QuantityUsed,
            UsageDate,
            Notes
        )
        VALUES (
            @EmployeeID,
            @ProductionOrderID,
            @RawMaterialID,
            @QuantityUsed,
            GETDATE(),
            @Notes
        );
        
        SET @StockUsageID = SCOPE_IDENTITY();
        
        -- Deduct quantity from raw material stock
        UPDATE RawMaterial
        SET Quantity = Quantity - @QuantityUsed,
            UpdatedDate = GETDATE()
        WHERE RawMaterialID = @RawMaterialID;
        
        COMMIT TRANSACTION;
        
        PRINT 'Stock usage recorded successfully. ID: ' + CAST(@StockUsageID AS NVARCHAR);
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

PRINT 'sp_RecordStockUsage created successfully.';
GO

-- ================================================================================
-- 4. GET STOCK USAGE BY PRODUCTION ORDER
-- ================================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetStockUsageByProductionOrder')
    DROP PROCEDURE sp_GetStockUsageByProductionOrder;
GO

CREATE PROCEDURE sp_GetStockUsageByProductionOrder
    @ProductionOrderID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        su.StockUsageID,
        su.EmployeeID,
        (e.FirstName + ' ' + e.LastName) AS EmployeeName,
        su.RawMaterialID,
        rm.MaterialName,
        rm.Category AS MaterialCategory,
        rm.Unit,
        su.QuantityUsed,
        (su.QuantityUsed * rm.UnitPrice) AS TotalCost,
        su.UsageDate,
        su.Notes
    FROM StockUsage su
    INNER JOIN Employee e ON su.EmployeeID = e.EmployeeID
    INNER JOIN RawMaterial rm ON su.RawMaterialID = rm.RawMaterialID
    WHERE su.ProductionOrderID = @ProductionOrderID
    ORDER BY su.UsageDate DESC;
END
GO

PRINT 'sp_GetStockUsageByProductionOrder created successfully.';
GO

-- ================================================================================
-- 5. GET STOCK USAGE BY EMPLOYEE (Tailor)
-- ================================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetStockUsageByEmployee')
    DROP PROCEDURE sp_GetStockUsageByEmployee;
GO

CREATE PROCEDURE sp_GetStockUsageByEmployee
    @EmployeeID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        su.StockUsageID,
        su.ProductionOrderID,
        po.ProductionOrderID AS OrderNumber,
        su.RawMaterialID,
        rm.MaterialName,
        rm.Category AS MaterialCategory,
        rm.Unit,
        su.QuantityUsed,
        (su.QuantityUsed * rm.UnitPrice) AS TotalCost,
        su.UsageDate,
        su.Notes
    FROM StockUsage su
    INNER JOIN ProductionOrder po ON su.ProductionOrderID = po.ProductionOrderID
    INNER JOIN RawMaterial rm ON su.RawMaterialID = rm.RawMaterialID
    WHERE su.EmployeeID = @EmployeeID
    ORDER BY su.UsageDate DESC;
END
GO

PRINT 'sp_GetStockUsageByEmployee created successfully.';
GO

-- ================================================================================
-- 6. GET STOCK USAGE BY MATERIAL
-- ================================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetStockUsageByMaterial')
    DROP PROCEDURE sp_GetStockUsageByMaterial;
GO

CREATE PROCEDURE sp_GetStockUsageByMaterial
    @RawMaterialID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        su.StockUsageID,
        su.EmployeeID,
        (e.FirstName + ' ' + e.LastName) AS EmployeeName,
        su.ProductionOrderID,
        po.ProductionOrderID AS OrderNumber,
        su.QuantityUsed,
        (su.QuantityUsed * rm.UnitPrice) AS TotalCost,
        su.UsageDate,
        su.Notes
    FROM StockUsage su
    INNER JOIN Employee e ON su.EmployeeID = e.EmployeeID
    INNER JOIN ProductionOrder po ON su.ProductionOrderID = po.ProductionOrderID
    INNER JOIN RawMaterial rm ON su.RawMaterialID = rm.RawMaterialID
    WHERE su.RawMaterialID = @RawMaterialID
    ORDER BY su.UsageDate DESC;
END
GO

PRINT 'sp_GetStockUsageByMaterial created successfully.';
GO

-- ================================================================================
-- 7. GET STOCK USAGE STATISTICS
-- ================================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetStockUsageStatistics')
    DROP PROCEDURE sp_GetStockUsageStatistics;
GO

CREATE PROCEDURE sp_GetStockUsageStatistics
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        COUNT(*) AS TotalUsageRecords,
        COUNT(DISTINCT su.EmployeeID) AS TotalTailorsUsed,
        COUNT(DISTINCT su.ProductionOrderID) AS TotalOrdersWithUsage,
        COUNT(DISTINCT su.RawMaterialID) AS TotalMaterialsUsed,
        ISNULL(SUM(su.QuantityUsed * rm.UnitPrice), 0) AS TotalCostOfMaterialsUsed,
        ISNULL(AVG(su.QuantityUsed * rm.UnitPrice), 0) AS AverageCostPerUsage
    FROM StockUsage su
    INNER JOIN RawMaterial rm ON su.RawMaterialID = rm.RawMaterialID;
END
GO

PRINT 'sp_GetStockUsageStatistics created successfully.';
GO

-- ================================================================================
-- 8. DELETE STOCK USAGE RECORD (With stock restoration)
-- ================================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_DeleteStockUsage')
    DROP PROCEDURE sp_DeleteStockUsage;
GO

CREATE PROCEDURE sp_DeleteStockUsage
    @StockUsageID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validate stock usage record exists
        IF NOT EXISTS (SELECT 1 FROM StockUsage WHERE StockUsageID = @StockUsageID)
        BEGIN
            RAISERROR('Stock usage record not found.', 16, 1);
            RETURN;
        END
        
        -- Get the usage details before deletion
        DECLARE @RawMaterialID INT;
        DECLARE @QuantityUsed DECIMAL(18,2);
        
        SELECT @RawMaterialID = RawMaterialID, @QuantityUsed = QuantityUsed
        FROM StockUsage
        WHERE StockUsageID = @StockUsageID;
        
        -- Delete the stock usage record
        DELETE FROM StockUsage WHERE StockUsageID = @StockUsageID;
        
        -- Restore the quantity back to raw material stock
        UPDATE RawMaterial
        SET Quantity = Quantity + @QuantityUsed,
            UpdatedDate = GETDATE()
        WHERE RawMaterialID = @RawMaterialID;
        
        COMMIT TRANSACTION;
        
        PRINT 'Stock usage record deleted and stock restored successfully.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

PRINT 'sp_DeleteStockUsage created successfully.';
GO

-- ================================================================================
-- 9. SEARCH STOCK USAGE RECORDS
-- ================================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_SearchStockUsage')
    DROP PROCEDURE sp_SearchStockUsage;
GO

CREATE PROCEDURE sp_SearchStockUsage
    @SearchTerm NVARCHAR(100) = NULL,
    @EmployeeID INT = NULL,
    @ProductionOrderID INT = NULL,
    @RawMaterialID INT = NULL,
    @StartDate DATETIME = NULL,
    @EndDate DATETIME = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        su.StockUsageID,
        su.EmployeeID,
        (e.FirstName + ' ' + e.LastName) AS EmployeeName,
        su.ProductionOrderID,
        po.ProductionOrderID AS OrderNumber,
        su.RawMaterialID,
        rm.MaterialName,
        rm.Category AS MaterialCategory,
        rm.Unit,
        su.QuantityUsed,
        (su.QuantityUsed * rm.UnitPrice) AS TotalCost,
        su.UsageDate,
        su.Notes
    FROM StockUsage su
    INNER JOIN Employee e ON su.EmployeeID = e.EmployeeID
    INNER JOIN ProductionOrder po ON su.ProductionOrderID = po.ProductionOrderID
    INNER JOIN RawMaterial rm ON su.RawMaterialID = rm.RawMaterialID
    WHERE (@SearchTerm IS NULL OR 
           (e.FirstName + ' ' + e.LastName) LIKE '%' + @SearchTerm + '%' OR
           CAST(po.ProductionOrderID AS NVARCHAR) LIKE '%' + @SearchTerm + '%' OR
           rm.MaterialName LIKE '%' + @SearchTerm + '%' OR
           su.Notes LIKE '%' + @SearchTerm + '%')
        AND (@EmployeeID IS NULL OR su.EmployeeID = @EmployeeID)
        AND (@ProductionOrderID IS NULL OR su.ProductionOrderID = @ProductionOrderID)
        AND (@RawMaterialID IS NULL OR su.RawMaterialID = @RawMaterialID)
        AND (@StartDate IS NULL OR su.UsageDate >= @StartDate)
        AND (@EndDate IS NULL OR su.UsageDate <= @EndDate)
    ORDER BY su.UsageDate DESC;
END
GO

PRINT 'sp_SearchStockUsage created successfully.';
GO

-- ================================================================================
-- 10. CHECK MATERIAL AVAILABILITY FOR PRODUCTION ORDER
-- ================================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_CheckMaterialAvailability')
    DROP PROCEDURE sp_CheckMaterialAvailability;
GO

CREATE PROCEDURE sp_CheckMaterialAvailability
    @RawMaterialID INT,
    @RequiredQuantity DECIMAL(18,2)
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        rm.RawMaterialID,
        rm.MaterialName,
        rm.Category,
        rm.Unit,
        rm.Quantity AS AvailableQuantity,
        @RequiredQuantity AS RequiredQuantity,
        CASE 
            WHEN rm.Quantity >= @RequiredQuantity THEN 'Available'
            WHEN rm.Quantity > 0 THEN 'Insufficient'
            ELSE 'Out of Stock'
        END AS AvailabilityStatus,
        (rm.Quantity - @RequiredQuantity) AS QuantityDifference,
        rm.Supplier,
        rm.SupplierContact
    FROM RawMaterial rm
    WHERE rm.RawMaterialID = @RawMaterialID AND rm.IsActive = 1;
END
GO

PRINT 'sp_CheckMaterialAvailability created successfully.';
GO

-- ================================================================================
-- STORED PROCEDURES CREATION COMPLETE!
-- ================================================================================
PRINT '';
PRINT '========================================';
PRINT 'STOCK USAGE MANAGEMENT PROCEDURES CREATED SUCCESSFULLY!';
PRINT 'Total Procedures: 10';
PRINT '';
PRINT 'Procedures Created:';
PRINT '1. sp_GetAllStockUsage - Get all stock usage records with details';
PRINT '2. sp_GetStockUsageById - Get single usage record';
PRINT '3. sp_RecordStockUsage - Record material consumption (auto-deducts stock)';
PRINT '4. sp_GetStockUsageByProductionOrder - Get materials used for specific order';
PRINT '5. sp_GetStockUsageByEmployee - Get materials used by specific tailor';
PRINT '6. sp_GetStockUsageByMaterial - Get usage history of specific material';
PRINT '7. sp_GetStockUsageStatistics - Get usage statistics for dashboard';
PRINT '8. sp_DeleteStockUsage - Delete usage record (restores stock)';
PRINT '9. sp_SearchStockUsage - Search/filter usage records';
PRINT '10. sp_CheckMaterialAvailability - Check if material is available';
PRINT '';
PRINT 'KEY FEATURES:';
PRINT '- Auto-deducts stock when recording usage';
PRINT '- Validates tailor role and stock availability';
PRINT '- Restores stock when deleting usage records';
PRINT '- Links Employee + ProductionOrder + RawMaterial';
PRINT '- Tracks costs and provides detailed reports';
PRINT '';
PRINT 'Next Steps:';
PRINT '1. Execute this script in SSMS';
PRINT '2. Create StockUsageDataService.cs in C#';
PRINT '3. Integrate with Production Order system';
PRINT '========================================';
GO
