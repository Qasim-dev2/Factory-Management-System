-- =============================================
-- INSERT SAMPLE PRODUCTS & MATERIAL REQUIREMENTS
-- Garments Factory Management System
-- Date: December 17, 2025
-- =============================================

USE GarmentsFactoryDB;
GO

PRINT '🔄 Starting Products and Material Requirements insertion...';
PRINT '';

-- =============================================
-- STEP 1: INSERT PRODUCTS
-- =============================================

PRINT '📌 STEP 1: INSERTING PRODUCTS';
PRINT '';

-- Shirts
INSERT INTO Product (ProductName, Description, Category, Brand, SalePrice, Material, AvailableSizes, AvailableColors, ProductionStatus, SKU, IsActive, CreatedDate)
VALUES ('Formal Shirt - White', 'Premium white formal shirt with full sleeves, perfect for office and formal events', 'Shirts', 'Elite Garments', 1200.00, 'Cotton', 'S,M,L,XL,XXL', 'White', 'Active', 'SKU-SHIRT-WHT-001', 1, GETDATE());

INSERT INTO Product (ProductName, Description, Category, Brand, SalePrice, Material, AvailableSizes, AvailableColors, ProductionStatus, SKU, IsActive, CreatedDate)
VALUES ('Formal Shirt - Black', 'Premium black formal shirt with full sleeves, elegant design', 'Shirts', 'Elite Garments', 1200.00, 'Cotton', 'S,M,L,XL,XXL', 'Black', 'Active', 'SKU-SHIRT-BLK-002', 1, GETDATE());

INSERT INTO Product (ProductName, Description, Category, Brand, SalePrice, Material, AvailableSizes, AvailableColors, ProductionStatus, SKU, IsActive, CreatedDate)
VALUES ('Casual Shirt - Blue', 'Stylish navy blue casual shirt with modern fit', 'Shirts', 'Elite Garments', 1000.00, 'Cotton', 'S,M,L,XL,XXL', 'Blue', 'Active', 'SKU-SHIRT-BLU-003', 1, GETDATE());

PRINT '   ✅ Inserted 3 Shirts';

-- Pants/Trousers
INSERT INTO Product (ProductName, Description, Category, Brand, SalePrice, Material, AvailableSizes, AvailableColors, ProductionStatus, SKU, IsActive, CreatedDate)
VALUES ('Formal Trousers - Grey', 'Classic grey formal trousers with perfect tailoring', 'Pants', 'Elite Garments', 1500.00, 'Polyester', '28,30,32,34,36,38,40', 'Grey', 'Active', 'SKU-PANT-GRY-001', 1, GETDATE());

INSERT INTO Product (ProductName, Description, Category, Brand, SalePrice, Material, AvailableSizes, AvailableColors, ProductionStatus, SKU, IsActive, CreatedDate)
VALUES ('Formal Trousers - Black', 'Premium black formal trousers for office wear', 'Pants', 'Elite Garments', 1500.00, 'Polyester', '28,30,32,34,36,38,40', 'Black', 'Active', 'SKU-PANT-BLK-002', 1, GETDATE());

INSERT INTO Product (ProductName, Description, Category, Brand, SalePrice, Material, AvailableSizes, AvailableColors, ProductionStatus, SKU, IsActive, CreatedDate)
VALUES ('Denim Jeans - Blue', 'Classic blue denim jeans with modern fit', 'Pants', 'Elite Garments', 1800.00, 'Denim', '28,30,32,34,36,38,40', 'Blue', 'Active', 'SKU-JEAN-BLU-001', 1, GETDATE());

PRINT '   ✅ Inserted 3 Pants/Trousers';

-- Suits
INSERT INTO Product (ProductName, Description, Category, Brand, SalePrice, Material, AvailableSizes, AvailableColors, ProductionStatus, SKU, IsActive, CreatedDate)
VALUES ('Two-Piece Suit - Grey', 'Complete grey two-piece suit with jacket and trousers', 'Suits', 'Elite Garments', 5500.00, 'Polyester', 'S,M,L,XL,XXL', 'Grey', 'Active', 'SKU-SUIT-GRY-001', 1, GETDATE());

