-- ================================================================================
-- GARMENTS FACTORY MANAGEMENT SYSTEM - DATABASE CREATION SCRIPT
-- ================================================================================
-- Execute this script in SQL Server Management Studio (SSMS)
-- Tables are designed to match FRONTEND FORM FIELDS exactly
-- ================================================================================

-- Step 1: Create the Database (Run this first, then connect to it)
-- ================================================================================
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'GarmentsFactoryDB')
BEGIN
    CREATE DATABASE GarmentsFactoryDB;
END
GO

USE GarmentsFactoryDB;
GO

-- ================================================================================
-- Step 2: Drop existing tables if they exist (for clean setup)
-- Run this only if you want to reset the database
-- ================================================================================
/*
DROP TABLE IF EXISTS Delivery;
DROP TABLE IF EXISTS TailorTask;
DROP TABLE IF EXISTS StockUsage;
DROP TABLE IF EXISTS ProductionOrderItem;
DROP TABLE IF EXISTS ProductionOrder;
DROP TABLE IF EXISTS DealItem;
DROP TABLE IF EXISTS Deal;
DROP TABLE IF EXISTS SalesOrderItem;
DROP TABLE IF EXISTS SalesOrder;
DROP TABLE IF EXISTS Stock;
DROP TABLE IF EXISTS Product;
DROP TABLE IF EXISTS RawMaterial;
DROP TABLE IF EXISTS Retailer;
DROP TABLE IF EXISTS Employee;
DROP TABLE IF EXISTS EmployeeRole;
DROP TABLE IF EXISTS Department;
*/

-- ================================================================================
-- Step 3: CREATE CORE TABLES
-- ================================================================================

-- 1. Department Table
-- ================================================================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Department')
BEGIN
    CREATE TABLE Department (
        DepartmentID INT PRIMARY KEY IDENTITY(1,1),
        DepartmentName NVARCHAR(100) NOT NULL,
        Description NVARCHAR(500) NULL,
        CreatedDate DATETIME DEFAULT GETDATE(),
        IsActive BIT DEFAULT 1
    );
    PRINT 'Table Department created successfully.';
END
GO

-- 2. EmployeeRole Table (Position in frontend)
-- ================================================================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'EmployeeRole')
BEGIN
    CREATE TABLE EmployeeRole (
        RoleID INT PRIMARY KEY IDENTITY(1,1),
        RoleName NVARCHAR(50) NOT NULL,  -- Position from AddEmployeeDialog
        Description NVARCHAR(500) NULL,
        CreatedDate DATETIME DEFAULT GETDATE(),
        IsActive BIT DEFAULT 1
    );
    PRINT 'Table EmployeeRole created successfully.';
END
GO

-- 3. Employee Table - MATCHES AddEmployeeDialog.xaml form fields
-- ================================================================================
-- Frontend Fields: FirstName, LastName, Email, Phone, Department, Position, 
--                  ShiftType, Salary, JoinDate, Address, EmergencyContact, Notes
-- ================================================================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Employee')
BEGIN
    CREATE TABLE Employee (
        EmployeeID INT PRIMARY KEY IDENTITY(1,1),
        
        -- Personal Information Section
        FirstName NVARCHAR(50) NOT NULL,         -- FirstNameTextBox
        LastName NVARCHAR(50) NOT NULL,          -- LastNameTextBox
        Email NVARCHAR(100) NULL,                -- EmailTextBox
        Phone NVARCHAR(20) NULL,                 -- PhoneTextBox
        
        -- Work Information Section
        DepartmentID INT NOT NULL,               -- DepartmentComboBox
        RoleID INT NOT NULL,                     -- PositionComboBox
        ShiftType NVARCHAR(20) NULL,             -- ShiftComboBox (Morning, Evening, Night, Rotating)
        Salary DECIMAL(18,2) DEFAULT 0,          -- SalaryTextBox
        JoinDate DATE DEFAULT GETDATE(),         -- JoinDatePicker
        
        -- Additional Information Section
        Address NVARCHAR(500) NULL,              -- AddressTextBox
        EmergencyContact NVARCHAR(100) NULL,     -- EmergencyContactTextBox
        Notes NVARCHAR(1000) NULL,               -- NotesTextBox
        
        -- Salesperson Fields (nullable - only for salespersons)
        CommissionRate DECIMAL(5,2) NULL,        -- Salesperson commission %
        SalesTarget DECIMAL(18,2) NULL,          -- Monthly/yearly sales target
        TotalSales DECIMAL(18,2) DEFAULT 0,      -- Total sales achieved
        SalesRegion NVARCHAR(100) NULL,          -- Sales territory/region
        
        -- Tailor Fields (nullable - only for tailors)
        Specialization NVARCHAR(100) NULL,       -- Shirt, Trouser, Kurta, etc.
        PieceRate DECIMAL(18,2) NULL,            -- Rate per piece
        TotalPiecesCompleted INT DEFAULT 0,      -- Total pieces completed
        
        -- System Fields
        CNIC NVARCHAR(15) NULL,                  -- For ID verification
        IsActive BIT DEFAULT 1,
        CreatedDate DATETIME DEFAULT GETDATE(),
        UpdatedDate DATETIME NULL,
        
        CONSTRAINT FK_Employee_Department FOREIGN KEY (DepartmentID) 
            REFERENCES Department(DepartmentID),
        CONSTRAINT FK_Employee_Role FOREIGN KEY (RoleID) 
            REFERENCES EmployeeRole(RoleID)
    );
    PRINT 'Table Employee created successfully.';
