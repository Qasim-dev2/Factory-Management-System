-- ================================================================================
-- COMPLETE SAMPLE DATA FOR PAKISTANI GARMENT FACTORY
-- Proper data for all tables to enable Revenue tracking
-- ================================================================================
USE GarmentsFactoryDB;
GO

PRINT '========================================';
PRINT 'INSERTING COMPLETE SAMPLE DATA';
PRINT '========================================';
PRINT '';

-- ================================================================================
-- STEP 1: CLEAR EXISTING SAMPLE DATA (Optional - for clean setup)
-- ================================================================================
PRINT 'Step 1: Cleaning existing data...';

-- Delete in proper order to avoid FK violations
DELETE FROM Delivery;
DELETE FROM TailorTask;
DELETE FROM StockUsage;
DELETE FROM ProductionOrderItem;
DELETE FROM ProductionOrder;
DELETE FROM DealItem;
DELETE FROM Deal;
DELETE FROM SalesOrderItem;
DELETE FROM SalesOrder;
DELETE FROM Stock;
DELETE FROM Product;
DELETE FROM RawMaterial;
DELETE FROM Retailer;
DELETE FROM Employee;
DELETE FROM EmployeeRole;
DELETE FROM Department;
DELETE FROM MonthlyRevenue;

-- Reset identity seeds
DBCC CHECKIDENT ('Department', RESEED, 0);
DBCC CHECKIDENT ('EmployeeRole', RESEED, 0);
DBCC CHECKIDENT ('Employee', RESEED, 0);
DBCC CHECKIDENT ('RawMaterial', RESEED, 0);
DBCC CHECKIDENT ('Product', RESEED, 0);
DBCC CHECKIDENT ('Stock', RESEED, 0);
DBCC CHECKIDENT ('Retailer', RESEED, 0);
DBCC CHECKIDENT ('SalesOrder', RESEED, 0);
DBCC CHECKIDENT ('SalesOrderItem', RESEED, 0);
DBCC CHECKIDENT ('Deal', RESEED, 0);
DBCC CHECKIDENT ('DealItem', RESEED, 0);
DBCC CHECKIDENT ('ProductionOrder', RESEED, 0);
DBCC CHECKIDENT ('Delivery', RESEED, 0);
DBCC CHECKIDENT ('MonthlyRevenue', RESEED, 0);

PRINT '✅ Existing data cleared';
GO

-- ================================================================================
-- STEP 2: INSERT DEPARTMENTS
-- ================================================================================
PRINT 'Step 2: Inserting Departments...';

INSERT INTO Department (DepartmentName, Description, IsActive) VALUES
('Production', 'Handles all garment production, cutting, stitching, and finishing', 1),
('Sales', 'Manages sales, customer relations, and order processing', 1),
('Inventory', 'Manages raw materials, finished goods, and stock control', 1),
('Delivery', 'Handles order deliveries, logistics, and shipping', 1),
('Administration', 'General administration and management', 1);

PRINT '✅ 5 Departments inserted';
GO

-- ================================================================================
-- STEP 3: INSERT EMPLOYEE ROLES
-- ================================================================================
PRINT 'Step 3: Inserting Employee Roles...';

INSERT INTO EmployeeRole (RoleName, Description, IsActive) VALUES
('Owner', 'Factory owner with full access', 1),
('Production Manager', 'Manages production department', 1),
('Sales Manager', 'Manages sales team and targets', 1),
('Master Tailor', 'Senior tailor with supervision duties', 1),
('Tailor', 'Production worker for garment stitching', 1),
('Salesperson', 'Sales staff for customer orders', 1),
('Inventory Clerk', 'Manages stock and raw materials', 1),
('Delivery Person', 'Handles order deliveries', 1),
('Cutter', 'Fabric cutting specialist', 1),
('Quality Inspector', 'Quality control and inspection', 1);

PRINT '✅ 10 Employee Roles inserted';
GO

-- ================================================================================
-- STEP 4: INSERT EMPLOYEES (Pakistani Names with proper salaries)
-- ================================================================================
PRINT 'Step 4: Inserting Employees...';

-- Administration (DeptID=5)
INSERT INTO Employee (FirstName, LastName, Email, Phone, DepartmentID, RoleID, ShiftType, Salary, JoinDate, Address, CNIC, IsActive) VALUES
('Muhammad', 'Arshad', 'arshad@factory.com', '0300-1111111', 5, 1, 'Morning', 150000, '2020-01-01', 'House 1, DHA Phase 5, Lahore', '35201-1111111-1', 1);