INSERT INTO Product (ProductName, Description, Category, Brand, SalePrice, Material, AvailableSizes, AvailableColors, ProductionStatus, SKU, IsActive, CreatedDate)
VALUES ('Two-Piece Suit - Black', 'Premium black two-piece suit for formal occasions', 'Suits', 'Elite Garments', 5500.00, 'Polyester', 'S,M,L,XL,XXL', 'Black', 'Active', 'SKU-SUIT-BLK-002', 1, GETDATE());

PRINT '   ✅ Inserted 2 Suits';

-- Summer Collection
INSERT INTO Product (ProductName, Description, Category, Brand, SalePrice, Material, AvailableSizes, AvailableColors, ProductionStatus, SKU, IsActive, CreatedDate)
VALUES ('Linen Shirt - Beige', 'Breathable beige linen shirt for summer', 'Shirts', 'Elite Garments', 1400.00, 'Linen', 'S,M,L,XL,XXL', 'Beige', 'Active', 'SKU-SHIRT-LIN-001', 1, GETDATE());

INSERT INTO Product (ProductName, Description, Category, Brand, SalePrice, Material, AvailableSizes, AvailableColors, ProductionStatus, SKU, IsActive, CreatedDate)
VALUES ('Premium Silk Shirt - Cream', 'Luxury cream silk shirt for special occasions', 'Shirts', 'Elite Garments', 2500.00, 'Silk', 'S,M,L,XL,XXL', 'Cream', 'Active', 'SKU-SHIRT-SILK-001', 1, GETDATE());

PRINT '   ✅ Inserted 2 Premium Shirts';

PRINT '';
PRINT '========================================';
PRINT '✅ TOTAL: 10 PRODUCTS INSERTED';
PRINT '========================================';
PRINT '';

-- =============================================
-- STEP 2: INSERT PRODUCT MATERIAL REQUIREMENTS
-- =============================================

PRINT '📌 STEP 2: INSERTING MATERIAL REQUIREMENTS';
PRINT '';

-- Product 1: Formal Shirt - White
INSERT INTO ProductMaterialRequirement (ProductID, RawMaterialID, QuantityRequired, Unit, Notes, CreatedDate)
VALUES (1, 3, 2.50, 'Meters', 'Cotton fabric for shirt body and sleeves', GETDATE());

INSERT INTO ProductMaterialRequirement (ProductID, RawMaterialID, QuantityRequired, Unit, Notes, CreatedDate)
VALUES (1, 13, 8, 'Pieces', 'White buttons for front placket and cuffs', GETDATE());

INSERT INTO ProductMaterialRequirement (ProductID, RawMaterialID, QuantityRequired, Unit, Notes, CreatedDate)
VALUES (1, 10, 1, 'Spools', 'White thread for stitching', GETDATE());

INSERT INTO ProductMaterialRequirement (ProductID, RawMaterialID, QuantityRequired, Unit, Notes, CreatedDate)
VALUES (1, 21, 0.30, 'Meters', 'Interfacing for collar and cuffs', GETDATE());

PRINT '   ✅ Product 1: Formal Shirt - White (4 materials)';

-- Product 2: Formal Shirt - Black
INSERT INTO ProductMaterialRequirement (ProductID, RawMaterialID, QuantityRequired, Unit, Notes, CreatedDate)
VALUES (2, 4, 2.50, 'Meters', 'Cotton fabric for shirt body and sleeves', GETDATE());

INSERT INTO ProductMaterialRequirement (ProductID, RawMaterialID, QuantityRequired, Unit, Notes, CreatedDate)
VALUES (2, 14, 8, 'Pieces', 'Black buttons for front placket and cuffs', GETDATE());

INSERT INTO ProductMaterialRequirement (ProductID, RawMaterialID, QuantityRequired, Unit, Notes, CreatedDate)
VALUES (2, 11, 1, 'Spools', 'Black thread for stitching', GETDATE());

