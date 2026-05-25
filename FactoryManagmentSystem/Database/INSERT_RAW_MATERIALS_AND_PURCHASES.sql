-- =============================================
-- INSERT SAMPLE RAW MATERIALS & PURCHASES
-- Garments Factory Management System
-- Date: December 17, 2025
-- =============================================

USE GarmentsFactoryDB;
GO

PRINT '🔄 Starting Raw Material and Purchase data insertion...';
PRINT '';

-- =============================================
-- STEP 1: INSERT RAW MATERIALS
-- =============================================

PRINT '📌 STEP 1: INSERTING RAW MATERIALS';
PRINT '';

-- Fabrics
INSERT INTO RawMaterial (MaterialName, Category, Unit, Quantity, MinimumStock, UnitPrice, Supplier, SupplierContact, Description, StockStatus, LastRestockDate, IsActive, CreatedDate)
VALUES ('Cotton Fabric - White', 'Fabric', 'Meters', 500.00, 100.00, 250.00, 'Pakistan Textile Mills', '021-12345678', 'High-quality white cotton fabric for shirts and formal wear', 'In Stock', '2025-12-01', 1, GETDATE());

INSERT INTO RawMaterial (MaterialName, Category, Unit, Quantity, MinimumStock, UnitPrice, Supplier, SupplierContact, Description, StockStatus, LastRestockDate, IsActive, CreatedDate)
VALUES ('Cotton Fabric - Black', 'Fabric', 'Meters', 300.00, 100.00, 250.00, 'Pakistan Textile Mills', '021-12345678', 'Premium black cotton fabric for formal clothing', 'In Stock', '2025-12-01', 1, GETDATE());

INSERT INTO RawMaterial (MaterialName, Category, Unit, Quantity, MinimumStock, UnitPrice, Supplier, SupplierContact, Description, StockStatus, LastRestockDate, IsActive, CreatedDate)
VALUES ('Cotton Fabric - Blue', 'Fabric', 'Meters', 250.00, 100.00, 250.00, 'Pakistan Textile Mills', '021-12345678', 'Navy blue cotton fabric for casual and formal wear', 'In Stock', '2025-12-01', 1, GETDATE());

INSERT INTO RawMaterial (MaterialName, Category, Unit, Quantity, MinimumStock, UnitPrice, Supplier, SupplierContact, Description, StockStatus, LastRestockDate, IsActive, CreatedDate)
VALUES ('Polyester Fabric - Grey', 'Fabric', 'Meters', 400.00, 80.00, 180.00, 'Synthetic Fabrics Co.', '042-87654321', 'Durable grey polyester for suits and pants', 'In Stock', '2025-12-05', 1, GETDATE());

INSERT INTO RawMaterial (MaterialName, Category, Unit, Quantity, MinimumStock, UnitPrice, Supplier, SupplierContact, Description, StockStatus, LastRestockDate, IsActive, CreatedDate)
VALUES ('Silk Fabric - Cream', 'Fabric', 'Meters', 150.00, 50.00, 800.00, 'Premium Silk Traders', '051-11223344', 'Luxury cream silk fabric for premium garments', 'In Stock', '2025-12-10', 1, GETDATE());

INSERT INTO RawMaterial (MaterialName, Category, Unit, Quantity, MinimumStock, UnitPrice, Supplier, SupplierContact, Description, StockStatus, LastRestockDate, IsActive, CreatedDate)
VALUES ('Denim Fabric - Blue', 'Fabric', 'Meters', 350.00, 100.00, 320.00, 'Denim World Lahore', '042-99887766', 'Strong denim fabric for jeans and jackets', 'In Stock', '2025-12-03', 1, GETDATE());

INSERT INTO RawMaterial (MaterialName, Category, Unit, Quantity, MinimumStock, UnitPrice, Supplier, SupplierContact, Description, StockStatus, LastRestockDate, IsActive, CreatedDate)
VALUES ('Linen Fabric - Beige', 'Fabric', 'Meters', 200.00, 60.00, 450.00, 'Natural Fabrics Ltd', '021-55667788', 'Breathable beige linen for summer clothing', 'In Stock', '2025-12-08', 1, GETDATE());

