-- ================================================================================
-- GARMENTS FACTORY MANAGEMENT SYSTEM - COMPLETE DATABASE SCHEMA
-- ================================================================================
-- Database: GarmentsFactoryDB
-- Purpose: Comprehensive database schema with all tables, relationships, 
--          indexes, and constraints for garments factory management
-- Created: December 2025
-- ================================================================================

USE GarmentsFactoryDB;
GO

-- ================================================================================
-- PART 1: CORE REFERENCE TABLES
-- ================================================================================

-- TABLE: Department
-- Purpose: Store organizational departments (e.g., Production, Sales, Management)
-- Relationships: Referenced by Employee table
CREATE TABLE Department (
    DepartmentID INT PRIMARY KEY IDENTITY(1,1),          -- Unique identifier
    DepartmentName NVARCHAR(200) NOT NULL UNIQUE,        -- Department name (e.g., Production, Sales)
    Description NVARCHAR(1000) NULL,                     -- Department description
    CreatedDate DATETIME NULL DEFAULT GETDATE(),         -- Creation timestamp
    IsActive BIT NULL DEFAULT 1                          -- Flag to mark active/inactive departments
);
GO

-- TABLE: EmployeeRole
-- Purpose: Define employee roles and their descriptions
-- Relationships: Referenced by Employee table
CREATE TABLE EmployeeRole (
    RoleID INT PRIMARY KEY IDENTITY(1,1),                -- Unique role identifier
    RoleName NVARCHAR(100) NOT NULL UNIQUE,              -- Role name (e.g., Owner, Manager, Tailor)
    Description NVARCHAR(1000) NULL,                     -- Role description and permissions
    CreatedDate DATETIME NULL DEFAULT GETDATE(),         -- Creation timestamp
    IsActive BIT NULL DEFAULT 1                          -- Flag to mark active/inactive roles
);
GO

-- ================================================================================
-- PART 2: EMPLOYEE MANAGEMENT TABLES
-- ================================================================================

-- TABLE: Employee
-- Purpose: Store employee information with payroll and authentication details
-- Relationships: Foreign Keys to Department and EmployeeRole
CREATE TABLE Employee (
    EmployeeID INT PRIMARY KEY IDENTITY(1,1),            -- Unique employee identifier
    FirstName NVARCHAR(100) NOT NULL,                    -- Employee first name
    LastName NVARCHAR(100) NOT NULL,                     -- Employee last name
    Email NVARCHAR(200) NULL UNIQUE,                     -- Email address (unique)
    Phone NVARCHAR(40) NULL,                             -- Contact phone number
    DepartmentID INT NOT NULL,                           -- Foreign Key to Department
    RoleID INT NOT NULL,                                 -- Foreign Key to EmployeeRole
    Salary DECIMAL(18,2) NULL,                           -- Monthly salary amount
    JoinDate DATE NULL,                                  -- Date employee joined
    Address NVARCHAR(1000) NULL,                         -- Residential address
    EmergencyContact NVARCHAR(200) NULL,                 -- Emergency contact name
    CNIC NVARCHAR(30) NULL,                              -- National ID number
    IsActive BIT NULL DEFAULT 1,                         -- Employee status (active/inactive)
    CreatedDate DATETIME NULL DEFAULT GETDATE(),         -- Account creation date
    Username NVARCHAR(100) NULL UNIQUE,                  -- Login username
    LastLogin DATETIME NULL,                             -- Last login timestamp
    PIN NVARCHAR(8) NULL,                                -- Login PIN for quick access
    Specialization NVARCHAR(200) NULL,                   -- Job specialization (for tailors)
    PieceRate DECIMAL(18,2) NULL,                        -- Payment rate per piece (for tailors)
    TotalPiecesCompleted INT NULL,                       -- Total pieces completed by employee
    ShiftType NVARCHAR(100) NULL,                        -- Shift type (Morning, Evening, Night)
    Position NVARCHAR(200) NULL,                         -- Job position/designation
    
    -- Constraints
    CONSTRAINT FK_Employee_Department FOREIGN KEY (DepartmentID) REFERENCES Department(DepartmentID),
    CONSTRAINT FK_Employee_Role FOREIGN KEY (RoleID) REFERENCES EmployeeRole(RoleID)
);
GO

-- INDEX: Employee - Improve search performance
CREATE INDEX IX_Employee_Email ON Employee(Email);
CREATE INDEX IX_Employee_Department ON Employee(DepartmentID);
CREATE INDEX IX_Employee_Role ON Employee(RoleID);
CREATE INDEX IX_Employee_IsActive ON Employee(IsActive);
GO

-- ================================================================================
-- PART 3: PRODUCT & MATERIAL MANAGEMENT TABLES
-- ================================================================================