INSERT INTO ProductMaterialRequirement (ProductID, RawMaterialID, QuantityRequired, Unit, Notes, CreatedDate)
VALUES (2, 21, 0.30, 'Meters', 'Interfacing for collar and cuffs', GETDATE());

PRINT '   ✅ Product 2: Formal Shirt - Black (4 materials)';

-- Product 3: Casual Shirt - Blue
INSERT INTO ProductMaterialRequirement (ProductID, RawMaterialID, QuantityRequired, Unit, Notes, CreatedDate)
VALUES (3, 5, 2.50, 'Meters', 'Blue cotton fabric for shirt', GETDATE());

INSERT INTO ProductMaterialRequirement (ProductID, RawMaterialID, QuantityRequired, Unit, Notes, CreatedDate)
VALUES (3, 13, 8, 'Pieces', 'White buttons (standard for blue shirts)', GETDATE());

INSERT INTO ProductMaterialRequirement (ProductID, RawMaterialID, QuantityRequired, Unit, Notes, CreatedDate)
VALUES (3, 10, 1, 'Spools', 'Thread for stitching', GETDATE());

INSERT INTO ProductMaterialRequirement (ProductID, RawMaterialID, QuantityRequired, Unit, Notes, CreatedDate)
VALUES (3, 21, 0.30, 'Meters', 'Interfacing for collar', GETDATE());

PRINT '   ✅ Product 3: Casual Shirt - Blue (4 materials)';

-- Product 4: Formal Trousers - Grey
INSERT INTO ProductMaterialRequirement (ProductID, RawMaterialID, QuantityRequired, Unit, Notes, CreatedDate)
VALUES (4, 6, 2.00, 'Meters', 'Grey polyester fabric for trousers', GETDATE());

INSERT INTO ProductMaterialRequirement (ProductID, RawMaterialID, QuantityRequired, Unit, Notes, CreatedDate)
VALUES (4, 16, 1, 'Pieces', 'Metal zipper for fly', GETDATE());

INSERT INTO ProductMaterialRequirement (ProductID, RawMaterialID, QuantityRequired, Unit, Notes, CreatedDate)
VALUES (4, 10, 1, 'Spools', 'Thread for stitching', GETDATE());

INSERT INTO ProductMaterialRequirement (ProductID, RawMaterialID, QuantityRequired, Unit, Notes, CreatedDate)
VALUES (4, 18, 0.50, 'Meters', 'Elastic band for waistband', GETDATE());

INSERT INTO ProductMaterialRequirement (ProductID, RawMaterialID, QuantityRequired, Unit, Notes, CreatedDate)
VALUES (4, 15, 2, 'Pieces', 'Metal buttons for waist closure', GETDATE());

PRINT '   ✅ Product 4: Formal Trousers - Grey (5 materials)';

-- Product 5: Formal Trousers - Black
INSERT INTO ProductMaterialRequirement (ProductID, RawMaterialID, QuantityRequired, Unit, Notes, CreatedDate)
VALUES (5, 4, 2.00, 'Meters', 'Black cotton fabric for trousers', GETDATE());

INSERT INTO ProductMaterialRequirement (ProductID, RawMaterialID, QuantityRequired, Unit, Notes, CreatedDate)
VALUES (5, 16, 1, 'Pieces', 'Metal zipper for fly', GETDATE());

INSERT INTO ProductMaterialRequirement (ProductID, RawMaterialID, QuantityRequired, Unit, Notes, CreatedDate)
VALUES (5, 11, 1, 'Spools', 'Black thread for stitching', GETDATE());

INSERT INTO ProductMaterialRequirement (ProductID, RawMaterialID, QuantityRequired, Unit, Notes, CreatedDate)
VALUES (5, 18, 0.50, 'Meters', 'Elastic band for waistband', GETDATE());