END
GO

-- ================================================================================
-- Step 4: CREATE PRODUCT & INVENTORY TABLES
-- ================================================================================

-- 6. Product Table - MATCHES AddProductDialog.xaml form fields
-- ================================================================================
-- Frontend Fields: ProductName, Description, Category, Brand, Price, CostPrice,
--                  Material, Sizes, Colors, StockQuantity, MinimumStock, 
--                  Supplier, ImageUrl, ProductionStatus
-- ================================================================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Product')
BEGIN
    CREATE TABLE Product (
        ProductID INT PRIMARY KEY IDENTITY(1,1),
        
        -- Basic Information Section
        ProductName NVARCHAR(100) NOT NULL,      -- ProductNameTextBox
        Description NVARCHAR(1000) NULL,         -- DescriptionTextBox
        Category NVARCHAR(50) NULL,              -- CategoryComboBox (T-Shirts, Shirts, Pants, etc.)
        Brand NVARCHAR(100) NULL,                -- BrandTextBox
        
        -- Pricing Information Section
        SalePrice DECIMAL(18,2) NOT NULL DEFAULT 0,   -- PriceTextBox (PKR)
        CostPrice DECIMAL(18,2) NULL DEFAULT 0,       -- CostPriceTextBox (PKR)
        
        -- Product Details Section
        Material NVARCHAR(50) NULL,              -- MaterialComboBox (Cotton, Polyester, Denim, etc.)
        AvailableSizes NVARCHAR(100) NULL,       -- SizesTextBox (S, M, L, XL)
        AvailableColors NVARCHAR(200) NULL,      -- ColorsTextBox (Black, White, Blue)
        
        -- Inventory Information Section
        StockQuantity INT DEFAULT 0,             -- StockQuantityTextBox
        MinimumStock INT DEFAULT 10,             -- MinimumStockTextBox
        Supplier NVARCHAR(100) NULL,             -- SupplierTextBox
        
        -- Additional Information Section
        ImageUrl NVARCHAR(500) NULL,             -- ImageUrlTextBox
        ProductionStatus NVARCHAR(30) DEFAULT 'Active',  -- ProductionStatusComboBox (Active, InDevelopment, Discontinued, OutOfStock)
        
        -- System Fields
        SKU NVARCHAR(50) NULL UNIQUE,
        IsActive BIT DEFAULT 1,
        CreatedDate DATETIME DEFAULT GETDATE(),
        UpdatedDate DATETIME NULL
    );
    PRINT 'Table Product created successfully.';
END
GO