-- TABLE: Product
-- Purpose: Store garment products with specifications
-- Relationships: Referenced by SalesOrderItem, DealItem, ProductionOrder, Stock, TailorAssignment
CREATE TABLE Product (
    ProductID INT PRIMARY KEY IDENTITY(1,1),             -- Unique product identifier
    ProductName NVARCHAR(200) NOT NULL,                  -- Product name (e.g., Shirt, Pant)
    Description NVARCHAR(2000) NULL,                     -- Detailed product description
    Category NVARCHAR(100) NULL,                         -- Product category (e.g., Casual, Formal)
    Brand NVARCHAR(200) NULL,                            -- Brand name
    SalePrice DECIMAL(18,2) NOT NULL,                    -- Selling price per unit
    Material NVARCHAR(100) NULL,                         -- Material composition (e.g., Cotton 100%)
    AvailableSizes NVARCHAR(200) NULL,                   -- Available sizes (e.g., S, M, L, XL)
    AvailableColors NVARCHAR(400) NULL,                  -- Available colors (e.g., Red, Blue, Black)
    ProductionStatus NVARCHAR(60) NULL,                  -- Production status (Active, Discontinued)
    SKU NVARCHAR(100) NULL UNIQUE,                       -- Stock Keeping Unit for inventory
    IsActive BIT NULL DEFAULT 1,                         -- Product active/inactive flag
    CreatedDate DATETIME NULL DEFAULT GETDATE(),         -- Creation timestamp
    UpdatedDate DATETIME NULL,                           -- Last update timestamp
    
    -- Constraints
    CONSTRAINT UQ_Product_SKU UNIQUE (SKU)
);
GO

-- INDEX: Product - Improve search and filter performance
CREATE INDEX IX_Product_Category ON Product(Category);
CREATE INDEX IX_Product_IsActive ON Product(IsActive);
CREATE INDEX IX_Product_SKU ON Product(SKU);
GO

-- TABLE: RawMaterial
-- Purpose: Store raw materials inventory (fabrics, threads, buttons, etc.)
-- Relationships: Referenced by ProductMaterialRequirement, RawMaterialPurchase
CREATE TABLE RawMaterial (
    RawMaterialID INT PRIMARY KEY IDENTITY(1,1),         -- Unique material identifier
    MaterialName NVARCHAR(200) NOT NULL,                 -- Material name (e.g., Cotton Fabric)
    Category NVARCHAR(100) NULL,                         -- Category (e.g., Fabric, Thread, Buttons)
    Unit NVARCHAR(40) NULL,                              -- Unit of measurement (Meters, KG, Pieces)
    Quantity DECIMAL(18,2) NOT NULL,                     -- Current quantity in stock
    MinimumStock DECIMAL(18,2) NULL,                     -- Minimum threshold for reordering
    UnitPrice DECIMAL(18,2) NOT NULL,                    -- Price per unit
    Supplier NVARCHAR(200) NULL,                         -- Supplier name
    SupplierContact NVARCHAR(200) NULL,                  -- Supplier contact information
    Description NVARCHAR(1000) NULL,                     -- Material description
    StockStatus NVARCHAR(40) NULL,                       -- Status (In Stock, Low Stock, Out of Stock)
    LastRestockDate DATE NULL,                           -- Date of last restock
    IsActive BIT NULL DEFAULT 1,                         -- Material active/inactive flag
    CreatedDate DATETIME NULL DEFAULT GETDATE(),         -- Creation timestamp
    UpdatedDate DATETIME NULL                            -- Last update timestamp
);
GO

-- INDEX: RawMaterial - Improve inventory search and alerts
CREATE INDEX IX_RawMaterial_Category ON RawMaterial(Category);
CREATE INDEX IX_RawMaterial_Quantity ON RawMaterial(Quantity);
CREATE INDEX IX_RawMaterial_IsActive ON RawMaterial(IsActive);
GO

-- TABLE: RawMaterialPurchase
-- Purpose: Auto-record all raw material purchases (automated from sp_CreateRawMaterial, sp_RestockRawMaterial)
-- Relationships: Foreign Key to RawMaterial
CREATE TABLE RawMaterialPurchase (
    PurchaseID INT PRIMARY KEY IDENTITY(1,1),            -- Unique purchase identifier
    RawMaterialID INT NULL,                              -- Foreign Key to RawMaterial
    MaterialName NVARCHAR(200) NOT NULL,                 -- Material name (denormalized for history)
    PurchaseDate DATE NOT NULL,                          -- Date of purchase (auto-recorded)
    Quantity DECIMAL(18,2) NOT NULL,                     -- Quantity purchased
    Unit NVARCHAR(40) NULL,                              -- Unit of measurement
    UnitPrice DECIMAL(18,2) NOT NULL,                    -- Price per unit at time of purchase
    TotalAmount DECIMAL(18,2) NOT NULL,                  -- Total purchase amount (Quantity * UnitPrice)
    SupplierName NVARCHAR(200) NULL,                     -- Supplier name
    InvoiceNumber NVARCHAR(100) NULL,                    -- Invoice/Bill number for reference
    Notes NVARCHAR(1000) NULL,                           -- Additional notes (e.g., "Initial stock", "Restock")
    CreatedDate DATETIME NULL DEFAULT GETDATE(),         -- Record creation date
    
    -- Constraints
    CONSTRAINT FK_RawMaterialPurchase_Material FOREIGN KEY (RawMaterialID) REFERENCES RawMaterial(RawMaterialID)
);
GO

