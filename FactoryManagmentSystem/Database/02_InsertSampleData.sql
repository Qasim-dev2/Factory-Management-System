-- ================================================================================
-- GARMENTS FACTORY MANAGEMENT SYSTEM - SAMPLE DATA
-- ================================================================================
-- Execute this script AFTER running 01_CreateDatabase.sql
-- This inserts sample data for testing
-- ================================================================================

USE GarmentsFactoryDB;
GO

-- ================================================================================
-- INSERT DEPARTMENTS
-- ================================================================================
INSERT INTO Department (DepartmentName, Description) VALUES
('Production Department', 'Handles all production activities including tailoring, cutting, and assembly'),
('Sales Department', 'Manages sales, retailer relationships, and order processing'),
('Inventory Department', 'Manages raw materials and finished goods inventory'),
('Delivery Department', 'Handles order deliveries and logistics');

PRINT 'Departments inserted successfully.';
GO

-- ================================================================================
-- INSERT EMPLOYEE ROLES
-- ================================================================================
INSERT INTO EmployeeRole (RoleName, Description) VALUES
('Manager', 'Department manager with supervisory responsibilities'),
('Tailor', 'Production worker responsible for garment stitching'),
('Salesperson', 'Sales staff responsible for customer relations and orders'),
('Inventory Clerk', 'Staff managing stock and raw materials'),
('Delivery Person', 'Staff responsible for order deliveries');

PRINT 'Employee Roles inserted successfully.';
GO

-- ================================================================================
-- INSERT EMPLOYEES
-- ================================================================================
-- Production Department Employees (DepartmentID = 1)
INSERT INTO Employee (FullName, CNIC, Phone, Email, Address, DepartmentID, RoleID, Salary) VALUES
('Ahmed Khan', '35201-1234567-1', '0300-1234567', 'ahmed.khan@factory.com', 'House 1, Street 5, Lahore', 1, 1, 75000.00),
('Muhammad Ali', '35201-2345678-2', '0301-2345678', 'muhammad.ali@factory.com', 'House 2, Street 6, Lahore', 1, 2, 35000.00),
('Usman Tariq', '35201-3456789-3', '0302-3456789', 'usman.tariq@factory.com', 'House 3, Street 7, Lahore', 1, 2, 32000.00),
('Bilal Ahmed', '35201-4567890-4', '0303-4567890', 'bilal.ahmed@factory.com', 'House 4, Street 8, Lahore', 1, 2, 30000.00),
('Hassan Raza', '35201-5678901-5', '0304-5678901', 'hassan.raza@factory.com', 'House 5, Street 9, Lahore', 1, 2, 33000.00);

-- Sales Department Employees (DepartmentID = 2)
INSERT INTO Employee (FullName, CNIC, Phone, Email, Address, DepartmentID, RoleID, Salary) VALUES
('Imran Malik', '35201-6789012-6', '0305-6789012', 'imran.malik@factory.com', 'House 6, Street 10, Lahore', 2, 1, 70000.00),
('Kamran Shah', '35201-7890123-7', '0306-7890123', 'kamran.shah@factory.com', 'House 7, Street 11, Lahore', 2, 3, 40000.00),
('Faisal Qureshi', '35201-8901234-8', '0307-8901234', 'faisal.qureshi@factory.com', 'House 8, Street 12, Lahore', 2, 3, 38000.00),
('Zubair Aslam', '35201-9012345-9', '0308-9012345', 'zubair.aslam@factory.com', 'House 9, Street 13, Lahore', 2, 3, 42000.00);

-- Inventory Department Employees (DepartmentID = 3)
INSERT INTO Employee (FullName, CNIC, Phone, Email, Address, DepartmentID, RoleID, Salary) VALUES
('Tariq Mehmood', '35201-0123456-0', '0309-0123456', 'tariq.mehmood@factory.com', 'House 10, Street 14, Lahore', 3, 4, 28000.00);