-- 7. Stock Table - MATCHES AddStockEntryDialog.xaml form fields
-- ================================================================================
-- Frontend Fields: Product, ProductId, Category, BatchNo, EntryDate, Quantity,
--                  StockStatus, Progress, Location, Notes
-- ================================================================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Stock')
BEGIN
    CREATE TABLE Stock (
        StockID INT PRIMARY KEY IDENTITY(1,1),
        
        -- Product Information Section
        ProductID INT NOT NULL,                  -- ProductComboBox
        
        -- Batch Information Section
        BatchNo NVARCHAR(50) NOT NULL,           -- BatchNoTextBox
        EntryDate DATETIME DEFAULT GETDATE(),   -- EntryDatePicker
        
        -- Quantity & Status Section
        Quantity INT NOT NULL DEFAULT 0,         -- QuantityTextBox
        StockStatus NVARCHAR(30) DEFAULT 'Ready',  -- StockStatusComboBox (Ready, InProcess)
        ProgressPercentage INT DEFAULT 100,      -- ProgressTextBox (for InProcess items)
        
        -- Additional Information Section
        Location NVARCHAR(100) NULL,             -- LocationComboBox (Main Warehouse, Production Floor, etc.)
        Notes NVARCHAR(500) NULL,                -- NotesTextBox
        
        -- System Fields
        CreatedBy INT NULL,
        LastUpdated DATETIME DEFAULT GETDATE(),
        CreatedDate DATETIME DEFAULT GETDATE(),
        
        CONSTRAINT FK_Stock_Product FOREIGN KEY (ProductID) 
            REFERENCES Product(ProductID),
        CONSTRAINT FK_Stock_Employee FOREIGN KEY (CreatedBy) 
            REFERENCES Employee(EmployeeID)
    );
    PRINT 'Table Stock created successfully.';
END
GO

-- 8. RawMaterial Table - MATCHES RawMaterialManagementView.xaml form fields
-- ================================================================================
-- Frontend Fields: MaterialName, Category, Unit, Quantity, MinimumStock, 
--                  UnitPrice, Supplier, Description
-- ================================================================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'RawMaterial')
BEGIN
    CREATE TABLE RawMaterial (
        RawMaterialID INT PRIMARY KEY IDENTITY(1,1),
        
        -- Basic Information
        MaterialName NVARCHAR(100) NOT NULL,     -- AddMaterialName TextBox
        Category NVARCHAR(50) NULL,              -- AddCategory ComboBox (Fabric, Thread, Button, Zipper, etc.)
        Unit NVARCHAR(20) NULL,                  -- AddUnit ComboBox (Meters, Yards, Pieces, Kg, Rolls, Packs, Dozen)
        
        -- Stock Information
        Quantity DECIMAL(18,2) NOT NULL DEFAULT 0,      -- AddQuantity TextBox
        MinimumStock DECIMAL(18,2) DEFAULT 0,           -- AddMinStock TextBox
        UnitPrice DECIMAL(18,2) NOT NULL DEFAULT 0,     -- AddUnitPrice TextBox (Rs.)
        
        -- Supplier Information
        Supplier NVARCHAR(100) NULL,             -- AddSupplier TextBox
        SupplierContact NVARCHAR(100) NULL,
        
        -- Additional Information
        Description NVARCHAR(500) NULL,          -- AddDescription TextBox
        StockStatus NVARCHAR(20) DEFAULT 'In Stock',  -- Calculated: In Stock, Low Stock, Out of Stock
        
        -- System Fields
        LastRestockDate DATE NULL,
        IsActive BIT DEFAULT 1,
        CreatedDate DATETIME DEFAULT GETDATE(),
        UpdatedDate DATETIME NULL
    );
    PRINT 'Table RawMaterial created successfully.';
END
GO

-- ================================================================================
-- Step 5: CREATE RETAILER & SALES TABLES
-- ================================================================================

