-- ================================================================================
-- SALES ORDER MANAGEMENT - STORED PROCEDURES
-- ================================================================================
-- Execute this script in SQL Server Management Studio (SSMS)
-- Make sure you're connected to GarmentsFactoryDB database
-- ================================================================================

USE GarmentsFactoryDB;
GO

-- ================================================================================
-- 1. GET ALL SALES ORDERS (For View All Tab)
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
        so.ExpectedDeliveryDate,
        so.PriorityLevel,
        so.Status,
        so.RetailerID,
        r.CompanyName AS RetailerName,
        r.ContactPerson,
        r.Phone AS RetailerPhone,
        r.Email AS RetailerEmail,
        so.ShippingAddress,
        so.SpecialInstructions,
        so.PaymentTerms,
        so.AdvancePaymentPercent,
        so.DiscountPercentage,
        so.PaymentStatus,
        so.SubTotal,
        so.DiscountAmount,
        so.TaxAmount,
        so.TotalAmount,
        so.SalesRepID,
        CONCAT(e.FirstName, ' ', e.LastName) AS SalesRepName,
        so.OrderSource,
        so.InternalNotes,
        so.Tags,
        so.CreatedDate,
        so.UpdatedDate,
        (SELECT COUNT(*) FROM SalesOrderItem WHERE SalesOrderID = so.SalesOrderID) AS ItemCount
    FROM SalesOrder so
    LEFT JOIN Retailer r ON so.RetailerID = r.RetailerID
    LEFT JOIN Employee e ON so.SalesRepID = e.EmployeeID
    ORDER BY so.CreatedDate DESC;
END
GO

PRINT 'sp_GetAllSalesOrders created successfully.';
GO

-- ================================================================================
-- 2. GET SALES ORDER BY ID (For Update/Delete/Details)
-- ================================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetSalesOrderById')
    DROP PROCEDURE sp_GetSalesOrderById;
GO

CREATE PROCEDURE sp_GetSalesOrderById
    @SalesOrderID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Get Sales Order Header
    SELECT 
        so.SalesOrderID,
        so.OrderDate,
        so.ExpectedDeliveryDate,
        so.PriorityLevel,
        so.Status,
        so.RetailerID,
        r.CompanyName AS RetailerName,
        r.ContactPerson,
        r.Phone AS RetailerPhone,
        r.Email AS RetailerEmail,
        so.ShippingAddress,
        so.SpecialInstructions,
        so.PaymentTerms,
        so.AdvancePaymentPercent,
        so.DiscountPercentage,
        so.PaymentStatus,
        so.SubTotal,
        so.DiscountAmount,
        so.TaxAmount,
        so.TotalAmount,
        so.SalesRepID,
        CONCAT(e.FirstName, ' ', e.LastName) AS SalesRepName,
        so.OrderSource,
        so.InternalNotes,
        so.Tags,
        so.CreatedDate,
        so.UpdatedDate
    FROM SalesOrder so
    LEFT JOIN Retailer r ON so.RetailerID = r.RetailerID
    LEFT JOIN Employee e ON so.SalesRepID = e.EmployeeID
    WHERE so.SalesOrderID = @SalesOrderID;
    
    -- Get Sales Order Items
    SELECT 
        soi.SalesOrderItemID,
        soi.SalesOrderID,
        soi.ProductID,
        p.ProductName,
        p.Category,
        p.Brand,
        soi.Size,
        soi.Color,
        soi.Quantity,
        soi.UnitPrice,
        soi.Discount,
        soi.TotalPrice
    FROM SalesOrderItem soi
    INNER JOIN Product p ON soi.ProductID = p.ProductID
    WHERE soi.SalesOrderID = @SalesOrderID;
END
GO

PRINT 'sp_GetSalesOrderById created successfully.';
GO

