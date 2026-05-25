-- =============================================
-- COMPLETE DATABASE SCHEMA AND PROCEDURES
-- Factory Management System
-- Created: December 10, 2025
-- =============================================

USE GarmentsFactoryDB;
GO

PRINT '========================================';
PRINT 'Complete Database Schema and Procedures';
PRINT '========================================';

-- =============================================
-- SECTION 1: CORE TABLES
-- =============================================

-- Department Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Department')
BEGIN
    CREATE TABLE Department (
        DepartmentID INT IDENTITY(1,1) PRIMARY KEY,
        DepartmentName NVARCHAR(100) NOT NULL,
        Description NVARCHAR(500) NULL,
        IsActive BIT DEFAULT 1,
        CreatedDate DATETIME DEFAULT GETDATE()
    );
END

-- EmployeeRole Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'EmployeeRole')
BEGIN
    CREATE TABLE EmployeeRole (
        RoleID INT IDENTITY(1,1) PRIMARY KEY,
        RoleName NVARCHAR(100) NOT NULL,
        Description NVARCHAR(500) NULL,
        IsActive BIT DEFAULT 1
    );
END

-- Employee Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Employee')
BEGIN
    CREATE TABLE Employee (
        EmployeeID INT IDENTITY(1,1) PRIMARY KEY,
        FirstName NVARCHAR(100) NOT NULL,
        LastName NVARCHAR(100) NOT NULL,
        Email NVARCHAR(100) NULL,
        Phone NVARCHAR(20) NULL,
        DepartmentID INT NOT NULL,
        RoleID INT NOT NULL,
        Salary DECIMAL(18,2) NULL,
        JoinDate DATE NULL,
        Address NVARCHAR(500) NULL,
        EmergencyContact NVARCHAR(100) NULL,
        CNIC NVARCHAR(20) NULL,
        IsActive BIT DEFAULT 1,
        CreatedDate DATETIME DEFAULT GETDATE(),
        Username NVARCHAR(50) NULL,
        LastLogin DATETIME NULL,
        PIN NVARCHAR(10) NULL,
        Specialization NVARCHAR(100) NULL,
        PieceRate DECIMAL(10,2) NULL,
        TotalPiecesCompleted INT DEFAULT 0,
        ShiftType NVARCHAR(50) NULL,
        Position NVARCHAR(100) NULL,
        FOREIGN KEY (DepartmentID) REFERENCES Department(DepartmentID),
        FOREIGN KEY (RoleID) REFERENCES EmployeeRole(RoleID)
    );
END

-- Product Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Product')
BEGIN
    CREATE TABLE Product (
        ProductID INT IDENTITY(1,1) PRIMARY KEY,
        ProductCode NVARCHAR(50) NULL,
        ProductName NVARCHAR(200) NOT NULL,
        Category NVARCHAR(100) NULL,
        Material NVARCHAR(100) NULL,
        Size NVARCHAR(50) NULL,
        Color NVARCHAR(50) NULL,
        UnitPrice DECIMAL(18,2) DEFAULT 0,
        Description NVARCHAR(MAX) NULL,
        ImageUrl NVARCHAR(500) NULL,
        Status NVARCHAR(50) DEFAULT 'Active',
        IsActive BIT DEFAULT 1,
        CreatedDate DATETIME DEFAULT GETDATE()
    );
END

-- RawMaterial Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'RawMaterial')
BEGIN
    CREATE TABLE RawMaterial (
        RawMaterialID INT IDENTITY(1,1) PRIMARY KEY,
        MaterialName NVARCHAR(200) NOT NULL,
        Description NVARCHAR(500) NULL,
        Unit NVARCHAR(50) NULL,
        UnitPrice DECIMAL(18,2) DEFAULT 0,
        CurrentStock DECIMAL(18,2) DEFAULT 0,
        MinimumStock DECIMAL(18,2) DEFAULT 0,
        SupplierName NVARCHAR(200) NULL,
        IsActive BIT DEFAULT 1,
        CreatedDate DATETIME DEFAULT GETDATE()
    );
END

-- Retailer Table (Simplified)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Retailer')
BEGIN
    CREATE TABLE Retailer (
        RetailerID INT IDENTITY(1,1) PRIMARY KEY,
        CompanyName NVARCHAR(200) NOT NULL,
        ContactPerson NVARCHAR(100) NULL,
        Phone NVARCHAR(20) NULL,
        Email NVARCHAR(100) NULL,
        AlternativePhone NVARCHAR(20) NULL,
        Address NVARCHAR(500) NULL,
        City NVARCHAR(100) NULL,
        Province NVARCHAR(100) NULL,
        PostalCode NVARCHAR(20) NULL,
        Status NVARCHAR(50) DEFAULT 'Active',
        IsActive BIT DEFAULT 1,
        CreatedDate DATETIME DEFAULT GETDATE(),
        UpdatedDate DATETIME NULL
    );