-- Delivery Department Employees (DepartmentID = 4)
INSERT INTO Employee (FullName, CNIC, Phone, Email, Address, DepartmentID, RoleID, Salary) VALUES
('Asad Hussain', '35201-1234560-1', '0310-1234560', 'asad.hussain@factory.com', 'House 11, Street 15, Lahore', 4, 5, 25000.00),
('Nabeel Farooq', '35201-2345601-2', '0311-2345601', 'nabeel.farooq@factory.com', 'House 12, Street 16, Lahore', 4, 5, 25000.00);

PRINT 'Employees inserted successfully.';
GO

-- ================================================================================
-- INSERT TAILOR DETAILS (for employees with RoleID = 2)
-- ================================================================================
INSERT INTO TailorDetails (TailorID, Specialization, PieceRate, TotalPiecesCompleted) VALUES
(2, 'Shirt Stitching', 150.00, 245),
(3, 'Trouser Stitching', 180.00, 198),
(4, 'Kurta Stitching', 200.00, 156),
(5, 'All-rounder', 175.00, 312);

PRINT 'Tailor Details inserted successfully.';
GO

-- ================================================================================
-- INSERT SALESPERSON DETAILS (for employees with RoleID = 3)
-- ================================================================================
INSERT INTO SalespersonDetails (SalespersonID, CommissionRate, SalesTarget, TotalSales, Region) VALUES
(7, 5.00, 500000.00, 325000.00, 'Lahore'),
(8, 4.50, 400000.00, 280000.00, 'Karachi'),
(9, 5.50, 450000.00, 410000.00, 'Islamabad');

PRINT 'Salesperson Details inserted successfully.';
GO

-- ================================================================================
-- INSERT PRODUCTS
-- ================================================================================
INSERT INTO Product (ProductName, SKU, Category, Size, Color, UnitPrice, Description) VALUES
('Men''s Formal Shirt', 'MFS-001', 'Shirts', 'M', 'White', 1500.00, 'Premium cotton formal shirt'),
('Men''s Formal Shirt', 'MFS-002', 'Shirts', 'L', 'White', 1500.00, 'Premium cotton formal shirt'),
('Men''s Formal Shirt', 'MFS-003', 'Shirts', 'XL', 'White', 1600.00, 'Premium cotton formal shirt'),
('Men''s Casual Shirt', 'MCS-001', 'Shirts', 'M', 'Blue', 1200.00, 'Comfortable casual shirt'),
('Men''s Casual Shirt', 'MCS-002', 'Shirts', 'L', 'Blue', 1200.00, 'Comfortable casual shirt'),
('Men''s Trouser', 'MTR-001', 'Trousers', '32', 'Black', 1800.00, 'Formal cotton trouser'),
('Men''s Trouser', 'MTR-002', 'Trousers', '34', 'Black', 1800.00, 'Formal cotton trouser'),
('Kurta Shalwar', 'KSH-001', 'Traditional', 'M', 'White', 2500.00, 'Traditional kurta shalwar set'),
('Kurta Shalwar', 'KSH-002', 'Traditional', 'L', 'White', 2500.00, 'Traditional kurta shalwar set'),
('Polo Shirt', 'PLS-001', 'Shirts', 'M', 'Red', 900.00, 'Casual polo shirt'),
('Polo Shirt', 'PLS-002', 'Shirts', 'L', 'Red', 900.00, 'Casual polo shirt'),
('Denim Jeans', 'DNJ-001', 'Jeans', '32', 'Blue', 2200.00, 'Stylish denim jeans'),
('Denim Jeans', 'DNJ-002', 'Jeans', '34', 'Blue', 2200.00, 'Stylish denim jeans');

PRINT 'Products inserted successfully.';
GO

-- ================================================================================
-- INSERT STOCK (Inventory)
-- ================================================================================
INSERT INTO Stock (ProductID, Quantity, WarehouseLocation, CreatedBy) VALUES
(1, 150, 'Warehouse A - Rack 1', 10),
(2, 120, 'Warehouse A - Rack 1', 10),
(3, 80, 'Warehouse A - Rack 1', 10),
(4, 200, 'Warehouse A - Rack 2', 10),
(5, 180, 'Warehouse A - Rack 2', 10),
(6, 100, 'Warehouse B - Rack 1', 10),
(7, 90, 'Warehouse B - Rack 1', 10),
(8, 60, 'Warehouse B - Rack 2', 10),
(9, 55, 'Warehouse B - Rack 2', 10),
(10, 250, 'Warehouse A - Rack 3', 10),
(11, 230, 'Warehouse A - Rack 3', 10),
(12, 75, 'Warehouse B - Rack 3', 10),
(13, 70, 'Warehouse B - Rack 3', 10);