-- INDEX: RawMaterialPurchase - Improve purchase history and financial tracking
CREATE INDEX IX_RawMaterialPurchase_Date ON RawMaterialPurchase(PurchaseDate);
CREATE INDEX IX_RawMaterialPurchase_Material ON RawMaterialPurchase(RawMaterialID);
GO

-- TABLE: ProductMaterialRequirement
-- Purpose: Define which raw materials are needed to produce each product and in what quantities
-- Relationships: Foreign Keys to Product and RawMaterial
CREATE TABLE ProductMaterialRequirement (
    RequirementID INT PRIMARY KEY IDENTITY(1,1),         -- Unique requirement identifier
    ProductID INT NOT NULL,                              -- Foreign Key to Product
    RawMaterialID INT NOT NULL,                          -- Foreign Key to RawMaterial
    QuantityRequired DECIMAL(18,2) NOT NULL,             -- Quantity of material needed per product unit
    Unit NVARCHAR(100) NULL,                             -- Unit of measurement
    Notes NVARCHAR(1000) NULL,                           -- Additional notes
    CreatedDate DATETIME NULL DEFAULT GETDATE(),         -- Creation timestamp
    
    -- Constraints
    CONSTRAINT FK_ProductMaterialRequirement_Product FOREIGN KEY (ProductID) REFERENCES Product(ProductID),
    CONSTRAINT FK_ProductMaterialRequirement_RawMaterial FOREIGN KEY (RawMaterialID) REFERENCES RawMaterial(RawMaterialID),
    CONSTRAINT UQ_ProductMaterial UNIQUE (ProductID, RawMaterialID)  -- One requirement per product-material pair
);
GO

-- INDEX: ProductMaterialRequirement - Improve BOM lookups
CREATE INDEX IX_ProductMaterialRequirement_Product ON ProductMaterialRequirement(ProductID);
CREATE INDEX IX_ProductMaterialRequirement_Material ON ProductMaterialRequirement(RawMaterialID);
GO

-- ================================================================================
-- PART 4: SALES & RETAIL MANAGEMENT TABLES
-- ================================================================================

-- TABLE: Retailer
-- Purpose: Store retail customer information
-- Relationships: Referenced by SalesOrder
CREATE TABLE Retailer (
    RetailerID INT PRIMARY KEY IDENTITY(1,1),            -- Unique retailer identifier
    CompanyName NVARCHAR(200) NOT NULL,                  -- Company/Store name
    ContactPerson NVARCHAR(200) NULL,                    -- Contact person name
    Phone NVARCHAR(40) NULL,                             -- Primary phone number
    Email NVARCHAR(200) NULL,                            -- Email address
    AlternativePhone NVARCHAR(40) NULL,                  -- Alternative phone number
    Address NVARCHAR(1000) NULL,                         -- Street address
    City NVARCHAR(100) NULL,                             -- City
    Province NVARCHAR(100) NULL,                         -- Province/State
    PostalCode NVARCHAR(20) NULL,                        -- Postal code
    Status NVARCHAR(40) NULL,                            -- Status (Active, Inactive, Blacklisted)
    IsActive BIT NULL DEFAULT 1,                         -- Retailer active/inactive flag
    CreatedDate DATETIME NULL DEFAULT GETDATE(),         -- Creation timestamp
    UpdatedDate DATETIME NULL                            -- Last update timestamp
);
GO

-- INDEX: Retailer - Improve customer lookups and filtering
CREATE INDEX IX_Retailer_City ON Retailer(City);
CREATE INDEX IX_Retailer_Status ON Retailer(Status);
CREATE INDEX IX_Retailer_IsActive ON Retailer(IsActive);
GO

-- TABLE: SalesOrder
-- Purpose: Store sales orders from retailers
-- Relationships: Foreign Keys to Retailer and Employee (SalesRep), referenced by SalesOrderItem, Delivery, TailorAssignment
CREATE TABLE SalesOrder (
    SalesOrderID INT PRIMARY KEY IDENTITY(1,1),          -- Unique sales order identifier
    OrderDate DATETIME NULL,                             -- Date order was created
    Status NVARCHAR(60) NULL,                            -- Order status (Pending, Confirmed, Approved, Shipped, Delivered, Rejected, Cancelled)
    RetailerID INT NOT NULL,                             -- Foreign Key to Retailer
    ShippingAddress NVARCHAR(1000) NULL,                 -- Delivery address
    DiscountPercentage DECIMAL(5,2) NULL,                -- Discount percentage applied
    SubTotal DECIMAL(18,2) NULL,                         -- Subtotal before discount
    DiscountAmount DECIMAL(18,2) NULL,                   -- Discount amount
    TotalAmount DECIMAL(18,2) NOT NULL,                  -- Total order amount (auto-calculated from items)
    SalesRepID INT NULL,                                 -- Foreign Key to Employee (Salesperson)
    CreatedDate DATETIME NULL DEFAULT GETDATE(),         -- Creation timestamp
    UpdatedDate DATETIME NULL,                           -- Last update timestamp
    
    -- Constraints
    CONSTRAINT FK_SalesOrder_Retailer FOREIGN KEY (RetailerID) REFERENCES Retailer(RetailerID),
    CONSTRAINT FK_SalesOrder_SalesRep FOREIGN KEY (SalesRepID) REFERENCES Employee(EmployeeID)
);
GO

