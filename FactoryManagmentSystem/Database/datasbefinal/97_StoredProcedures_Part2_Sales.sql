-- ================================================================================
-- GARMENTS FACTORY MANAGEMENT SYSTEM - STORED PROCEDURES
-- PART 2: SALES & DEALS PROCEDURES
-- ================================================================================
-- Database: GarmentsFactoryDB
-- Purpose: Sales Order, Deal, and Order Approval Management
-- Created: December 2025
-- Total Procedures in this file: ~35 procedures
-- ================================================================================

USE GarmentsFactoryDB;
GO

-- ================================================================================
-- SECTION 1: SALES ORDER MANAGEMENT
-- ================================================================================

-- PROCEDURE: sp_GetAllSalesOrders
-- Purpose: Retrieve all sales orders with retailer and salesperson information
-- Used by: Sales dashboard, order management screens
IF OBJECT_ID('sp_GetAllSalesOrders', 'P') IS NOT NULL
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
        r.CompanyName AS RetailerName,
        e.FirstName + ' ' + e.LastName AS SalesRep,
        so.TotalAmount,
        so.CreatedDate,
        so.UpdatedDate
    FROM SalesOrder so
    JOIN Retailer r ON so.RetailerID = r.RetailerID
    LEFT JOIN Employee e ON so.SalesRepID = e.EmployeeID
    ORDER BY so.OrderDate DESC;
END
GO

PRINT '✓ sp_GetAllSalesOrders created';
GO