PRINT 'Stock inserted successfully.';
GO

-- ================================================================================
-- INSERT RAW MATERIALS
-- ================================================================================
INSERT INTO RawMaterial (MaterialName, Category, Unit, CostPerUnit, QuantityOnHand, ReorderLevel, SupplierName, SupplierContact) VALUES
('Cotton Fabric - White', 'Fabric', 'Meters', 250.00, 5000.00, 500.00, 'Al-Madina Textiles', '042-1234567'),
('Cotton Fabric - Blue', 'Fabric', 'Meters', 280.00, 3500.00, 400.00, 'Al-Madina Textiles', '042-1234567'),
('Cotton Fabric - Black', 'Fabric', 'Meters', 260.00, 4000.00, 400.00, 'Al-Madina Textiles', '042-1234567'),
('Denim Fabric', 'Fabric', 'Meters', 450.00, 2000.00, 300.00, 'Denim House', '042-2345678'),
('Buttons - White', 'Accessories', 'Pieces', 5.00, 10000.00, 1000.00, 'Button World', '042-3456789'),
('Buttons - Black', 'Accessories', 'Pieces', 5.00, 8000.00, 1000.00, 'Button World', '042-3456789'),
('Thread - White', 'Thread', 'Spools', 50.00, 500.00, 50.00, 'Thread Masters', '042-4567890'),
('Thread - Black', 'Thread', 'Spools', 50.00, 450.00, 50.00, 'Thread Masters', '042-4567890'),
('Thread - Blue', 'Thread', 'Spools', 55.00, 300.00, 50.00, 'Thread Masters', '042-4567890'),
('Zippers - 7 inch', 'Accessories', 'Pieces', 25.00, 2000.00, 200.00, 'Zipper Zone', '042-5678901'),
('Elastic Band', 'Accessories', 'Meters', 15.00, 3000.00, 300.00, 'Elastic Traders', '042-6789012');

PRINT 'Raw Materials inserted successfully.';
GO

-- ================================================================================
-- INSERT RETAILERS
-- ================================================================================
INSERT INTO Retailer (Name, ContactPerson, Phone, Email, Address, City, CreditLimit, CurrentBalance) VALUES
('Fashion Hub', 'Ali Hassan', '0321-1111111', 'fashionhub@gmail.com', 'Shop 1, Mall Road', 'Lahore', 100000.00, 25000.00),
('Style Palace', 'Umar Farooq', '0322-2222222', 'stylepalace@gmail.com', 'Shop 5, Anarkali', 'Lahore', 150000.00, 45000.00),
('Trendy Wear', 'Sana Ahmed', '0323-3333333', 'trendywear@gmail.com', 'Plaza 10, Gulberg', 'Lahore', 200000.00, 80000.00),
('Classic Collection', 'Bilal Riaz', '0324-4444444', 'classic@gmail.com', 'Shop 20, Liberty', 'Lahore', 120000.00, 15000.00),
('Modern Outfits', 'Kashif Ali', '0325-5555555', 'modernoutfits@gmail.com', 'Shop 8, DHA', 'Karachi', 180000.00, 60000.00),
('Elite Fashion', 'Noman Khan', '0326-6666666', 'elitefashion@gmail.com', 'Plaza 5, F-10', 'Islamabad', 250000.00, 120000.00),
('Budget Wear', 'Asif Mahmood', '0327-7777777', 'budgetwear@gmail.com', 'Shop 15, Saddar', 'Rawalpindi', 80000.00, 10000.00);

PRINT 'Retailers inserted successfully.';
GO

