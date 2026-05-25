-- ================================================================================
-- SIMPLIFY SALESORDER TABLE
-- Drop unnecessary columns and keep essential ones
-- ================================================================================

USE GarmentsFactoryDB;
GO

PRINT 'Starting SalesOrder table simplification...';
GO

-- Drop columns that are not needed
IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('SalesOrder') AND name = 'ExpectedDeliveryDate')
    ALTER TABLE SalesOrder DROP COLUMN ExpectedDeliveryDate;
GO

IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('SalesOrder') AND name = 'PriorityLevel')
    ALTER TABLE SalesOrder DROP COLUMN PriorityLevel;
GO

IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('SalesOrder') AND name = 'SpecialInstructions')
    ALTER TABLE SalesOrder DROP COLUMN SpecialInstructions;
GO

IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('SalesOrder') AND name = 'PaymentTerms')
    ALTER TABLE SalesOrder DROP COLUMN PaymentTerms;
GO

IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('SalesOrder') AND name = 'AdvancePaymentPercent')
    ALTER TABLE SalesOrder DROP COLUMN AdvancePaymentPercent;
GO

IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('SalesOrder') AND name = 'PaymentStatus')
    ALTER TABLE SalesOrder DROP COLUMN PaymentStatus;
GO

IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('SalesOrder') AND name = 'TaxAmount')
    ALTER TABLE SalesOrder DROP COLUMN TaxAmount;
GO

IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('SalesOrder') AND name = 'OrderSource')
    ALTER TABLE SalesOrder DROP COLUMN OrderSource;
GO

IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('SalesOrder') AND name = 'InternalNotes')
    ALTER TABLE SalesOrder DROP COLUMN InternalNotes;
GO

IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('SalesOrder') AND name = 'Tags')
    ALTER TABLE SalesOrder DROP COLUMN Tags;
GO

PRINT 'SalesOrder table columns dropped successfully!';
PRINT 'Remaining columns: SalesOrderID, OrderDate, Status, RetailerID, ShippingAddress, DiscountPercentage, SubTotal, DiscountAmount, TotalAmount, SalesRepID, CreatedDate, UpdatedDate';
GO

-- ================================================================================
-- UPDATE sp_GetAllSalesOrders
-- ================================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetAllSalesOrders')
    DROP PROCEDURE sp_GetAllSalesOrders;
GO

CREATE PROCEDURE sp_GetAllSalesOrders
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        so.SalesOrderID,
        so.OrderDate,
        so.Status,
        so.RetailerID,
        r.CompanyName AS RetailerName,
        so.ShippingAddress,
        so.DiscountPercentage,
        so.SubTotal,
        so.DiscountAmount,
        so.TotalAmount,
        so.SalesRepID,
        e.FirstName + ' ' + e.LastName AS SalesRepName,
        so.CreatedDate,
        so.UpdatedDate
    FROM SalesOrder so
    LEFT JOIN Retailer r ON so.RetailerID = r.RetailerID
    LEFT JOIN Employee e ON so.SalesRepID = e.EmployeeID
    ORDER BY so.OrderDate DESC;
END
GO

PRINT 'sp_GetAllSalesOrders updated successfully!';
GO

-- ================================================================================
-- UPDATE sp_GetSalesOrderById
-- ================================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetSalesOrderById')
    DROP PROCEDURE sp_GetSalesOrderById;
GO

CREATE PROCEDURE sp_GetSalesOrderById
    @SalesOrderID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        so.SalesOrderID,
        so.OrderDate,
        so.Status,
        so.RetailerID,
        r.CompanyName AS RetailerName,
        so.ShippingAddress,
        so.DiscountPercentage,
        so.SubTotal,
        so.DiscountAmount,
        so.TotalAmount,
        so.SalesRepID,
        e.FirstName + ' ' + e.LastName AS SalesRepName,
        so.CreatedDate,
        so.UpdatedDate
    FROM SalesOrder so
    LEFT JOIN Retailer r ON so.RetailerID = r.RetailerID
    LEFT JOIN Employee e ON so.SalesRepID = e.EmployeeID
    WHERE so.SalesOrderID = @SalesOrderID;
END
GO

PRINT 'sp_GetSalesOrderById updated successfully!';
GO

-- ================================================================================
-- UPDATE sp_AddSalesOrder
-- ================================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_AddSalesOrder')
    DROP PROCEDURE sp_AddSalesOrder;
GO