END

-- Deal Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Deal')
BEGIN
    CREATE TABLE Deal (
        DealID INT IDENTITY(1,1) PRIMARY KEY,
        DealTitle NVARCHAR(200) NOT NULL,
        DealType NVARCHAR(50) NULL,
        ClientName NVARCHAR(200) NULL,
        ContactPerson NVARCHAR(100) NULL,
        Email NVARCHAR(100) NULL,
        Phone NVARCHAR(20) NULL,
        EstimatedValue DECIMAL(18,2) DEFAULT 0,
        Currency NVARCHAR(10) DEFAULT 'PKR',
        Priority NVARCHAR(20) DEFAULT 'Medium',
        ExpectedDuration NVARCHAR(50) NULL,
        StartDate DATE NULL,
        EndDate DATE NULL,
        Description NVARCHAR(MAX) NULL,
        KeyTerms NVARCHAR(MAX) NULL,
        PaymentTerms NVARCHAR(100) NULL,
        PaymentMethod NVARCHAR(50) NULL,
        SpecialRequirements NVARCHAR(MAX) NULL,
        AssignedManagerID INT NULL,
        Status NVARCHAR(50) DEFAULT 'Pending',
        CreatedBy INT NULL,
        CreatedDate DATETIME DEFAULT GETDATE(),
        UpdatedDate DATETIME NULL,
        DeliveryAddress NVARCHAR(500) NULL,
        City NVARCHAR(100) NULL,
        Province NVARCHAR(100) NULL
    );
END

-- DealItem Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'DealItem')
BEGIN
    CREATE TABLE DealItem (
        DealItemID INT IDENTITY(1,1) PRIMARY KEY,
        DealID INT NOT NULL,
        ProductID INT NOT NULL,
        Quantity INT DEFAULT 1,
        UnitPrice DECIMAL(18,2) DEFAULT 0,
        TotalPrice DECIMAL(18,2) DEFAULT 0,
        Notes NVARCHAR(500) NULL,
        FOREIGN KEY (DealID) REFERENCES Deal(DealID),
        FOREIGN KEY (ProductID) REFERENCES Product(ProductID)
    );
END

-- SalesOrder Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'SalesOrder')
BEGIN
    CREATE TABLE SalesOrder (
        SalesOrderID INT IDENTITY(1,1) PRIMARY KEY,
        OrderDate DATETIME DEFAULT GETDATE(),
        ExpectedDeliveryDate DATETIME NULL,
        PriorityLevel NVARCHAR(20) DEFAULT 'Medium',
        Status NVARCHAR(50) DEFAULT 'Pending',
        RetailerID INT NULL,
        ShippingAddress NVARCHAR(500) NULL,
        SpecialInstructions NVARCHAR(MAX) NULL,
        PaymentTerms NVARCHAR(100) NULL,
        AdvancePaymentPercent DECIMAL(5,2) DEFAULT 0,
        DiscountPercentage DECIMAL(5,2) DEFAULT 0,
        PaymentStatus NVARCHAR(50) DEFAULT 'Pending',
        SubTotal DECIMAL(18,2) DEFAULT 0,
        DiscountAmount DECIMAL(18,2) DEFAULT 0,
        TaxAmount DECIMAL(18,2) DEFAULT 0,
        TotalAmount DECIMAL(18,2) DEFAULT 0,
        SalesRepID INT NULL,
        OrderSource NVARCHAR(50) NULL,
        InternalNotes NVARCHAR(MAX) NULL,
        Tags NVARCHAR(200) NULL,
        CreatedDate DATETIME DEFAULT GETDATE(),
        UpdatedDate DATETIME NULL
    );
END

-- SalesOrderItem Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'SalesOrderItem')
BEGIN
    CREATE TABLE SalesOrderItem (
        SalesOrderItemID INT IDENTITY(1,1) PRIMARY KEY,
        SalesOrderID INT NOT NULL,
        ProductID INT NOT NULL,
        Quantity INT DEFAULT 1,
        UnitPrice DECIMAL(18,2) DEFAULT 0,
        TotalPrice DECIMAL(18,2) DEFAULT 0,
        Size NVARCHAR(50) NULL,
        Color NVARCHAR(50) NULL,
        Notes NVARCHAR(500) NULL,
        FOREIGN KEY (SalesOrderID) REFERENCES SalesOrder(SalesOrderID),
        FOREIGN KEY (ProductID) REFERENCES Product(ProductID)
    );