-- Production Department (DeptID=1)
INSERT INTO Employee (FirstName, LastName, Email, Phone, DepartmentID, RoleID, ShiftType, Salary, JoinDate, Address, CNIC, IsActive) VALUES
('Ahmed', 'Khan', 'ahmed.khan@factory.com', '0300-2222222', 1, 2, 'Morning', 75000, '2021-03-15', 'House 10, Model Town, Lahore', '35201-2222222-2', 1),
('Usman', 'Ali', 'usman.ali@factory.com', '0301-3333333', 1, 4, 'Morning', 45000, '2021-06-01', 'Street 5, Gulberg, Lahore', '35201-3333333-3', 1),
('Bilal', 'Ahmed', 'bilal.ahmed@factory.com', '0302-4444444', 1, 5, 'Morning', 35000, '2022-01-10', 'Shahdara, Lahore', '35201-4444444-4', 1),
('Hassan', 'Raza', 'hassan.raza@factory.com', '0303-5555555', 1, 5, 'Morning', 32000, '2022-03-20', 'Data Ganj Bakhsh Town, Lahore', '35201-5555555-5', 1),
('Imran', 'Siddiqui', 'imran.siddiqui@factory.com', '0304-6666666', 1, 5, 'Evening', 30000, '2022-06-15', 'Badami Bagh, Lahore', '35201-6666666-6', 1),
('Tariq', 'Mehmood', 'tariq.mehmood@factory.com', '0305-7777777', 1, 9, 'Morning', 38000, '2021-08-01', 'Johar Town, Lahore', '35201-7777777-7', 1),
('Aslam', 'Pervez', 'aslam.pervez@factory.com', '0306-8888888', 1, 10, 'Morning', 40000, '2022-02-01', 'Iqbal Town, Lahore', '35201-8888888-8', 1);

-- Sales Department (DeptID=2)
INSERT INTO Employee (FirstName, LastName, Email, Phone, DepartmentID, RoleID, ShiftType, Salary, JoinDate, Address, CNIC, IsActive) VALUES
('Kamran', 'Shah', 'kamran.shah@factory.com', '0307-9999999', 2, 3, 'Morning', 65000, '2021-04-01', 'Garden Town, Lahore', '35201-9999999-9', 1),
('Faisal', 'Qureshi', 'faisal.qureshi@factory.com', '0308-1010101', 2, 6, 'Morning', 40000, '2022-05-01', 'Faisal Town, Lahore', '35201-1010101-1', 1),
('Zubair', 'Aslam', 'zubair.aslam@factory.com', '0309-1212121', 2, 6, 'Morning', 38000, '2022-08-15', 'Township, Lahore', '35201-1212121-2', 1),
('Waqas', 'Malik', 'waqas.malik@factory.com', '0310-1313131', 2, 6, 'Evening', 35000, '2023-01-10', 'Cantt, Lahore', '35201-1313131-3', 1);

-- Inventory Department (DeptID=3)
INSERT INTO Employee (FirstName, LastName, Email, Phone, DepartmentID, RoleID, ShiftType, Salary, JoinDate, Address, CNIC, IsActive) VALUES
('Naveed', 'Akhtar', 'naveed.akhtar@factory.com', '0311-1414141', 3, 7, 'Morning', 32000, '2022-04-01', 'Sabzazar, Lahore', '35201-1414141-4', 1);

-- Delivery Department (DeptID=4)
INSERT INTO Employee (FirstName, LastName, Email, Phone, DepartmentID, RoleID, ShiftType, Salary, JoinDate, Address, CNIC, IsActive) VALUES
('Asad', 'Hussain', 'asad.hussain@factory.com', '0312-1515151', 4, 8, 'Morning', 28000, '2022-07-01', 'Ravi Road, Lahore', '35201-1515151-5', 1),
('Nabeel', 'Farooq', 'nabeel.farooq@factory.com', '0313-1616161', 4, 8, 'Morning', 26000, '2023-02-01', 'Mughalpura, Lahore', '35201-1616161-6', 1);

PRINT '✅ 15 Employees inserted (Total Salary: Rs. 809,000/month)';
GO

-- ================================================================================
-- STEP 5: INSERT RAW MATERIALS
-- ================================================================================
PRINT 'Step 5: Inserting Raw Materials...';

INSERT INTO RawMaterial (MaterialName, Category, Unit, Quantity, MinimumStock, UnitPrice, Supplier, SupplierContact, Description, IsActive) VALUES
-- Fabrics
('Cotton Fabric - White', 'Fabric', 'Meters', 5000, 500, 280.00, 'Al-Madina Textiles', '042-35761234', 'Premium white cotton for shirts', 1),
('Cotton Fabric - Sky Blue', 'Fabric', 'Meters', 3500, 400, 300.00, 'Al-Madina Textiles', '042-35761234', 'Sky blue cotton fabric', 1),
('Cotton Fabric - Black', 'Fabric', 'Meters', 4000, 400, 290.00, 'Al-Madina Textiles', '042-35761234', 'Black cotton fabric', 1),
('Lawn Fabric - Printed', 'Fabric', 'Meters', 2500, 300, 450.00, 'Gul Ahmed Fabrics', '042-35112233', 'Printed lawn for kurtas', 1),
('Denim Fabric - Blue', 'Fabric', 'Meters', 2000, 300, 520.00, 'Denim House Faisalabad', '041-2614567', 'Heavy denim for jeans', 1),
('Khaddar Fabric', 'Fabric', 'Meters', 1500, 200, 380.00, 'Chenab Textiles', '041-2513456', 'Winter khaddar fabric', 1),
('Silk Fabric - Mixed', 'Fabric', 'Meters', 800, 100, 1200.00, 'Silk Palace Lahore', '042-36311111', 'Premium silk blend', 1),