INSERT INTO ProductMaterialRequirement (ProductID, RawMaterialID, QuantityRequired, Unit, Notes, CreatedDate)
VALUES (5, 15, 2, 'Pieces', 'Metal buttons for waist closure', GETDATE());

PRINT '   ✅ Product 5: Formal Trousers - Black (5 materials)';

-- Product 6: Denim Jeans - Blue
INSERT INTO ProductMaterialRequirement (ProductID, RawMaterialID, QuantityRequired, Unit, Notes, CreatedDate)
VALUES (6, 8, 2.20, 'Meters', 'Blue denim fabric for jeans', GETDATE());

INSERT INTO ProductMaterialRequirement (ProductID, RawMaterialID, QuantityRequired, Unit, Notes, CreatedDate)
VALUES (6, 16, 1, 'Pieces', 'Metal zipper for fly', GETDATE());

INSERT INTO ProductMaterialRequirement (ProductID, RawMaterialID, QuantityRequired, Unit, Notes, CreatedDate)
VALUES (6, 10, 1, 'Spools', 'Thread for stitching', GETDATE());

INSERT INTO ProductMaterialRequirement (ProductID, RawMaterialID, QuantityRequired, Unit, Notes, CreatedDate)
VALUES (6, 15, 5, 'Pieces', 'Metal buttons and rivets', GETDATE());

PRINT '   ✅ Product 6: Denim Jeans - Blue (4 materials)';

-- Product 7: Two-Piece Suit - Grey
INSERT INTO ProductMaterialRequirement (ProductID, RawMaterialID, QuantityRequired, Unit, Notes, CreatedDate)
VALUES (7, 6, 4.50, 'Meters', 'Grey polyester fabric for jacket and pants', GETDATE());

INSERT INTO ProductMaterialRequirement (ProductID, RawMaterialID, QuantityRequired, Unit, Notes, CreatedDate)
VALUES (7, 20, 2.00, 'Meters', 'White lining fabric for jacket', GETDATE());

INSERT INTO ProductMaterialRequirement (ProductID, RawMaterialID, QuantityRequired, Unit, Notes, CreatedDate)
VALUES (7, 15, 6, 'Pieces', 'Silver metal buttons for jacket', GETDATE());

INSERT INTO ProductMaterialRequirement (ProductID, RawMaterialID, QuantityRequired, Unit, Notes, CreatedDate)
VALUES (7, 16, 1, 'Pieces', 'Metal zipper for pants', GETDATE());

INSERT INTO ProductMaterialRequirement (ProductID, RawMaterialID, QuantityRequired, Unit, Notes, CreatedDate)
VALUES (7, 22, 1, 'Pairs', 'Shoulder pads for jacket structure', GETDATE());

INSERT INTO ProductMaterialRequirement (ProductID, RawMaterialID, QuantityRequired, Unit, Notes, CreatedDate)
VALUES (7, 10, 2, 'Spools', 'Thread for stitching', GETDATE());

INSERT INTO ProductMaterialRequirement (ProductID, RawMaterialID, QuantityRequired, Unit, Notes, CreatedDate)
VALUES (7, 21, 0.50, 'Meters', 'Interfacing for lapels and collar', GETDATE());

PRINT '   ✅ Product 7: Two-Piece Suit - Grey (7 materials)';

-- Product 8: Two-Piece Suit - Black
INSERT INTO ProductMaterialRequirement (ProductID, RawMaterialID, QuantityRequired, Unit, Notes, CreatedDate)
VALUES (8, 4, 4.50, 'Meters', 'Black cotton fabric for jacket and pants', GETDATE());

INSERT INTO ProductMaterialRequirement (ProductID, RawMaterialID, QuantityRequired, Unit, Notes, CreatedDate)
VALUES (8, 20, 2.00, 'Meters', 'White lining fabric for jacket', GETDATE());

INSERT INTO ProductMaterialRequirement (ProductID, RawMaterialID, QuantityRequired, Unit, Notes, CreatedDate)
VALUES (8, 15, 6, 'Pieces', 'Silver metal buttons for jacket', GETDATE());

