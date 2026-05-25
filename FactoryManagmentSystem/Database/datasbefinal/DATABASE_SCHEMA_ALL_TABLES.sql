-- =============================================
-- COMPLETE DATABASE SCHEMA
-- GarmentsFactoryDB - All Tables
-- Generated: December 17, 2025
-- =============================================

USE master;
GO

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'GarmentsFactoryDB')
BEGIN
    CREATE DATABASE GarmentsFactoryDB;
END
GO

USE GarmentsFactoryDB;
GO

-- =============================================
-- TABLE 1: EmployeeRole
-- Purpose: Define employee job roles
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'EmployeeRole') AND type = 'U')
BEGIN
    CREATE TABLE EmployeeRole (
        RoleID INT PRIMARY KEY IDENTITY(1,1),
        RoleName NVARCHAR(100) NOT NULL UNIQUE,
        Description NVARCHAR(500),
        CreatedDate DATETIME DEFAULT GETDATE(),
        IsActive BIT DEFAULT 1
    );
END
GO

-- =============================================
-- TABLE 2: Department
-- Purpose: Organizational departments
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'Department') AND type = 'U')
BEGIN
    CREATE TABLE Department (
        DepartmentID INT PRIMARY KEY IDENTITY(1,1),
        DepartmentName NVARCHAR(200) NOT NULL UNIQUE,
        Description NVARCHAR(1000),
        CreatedDate DATETIME DEFAULT GETDATE(),
        IsActive BIT DEFAULT 1
    );
END
GO

-- =============================================
-- TABLE 3: Employee
-- Purpose: Core employee information
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'Employee') AND type = 'U')
BEGIN
    CREATE TABLE Employee (
        EmployeeID INT PRIMARY KEY IDENTITY(1,1),
        FirstName NVARCHAR(100) NOT NULL,
        LastName NVARCHAR(100),
        Email NVARCHAR(200) UNIQUE,
        Phone NVARCHAR(20),
        DepartmentID INT,
        RoleID INT,
        Salary DECIMAL(18,2) DEFAULT 0,
        JoinDate DATE DEFAULT GETDATE(),
        Address NVARCHAR(500),
        EmergencyContact NVARCHAR(100),
        CNIC NVARCHAR(20) UNIQUE,
        IsActive BIT DEFAULT 1,
        CreatedDate DATETIME DEFAULT GETDATE(),
        Username NVARCHAR(100) UNIQUE,
        LastLogin DATETIME,
        PIN NVARCHAR(10),
        Position NVARCHAR(100),
        FOREIGN KEY (DepartmentID) REFERENCES Department(DepartmentID),
        FOREIGN KEY (RoleID) REFERENCES EmployeeRole(RoleID)
    );
END
GO

-- =============================================
-- TABLE 4: Retailer
-- Purpose: Customer/Retailer information
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'Retailer') AND type = 'U')
BEGIN
    CREATE TABLE Retailer (
        RetailerID INT PRIMARY KEY IDENTITY(1,1),
        ContactPerson NVARCHAR(200) NOT NULL,
        Phone NVARCHAR(20),
        Email NVARCHAR(200),
        Address NVARCHAR(500),
        City NVARCHAR(100),
        Province NVARCHAR(100),
        BusinessName NVARCHAR(300),
        CreatedDate DATETIME DEFAULT GETDATE(),
        IsActive BIT DEFAULT 1
    );
END
GO

-- =============================================
-- TABLE 5: Product
-- Purpose: Product catalog
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'Product') AND type = 'U')
BEGIN
    CREATE TABLE Product (
        ProductID INT PRIMARY KEY IDENTITY(1,1),
        ProductName NVARCHAR(300) NOT NULL,
        Description NVARCHAR(1000),
        Category NVARCHAR(100),
        Brand NVARCHAR(100),
        SalePrice DECIMAL(18,2) NOT NULL,
        Material NVARCHAR(200),
        AvailableSizes NVARCHAR(200),
        AvailableColors NVARCHAR(200),
        ProductionStatus NVARCHAR(50) DEFAULT 'Available',
        SKU NVARCHAR(100) UNIQUE,
        IsActive BIT DEFAULT 1,
        CreatedDate DATETIME DEFAULT GETDATE(),
        UpdatedDate DATETIME
    );
