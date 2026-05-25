-- ================================================================================
-- PRODUCT MATERIAL REQUIREMENT (BILL OF MATERIALS - BOM)
-- ================================================================================
-- This table defines which raw materials are needed for each product
-- and in what quantities. This is essential for:
-- 1. Automatic material requirement calculation during production orders
-- 2. Automatic stock checks before starting production
-- 3. Automatic stock deduction when recording material usage
-- 4. Material cost calculation for products
-- ================================================================================

USE GarmentsFactoryDB;
GO

-- ================================================================================
-- Step 1: Create the ProductMaterialRequirement Table
-- ================================================================================
PRINT '=== Creating ProductMaterialRequirement Table ===';

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ProductMaterialRequirement')
BEGIN
    CREATE TABLE ProductMaterialRequirement (
        RequirementID INT IDENTITY(1,1) PRIMARY KEY,
        ProductID INT NOT NULL,
        RawMaterialID INT NOT NULL,
        QuantityRequired DECIMAL(18,2) NOT NULL,
        Unit NVARCHAR(50) NOT NULL,
        Notes NVARCHAR(500) NULL,
        CreatedDate DATETIME DEFAULT GETDATE(),
        UpdatedDate DATETIME DEFAULT GETDATE(),
        IsActive BIT DEFAULT 1,

        CONSTRAINT FK_PMR_Product FOREIGN KEY (ProductID)
            REFERENCES Product(ProductID),

        CONSTRAINT FK_PMR_RawMaterial FOREIGN KEY (RawMaterialID)
            REFERENCES RawMaterial(RawMaterialID),

        -- Prevent duplicate entries for same product-material combination
        CONSTRAINT UQ_PMR_Product_Material UNIQUE (ProductID, RawMaterialID)
    );

    PRINT 'ProductMaterialRequirement table created successfully.';
END
ELSE
BEGIN
    PRINT 'ProductMaterialRequirement table already exists.';
END
GO

-- ================================================================================
-- Step 2: Create Stored Procedures for Product Material Requirements
-- ================================================================================

-- Procedure 1: Add Material Requirement for a Product
-- ================================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE name = 'sp_AddProductMaterialRequirement' AND type = 'P')
    DROP PROCEDURE sp_AddProductMaterialRequirement;
GO

CREATE PROCEDURE sp_AddProductMaterialRequirement
    @ProductID INT,
    @RawMaterialID INT,
    @QuantityRequired DECIMAL(18,2),
    @Unit NVARCHAR(50),
    @Notes NVARCHAR(500) = NULL,
    @NewRequirementID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validate Product exists
        IF NOT EXISTS (SELECT 1 FROM Product WHERE ProductID = @ProductID)
        BEGIN
            RAISERROR('Product does not exist.', 16, 1);
            RETURN;
        END

        -- Validate RawMaterial exists
        IF NOT EXISTS (SELECT 1 FROM RawMaterial WHERE RawMaterialID = @RawMaterialID)
        BEGIN
            RAISERROR('Raw Material does not exist.', 16, 1);
            RETURN;
        END

        -- Check if this combination already exists
        IF EXISTS (SELECT 1 FROM ProductMaterialRequirement 
                   WHERE ProductID = @ProductID AND RawMaterialID = @RawMaterialID)
        BEGIN
            RAISERROR('This material is already added to this product. Use Update instead.', 16, 1);
            RETURN;
        END

        -- Insert new requirement
        INSERT INTO ProductMaterialRequirement (
            ProductID, RawMaterialID, QuantityRequired, Unit, Notes
        )
        VALUES (
            @ProductID, @RawMaterialID, @QuantityRequired, @Unit, @Notes
        );

        SET @NewRequirementID = SCOPE_IDENTITY();

        COMMIT TRANSACTION;
        PRINT 'Material requirement added successfully.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

-- Procedure 2: Update Material Requirement
-- ================================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE name = 'sp_UpdateProductMaterialRequirement' AND type = 'P')
    DROP PROCEDURE sp_UpdateProductMaterialRequirement;
GO

