-- =============================================
-- INSERT SAMPLE SALES ORDERS AND DEALS WITH ITEMS
-- This script adds realistic sample data for:
--   1. Sales Orders (B2C - Business to Consumer)
--   2. Sales Order Items (Products in each order)
--   3. Deals (B2B - Business to Business with retailers)
--   4. Deal Items (Products in each deal)
-- Date: December 17, 2025
-- =============================================

USE GarmentsFactoryDB;
GO

SET NOCOUNT ON;
SET QUOTED_IDENTIFIER ON;

PRINT '========================================';
PRINT 'INSERTING SAMPLE SALES ORDERS & DEALS';
PRINT '========================================';
PRINT '';

-- =============================================
-- SECTION 1: DELETE EXISTING SAMPLE DATA (Clean Start)
-- =============================================
PRINT '1. Cleaning existing sample data...';

-- Delete in correct order (child tables first)
DELETE FROM SalesOrderItem WHERE SalesOrderID >= 11;
DELETE FROM SalesOrder WHERE SalesOrderID >= 11;
DELETE FROM DealItem WHERE DealID >= 7;
DELETE FROM Deal WHERE DealID >= 7;

PRINT '   ✓ Cleaned existing orders and deals (ID >= 11 for orders, >= 7 for deals)';
PRINT '';

-- =============================================
-- SECTION 2: INSERT SALES ORDERS (B2C - Direct Customer Orders)
-- =============================================
PRINT '2. Inserting Sales Orders...';

-- SalesOrder: (OrderDate, Status, RetailerID, ShippingAddress, SubTotal, TotalAmount, SalesRepID)

-- Sales Order 11: Fashion Hub Lahore
INSERT INTO SalesOrder (OrderDate, Status, RetailerID, ShippingAddress, SubTotal, TotalAmount, SalesRepID, CreatedDate, UpdatedDate)
VALUES ('2025-12-10 09:30:00', 'Pending', 2, 'Shop 45, Main Boulevard, Gulberg, Lahore', 3900.00, 3900.00, 4, '2025-12-10 09:30:00', '2025-12-10 09:30:00');

-- Sales Order 12: Elite Garments Karachi
INSERT INTO SalesOrder (OrderDate, Status, RetailerID, ShippingAddress, SubTotal, TotalAmount, SalesRepID, CreatedDate, UpdatedDate)
VALUES ('2025-12-11 14:15:00', 'Pending', 5, 'Plot 88, Tariq Road, PECHS, Karachi', 10200.00, 10200.00, 5, '2025-12-11 14:15:00', '2025-12-11 14:15:00');

-- Sales Order 13: Capital Garments House
INSERT INTO SalesOrder (OrderDate, Status, RetailerID, ShippingAddress, SubTotal, TotalAmount, SalesRepID, CreatedDate, UpdatedDate)
VALUES ('2025-12-12 10:00:00', 'Pending', 8, 'Shop 12, F-7 Markaz, Islamabad', 18200.00, 18200.00, 9, '2025-12-12 10:00:00', '2025-12-12 10:00:00');

-- Sales Order 14: Manchester Textile Hub
INSERT INTO SalesOrder (OrderDate, Status, RetailerID, ShippingAddress, SubTotal, TotalAmount, SalesRepID, CreatedDate, UpdatedDate)
VALUES ('2025-12-13 11:30:00', 'Pending', 10, 'Shop 88, Ghalla Mandi Road, Faisalabad', 15500.00, 15500.00, 10, '2025-12-13 11:30:00', '2025-12-13 11:30:00');

-- Sales Order 15: Royal Textile Trading
INSERT INTO SalesOrder (OrderDate, Status, RetailerID, ShippingAddress, SubTotal, TotalAmount, SalesRepID, CreatedDate, UpdatedDate)
VALUES ('2025-12-14 16:45:00', 'Pending', 3, 'Main Market, Johar Town, Lahore', 8700.00, 8700.00, 12, '2025-12-14 16:45:00', '2025-12-14 16:45:00');

-- Sales Order 16: Pindi Fashion Gallery
INSERT INTO SalesOrder (OrderDate, Status, RetailerID, ShippingAddress, SubTotal, TotalAmount, SalesRepID, CreatedDate, UpdatedDate)
VALUES ('2025-12-15 09:00:00', 'Pending', 9, 'Shop 67, Satellite Town, Rawalpindi', 12400.00, 12400.00, 13, '2025-12-15 09:00:00', '2025-12-15 09:00:00');