INSERT INTO ProductMaterialRequirement (ProductID, RawMaterialID, QuantityRequired, Unit, Notes, CreatedDate)
VALUES (8, 16, 1, 'Pieces', 'Metal zipper for pants', GETDATE());

INSERT INTO ProductMaterialRequirement (ProductID, RawMaterialID, QuantityRequired, Unit, Notes, CreatedDate)
VALUES (8, 22, 1, 'Pairs', 'Shoulder pads for jacket structure', GETDATE());

INSERT INTO ProductMaterialRequirement (ProductID, RawMaterialID, QuantityRequired, Unit, Notes, CreatedDate)
VALUES (8, 11, 2, 'Spools', 'Black thread for stitching', GETDATE());

INSERT INTO ProductMaterialRequirement (ProductID, RawMaterialID, QuantityRequired, Unit, Notes, CreatedDate)
VALUES (8, 21, 0.50, 'Meters', 'Interfacing for lapels and collar', GETDATE());

PRINT '   ✅ Product 8: Two-Piece Suit - Black (7 materials)';

-- Product 9: Linen Shirt - Beige
INSERT INTO ProductMaterialRequirement (ProductID, RawMaterialID, QuantityRequired, Unit, Notes, CreatedDate)
VALUES (9, 9, 2.50, 'Meters', 'Beige linen fabric for shirt', GETDATE());

INSERT INTO ProductMaterialRequirement (ProductID, RawMaterialID, QuantityRequired, Unit, Notes, CreatedDate)
VALUES (9, 13, 8, 'Pieces', 'White buttons for shirt', GETDATE());

INSERT INTO ProductMaterialRequirement (ProductID, RawMaterialID, QuantityRequired, Unit, Notes, CreatedDate)
VALUES (9, 12, 1, 'Spools', 'Cotton thread for stitching', GETDATE());

INSERT INTO ProductMaterialRequirement (ProductID, RawMaterialID, QuantityRequired, Unit, Notes, CreatedDate)
VALUES (9, 21, 0.30, 'Meters', 'Interfacing for collar', GETDATE());

PRINT '   ✅ Product 9: Linen Shirt - Beige (4 materials)';

-- Product 10: Premium Silk Shirt - Cream
INSERT INTO ProductMaterialRequirement (ProductID, RawMaterialID, QuantityRequired, Unit, Notes, CreatedDate)
VALUES (10, 7, 2.50, 'Meters', 'Cream silk fabric for premium shirt', GETDATE());

INSERT INTO ProductMaterialRequirement (ProductID, RawMaterialID, QuantityRequired, Unit, Notes, CreatedDate)
VALUES (10, 13, 8, 'Pieces', 'White buttons for shirt', GETDATE());

INSERT INTO ProductMaterialRequirement (ProductID, RawMaterialID, QuantityRequired, Unit, Notes, CreatedDate)
VALUES (10, 12, 1, 'Spools', 'Cotton thread for delicate stitching', GETDATE());

INSERT INTO ProductMaterialRequirement (ProductID, RawMaterialID, QuantityRequired, Unit, Notes, CreatedDate)
VALUES (10, 21, 0.30, 'Meters', 'Interfacing for collar', GETDATE());

PRINT '   ✅ Product 10: Premium Silk Shirt - Cream (4 materials)';

PRINT '';
PRINT '========================================';
PRINT '✅ TOTAL: 48 MATERIAL REQUIREMENTS INSERTED';
PRINT '========================================';
PRINT '';

-- =============================================
-- VERIFICATION & SUMMARY
-- =============================================

PRINT '📋 VERIFICATION SUMMARY:';
PRINT '';

-- Count Products
SELECT '✓ Total Products: ' + CAST(COUNT(*) AS NVARCHAR) AS Summary
FROM Product
WHERE IsActive = 1;

-- Count Requirements
SELECT '✓ Total Material Requirements: ' + CAST(COUNT(*) AS NVARCHAR) AS Summary
FROM ProductMaterialRequirement;