END

-- ProductionOrder Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ProductionOrder')
BEGIN
    CREATE TABLE ProductionOrder (
        ProductionOrderID INT IDENTITY(1,1) PRIMARY KEY,
        OrderNumber NVARCHAR(50) NULL,
        SalesOrderID INT NULL,
        DealID INT NULL,
        ProductID INT NULL,
        Quantity INT DEFAULT 0,
        Priority NVARCHAR(20) DEFAULT 'Medium',
        Status NVARCHAR(50) DEFAULT 'Pending',
        StartDate DATE NULL,
        DueDate DATE NULL,
        CompletedDate DATE NULL,
        AssignedTo INT NULL,
        Notes NVARCHAR(MAX) NULL,
        CreatedDate DATETIME DEFAULT GETDATE()
    );
END

-- Stock Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Stock')
BEGIN
    CREATE TABLE Stock (
        StockID INT IDENTITY(1,1) PRIMARY KEY,
        ProductID INT NOT NULL,
        BatchNo NVARCHAR(50) NULL,
        EntryDate DATETIME DEFAULT GETDATE(),
        Quantity INT DEFAULT 0,
        StockStatus NVARCHAR(50) DEFAULT 'InProcess',
        ProgressPercentage INT DEFAULT 0,
        Location NVARCHAR(100) NULL,
        Notes NVARCHAR(500) NULL,
        CreatedBy INT NULL,
        LastUpdated DATETIME DEFAULT GETDATE(),
        CreatedDate DATETIME DEFAULT GETDATE(),
        FOREIGN KEY (ProductID) REFERENCES Product(ProductID)
    );
END

-- Delivery Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Delivery')
BEGIN
    CREATE TABLE Delivery (
        DeliveryID INT IDENTITY(1,1) PRIMARY KEY,
        SalesOrderID INT NULL,
        DealID INT NULL,
        DeliveryPersonID INT NULL,
        DeliveryAddress NVARCHAR(500) NULL,
        DeliveryDate DATETIME NULL,
        Status NVARCHAR(50) DEFAULT 'Pending',
        Notes NVARCHAR(500) NULL,
        CreatedDate DATETIME DEFAULT GETDATE(),
        CompletedDate DATETIME NULL
    );
END

-- TailorTask Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'TailorTask')
BEGIN
    CREATE TABLE TailorTask (
        TailorTaskID INT IDENTITY(1,1) PRIMARY KEY,
        EmployeeID INT NOT NULL,
        ProductionOrderID INT NULL,
        QuantityAssigned INT DEFAULT 0,
        QuantityCompleted INT DEFAULT 0,
        StartDate DATE NULL,
        EndDate DATE NULL,
        Status NVARCHAR(50) DEFAULT 'Assigned',
        Notes NVARCHAR(500) NULL,
        FOREIGN KEY (EmployeeID) REFERENCES Employee(EmployeeID),
        FOREIGN KEY (ProductionOrderID) REFERENCES ProductionOrder(ProductionOrderID)
    );
END

-- OrderApproval Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'OrderApproval')
BEGIN
    CREATE TABLE OrderApproval (
        ApprovalID INT IDENTITY(1,1) PRIMARY KEY,
        SalesOrderID INT NULL,
        DealID INT NULL,
        OrderType NVARCHAR(50) NULL,
        OrderID INT NULL,
        RequestedByEmployeeID INT NULL,
        Status NVARCHAR(50) DEFAULT 'Pending',
        RequestDate DATETIME DEFAULT GETDATE(),
        ApprovedBy INT NULL,
        ApprovalStatus NVARCHAR(50) NULL,
        ApprovalDate DATETIME NULL,
        Comments NVARCHAR(500) NULL,
        CreatedDate DATETIME DEFAULT GETDATE()
    );
END
ELSE
BEGIN
    -- Add missing columns if table exists
    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'OrderApproval' AND COLUMN_NAME = 'OrderType')
        ALTER TABLE OrderApproval ADD OrderType NVARCHAR(50) NULL;
    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'OrderApproval' AND COLUMN_NAME = 'OrderID')
        ALTER TABLE OrderApproval ADD OrderID INT NULL;
    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'OrderApproval' AND COLUMN_NAME = 'RequestedByEmployeeID')
        ALTER TABLE OrderApproval ADD RequestedByEmployeeID INT NULL;
    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'OrderApproval' AND COLUMN_NAME = 'Status')
        ALTER TABLE OrderApproval ADD Status NVARCHAR(50) DEFAULT 'Pending';
    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'OrderApproval' AND COLUMN_NAME = 'RequestDate')
        ALTER TABLE OrderApproval ADD RequestDate DATETIME DEFAULT GETDATE();