CREATE PROCEDURE sp_UpdateProductMaterialRequirement
    @RequirementID INT,
    @QuantityRequired DECIMAL(18,2),
    @Unit NVARCHAR(50),
    @Notes NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Validate requirement exists
        IF NOT EXISTS (SELECT 1 FROM ProductMaterialRequirement WHERE RequirementID = @RequirementID)
        BEGIN
            RAISERROR('Material requirement not found.', 16, 1);
            RETURN;
        END

        UPDATE ProductMaterialRequirement
        SET 
            QuantityRequired = @QuantityRequired,
            Unit = @Unit,
            Notes = @Notes,
            UpdatedDate = GETDATE()
        WHERE RequirementID = @RequirementID;

        PRINT 'Material requirement updated successfully.';
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

-- Procedure 3: Delete Material Requirement
-- ================================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE name = 'sp_DeleteProductMaterialRequirement' AND type = 'P')
    DROP PROCEDURE sp_DeleteProductMaterialRequirement;
GO

CREATE PROCEDURE sp_DeleteProductMaterialRequirement
    @RequirementID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Soft delete by setting IsActive = 0
        UPDATE ProductMaterialRequirement
        SET IsActive = 0, UpdatedDate = GETDATE()
        WHERE RequirementID = @RequirementID;

        PRINT 'Material requirement deleted successfully.';
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

-- Procedure 4: Get All Materials for a Product (Bill of Materials)
-- ================================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE name = 'sp_GetProductMaterials' AND type = 'P')
    DROP PROCEDURE sp_GetProductMaterials;
GO

CREATE PROCEDURE sp_GetProductMaterials
    @ProductID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        pmr.RequirementID,
        pmr.ProductID,
        p.ProductName,
        pmr.RawMaterialID,
        rm.MaterialName,
        rm.Category AS MaterialCategory,
        pmr.QuantityRequired,
        pmr.Unit,
        rm.UnitPrice AS MaterialUnitPrice,
        (pmr.QuantityRequired * rm.UnitPrice) AS TotalMaterialCost,
        rm.Quantity AS AvailableStock,
        CASE 
            WHEN rm.Quantity >= pmr.QuantityRequired THEN 'Available'
            WHEN rm.Quantity > 0 THEN 'Insufficient'
            ELSE 'Out of Stock'
        END AS StockStatus,
        pmr.Notes,
        pmr.CreatedDate,
        pmr.UpdatedDate
    FROM ProductMaterialRequirement pmr
    INNER JOIN Product p ON pmr.ProductID = p.ProductID
    INNER JOIN RawMaterial rm ON pmr.RawMaterialID = rm.RawMaterialID
    WHERE pmr.ProductID = @ProductID AND pmr.IsActive = 1
    ORDER BY rm.MaterialName;
END
GO

-- Procedure 5: Calculate Total Material Requirements for Production Order
-- ================================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE name = 'sp_CalculateProductionOrderMaterialRequirements' AND type = 'P')
    DROP PROCEDURE sp_CalculateProductionOrderMaterialRequirements;
GO

CREATE PROCEDURE sp_CalculateProductionOrderMaterialRequirements
    @ProductID INT,
    @Quantity INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Calculate total materials needed based on product BOM and order quantity
    SELECT 
        pmr.RawMaterialID,
        rm.MaterialName,
        rm.Category,
        pmr.Unit,
        pmr.QuantityRequired AS QuantityPerUnit,
        (pmr.QuantityRequired * @Quantity) AS TotalQuantityRequired,
        rm.Quantity AS AvailableStock,
        CASE 
            WHEN rm.Quantity >= (pmr.QuantityRequired * @Quantity) THEN 'Sufficient'
            WHEN rm.Quantity > 0 THEN 'Insufficient - Need to Order'
            ELSE 'Out of Stock - Must Order'
        END AS StockStatus,
        (rm.Quantity - (pmr.QuantityRequired * @Quantity)) AS StockBalanceAfterProduction,
        rm.UnitPrice,
        ((pmr.QuantityRequired * @Quantity) * rm.UnitPrice) AS TotalMaterialCost
    FROM ProductMaterialRequirement pmr
    INNER JOIN RawMaterial rm ON pmr.RawMaterialID = rm.RawMaterialID
    WHERE pmr.ProductID = @ProductID AND pmr.IsActive = 1
    ORDER BY 
        CASE 
            WHEN rm.Quantity < (pmr.QuantityRequired * @Quantity) THEN 0
            ELSE 1
        END,
        rm.MaterialName;