-- 9. Retailer Table - MATCHES AddRetailerDialog.xaml form fields
-- ================================================================================
-- Frontend Fields: CompanyName, BusinessType, RegistrationNumber, TaxId,
--                  ContactPerson, Designation, Phone, Email, AlternativePhone,
--                  Address, City, Province, PostalCode,
--                  CreditLimit, PaymentTerms, DiscountPercentage, SalesRep, Priority,
--                  BankName, AccountNumber, AccountTitle, BranchCode,
--                  Status, Website, Notes, Tags
-- ================================================================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Retailer')
BEGIN
    CREATE TABLE Retailer (
        RetailerID INT PRIMARY KEY IDENTITY(1,1),
        
        -- Company Information Section
        CompanyName NVARCHAR(100) NOT NULL,      -- CompanyNameTextBox
        BusinessType NVARCHAR(50) NULL,          -- BusinessTypeComboBox (Wholesaler, Retailer, Boutique, etc.)
        RegistrationNumber NVARCHAR(50) NULL,    -- RegistrationNumberTextBox
        TaxId NVARCHAR(50) NULL,                 -- TaxIdTextBox
        
        -- Contact Information Section
        ContactPerson NVARCHAR(100) NULL,        -- ContactPersonTextBox
        Designation NVARCHAR(50) NULL,           -- DesignationTextBox
        Phone NVARCHAR(20) NULL,                 -- PhoneTextBox
        Email NVARCHAR(100) NULL,                -- EmailTextBox
        AlternativePhone NVARCHAR(20) NULL,      -- AlternativePhoneTextBox
        
        -- Location Information Section
        Address NVARCHAR(500) NULL,              -- AddressTextBox
        City NVARCHAR(50) NULL,                  -- CityComboBox (Karachi, Lahore, Faisalabad, etc.)
        Province NVARCHAR(50) NULL,              -- ProvinceComboBox (Punjab, Sindh, KPK, Balochistan)
        PostalCode NVARCHAR(10) NULL,            -- PostalCodeTextBox
        
        -- Business Terms Section
        CreditLimit DECIMAL(18,2) DEFAULT 0,     -- CreditLimitTextBox
        PaymentTerms NVARCHAR(30) NULL,          -- PaymentTermsComboBox (Cash, Net15, Net30, Net45, Net60)
        DiscountPercentage DECIMAL(5,2) DEFAULT 0,  -- DiscountPercentageTextBox
        SalesRepID INT NULL,                     -- SalesRepComboBox (FK to Employee/Salesperson)
        Priority NVARCHAR(20) DEFAULT 'Regular', -- PriorityComboBox (VIP, Premium, Regular, New)
        
        -- Banking Information Section
        BankName NVARCHAR(100) NULL,             -- BankNameComboBox (HBL, MCB, UBL, etc.)
        AccountNumber NVARCHAR(50) NULL,         -- AccountNumberTextBox
        AccountTitle NVARCHAR(100) NULL,         -- AccountTitleTextBox
        BranchCode NVARCHAR(20) NULL,            -- BranchCodeTextBox
        
        -- Additional Information Section
        Status NVARCHAR(20) DEFAULT 'Active',    -- StatusComboBox (Active, Inactive, Pending, Blocked)
        Website NVARCHAR(200) NULL,              -- WebsiteTextBox
        Notes NVARCHAR(1000) NULL,               -- NotesTextBox
        Tags NVARCHAR(200) NULL,                 -- TagsTextBox
        
        -- System Fields
        CurrentBalance DECIMAL(18,2) DEFAULT 0,
        IsActive BIT DEFAULT 1,
        CreatedDate DATETIME DEFAULT GETDATE(),
        UpdatedDate DATETIME NULL,
        
        CONSTRAINT FK_Retailer_SalesRep FOREIGN KEY (SalesRepID) 
            REFERENCES Employee(EmployeeID)
    );
    PRINT 'Table Retailer created successfully.';
END
GO

-- 10. SalesOrder Table - MATCHES CreateOrderDialog.xaml form fields
-- ================================================================================
-- Frontend Fields: OrderId, OrderDate, DeliveryDate, Priority, Status,
--                  Customer, CustomerEmail, CustomerPhone, ShippingAddress, SpecialInstructions,
--                  PaymentTerms, AdvancePayment, DiscountPercentage, PaymentStatus,
--                  SalesRep, OrderSource, InternalNotes, Tags
-- ================================================================================
       -- Payment Information Section
        PaymentTerms NVARCHAR(50) NULL,          -- PaymentTermsComboBox (Net 30 Days, Net 60 Days, etc.)
        PaymentMethod NVARCHAR(50) NULL,         -- PaymentMethodComboBox (Bank Transfer, Letter of Credit, etc.)
        
        -- Additional Information Section
        SpecialRequirements NVARCHAR(1000) NULL, -- RequirementsTextBox
        AssignedManagerID INT NULL,              -- ManagerComboBox
        Status NVARCHAR(30) DEFAULT 'Draft',     -- StatusComboBox (Draft, Under Review, Pending Approval, Approved, Active)
        
        -- System Fields
        CreatedBy INT NULL,
        CreatedDate DATETIME DEFAULT GETDATE(),
        UpdatedDate DATETIME NULL,
        
  IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'SalesOrder')