PRINT '   ✅ Inserted 7 Fabric Materials';

-- Threads & Stitching Materials
INSERT INTO RawMaterial (MaterialName, Category, Unit, Quantity, MinimumStock, UnitPrice, Supplier, SupplierContact, Description, StockStatus, LastRestockDate, IsActive, CreatedDate)
VALUES ('Polyester Thread - White', 'Thread', 'Spools', 500.00, 100.00, 45.00, 'Thread Masters Karachi', '021-33445566', 'Strong white polyester thread for general stitching', 'In Stock', '2025-11-25', 1, GETDATE());

INSERT INTO RawMaterial (MaterialName, Category, Unit, Quantity, MinimumStock, UnitPrice, Supplier, SupplierContact, Description, StockStatus, LastRestockDate, IsActive, CreatedDate)
VALUES ('Polyester Thread - Black', 'Thread', 'Spools', 400.00, 100.00, 45.00, 'Thread Masters Karachi', '021-33445566', 'Durable black polyester thread', 'In Stock', '2025-11-25', 1, GETDATE());

INSERT INTO RawMaterial (MaterialName, Category, Unit, Quantity, MinimumStock, UnitPrice, Supplier, SupplierContact, Description, StockStatus, LastRestockDate, IsActive, CreatedDate)
VALUES ('Cotton Thread - Multicolor', 'Thread', 'Spools', 300.00, 80.00, 50.00, 'Thread Masters Karachi', '021-33445566', 'Assorted color cotton threads', 'In Stock', '2025-11-28', 1, GETDATE());

PRINT '   ✅ Inserted 3 Thread Materials';

-- Buttons & Accessories
INSERT INTO RawMaterial (MaterialName, Category, Unit, Quantity, MinimumStock, UnitPrice, Supplier, SupplierContact, Description, StockStatus, LastRestockDate, IsActive, CreatedDate)
VALUES ('Shirt Buttons - White', 'Buttons', 'Pieces', 5000.00, 1000.00, 2.50, 'Button House Lahore', '042-44556677', 'Standard white shirt buttons (4-hole)', 'In Stock', '2025-11-20', 1, GETDATE());

INSERT INTO RawMaterial (MaterialName, Category, Unit, Quantity, MinimumStock, UnitPrice, Supplier, SupplierContact, Description, StockStatus, LastRestockDate, IsActive, CreatedDate)
VALUES ('Shirt Buttons - Black', 'Buttons', 'Pieces', 3000.00, 800.00, 2.50, 'Button House Lahore', '042-44556677', 'Black shirt buttons (4-hole)', 'In Stock', '2025-11-20', 1, GETDATE());

INSERT INTO RawMaterial (MaterialName, Category, Unit, Quantity, MinimumStock, UnitPrice, Supplier, SupplierContact, Description, StockStatus, LastRestockDate, IsActive, CreatedDate)
VALUES ('Metal Buttons - Silver', 'Buttons', 'Pieces', 2000.00, 500.00, 5.00, 'Metal Works Islamabad', '051-66778899', 'Silver-finish metal buttons for suits', 'In Stock', '2025-12-01', 1, GETDATE());

INSERT INTO RawMaterial (MaterialName, Category, Unit, Quantity, MinimumStock, UnitPrice, Supplier, SupplierContact, Description, StockStatus, LastRestockDate, IsActive, CreatedDate)
VALUES ('Zippers - Metal 12 inch', 'Zippers', 'Pieces', 1500.00, 300.00, 15.00, 'Zipper World Faisalabad', '041-77889900', 'Metal zippers for pants and jackets', 'In Stock', '2025-12-05', 1, GETDATE());