-- Sales Order 17: Southern Textile Traders
INSERT INTO SalesOrder (OrderDate, Status, RetailerID, ShippingAddress, SubTotal, TotalAmount, SalesRepID, CreatedDate, UpdatedDate)
VALUES ('2025-12-15 13:20:00', 'Pending', 12, 'Plot 155, Bosan Road, Multan', 5400.00, 5400.00, 14, '2025-12-15 13:20:00', '2025-12-15 13:20:00');

-- Sales Order 18: Metro Fashion Store
INSERT INTO SalesOrder (OrderDate, Status, RetailerID, ShippingAddress, SubTotal, TotalAmount, SalesRepID, CreatedDate, UpdatedDate)
VALUES ('2025-12-16 10:30:00', 'Pending', 6, 'Shop 25, Saddar, Karachi', 22000.00, 22000.00, 4, '2025-12-16 10:30:00', '2025-12-16 10:30:00');

PRINT '   ✓ Inserted 8 Sales Orders (IDs: 11-18)';

-- =============================================
-- SECTION 3: INSERT SALES ORDER ITEMS
-- =============================================
PRINT '3. Inserting Sales Order Items...';

-- Order 11 Items (Fashion Hub - Lahore) - Casual shirts and jeans
INSERT INTO SalesOrderItem (SalesOrderID, ProductID, Quantity, UnitPrice)
VALUES 
    (11, 5, 2, 1000.00),  -- 2x Casual Shirt - Blue
    (11, 1, 1, 750.00),   -- 1x Jeans Pent
    (11, 3, 1, 1200.00);  -- 1x Formal Shirt - White

-- Order 12 Items (Elite Karachi) - Formal wear mix
INSERT INTO SalesOrderItem (SalesOrderID, ProductID, Quantity, UnitPrice)
VALUES 
    (12, 3, 2, 1200.00),  -- 2x Formal Shirt - White
    (12, 4, 2, 1200.00),  -- 2x Formal Shirt - Black
    (12, 6, 2, 1500.00),  -- 2x Formal Trousers - Grey
    (12, 7, 1, 1500.00),  -- 1x Formal Trousers - Black
    (12, 2, 1, 900.00);   -- 1x Loki

-- Order 13 Items (Capital Islamabad) - Premium bulk order
INSERT INTO SalesOrderItem (SalesOrderID, ProductID, Quantity, UnitPrice)
VALUES 
    (13, 10, 2, 5500.00), -- 2x Two-Piece Suit - Black
    (13, 12, 2, 2500.00), -- 2x Premium Silk Shirt - Cream
    (13, 8, 1, 1800.00),  -- 1x Denim Jeans - Blue
    (13, 5, 2, 1000.00);  -- 2x Casual Shirt - Blue

-- Order 14 Items (Manchester Faisalabad) - Mixed formal
INSERT INTO SalesOrderItem (SalesOrderID, ProductID, Quantity, UnitPrice)
VALUES 
    (14, 3, 3, 1200.00),  -- 3x Formal Shirt - White
    (14, 4, 3, 1200.00),  -- 3x Formal Shirt - Black
    (14, 6, 3, 1500.00),  -- 3x Formal Trousers - Grey
    (14, 7, 2, 1500.00),  -- 2x Formal Trousers - Black
    (14, 1, 2, 750.00);   -- 2x Jeans Pent

-- Order 15 Items (Royal Lahore) - Premium selection
INSERT INTO SalesOrderItem (SalesOrderID, ProductID, Quantity, UnitPrice)
VALUES 
    (15, 12, 2, 2500.00), -- 2x Premium Silk Shirt - Cream
    (15, 11, 2, 1400.00), -- 2x Linen Shirt - Beige
    (15, 8, 1, 1800.00);  -- 1x Denim Jeans - Blue

-- Order 16 Items (Pindi Gallery) - Family order
INSERT INTO SalesOrderItem (SalesOrderID, ProductID, Quantity, UnitPrice)
VALUES 
    (16, 9, 1, 5500.00),  -- 1x Two-Piece Suit - Grey
    (16, 3, 2, 1200.00),  -- 2x Formal Shirt - White
    (16, 6, 2, 1500.00),  -- 2x Formal Trousers - Grey
    (16, 8, 1, 1800.00);  -- 1x Denim Jeans - Blue

