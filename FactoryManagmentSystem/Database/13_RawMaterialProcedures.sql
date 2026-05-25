-- ================================================================================
-- RAW MATERIAL MANAGEMENT - STORED PROCEDURES
-- ================================================================================
-- Execute this script in SQL Server Management Studio (SSMS)
-- Make sure you're connected to GarmentsFactoryDB database
-- Matches RawMaterial table structure from 01_CreateDatabase.sql
-- ================================================================================

USE GarmentsFactoryDB;
GO

-- ================================================================================
-- 1. GET ALL RAW MATERIALS (For Browse Tab)
-- ================================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetAllRawMaterials')
    DROP PROCEDURE sp_GetAllRawMaterials;
GO

CREATE PROCEDURE sp_GetAllRawMaterials
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        RawMaterialID,
        MaterialName,
        Category,
        Unit,
        Quantity,
        MinimumStock,
        UnitPrice,
        Supplier,
        SupplierContact,
        Description,
        -- Calculate Stock Status
        CASE 
            WHEN Quantity <= 0 THEN 'Out of Stock'
            WHEN Quantity <= MinimumStock THEN 'Low Stock'
            ELSE 'In Stock'
        END AS StockStatus,
        -- Calculate Total Value
        (Quantity * UnitPrice) AS TotalValue,
        LastRestockDate,
        IsActive,
        CreatedDate,
        UpdatedDate
    FROM RawMaterial
    WHERE IsActive = 1
    ORDER BY MaterialName;
END
GO

PRINT 'sp_GetAllRawMaterials created successfully.';
GO

-- ================================================================================
-- 2. GET RAW MATERIAL BY ID (For Details/Update)
-- ================================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetRawMaterialById')
    DROP PROCEDURE sp_GetRawMaterialById;
GO

CREATE PROCEDURE sp_GetRawMaterialById
    @RawMaterialID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        RawMaterialID,
        MaterialName,
        Category,
        Unit,
        Quantity,
        MinimumStock,
        UnitPrice,
        Supplier,
        SupplierContact,
        Description,
        CASE 
            WHEN Quantity <= 0 THEN 'Out of Stock'
            WHEN Quantity <= MinimumStock THEN 'Low Stock'
            ELSE 'In Stock'
        END AS StockStatus,
        (Quantity * UnitPrice) AS TotalValue,
        LastRestockDate,
        IsActive,
        CreatedDate,
        UpdatedDate
    FROM RawMaterial
    WHERE RawMaterialID = @RawMaterialID;
END
GO

PRINT 'sp_GetRawMaterialById created successfully.';
GO

-- ================================================================================
-- 3. CREATE RAW MATERIAL (For Add Tab)
-- ================================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_CreateRawMaterial')
    DROP PROCEDURE sp_CreateRawMaterial;
GO

CREATE PROCEDURE sp_CreateRawMaterial
    @MaterialName NVARCHAR(100),
    @Category NVARCHAR(50) = NULL,
    @Unit NVARCHAR(20) = NULL,
    @Quantity DECIMAL(18,2) = 0,
    @MinimumStock DECIMAL(18,2) = 0,
    @UnitPrice DECIMAL(18,2) = 0,
    @Supplier NVARCHAR(100) = NULL,
    @SupplierContact NVARCHAR(100) = NULL,
    @Description NVARCHAR(500) = NULL,
    @RawMaterialID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validate material name
        IF @MaterialName IS NULL OR LTRIM(RTRIM(@MaterialName)) = ''
        BEGIN
            RAISERROR('Material name is required.', 16, 1);
            RETURN;
        END
        
        -- Check for duplicate material name
        IF EXISTS (SELECT 1 FROM RawMaterial WHERE MaterialName = @MaterialName AND IsActive = 1)
        BEGIN
            RAISERROR('Material with this name already exists.', 16, 1);
            RETURN;
        END
        
        -- Insert Raw Material
        INSERT INTO RawMaterial (
            MaterialName,
            Category,
            Unit,
            Quantity,
            MinimumStock,
            UnitPrice,
            Supplier,
            SupplierContact,
            Description,
            LastRestockDate,
            IsActive,
            CreatedDate
        )
        VALUES (
            @MaterialName,
            @Category,
            @Unit,
            @Quantity,
            @MinimumStock,
            @UnitPrice,
            @Supplier,
            @SupplierContact,
            @Description,
            CASE WHEN @Quantity > 0 THEN CAST(GETDATE() AS DATE) ELSE NULL END,
            1,
            GETDATE()
        );
        
        SET @RawMaterialID = SCOPE_IDENTITY();
        
        COMMIT TRANSACTION;
        
        PRINT 'Raw Material created successfully with ID: ' + CAST(@RawMaterialID AS NVARCHAR);
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

PRINT 'sp_CreateRawMaterial created successfully.';
GO