-- ================================================================================
-- INSERT SALES ORDERS
-- ================================================================================
INSERT INTO SalesOrder (RetailerID, SalespersonID, OrderDate, TotalAmount, Status, Notes) VALUES
(1, 7, '2025-11-25', 45000.00, 'Delivered', 'Regular monthly order'),
(2, 7, '2025-11-26', 62000.00, 'Delivered', 'Bulk order for event'),
(3, 8, '2025-11-27', 38500.00, 'InTransit', 'Express delivery requested'),
(4, 9, '2025-11-28', 25000.00, 'Pending', 'Awaiting confirmation'),
(5, 8, '2025-11-29', 85000.00, 'Confirmed', 'Large order'),
(6, 9, '2025-11-30', 120000.00, 'Pending', 'Premium items'),
(1, 7, '2025-12-01', 32000.00, 'Pending', 'Regular order');

PRINT 'Sales Orders inserted successfully.';
GO

-- ================================================================================
-- INSERT SALES ORDER ITEMS
-- ================================================================================
-- Order 1 Items
INSERT INTO SalesOrderItem (SalesOrderID, ProductID, Quantity, UnitPrice, Discount) VALUES
(1, 1, 10, 1500.00, 0),
(1, 4, 15, 1200.00, 500),
(1, 10, 10, 900.00, 0);

-- Order 2 Items
INSERT INTO SalesOrderItem (SalesOrderID, ProductID, Quantity, UnitPrice, Discount) VALUES
(2, 6, 20, 1800.00, 1000),
(2, 8, 10, 2500.00, 500);

-- Order 3 Items
INSERT INTO SalesOrderItem (SalesOrderID, ProductID, Quantity, UnitPrice, Discount) VALUES
(3, 1, 15, 1500.00, 500),
(3, 2, 10, 1500.00, 0);

-- Order 4 Items
INSERT INTO SalesOrderItem (SalesOrderID, ProductID, Quantity, UnitPrice, Discount) VALUES
(4, 10, 20, 900.00, 0),
(4, 11, 15, 900.00, 500);

-- Order 5 Items
INSERT INTO SalesOrderItem (SalesOrderID, ProductID, Quantity, UnitPrice, Discount) VALUES
(5, 12, 25, 2200.00, 1000),
(5, 13, 20, 2200.00, 1000);

-- Order 6 Items
INSERT INTO SalesOrderItem (SalesOrderID, ProductID, Quantity, UnitPrice, Discount) VALUES
(6, 8, 30, 2500.00, 2000),
(6, 9, 25, 2500.00, 1500);

-- Order 7 Items
INSERT INTO SalesOrderItem (SalesOrderID, ProductID, Quantity, UnitPrice, Discount) VALUES
(7, 4, 20, 1200.00, 500),
(7, 5, 10, 1200.00, 0);

PRINT 'Sales Order Items inserted successfully.';
GO

-- ================================================================================
-- INSERT DEALS
-- ================================================================================
INSERT INTO Deal (DealName, Description, StartDate, EndDate, DiscountPercentage, Status, CreatedBy) VALUES
('Winter Sale 2025', 'Special winter collection discount', '2025-12-01', '2025-12-31', 15.00, 'Active', 6),
('New Year Bundle', 'Buy 3 get 1 free on selected items', '2025-12-25', '2026-01-05', 25.00, 'Pending', 6),
('Bulk Purchase Deal', 'Extra 10% off on orders above 50000', '2025-12-01', '2025-12-15', 10.00, 'Active', 1);

PRINT 'Deals inserted successfully.';
GO

-- ================================================================================
-- INSERT DEAL ITEMS
-- ================================================================================
INSERT INTO DealItem (DealID, ProductID, Quantity, UnitPrice) VALUES
(1, 1, 5, 1275.00),  -- 15% off
(1, 4, 5, 1020.00),
(1, 8, 3, 2125.00),
(2, 10, 4, 675.00),  -- Buy 3 get 1 free (25% effective)
(2, 11, 4, 675.00),
(3, 6, 10, 1620.00),  -- 10% off
(3, 7, 10, 1620.00);

PRINT 'Deal Items inserted successfully.';
GO