-- ================================================================================
-- 3. ADD NEW SALES ORDER WITH ITEMS (For Create Order)
-- ================================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_AddSalesOrder')
    DROP PROCEDURE sp_AddSalesOrder;
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE sp_AddSalesOrder
    -- Order Information
    @OrderDate DATETIME = NULL,
    @ExpectedDeliveryDate DATE = NULL,
    @PriorityLevel NVARCHAR(20) = 'Medium',
    @Status NVARCHAR(30) = 'Pending',
    
    -- Customer Information
    @RetailerID INT,
    @ShippingAddress NVARCHAR(500) = NULL,
    @SpecialInstructions NVARCHAR(500) = NULL,
    
    -- Payment Information
    @PaymentTerms NVARCHAR(30) = NULL,
    @AdvancePaymentPercent DECIMAL(5,2) = 0,
    @DiscountPercentage DECIMAL(5,2) = 0,
    @PaymentStatus NVARCHAR(20) = 'Pending',
    
    -- Order Summary
    @SubTotal DECIMAL(18,2) = 0,
    @DiscountAmount DECIMAL(18,2) = 0,
    @TaxAmount DECIMAL(18,2) = 0,
    @TotalAmount DECIMAL(18,2),
    
    -- Additional Information
    @SalesRepID INT = NULL,
    @OrderSource NVARCHAR(30) = NULL,
    @InternalNotes NVARCHAR(1000) = NULL,
    @Tags NVARCHAR(200) = NULL,
    
    -- Order Items (XML format)
    @OrderItemsXML XML = NULL,
    
    @NewSalesOrderID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Set default OrderDate if not provided
        IF @OrderDate IS NULL
            SET @OrderDate = GETDATE();
        
        -- Validate required fields
        IF @RetailerID IS NULL
        BEGIN
            RAISERROR('Retailer is required.', 16, 1);
            RETURN;
        END
        
        -- Validate Retailer exists
        IF NOT EXISTS (SELECT 1 FROM Retailer WHERE RetailerID = @RetailerID)
        BEGIN
            RAISERROR('Invalid Retailer ID.', 16, 1);
            RETURN;
        END
        
        -- Validate SalesRepID if provided
        IF @SalesRepID IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Employee WHERE EmployeeID = @SalesRepID)
        BEGIN
            RAISERROR('Invalid Sales Representative ID.', 16, 1);
            RETURN;
        END
        
        -- Insert Sales Order Header
        INSERT INTO SalesOrder (
            OrderDate, ExpectedDeliveryDate, PriorityLevel, Status,
            RetailerID, ShippingAddress, SpecialInstructions,
            PaymentTerms, AdvancePaymentPercent, DiscountPercentage, PaymentStatus,
            SubTotal, DiscountAmount, TaxAmount, TotalAmount,
            SalesRepID, OrderSource, InternalNotes, Tags,
            CreatedDate
        )
        VALUES (
            @OrderDate, @ExpectedDeliveryDate, @PriorityLevel, @Status,
            @RetailerID, @ShippingAddress, @SpecialInstructions,
            @PaymentTerms, @AdvancePaymentPercent, @DiscountPercentage, @PaymentStatus,
            @SubTotal, @DiscountAmount, @TaxAmount, @TotalAmount,
            @SalesRepID, @OrderSource, @InternalNotes, @Tags,
            GETDATE()
        );
        
        SET @NewSalesOrderID = SCOPE_IDENTITY();
        
        -- Insert Sales Order Items from XML
        IF @OrderItemsXML IS NOT NULL
        BEGIN
            INSERT INTO SalesOrderItem (SalesOrderID, ProductID, Size, Color, Quantity, UnitPrice, Discount)
            SELECT 
                @NewSalesOrderID,
                Item.value('(ProductID)[1]', 'INT'),
                Item.value('(Size)[1]', 'NVARCHAR(20)'),
                Item.value('(Color)[1]', 'NVARCHAR(50)'),
                Item.value('(Quantity)[1]', 'INT'),
                Item.value('(UnitPrice)[1]', 'DECIMAL(18,2)'),
                Item.value('(Discount)[1]', 'DECIMAL(18,2)')
            FROM @OrderItemsXML.nodes('/Items/Item') AS Items(Item);
        END
        
        COMMIT TRANSACTION;
        
        PRINT 'Sales Order added successfully with ID: ' + CAST(@NewSalesOrderID AS VARCHAR(10));
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

PRINT 'sp_AddSalesOrder created successfully.';
GO