PRINT '';
PRINT '📊 PRODUCTS BY CATEGORY:';
SELECT 
    Category,
    COUNT(*) AS ProductCount,
    MIN(SalePrice) AS MinPrice,
    MAX(SalePrice) AS MaxPrice,
    AVG(SalePrice) AS AvgPrice
FROM Product
WHERE IsActive = 1
GROUP BY Category
ORDER BY Category;

PRINT '';
PRINT '📦 MATERIAL REQUIREMENTS PER PRODUCT:';
SELECT 
    p.ProductID,
    p.ProductName,
    p.Category,
    p.SalePrice,
    COUNT(pmr.RequirementID) AS MaterialCount,
    STRING_AGG(rm.MaterialName, ', ') AS RequiredMaterials
FROM Product p
LEFT JOIN ProductMaterialRequirement pmr ON p.ProductID = pmr.ProductID
LEFT JOIN RawMaterial rm ON pmr.RawMaterialID = rm.RawMaterialID
WHERE p.IsActive = 1
GROUP BY p.ProductID, p.ProductName, p.Category, p.SalePrice
ORDER BY p.ProductID;

PRINT '';
PRINT '🔍 DETAILED REQUIREMENTS (SAMPLE - Product 1):';
SELECT 
    p.ProductName,
    rm.MaterialName,
    pmr.QuantityRequired,
    pmr.Unit,
    pmr.Notes
FROM ProductMaterialRequirement pmr
JOIN Product p ON pmr.ProductID = p.ProductID
JOIN RawMaterial rm ON pmr.RawMaterialID = rm.RawMaterialID
WHERE pmr.ProductID = 1;

PRINT '';
PRINT '💰 ESTIMATED MATERIAL COST PER PRODUCT:';
SELECT 
    p.ProductID,
    p.ProductName,
    p.SalePrice,
    SUM(pmr.QuantityRequired * rm.UnitPrice) AS EstimatedMaterialCost,
    (p.SalePrice - SUM(pmr.QuantityRequired * rm.UnitPrice)) AS EstimatedProfit,
    CAST((((p.SalePrice - SUM(pmr.QuantityRequired * rm.UnitPrice)) / p.SalePrice) * 100) AS DECIMAL(5,2)) AS ProfitMarginPercent
FROM Product p
JOIN ProductMaterialRequirement pmr ON p.ProductID = pmr.ProductID
JOIN RawMaterial rm ON pmr.RawMaterialID = rm.RawMaterialID
WHERE p.IsActive = 1
GROUP BY p.ProductID, p.ProductName, p.SalePrice
ORDER BY EstimatedProfit DESC;

PRINT '';
PRINT '⚠️ PRODUCTS WITHOUT MATERIAL REQUIREMENTS (Should be 0):';
SELECT 
    p.ProductID,
    p.ProductName,
    p.Category
FROM Product p
LEFT JOIN ProductMaterialRequirement pmr ON p.ProductID = pmr.ProductID
WHERE p.IsActive = 1 AND pmr.RequirementID IS NULL;

PRINT '';
PRINT '========================================';
PRINT '✅ PRODUCT DATA SETUP COMPLETE';
PRINT '========================================';
PRINT '';
PRINT '📦 Product Summary:';
PRINT '   - 10 Products Added';
PRINT '   - Categories: Shirts (5), Pants (3), Suits (2)';
PRINT '   - Price Range: Rs. 1,000 - Rs. 5,500';
PRINT '   - All products linked to materials ✓';
PRINT '';
PRINT '🔗 Material Requirements:';
PRINT '   - 48 Total Requirements';
PRINT '   - Average 4-7 materials per product';
PRINT '   - All properly linked to RawMaterial table ✓';
PRINT '';
PRINT '✨ System Ready for:';
PRINT '   ✓ Order creation with product selection';
PRINT '   ✓ Material requirement calculation';
PRINT '   ✓ Stock validation before approval';
PRINT '   ✓ Production costing analysis';
PRINT '   ✓ Profit margin tracking';
PRINT '';

GO