-- ================================================================================
-- 4. UPDATE RAW MATERIAL (For Update Tab)
-- ================================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_UpdateRawMaterial')
    DROP PROCEDURE sp_UpdateRawMaterial;
GO

CREATE PROCEDURE sp_UpdateRawMaterial
    @RawMaterialID INT,
    @MaterialName NVARCHAR(100) = NULL,
    @Category NVARCHAR(50) = NULL,
    @Unit NVARCHAR(20) = NULL,
    @Quantity DECIMAL(18,2) = NULL,
    @MinimumStock DECIMAL(18,2) = NULL,
    @UnitPrice DECIMAL(18,2) = NULL,
    @Supplier NVARCHAR(100) = NULL,
    @SupplierContact NVARCHAR(100) = NULL,
    @Description NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validate raw material exists
        IF NOT EXISTS (SELECT 1 FROM RawMaterial WHERE RawMaterialID = @RawMaterialID)
        BEGIN
            RAISERROR('Raw Material not found.', 16, 1);
            RETURN;
        END
        
        -- Check for duplicate name if updating
        IF @MaterialName IS NOT NULL 
           AND EXISTS (SELECT 1 FROM RawMaterial 
                      WHERE MaterialName = @MaterialName 
                      AND RawMaterialID != @RawMaterialID 
                      AND IsActive = 1)
        BEGIN
            RAISERROR('Another material with this name already exists.', 16, 1);
            RETURN;
        END
        
        DECLARE @OldQuantity DECIMAL(18,2);
        SELECT @OldQuantity = Quantity FROM RawMaterial WHERE RawMaterialID = @RawMaterialID;
        
        -- Update Raw Material
        UPDATE RawMaterial
        SET 
            MaterialName = ISNULL(@MaterialName, MaterialName),
            Category = ISNULL(@Category, Category),
            Unit = ISNULL(@Unit, Unit),
            Quantity = ISNULL(@Quantity, Quantity),
            MinimumStock = ISNULL(@MinimumStock, MinimumStock),
            UnitPrice = ISNULL(@UnitPrice, UnitPrice),
            Supplier = ISNULL(@Supplier, Supplier),
            SupplierContact = ISNULL(@SupplierContact, SupplierContact),
            Description = ISNULL(@Description, Description),
            -- Update restock date if quantity increased
            LastRestockDate = CASE 
                WHEN @Quantity IS NOT NULL AND @Quantity > @OldQuantity 
                THEN CAST(GETDATE() AS DATE)
                ELSE LastRestockDate
            END,
            UpdatedDate = GETDATE()
        WHERE RawMaterialID = @RawMaterialID;
        
        COMMIT TRANSACTION;
        
        PRINT 'Raw Material updated successfully.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

PRINT 'sp_UpdateRawMaterial created successfully.';
GO

-- ================================================================================
-- 5. DELETE RAW MATERIAL (For Delete Tab - Soft Delete)
-- ================================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_DeleteRawMaterial')
    DROP PROCEDURE sp_DeleteRawMaterial;
GO

CREATE PROCEDURE sp_DeleteRawMaterial
    @RawMaterialID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validate raw material exists
        IF NOT EXISTS (SELECT 1 FROM RawMaterial WHERE RawMaterialID = @RawMaterialID)
        BEGIN
            RAISERROR('Raw Material not found.', 16, 1);
            RETURN;
        END
        
        -- Check if material is used in any production orders
        IF EXISTS (SELECT 1 FROM ProductionOrderItem WHERE RawMaterialID = @RawMaterialID)
        BEGIN
            RAISERROR('Cannot delete material that is used in production orders. Please deactivate instead.', 16, 1);
            RETURN;
        END
        
        -- Soft delete (set IsActive = 0)
        UPDATE RawMaterial
        SET IsActive = 0,
            UpdatedDate = GETDATE()
        WHERE RawMaterialID = @RawMaterialID;
        
        COMMIT TRANSACTION;
        
        PRINT 'Raw Material deactivated successfully.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

PRINT 'sp_DeleteRawMaterial created successfully.';
GO

-- ================================================================================
-- 6. SEARCH RAW MATERIALS (For Search/Filter)
-- ================================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_SearchRawMaterials')
    DROP PROCEDURE sp_SearchRawMaterials;
GO