BEGIN
    CREATE TABLE SalesOrder (
        SalesOrderID INT PRIMARY KEY IDENTITY(1,1),
        
        -- Order Information Section
        OrderDate DATETIME DEFAULT GETDATE(),    -- OrderDatePicker
        ExpectedDeliveryDate DATE NULL,          -- DeliveryDatePicker
        PriorityLevel NVARCHAR(20) DEFAULT 'Medium',  -- PriorityComboBox (Low, Medium, High, Rush)
        Status NVARCHAR(30) DEFAULT 'Pending',   -- StatusComboBox (Pending, Confirmed, InProduction, ReadyToShip, Shipped, Delivered)
        
        -- Customer Information Section
        RetailerID INT NOT NULL,                 -- CustomerComboBox
        ShippingAddress NVARCHAR(500) NULL,      -- ShippingAddressTextBox
        SpecialInstructions NVARCHAR(500) NULL,  -- SpecialInstructionsTextBox
        
        -- Payment Information Section
        PaymentTerms NVARCHAR(30) NULL,          -- PaymentTermsComboBox (Cash on Delivery, 15 days, 30 days, etc.)
        AdvancePaymentPercent DECIMAL(5,2) DEFAULT 0,  -- AdvancePaymentTextBox
        DiscountPercentage DECIMAL(5,2) DEFAULT 0,     -- DiscountPercentageTextBox
        PaymentStatus NVARCHAR(20) DEFAULT 'Pending',  -- PaymentStatusComboBox (Pending, Partial, Paid, Overdue)
        
        -- Order Summary (Calculated)
        SubTotal DECIMAL(18,2) DEFAULT 0,
        DiscountAmount DECIMAL(18,2) DEFAULT 0,
        TaxAmount DECIMAL(18,2) DEFAULT 0,
        TotalAmount DECIMAL(18,2) NOT NULL DEFAULT 0,
        
        -- Additional Information Section
        SalesRepID INT NULL,                     -- SalesRepComboBox
        OrderSource NVARCHAR(30) NULL,           -- OrderSourceComboBox (Direct Call, Email, Website, Walk-in, Referral, Trade Show)
        InternalNotes NVARCHAR(1000) NULL,       -- InternalNotesTextBox
        Tags NVARCHAR(200) NULL,                 -- TagsTextBox
        
        -- System Fields
        CreatedDate DATETIME DEFAULT GETDATE(),
        UpdatedDate DATETIME NULL,
        
        CONSTRAINT FK_SalesOrder_Retailer FOREIGN KEY (RetailerID) 
            REFERENCES Retailer(RetailerID),
        CONSTRAINT FK_SalesOrder_SalesRep FOREIGN KEY (SalesRepID) 
            REFERENCES Employee(EmployeeID)
    );
    PRINT 'Table SalesOrder created successfully.';
END
GO

-- 11. SalesOrderItem Table - MATCHES CreateOrderDialog.xaml DataGrid
-- ================================================================================
-- Frontend Fields: Product, Size, Color, Quantity, UnitPrice, Total
-- ================================================================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'SalesOrderItem')
BEGIN
    CREATE TABLE SalesOrderItem (
        SalesOrderItemID INT PRIMARY KEY IDENTITY(1,1),
        SalesOrderID INT NOT NULL,
        ProductID INT NOT NULL,                  -- Product column
        Size NVARCHAR(20) NULL,                  -- Size column
        Color NVARCHAR(50) NULL,                 -- Color column
        Quantity INT NOT NULL DEFAULT 1,         -- Qty column
        UnitPrice DECIMAL(18,2) NOT NULL DEFAULT 0,  -- Unit Price column
        Discount DECIMAL(18,2) DEFAULT 0,
        TotalPrice AS (Quantity * UnitPrice - Discount) PERSISTED,  -- Total column
        
        CONSTRAINT FK_SalesOrderItem_SalesOrder FOREIGN KEY (SalesOrderID) 
            REFERENCES SalesOrder(SalesOrderID) ON DELETE CASCADE,
        CONSTRAINT FK_SalesOrderItem_Product FOREIGN KEY (ProductID) 
            REFERENCES Product(ProductID)
    );
    PRINT 'Table SalesOrderItem created successfully.';
