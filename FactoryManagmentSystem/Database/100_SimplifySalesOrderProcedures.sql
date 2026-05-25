-- ================================================================================
-- SIMPLIFIED SALES ORDER PROCEDURES
-- ================================================================================
-- This script updates all Sales Order procedures to work with the simplified table
-- SalesOrder columns: SalesOrderID, OrderDate, Status, RetailerID, ShippingAddress,
--                     DiscountPercentage, SubTotal, DiscountAmount, TotalAmount,
--                     SalesRepID, CreatedDate, UpdatedDate
-- ================================================================================

USE GarmentsFactoryDB;
GO

-- ================================================================================
-- 1. GET ALL SALES ORDERS
-- ================================================================================
DROP PROCEDURE IF EXISTS sp_GetAllSalesOrders;
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
        CONCAT(e.FirstName, ' ', e.LastName) AS SalesRepName,
        so.CreatedDate,
        so.UpdatedDate,
        (SELECT COUNT(*) FROM SalesOrderItem WHERE SalesOrderID = so.SalesOrderID) AS ItemCount
    FROM SalesOrder so
    LEFT JOIN Retailer r ON so.RetailerID = r.RetailerID
    LEFT JOIN Employee e ON so.SalesRepID = e.EmployeeID
    ORDER BY so.CreatedDate DESC;
END
GO

PRINT 'sp_GetAllSalesOrders updated successfully.';
GO

-- ================================================================================
-- 2. GET SALES ORDER BY ID (WITH ITEMS)
-- ================================================================================
DROP PROCEDURE IF EXISTS sp_GetSalesOrderById;
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
        so.Status,
        so.RetailerID,
        r.CompanyName AS RetailerName,
        so.ShippingAddress,
        so.DiscountPercentage,
        so.SubTotal,
        so.DiscountAmount,
        so.TotalAmount,
        so.SalesRepID,
        CONCAT(e.FirstName, ' ', e.LastName) AS SalesRepName,
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

PRINT 'sp_GetSalesOrderById updated successfully.';
GO

-- ================================================================================
-- 3. ADD NEW SALES ORDER WITH ITEMS
-- ================================================================================
DROP PROCEDURE IF EXISTS sp_AddSalesOrder;
GO