END

-- TailorAssignment Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'TailorAssignment')
BEGIN
    CREATE TABLE TailorAssignment (
        AssignmentID INT IDENTITY(1,1) PRIMARY KEY,
        TailorID INT NOT NULL,
        ProductionOrderID INT NULL,
        SalesOrderID INT NULL,
        DealID INT NULL,
        ProductID INT NULL,
        QuantityAssigned INT DEFAULT 0,
        QuantityCompleted INT DEFAULT 0,
        AssignedDate DATETIME DEFAULT GETDATE(),
        DueDate DATETIME NULL,
        CompletedDate DATETIME NULL,
        Status NVARCHAR(50) DEFAULT 'Assigned',
        Notes NVARCHAR(500) NULL,
        FOREIGN KEY (TailorID) REFERENCES Employee(EmployeeID)
    );
END

-- ProductMaterialRequirement Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ProductMaterialRequirement')
BEGIN
    CREATE TABLE ProductMaterialRequirement (
        RequirementID INT IDENTITY(1,1) PRIMARY KEY,
        ProductID INT NOT NULL,
        RawMaterialID INT NOT NULL,
        QuantityRequired DECIMAL(10,2) NOT NULL,
        Unit NVARCHAR(50) NULL,
        Notes NVARCHAR(500) NULL,
        CreatedDate DATETIME DEFAULT GETDATE(),
        FOREIGN KEY (ProductID) REFERENCES Product(ProductID),
        FOREIGN KEY (RawMaterialID) REFERENCES RawMaterial(RawMaterialID)
    );
END

PRINT 'Tables created/verified successfully';
GO

-- =============================================
-- SECTION 2: STORED PROCEDURES
-- =============================================

-- Department Procedures
DROP PROCEDURE IF EXISTS sp_GetDepartments;
GO
CREATE PROCEDURE sp_GetDepartments
AS
BEGIN
    SELECT DepartmentID, DepartmentName, Description, IsActive, CreatedDate
    FROM Department WHERE IsActive = 1 ORDER BY DepartmentName;
END
GO

DROP PROCEDURE IF EXISTS sp_GetAllDepartments;
GO
CREATE PROCEDURE sp_GetAllDepartments
AS
BEGIN
    SELECT DepartmentID, DepartmentName, Description, IsActive, CreatedDate
    FROM Department ORDER BY DepartmentName;
END
GO

DROP PROCEDURE IF EXISTS sp_AddDepartment;
GO
CREATE PROCEDURE sp_AddDepartment
    @DepartmentName NVARCHAR(100),
    @Description NVARCHAR(500) = NULL
AS
BEGIN
    INSERT INTO Department (DepartmentName, Description)
    VALUES (@DepartmentName, @Description);
    SELECT SCOPE_IDENTITY();
END
GO

DROP PROCEDURE IF EXISTS sp_DeleteDepartment;
GO
CREATE PROCEDURE sp_DeleteDepartment
    @DepartmentID INT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Employee WHERE DepartmentID = @DepartmentID AND IsActive = 1)
    BEGIN
        RAISERROR('Cannot delete department with active employees.', 16, 1);
        RETURN -1;
    END
    DELETE FROM Department WHERE DepartmentID = @DepartmentID;
    RETURN @@ROWCOUNT;
END
GO

DROP PROCEDURE IF EXISTS sp_GetDepartmentsWithEmployeeCount;
GO
CREATE PROCEDURE sp_GetDepartmentsWithEmployeeCount
AS
BEGIN
    SELECT d.DepartmentID, d.DepartmentName, d.Description, d.IsActive,
           ISNULL((SELECT COUNT(*) FROM Employee WHERE DepartmentID = d.DepartmentID AND IsActive = 1), 0) AS EmployeeCount
    FROM Department d ORDER BY d.DepartmentName;
END
GO