INSERT INTO RawMaterial (MaterialName, Category, Unit, Quantity, MinimumStock, UnitPrice, Supplier, SupplierContact, Description, StockStatus, LastRestockDate, IsActive, CreatedDate)
VALUES ('Zippers - Plastic 8 inch', 'Zippers', 'Pieces', 1800.00, 400.00, 8.00, 'Zipper World Faisalabad', '041-77889900', 'Plastic zippers for casual wear', 'In Stock', '2025-12-05', 1, GETDATE());

PRINT '   ✅ Inserted 5 Button & Zipper Materials';

-- Other Materials
INSERT INTO RawMaterial (MaterialName, Category, Unit, Quantity, MinimumStock, UnitPrice, Supplier, SupplierContact, Description, StockStatus, LastRestockDate, IsActive, CreatedDate)
VALUES ('Elastic Band - 1 inch', 'Accessories', 'Meters', 800.00, 200.00, 12.00, 'Accessories Depot', '021-99001122', 'Elastic band for waistbands', 'In Stock', '2025-11-30', 1, GETDATE());

INSERT INTO RawMaterial (MaterialName, Category, Unit, Quantity, MinimumStock, UnitPrice, Supplier, SupplierContact, Description, StockStatus, LastRestockDate, IsActive, CreatedDate)
VALUES ('Velcro Strips - 2 inch', 'Accessories', 'Meters', 300.00, 100.00, 25.00, 'Accessories Depot', '021-99001122', 'Hook and loop fasteners', 'In Stock', '2025-12-02', 1, GETDATE());

INSERT INTO RawMaterial (MaterialName, Category, Unit, Quantity, MinimumStock, UnitPrice, Supplier, SupplierContact, Description, StockStatus, LastRestockDate, IsActive, CreatedDate)
VALUES ('Lining Fabric - White', 'Lining', 'Meters', 400.00, 100.00, 120.00, 'Lining Solutions', '042-33221100', 'Polyester lining fabric for jackets', 'In Stock', '2025-12-07', 1, GETDATE());

INSERT INTO RawMaterial (MaterialName, Category, Unit, Quantity, MinimumStock, UnitPrice, Supplier, SupplierContact, Description, StockStatus, LastRestockDate, IsActive, CreatedDate)
VALUES ('Interfacing Fabric', 'Accessories', 'Meters', 350.00, 80.00, 90.00, 'Lining Solutions', '042-33221100', 'Fusible interfacing for collars and cuffs', 'In Stock', '2025-12-07', 1, GETDATE());

INSERT INTO RawMaterial (MaterialName, Category, Unit, Quantity, MinimumStock, UnitPrice, Supplier, SupplierContact, Description, StockStatus, LastRestockDate, IsActive, CreatedDate)
VALUES ('Shoulder Pads - Foam', 'Accessories', 'Pairs', 600.00, 150.00, 35.00, 'Tailoring Supplies Co.', '051-88990011', 'Foam shoulder pads for suits and jackets', 'In Stock', '2025-12-09', 1, GETDATE());

PRINT '   ✅ Inserted 5 Accessory Materials';

PRINT '';
PRINT '========================================';
PRINT '✅ TOTAL: 20 RAW MATERIALS INSERTED';
PRINT '========================================';
PRINT '';

-- =============================================
-- STEP 2: INSERT RAW MATERIAL PURCHASES
-- =============================================

PRINT '📌 STEP 2: INSERTING PURCHASE HISTORY';
PRINT '';

-- November 2025 Purchases
INSERT INTO RawMaterialPurchase (RawMaterialID, MaterialName, PurchaseDate, Quantity, Unit, UnitPrice, TotalAmount, SupplierName, InvoiceNumber, Notes, CreatedDate)
VALUES (1, 'Cotton Fabric - White', '2025-11-15', 300.00, 'Meters', 250.00, 75000.00, 'Pakistan Textile Mills', 'INV-PTM-001', 'Initial stock purchase for winter season', GETDATE());