-- Threads
('Thread - White', 'Thread', 'Spools', 1000, 100, 45.00, 'Thread Masters', '042-35421234', 'White polyester thread', 1),
('Thread - Black', 'Thread', 'Spools', 800, 100, 45.00, 'Thread Masters', '042-35421234', 'Black polyester thread', 1),
('Thread - Multicolor Pack', 'Thread', 'Packs', 200, 50, 350.00, 'Thread Masters', '042-35421234', 'Assorted colors pack', 1),

-- Buttons & Accessories
('Buttons - White Pearl', 'Buttons', 'Dozen', 500, 100, 60.00, 'Button World', '042-35671234', 'Pearl white buttons', 1),
('Buttons - Black Matte', 'Buttons', 'Dozen', 400, 80, 55.00, 'Button World', '042-35671234', 'Matte black buttons', 1),
('Zippers - 7 inch', 'Zippers', 'Pieces', 1000, 200, 35.00, 'Zipper Zone', '042-35891234', '7 inch metal zippers', 1),
('Zippers - 16 inch', 'Zippers', 'Pieces', 500, 100, 65.00, 'Zipper Zone', '042-35891234', '16 inch metal zippers', 1),
('Elastic Band - 1 inch', 'Elastic', 'Meters', 2000, 300, 18.00, 'Elastic Traders', '042-36121234', '1 inch elastic band', 1),
('Lining Fabric', 'Fabric', 'Meters', 1500, 200, 120.00, 'Al-Madina Textiles', '042-35761234', 'Pocket lining material', 1);

PRINT '✅ 16 Raw Materials inserted';
GO

-- ================================================================================
-- STEP 6: INSERT PRODUCTS
-- ================================================================================
PRINT 'Step 6: Inserting Products...';

INSERT INTO Product (ProductName, Description, Category, UnitPrice, CostPrice, StockQuantity, MinimumStock, IsActive) VALUES
-- Formal Shirts
('Mens Formal Shirt - White', 'Premium white cotton formal shirt', 'Formal Shirts', 1800.00, 850.00, 150, 30, 1),
('Mens Formal Shirt - Sky Blue', 'Sky blue cotton formal shirt', 'Formal Shirts', 1800.00, 880.00, 120, 25, 1),
('Mens Formal Shirt - Black', 'Black cotton formal shirt', 'Formal Shirts', 1900.00, 900.00, 100, 25, 1),

-- Casual Shirts
('Mens Casual Shirt - Printed', 'Casual printed shirt', 'Casual Shirts', 1500.00, 700.00, 200, 40, 1),
('Polo Shirt - Red', 'Cotton polo shirt red', 'Casual Shirts', 1200.00, 550.00, 180, 35, 1),
('Polo Shirt - Navy', 'Cotton polo shirt navy blue', 'Casual Shirts', 1200.00, 550.00, 160, 35, 1),

-- Trousers
('Formal Trouser - Black', 'Cotton blend formal trouser', 'Trousers', 2200.00, 1000.00, 100, 20, 1),
('Formal Trouser - Grey', 'Cotton blend formal trouser grey', 'Trousers', 2200.00, 1000.00, 90, 20, 1),
('Denim Jeans - Blue', 'Classic blue denim jeans', 'Jeans', 2800.00, 1300.00, 80, 15, 1),
('Denim Jeans - Black', 'Black denim jeans', 'Jeans', 2800.00, 1300.00, 70, 15, 1),

-- Traditional
('Kurta Shalwar - White', 'Traditional white kurta shalwar', 'Traditional', 3200.00, 1500.00, 60, 15, 1),
('Kurta Shalwar - Printed', 'Lawn printed kurta shalwar', 'Traditional', 3500.00, 1700.00, 50, 12, 1),
('Khaddar Suit', 'Winter khaddar suit', 'Traditional', 4500.00, 2200.00, 40, 10, 1),

-- T-Shirts
('Round Neck T-Shirt - White', 'Basic white cotton t-shirt', 'T-Shirts', 800.00, 350.00, 250, 50, 1),
('Round Neck T-Shirt - Black', 'Basic black cotton t-shirt', 'T-Shirts', 800.00, 350.00, 230, 50, 1),
('V-Neck T-Shirt - Mixed', 'V-neck cotton t-shirt', 'T-Shirts', 900.00, 400.00, 200, 40, 1);

PRINT '✅ 16 Products inserted';
GO

-- ================================================================================
-- STEP 7: INSERT STOCK
-- ================================================================================
PRINT 'Step 7: Inserting Stock...';