CREATE PROCEDURE sp_AddSalesOrder
    @OrderDate DATETIME,
    @Status VARCHAR(50),
    @RetailerID INT,
    @ShippingAddress VARCHAR(500) = NULL,
    @DiscountPercentage DECIMAL(5,2) = 0,
    @SubTotal DECIMAL(18,2),
    @DiscountAmount DECIMAL(18,2) = 0,
    @TotalAmount DECIMAL(18,2),
    @SalesRepID INT,
    @NewSalesOrderID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO SalesOrder (
        OrderDate, Status, RetailerID, ShippingAddress,
        DiscountPercentage, SubTotal, DiscountAmount, TotalAmount,
        SalesRepID, CreatedDate, UpdatedDate
    )
    VALUES (
        @OrderDate, @Status, @RetailerID, @ShippingAddress,
        @DiscountPercentage, @SubTotal, @DiscountAmount, @TotalAmount,
        @SalesRepID, GETDATE(), GETDATE()
    );
    
    SET @NewSalesOrderID = SCOPE_IDENTITY();
END
GO

PRINT 'sp_AddSalesOrder updated successfully!';
GO

-- ================================================================================
-- UPDATE sp_UpdateSalesOrder
-- ================================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_UpdateSalesOrder')
    DROP PROCEDURE sp_UpdateSalesOrder;
GO

CREATE PROCEDURE sp_UpdateSalesOrder
    @SalesOrderID INT,
    @OrderDate DATETIME,
    @Status VARCHAR(50),
    @RetailerID INT,
    @ShippingAddress VARCHAR(500) = NULL,
    @DiscountPercentage DECIMAL(5,2) = 0,
    @SubTotal DECIMAL(18,2),
    @DiscountAmount DECIMAL(18,2) = 0,
    @TotalAmount DECIMAL(18,2),
    @SalesRepID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE SalesOrder
    SET 
        OrderDate = @OrderDate,
        Status = @Status,
        RetailerID = @RetailerID,
        ShippingAddress = @ShippingAddress,
        DiscountPercentage = @DiscountPercentage,
        SubTotal = @SubTotal,
        DiscountAmount = @DiscountAmount,
        TotalAmount = @TotalAmount,
        SalesRepID = @SalesRepID,
        UpdatedDate = GETDATE()
    WHERE SalesOrderID = @SalesOrderID;
END
GO

PRINT 'sp_UpdateSalesOrder updated successfully!';
GO

-- ================================================================================
-- UPDATE sp_SearchSalesOrders
-- ================================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_SearchSalesOrders')
    DROP PROCEDURE sp_SearchSalesOrders;
GO

CREATE PROCEDURE sp_SearchSalesOrders
    @SearchTerm VARCHAR(100) = NULL,
    @Status VARCHAR(50) = NULL,
    @SalesRepID INT = NULL,
    @StartDate DATETIME = NULL,
    @EndDate DATETIME = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        so.SalesOrderID,
        so.OrderDate,
        so.Status,
        so.RetailerID,
        r.CompanyName AS RetailerName,
        so.ShippingAddress,
        so.DiscountPercentage,
        so.SubTotal,
        so.DiscountAmount,
        so.TotalAmount,
        so.SalesRepID,
        e.FirstName + ' ' + e.LastName AS SalesRepName,
        so.CreatedDate,
        so.UpdatedDate
    FROM SalesOrder so
    LEFT JOIN Retailer r ON so.RetailerID = r.RetailerID
    LEFT JOIN Employee e ON so.SalesRepID = e.EmployeeID
    WHERE 
        (@SearchTerm IS NULL OR 
         r.CompanyName LIKE '%' + @SearchTerm + '%' OR
         CAST(so.SalesOrderID AS VARCHAR) LIKE '%' + @SearchTerm + '%')
        AND (@Status IS NULL OR so.Status = @Status)
        AND (@SalesRepID IS NULL OR so.SalesRepID = @SalesRepID)
        AND (@StartDate IS NULL OR so.OrderDate >= @StartDate)
        AND (@EndDate IS NULL OR so.OrderDate <= @EndDate)
    ORDER BY so.OrderDate DESC;
END
GO

PRINT 'sp_SearchSalesOrders updated successfully!';
GO

PRINT '=================================================================';
PRINT 'SalesOrder table simplified successfully!';
PRINT 'Removed: ExpectedDeliveryDate, PriorityLevel, SpecialInstructions,';
PRINT '         PaymentTerms, AdvancePaymentPercent, PaymentStatus,';
PRINT '         TaxAmount, OrderSource, InternalNotes, Tags';
PRINT 'Kept: ShippingAddress, DiscountPercentage, DiscountAmount';
PRINT 'All stored procedures updated!';
PRINT '=================================================================';
GO