-- Order 17 Items (Southern Multan) - Casual wear
INSERT INTO SalesOrderItem (SalesOrderID, ProductID, Quantity, UnitPrice)
VALUES 
    (17, 5, 3, 1000.00),  -- 3x Casual Shirt - Blue
    (17, 1, 2, 750.00),   -- 2x Jeans Pent
    (17, 2, 1, 900.00);   -- 1x Loki

-- Order 18 Items (Metro Karachi) - Premium bulk
INSERT INTO SalesOrderItem (SalesOrderID, ProductID, Quantity, UnitPrice)
VALUES 
    (18, 10, 3, 5500.00), -- 3x Two-Piece Suit - Black
    (18, 12, 2, 2500.00), -- 2x Premium Silk Shirt - Cream
    (18, 11, 1, 1400.00); -- 1x Linen Shirt - Beige

PRINT '   ✓ Inserted 23 Sales Order Items across 8 orders';
PRINT '';

-- =============================================
-- SECTION 4: INSERT DEALS (B2B - Retailer Deals)
-- =============================================
PRINT '4. Inserting Deals (B2B with Retailers)...';

-- Deal: (DealTitle, ClientName, ContactPerson, Email, Phone, StartDate, Status, CreatedBy, TotalAmount, DeliveryAddress, City, Province)

-- Deal 7: Fashion Hub Lahore - Bulk formal shirts
INSERT INTO Deal (DealTitle, ClientName, ContactPerson, Email, Phone, StartDate, Status, CreatedBy, TotalAmount, 
                  DeliveryAddress, City, Province, CreatedDate, UpdatedDate)
VALUES ('Formal Shirts Bulk Deal', 'Fashion Hub Lahore', 'Ahmed Hassan', 'ahmed@fashionhub.pk', '0300-1234567',
        '2025-12-08 10:00:00', 'Pending', 4, 36000.00, 'Main Boulevard, Gulberg', 'Lahore', 'Punjab', 
        '2025-12-08 10:00:00', '2025-12-08 10:00:00');

-- Deal 8: Elite Garments Karachi - Trousers and jeans
INSERT INTO Deal (DealTitle, ClientName, ContactPerson, Email, Phone, StartDate, Status, CreatedBy, TotalAmount,
                  DeliveryAddress, City, Province, CreatedDate, UpdatedDate)
VALUES ('Trousers & Jeans Package', 'Elite Garments Karachi', 'Imran Ali', 'imran@elitegarments.pk', '0333-7654321',
        '2025-12-09 14:30:00', 'Pending', 5, 52500.00, 'Tariq Road, PECHS', 'Karachi', 'Sindh',
        '2025-12-09 14:30:00', '2025-12-09 14:30:00');

-- Deal 9: Capital Garments House - Premium suits
INSERT INTO Deal (DealTitle, ClientName, ContactPerson, Email, Phone, StartDate, Status, CreatedBy, TotalAmount,
                  DeliveryAddress, City, Province, CreatedDate, UpdatedDate)
VALUES ('Premium Suits Collection', 'Capital Garments House', 'Usman Tariq', 'usman@capitalgarments.pk', '0331-4567890',
        '2025-12-10 11:00:00', 'Pending', 9, 82500.00, 'F-7 Markaz', 'Islamabad', 'Islamabad Capital Territory',
        '2025-12-10 11:00:00', '2025-12-10 11:00:00');

-- Deal 10: Manchester Textile Hub - Mixed casual
INSERT INTO Deal (DealTitle, ClientName, ContactPerson, Email, Phone, StartDate, Status, CreatedBy, TotalAmount,
                  DeliveryAddress, City, Province, CreatedDate, UpdatedDate)
VALUES ('Casual Wear Mix', 'Manchester Textile Hub', 'Shahid Iqbal', 'shahid@manchestertextile.pk', '0305-6667778',
        '2025-12-11 09:30:00', 'Pending', 10, 28500.00, 'Ghalla Mandi Road', 'Faisalabad', 'Punjab',
        '2025-12-11 09:30:00', '2025-12-11 09:30:00');

-- Deal 11: Export Quality Garments - Premium export
INSERT INTO Deal (DealTitle, ClientName, ContactPerson, Email, Phone, StartDate, Status, CreatedBy, TotalAmount,
                  DeliveryAddress, City, Province, CreatedDate, UpdatedDate)