-- INDEX: SalesOrder - Improve order tracking and filtering
CREATE INDEX IX_SalesOrder_Date ON SalesOrder(OrderDate);
CREATE INDEX IX_SalesOrder_Status ON SalesOrder(Status);
CREATE INDEX IX_SalesOrder_Retailer ON SalesOrder(RetailerID);
CREATE INDEX IX_SalesOrder_SalesRep ON SalesOrder(SalesRepID);
GO

-- TABLE: SalesOrderItem
-- Purpose: Line items for each sales order (what products, quantities, prices)
-- Relationships: Foreign Keys to SalesOrder and Product
CREATE TABLE SalesOrderItem (
    SalesOrderItemID INT PRIMARY KEY IDENTITY(1,1),      -- Unique line item identifier
    SalesOrderID INT NOT NULL,                           -- Foreign Key to SalesOrder
    ProductID INT NOT NULL,                              -- Foreign Key to Product
    Size NVARCHAR(40) NULL,                              -- Product size (S, M, L, XL)
    Color NVARCHAR(100) NULL,                            -- Product color
    Quantity INT NOT NULL,                               -- Quantity ordered
    UnitPrice DECIMAL(18,2) NOT NULL,                    -- Price per unit at time of order
    Discount DECIMAL(18,2) NULL,                         -- Item-level discount
    TotalPrice DECIMAL(18,2) NULL,                       -- Total for this item (Quantity * UnitPrice - Discount)
    
    -- Constraints
    CONSTRAINT FK_SalesOrderItem_SalesOrder FOREIGN KEY (SalesOrderID) REFERENCES SalesOrder(SalesOrderID) ON DELETE CASCADE,
    CONSTRAINT FK_SalesOrderItem_Product FOREIGN KEY (ProductID) REFERENCES Product(ProductID)
);
GO

-- INDEX: SalesOrderItem - Improve order detail lookups
CREATE INDEX IX_SalesOrderItem_SalesOrder ON SalesOrderItem(SalesOrderID);
CREATE INDEX IX_SalesOrderItem_Product ON SalesOrderItem(ProductID);
GO

-- ================================================================================
-- PART 5: DEALS & SPECIAL PROJECTS TABLES
-- ================================================================================

-- TABLE: Deal
-- Purpose: Store special deals, bulk orders, and special projects
-- Relationships: Foreign Key to Employee (CreatedBy), referenced by DealItem, Delivery, TailorAssignment
CREATE TABLE Deal (
    DealID INT PRIMARY KEY IDENTITY(1,1),                -- Unique deal identifier
    DealTitle NVARCHAR(200) NOT NULL,                    -- Deal title/name
    DealType NVARCHAR(100) NULL,                         -- Type of deal (Bulk Order, Export, Corporate, Event)
    ClientName NVARCHAR(200) NULL,                       -- Client name
    ContactPerson NVARCHAR(200) NULL,                    -- Contact person at client organization
    Email NVARCHAR(200) NULL,                            -- Contact email
    Phone NVARCHAR(40) NULL,                             -- Contact phone
    ExpectedDuration NVARCHAR(100) NULL,                 -- Duration of project (e.g., "3 months")
    StartDate DATE NULL,                                 -- Project start date
    EndDate DATE NULL,                                   -- Project end date
    Description NVARCHAR(2000) NULL,                     -- Deal description
    Status NVARCHAR(60) NULL,                            -- Status (Pending, Approved, Active, Completed, Cancelled, Rejected)
    CreatedBy INT NULL,                                  -- Foreign Key to Employee (who created deal)
    DeliveryAddress NVARCHAR(1000) NULL,                 -- Delivery address
    City NVARCHAR(200) NULL,                             -- City
    Province NVARCHAR(200) NULL,                         -- Province
    TotalAmount DECIMAL(18,2) NULL,                      -- Total deal amount (auto-calculated from items)
    CreatedDate DATETIME NULL DEFAULT GETDATE(),         -- Creation timestamp
    UpdatedDate DATETIME NULL,                           -- Last update timestamp
    
    -- Constraints
    CONSTRAINT FK_Deal_CreatedBy FOREIGN KEY (CreatedBy) REFERENCES Employee(EmployeeID)
);
GO

-- INDEX: Deal - Improve deal tracking and filtering
CREATE INDEX IX_Deal_Status ON Deal(Status);
CREATE INDEX IX_Deal_StartDate ON Deal(StartDate);
CREATE INDEX IX_Deal_CreatedBy ON Deal(CreatedBy);
GO

-- TABLE: DealItem
-- Purpose: Line items for each deal (what products, quantities, prices)
-- Relationships: Foreign Keys to Deal and Product
CREATE TABLE DealItem (
    DealItemID INT PRIMARY KEY IDENTITY(1,1),            -- Unique line item identifier
    DealID INT NOT NULL,                                 -- Foreign Key to Deal
    ProductID INT NOT NULL,                              -- Foreign Key to Product
    Quantity INT NOT NULL,                               -- Quantity in deal
    UnitPrice DECIMAL(18,2) NOT NULL,                    -- Price per unit
    
    -- Constraints
    CONSTRAINT FK_DealItem_Deal FOREIGN KEY (DealID) REFERENCES Deal(DealID) ON DELETE CASCADE,
    CONSTRAINT FK_DealItem_Product FOREIGN KEY (ProductID) REFERENCES Product(ProductID)
);
GO