INSERT INTO Stock (ProductID, Quantity, BatchNumber, Location, Status, CreatedBy) VALUES
(1, 150, 'BATCH-2025-001', 'Warehouse A - Rack 1', 'Available', 13),
(2, 120, 'BATCH-2025-002', 'Warehouse A - Rack 1', 'Available', 13),
(3, 100, 'BATCH-2025-003', 'Warehouse A - Rack 2', 'Available', 13),
(4, 200, 'BATCH-2025-004', 'Warehouse A - Rack 2', 'Available', 13),
(5, 180, 'BATCH-2025-005', 'Warehouse A - Rack 3', 'Available', 13),
(6, 160, 'BATCH-2025-006', 'Warehouse A - Rack 3', 'Available', 13),
(7, 100, 'BATCH-2025-007', 'Warehouse B - Rack 1', 'Available', 13),
(8, 90, 'BATCH-2025-008', 'Warehouse B - Rack 1', 'Available', 13),
(9, 80, 'BATCH-2025-009', 'Warehouse B - Rack 2', 'Available', 13),
(10, 70, 'BATCH-2025-010', 'Warehouse B - Rack 2', 'Available', 13),
(11, 60, 'BATCH-2025-011', 'Warehouse B - Rack 3', 'Available', 13),
(12, 50, 'BATCH-2025-012', 'Warehouse B - Rack 3', 'Available', 13),
(13, 40, 'BATCH-2025-013', 'Warehouse B - Rack 4', 'Available', 13),
(14, 250, 'BATCH-2025-014', 'Warehouse A - Rack 4', 'Available', 13),
(15, 230, 'BATCH-2025-015', 'Warehouse A - Rack 4', 'Available', 13),
(16, 200, 'BATCH-2025-016', 'Warehouse A - Rack 5', 'Available', 13);

PRINT '✅ 16 Stock entries inserted';
GO

-- ================================================================================
-- STEP 8: INSERT RETAILERS
-- ================================================================================
PRINT 'Step 8: Inserting Retailers...';

INSERT INTO Retailer (CompanyName, BusinessType, ContactPerson, Phone, Email, Address, City, CreditLimit, PaymentTerms, Status, IsActive) VALUES
('Hussain Fabrics', 'Wholesaler', 'Muhammad Hussain', '0321-4567890', 'hussain@fabrics.com', 'Shop 15, Anarkali Bazaar', 'Lahore', 500000, 'Net30', 'Active', 1),
('Karachi Garments', 'Retailer', 'Ahmed Ali', '0322-5678901', 'ahmed@kgarments.com', 'Plot 25, Tariq Road', 'Karachi', 300000, 'Net15', 'Active', 1),
('Faisalabad Textiles', 'Wholesaler', 'Rashid Mahmood', '0323-6789012', 'rashid@ftextiles.com', 'D-Ground, Faisalabad', 'Faisalabad', 750000, 'Net45', 'Active', 1),
('Islamabad Fashion House', 'Boutique', 'Sara Khan', '0324-7890123', 'sara@ifhouse.com', 'F-7 Markaz', 'Islamabad', 200000, 'Net15', 'Active', 1),
('Multan Cloth Market', 'Wholesaler', 'Akram Shah', '0325-8901234', 'akram@mcloth.com', 'Hussain Agahi', 'Multan', 400000, 'Net30', 'Active', 1),
('Peshawar Traders', 'Retailer', 'Khan Wali', '0326-9012345', 'khan@ptraders.com', 'Qissa Khwani Bazaar', 'Peshawar', 250000, 'Net30', 'Active', 1),
('Sialkot Export House', 'Exporter', 'Amir Shahzad', '0327-0123456', 'amir@sexport.com', 'Industrial Area', 'Sialkot', 1000000, 'Net60', 'Active', 1),
('Rawalpindi Store', 'Retailer', 'Tariq Nawaz', '0328-1234567', 'tariq@rstore.com', 'Raja Bazaar', 'Rawalpindi', 180000, 'Cash', 'Active', 1);

PRINT '✅ 8 Retailers inserted';
GO

-- ================================================================================
-- STEP 9: INSERT SALES ORDERS (October - December 2025)
-- ================================================================================
PRINT 'Step 9: Inserting Sales Orders...';

-- October 2025 Sales Orders
INSERT INTO SalesOrder (OrderDate, ExpectedDeliveryDate, PriorityLevel, Status, RetailerID, ShippingAddress, PaymentTerms, PaymentStatus, SubTotal, TotalAmount, SalesRepID) VALUES
('2025-10-05', '2025-10-12', 'High', 'Delivered', 1, 'Shop 15, Anarkali Bazaar, Lahore', 'Net30', 'Paid', 85000, 85000, 10),
('2025-10-08', '2025-10-15', 'Medium', 'Delivered', 2, 'Plot 25, Tariq Road, Karachi', 'Net15', 'Paid', 62000, 62000, 11),
('2025-10-12', '2025-10-20', 'High', 'Delivered', 3, 'D-Ground, Faisalabad', 'Net45', 'Paid', 145000, 145000, 10),
('2025-10-18', '2025-10-25', 'Medium', 'Delivered', 4, 'F-7 Markaz, Islamabad', 'Net15', 'Paid', 48000, 48000, 12),
('2025-10-22', '2025-10-30', 'High', 'Delivered', 5, 'Hussain Agahi, Multan', 'Net30', 'Paid', 92000, 92000, 11),
('2025-10-28', '2025-11-05', 'Medium', 'Delivered', 7, 'Industrial Area, Sialkot', 'Net60', 'Paid', 180000, 180000, 10);