END
GO

-- =============================================
-- TABLE 6: SalesOrder
-- Purpose: Retail sales orders
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'SalesOrder') AND type = 'U')
BEGIN
    CREATE TABLE SalesOrder (
        SalesOrderID INT PRIMARY KEY IDENTITY(1,1),
        RetailerID INT,
        SalesRepID INT,
        OrderDate DATETIME DEFAULT GETDATE(),
        TotalAmount DECIMAL(18,2) DEFAULT 0,
        Status NVARCHAR(50) DEFAULT 'Pending',
        ShippingAddress NVARCHAR(500),
        CreatedDate DATETIME DEFAULT GETDATE(),
        UpdatedDate DATETIME,
        FOREIGN KEY (RetailerID) REFERENCES Retailer(RetailerID),
        FOREIGN KEY (SalesRepID) REFERENCES Employee(EmployeeID)
    );
END
GO

-- =============================================
-- TABLE 7: SalesOrderItem
-- Purpose: Line items for sales orders
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'SalesOrderItem') AND type = 'U')
BEGIN
    CREATE TABLE SalesOrderItem (
        SalesOrderItemID INT PRIMARY KEY IDENTITY(1,1),
        SalesOrderID INT NOT NULL,
        ProductID INT NOT NULL,
        Quantity INT NOT NULL CHECK (Quantity > 0),
        UnitPrice DECIMAL(18,2) NOT NULL CHECK (UnitPrice >= 0),
        TotalPrice AS (Quantity * UnitPrice) PERSISTED,
        FOREIGN KEY (SalesOrderID) REFERENCES SalesOrder(SalesOrderID) ON DELETE CASCADE,
        FOREIGN KEY (ProductID) REFERENCES Product(ProductID)
    );
END
GO

-- =============================================
-- TABLE 8: Deal
-- Purpose: Bulk/contract orders
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'Deal') AND type = 'U')
BEGIN
    CREATE TABLE Deal (
        DealID INT PRIMARY KEY IDENTITY(1,1),
        DealTitle NVARCHAR(500) NOT NULL,
        ClientName NVARCHAR(300) NOT NULL,
        ContactPerson NVARCHAR(200),
        Phone NVARCHAR(20),
        StartDate DATETIME DEFAULT GETDATE(),
        EndDate DATETIME,
        TotalAmount DECIMAL(18,2) DEFAULT 0,
        Status NVARCHAR(50) DEFAULT 'Pending',
        DeliveryAddress NVARCHAR(500),
        City NVARCHAR(100),
        Province NVARCHAR(100),
        CreatedBy INT,
        CreatedDate DATETIME DEFAULT GETDATE(),
        UpdatedDate DATETIME,
        FOREIGN KEY (CreatedBy) REFERENCES Employee(EmployeeID)
    );
END
GO

-- =============================================
-- TABLE 9: DealItem
-- Purpose: Line items for deals
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'DealItem') AND type = 'U')
BEGIN
    CREATE TABLE DealItem (
        DealItemID INT PRIMARY KEY IDENTITY(1,1),
        DealID INT NOT NULL,
        ProductID INT NOT NULL,
        Quantity INT NOT NULL CHECK (Quantity > 0),
        UnitPrice DECIMAL(18,2) NOT NULL CHECK (UnitPrice >= 0),
        TotalPrice AS (Quantity * UnitPrice) PERSISTED,
        FOREIGN KEY (DealID) REFERENCES Deal(DealID) ON DELETE CASCADE,
        FOREIGN KEY (ProductID) REFERENCES Product(ProductID)
    );
END
GO