-- Production Department Stats
DROP PROCEDURE IF EXISTS sp_GetProductionDepartmentStats;
GO
CREATE PROCEDURE sp_GetProductionDepartmentStats
AS
BEGIN
    SELECT 
        ISNULL((SELECT COUNT(*) FROM ProductionOrder WHERE Status = 'Pending'), 0) AS PendingOrders,
        ISNULL((SELECT COUNT(*) FROM ProductionOrder WHERE Status = 'In Progress'), 0) AS InProgressOrders,
        ISNULL((SELECT COUNT(*) FROM ProductionOrder WHERE Status = 'Completed'), 0) AS CompletedOrders,
        ISNULL((SELECT COUNT(*) FROM ProductionOrder), 0) AS TotalOrders,
        ISNULL((SELECT COUNT(*) FROM Employee e JOIN EmployeeRole r ON e.RoleID = r.RoleID WHERE r.RoleName = 'Tailor' AND e.IsActive = 1), 0) AS TotalTailors,
        ISNULL((SELECT COUNT(*) FROM RawMaterial WHERE IsActive = 1), 0) AS TotalRawMaterials;
END
GO

-- Sales Department Stats
DROP PROCEDURE IF EXISTS sp_GetSalesDepartmentStats;
GO
CREATE PROCEDURE sp_GetSalesDepartmentStats
AS
BEGIN
    SELECT 
        CAST(ISNULL((SELECT SUM(TotalAmount) FROM SalesOrder), 0) AS DECIMAL(18,2)) AS TotalSales,
        ISNULL((SELECT COUNT(*) FROM Employee e JOIN EmployeeRole r ON e.RoleID = r.RoleID WHERE r.RoleName IN ('Salesperson', 'Sales Manager') AND e.IsActive = 1), 0) AS ActiveSalespeople,
        ISNULL((SELECT COUNT(*) FROM SalesOrder), 0) AS TotalOrders,
        CAST(ISNULL((SELECT AVG(TotalAmount) FROM SalesOrder), 0) AS DECIMAL(18,2)) AS AvgOrderValue,
        CAST(0.0 AS DECIMAL(18,2)) AS ConversionRate,
        CAST(0.0 AS DECIMAL(18,2)) AS SalesGrowth;
END
GO

-- Retailer Procedures
DROP PROCEDURE IF EXISTS sp_GetAllRetailers;
GO
CREATE PROCEDURE sp_GetAllRetailers
AS
BEGIN
    SELECT RetailerID, CompanyName, ContactPerson, Phone, Email, AlternativePhone,
           Address, City, Province, PostalCode, Status, IsActive, CreatedDate, UpdatedDate
    FROM Retailer WHERE IsActive = 1 ORDER BY CompanyName;
END
GO

DROP PROCEDURE IF EXISTS sp_GetRetailerById;
GO
CREATE PROCEDURE sp_GetRetailerById @RetailerID INT
AS
BEGIN
    SELECT RetailerID, CompanyName, ContactPerson, Phone, Email, AlternativePhone,
           Address, City, Province, PostalCode, Status, IsActive, CreatedDate, UpdatedDate
    FROM Retailer WHERE RetailerID = @RetailerID;
END
GO

DROP PROCEDURE IF EXISTS sp_AddRetailer;
GO
CREATE PROCEDURE sp_AddRetailer
    @CompanyName NVARCHAR(200),
    @ContactPerson NVARCHAR(100) = NULL,
    @Phone NVARCHAR(20) = NULL,
    @Email NVARCHAR(100) = NULL,
    @AlternativePhone NVARCHAR(20) = NULL,
    @Address NVARCHAR(500) = NULL,
    @City NVARCHAR(100) = NULL,
    @Province NVARCHAR(100) = NULL,
    @PostalCode NVARCHAR(20) = NULL,
    @NewRetailerID INT OUTPUT
AS
BEGIN
    INSERT INTO Retailer (CompanyName, ContactPerson, Phone, Email, AlternativePhone, Address, City, Province, PostalCode, Status, IsActive, CreatedDate)
    VALUES (@CompanyName, @ContactPerson, @Phone, @Email, @AlternativePhone, @Address, @City, @Province, @PostalCode, 'Active', 1, GETDATE());
    SET @NewRetailerID = SCOPE_IDENTITY();
END
GO

DROP PROCEDURE IF EXISTS sp_UpdateRetailer;
GO
CREATE PROCEDURE sp_UpdateRetailer
    @RetailerID INT,
    @CompanyName NVARCHAR(200),
    @ContactPerson NVARCHAR(100) = NULL,
    @Phone NVARCHAR(20) = NULL,
    @Email NVARCHAR(100) = NULL,
    @AlternativePhone NVARCHAR(20) = NULL,
    @Address NVARCHAR(500) = NULL,
    @City NVARCHAR(100) = NULL,
    @Province NVARCHAR(100) = NULL,
    @PostalCode NVARCHAR(20) = NULL,
    @Status NVARCHAR(50) = NULL