END
GO

-- Procedure 6: Check if All Materials Available for Production Order
-- ================================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE name = 'sp_CheckMaterialsAvailability' AND type = 'P')
    DROP PROCEDURE sp_CheckMaterialsAvailability;
GO

CREATE PROCEDURE sp_CheckMaterialsAvailability
    @ProductID INT,
    @Quantity INT,
    @AllMaterialsAvailable BIT OUTPUT,
    @MissingMaterialsCount INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Check if all required materials are available in sufficient quantity
    SELECT @MissingMaterialsCount = COUNT(*)
    FROM ProductMaterialRequirement pmr
    INNER JOIN RawMaterial rm ON pmr.RawMaterialID = rm.RawMaterialID
    WHERE pmr.ProductID = @ProductID 
        AND pmr.IsActive = 1
        AND rm.Quantity < (pmr.QuantityRequired * @Quantity);
    
    IF @MissingMaterialsCount = 0
        SET @AllMaterialsAvailable = 1;
    ELSE
        SET @AllMaterialsAvailable = 0;
    
    -- Return detailed availability info
    SELECT 
        rm.RawMaterialID,
        rm.MaterialName,
        (pmr.QuantityRequired * @Quantity) AS RequiredQuantity,
        rm.Quantity AS AvailableStock,
        CASE 
            WHEN rm.Quantity >= (pmr.QuantityRequired * @Quantity) THEN 1
            ELSE 0
        END AS IsAvailable
    FROM ProductMaterialRequirement pmr
    INNER JOIN RawMaterial rm ON pmr.RawMaterialID = rm.RawMaterialID
    WHERE pmr.ProductID = @ProductID AND pmr.IsActive = 1;
END
GO

-- Procedure 7: Get All Product-Material Requirements (Admin View)
-- ================================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE name = 'sp_GetAllProductMaterialRequirements' AND type = 'P')
    DROP PROCEDURE sp_GetAllProductMaterialRequirements;
GO

CREATE PROCEDURE sp_GetAllProductMaterialRequirements
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        pmr.RequirementID,
        pmr.ProductID,
        p.ProductName,
        p.Category AS ProductCategory,
        pmr.RawMaterialID,
        rm.MaterialName,
        rm.Category AS MaterialCategory,
        pmr.QuantityRequired,
        pmr.Unit,
        rm.UnitPrice,
        (pmr.QuantityRequired * rm.UnitPrice) AS CostPerUnit,
        rm.Quantity AS CurrentStock,
        pmr.Notes,
        pmr.CreatedDate
    FROM ProductMaterialRequirement pmr
    INNER JOIN Product p ON pmr.ProductID = p.ProductID
    INNER JOIN RawMaterial rm ON pmr.RawMaterialID = rm.RawMaterialID
    WHERE pmr.IsActive = 1
    ORDER BY p.ProductName, rm.MaterialName;
END
GO

-- ================================================================================
-- Step 3: Verify Installation
-- ================================================================================
PRINT '';
PRINT '=== Verification: Product Material Requirements ===';
SELECT COUNT(*) AS TotalRequirements FROM ProductMaterialRequirement WHERE IsActive = 1;
GO

PRINT '';
PRINT '========================================';
PRINT 'PRODUCT MATERIAL REQUIREMENT SYSTEM SETUP COMPLETE!';
PRINT '';
PRINT 'What you can do now:';
PRINT '1. Add material requirements when creating/editing products';
PRINT '2. System will auto-calculate materials needed for production orders';
PRINT '3. System will check material availability before starting production';
PRINT '4. Accurate cost calculation for each product';
PRINT '';
PRINT 'Next: Integrate with C# application (Phase 3)';
PRINT '========================================';