-- November 2025 Sales Orders (Wedding Season - Higher)
INSERT INTO SalesOrder (OrderDate, ExpectedDeliveryDate, PriorityLevel, Status, RetailerID, ShippingAddress, PaymentTerms, PaymentStatus, SubTotal, TotalAmount, SalesRepID) VALUES
('2025-11-02', '2025-11-10', 'High', 'Delivered', 1, 'Shop 15, Anarkali Bazaar, Lahore', 'Net30', 'Paid', 125000, 125000, 10),
('2025-11-05', '2025-11-12', 'High', 'Delivered', 3, 'D-Ground, Faisalabad', 'Net45', 'Paid', 195000, 195000, 11),
('2025-11-08', '2025-11-15', 'Medium', 'Delivered', 2, 'Plot 25, Tariq Road, Karachi', 'Net15', 'Paid', 78000, 78000, 10),
('2025-11-12', '2025-11-20', 'High', 'Delivered', 7, 'Industrial Area, Sialkot', 'Net60', 'Paid', 250000, 250000, 12),
('2025-11-18', '2025-11-25', 'Medium', 'Delivered', 5, 'Hussain Agahi, Multan', 'Net30', 'Paid', 115000, 115000, 11),
('2025-11-22', '2025-11-30', 'High', 'Delivered', 4, 'F-7 Markaz, Islamabad', 'Net15', 'Paid', 68000, 68000, 10),
('2025-11-25', '2025-12-03', 'High', 'Delivered', 6, 'Qissa Khwani Bazaar, Peshawar', 'Net30', 'Paid', 88000, 88000, 12),
('2025-11-28', '2025-12-05', 'Medium', 'Delivered', 8, 'Raja Bazaar, Rawalpindi', 'Cash', 'Paid', 45000, 45000, 11);

-- December 2025 Sales Orders (Current Month)
INSERT INTO SalesOrder (OrderDate, ExpectedDeliveryDate, PriorityLevel, Status, RetailerID, ShippingAddress, PaymentTerms, PaymentStatus, SubTotal, TotalAmount, SalesRepID) VALUES
('2025-12-01', '2025-12-08', 'High', 'Delivered', 1, 'Shop 15, Anarkali Bazaar, Lahore', 'Net30', 'Paid', 95000, 95000, 10),
('2025-12-03', '2025-12-10', 'Medium', 'Delivered', 2, 'Plot 25, Tariq Road, Karachi', 'Net15', 'Paid', 72000, 72000, 11),
('2025-12-05', '2025-12-12', 'High', 'Shipped', 3, 'D-Ground, Faisalabad', 'Net45', 'Pending', 168000, 168000, 10),
('2025-12-07', '2025-12-15', 'Medium', 'Shipped', 7, 'Industrial Area, Sialkot', 'Net60', 'Pending', 220000, 220000, 12),
('2025-12-09', '2025-12-16', 'High', 'Confirmed', 5, 'Hussain Agahi, Multan', 'Net30', 'Pending', 85000, 85000, 11),
('2025-12-10', '2025-12-18', 'Medium', 'Pending', 4, 'F-7 Markaz, Islamabad', 'Net15', 'Pending', 55000, 55000, 10);

PRINT '✅ 20 Sales Orders inserted';
GO

-- ================================================================================
-- STEP 10: INSERT SALES ORDER ITEMS
-- ================================================================================
PRINT 'Step 10: Inserting Sales Order Items...';

-- Order 1 items (85000)
INSERT INTO SalesOrderItem (SalesOrderID, ProductID, Size, Color, Quantity, UnitPrice) VALUES
(1, 1, 'M', 'White', 20, 1800), (1, 2, 'L', 'Sky Blue', 15, 1800), (1, 7, '32', 'Black', 10, 2200);

-- Order 2 items (62000)
INSERT INTO SalesOrderItem (SalesOrderID, ProductID, Size, Color, Quantity, UnitPrice) VALUES
(2, 4, 'M', 'Printed', 20, 1500), (2, 5, 'L', 'Red', 15, 1200), (2, 14, 'M', 'White', 20, 800);

-- Order 3 items (145000)
INSERT INTO SalesOrderItem (SalesOrderID, ProductID, Size, Color, Quantity, UnitPrice) VALUES
(3, 1, 'L', 'White', 30, 1800), (3, 11, 'M', 'White', 20, 3200), (3, 9, '32', 'Blue', 10, 2800);

-- Order 4 items (48000)
INSERT INTO SalesOrderItem (SalesOrderID, ProductID, Size, Color, Quantity, UnitPrice) VALUES
(4, 6, 'M', 'Navy', 20, 1200), (4, 14, 'L', 'White', 30, 800);