AS
BEGIN
    UPDATE Retailer SET CompanyName = @CompanyName, ContactPerson = @ContactPerson, Phone = @Phone,
        Email = @Email, AlternativePhone = @AlternativePhone, Address = @Address,
        City = @City, Province = @Province, PostalCode = @PostalCode,
        Status = ISNULL(@Status, Status), UpdatedDate = GETDATE()
    WHERE RetailerID = @RetailerID;
END
GO

DROP PROCEDURE IF EXISTS sp_DeleteRetailer;
GO
CREATE PROCEDURE sp_DeleteRetailer @RetailerID INT
AS
BEGIN
    UPDATE Retailer SET IsActive = 0, UpdatedDate = GETDATE() WHERE RetailerID = @RetailerID;
END
GO

DROP PROCEDURE IF EXISTS sp_SearchRetailers;
GO
CREATE PROCEDURE sp_SearchRetailers @SearchTerm NVARCHAR(100)
AS
BEGIN
    SELECT RetailerID, CompanyName, ContactPerson, Phone, Email, AlternativePhone,
           Address, City, Province, PostalCode, Status, IsActive, CreatedDate, UpdatedDate
    FROM Retailer WHERE IsActive = 1 AND (CompanyName LIKE '%' + @SearchTerm + '%' OR ContactPerson LIKE '%' + @SearchTerm + '%' OR City LIKE '%' + @SearchTerm + '%')
    ORDER BY CompanyName;
END
GO

DROP PROCEDURE IF EXISTS sp_GetRetailerStatistics;
GO
CREATE PROCEDURE sp_GetRetailerStatistics
AS
BEGIN
    SELECT COUNT(*) AS TotalRetailers,
           SUM(CASE WHEN IsActive = 1 THEN 1 ELSE 0 END) AS ActiveRetailers,
           SUM(CASE WHEN IsActive = 0 THEN 1 ELSE 0 END) AS InactiveRetailers,
           COUNT(DISTINCT City) AS CitiesCovered
    FROM Retailer;
END
GO

-- ProductMaterialRequirement Procedures
DROP PROCEDURE IF EXISTS sp_AddProductMaterialRequirement;
GO
CREATE PROCEDURE sp_AddProductMaterialRequirement
    @ProductID INT,
    @RawMaterialID INT,
    @QuantityRequired DECIMAL(10,2),
    @Unit NVARCHAR(50) = NULL,
    @Notes NVARCHAR(500) = NULL,
    @NewRequirementID INT OUTPUT
AS
BEGIN
    INSERT INTO ProductMaterialRequirement (ProductID, RawMaterialID, QuantityRequired, Unit, Notes)
    VALUES (@ProductID, @RawMaterialID, @QuantityRequired, @Unit, @Notes);
    SET @NewRequirementID = SCOPE_IDENTITY();
END
GO

DROP PROCEDURE IF EXISTS sp_UpdateProductMaterialRequirement;
GO
CREATE PROCEDURE sp_UpdateProductMaterialRequirement
    @RequirementID INT,
    @QuantityRequired DECIMAL(10,2),
    @Unit NVARCHAR(50) = NULL,
    @Notes NVARCHAR(500) = NULL
AS
BEGIN
    UPDATE ProductMaterialRequirement SET QuantityRequired = @QuantityRequired, Unit = @Unit, Notes = @Notes
    WHERE RequirementID = @RequirementID;
END
GO

DROP PROCEDURE IF EXISTS sp_DeleteProductMaterialRequirement;
GO
CREATE PROCEDURE sp_DeleteProductMaterialRequirement @RequirementID INT
AS
BEGIN
    DELETE FROM ProductMaterialRequirement WHERE RequirementID = @RequirementID;
END
GO

DROP PROCEDURE IF EXISTS sp_GetProductMaterials;
GO
CREATE PROCEDURE sp_GetProductMaterials @ProductID INT
AS
BEGIN
    SELECT pmr.RequirementID, pmr.ProductID, pmr.RawMaterialID, pmr.QuantityRequired, pmr.Unit, pmr.Notes,
           rm.MaterialName, rm.UnitPrice
    FROM ProductMaterialRequirement pmr
    INNER JOIN RawMaterial rm ON pmr.RawMaterialID = rm.RawMaterialID
    WHERE pmr.ProductID = @ProductID;
END
GO

