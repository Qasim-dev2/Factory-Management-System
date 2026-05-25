-- =============================================
-- Product Management Procedures (Simplified)
-- =============================================

-- Get All Products
DROP PROCEDURE IF EXISTS sp_GetAllProducts;
GO
CREATE PROCEDURE sp_GetAllProducts
AS
BEGIN
    SELECT 
        ProductID,
        ProductName,
        Description,
        Category,
        Brand,
        SalePrice,
        Material,
        AvailableSizes,
        AvailableColors,
        ProductionStatus,
        SKU,
        IsActive,
        CreatedDate,
        UpdatedDate
    FROM Product
    ORDER BY ProductName;
END
GO

-- Get Product By ID
DROP PROCEDURE IF EXISTS sp_GetProductById;
GO
CREATE PROCEDURE sp_GetProductById
    @ProductID INT
AS
BEGIN
    SELECT 
        ProductID,
        ProductName,
        Description,
        Category,
        Brand,
        SalePrice,
        Material,
        AvailableSizes,
        AvailableColors,
        ProductionStatus,
        SKU,
        IsActive,
        CreatedDate,
        UpdatedDate
    FROM Product
    WHERE ProductID = @ProductID;
END
GO

-- Add Product
DROP PROCEDURE IF EXISTS sp_AddProduct;
GO
CREATE PROCEDURE sp_AddProduct
    @ProductName NVARCHAR(200),
    @Description NVARCHAR(MAX) = NULL,
    @Category NVARCHAR(100) = NULL,
    @Brand NVARCHAR(100) = NULL,
    @SalePrice DECIMAL(18,2) = 0,
    @Material NVARCHAR(100) = NULL,
    @AvailableSizes NVARCHAR(200) = NULL,
    @AvailableColors NVARCHAR(200) = NULL,
    @ProductionStatus NVARCHAR(50) = 'Active',
    @SKU NVARCHAR(50) = NULL,
    @IsActive BIT = 1
AS
BEGIN
    INSERT INTO Product (ProductName, Description, Category, Brand, SalePrice, Material, AvailableSizes, AvailableColors, ProductionStatus, SKU, IsActive)
    VALUES (@ProductName, @Description, @Category, @Brand, @SalePrice, @Material, @AvailableSizes, @AvailableColors, @ProductionStatus, @SKU, @IsActive);
    
    SELECT SCOPE_IDENTITY() AS ProductID;
END
GO

-- Update Product
DROP PROCEDURE IF EXISTS sp_UpdateProduct;
GO
CREATE PROCEDURE sp_UpdateProduct
    @ProductID INT,
    @ProductName NVARCHAR(200),
    @Description NVARCHAR(MAX) = NULL,
    @Category NVARCHAR(100) = NULL,
    @Brand NVARCHAR(100) = NULL,
    @SalePrice DECIMAL(18,2) = 0,
    @Material NVARCHAR(100) = NULL,
    @AvailableSizes NVARCHAR(200) = NULL,
    @AvailableColors NVARCHAR(200) = NULL,
    @ProductionStatus NVARCHAR(50) = 'Active',
    @SKU NVARCHAR(50) = NULL,
    @IsActive BIT = 1
AS
BEGIN
    UPDATE Product
    SET 
        ProductName = @ProductName,
        Description = @Description,
        Category = @Category,
        Brand = @Brand,
        SalePrice = @SalePrice,
        Material = @Material,
        AvailableSizes = @AvailableSizes,
        AvailableColors = @AvailableColors,
        ProductionStatus = @ProductionStatus,
        SKU = @SKU,
        IsActive = @IsActive,
        UpdatedDate = GETDATE()
    WHERE ProductID = @ProductID;
END
GO

-- Delete Product
DROP PROCEDURE IF EXISTS sp_DeleteProduct;
GO
CREATE PROCEDURE sp_DeleteProduct
    @ProductID INT
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        -- Delete related records first to avoid foreign key constraint violations
        DELETE FROM ProductMaterialRequirement WHERE ProductID = @ProductID;
        DELETE FROM DealItem WHERE ProductID = @ProductID;
        DELETE FROM SalesOrderItem WHERE ProductID = @ProductID;
        DELETE FROM TailorAssignment WHERE ProductID = @ProductID;
        DELETE FROM ProductionOrder WHERE ProductID = @ProductID;
        DELETE FROM Stock WHERE ProductID = @ProductID;
        -- Finally delete the product
        DELETE FROM Product WHERE ProductID = @ProductID;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

PRINT 'Product procedures created successfully!';