-- ================================================================================
-- 4. UPDATE SALES ORDER WITH ITEMS (For Update Order)
-- ================================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_UpdateSalesOrder')
    DROP PROCEDURE sp_UpdateSalesOrder;
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE sp_UpdateSalesOrder
    @SalesOrderID INT,
    
    -- Order Information
    @OrderDate DATETIME,
    @ExpectedDeliveryDate DATE = NULL,
    @PriorityLevel NVARCHAR(20) = 'Medium',
    @Status NVARCHAR(30) = 'Pending',
    
    -- Customer Information
    @RetailerID INT,
    @ShippingAddress NVARCHAR(500) = NULL,
    @SpecialInstructions NVARCHAR(500) = NULL,
    
    -- Payment Information
    @PaymentTerms NVARCHAR(30) = NULL,
    @AdvancePaymentPercent DECIMAL(5,2) = 0,
    @DiscountPercentage DECIMAL(5,2) = 0,
    @PaymentStatus NVARCHAR(20) = 'Pending',
    
    -- Order Summary
    @SubTotal DECIMAL(18,2) = 0,
    @DiscountAmount DECIMAL(18,2) = 0,
    @TaxAmount DECIMAL(18,2) = 0,
    @TotalAmount DECIMAL(18,2),
    
    -- Additional Information
    @SalesRepID INT = NULL,
    @OrderSource NVARCHAR(30) = NULL,
    @InternalNotes NVARCHAR(1000) = NULL,
    @Tags NVARCHAR(200) = NULL,
    
    -- Order Items (XML format)
    @OrderItemsXML XML = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validate sales order exists
        IF NOT EXISTS (SELECT 1 FROM SalesOrder WHERE SalesOrderID = @SalesOrderID)
        BEGIN
            RAISERROR('Sales Order not found.', 16, 1);
            RETURN;
        END
        
        -- Validate required fields
        IF @RetailerID IS NULL
        BEGIN
            RAISERROR('Retailer is required.', 16, 1);
            RETURN;
        END
        
        -- Validate Retailer exists
        IF NOT EXISTS (SELECT 1 FROM Retailer WHERE RetailerID = @RetailerID)
        BEGIN
            RAISERROR('Invalid Retailer ID.', 16, 1);
            RETURN;
        END
        
        -- Validate SalesRepID if provided
        IF @SalesRepID IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Employee WHERE EmployeeID = @SalesRepID)
        BEGIN
            RAISERROR('Invalid Sales Representative ID.', 16, 1);
            RETURN;
        END
        
        -- Update Sales Order Header
        UPDATE SalesOrder
        SET 
            OrderDate = @OrderDate,
            ExpectedDeliveryDate = @ExpectedDeliveryDate,
            PriorityLevel = @PriorityLevel,
            Status = @Status,
            RetailerID = @RetailerID,
            ShippingAddress = @ShippingAddress,
            SpecialInstructions = @SpecialInstructions,
            PaymentTerms = @PaymentTerms,
            AdvancePaymentPercent = @AdvancePaymentPercent,
            DiscountPercentage = @DiscountPercentage,
            PaymentStatus = @PaymentStatus,
            SubTotal = @SubTotal,
            DiscountAmount = @DiscountAmount,
            TaxAmount = @TaxAmount,
            TotalAmount = @TotalAmount,
            SalesRepID = @SalesRepID,
            OrderSource = @OrderSource,
            InternalNotes = @InternalNotes,
            Tags = @Tags,
            UpdatedDate = GETDATE()
        WHERE SalesOrderID = @SalesOrderID;
        
        -- Delete existing order items
        DELETE FROM SalesOrderItem WHERE SalesOrderID = @SalesOrderID;
        
        -- Insert updated Sales Order Items from XML
        IF @OrderItemsXML IS NOT NULL
        BEGIN
            INSERT INTO SalesOrderItem (SalesOrderID, ProductID, Size, Color, Quantity, UnitPrice, Discount)
            SELECT 
                @SalesOrderID,
                Item.value('(ProductID)[1]', 'INT'),
                Item.value('(Size)[1]', 'NVARCHAR(20)'),
                Item.value('(Color)[1]', 'NVARCHAR(50)'),
                Item.value('(Quantity)[1]', 'INT'),
                Item.value('(UnitPrice)[1]', 'DECIMAL(18,2)'),
                Item.value('(Discount)[1]', 'DECIMAL(18,2)')
            FROM @OrderItemsXML.nodes('/Items/Item') AS Items(Item);
        END
        
        COMMIT TRANSACTION;
        
        PRINT 'Sales Order updated successfully.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

PRINT 'sp_UpdateSalesOrder created successfully.';
GO

-- ================================================================================
-- 5. DELETE SALES ORDER (For Delete Operation)
-- ================================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_DeleteSalesOrder')
    DROP PROCEDURE sp_DeleteSalesOrder;
GO