-- =============================================
-- TABLE 10: OrderApproval
-- Purpose: Order approval workflow
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'OrderApproval') AND type = 'U')
BEGIN
    CREATE TABLE OrderApproval (
        ApprovalID INT PRIMARY KEY IDENTITY(1,1),
        SalesOrderID INT NULL,
        DealID INT NULL,
        ApprovedBy INT NULL,
        ApprovalStatus NVARCHAR(50),
        ApprovalDate DATETIME,
        Comments NVARCHAR(1000),
        CreatedDate DATETIME DEFAULT GETDATE(),
        OrderType NVARCHAR(50),
        OrderID INT,
        RequestedByEmployeeID INT,
        Status NVARCHAR(50),
        RequestDate DATETIME,
        FOREIGN KEY (SalesOrderID) REFERENCES SalesOrder(SalesOrderID),
        FOREIGN KEY (DealID) REFERENCES Deal(DealID),
        FOREIGN KEY (ApprovedBy) REFERENCES Employee(EmployeeID),
        FOREIGN KEY (RequestedByEmployeeID) REFERENCES Employee(EmployeeID)
    );
END
GO

-- =============================================
-- TABLE 11: ProductionOrder
-- Purpose: Production planning and tracking
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'ProductionOrder') AND type = 'U')
BEGIN
    CREATE TABLE ProductionOrder (
        ProductionOrderID INT PRIMARY KEY IDENTITY(1,1),
        ProductID INT NOT NULL,
        QuantityOrdered INT NOT NULL CHECK (QuantityOrdered > 0),
        QuantityCompleted INT DEFAULT 0,
        StartDate DATETIME DEFAULT GETDATE(),
        ExpectedEndDate DATETIME,
        ActualEndDate DATETIME,
        Status NVARCHAR(50) DEFAULT 'Pending',
        Priority NVARCHAR(50) DEFAULT 'Normal',
        Notes NVARCHAR(1000),
        CreatedByEmployeeID INT,
        CreatedDate DATETIME DEFAULT GETDATE(),
        UpdatedDate DATETIME,
        FOREIGN KEY (ProductID) REFERENCES Product(ProductID),
        FOREIGN KEY (CreatedByEmployeeID) REFERENCES Employee(EmployeeID)
    );
END
GO

-- =============================================
-- TABLE 12: TailorAssignment
-- Purpose: Assign production work to tailors
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'TailorAssignment') AND type = 'U')
BEGIN
    CREATE TABLE TailorAssignment (
        AssignmentID INT PRIMARY KEY IDENTITY(1,1),
        ProductionOrderID INT NOT NULL,
        TailorID INT NOT NULL,
        ProductID INT NOT NULL,
        QuantityAssigned INT NOT NULL CHECK (QuantityAssigned > 0),
        Status NVARCHAR(50) DEFAULT 'Assigned',
        AssignedDate DATETIME DEFAULT GETDATE(),
        CompletedDate DATETIME,
        FOREIGN KEY (ProductionOrderID) REFERENCES ProductionOrder(ProductionOrderID),
        FOREIGN KEY (TailorID) REFERENCES Employee(EmployeeID),
        FOREIGN KEY (ProductID) REFERENCES Product(ProductID)
    );
END
GO

-- =============================================
-- TABLE 13: Delivery
-- Purpose: Shipment and delivery tracking
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'Delivery') AND type = 'U')
BEGIN
    CREATE TABLE Delivery (
        DeliveryID INT PRIMARY KEY IDENTITY(1,1),
        SalesOrderID INT NULL,
        DealID INT NULL,
        DeliveredBy INT,
        DeliveryDate DATETIME,
        DeliveryAddress NVARCHAR(500),
        City NVARCHAR(100),
        Province NVARCHAR(100),
        Status NVARCHAR(50) DEFAULT 'Pending',
        ReceiverName NVARCHAR(200),
        ReceiverPhone NVARCHAR(20),
        Notes NVARCHAR(1000),
        CreatedDate DATETIME DEFAULT GETDATE(),
        FOREIGN KEY (SalesOrderID) REFERENCES SalesOrder(SalesOrderID),
        FOREIGN KEY (DealID) REFERENCES Deal(DealID),
        FOREIGN KEY (DeliveredBy) REFERENCES Employee(EmployeeID)
    );
END
GO