-- Continue with more items...
INSERT INTO SalesOrderItem (SalesOrderID, ProductID, Size, Color, Quantity, UnitPrice) VALUES
(5, 1, 'M', 'White', 25, 1800), (5, 3, 'L', 'Black', 20, 1900),
(6, 11, 'L', 'White', 30, 3200), (6, 12, 'M', 'Printed', 25, 3500),
(7, 1, 'M', 'White', 35, 1800), (7, 7, '34', 'Black', 25, 2200),
(8, 11, 'L', 'White', 40, 3200), (8, 13, 'M', 'Khaddar', 15, 4500),
(9, 4, 'L', 'Printed', 30, 1500), (9, 5, 'M', 'Red', 25, 1200),
(10, 1, 'XL', 'White', 50, 1800), (10, 11, 'L', 'White', 45, 3200),
(11, 7, '32', 'Black', 30, 2200), (11, 8, '34', 'Grey', 25, 2200),
(12, 6, 'M', 'Navy', 30, 1200), (12, 14, 'S', 'White', 40, 800),
(13, 12, 'L', 'Printed', 15, 3500), (13, 5, 'M', 'Red', 30, 1200),
(14, 1, 'M', 'White', 30, 1800), (14, 2, 'L', 'Sky Blue', 20, 1800);

-- December orders
INSERT INTO SalesOrderItem (SalesOrderID, ProductID, Size, Color, Quantity, UnitPrice) VALUES
(15, 1, 'M', 'White', 25, 1800), (15, 3, 'L', 'Black', 20, 1900),
(16, 4, 'M', 'Printed', 25, 1500), (16, 6, 'L', 'Navy', 30, 1200),
(17, 11, 'M', 'White', 35, 3200), (17, 7, '32', 'Black', 25, 2200),
(18, 1, 'L', 'White', 50, 1800), (18, 11, 'L', 'White', 40, 3200),
(19, 7, '34', 'Black', 20, 2200), (19, 8, '32', 'Grey', 20, 2200),
(20, 6, 'M', 'Navy', 25, 1200), (20, 14, 'M', 'White', 25, 800);

PRINT '✅ Sales Order Items inserted';
GO

-- ================================================================================
-- STEP 11: INSERT DEALS (October - December 2025)
-- ================================================================================
PRINT 'Step 11: Inserting Deals...';

-- October 2025 Deals
INSERT INTO Deal (DealTitle, DealType, ClientName, ContactPerson, Email, Phone, EstimatedValue, Currency, Priority, StartDate, EndDate, Description, Status) VALUES
('Eid Collection Supply', 'Supply Contract', 'Karachi Wholesale Market', 'Saleem Ahmed', 'saleem@kwm.com', '0321-1112233', 180000, 'PKR', 'High', '2025-10-01', '2025-10-30', 'Eid special collection supply', 'Completed'),
('Corporate Uniforms', 'Partnership', 'Bank Al-Habib', 'HR Department', 'hr@abl.com', '021-111225522', 250000, 'PKR', 'High', '2025-10-15', '2025-11-15', 'Staff uniform supply contract', 'Completed');

-- November 2025 Deals (Wedding Season)
INSERT INTO Deal (DealTitle, DealType, ClientName, ContactPerson, Email, Phone, EstimatedValue, Currency, Priority, StartDate, EndDate, Description, Status) VALUES
('Wedding Season Bulk', 'Supply Contract', 'Lahore Bridal Market', 'Asif Iqbal', 'asif@lbm.com', '0300-4445566', 350000, 'PKR', 'Critical', '2025-11-01', '2025-11-30', 'Wedding season bulk order', 'Completed'),
('Export Order - UK', 'Export', 'British Asian Fashions', 'James Khan', 'james@baf.co.uk', '+44-7891234567', 420000, 'PKR', 'High', '2025-11-10', '2025-12-10', 'Export quality garments for UK market', 'Completed'),
('Hotel Staff Uniforms', 'Partnership', 'Pearl Continental Hotels', 'Procurement Dept', 'procurement@pc.com', '042-111505505', 280000, 'PKR', 'Medium', '2025-11-15', '2025-12-15', 'Staff uniforms for PC hotels', 'Completed');

-- December 2025 Deals
INSERT INTO Deal (DealTitle, DealType, ClientName, ContactPerson, Email, Phone, EstimatedValue, Currency, Priority, StartDate, EndDate, Description, Status) VALUES
('Year End Clearance', 'Supply Contract', 'Faisalabad Mega Mart', 'Naveed Khan', 'naveed@fmm.com', '041-2515151', 320000, 'PKR', 'High', '2025-12-01', '2025-12-31', 'Year end bulk purchase', 'Approved'),
('New Year Collection', 'Partnership', 'Islamabad Fashion Week', 'Event Manager', 'events@ifw.pk', '051-2876543', 150000, 'PKR', 'Medium', '2025-12-05', '2025-12-25', 'Fashion week collection supply', 'Active'),
('School Uniforms 2026', 'Supply Contract', 'Punjab Education Dept', 'Procurement', 'proc@ped.gov.pk', '042-99210000', 500000, 'PKR', 'High', '2025-12-10', '2026-02-28', 'School uniforms for govt schools', 'Pending Approval');