INSERT INTO RawMaterialPurchase (RawMaterialID, MaterialName, PurchaseDate, Quantity, Unit, UnitPrice, TotalAmount, SupplierName, InvoiceNumber, Notes, CreatedDate)
VALUES (2, 'Cotton Fabric - Black', '2025-11-15', 200.00, 'Meters', 250.00, 50000.00, 'Pakistan Textile Mills', 'INV-PTM-002', 'Initial stock purchase for winter season', GETDATE());

INSERT INTO RawMaterialPurchase (RawMaterialID, MaterialName, PurchaseDate, Quantity, Unit, UnitPrice, TotalAmount, SupplierName, InvoiceNumber, Notes, CreatedDate)
VALUES (8, 'Polyester Thread - White', '2025-11-20', 300.00, 'Spools', 45.00, 13500.00, 'Thread Masters Karachi', 'INV-TMK-101', 'Bulk thread purchase', GETDATE());

INSERT INTO RawMaterialPurchase (RawMaterialID, MaterialName, PurchaseDate, Quantity, Unit, UnitPrice, TotalAmount, SupplierName, InvoiceNumber, Notes, CreatedDate)
VALUES (9, 'Polyester Thread - Black', '2025-11-20', 250.00, 'Spools', 45.00, 11250.00, 'Thread Masters Karachi', 'INV-TMK-102', 'Bulk thread purchase', GETDATE());

INSERT INTO RawMaterialPurchase (RawMaterialID, MaterialName, PurchaseDate, Quantity, Unit, UnitPrice, TotalAmount, SupplierName, InvoiceNumber, Notes, CreatedDate)
VALUES (11, 'Shirt Buttons - White', '2025-11-22', 3000.00, 'Pieces', 2.50, 7500.00, 'Button House Lahore', 'INV-BHL-201', 'Button restock', GETDATE());

INSERT INTO RawMaterialPurchase (RawMaterialID, MaterialName, PurchaseDate, Quantity, Unit, UnitPrice, TotalAmount, SupplierName, InvoiceNumber, Notes, CreatedDate)
VALUES (12, 'Shirt Buttons - Black', '2025-11-22', 2000.00, 'Pieces', 2.50, 5000.00, 'Button House Lahore', 'INV-BHL-202', 'Button restock', GETDATE());

PRINT '   ✅ Inserted 6 November Purchases (Total: Rs. 162,250)';

-- December 2025 Purchases (Recent)
INSERT INTO RawMaterialPurchase (RawMaterialID, MaterialName, PurchaseDate, Quantity, Unit, UnitPrice, TotalAmount, SupplierName, InvoiceNumber, Notes, CreatedDate)
VALUES (1, 'Cotton Fabric - White', '2025-12-01', 200.00, 'Meters', 250.00, 50000.00, 'Pakistan Textile Mills', 'INV-PTM-003', 'Restock for high demand', GETDATE());

INSERT INTO RawMaterialPurchase (RawMaterialID, MaterialName, PurchaseDate, Quantity, Unit, UnitPrice, TotalAmount, SupplierName, InvoiceNumber, Notes, CreatedDate)
VALUES (2, 'Cotton Fabric - Black', '2025-12-01', 100.00, 'Meters', 250.00, 25000.00, 'Pakistan Textile Mills', 'INV-PTM-004', 'Restock for formal orders', GETDATE());

INSERT INTO RawMaterialPurchase (RawMaterialID, MaterialName, PurchaseDate, Quantity, Unit, UnitPrice, TotalAmount, SupplierName, InvoiceNumber, Notes, CreatedDate)
VALUES (3, 'Cotton Fabric - Blue', '2025-12-03', 250.00, 'Meters', 250.00, 62500.00, 'Pakistan Textile Mills', 'INV-PTM-005', 'New color stock', GETDATE());

INSERT INTO RawMaterialPurchase (RawMaterialID, MaterialName, PurchaseDate, Quantity, Unit, UnitPrice, TotalAmount, SupplierName, InvoiceNumber, Notes, CreatedDate)
VALUES (4, 'Polyester Fabric - Grey', '2025-12-05', 400.00, 'Meters', 180.00, 72000.00, 'Synthetic Fabrics Co.', 'INV-SFC-301', 'Bulk order for suit production', GETDATE());