-- =============================================
-- TABLE 14: Stock
-- Purpose: Inventory batch management
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'Stock') AND type = 'U')
BEGIN
    CREATE TABLE Stock (
        StockID INT PRIMARY KEY IDENTITY(1,1),
        ProductID INT NOT NULL,
        BatchNo NVARCHAR(100),
        EntryDate DATETIME DEFAULT GETDATE(),
        Quantity INT NOT NULL CHECK (Quantity >= 0),
        StockStatus NVARCHAR(50) DEFAULT 'In Stock',
        ProgressPercentage INT DEFAULT 0,
        Location NVARCHAR(200),
        Notes NVARCHAR(1000),
        CreatedBy INT,
        LastUpdated DATETIME DEFAULT GETDATE(),
        CreatedDate DATETIME DEFAULT GETDATE(),
        FOREIGN KEY (ProductID) REFERENCES Product(ProductID),
        FOREIGN KEY (CreatedBy) REFERENCES Employee(EmployeeID)
    );
END
GO

-- =============================================
-- TABLE 15: RawMaterial
-- Purpose: Raw material catalog
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'RawMaterial') AND type = 'U')
BEGIN
    CREATE TABLE RawMaterial (
        RawMaterialID INT PRIMARY KEY IDENTITY(1,1),
        MaterialName NVARCHAR(300) NOT NULL,
        Category NVARCHAR(100),
        Unit NVARCHAR(50),
        StockQuantity DECIMAL(18,2) DEFAULT 0,
        ReorderLevel DECIMAL(18,2) DEFAULT 0,
        UnitCost DECIMAL(18,2) DEFAULT 0,
        Description NVARCHAR(1000),
        CreatedDate DATETIME DEFAULT GETDATE(),
        UpdatedDate DATETIME
    );
END
GO

-- =============================================
-- TABLE 16: RawMaterialPurchase
-- Purpose: Track raw material procurement
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'RawMaterialPurchase') AND type = 'U')
BEGIN
    CREATE TABLE RawMaterialPurchase (
        PurchaseID INT PRIMARY KEY IDENTITY(1,1),
        RawMaterialID INT NOT NULL,
        MaterialName NVARCHAR(300),
        PurchaseDate DATE DEFAULT GETDATE(),
        Quantity DECIMAL(18,2) NOT NULL CHECK (Quantity > 0),
        Unit NVARCHAR(50),
        UnitPrice DECIMAL(18,2) NOT NULL CHECK (UnitPrice >= 0),
        TotalAmount DECIMAL(18,2),
        SupplierName NVARCHAR(300),
        InvoiceNumber NVARCHAR(100),
        Notes NVARCHAR(1000),
        CreatedDate DATETIME DEFAULT GETDATE(),
        FOREIGN KEY (RawMaterialID) REFERENCES RawMaterial(RawMaterialID)
    );
END
GO

-- =============================================
-- TABLE 17: ProductMaterialRequirement
-- Purpose: Bill of materials for products
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'ProductMaterialRequirement') AND type = 'U')
BEGIN
    CREATE TABLE ProductMaterialRequirement (
        RequirementID INT PRIMARY KEY IDENTITY(1,1),
        ProductID INT NOT NULL,
        RawMaterialID INT NOT NULL,
        QuantityRequired DECIMAL(18,2) NOT NULL CHECK (QuantityRequired > 0),
        FOREIGN KEY (ProductID) REFERENCES Product(ProductID) ON DELETE CASCADE,
        FOREIGN KEY (RawMaterialID) REFERENCES RawMaterial(RawMaterialID)
    );
END
GO

-- =============================================
-- TABLE 18: MonthlyRevenue
-- Purpose: Financial tracking - profit/loss
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'MonthlyRevenue') AND type = 'U')
BEGIN
    CREATE TABLE MonthlyRevenue (
        RevenueID INT PRIMARY KEY IDENTITY(1,1),
        Year INT NOT NULL,
        Month INT NOT NULL CHECK (Month BETWEEN 1 AND 12),
        MonthName NVARCHAR(20),
        SalesIncome DECIMAL(18,2) DEFAULT 0,
        DealIncome DECIMAL(18,2) DEFAULT 0,
        SalariesPaid BIT DEFAULT 0,
        TotalSalaries DECIMAL(18,2) DEFAULT 0,
        RawMaterialCost DECIMAL(18,2) DEFAULT 0,
        MiscExpense DECIMAL(18,2) DEFAULT 0,
        TotalIncome AS (SalesIncome + DealIncome) PERSISTED,
        TotalExpense AS (TotalSalaries + RawMaterialCost + MiscExpense) PERSISTED,
        NetProfit AS ((SalesIncome + DealIncome) - TotalSalaries - RawMaterialCost - MiscExpense) PERSISTED,
        Notes NVARCHAR(1000),
        CreatedDate DATETIME DEFAULT GETDATE(),
        UpdatedDate DATETIME,
        UNIQUE (Year, Month)
    );