PRINT '✅ 8 Deals inserted';
GO

-- ================================================================================
-- STEP 12: INSERT DEAL ITEMS
-- ================================================================================
PRINT 'Step 12: Inserting Deal Items...';

INSERT INTO DealItem (DealID, ProductID, Quantity, UnitPrice) VALUES
-- Deal 1 (180000)
(1, 11, 30, 3200), (1, 12, 20, 3500),
-- Deal 2 (250000)
(2, 1, 80, 1800), (2, 7, 40, 2200),
-- Deal 3 (350000)
(3, 11, 50, 3200), (3, 12, 35, 3500), (3, 13, 20, 4500),
-- Deal 4 (420000)
(4, 1, 100, 1800), (4, 2, 80, 1800), (4, 7, 50, 2200),
-- Deal 5 (280000)
(5, 1, 60, 1800), (5, 7, 50, 2200), (5, 3, 40, 1900),
-- Deal 6 (320000)
(6, 1, 80, 1800), (6, 4, 60, 1500), (6, 14, 100, 800),
-- Deal 7 (150000)
(7, 11, 25, 3200), (7, 12, 20, 3500),
-- Deal 8 (500000)
(8, 1, 150, 1800), (8, 7, 80, 2200);

PRINT '✅ Deal Items inserted';
GO

-- ================================================================================
-- STEP 13: INSERT DELIVERIES
-- ================================================================================
PRINT 'Step 13: Inserting Deliveries...';

INSERT INTO Delivery (SalesOrderID, DeliveryPersonID, DeliveryDate, Status, DeliveryAddress, ReceiverName, ReceiverPhone, Notes) VALUES
-- October deliveries
(1, 14, '2025-10-12', 'Delivered', 'Shop 15, Anarkali Bazaar, Lahore', 'Muhammad Hussain', '0321-4567890', 'Delivered on time'),
(2, 15, '2025-10-15', 'Delivered', 'Plot 25, Tariq Road, Karachi', 'Ahmed Ali', '0322-5678901', 'Delivered successfully'),
(3, 14, '2025-10-20', 'Delivered', 'D-Ground, Faisalabad', 'Rashid Mahmood', '0323-6789012', 'Bulk order delivered'),
(4, 15, '2025-10-25', 'Delivered', 'F-7 Markaz, Islamabad', 'Sara Khan', '0324-7890123', 'Delivered to boutique'),
(5, 14, '2025-10-30', 'Delivered', 'Hussain Agahi, Multan', 'Akram Shah', '0325-8901234', 'All items received'),
(6, 15, '2025-11-05', 'Delivered', 'Industrial Area, Sialkot', 'Amir Shahzad', '0327-0123456', 'Export shipment delivered'),

-- November deliveries
(7, 14, '2025-11-10', 'Delivered', 'Shop 15, Anarkali Bazaar, Lahore', 'Muhammad Hussain', '0321-4567890', 'Wedding season order'),
(8, 15, '2025-11-12', 'Delivered', 'D-Ground, Faisalabad', 'Rashid Mahmood', '0323-6789012', 'Large bulk order'),
(9, 14, '2025-11-15', 'Delivered', 'Plot 25, Tariq Road, Karachi', 'Ahmed Ali', '0322-5678901', 'Delivered successfully'),
(10, 15, '2025-11-20', 'Delivered', 'Industrial Area, Sialkot', 'Amir Shahzad', '0327-0123456', 'Export order completed'),
(11, 14, '2025-11-25', 'Delivered', 'Hussain Agahi, Multan', 'Akram Shah', '0325-8901234', 'All items verified'),
(12, 15, '2025-11-30', 'Delivered', 'F-7 Markaz, Islamabad', 'Sara Khan', '0324-7890123', 'Boutique delivery'),
(13, 14, '2025-12-03', 'Delivered', 'Qissa Khwani Bazaar, Peshawar', 'Khan Wali', '0326-9012345', 'First order delivered'),
(14, 15, '2025-12-05', 'Delivered', 'Raja Bazaar, Rawalpindi', 'Tariq Nawaz', '0328-1234567', 'Cash order delivered'),

-- December deliveries
(15, 14, '2025-12-08', 'Delivered', 'Shop 15, Anarkali Bazaar, Lahore', 'Muhammad Hussain', '0321-4567890', 'December order'),
(16, 15, '2025-12-10', 'Delivered', 'Plot 25, Tariq Road, Karachi', 'Ahmed Ali', '0322-5678901', 'Delivered on time'),
(17, 14, NULL, 'In Transit', 'D-Ground, Faisalabad', 'Rashid Mahmood', '0323-6789012', 'On the way'),
(18, 15, NULL, 'In Transit', 'Industrial Area, Sialkot', 'Amir Shahzad', '0327-0123456', 'Large shipment'),
(19, 14, NULL, 'Pending', 'Hussain Agahi, Multan', 'Akram Shah', '0325-8901234', 'Awaiting dispatch'),
(20, 15, NULL, 'Pending', 'F-7 Markaz, Islamabad', 'Sara Khan', '0324-7890123', 'Order confirmed');