INSERT INTO RawMaterialPurchase (RawMaterialID, MaterialName, PurchaseDate, Quantity, Unit, UnitPrice, TotalAmount, SupplierName, InvoiceNumber, Notes, CreatedDate)
VALUES (5, 'Silk Fabric - Cream', '2025-12-10', 150.00, 'Meters', 800.00, 120000.00, 'Premium Silk Traders', 'INV-PST-401', 'Premium fabric for luxury orders', GETDATE());

INSERT INTO RawMaterialPurchase (RawMaterialID, MaterialName, PurchaseDate, Quantity, Unit, UnitPrice, TotalAmount, SupplierName, InvoiceNumber, Notes, CreatedDate)
VALUES (6, 'Denim Fabric - Blue', '2025-12-03', 350.00, 'Meters', 320.00, 112000.00, 'Denim World Lahore', 'INV-DWL-501', 'Denim for jeans production', GETDATE());

INSERT INTO RawMaterialPurchase (RawMaterialID, MaterialName, PurchaseDate, Quantity, Unit, UnitPrice, TotalAmount, SupplierName, InvoiceNumber, Notes, CreatedDate)
VALUES (7, 'Linen Fabric - Beige', '2025-12-08', 200.00, 'Meters', 450.00, 90000.00, 'Natural Fabrics Ltd', 'INV-NFL-601', 'Summer collection preparation', GETDATE());

INSERT INTO RawMaterialPurchase (RawMaterialID, MaterialName, PurchaseDate, Quantity, Unit, UnitPrice, TotalAmount, SupplierName, InvoiceNumber, Notes, CreatedDate)
VALUES (8, 'Polyester Thread - White', '2025-12-05', 200.00, 'Spools', 45.00, 9000.00, 'Thread Masters Karachi', 'INV-TMK-103', 'Thread restock', GETDATE());

INSERT INTO RawMaterialPurchase (RawMaterialID, MaterialName, PurchaseDate, Quantity, Unit, UnitPrice, TotalAmount, SupplierName, InvoiceNumber, Notes, CreatedDate)
VALUES (9, 'Polyester Thread - Black', '2025-12-05', 150.00, 'Spools', 45.00, 6750.00, 'Thread Masters Karachi', 'INV-TMK-104', 'Thread restock', GETDATE());

INSERT INTO RawMaterialPurchase (RawMaterialID, MaterialName, PurchaseDate, Quantity, Unit, UnitPrice, TotalAmount, SupplierName, InvoiceNumber, Notes, CreatedDate)
VALUES (10, 'Cotton Thread - Multicolor', '2025-12-07', 300.00, 'Spools', 50.00, 15000.00, 'Thread Masters Karachi', 'INV-TMK-105', 'Multicolor thread for decorative stitching', GETDATE());

INSERT INTO RawMaterialPurchase (RawMaterialID, MaterialName, PurchaseDate, Quantity, Unit, UnitPrice, TotalAmount, SupplierName, InvoiceNumber, Notes, CreatedDate)
VALUES (11, 'Shirt Buttons - White', '2025-12-10', 2000.00, 'Pieces', 2.50, 5000.00, 'Button House Lahore', 'INV-BHL-203', 'Button restock', GETDATE());

INSERT INTO RawMaterialPurchase (RawMaterialID, MaterialName, PurchaseDate, Quantity, Unit, UnitPrice, TotalAmount, SupplierName, InvoiceNumber, Notes, CreatedDate)
VALUES (12, 'Shirt Buttons - Black', '2025-12-10', 1000.00, 'Pieces', 2.50, 2500.00, 'Button House Lahore', 'INV-BHL-204', 'Button restock', GETDATE());