-- INDEX: DealItem - Improve deal detail lookups
CREATE INDEX IX_DealItem_Deal ON DealItem(DealID);
CREATE INDEX IX_DealItem_Product ON DealItem(ProductID);
GO

-- ================================================================================
-- PART 6: PRODUCTION & MANUFACTURING TABLES
-- ================================================================================

-- TABLE: ProductionOrder
-- Purpose: Track manufacturing orders created from approved sales orders and deals
-- Relationships: Foreign Keys to Product and Employee
CREATE TABLE ProductionOrder (
    ProductionOrderID INT PRIMARY KEY IDENTITY(1,1),     -- Unique production order identifier
    ProductID INT NOT NULL,                              -- Foreign Key to Product
    QuantityOrdered INT NOT NULL,                        -- Total quantity to produce
    QuantityCompleted INT NULL DEFAULT 0,                -- Quantity completed so far
    StartDate DATE NULL,                                 -- Production start date
    ExpectedEndDate DATE NULL,                           -- Expected completion date
    ActualEndDate DATE NULL,                             -- Actual completion date
    Status NVARCHAR(100) NULL,                           -- Status (Pending, In Progress, Completed, On Hold)
    Priority NVARCHAR(40) NULL,                          -- Priority (Low, Normal, High, Urgent)
    Notes NVARCHAR(1000) NULL,                           -- Special instructions
    CreatedByEmployeeID INT NULL,                        -- Foreign Key to Employee (who created order)
    CreatedDate DATETIME NULL DEFAULT GETDATE(),         -- Creation timestamp
    UpdatedDate DATETIME NULL,                           -- Last update timestamp
    
    -- Constraints
    CONSTRAINT FK_ProductionOrder_Product FOREIGN KEY (ProductID) REFERENCES Product(ProductID),
    CONSTRAINT FK_ProductionOrder_Employee FOREIGN KEY (CreatedByEmployeeID) REFERENCES Employee(EmployeeID)
);
GO

-- INDEX: ProductionOrder - Improve production tracking
CREATE INDEX IX_ProductionOrder_Status ON ProductionOrder(Status);
CREATE INDEX IX_ProductionOrder_Product ON ProductionOrder(ProductID);
CREATE INDEX IX_ProductionOrder_Priority ON ProductionOrder(Priority);
GO

-- TABLE: TailorAssignment
-- Purpose: Assign production tasks to tailors/employees
-- Relationships: Foreign Keys to Employee, ProductionOrder, Product, SalesOrder, Deal
CREATE TABLE TailorAssignment (
    AssignmentID INT PRIMARY KEY IDENTITY(1,1),          -- Unique assignment identifier
    TailorID INT NOT NULL,                               -- Foreign Key to Employee (Tailor)
    ProductionOrderID INT NULL,                          -- Foreign Key to ProductionOrder
    SalesOrderID INT NULL,                               -- Foreign Key to SalesOrder (if from SO)
    DealID INT NULL,                                     -- Foreign Key to Deal (if from Deal)
    ProductID INT NULL,                                  -- Foreign Key to Product
    QuantityAssigned INT NOT NULL,                       -- Quantity to produce
    AssignedDate DATETIME NULL,                          -- Date assignment was made
    CompletedDate DATETIME NULL,                         -- Date assignment was completed
    Status NVARCHAR(100) NULL,                           -- Status (Incomplete, Completed, On Hold)
    
    -- Constraints
    CONSTRAINT FK_TailorAssignment_Tailor FOREIGN KEY (TailorID) REFERENCES Employee(EmployeeID),
    CONSTRAINT FK_TailorAssignment_ProductionOrder FOREIGN KEY (ProductionOrderID) REFERENCES ProductionOrder(ProductionOrderID),
    CONSTRAINT FK_TailorAssignment_Product FOREIGN KEY (ProductID) REFERENCES Product(ProductID),
    CONSTRAINT FK_TailorAssignment_Deal FOREIGN KEY (DealID) REFERENCES Deal(DealID),
    CONSTRAINT FK_TailorAssignment_SalesOrder FOREIGN KEY (SalesOrderID) REFERENCES SalesOrder(SalesOrderID)
);
GO

-- INDEX: TailorAssignment - Improve assignment tracking and tailor workload
CREATE INDEX IX_TailorAssignment_Tailor ON TailorAssignment(TailorID);
CREATE INDEX IX_TailorAssignment_Status ON TailorAssignment(Status);
CREATE INDEX IX_TailorAssignment_AssignedDate ON TailorAssignment(AssignedDate);
GO

-- ================================================================================
-- PART 7: INVENTORY & STOCK MANAGEMENT TABLES
-- ================================================================================