END
GO

-- =============================================
-- TABLE 19: SalaryPayment
-- Purpose: Employee payroll tracking
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'SalaryPayment') AND type = 'U')
BEGIN
    CREATE TABLE SalaryPayment (
        PaymentID INT PRIMARY KEY IDENTITY(1,1),
        PaymentDate DATE DEFAULT GETDATE(),
        PaymentMonth INT NOT NULL CHECK (PaymentMonth BETWEEN 1 AND 12),
        PaymentYear INT NOT NULL,
        TotalAmount DECIMAL(18,2) NOT NULL CHECK (TotalAmount >= 0),
        EmployeeCount INT DEFAULT 0,
        Notes NVARCHAR(1000),
        CreatedDate DATETIME DEFAULT GETDATE(),
        UNIQUE (PaymentMonth, PaymentYear)
    );
END
GO

-- =============================================
-- TABLE 20: MiscExpense
-- Purpose: Track miscellaneous expenses
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'MiscExpense') AND type = 'U')
BEGIN
    CREATE TABLE MiscExpense (
        ExpenseID INT PRIMARY KEY IDENTITY(1,1),
        ExpenseDate DATE DEFAULT GETDATE(),
        Amount DECIMAL(18,2) NOT NULL CHECK (Amount >= 0),
        Category NVARCHAR(100),
        Description NVARCHAR(500),
        PaidTo NVARCHAR(200),
        PaymentMethod NVARCHAR(50),
        ReceiptNumber NVARCHAR(100),
        CreatedDate DATETIME DEFAULT GETDATE()
    );
END
GO

-- =============================================
-- INDEXES FOR PERFORMANCE
-- =============================================

-- Employee indexes
CREATE NONCLUSTERED INDEX IX_Employee_DepartmentID ON Employee(DepartmentID);
CREATE NONCLUSTERED INDEX IX_Employee_RoleID ON Employee(RoleID);
CREATE NONCLUSTERED INDEX IX_Employee_Username ON Employee(Username);

-- SalesOrder indexes
CREATE NONCLUSTERED INDEX IX_SalesOrder_RetailerID ON SalesOrder(RetailerID);
CREATE NONCLUSTERED INDEX IX_SalesOrder_Status ON SalesOrder(Status);
CREATE NONCLUSTERED INDEX IX_SalesOrder_OrderDate ON SalesOrder(OrderDate);

-- Deal indexes
CREATE NONCLUSTERED INDEX IX_Deal_Status ON Deal(Status);
CREATE NONCLUSTERED INDEX IX_Deal_CreatedBy ON Deal(CreatedBy);

-- ProductionOrder indexes
CREATE NONCLUSTERED INDEX IX_ProductionOrder_Status ON ProductionOrder(Status);
CREATE NONCLUSTERED INDEX IX_ProductionOrder_ProductID ON ProductionOrder(ProductID);

-- TailorAssignment indexes
CREATE NONCLUSTERED INDEX IX_TailorAssignment_TailorID ON TailorAssignment(TailorID);
CREATE NONCLUSTERED INDEX IX_TailorAssignment_Status ON TailorAssignment(Status);

-- Delivery indexes
CREATE NONCLUSTERED INDEX IX_Delivery_Status ON Delivery(Status);
CREATE NONCLUSTERED INDEX IX_Delivery_SalesOrderID ON Delivery(SalesOrderID);
CREATE NONCLUSTERED INDEX IX_Delivery_DealID ON Delivery(DealID);

PRINT '✓ Database schema created successfully!';
PRINT '✓ Total Tables: 20';
PRINT '✓ Total Indexes: 15';
GO