CREATE PROCEDURE sp_DeleteSalesOrder
    @SalesOrderID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validate sales order exists
        IF NOT EXISTS (SELECT 1 FROM SalesOrder WHERE SalesOrderID = @SalesOrderID)
        BEGIN
            RAISERROR('Sales Order not found.', 16, 1);
            RETURN;
        END
        
        -- Check if order has delivery record
        IF EXISTS (SELECT 1 FROM Delivery WHERE SalesOrderID = @SalesOrderID)
        BEGIN
            RAISERROR('Cannot delete sales order with existing delivery record. Please delete delivery first.', 16, 1);
            RETURN;
        END
        
        -- Delete order items (CASCADE will handle this, but explicit for clarity)
        DELETE FROM SalesOrderItem WHERE SalesOrderID = @SalesOrderID;
        
        -- Delete sales order
        DELETE FROM SalesOrder WHERE SalesOrderID = @SalesOrderID;
        
        COMMIT TRANSACTION;
        
        PRINT 'Sales Order deleted successfully.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

PRINT 'sp_DeleteSalesOrder created successfully.';
GO

-- ================================================================================
-- 6. GET ALL RETAILERS (For Dropdown in Create/Update Order)
-- ================================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetRetailersForOrder')
    DROP PROCEDURE sp_GetRetailersForOrder;
GO

CREATE PROCEDURE sp_GetRetailersForOrder
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        r.RetailerID,
        r.CompanyName,
        r.ContactPerson,
        r.Phone,
        r.Email,
        r.City,
        r.Province,
        r.Address AS ShippingAddress,
        r.Status
    FROM Retailer r
    WHERE r.IsActive = 1 AND r.Status = 'Active'
    ORDER BY r.CompanyName;
END
GO

PRINT 'sp_GetRetailersForOrder created successfully.';
GO

-- ================================================================================
-- 7. GET ALL PRODUCTS (For Dropdown in Order Items)
-- ================================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetProductsForOrder')
    DROP PROCEDURE sp_GetProductsForOrder;
GO

CREATE PROCEDURE sp_GetProductsForOrder
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        p.ProductID,
        p.ProductName,
        p.Category,
        p.Brand,
        p.SalePrice,
        p.AvailableSizes,
        p.AvailableColors,
        p.ProductionStatus
    FROM Product p
    WHERE p.IsActive = 1
    ORDER BY p.ProductName;
END
GO

PRINT 'sp_GetProductsForOrder created successfully.';
GO

-- ================================================================================
-- 8. SEARCH SALES ORDERS (For Search/Filter functionality)
-- ================================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_SearchSalesOrders')
    DROP PROCEDURE sp_SearchSalesOrders;
GO

CREATE PROCEDURE sp_SearchSalesOrders
    @SearchTerm NVARCHAR(100) = NULL,
    @Status NVARCHAR(30) = NULL,
    @PriorityLevel NVARCHAR(20) = NULL,
    @PaymentStatus NVARCHAR(20) = NULL,
    @SalesRepID INT = NULL,
    @StartDate DATE = NULL,
    @EndDate DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        so.SalesOrderID,
        so.OrderDate,
        so.ExpectedDeliveryDate,
        so.PriorityLevel,
        so.Status,
        r.CompanyName AS RetailerName,
        r.ContactPerson,
        r.Phone AS RetailerPhone,
        so.TotalAmount,
        so.PaymentStatus,
        CONCAT(e.FirstName, ' ', e.LastName) AS SalesRepName,
        so.CreatedDate,
        (SELECT COUNT(*) FROM SalesOrderItem WHERE SalesOrderID = so.SalesOrderID) AS ItemCount
    FROM SalesOrder so
    LEFT JOIN Retailer r ON so.RetailerID = r.RetailerID
    LEFT JOIN Employee e ON so.SalesRepID = e.EmployeeID
    WHERE 
        (@SearchTerm IS NULL OR 
         r.CompanyName LIKE '%' + @SearchTerm + '%' OR
         r.ContactPerson LIKE '%' + @SearchTerm + '%' OR
         CAST(so.SalesOrderID AS NVARCHAR) LIKE '%' + @SearchTerm + '%')
        AND (@Status IS NULL OR so.Status = @Status)
        AND (@PriorityLevel IS NULL OR so.PriorityLevel = @PriorityLevel)
        AND (@PaymentStatus IS NULL OR so.PaymentStatus = @PaymentStatus)
        AND (@SalesRepID IS NULL OR so.SalesRepID = @SalesRepID)
        AND (@StartDate IS NULL OR so.OrderDate >= @StartDate)
        AND (@EndDate IS NULL OR so.OrderDate <= @EndDate)
    ORDER BY so.CreatedDate DESC;