-- TABLE: Stock
-- Purpose: Track finished product inventory in warehouse
-- Relationships: Foreign Keys to Product and Employee
CREATE TABLE Stock (
    StockID INT PRIMARY KEY IDENTITY(1,1),               -- Unique stock entry identifier
    ProductID INT NOT NULL,                              -- Foreign Key to Product
    BatchNo NVARCHAR(100) NOT NULL,                      -- Batch/Production number for traceability
    EntryDate DATETIME NULL,                             -- Date stock was added
    Quantity INT NOT NULL,                               -- Quantity in this batch
    StockStatus NVARCHAR(60) NULL,                       -- Status (In Stock, Reserved, Damaged, Returned)
    ProgressPercentage INT NULL,                         -- Production progress percentage
    Location NVARCHAR(200) NULL,                         -- Warehouse location/shelf
    Notes NVARCHAR(1000) NULL,                           -- Additional notes
    CreatedBy INT NULL,                                  -- Foreign Key to Employee (who created entry)
    LastUpdated DATETIME NULL,                           -- Last update timestamp
    CreatedDate DATETIME NULL DEFAULT GETDATE(),         -- Creation timestamp
    
    -- Constraints
    CONSTRAINT FK_Stock_Product FOREIGN KEY (ProductID) REFERENCES Product(ProductID),
    CONSTRAINT FK_Stock_Employee FOREIGN KEY (CreatedBy) REFERENCES Employee(EmployeeID)
);
GO

-- INDEX: Stock - Improve inventory tracking and warehouse management
CREATE INDEX IX_Stock_Product ON Stock(ProductID);
CREATE INDEX IX_Stock_Location ON Stock(Location);
CREATE INDEX IX_Stock_Status ON Stock(StockStatus);
GO

-- ================================================================================
-- PART 8: DELIVERY & LOGISTICS TABLES
-- ================================================================================

-- TABLE: Delivery
-- Purpose: Track delivery of sales orders and deals to customers
-- Relationships: Foreign Keys to SalesOrder, Deal, and Employee (DeliveredBy)
CREATE TABLE Delivery (
    DeliveryID INT PRIMARY KEY IDENTITY(1,1),            -- Unique delivery identifier
    SalesOrderID INT NULL,                               -- Foreign Key to SalesOrder (if applicable)
    DealID INT NULL,                                     -- Foreign Key to Deal (if applicable)
    DeliveredBy INT NULL,                                -- Foreign Key to Employee (Delivery person)
    DeliveryDate DATETIME NULL,                          -- Date of delivery
    DeliveryAddress NVARCHAR(1000) NULL,                 -- Delivery address
    City NVARCHAR(200) NULL,                             -- City
    Province NVARCHAR(200) NULL,                         -- Province
    PostalCode NVARCHAR(40) NULL,                        -- Postal code
    Status NVARCHAR(100) NULL,                           -- Status (Pending, In Transit, Delivered, Failed, Returned)
    ReceiverName NVARCHAR(400) NULL,                     -- Name of person who received delivery
    ReceiverPhone NVARCHAR(40) NULL,                     -- Receiver's phone number
    Notes NVARCHAR(1000) NULL,                           -- Delivery notes
    CreatedDate DATETIME NULL DEFAULT GETDATE(),         -- Creation timestamp
    UpdatedDate DATETIME NULL,                           -- Last update timestamp
    
    -- Constraints
    CONSTRAINT FK_Delivery_SalesOrder FOREIGN KEY (SalesOrderID) REFERENCES SalesOrder(SalesOrderID),
    CONSTRAINT FK_Delivery_Deal FOREIGN KEY (DealID) REFERENCES Deal(DealID),
    CONSTRAINT FK_Delivery_Employee FOREIGN KEY (DeliveredBy) REFERENCES Employee(EmployeeID)
);
GO

-- INDEX: Delivery - Improve delivery tracking and logistics
CREATE INDEX IX_Delivery_Status ON Delivery(Status);
CREATE INDEX IX_Delivery_Date ON Delivery(DeliveryDate);
CREATE INDEX IX_Delivery_SalesOrder ON Delivery(SalesOrderID);
CREATE INDEX IX_Delivery_Deal ON Delivery(DealID);
GO

-- ================================================================================
-- PART 9: FINANCIAL & REVENUE MANAGEMENT TABLES
-- ================================================================================

-- TABLE: SalaryPayment
-- Purpose: Record monthly salary payments to employees (auto-calculated and paid)
-- Relationships: Foreign Key to Employee
CREATE TABLE SalaryPayment (
    PaymentID INT PRIMARY KEY IDENTITY(1,1),             -- Unique payment identifier
    PaymentDate DATE NOT NULL,                           -- Date of payment
    PaymentMonth INT NOT NULL,                           -- Month (1-12)
    PaymentYear INT NOT NULL,                            -- Year
    TotalAmount DECIMAL(18,2) NOT NULL,                  -- Total amount paid (all employees)
    EmployeeCount INT NOT NULL,                          -- Number of employees paid
    Notes NVARCHAR(1000) NULL,                           -- Payment notes
    CreatedDate DATETIME NULL DEFAULT GETDATE()          -- Record creation date
);
GO