PRINT '✅ 20 Deliveries inserted';
GO

-- ================================================================================
-- STEP 14: UPDATE MONTHLY REVENUE WITH REAL DATA
-- ================================================================================
PRINT 'Step 14: Updating Monthly Revenue...';

-- Clear existing revenue data
DELETE FROM MonthlyRevenue;

-- Insert fresh data based on actual SalesOrders and Deals
-- October 2025
INSERT INTO MonthlyRevenue ([Year], [Month], MonthName, SalesIncome, DealIncome, SalariesPaid, TotalSalaries, RawMaterialCost, MiscExpense, Notes)
SELECT 
    2025, 10, 'October',
    (SELECT ISNULL(SUM(TotalAmount), 0) FROM SalesOrder WHERE YEAR(OrderDate) = 2025 AND MONTH(OrderDate) = 10 AND Status IN ('Delivered', 'Completed', 'Shipped')),
    (SELECT ISNULL(SUM(EstimatedValue), 0) FROM Deal WHERE YEAR(StartDate) = 2025 AND MONTH(StartDate) = 10 AND Status IN ('Completed', 'Approved')),
    1, 809000, 120000, 35000, 'October - Post Eid, Wedding season beginning';

-- November 2025
INSERT INTO MonthlyRevenue ([Year], [Month], MonthName, SalesIncome, DealIncome, SalariesPaid, TotalSalaries, RawMaterialCost, MiscExpense, Notes)
SELECT 
    2025, 11, 'November',
    (SELECT ISNULL(SUM(TotalAmount), 0) FROM SalesOrder WHERE YEAR(OrderDate) = 2025 AND MONTH(OrderDate) = 11 AND Status IN ('Delivered', 'Completed', 'Shipped')),
    (SELECT ISNULL(SUM(EstimatedValue), 0) FROM Deal WHERE YEAR(StartDate) = 2025 AND MONTH(StartDate) = 11 AND Status IN ('Completed', 'Approved')),
    1, 809000, 180000, 55000, 'November - Wedding Season Peak';

-- December 2025
INSERT INTO MonthlyRevenue ([Year], [Month], MonthName, SalesIncome, DealIncome, SalariesPaid, TotalSalaries, RawMaterialCost, MiscExpense, Notes)
SELECT 
    2025, 12, 'December',
    (SELECT ISNULL(SUM(TotalAmount), 0) FROM SalesOrder WHERE YEAR(OrderDate) = 2025 AND MONTH(OrderDate) = 12 AND Status IN ('Delivered', 'Completed', 'Shipped', 'Confirmed')),
    (SELECT ISNULL(SUM(EstimatedValue), 0) FROM Deal WHERE YEAR(StartDate) = 2025 AND MONTH(StartDate) = 12 AND Status IN ('Completed', 'Approved', 'Active')),
    0, 0, 150000, 45000, 'December - Year End Orders (Salaries Pending)';

PRINT '✅ Monthly Revenue updated with real data';
GO

-- ================================================================================
-- VERIFICATION
-- ================================================================================
PRINT '';
PRINT '========================================';
PRINT 'DATA VERIFICATION';
PRINT '========================================';

SELECT 'Departments' AS [Table], COUNT(*) AS [Count] FROM Department UNION ALL
SELECT 'Employee Roles', COUNT(*) FROM EmployeeRole UNION ALL
SELECT 'Employees', COUNT(*) FROM Employee UNION ALL
SELECT 'Raw Materials', COUNT(*) FROM RawMaterial UNION ALL
SELECT 'Products', COUNT(*) FROM Product UNION ALL
SELECT 'Stock', COUNT(*) FROM Stock UNION ALL
SELECT 'Retailers', COUNT(*) FROM Retailer UNION ALL
SELECT 'Sales Orders', COUNT(*) FROM SalesOrder UNION ALL
SELECT 'Deals', COUNT(*) FROM Deal UNION ALL
SELECT 'Deliveries', COUNT(*) FROM Delivery UNION ALL
SELECT 'Monthly Revenue', COUNT(*) FROM MonthlyRevenue;

PRINT '';
PRINT 'MONTHLY REVENUE SUMMARY:';
SELECT [Month], MonthName, 
       FORMAT(SalesIncome, 'N0') AS [Sales],
       FORMAT(DealIncome, 'N0') AS [Deals],
       FORMAT(SalesIncome + DealIncome, 'N0') AS [Total Income],
       FORMAT(TotalSalaries + RawMaterialCost + MiscExpense, 'N0') AS [Total Expense],
       FORMAT(SalesIncome + DealIncome - TotalSalaries - RawMaterialCost - MiscExpense, 'N0') AS [Net Profit]
FROM MonthlyRevenue 
WHERE [Year] = 2025
ORDER BY [Month];

PRINT '';
PRINT '✅ COMPLETE SAMPLE DATA INSERTED SUCCESSFULLY!';
PRINT '========================================';
GO