CREATE PROCEDURE sp_AddSalesOrder
    @OrderDate DATETIME = NULL,
    @Status NVARCHAR(30) = 'Pending',
    @RetailerID INT,
    @ShippingAddress NVARCHAR(500) = NULL,
    @DiscountPercentage DECIMAL(5,2) = 0,
    @SubTotal DECIMAL(18,2) = 0,
    @DiscountAmount DECIMAL(18,2) = 0,
    @TotalAmount DECIMAL(18,2),
    @SalesRepID INT = NULL,
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
            OrderDate, Status, RetailerID, ShippingAddress,
            DiscountPercentage, SubTotal, DiscountAmount, TotalAmount,
            SalesRepID, CreatedDate
        )
        VALUES (
            @OrderDate, @Status, @RetailerID, @ShippingAddress,
            @DiscountPercentage, @SubTotal, @DiscountAmount, @TotalAmount,
            @SalesRepID, GETDATE()
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

PRINT 'sp_AddSalesOrder updated successfully.';
GO

-- ================================================================================
-- 4. UPDATE SALES ORDER WITH ITEMS
-- ================================================================================
DROP PROCEDURE IF EXISTS sp_UpdateSalesOrder;
GO

CREATE PROCEDURE sp_UpdateSalesOrder
    @SalesOrderID INT,
    @OrderDate DATETIME,
    @Status NVARCHAR(30) = 'Pending',
    @RetailerID INT,
    @ShippingAddress NVARCHAR(500) = NULL,
    @DiscountPercentage DECIMAL(5,2) = 0,
    @SubTotal DECIMAL(18,2) = 0,
    @DiscountAmount DECIMAL(18,2) = 0,
    @TotalAmount DECIMAL(18,2),
    @SalesRepID INT = NULL,
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

PRINT 'sp_UpdateSalesOrder updated successfully.';
GO

-- ================================================================================
-- 5. DELETE SALES ORDER
-- ================================================================================
DROP PROCEDURE IF EXISTS sp_DeleteSalesOrder;
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
        
        -- Delete order items first
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

PRINT 'sp_DeleteSalesOrder updated successfully.';
GO

-- ================================================================================
-- 6. SEARCH SALES ORDERS
-- ================================================================================
DROP PROCEDURE IF EXISTS sp_SearchSalesOrders;
GO

CREATE PROCEDURE sp_SearchSalesOrders
    @SearchTerm NVARCHAR(100) = NULL,
    @Status NVARCHAR(30) = NULL,
    @RetailerID INT = NULL,
    @StartDate DATE = NULL,
    @EndDate DATE = NULL
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
        CONCAT(e.FirstName, ' ', e.LastName) AS SalesRepName,
        so.CreatedDate,
        so.UpdatedDate,
        (SELECT COUNT(*) FROM SalesOrderItem WHERE SalesOrderID = so.SalesOrderID) AS ItemCount
    FROM SalesOrder so
    LEFT JOIN Retailer r ON so.RetailerID = r.RetailerID
    LEFT JOIN Employee e ON so.SalesRepID = e.EmployeeID
    WHERE 
        (@SearchTerm IS NULL OR 
         r.CompanyName LIKE '%' + @SearchTerm + '%' OR
         CAST(so.SalesOrderID AS NVARCHAR) LIKE '%' + @SearchTerm + '%')
        AND (@Status IS NULL OR so.Status = @Status)
        AND (@RetailerID IS NULL OR so.RetailerID = @RetailerID)
        AND (@StartDate IS NULL OR so.OrderDate >= @StartDate)
        AND (@EndDate IS NULL OR so.OrderDate <= @EndDate)
    ORDER BY so.CreatedDate DESC;
END
GO

PRINT 'sp_SearchSalesOrders updated successfully.';
GO

-- ================================================================================
-- 7. UPDATE SALES ORDER STATUS
-- ================================================================================
DROP PROCEDURE IF EXISTS sp_UpdateSalesOrderStatus;
GO

CREATE PROCEDURE sp_UpdateSalesOrderStatus
    @SalesOrderID INT,
    @Status NVARCHAR(30)
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validate sales order exists
    IF NOT EXISTS (SELECT 1 FROM SalesOrder WHERE SalesOrderID = @SalesOrderID)
    BEGIN
        RAISERROR('Sales Order not found.', 16, 1);
        RETURN;
    END
    
    UPDATE SalesOrder
    SET Status = @Status, UpdatedDate = GETDATE()
    WHERE SalesOrderID = @SalesOrderID;
    
    PRINT 'Sales Order status updated successfully.';
END
GO

PRINT 'sp_UpdateSalesOrderStatus updated successfully.';
GO

-- ================================================================================
-- 8. GET RETAILERS FOR ORDER DROPDOWN
-- ================================================================================
DROP PROCEDURE IF EXISTS sp_GetRetailersForOrder;
GO

CREATE PROCEDURE sp_GetRetailersForOrder
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        RetailerID,
        CompanyName,
        ContactPerson,
        Phone,
        Email,
        City,
        Province,
        ShippingAddress,
        Status
    FROM Retailer
    WHERE Status = 'Active'
    ORDER BY CompanyName;
END
GO

PRINT 'sp_GetRetailersForOrder updated successfully.';
GO

-- ================================================================================
-- 9. GET SALESPERSONS FOR ORDER DROPDOWN
-- ================================================================================
DROP PROCEDURE IF EXISTS sp_GetSalespersonsForOrder;
GO

CREATE PROCEDURE sp_GetSalespersonsForOrder
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        e.EmployeeID,
        CONCAT(e.FirstName, ' ', e.LastName) AS FullName,
        e.Email,
        e.Phone,
        d.DepartmentName AS Department
    FROM Employee e
    LEFT JOIN Department d ON e.DepartmentID = d.DepartmentID
    WHERE e.Status = 'Active' 
        AND d.DepartmentName IN ('Sales', 'Sales Department')
    ORDER BY e.FirstName, e.LastName;
END
GO

PRINT 'sp_GetSalespersonsForOrder updated successfully.';
GO

-- ================================================================================
-- 10. GET PRODUCTS FOR ORDER DROPDOWN
-- ================================================================================
DROP PROCEDURE IF EXISTS sp_GetProductsForOrder;
GO

CREATE PROCEDURE sp_GetProductsForOrder
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        ProductID,
        ProductName,
        SKU,
        Category,
        Brand,
        Size,
        Color,
        UnitPrice,
        Description
    FROM Product
    WHERE Status = 'Active'
    ORDER BY ProductName;
END
GO

PRINT 'sp_GetProductsForOrder updated successfully.';
GO

-- ================================================================================
-- SUMMARY
-- ================================================================================
PRINT '';
PRINT '============================================================';
PRINT 'ALL SALES ORDER PROCEDURES UPDATED SUCCESSFULLY!';
PRINT '============================================================';
PRINT 'Simplified SalesOrder Table Columns:';
PRINT '  - SalesOrderID (PK)';
PRINT '  - OrderDate';
PRINT '  - Status';
PRINT '  - RetailerID (FK)';
PRINT '  - ShippingAddress';
PRINT '  - DiscountPercentage';
PRINT '  - SubTotal';
PRINT '  - DiscountAmount';
PRINT '  - TotalAmount';
PRINT '  - SalesRepID (FK)';
PRINT '  - CreatedDate';
PRINT '  - UpdatedDate';
PRINT '============================================================';
PRINT 'Procedures Updated:';
PRINT '  1. sp_GetAllSalesOrders';
PRINT '  2. sp_GetSalesOrderById';
PRINT '  3. sp_AddSalesOrder';
PRINT '  4. sp_UpdateSalesOrder';
PRINT '  5. sp_DeleteSalesOrder';
PRINT '  6. sp_SearchSalesOrders';
PRINT '  7. sp_UpdateSalesOrderStatus';
PRINT '  8. sp_GetRetailersForOrder';
PRINT '  9. sp_GetSalespersonsForOrder';
PRINT '  10. sp_GetProductsForOrder';
PRINT '============================================================';
GO