-- INDEX: SalaryPayment - Improve financial tracking
CREATE INDEX IX_SalaryPayment_Date ON SalaryPayment(PaymentDate);
CREATE INDEX IX_SalaryPayment_Month ON SalaryPayment(PaymentMonth, PaymentYear);
GO

-- TABLE: MiscExpense
-- Purpose: Track miscellaneous expenses (utilities, maintenance, etc.)
-- Relationships: No direct foreign keys
CREATE TABLE MiscExpense (
    ExpenseID INT PRIMARY KEY IDENTITY(1,1),             -- Unique expense identifier
    ExpenseDate DATE NOT NULL,                           -- Date expense was incurred
    Amount DECIMAL(18,2) NOT NULL,                       -- Expense amount
    Category NVARCHAR(100) NULL,                         -- Category (Utilities, Maintenance, Office Supplies)
    Description NVARCHAR(1000) NULL,                     -- Detailed description
    PaidTo NVARCHAR(200) NULL,                           -- Paid to (vendor name)
    PaymentMethod NVARCHAR(100) NULL,                    -- Payment method (Cash, Check, Bank Transfer)
    ReceiptNumber NVARCHAR(100) NULL,                    -- Receipt/Invoice number
    CreatedDate DATETIME NULL DEFAULT GETDATE()          -- Record creation date
);
GO

-- INDEX: MiscExpense - Improve expense tracking
CREATE INDEX IX_MiscExpense_Date ON MiscExpense(ExpenseDate);
CREATE INDEX IX_MiscExpense_Category ON MiscExpense(Category);
GO

-- TABLE: MonthlyRevenue
-- Purpose: Store monthly financial summary (auto-calculated from all transactions)
-- Relationships: None (summary table)
CREATE TABLE MonthlyRevenue (
    RevenueID INT PRIMARY KEY IDENTITY(1,1),             -- Unique revenue record identifier
    Year INT NOT NULL,                                   -- Year
    Month INT NOT NULL,                                  -- Month (1-12)
    MonthName NVARCHAR(40) NULL,                         -- Month name (January, February, etc.)
    SalesIncome DECIMAL(18,2) NULL,                      -- Income from sales orders
    DealIncome DECIMAL(18,2) NULL,                       -- Income from deals
    SalariesPaid BIT NULL,                               -- Flag: salaries paid for this month
    TotalSalaries DECIMAL(18,2) NULL,                    -- Total salaries paid
    RawMaterialCost DECIMAL(18,2) NULL,                  -- Cost of raw materials purchased
    MiscExpense DECIMAL(18,2) NULL,                      -- Miscellaneous expenses
    TotalIncome DECIMAL(18,2) NULL,                      -- Total income (SalesIncome + DealIncome)
    TotalExpense DECIMAL(18,2) NULL,                     -- Total expenses (Salaries + Materials + Misc)
    NetProfit DECIMAL(18,2) NULL,                        -- Net profit (TotalIncome - TotalExpense)
    Notes NVARCHAR(1000) NULL,                           -- Notes about the month
    CreatedDate DATETIME NULL DEFAULT GETDATE(),         -- Record creation date
    UpdatedDate DATETIME NULL,                           -- Last update timestamp
    
    -- Unique constraint to ensure one record per month
    CONSTRAINT UQ_MonthlyRevenue UNIQUE (Year, Month)
);
GO

-- INDEX: MonthlyRevenue - Improve financial reporting
CREATE INDEX IX_MonthlyRevenue_Period ON MonthlyRevenue(Year, Month);
GO

-- ================================================================================
-- PART 10: WORKFLOW & APPROVAL TABLES
-- ================================================================================

-- TABLE: OrderApproval
-- Purpose: Track approval workflow for sales orders and deals before production
-- Relationships: Foreign Keys to Employee
CREATE TABLE OrderApproval (
    ApprovalID INT PRIMARY KEY IDENTITY(1,1),            -- Unique approval identifier
    SalesOrderID INT NULL,                               -- Foreign Key to SalesOrder (for SO approvals)
    DealID INT NULL,                                     -- Foreign Key to Deal (for Deal approvals)
    ApprovedBy INT NULL,                                 -- Foreign Key to Employee (who approved)
    ApprovalStatus NVARCHAR(100) NULL,                   -- Approval status (Approved, Rejected, Pending)
    ApprovalDate DATETIME NULL,                          -- Date of approval decision
    Comments NVARCHAR(1000) NULL,                        -- Approval comments
    CreatedDate DATETIME NULL DEFAULT GETDATE(),         -- Approval request creation date
    OrderType NVARCHAR(100) NULL,                        -- Order type (SalesOrder, Deal)
    OrderID INT NULL,                                    -- Generic order ID reference
    RequestedByEmployeeID INT NULL,                      -- Foreign Key to Employee (who requested approval)
    Status NVARCHAR(100) NULL,                           -- Status (Pending, Approved, Rejected)
    RequestDate DATETIME NULL,                           -- Date approval was requested
    
    -- Constraints
    CONSTRAINT FK_OrderApproval_ApprovedBy FOREIGN KEY (ApprovedBy) REFERENCES Employee(EmployeeID),
    CONSTRAINT FK_OrderApproval_RequestedBy FOREIGN KEY (RequestedByEmployeeID) REFERENCES Employee(EmployeeID)
);
GO