-- Deal Procedures
DROP PROCEDURE IF EXISTS sp_AddDeal;
GO
CREATE PROCEDURE sp_AddDeal
    @DealTitle NVARCHAR(200),
    @DealType NVARCHAR(50) = NULL,
    @ClientName NVARCHAR(200) = NULL,
    @ContactPerson NVARCHAR(100) = NULL,
    @Email NVARCHAR(100) = NULL,
    @Phone NVARCHAR(20) = NULL,
    @EstimatedValue DECIMAL(18,2) = 0,
    @Currency NVARCHAR(10) = 'PKR',
    @Priority NVARCHAR(20) = 'Medium',
    @ExpectedDuration NVARCHAR(50) = NULL,
    @StartDate DATE = NULL,
    @EndDate DATE = NULL,
    @Description NVARCHAR(MAX) = NULL,
    @KeyTerms NVARCHAR(MAX) = NULL,
    @PaymentTerms NVARCHAR(100) = NULL,
    @PaymentMethod NVARCHAR(50) = NULL,
    @SpecialRequirements NVARCHAR(MAX) = NULL,
    @AssignedManagerID INT = NULL,
    @CreatedBy INT = NULL,
    @DeliveryAddress NVARCHAR(500) = NULL,
    @City NVARCHAR(100) = NULL,
    @Province NVARCHAR(100) = NULL,
    @NewDealID INT OUTPUT
AS
BEGIN
    INSERT INTO Deal (DealTitle, DealType, ClientName, ContactPerson, Email, Phone, EstimatedValue, Currency, Priority,
        ExpectedDuration, StartDate, EndDate, Description, KeyTerms, PaymentTerms, PaymentMethod, SpecialRequirements,
        AssignedManagerID, Status, CreatedBy, CreatedDate, DeliveryAddress, City, Province)
    VALUES (@DealTitle, @DealType, @ClientName, @ContactPerson, @Email, @Phone, @EstimatedValue, @Currency, @Priority,
        @ExpectedDuration, @StartDate, @EndDate, @Description, @KeyTerms, @PaymentTerms, @PaymentMethod, @SpecialRequirements,
        @AssignedManagerID, 'Pending', @CreatedBy, GETDATE(), @DeliveryAddress, @City, @Province);
    SET @NewDealID = SCOPE_IDENTITY();
END
GO

-- SalesOrder Procedures
DROP PROCEDURE IF EXISTS sp_AddSalesOrder;
GO
CREATE PROCEDURE sp_AddSalesOrder
    @RetailerID INT,
    @SalesRepID INT = NULL,
    @OrderDate DATETIME = NULL,
    @ExpectedDeliveryDate DATETIME = NULL,
    @PriorityLevel NVARCHAR(20) = 'Medium',
    @ShippingAddress NVARCHAR(500) = NULL,
    @SpecialInstructions NVARCHAR(MAX) = NULL,
    @PaymentTerms NVARCHAR(100) = NULL,
    @AdvancePaymentPercent DECIMAL(5,2) = 0,
    @DiscountPercentage DECIMAL(5,2) = 0,
    @SubTotal DECIMAL(18,2) = 0,
    @DiscountAmount DECIMAL(18,2) = 0,
    @TaxAmount DECIMAL(18,2) = 0,
    @TotalAmount DECIMAL(18,2) = 0,
    @OrderSource NVARCHAR(50) = NULL,
    @InternalNotes NVARCHAR(MAX) = NULL,
    @Tags NVARCHAR(200) = NULL,
    @NewOrderID INT OUTPUT
AS
BEGIN
    IF @OrderDate IS NULL SET @OrderDate = GETDATE();
    INSERT INTO SalesOrder (RetailerID, SalesRepID, OrderDate, ExpectedDeliveryDate, PriorityLevel, Status,
        ShippingAddress, SpecialInstructions, PaymentTerms, AdvancePaymentPercent, DiscountPercentage, PaymentStatus,
        SubTotal, DiscountAmount, TaxAmount, TotalAmount, OrderSource, InternalNotes, Tags, CreatedDate)
    VALUES (@RetailerID, @SalesRepID, @OrderDate, @ExpectedDeliveryDate, @PriorityLevel, 'Pending',
        @ShippingAddress, @SpecialInstructions, @PaymentTerms, @AdvancePaymentPercent, @DiscountPercentage, 'Pending',
        @SubTotal, @DiscountAmount, @TaxAmount, @TotalAmount, @OrderSource, @InternalNotes, @Tags, GETDATE());
    SET @NewOrderID = SCOPE_IDENTITY();
END
GO