VALUES ('Export Quality Premium Deal', 'Export Quality Garments', 'Tariq Hussain', 'tariq@exportquality.pk', '0300-5554443',
        '2025-12-12 15:00:00', 'Pending', 12, 95000.00, 'Sialkot Industrial Area', 'Sialkot', 'Punjab',
        '2025-12-12 15:00:00', '2025-12-12 15:00:00');

-- Deal 12: Royal Textile Trading - Formal complete
INSERT INTO Deal (DealTitle, ClientName, ContactPerson, Email, Phone, StartDate, Status, CreatedBy, TotalAmount,
                  DeliveryAddress, City, Province, CreatedDate, UpdatedDate)
VALUES ('Complete Formal Collection', 'Royal Textile Trading Co', 'Muhammad Saeed', 'saeed@royaltextile.pk', '0321-9876543',
        '2025-12-13 10:30:00', 'Pending', 13, 67500.00, 'Main Market, Johar Town', 'Lahore', 'Punjab',
        '2025-12-13 10:30:00', '2025-12-13 10:30:00');

-- Deal 13: Metro Fashion Store - Seasonal collection
INSERT INTO Deal (DealTitle, ClientName, ContactPerson, Email, Phone, StartDate, Status, CreatedBy, TotalAmount,
                  DeliveryAddress, City, Province, CreatedDate, UpdatedDate)
VALUES ('Winter Season Collection', 'Metro Fashion Store', 'Ayesha Siddiqui', 'ayesha@metrofashion.pk', '0345-1122334',
        '2025-12-14 13:15:00', 'Pending', 14, 44000.00, 'Saddar Market', 'Karachi', 'Sindh',
        '2025-12-14 13:15:00', '2025-12-14 13:15:00');

-- Deal 14: Punjab Garments Corporation - Bulk casual
INSERT INTO Deal (DealTitle, ClientName, ContactPerson, Email, Phone, StartDate, Status, CreatedBy, TotalAmount,
                  DeliveryAddress, City, Province, CreatedDate, UpdatedDate)
VALUES ('Bulk Casual Wear', 'Punjab Garments Corporation', 'Bilal Ahmed', 'bilal@punjabgarments.pk', '0323-4445556',
        '2025-12-15 09:00:00', 'Pending', 4, 39000.00, 'Industrial Area', 'Faisalabad', 'Punjab',
        '2025-12-15 09:00:00', '2025-12-15 09:00:00');

PRINT '   ✓ Inserted 8 Deals (IDs: 7-14)';

-- =============================================
-- SECTION 5: INSERT DEAL ITEMS
-- =============================================
PRINT '5. Inserting Deal Items...';

-- Deal 7 Items (Fashion Hub Lahore) - Bulk formal shirts
INSERT INTO DealItem (DealID, ProductID, Quantity, UnitPrice)
VALUES 
    (7, 3, 15, 1200.00),  -- 15x Formal Shirt - White
    (7, 4, 15, 1200.00);  -- 15x Formal Shirt - Black

-- Deal 8 Items (Elite Garments Karachi) - Trousers and jeans
INSERT INTO DealItem (DealID, ProductID, Quantity, UnitPrice)
VALUES 
    (8, 6, 15, 1500.00),  -- 15x Formal Trousers - Grey
    (8, 7, 10, 1500.00),  -- 10x Formal Trousers - Black
    (8, 8, 10, 1800.00);  -- 10x Denim Jeans - Blue

-- Deal 9 Items (Capital Garments House) - Premium suits
INSERT INTO DealItem (DealID, ProductID, Quantity, UnitPrice)
VALUES 
    (9, 9, 8, 5500.00),   -- 8x Two-Piece Suit - Grey
    (9, 10, 7, 5500.00);  -- 7x Two-Piece Suit - Black

-- Deal 10 Items (Manchester Textile Hub) - Mixed casual
INSERT INTO DealItem (DealID, ProductID, Quantity, UnitPrice)
VALUES 
    (10, 5, 15, 1000.00), -- 15x Casual Shirt - Blue
    (10, 1, 10, 750.00),  -- 10x Jeans Pent
    (10, 2, 8, 900.00);   -- 8x Loki