-- ================================================================================
-- INSERT PRODUCTION ORDERS
-- ================================================================================
INSERT INTO ProductionOrder (ProductID, QuantityOrdered, QuantityCompleted, StartDate, ExpectedEndDate, Status, CreatedByEmployeeID) VALUES
(1, 100, 75, '2025-11-20', '2025-12-05', 'InProgress', 1),
(4, 150, 150, '2025-11-15', '2025-11-30', 'Completed', 1),
(6, 80, 40, '2025-11-25', '2025-12-10', 'InProgress', 1),
(8, 50, 0, '2025-12-01', '2025-12-15', 'Pending', 1),
(12, 60, 20, '2025-11-28', '2025-12-12', 'InProgress', 1);

PRINT 'Production Orders inserted successfully.';
GO

-- ================================================================================
-- INSERT TAILOR TASKS
-- ================================================================================
INSERT INTO TailorTask (TailorID, ProductionOrderID, QuantityAssigned, QuantityCompleted, StartDate, Status, Notes) VALUES
(2, 1, 50, 40, '2025-11-20', 'InProgress', 'Priority task'),
(3, 1, 50, 35, '2025-11-20', 'InProgress', 'Standard task'),
(4, 2, 75, 75, '2025-11-15', 'Completed', 'Completed on time'),
(5, 2, 75, 75, '2025-11-15', 'Completed', 'Completed early'),
(3, 3, 40, 20, '2025-11-25', 'InProgress', 'Half done'),
(4, 3, 40, 20, '2025-11-25', 'InProgress', 'On track'),
(2, 5, 30, 10, '2025-11-28', 'InProgress', 'Just started'),
(5, 5, 30, 10, '2025-11-28', 'InProgress', 'In progress');

PRINT 'Tailor Tasks inserted successfully.';
GO

-- ================================================================================
-- INSERT STOCK USAGE (Raw material consumption)
-- ================================================================================
INSERT INTO StockUsage (TailorID, ProductionOrderID, RawMaterialID, QuantityUsed, Notes) VALUES
(2, 1, 1, 100.00, 'White cotton for shirts'),
(2, 1, 5, 200.00, 'White buttons'),
(2, 1, 7, 5.00, 'White thread'),
(3, 1, 1, 87.50, 'White cotton for shirts'),
(3, 1, 5, 175.00, 'White buttons'),
(4, 2, 2, 187.50, 'Blue cotton for casual shirts'),
(4, 2, 6, 150.00, 'Black buttons'),
(5, 2, 2, 187.50, 'Blue cotton for casual shirts'),
(5, 2, 6, 150.00, 'Black buttons'),
(3, 3, 3, 80.00, 'Black cotton for trousers'),
(3, 3, 10, 40.00, 'Zippers'),
(4, 3, 3, 80.00, 'Black cotton for trousers');

PRINT 'Stock Usage inserted successfully.';
GO

-- ================================================================================
-- INSERT DELIVERIES
-- ================================================================================
INSERT INTO Delivery (SalesOrderID, DeliveredBy, DeliveryDate, DeliveryAddress, Status, Notes) VALUES
(1, 11, '2025-11-26', 'Shop 1, Mall Road, Lahore', 'Delivered', 'Delivered on time'),
(2, 12, '2025-11-27', 'Shop 5, Anarkali, Lahore', 'Delivered', 'Customer satisfied'),
(3, 11, NULL, 'Plaza 10, Gulberg, Lahore', 'InTransit', 'Expected today');

PRINT 'Deliveries inserted successfully.';
GO

-- ================================================================================
-- SAMPLE DATA INSERTION COMPLETE!
-- ================================================================================
PRINT '========================================';
PRINT 'SAMPLE DATA INSERTION COMPLETED!';
PRINT '========================================';
PRINT 'Summary:';
PRINT '- 4 Departments';
PRINT '- 5 Employee Roles';
PRINT '- 12 Employees';
PRINT '- 4 Tailors with details';
PRINT '- 3 Salespersons with details';
PRINT '- 13 Products';
PRINT '- 13 Stock entries';
PRINT '- 11 Raw Materials';
PRINT '- 7 Retailers';
PRINT '- 7 Sales Orders with items';
PRINT '- 3 Deals with items';
PRINT '- 5 Production Orders';
PRINT '- 8 Tailor Tasks';
PRINT '- 12 Stock Usage records';
PRINT '- 3 Deliveries';
PRINT '========================================';
GO