-- INDEX: OrderApproval - Improve approval workflow tracking
CREATE INDEX IX_OrderApproval_Status ON OrderApproval(Status);
CREATE INDEX IX_OrderApproval_Date ON OrderApproval(RequestDate);
CREATE INDEX IX_OrderApproval_OrderType ON OrderApproval(OrderType);
GO

-- ================================================================================
-- PART 11: SYSTEM TABLES (Auto-generated by SQL Server)
-- ================================================================================

-- TABLE: sysdiagrams
-- Purpose: Stores database diagram information (created by SQL Server Management Studio)
-- Note: This table is auto-created and should not be manually modified
-- It is included here for completeness in the schema documentation

-- ================================================================================
-- PART 12: DATABASE CONSTRAINTS & RELATIONSHIPS SUMMARY
-- ================================================================================

/*
FOREIGN KEY RELATIONSHIPS:

1. EMPLOYEE MANAGEMENT:
   - Employee.DepartmentID → Department.DepartmentID
   - Employee.RoleID → EmployeeRole.RoleID

2. PRODUCT & MATERIALS:
   - ProductMaterialRequirement.ProductID → Product.ProductID
   - ProductMaterialRequirement.RawMaterialID → RawMaterial.RawMaterialID
   - RawMaterialPurchase.RawMaterialID → RawMaterial.RawMaterialID

3. SALES:
   - SalesOrder.RetailerID → Retailer.RetailerID
   - SalesOrder.SalesRepID → Employee.EmployeeID
   - SalesOrderItem.SalesOrderID → SalesOrder.SalesOrderID (CASCADE DELETE)
   - SalesOrderItem.ProductID → Product.ProductID

4. DEALS:
   - Deal.CreatedBy → Employee.EmployeeID
   - DealItem.DealID → Deal.DealID (CASCADE DELETE)
   - DealItem.ProductID → Product.ProductID

5. PRODUCTION:
   - ProductionOrder.ProductID → Product.ProductID
   - ProductionOrder.CreatedByEmployeeID → Employee.EmployeeID
   - TailorAssignment.TailorID → Employee.EmployeeID
   - TailorAssignment.ProductionOrderID → ProductionOrder.ProductionOrderID
   - TailorAssignment.ProductID → Product.ProductID
   - TailorAssignment.SalesOrderID → SalesOrder.SalesOrderID
   - TailorAssignment.DealID → Deal.DealID

6. INVENTORY:
   - Stock.ProductID → Product.ProductID
   - Stock.CreatedBy → Employee.EmployeeID

7. DELIVERY:
   - Delivery.SalesOrderID → SalesOrder.SalesOrderID
   - Delivery.DealID → Deal.DealID
   - Delivery.DeliveredBy → Employee.EmployeeID

8. WORKFLOW:
   - OrderApproval.ApprovedBy → Employee.EmployeeID
   - OrderApproval.RequestedByEmployeeID → Employee.EmployeeID
*/

-- ================================================================================
-- PART 13: KEY AUTOMATION FEATURES
-- ================================================================================

/*
AUTOMATED PROCESSES (Implemented via Stored Procedures):

1. RAW MATERIAL PURCHASES (AUTO-RECORDED):
   - When new raw material is added via sp_CreateRawMaterial → RawMaterialPurchase record created
   - When stock is restocked via sp_RestockRawMaterial → RawMaterialPurchase record created
   - When stock is updated via sp_UpdateRawMaterial → RawMaterialPurchase record created for quantity increase
   - Formula: TotalAmount = Quantity × UnitPrice

2. ORDER TOTALS (AUTO-CALCULATED):
   - When sales order items are added → SalesOrder.TotalAmount automatically updated
   - When deal items are added → Deal.TotalAmount automatically updated
   - Uses SUM(Quantity × UnitPrice) from line items

3. MONTHLY REVENUE (AUTO-CALCULATED):
   - SalesIncome = SUM(SalesOrder.TotalAmount) for non-cancelled orders
   - DealIncome = SUM(Deal.TotalAmount) for non-cancelled deals
   - RawMaterialCost = SUM(RawMaterialPurchase.TotalAmount) for the month
   - TotalSalaries = SUM(SalaryPayment) for the month
   - MiscExpense = SUM(MiscExpense.Amount) for the month
   - NetProfit = TotalIncome - TotalExpense

4. SALARY PAYMENTS (AUTO-PAID):
   - sp_AutoPayPastSalaries automatically pays unpaid monthly salaries
   - Creates SalaryPayment record for each month
   - Deducts from revenue tracking

5. ORDER APPROVALS:
   - Sales orders and deals automatically create approval requests
   - Requires approval before production can start
   - Checks material availability before approval
*/

-- ================================================================================
-- END OF DATABASE SCHEMA DEFINITION
-- ================================================================================
-- Last Updated: December 2025
-- All procedures, indexes, and constraints defined above
-- For more information, see Database stored procedures (sp_* files)
-- ================================================================================