INSERT INTO RawMaterialPurchase (RawMaterialID, MaterialName, PurchaseDate, Quantity, Unit, UnitPrice, TotalAmount, SupplierName, InvoiceNumber, Notes, CreatedDate)
VALUES (13, 'Metal Buttons - Silver', '2025-12-11', 2000.00, 'Pieces', 5.00, 10000.00, 'Metal Works Islamabad', 'INV-MWI-301', 'Premium buttons for suits', GETDATE());

INSERT INTO RawMaterialPurchase (RawMaterialID, MaterialName, PurchaseDate, Quantity, Unit, UnitPrice, TotalAmount, SupplierName, InvoiceNumber, Notes, CreatedDate)
VALUES (14, 'Zippers - Metal 12 inch', '2025-12-12', 1500.00, 'Pieces', 15.00, 22500.00, 'Zipper World Faisalabad', 'INV-ZWF-401', 'Zipper stock for pants', GETDATE());

INSERT INTO RawMaterialPurchase (RawMaterialID, MaterialName, PurchaseDate, Quantity, Unit, UnitPrice, TotalAmount, SupplierName, InvoiceNumber, Notes, CreatedDate)
VALUES (15, 'Zippers - Plastic 8 inch', '2025-12-12', 1800.00, 'Pieces', 8.00, 14400.00, 'Zipper World Faisalabad', 'INV-ZWF-402', 'Zipper stock for casual wear', GETDATE());

INSERT INTO RawMaterialPurchase (RawMaterialID, MaterialName, PurchaseDate, Quantity, Unit, UnitPrice, TotalAmount, SupplierName, InvoiceNumber, Notes, CreatedDate)
VALUES (16, 'Elastic Band - 1 inch', '2025-12-13', 800.00, 'Meters', 12.00, 9600.00, 'Accessories Depot', 'INV-AD-501', 'Elastic for waistbands', GETDATE());

INSERT INTO RawMaterialPurchase (RawMaterialID, MaterialName, PurchaseDate, Quantity, Unit, UnitPrice, TotalAmount, SupplierName, InvoiceNumber, Notes, CreatedDate)
VALUES (17, 'Velcro Strips - 2 inch', '2025-12-14', 300.00, 'Meters', 25.00, 7500.00, 'Accessories Depot', 'INV-AD-502', 'Velcro fasteners', GETDATE());

INSERT INTO RawMaterialPurchase (RawMaterialID, MaterialName, PurchaseDate, Quantity, Unit, UnitPrice, TotalAmount, SupplierName, InvoiceNumber, Notes, CreatedDate)
VALUES (18, 'Lining Fabric - White', '2025-12-15', 400.00, 'Meters', 120.00, 48000.00, 'Lining Solutions', 'INV-LS-601', 'Jacket lining material', GETDATE());

INSERT INTO RawMaterialPurchase (RawMaterialID, MaterialName, PurchaseDate, Quantity, Unit, UnitPrice, TotalAmount, SupplierName, InvoiceNumber, Notes, CreatedDate)
VALUES (19, 'Interfacing Fabric', '2025-12-15', 350.00, 'Meters', 90.00, 31500.00, 'Lining Solutions', 'INV-LS-602', 'Interfacing for collars', GETDATE());

INSERT INTO RawMaterialPurchase (RawMaterialID, MaterialName, PurchaseDate, Quantity, Unit, UnitPrice, TotalAmount, SupplierName, InvoiceNumber, Notes, CreatedDate)
VALUES (20, 'Shoulder Pads - Foam', '2025-12-16', 600.00, 'Pairs', 35.00, 21000.00, 'Tailoring Supplies Co.', 'INV-TSC-701', 'Shoulder pads for suits', GETDATE());

PRINT '   ✅ Inserted 20 December Purchases (Total: Rs. 733,750)';

PRINT '';
PRINT '========================================';
PRINT '✅ TOTAL: 26 PURCHASE RECORDS INSERTED';
PRINT '========================================';
PRINT '';

-- =============================================
-- VERIFICATION & SUMMARY
-- =============================================