END
GO

PRINT 'sp_SearchSalesOrders created successfully.';
GO

-- ================================================================================
-- 9. GET SALES ORDER STATISTICS (For Dashboard/Summary)
-- ================================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetSalesOrderStatistics')
    DROP PROCEDURE sp_GetSalesOrderStatistics;
GO

CREATE PROCEDURE sp_GetSalesOrderStatistics
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        COUNT(*) AS TotalOrders,
        SUM(CASE WHEN Status = 'Pending' THEN 1 ELSE 0 END) AS PendingOrders,
        SUM(CASE WHEN Status = 'Confirmed' THEN 1 ELSE 0 END) AS ConfirmedOrders,
        SUM(CASE WHEN Status = 'InProduction' THEN 1 ELSE 0 END) AS InProductionOrders,
        SUM(CASE WHEN Status = 'Shipped' THEN 1 ELSE 0 END) AS ShippedOrders,
        SUM(CASE WHEN Status = 'Delivered' THEN 1 ELSE 0 END) AS DeliveredOrders,
        SUM(CASE WHEN PriorityLevel = 'Rush' THEN 1 ELSE 0 END) AS RushOrders,
        SUM(CASE WHEN PaymentStatus = 'Pending' THEN 1 ELSE 0 END) AS PendingPayments,
        SUM(CASE WHEN PaymentStatus = 'Paid' THEN 1 ELSE 0 END) AS PaidOrders,
        SUM(TotalAmount) AS TotalRevenue,
        AVG(TotalAmount) AS AverageOrderValue,
        SUM(CASE WHEN CAST(OrderDate AS DATE) = CAST(GETDATE() AS DATE) THEN 1 ELSE 0 END) AS TodayOrders,
        SUM(CASE WHEN OrderDate >= DATEADD(DAY, -7, GETDATE()) THEN 1 ELSE 0 END) AS LastWeekOrders,
        SUM(CASE WHEN OrderDate >= DATEADD(MONTH, -1, GETDATE()) THEN 1 ELSE 0 END) AS LastMonthOrders
    FROM SalesOrder;
END
GO

PRINT 'sp_GetSalesOrderStatistics created successfully.';
GO

-- ================================================================================
-- 10. UPDATE SALES ORDER STATUS (For Quick Status Updates)
-- ================================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_UpdateSalesOrderStatus')
    DROP PROCEDURE sp_UpdateSalesOrderStatus;
GO

CREATE PROCEDURE sp_UpdateSalesOrderStatus
    @SalesOrderID INT,
    @Status NVARCHAR(30),
    @PaymentStatus NVARCHAR(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validate sales order exists
        IF NOT EXISTS (SELECT 1 FROM SalesOrder WHERE SalesOrderID = @SalesOrderID)
        BEGIN
            RAISERROR('Sales Order not found.', 16, 1);
            RETURN;
        END
        
        -- Update status
        UPDATE SalesOrder
        SET 
            Status = @Status,
            PaymentStatus = ISNULL(@PaymentStatus, PaymentStatus),
            UpdatedDate = GETDATE()
        WHERE SalesOrderID = @SalesOrderID;
        
        COMMIT TRANSACTION;
        
        PRINT 'Sales Order status updated successfully.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

PRINT 'sp_UpdateSalesOrderStatus created successfully.';
GO

-- ================================================================================
-- STORED PROCEDURES CREATION COMPLETE!
-- ================================================================================
PRINT '';
PRINT '========================================';
PRINT 'SALES ORDER PROCEDURES CREATED SUCCESSFULLY!';
PRINT 'Total Procedures: 10';
PRINT '';
PRINT 'Procedures Created:';
PRINT '1. sp_GetAllSalesOrders';
PRINT '2. sp_GetSalesOrderById';
PRINT '3. sp_AddSalesOrder';
PRINT '4. sp_UpdateSalesOrder';
PRINT '5. sp_DeleteSalesOrder';
PRINT '6. sp_GetRetailersForOrder';
PRINT '7. sp_GetProductsForOrder';
PRINT '8. sp_SearchSalesOrders';
PRINT '9. sp_GetSalesOrderStatistics';
PRINT '10. sp_UpdateSalesOrderStatus';
PRINT '';
PRINT 'Next Step: Execute this script in SSMS';
PRINT 'Then we will create the SalesOrderDataService.';
PRINT '========================================';
GO