END
GO

-- ================================================================================
-- Step 6: CREATE DEAL TABLES - MATCHES AddDealDialog.xaml form fields
-- ================================================================================

-- 12. Deal Table
-- ================================================================================
-- Frontend Fields: DealTitle, DealType, ClientName, ContactPerson, Email, Phone,
--                  DealValue, Currency, Priority, Duration, StartDate, EndDate,
--                  Description, Terms, PaymentTerms, PaymentMethod, Requirements,
--                  Manager, Status
-- ================================================================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Deal')
BEGIN
    CREATE TABLE Deal (
        DealID INT PRIMARY KEY IDENTITY(1,1),
        
        -- Basic Information Section
        DealTitle NVARCHAR(100) NOT NULL,        -- DealTitleTextBox
        DealType NVARCHAR(50) NULL,              -- DealTypeComboBox (Partnership, Supply Contract, etc.)
        
        -- Client Information Section
        ClientName NVARCHAR(100) NULL,           -- ClientNameTextBox
        ContactPerson NVARCHAR(100) NULL,        -- ContactPersonTextBox
        Email NVARCHAR(100) NULL,                -- EmailTextBox
        Phone NVARCHAR(20) NULL,                 -- PhoneTextBox
        
        -- Deal Details Section
        EstimatedValue DECIMAL(18,2) NULL,       -- DealValueTextBox
        Currency NVARCHAR(10) DEFAULT 'PKR',     -- CurrencyComboBox (USD, EUR, GBP, PKR, etc.)
        Priority NVARCHAR(20) DEFAULT 'Medium',  -- PriorityComboBox (Low, Medium, High, Critical)
        ExpectedDuration NVARCHAR(50) NULL,      -- DurationTextBox
        
        -- Timeline Section
        StartDate DATE NULL,                     -- StartDatePicker
        EndDate DATE NULL,                       -- EndDatePicker
        
        -- Terms & Description Section
        Description NVARCHAR(1000) NULL,         -- DescriptionTextBox
        KeyTerms NVARCHAR(1000) NULL,            -- TermsTextBox
        
       CONSTRAINT FK_Deal_Manager FOREIGN KEY (AssignedManagerID) 
            REFERENCES Employee(EmployeeID),
        CONSTRAINT FK_Deal_CreatedBy FOREIGN KEY (CreatedBy) 
            REFERENCES Employee(EmployeeID)
    );
    PRINT 'Table Deal created successfully.';
END
GO

-- 13. DealItem Table
-- ================================================================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'DealItem')
BEGIN
    CREATE TABLE DealItem (
        DealItemID INT PRIMARY KEY IDENTITY(1,1),
        DealID INT NOT NULL,
        ProductID INT NOT NULL,
        Quantity INT NOT NULL DEFAULT 1,
        UnitPrice DECIMAL(18,2) NOT NULL DEFAULT 0,
        
        CONSTRAINT FK_DealItem_Deal FOREIGN KEY (DealID) 
            REFERENCES Deal(DealID) ON DELETE CASCADE,
        CONSTRAINT FK_DealItem_Product FOREIGN KEY (ProductID) 
            REFERENCES Product(ProductID)
    );
    PRINT 'Table DealItem created successfully.';
END
GO

-- ================================================================================
-- Step 7: CREATE PRODUCTION TABLES
-- ================================================================================