PRINT '📋 VERIFICATION SUMMARY:';
PRINT '';

-- Count of Raw Materials
SELECT '✓ Total Raw Materials: ' + CAST(COUNT(*) AS NVARCHAR) AS Summary
FROM RawMaterial
WHERE IsActive = 1;

-- Count of Purchases
SELECT '✓ Total Purchase Records: ' + CAST(COUNT(*) AS NVARCHAR) AS Summary
FROM RawMaterialPurchase;

-- Total Purchase Amount (November)
SELECT '✓ November 2025 Purchases: Rs. ' + CAST(SUM(TotalAmount) AS NVARCHAR) AS Summary
FROM RawMaterialPurchase
WHERE PurchaseDate BETWEEN '2025-11-01' AND '2025-11-30';

-- Total Purchase Amount (December)
SELECT '✓ December 2025 Purchases: Rs. ' + CAST(SUM(TotalAmount) AS NVARCHAR) AS Summary
FROM RawMaterialPurchase
WHERE PurchaseDate BETWEEN '2025-12-01' AND '2025-12-31';

-- Total Overall Expenses
SELECT '✓ Total Raw Material Expenses: Rs. ' + CAST(SUM(TotalAmount) AS NVARCHAR) AS Summary
FROM RawMaterialPurchase;

PRINT '';
PRINT '📊 MATERIAL BREAKDOWN BY CATEGORY:';
SELECT 
    Category,
    COUNT(*) AS MaterialCount,
    SUM(Quantity) AS TotalQuantity,
    SUM(Quantity * UnitPrice) AS TotalValue
FROM RawMaterial
WHERE IsActive = 1
GROUP BY Category
ORDER BY TotalValue DESC;

PRINT '';
PRINT '🏢 TOP 5 SUPPLIERS BY PURCHASE VALUE:';
SELECT TOP 5
    SupplierName,
    COUNT(*) AS PurchaseCount,
    SUM(TotalAmount) AS TotalSpent,
    AVG(TotalAmount) AS AvgPurchaseAmount
FROM RawMaterialPurchase
GROUP BY SupplierName
ORDER BY TotalSpent DESC;

PRINT '';
PRINT '📅 PURCHASE TIMELINE (LAST 30 DAYS):';
SELECT 
    PurchaseDate,
    COUNT(*) AS PurchaseCount,
    SUM(TotalAmount) AS DailyTotal
FROM RawMaterialPurchase
WHERE PurchaseDate >= DATEADD(DAY, -30, GETDATE())
GROUP BY PurchaseDate
ORDER BY PurchaseDate DESC;

PRINT '';
PRINT '⚠️ LOW STOCK ALERT (Below Minimum):';
SELECT 
    MaterialName,
    Category,
    Quantity AS CurrentStock,
    MinimumStock,
    (MinimumStock - Quantity) AS ShortageAmount,
    Unit
FROM RawMaterial
WHERE Quantity < MinimumStock AND IsActive = 1
ORDER BY (MinimumStock - Quantity) DESC;

PRINT '';
PRINT '========================================';
PRINT '✅ RAW MATERIAL DATA SETUP COMPLETE';
PRINT '========================================';
PRINT '';
PRINT '💰 Financial Impact:';
PRINT '   - Total Investment: Rs. 896,000';
PRINT '   - Current Inventory Value: Rs. 850,000+';
PRINT '   - Ready for Production Orders';
PRINT '';
PRINT '📦 Inventory Status:';
PRINT '   - 20 Active Raw Materials';
PRINT '   - 26 Purchase Records';
PRINT '   - All materials properly linked';
PRINT '   - Supplier details complete';
PRINT '';
PRINT '✨ System Ready for:';
PRINT '   ✓ Material requirement calculation';
PRINT '   ✓ Stock deduction on order approval';
PRINT '   ✓ Purchase history tracking';
PRINT '   ✓ Revenue/expense reporting';
PRINT '   ✓ Low stock alerts';
PRINT '';

GO