-- Tailor Procedures
DROP PROCEDURE IF EXISTS sp_GetAvailableTailors;
GO
CREATE PROCEDURE sp_GetAvailableTailors
AS
BEGIN
    SELECT e.EmployeeID, CONCAT(e.FirstName, ' ', e.LastName) AS TailorName, e.Specialization, e.PieceRate,
           ISNULL(e.TotalPiecesCompleted, 0) AS TotalPiecesCompleted, e.Phone, e.Email,
           ISNULL((SELECT COUNT(*) FROM TailorTask tt WHERE tt.EmployeeID = e.EmployeeID AND tt.Status IN ('Assigned', 'In Progress')), 0) AS ActiveAssignments
    FROM Employee e INNER JOIN EmployeeRole r ON e.RoleID = r.RoleID
    WHERE r.RoleName = 'Tailor' AND e.IsActive = 1;
END
GO

DROP PROCEDURE IF EXISTS sp_GetTailorAssignments;
GO
CREATE PROCEDURE sp_GetTailorAssignments @TailorID INT = NULL
AS
BEGIN
    SELECT ta.AssignmentID, ta.TailorID, CONCAT(e.FirstName, ' ', e.LastName) AS TailorName,
           ta.ProductionOrderID, ta.ProductID, p.ProductName, ta.QuantityAssigned, ta.QuantityCompleted,
           ta.AssignedDate, ta.DueDate, ta.CompletedDate, ta.Status, ta.Notes
    FROM TailorAssignment ta
    INNER JOIN Employee e ON ta.TailorID = e.EmployeeID
    LEFT JOIN Product p ON ta.ProductID = p.ProductID
    WHERE (@TailorID IS NULL OR ta.TailorID = @TailorID)
    ORDER BY ta.AssignedDate DESC;
END
GO

-- Pending Approvals
DROP PROCEDURE IF EXISTS sp_GetPendingApprovals;
GO
CREATE PROCEDURE sp_GetPendingApprovals
AS
BEGIN
    SELECT 0 AS ApprovalID, 'SalesOrder' AS OrderType, so.SalesOrderID AS OrderID, so.Status, so.OrderDate AS RequestDate,
           ISNULL(so.SalesRepID, 0) AS RequestedByEmployeeID, CONCAT(e.FirstName, ' ', e.LastName) AS SalespersonName,
           e.Phone AS SalespersonPhone, so.TotalAmount AS SalesOrderAmount, so.PriorityLevel AS SalesOrderPriority,
           r.CompanyName AS RetailerName, CAST(NULL AS DECIMAL(18,2)) AS DealAmount, NULL AS DealPriority, NULL AS DealClientName
    FROM SalesOrder so LEFT JOIN Employee e ON so.SalesRepID = e.EmployeeID LEFT JOIN Retailer r ON so.RetailerID = r.RetailerID
    WHERE so.Status = 'Pending'
    UNION ALL
    SELECT 0 AS ApprovalID, 'Deal' AS OrderType, d.DealID AS OrderID, d.Status, d.StartDate AS RequestDate,
           ISNULL(d.AssignedManagerID, 0) AS RequestedByEmployeeID, CONCAT(e.FirstName, ' ', e.LastName) AS SalespersonName,
           e.Phone AS SalespersonPhone, CAST(NULL AS DECIMAL(18,2)) AS SalesOrderAmount, NULL AS SalesOrderPriority,
           NULL AS RetailerName, d.EstimatedValue AS DealAmount, d.Priority AS DealPriority, d.ClientName AS DealClientName
    FROM Deal d LEFT JOIN Employee e ON d.AssignedManagerID = e.EmployeeID
    WHERE d.Status = 'Pending';
END
GO

-- Stock Management
DROP PROCEDURE IF EXISTS sp_GetStockManagement;
GO
CREATE PROCEDURE sp_GetStockManagement @Status NVARCHAR(50) = NULL
AS
BEGIN
    IF @Status IS NULL
    BEGIN
        SELECT COUNT(*) AS TotalStockEntries,
               SUM(CASE WHEN StockStatus = 'Ready' THEN 1 ELSE 0 END) AS ReadyProducts,
               SUM(CASE WHEN StockStatus = 'InProcess' THEN 1 ELSE 0 END) AS InProcess,
               SUM(CASE WHEN StockStatus = 'Shipped' THEN 1 ELSE 0 END) AS Shipped
        FROM Stock;
    END
    ELSE
    BEGIN
        SELECT s.StockID, s.BatchNo, p.ProductName AS Product, s.Quantity AS InProcessQty, s.Quantity AS ReadyQty,
               s.Quantity AS ShippedQty, s.EntryDate AS DateAdded, s.StockStatus AS Status, 'Stock' AS OrderType, '' AS CustomerName
        FROM Stock s INNER JOIN Product p ON s.ProductID = p.ProductID WHERE s.StockStatus = @Status;
    END
END
GO

PRINT '';
PRINT 'All stored procedures created successfully!';
PRINT '========================================';
GO