-- PROCEDURE: sp_GetSalesOrderById
-- Purpose: Get specific sales order with items
IF OBJECT_ID('sp_GetSalesOrderById', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetSalesOrderById;
GO

CREATE PROCEDURE sp_GetSalesOrderById
    @SalesOrderID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Get order header
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
        e.FirstName + ' ' + e.LastName AS SalesRep,
        so.CreatedDate,
        so.UpdatedDate
    FROM SalesOrder so
    JOIN Retailer r ON so.RetailerID = r.RetailerID
    LEFT JOIN Employee e ON so.SalesRepID = e.EmployeeID
    WHERE so.SalesOrderID = @SalesOrderID;
    
    -- Get order items
    SELECT 
        soi.SalesOrderItemID,
        soi.ProductID,
        p.ProductName,
        soi.Size,
        soi.Color,
        soi.Quantity,
        soi.UnitPrice,
        soi.Discount,
        soi.TotalPrice
    FROM SalesOrderItem soi
    JOIN Product p ON soi.ProductID = p.ProductID
    WHERE soi.SalesOrderID = @SalesOrderID;
END
GO

PRINT '✓ sp_GetSalesOrderById created';
GO

-- PROCEDURE: sp_AddSalesOrder
-- Purpose: Create a new sales order and auto-create approval request
-- Used by: Sales order creation screen
-- Automation: Creates OrderApproval record automatically
IF OBJECT_ID('sp_AddSalesOrder', 'P') IS NOT NULL
    DROP PROCEDURE sp_AddSalesOrder;
GO

CREATE PROCEDURE sp_AddSalesOrder
    @OrderDate DATETIME = NULL,
    @Status NVARCHAR(60) = 'Pending Approval',
    @RetailerID INT,
    @ShippingAddress NVARCHAR(1000) = NULL,
    @DiscountPercentage DECIMAL(5,2) = 0,
    @SubTotal DECIMAL(18,2) = 0,
    @DiscountAmount DECIMAL(18,2) = 0,
    @TotalAmount DECIMAL(18,2) = 0,
    @SalesRepID INT = NULL,
    @NewSalesOrderID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Insert Sales Order
        INSERT INTO SalesOrder (
            OrderDate, Status, RetailerID, ShippingAddress, DiscountPercentage,
            SubTotal, DiscountAmount, TotalAmount, SalesRepID, CreatedDate
        )
        VALUES (
            ISNULL(@OrderDate, GETDATE()), 'Pending Approval', @RetailerID, @ShippingAddress,
            @DiscountPercentage, @SubTotal, @DiscountAmount, @TotalAmount, @SalesRepID, GETDATE()
        );

        SET @NewSalesOrderID = SCOPE_IDENTITY();

        -- Create approval request automatically
        INSERT INTO OrderApproval (OrderType, OrderID, RequestedByEmployeeID, Status, RequestDate, CreatedDate)
        VALUES ('SalesOrder', @NewSalesOrderID, @SalesRepID, 'Pending', GETDATE(), GETDATE());

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

PRINT '✓ sp_AddSalesOrder created (with auto-approval request)';
GO

-- PROCEDURE: sp_AddSalesOrderItem
-- Purpose: Add item to sales order and AUTO-UPDATE ORDER TOTAL
-- Automation: Automatically recalculates SalesOrder.TotalAmount
IF OBJECT_ID('sp_AddSalesOrderItem', 'P') IS NOT NULL
    DROP PROCEDURE sp_AddSalesOrderItem;
GO

CREATE PROCEDURE sp_AddSalesOrderItem
    @SalesOrderID INT,
    @ProductID INT,
    @Quantity INT,
    @UnitPrice DECIMAL(18,2),
    @SalesOrderItemID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Insert the order item
        INSERT INTO SalesOrderItem (SalesOrderID, ProductID, Quantity, UnitPrice)
        VALUES (@SalesOrderID, @ProductID, @Quantity, @UnitPrice);

        SET @SalesOrderItemID = SCOPE_IDENTITY();

        -- AUTO-UPDATE ORDER TOTAL
        UPDATE SalesOrder
        SET TotalAmount = (
            SELECT ISNULL(SUM(soi.Quantity * soi.UnitPrice), 0)
            FROM SalesOrderItem soi
            WHERE soi.SalesOrderID = @SalesOrderID
        )
        WHERE SalesOrderID = @SalesOrderID;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

PRINT '✓ sp_AddSalesOrderItem created (with auto-total calculation)';
GO

-- PROCEDURE: sp_UpdateSalesOrder
-- Purpose: Update sales order information
IF OBJECT_ID('sp_UpdateSalesOrder', 'P') IS NOT NULL
    DROP PROCEDURE sp_UpdateSalesOrder;
GO

CREATE PROCEDURE sp_UpdateSalesOrder
    @SalesOrderID INT,
    @OrderDate DATETIME = NULL,
    @Status NVARCHAR(60) = NULL,
    @RetailerID INT,
    @ShippingAddress NVARCHAR(1000) = NULL,
    @DiscountPercentage DECIMAL(5,2) = NULL,
    @SubTotal DECIMAL(18,2) = NULL,
    @DiscountAmount DECIMAL(18,2) = NULL,
    @TotalAmount DECIMAL(18,2) = NULL,
    @SalesRepID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE SalesOrder
    SET OrderDate = ISNULL(@OrderDate, OrderDate),
        Status = ISNULL(@Status, Status),
        RetailerID = @RetailerID,
        ShippingAddress = @ShippingAddress,
        DiscountPercentage = @DiscountPercentage,
        SubTotal = @SubTotal,
        DiscountAmount = @DiscountAmount,
        TotalAmount = ISNULL(@TotalAmount, TotalAmount),
        SalesRepID = @SalesRepID,
        UpdatedDate = GETDATE()
    WHERE SalesOrderID = @SalesOrderID;
END
GO

PRINT '✓ sp_UpdateSalesOrder created';
GO

-- PROCEDURE: sp_UpdateSalesOrderStatus
-- Purpose: Update sales order status
IF OBJECT_ID('sp_UpdateSalesOrderStatus', 'P') IS NOT NULL
    DROP PROCEDURE sp_UpdateSalesOrderStatus;
GO

CREATE PROCEDURE sp_UpdateSalesOrderStatus
    @SalesOrderID INT,
    @Status NVARCHAR(60)
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE SalesOrder
    SET Status = @Status,
        UpdatedDate = GETDATE()
    WHERE SalesOrderID = @SalesOrderID;
END
GO

PRINT '✓ sp_UpdateSalesOrderStatus created';
GO

-- PROCEDURE: sp_DeleteSalesOrder
-- Purpose: Delete sales order (hard delete due to CASCADE on items)
IF OBJECT_ID('sp_DeleteSalesOrder', 'P') IS NOT NULL
    DROP PROCEDURE sp_DeleteSalesOrder;
GO

CREATE PROCEDURE sp_DeleteSalesOrder
    @SalesOrderID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Delete will cascade to SalesOrderItems
    DELETE FROM SalesOrder WHERE SalesOrderID = @SalesOrderID;
END
GO

PRINT '✓ sp_DeleteSalesOrder created';
GO

-- PROCEDURE: sp_GetSalesOrdersByDateRange
-- Purpose: Get sales orders within date range for revenue tracking
-- Used by: Revenue dashboard
IF OBJECT_ID('sp_GetSalesOrdersByDateRange', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetSalesOrdersByDateRange;
GO

CREATE PROCEDURE sp_GetSalesOrdersByDateRange
    @StartDate DATE,
    @EndDate DATE
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        so.SalesOrderID,
        so.OrderDate,
        r.CompanyName AS RetailerName,
        so.Status,
        so.TotalAmount
    FROM SalesOrder so
    LEFT JOIN Retailer r ON so.RetailerID = r.RetailerID
    WHERE CAST(so.OrderDate AS DATE) BETWEEN @StartDate AND @EndDate
      AND so.Status NOT IN ('Cancelled', 'Rejected', 'Pending')
    ORDER BY so.OrderDate DESC;
END
GO

PRINT '✓ sp_GetSalesOrdersByDateRange created';
GO

-- PROCEDURE: sp_SearchSalesOrders
-- Purpose: Search sales orders by retailer, status, or date
IF OBJECT_ID('sp_SearchSalesOrders', 'P') IS NOT NULL
    DROP PROCEDURE sp_SearchSalesOrders;
GO

CREATE PROCEDURE sp_SearchSalesOrders
    @SearchTerm NVARCHAR(200) = NULL,
    @Status NVARCHAR(60) = NULL,
    @StartDate DATE = NULL,
    @EndDate DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        so.SalesOrderID,
        so.OrderDate,
        r.CompanyName AS RetailerName,
        so.Status,
        so.TotalAmount
    FROM SalesOrder so
    JOIN Retailer r ON so.RetailerID = r.RetailerID
    WHERE (@SearchTerm IS NULL OR r.CompanyName LIKE '%' + @SearchTerm + '%')
      AND (@Status IS NULL OR so.Status = @Status)
      AND (@StartDate IS NULL OR CAST(so.OrderDate AS DATE) >= @StartDate)
      AND (@EndDate IS NULL OR CAST(so.OrderDate AS DATE) <= @EndDate)
    ORDER BY so.OrderDate DESC;
END
GO

PRINT '✓ sp_SearchSalesOrders created';
GO

-- ================================================================================
-- SECTION 2: DEAL MANAGEMENT
-- ================================================================================

-- PROCEDURE: sp_GetAllDeals
-- Purpose: Retrieve all deals with client and creator information
-- Used by: Deal management screens
IF OBJECT_ID('sp_GetAllDeals', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetAllDeals;
GO

CREATE PROCEDURE sp_GetAllDeals
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        d.DealID,
        d.DealTitle,
        d.DealType,
        d.ClientName,
        d.ContactPerson,
        d.Email,
        d.Phone,
        d.StartDate,
        d.EndDate,
        d.Status,
        d.TotalAmount,
        e.FirstName + ' ' + e.LastName AS CreatedBy,
        d.CreatedDate,
        d.UpdatedDate
    FROM Deal d
    LEFT JOIN Employee e ON d.CreatedBy = e.EmployeeID
    ORDER BY d.StartDate DESC;
END
GO

PRINT '✓ sp_GetAllDeals created';
GO

-- PROCEDURE: sp_GetDealById
-- Purpose: Get specific deal with items
IF OBJECT_ID('sp_GetDealById', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetDealById;
GO

CREATE PROCEDURE sp_GetDealById
    @DealID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Get deal header
    SELECT 
        d.DealID,
        d.DealTitle,
        d.DealType,
        d.ClientName,
        d.ContactPerson,
        d.Email,
        d.Phone,
        d.ExpectedDuration,
        d.StartDate,
        d.EndDate,
        d.Description,
        d.Status,
        d.CreatedBy,
        e.FirstName + ' ' + e.LastName AS CreatedByName,
        d.DeliveryAddress,
        d.City,
        d.Province,
        d.TotalAmount,
        d.CreatedDate,
        d.UpdatedDate
    FROM Deal d
    LEFT JOIN Employee e ON d.CreatedBy = e.EmployeeID
    WHERE d.DealID = @DealID;
    
    -- Get deal items
    SELECT 
        di.DealItemID,
        di.ProductID,
        p.ProductName,
        di.Quantity,
        di.UnitPrice
    FROM DealItem di
    JOIN Product p ON di.ProductID = p.ProductID
    WHERE di.DealID = @DealID;
END
GO

PRINT '✓ sp_GetDealById created';
GO

-- PROCEDURE: sp_AddDeal
-- Purpose: Create a new deal and auto-create approval request
-- Automation: Creates OrderApproval record automatically
IF OBJECT_ID('sp_AddDeal', 'P') IS NOT NULL
    DROP PROCEDURE sp_AddDeal;
GO

CREATE PROCEDURE sp_AddDeal
    @DealTitle NVARCHAR(200),
    @DealType NVARCHAR(50) = NULL,
    @ClientName NVARCHAR(200),
    @ContactPerson NVARCHAR(100) = NULL,
    @Email NVARCHAR(100) = NULL,
    @Phone NVARCHAR(20) = NULL,
    @ExpectedDuration NVARCHAR(50) = NULL,
    @StartDate DATE = NULL,
    @EndDate DATE = NULL,
    @Description NVARCHAR(MAX) = NULL,
    @Status NVARCHAR(50) = 'Pending Approval',
    @CreatedBy INT = NULL,
    @DeliveryAddress NVARCHAR(500) = NULL,
    @City NVARCHAR(100) = NULL,
    @Province NVARCHAR(100) = NULL,
    @NewDealID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO Deal (
            DealTitle, DealType, ClientName, ContactPerson, Email, Phone,
            ExpectedDuration, StartDate, EndDate, Description, Status,
            CreatedBy, DeliveryAddress, City, Province, CreatedDate
        )
        VALUES (
            @DealTitle, @DealType, @ClientName, @ContactPerson, @Email, @Phone,
            @ExpectedDuration, @StartDate, @EndDate, @Description, 'Pending Approval',
            @CreatedBy, @DeliveryAddress, @City, @Province, GETDATE()
        );

        SET @NewDealID = SCOPE_IDENTITY();

        -- Create approval request automatically
        INSERT INTO OrderApproval (OrderType, OrderID, RequestedByEmployeeID, Status, RequestDate, CreatedDate)
        VALUES ('Deal', @NewDealID, @CreatedBy, 'Pending', GETDATE(), GETDATE());

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

PRINT '✓ sp_AddDeal created (with auto-approval request)';
GO

-- PROCEDURE: sp_AddDealItem
-- Purpose: Add item to deal and AUTO-UPDATE DEAL TOTAL
-- Automation: Automatically recalculates Deal.TotalAmount
IF OBJECT_ID('sp_AddDealItem', 'P') IS NOT NULL
    DROP PROCEDURE sp_AddDealItem;
GO

CREATE PROCEDURE sp_AddDealItem
    @DealID INT,
    @ProductID INT,
    @Quantity INT,
    @UnitPrice DECIMAL(18,2),
    @DealItemID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Insert the deal item
        INSERT INTO DealItem (DealID, ProductID, Quantity, UnitPrice)
        VALUES (@DealID, @ProductID, @Quantity, @UnitPrice);

        SET @DealItemID = SCOPE_IDENTITY();

        -- AUTO-UPDATE DEAL TOTAL
        UPDATE Deal
        SET TotalAmount = (
            SELECT ISNULL(SUM(di.Quantity * di.UnitPrice), 0)
            FROM DealItem di
            WHERE di.DealID = @DealID
        )
        WHERE DealID = @DealID;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

PRINT '✓ sp_AddDealItem created (with auto-total calculation)';
GO

-- PROCEDURE: sp_UpdateDeal
-- Purpose: Update deal information
IF OBJECT_ID('sp_UpdateDeal', 'P') IS NOT NULL
    DROP PROCEDURE sp_UpdateDeal;
GO

CREATE PROCEDURE sp_UpdateDeal
    @DealID INT,
    @DealTitle NVARCHAR(200),
    @DealType NVARCHAR(50) = NULL,
    @ClientName NVARCHAR(200),
    @ContactPerson NVARCHAR(100) = NULL,
    @Email NVARCHAR(100) = NULL,
    @Phone NVARCHAR(20) = NULL,
    @ExpectedDuration NVARCHAR(50) = NULL,
    @StartDate DATE = NULL,
    @EndDate DATE = NULL,
    @Description NVARCHAR(MAX) = NULL,
    @Status NVARCHAR(50) = NULL,
    @DeliveryAddress NVARCHAR(500) = NULL,
    @City NVARCHAR(100) = NULL,
    @Province NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE Deal
    SET DealTitle = @DealTitle,
        DealType = @DealType,
        ClientName = @ClientName,
        ContactPerson = @ContactPerson,
        Email = @Email,
        Phone = @Phone,
        ExpectedDuration = @ExpectedDuration,
        StartDate = @StartDate,
        EndDate = @EndDate,
        Description = @Description,
        Status = ISNULL(@Status, Status),
        DeliveryAddress = @DeliveryAddress,
        City = @City,
        Province = @Province,
        UpdatedDate = GETDATE()
    WHERE DealID = @DealID;
END
GO

PRINT '✓ sp_UpdateDeal created';
GO

-- PROCEDURE: sp_DeleteDeal
-- Purpose: Delete deal (hard delete due to CASCADE on items)
IF OBJECT_ID('sp_DeleteDeal', 'P') IS NOT NULL
    DROP PROCEDURE sp_DeleteDeal;
GO

CREATE PROCEDURE sp_DeleteDeal
    @DealID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Delete will cascade to DealItems
    DELETE FROM Deal WHERE DealID = @DealID;
END
GO

PRINT '✓ sp_DeleteDeal created';
GO

-- PROCEDURE: sp_DeleteDealItem
-- Purpose: Delete deal item and update deal total
IF OBJECT_ID('sp_DeleteDealItem', 'P') IS NOT NULL
    DROP PROCEDURE sp_DeleteDealItem;
GO

CREATE PROCEDURE sp_DeleteDealItem
    @DealItemID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @DealID INT;
        SELECT @DealID = DealID FROM DealItem WHERE DealItemID = @DealItemID;

        -- Delete the item
        DELETE FROM DealItem WHERE DealItemID = @DealItemID;

        -- Update deal total
        UPDATE Deal
        SET TotalAmount = (
            SELECT ISNULL(SUM(di.Quantity * di.UnitPrice), 0)
            FROM DealItem di
            WHERE di.DealID = @DealID
        )
        WHERE DealID = @DealID;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

PRINT '✓ sp_DeleteDealItem created';
GO

-- PROCEDURE: sp_GetDealsByDateRange
-- Purpose: Get deals within date range for revenue tracking
IF OBJECT_ID('sp_GetDealsByDateRange', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetDealsByDateRange;
GO

CREATE PROCEDURE sp_GetDealsByDateRange
    @StartDate DATE,
    @EndDate DATE
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        DealID,
        DealTitle,
        ClientName,
        StartDate,
        Status,
        TotalAmount
    FROM Deal
    WHERE CAST(StartDate AS DATE) BETWEEN @StartDate AND @EndDate
      AND Status NOT IN ('Cancelled', 'Rejected', 'Pending')
    ORDER BY StartDate DESC;
END
GO

PRINT '✓ sp_GetDealsByDateRange created';
GO

-- PROCEDURE: sp_GetDealsByStatus
-- Purpose: Get deals filtered by status
IF OBJECT_ID('sp_GetDealsByStatus', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetDealsByStatus;
GO

CREATE PROCEDURE sp_GetDealsByStatus
    @Status NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        d.DealID,
        d.DealTitle,
        d.ClientName,
        d.StartDate,
        d.EndDate,
        d.Status,
        d.TotalAmount
    FROM Deal d
    WHERE d.Status = @Status
    ORDER BY d.StartDate DESC;
END
GO

PRINT '✓ sp_GetDealsByStatus created';
GO

-- PROCEDURE: sp_GetDealsByEmployee
-- Purpose: Get deals created by specific employee
IF OBJECT_ID('sp_GetDealsByEmployee', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetDealsByEmployee;
GO

CREATE PROCEDURE sp_GetDealsByEmployee
    @EmployeeID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        d.DealID,
        d.DealTitle,
        d.ClientName,
        d.StartDate,
        d.Status,
        d.TotalAmount
    FROM Deal d
    WHERE d.CreatedBy = @EmployeeID
    ORDER BY d.StartDate DESC;
END
GO

PRINT '✓ sp_GetDealsByEmployee created';
GO

-- PROCEDURE: sp_GetDealItems
-- Purpose: Get all items for a specific deal
IF OBJECT_ID('sp_GetDealItems', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetDealItems;
GO

CREATE PROCEDURE sp_GetDealItems
    @DealID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        di.DealItemID,
        di.ProductID,
        p.ProductName,
        di.Quantity,
        di.UnitPrice,
        (di.Quantity * di.UnitPrice) AS TotalPrice
    FROM DealItem di
    JOIN Product p ON di.ProductID = p.ProductID
    WHERE di.DealID = @DealID;
END
GO

PRINT '✓ sp_GetDealItems created';
GO

-- ================================================================================
-- SECTION 3: ORDER APPROVAL & WORKFLOW
-- ================================================================================

-- PROCEDURE: sp_GetPendingApprovals
-- Purpose: Get all pending approval requests for owner dashboard
-- Used by: Owner dashboard to show pending approvals
IF OBJECT_ID('sp_GetPendingApprovals', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetPendingApprovals;
GO

CREATE PROCEDURE sp_GetPendingApprovals
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        oa.ApprovalID,
        oa.OrderType,
        oa.OrderID,
        oa.RequestDate,
        oa.Status,
        e.FirstName + ' ' + e.LastName AS RequestedBy,
        CASE 
            WHEN oa.OrderType = 'SalesOrder' THEN (SELECT r.CompanyName FROM SalesOrder so JOIN Retailer r ON so.RetailerID = r.RetailerID WHERE so.SalesOrderID = oa.OrderID)
            WHEN oa.OrderType = 'Deal' THEN (SELECT ClientName FROM Deal WHERE DealID = oa.OrderID)
        END AS CustomerName,
        CASE 
            WHEN oa.OrderType = 'SalesOrder' THEN (SELECT TotalAmount FROM SalesOrder WHERE SalesOrderID = oa.OrderID)
            WHEN oa.OrderType = 'Deal' THEN (SELECT TotalAmount FROM Deal WHERE DealID = oa.OrderID)
        END AS TotalAmount
    FROM OrderApproval oa
    LEFT JOIN Employee e ON oa.RequestedByEmployeeID = e.EmployeeID
    WHERE oa.Status = 'Pending'
    ORDER BY oa.RequestDate DESC;
END
GO

PRINT '✓ sp_GetPendingApprovals created';
GO

-- PROCEDURE: sp_ApproveOrderAndCreateProduction
-- Purpose: Approve order/deal, check materials, and create production order
-- Used by: Owner dashboard when approving orders
-- Automation: Creates production order and tailor assignments
IF OBJECT_ID('sp_ApproveOrderAndCreateProduction', 'P') IS NOT NULL
    DROP PROCEDURE sp_ApproveOrderAndCreateProduction;
GO

CREATE PROCEDURE sp_ApproveOrderAndCreateProduction
    @ApprovalID INT,
    @OwnerID INT,
    @TailorIDs NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @OrderType NVARCHAR(50), @OrderID INT, @ProductionOrderID INT = NULL;
        DECLARE @InsufficientCount INT = 0;
        DECLARE @ProductID INT, @QuantityOrdered INT;

        -- Get order details
        SELECT @OrderType = OrderType, @OrderID = OrderID
        FROM OrderApproval WHERE ApprovalID = @ApprovalID;

        IF @OrderType IS NULL
        BEGIN
            SELECT 'Error' AS Result, 'Approval request not found.' AS Message, NULL AS ProductionOrderID;
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Check materials availability
        CREATE TABLE #MaterialCheck (
            ProductID INT,
            ProductName NVARCHAR(100),
            QuantityOrdered INT,
            RawMaterialID INT,
            MaterialName NVARCHAR(100),
            RequiredQuantity DECIMAL(18,2),
            AvailableQuantity DECIMAL(18,2),
            Unit NVARCHAR(20),
            Status NVARCHAR(20)
        );

        -- Get products based on order type
        IF @OrderType = 'SalesOrder'
        BEGIN
            INSERT INTO #MaterialCheck (ProductID, ProductName, QuantityOrdered)
            SELECT soi.ProductID, p.ProductName, soi.Quantity
            FROM SalesOrderItem soi
            JOIN Product p ON soi.ProductID = p.ProductID
            WHERE soi.SalesOrderID = @OrderID;
        END
        ELSE IF @OrderType = 'Deal'
        BEGIN
            INSERT INTO #MaterialCheck (ProductID, ProductName, QuantityOrdered)
            SELECT di.ProductID, p.ProductName, di.Quantity
            FROM DealItem di
            JOIN Product p ON di.ProductID = p.ProductID
            WHERE di.DealID = @OrderID;
        END

        -- Check material requirements
        UPDATE mc
        SET
            mc.RawMaterialID = pmr.RawMaterialID,
            mc.MaterialName = rm.MaterialName,
            mc.RequiredQuantity = pmr.QuantityRequired * mc.QuantityOrdered,
            mc.AvailableQuantity = rm.Quantity,
            mc.Unit = rm.Unit,
            mc.Status = CASE
                WHEN rm.Quantity >= (pmr.QuantityRequired * mc.QuantityOrdered) THEN 'Available'
                ELSE 'Insufficient'
            END
        FROM #MaterialCheck mc
        LEFT JOIN ProductMaterialRequirement pmr ON mc.ProductID = pmr.ProductID
        LEFT JOIN RawMaterial rm ON pmr.RawMaterialID = rm.RawMaterialID;

        -- Count insufficient materials
        SELECT @InsufficientCount = COUNT(*) FROM #MaterialCheck WHERE Status = 'Insufficient';

        -- If materials are insufficient, return error
        IF @InsufficientCount > 0
        BEGIN
            SELECT 'Error' AS Result,
                   'Cannot approve order. ' + CAST(@InsufficientCount AS NVARCHAR) + ' material(s) insufficient.' AS Message,
                   NULL AS ProductionOrderID;
            DROP TABLE #MaterialCheck;
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Get first product and quantity for production order
        SELECT TOP 1 @ProductID = ProductID, @QuantityOrdered = QuantityOrdered
        FROM #MaterialCheck;

        -- Check if ProductID was found
        IF @ProductID IS NULL
        BEGIN
            SELECT 'Error' AS Result,
                   'Cannot create production order. No products found in the order.' AS Message,
                   NULL AS ProductionOrderID;
            DROP TABLE #MaterialCheck;
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- **CRITICAL FIX: Deduct raw materials from stock BEFORE dropping the MaterialCheck table**
        -- Deduct materials based on BOM (Bill of Materials)
        DECLARE @RawMaterialID INT, @RequiredQty DECIMAL(18,2);
        DECLARE material_cursor CURSOR FOR
        SELECT DISTINCT mc.RawMaterialID, mc.RequiredQuantity
        FROM #MaterialCheck mc
        WHERE mc.RawMaterialID IS NOT NULL;

        OPEN material_cursor;
        FETCH NEXT FROM material_cursor INTO @RawMaterialID, @RequiredQty;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            -- Deduct the required quantity from raw material stock
            UPDATE RawMaterial
            SET Quantity = Quantity - @RequiredQty,
                UpdatedDate = GETDATE()
            WHERE RawMaterialID = @RawMaterialID;

            FETCH NEXT FROM material_cursor INTO @RawMaterialID, @RequiredQty;
        END

        CLOSE material_cursor;
        DEALLOCATE material_cursor;

        DROP TABLE #MaterialCheck;

        -- Update approval record
        UPDATE OrderApproval
        SET Status = 'Approved',
            ApprovedBy = @OwnerID,
            ApprovalDate = GETDATE(),
            ApprovalStatus = 'Approved'
        WHERE ApprovalID = @ApprovalID;

        -- Update order status
        IF @OrderType = 'SalesOrder'
        BEGIN
            UPDATE SalesOrder SET Status = 'Approved', UpdatedDate = GETDATE() WHERE SalesOrderID = @OrderID;
        END
        ELSE IF @OrderType = 'Deal'
        BEGIN
            UPDATE Deal SET Status = 'Approved', UpdatedDate = GETDATE() WHERE DealID = @OrderID;
        END

        -- Create ProductionOrder (handle ownerID = 0 by setting it to NULL)
        DECLARE @CreatedBy INT = CASE WHEN @OwnerID = 0 THEN NULL ELSE @OwnerID END;
        
        INSERT INTO ProductionOrder (ProductID, QuantityOrdered, Status, Priority, CreatedByEmployeeID, CreatedDate, StartDate)
        VALUES (@ProductID, @QuantityOrdered, 'Pending', 'Normal', @CreatedBy, GETDATE(), GETDATE());

        SET @ProductionOrderID = SCOPE_IDENTITY();

        -- Assign tailors if provided
        IF @TailorIDs IS NOT NULL AND @TailorIDs != ''
        BEGIN
            DECLARE @TailorID INT;
            DECLARE @Pos INT;
            DECLARE @TailorList NVARCHAR(500) = @TailorIDs;

            WHILE LEN(@TailorList) > 0
            BEGIN
                SET @Pos = CHARINDEX(',', @TailorList);
                IF @Pos = 0
                BEGIN
                    SET @TailorID = CAST(@TailorList AS INT);
                    SET @TailorList = '';
                END
                ELSE
                BEGIN
                    SET @TailorID = CAST(LEFT(@TailorList, @Pos - 1) AS INT);
                    SET @TailorList = SUBSTRING(@TailorList, @Pos + 1, LEN(@TailorList));
                END

                -- Create assignment with ProductionOrderID and ProductID
                IF @OrderType = 'SalesOrder'
                BEGIN
                    INSERT INTO TailorAssignment (TailorID, ProductionOrderID, SalesOrderID, ProductID, QuantityAssigned, AssignedDate, Status)
                    VALUES (@TailorID, @ProductionOrderID, @OrderID, @ProductID, @QuantityOrdered, GETDATE(), 'Incomplete');
                END
                ELSE IF @OrderType = 'Deal'
                BEGIN
                    INSERT INTO TailorAssignment (TailorID, ProductionOrderID, DealID, ProductID, QuantityAssigned, AssignedDate, Status)
                    VALUES (@TailorID, @ProductionOrderID, @OrderID, @ProductID, @QuantityOrdered, GETDATE(), 'Incomplete');
                END
            END
        END

        COMMIT TRANSACTION;

        SELECT 'Success' AS Result, 'Order approved and production order created successfully.' AS Message, @ProductionOrderID AS ProductionOrderID;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SELECT 'Error' AS Result, ERROR_MESSAGE() AS Message, NULL AS ProductionOrderID;
    END CATCH
END
GO

PRINT '✓ sp_ApproveOrderAndCreateProduction created';
GO

-- PROCEDURE: sp_RejectOrder
-- Purpose: Reject an approval request
IF OBJECT_ID('sp_RejectOrder', 'P') IS NOT NULL
    DROP PROCEDURE sp_RejectOrder;
GO

CREATE PROCEDURE sp_RejectOrder
    @ApprovalID INT,
    @OwnerID INT,
    @Comments NVARCHAR(1000) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @OrderType NVARCHAR(50), @OrderID INT;

        -- Get order details
        SELECT @OrderType = OrderType, @OrderID = OrderID
        FROM OrderApproval WHERE ApprovalID = @ApprovalID;

        -- Update approval record
        UPDATE OrderApproval
        SET Status = 'Rejected',
            ApprovedBy = @OwnerID,
            ApprovalDate = GETDATE(),
            ApprovalStatus = 'Rejected',
            Comments = @Comments
        WHERE ApprovalID = @ApprovalID;

        -- Update order status
        IF @OrderType = 'SalesOrder'
        BEGIN
            UPDATE SalesOrder SET Status = 'Rejected', UpdatedDate = GETDATE() WHERE SalesOrderID = @OrderID;
        END
        ELSE IF @OrderType = 'Deal'
        BEGIN
            UPDATE Deal SET Status = 'Rejected', UpdatedDate = GETDATE() WHERE DealID = @OrderID;
        END

        COMMIT TRANSACTION;

        SELECT 'Success' AS Result, 'Order rejected successfully.' AS Message;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SELECT 'Error' AS Result, ERROR_MESSAGE() AS Message;
    END CATCH
END
GO

PRINT '✓ sp_RejectOrder created';
GO

-- PROCEDURE: sp_GetApprovalHistory
-- Purpose: Get approval history for a specific order
IF OBJECT_ID('sp_GetApprovalHistory', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetApprovalHistory;
GO

CREATE PROCEDURE sp_GetApprovalHistory
    @OrderType NVARCHAR(50) = NULL,
    @OrderID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        oa.ApprovalID,
        oa.OrderType,
        oa.OrderID,
        oa.RequestDate,
        oa.ApprovalDate,
        oa.Status,
        oa.ApprovalStatus,
        oa.Comments,
        req.FirstName + ' ' + req.LastName AS RequestedBy,
        app.FirstName + ' ' + app.LastName AS ApprovedBy
    FROM OrderApproval oa
    LEFT JOIN Employee req ON oa.RequestedByEmployeeID = req.EmployeeID
    LEFT JOIN Employee app ON oa.ApprovedBy = app.EmployeeID
    WHERE (@OrderType IS NULL OR oa.OrderType = @OrderType)
      AND (@OrderID IS NULL OR oa.OrderID = @OrderID)
    ORDER BY oa.RequestDate DESC;
END
GO

PRINT '✓ sp_GetApprovalHistory created';
GO

-- ================================================================================
-- END OF PART 2: SALES & DEALS PROCEDURES
-- ================================================================================
PRINT '';
PRINT '========================================';
PRINT 'PART 2 COMPLETE: Sales & Deals Procedures';
PRINT 'Total: ~25 procedures created';
PRINT '========================================';
GO