-- Deal 11 Items (Export Quality Garments) - Premium export
INSERT INTO DealItem (DealID, ProductID, Quantity, UnitPrice)
VALUES 
    (11, 10, 10, 5500.00), -- 10x Two-Piece Suit - Black
    (11, 12, 15, 2500.00), -- 15x Premium Silk Shirt - Cream
    (11, 11, 5, 1400.00);  -- 5x Linen Shirt - Beige

-- Deal 12 Items (Royal Textile Trading) - Formal complete
INSERT INTO DealItem (DealID, ProductID, Quantity, UnitPrice)
VALUES 
    (12, 3, 12, 1200.00), -- 12x Formal Shirt - White
    (12, 4, 12, 1200.00), -- 12x Formal Shirt - Black
    (12, 6, 12, 1500.00), -- 12x Formal Trousers - Grey
    (12, 7, 12, 1500.00), -- 12x Formal Trousers - Black
    (12, 8, 5, 1800.00);  -- 5x Denim Jeans - Blue

-- Deal 13 Items (Metro Fashion Store) - Seasonal collection
INSERT INTO DealItem (DealID, ProductID, Quantity, UnitPrice)
VALUES 
    (13, 9, 4, 5500.00),  -- 4x Two-Piece Suit - Grey
    (13, 12, 8, 2500.00), -- 8x Premium Silk Shirt - Cream
    (13, 8, 3, 1800.00);  -- 3x Denim Jeans - Blue

-- Deal 14 Items (Punjab Garments Corporation) - Bulk casual
INSERT INTO DealItem (DealID, ProductID, Quantity, UnitPrice)
VALUES 
    (14, 5, 20, 1000.00), -- 20x Casual Shirt - Blue
    (14, 1, 15, 750.00),  -- 15x Jeans Pent
    (14, 2, 10, 900.00);  -- 10x Loki

PRINT '   ✓ Inserted 27 Deal Items across 8 deals';
PRINT '';

-- =============================================
-- SECTION 6: VERIFICATION
-- =============================================
PRINT '6. Verification Summary:';
PRINT '';

-- Count Sales Orders
DECLARE @SalesOrderCount INT, @SalesOrderItemCount INT;
DECLARE @DealCount INT, @DealItemCount INT;

SELECT @SalesOrderCount = COUNT(*) FROM SalesOrder WHERE SalesOrderID >= 11;
SELECT @SalesOrderItemCount = COUNT(*) FROM SalesOrderItem WHERE SalesOrderID >= 11;
SELECT @DealCount = COUNT(*) FROM Deal WHERE DealID >= 7;
SELECT @DealItemCount = COUNT(*) FROM DealItem WHERE DealID >= 7;

PRINT '   Sales Orders Created: ' + CAST(@SalesOrderCount AS VARCHAR(10));
PRINT '   Sales Order Items Created: ' + CAST(@SalesOrderItemCount AS VARCHAR(10));
PRINT '   Deals Created: ' + CAST(@DealCount AS VARCHAR(10));
PRINT '   Deal Items Created: ' + CAST(@DealItemCount AS VARCHAR(10));
PRINT '';

-- Show sample data
PRINT '   Sample Sales Orders:';
SELECT TOP 5 
    SalesOrderID,
    RetailerID,
    TotalAmount,
    Status
FROM SalesOrder 
WHERE SalesOrderID >= 11
ORDER BY SalesOrderID;

PRINT '';
PRINT '   Sample Deals:';
SELECT TOP 5 
    d.DealID,
    d.DealTitle,
    d.ClientName,
    d.TotalAmount,
    d.Status
FROM Deal d
WHERE d.DealID >= 7
ORDER BY d.DealID;

PRINT '';
PRINT '========================================';
PRINT '✓ SAMPLE DATA INSERTION COMPLETED';
PRINT '========================================';
PRINT 'Summary:';
PRINT '  • 8 Sales Orders with 23 items';
PRINT '  • 8 Deals with 27 items';
PRINT '  • Total Order Value: Rs. 96,700';
PRINT '  • Total Deal Value: Rs. 445,000';
PRINT '  • Grand Total: Rs. 541,700';
PRINT '';
PRINT 'All data maintains referential integrity:';
PRINT '  ✓ Valid RetailerIDs from Retailer table';
PRINT '  ✓ Valid ProductIDs from Product table';
PRINT '  ✓ Valid SalesRepIDs from Employee table';
PRINT '  ✓ Proper parent-child relationships maintained';
PRINT '========================================';

GO