-- 14. ProductionOrder Table
-- ================================================================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ProductionOrder')
BEGIN
    CREATE TABLE ProductionOrder (
        ProductionOrderID INT PRIMARY KEY IDENTITY(1,1),
        ProductID INT NOT NULL,
        QuantityOrdered INT NOT NULL DEFAULT 0,
        QuantityCompleted INT DEFAULT 0,
        StartDate DATE NULL,
        ExpectedEndDate DATE NULL,
        ActualEndDate DATE NULL,
        Status NVARCHAR(50) DEFAULT 'Pending',  -- Pending, InProgress, Completed, Cancelled
        Priority NVARCHAR(20) DEFAULT 'Normal', -- Low, Normal, High, Urgent
        Notes NVARCHAR(500) NULL,
        CreatedByEmployeeID INT NULL,
        CreatedDate DATETIME DEFAULT GETDATE(),
        UpdatedDate DATETIME NULL,
        
        CONSTRAINT FK_ProductionOrder_Product FOREIGN KEY (ProductID) 
            REFERENCES Product(ProductID),
        CONSTRAINT FK_ProductionOrder_Employee FOREIGN KEY (CreatedByEmployeeID) 
            REFERENCES Employee(EmployeeID)
    );
    PRINT 'Table ProductionOrder created successfully.';
END
GO

-- 15. ProductionOrderItem Table
-- ================================================================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ProductionOrderItem')
BEGIN
    CREATE TABLE ProductionOrderItem (
        ProductionOrderItemID INT PRIMARY KEY IDENTITY(1,1),
        ProductionOrderID INT NOT NULL,
        RawMaterialID INT NOT NULL,
        QuantityRequired DECIMAL(18,2) NOT NULL DEFAULT 0,
        QuantityUsed DECIMAL(18,2) DEFAULT 0,
        
        CONSTRAINT FK_ProductionOrderItem_ProductionOrder FOREIGN KEY (ProductionOrderID) 
            REFERENCES ProductionOrder(ProductionOrderID) ON DELETE CASCADE,
        CONSTRAINT FK_ProductionOrderItem_RawMaterial FOREIGN KEY (RawMaterialID) 
            REFERENCES RawMaterial(RawMaterialID)
    );
    PRINT 'Table ProductionOrderItem created successfully.';
END
GO

-- 14. TailorTask Table (Tasks assigned to tailors/employees)
-- ================================================================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'TailorTask')
BEGIN
    CREATE TABLE TailorTask (
        TailorTaskID INT PRIMARY KEY IDENTITY(1,1),
        EmployeeID INT NOT NULL,                 -- References Employee (tailor)
        ProductionOrderID INT NOT NULL,
        QuantityAssigned INT NOT NULL DEFAULT 0,
        QuantityCompleted INT DEFAULT 0,
        StartDate DATE NULL,
        EndDate DATE NULL,
        Status NVARCHAR(50) DEFAULT 'Assigned',  -- Assigned, InProgress, Completed
        Notes NVARCHAR(500) NULL,
        
        CONSTRAINT FK_TailorTask_Employee FOREIGN KEY (EmployeeID) 
            REFERENCES Employee(EmployeeID),
        CONSTRAINT FK_TailorTask_ProductionOrder FOREIGN KEY (ProductionOrderID) 
            REFERENCES ProductionOrder(ProductionOrderID)
    );
    PRINT 'Table TailorTask created successfully.';
END
GO

-- 15. StockUsage Table (Raw material usage tracking)
-- ================================================================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'StockUsage')
BEGIN
    CREATE TABLE StockUsage (
        StockUsageID INT PRIMARY KEY IDENTITY(1,1),
        EmployeeID INT NOT NULL,                 -- References Employee (tailor/worker)
        ProductionOrderID INT NOT NULL,
        RawMaterialID INT NOT NULL,
        QuantityUsed DECIMAL(18,2) NOT NULL DEFAULT 0,
        UsageDate DATETIME DEFAULT GETDATE(),
        Notes NVARCHAR(500) NULL,
        
        CONSTRAINT FK_StockUsage_Employee FOREIGN KEY (EmployeeID) 
            REFERENCES Employee(EmployeeID),
        CONSTRAINT FK_StockUsage_ProductionOrder FOREIGN KEY (ProductionOrderID) 
            REFERENCES ProductionOrder(ProductionOrderID),
        CONSTRAINT FK_StockUsage_RawMaterial FOREIGN KEY (RawMaterialID) 
            REFERENCES RawMaterial(RawMaterialID)
    );
    PRINT 'Table StockUsage created successfully.';