CREATE PROCEDURE sp_SearchRawMaterials
    @SearchTerm NVARCHAR(100) = NULL,
    @Category NVARCHAR(50) = NULL,
    @StockStatus NVARCHAR(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        RawMaterialID,
        MaterialName,
        Category,
        Unit,
        Quantity,
        MinimumStock,
        UnitPrice,
        Supplier,
        CASE 
            WHEN Quantity <= 0 THEN 'Out of Stock'
            WHEN Quantity <= MinimumStock THEN 'Low Stock'
            ELSE 'In Stock'
        END AS StockStatus,
        (Quantity * UnitPrice) AS TotalValue
    FROM RawMaterial
    WHERE IsActive = 1
        AND (@SearchTerm IS NULL OR 
             MaterialName LIKE '%' + @SearchTerm + '%' OR
             Supplier LIKE '%' + @SearchTerm + '%' OR
             Description LIKE '%' + @SearchTerm + '%')
        AND (@Category IS NULL OR Category = @Category)
        AND (@StockStatus IS NULL OR 
             (@StockStatus = 'Out of Stock' AND Quantity <= 0) OR
             (@StockStatus = 'Low Stock' AND Quantity > 0 AND Quantity <= MinimumStock) OR
             (@StockStatus = 'In Stock' AND Quantity > MinimumStock))
    ORDER BY MaterialName;
END
GO

PRINT 'sp_SearchRawMaterials created successfully.';
GO

-- ================================================================================
-- 7. GET RAW MATERIAL STATISTICS (For Dashboard)
-- ================================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetRawMaterialStatistics')
    DROP PROCEDURE sp_GetRawMaterialStatistics;
GO

CREATE PROCEDURE sp_GetRawMaterialStatistics
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        COUNT(*) AS TotalMaterials,
        SUM(CASE WHEN Quantity <= 0 THEN 1 ELSE 0 END) AS OutOfStockCount,
        SUM(CASE WHEN Quantity > 0 AND Quantity <= MinimumStock THEN 1 ELSE 0 END) AS LowStockCount,
        SUM(CASE WHEN Quantity > MinimumStock THEN 1 ELSE 0 END) AS InStockCount,
        ISNULL(SUM(Quantity * UnitPrice), 0) AS TotalStockValue,
        ISNULL(AVG(UnitPrice), 0) AS AverageUnitPrice,
        COUNT(DISTINCT Category) AS TotalCategories,
        COUNT(DISTINCT Supplier) AS TotalSuppliers
    FROM RawMaterial
    WHERE IsActive = 1;
END
GO

PRINT 'sp_GetRawMaterialStatistics created successfully.';
GO

-- ================================================================================
-- 8. RESTOCK RAW MATERIAL (Add quantity to existing stock)
-- ================================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_RestockRawMaterial')
    DROP PROCEDURE sp_RestockRawMaterial;
GO

CREATE PROCEDURE sp_RestockRawMaterial
    @RawMaterialID INT,
    @QuantityToAdd DECIMAL(18,2),
    @NewUnitPrice DECIMAL(18,2) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validate raw material exists
        IF NOT EXISTS (SELECT 1 FROM RawMaterial WHERE RawMaterialID = @RawMaterialID)
        BEGIN
            RAISERROR('Raw Material not found.', 16, 1);
            RETURN;
        END
        
        -- Validate quantity
        IF @QuantityToAdd <= 0
        BEGIN
            RAISERROR('Quantity to add must be greater than zero.', 16, 1);
            RETURN;
        END
        
        -- Update stock
        UPDATE RawMaterial
        SET 
            Quantity = Quantity + @QuantityToAdd,
            UnitPrice = ISNULL(@NewUnitPrice, UnitPrice),
            LastRestockDate = CAST(GETDATE() AS DATE),
            UpdatedDate = GETDATE()
        WHERE RawMaterialID = @RawMaterialID;
        
        COMMIT TRANSACTION;
        
        PRINT 'Raw Material restocked successfully.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

PRINT 'sp_RestockRawMaterial created successfully.';
GO

-- ================================================================================
-- STORED PROCEDURES CREATION COMPLETE!
-- ================================================================================
PRINT '';
PRINT '========================================';
PRINT 'RAW MATERIAL MANAGEMENT PROCEDURES CREATED SUCCESSFULLY!';
PRINT 'Total Procedures: 8';
PRINT '';
PRINT 'Procedures Created:';
PRINT '1. sp_GetAllRawMaterials - Get all raw materials with calculated fields';
PRINT '2. sp_GetRawMaterialById - Get single raw material details';
PRINT '3. sp_CreateRawMaterial - Create new raw material';
PRINT '4. sp_UpdateRawMaterial - Update existing raw material';
PRINT '5. sp_DeleteRawMaterial - Soft delete raw material';
PRINT '6. sp_SearchRawMaterials - Search/filter raw materials';
PRINT '7. sp_GetRawMaterialStatistics - Get dashboard statistics';
PRINT '8. sp_RestockRawMaterial - Add quantity to existing stock';
PRINT '';
PRINT 'KEY FEATURES:';
PRINT '- Auto-calculate stock status (In Stock, Low Stock, Out of Stock)';
PRINT '- Auto-update restock dates when quantity increases';
PRINT '- Prevent deletion if material used in production orders';
PRINT '- Track total stock value and supplier information';
PRINT '';
PRINT 'Next Step: Execute this script in SSMS';
PRINT 'Then we will create the RawMaterialDataService in C#.';
PRINT '========================================';
GO