END
GO

-- ================================================================================
-- Step 8: CREATE DELIVERY TABLE
-- ================================================================================

-- 18. Delivery Table
-- ================================================================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Delivery')
BEGIN
    CREATE TABLE Delivery (
        DeliveryID INT PRIMARY KEY IDENTITY(1,1),
        SalesOrderID INT NOT NULL UNIQUE,  -- One-to-One with SalesOrder
        DeliveredBy INT NULL,
        DeliveryDate DATETIME NULL,
        DeliveryAddress NVARCHAR(500) NULL,
        City NVARCHAR(50) NULL,
        Province NVARCHAR(50) NULL,
        PostalCode NVARCHAR(10) NULL,
        TrackingNumber NVARCHAR(100) NULL,
        DeliveryMethod NVARCHAR(50) NULL,  -- Own Delivery, Courier, etc.
        DeliveryCost DECIMAL(18,2) DEFAULT 0,
        Status NVARCHAR(50) DEFAULT 'Pending',  -- Pending, InTransit, Delivered, Failed
        ReceiverName NVARCHAR(100) NULL,
        ReceiverPhone NVARCHAR(20) NULL,
        Notes NVARCHAR(500) NULL,
        CreatedDate DATETIME DEFAULT GETDATE(),
        UpdatedDate DATETIME NULL,
        
        CONSTRAINT FK_Delivery_SalesOrder FOREIGN KEY (SalesOrderID) 
            REFERENCES SalesOrder(SalesOrderID),
        CONSTRAINT FK_Delivery_Employee FOREIGN KEY (DeliveredBy) 
            REFERENCES Employee(EmployeeID)
    );
    PRINT 'Table Delivery created successfully.';
END
GO

-- ================================================================================
-- Step 9: CREATE INDEXES FOR BETTER PERFORMANCE
-- ================================================================================

-- Indexes on Foreign Keys
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Employee_DepartmentID')
    CREATE NONCLUSTERED INDEX IX_Employee_DepartmentID ON Employee(DepartmentID);
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Employee_RoleID')
    CREATE NONCLUSTERED INDEX IX_Employee_RoleID ON Employee(RoleID);
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Stock_ProductID')
    CREATE NONCLUSTERED INDEX IX_Stock_ProductID ON Stock(ProductID);
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_SalesOrder_RetailerID')
    CREATE NONCLUSTERED INDEX IX_SalesOrder_RetailerID ON SalesOrder(RetailerID);
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_SalesOrder_SalesRepID')
    CREATE NONCLUSTERED INDEX IX_SalesOrder_SalesRepID ON SalesOrder(SalesRepID);
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_SalesOrderItem_SalesOrderID')
    CREATE NONCLUSTERED INDEX IX_SalesOrderItem_SalesOrderID ON SalesOrderItem(SalesOrderID);
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_ProductionOrder_ProductID')
    CREATE NONCLUSTERED INDEX IX_ProductionOrder_ProductID ON ProductionOrder(ProductID);
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_TailorTask_EmployeeID')
    CREATE NONCLUSTERED INDEX IX_TailorTask_EmployeeID ON TailorTask(EmployeeID);
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_TailorTask_ProductionOrderID')
    CREATE NONCLUSTERED INDEX IX_TailorTask_ProductionOrderID ON TailorTask(ProductionOrderID);
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Retailer_SalesRepID')
    CREATE NONCLUSTERED INDEX IX_Retailer_SalesRepID ON Retailer(SalesRepID);
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Deal_AssignedManagerID')
    CREATE NONCLUSTERED INDEX IX_Deal_AssignedManagerID ON Deal(AssignedManagerID);

PRINT 'Indexes created successfully.';
GO

-- ================================================================================
-- DATABASE CREATION COMPLETE!
-- ================================================================================
PRINT '========================================';
PRINT 'DATABASE CREATION COMPLETED SUCCESSFULLY!';
PRINT 'All 16 tables have been created.';
PRINT 'Tables match FRONTEND FORM FIELDS exactly.';
PRINT '';
PRINT 'NOTE: SalespersonDetails and TailorDetails';
PRINT 'have been MERGED into the Employee table.';
PRINT '========================================';
GO
