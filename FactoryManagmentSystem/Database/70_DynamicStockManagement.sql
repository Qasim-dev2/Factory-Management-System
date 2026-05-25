-- ================================================================================
-- STOCK MANAGEMENT DYNAMIC FLOW - Complete Implementation
-- ================================================================================
-- This creates a dynamic stock management system with the following flow:
-- 1. When approval is given → Stock entry is auto-generated
-- 2. Ready Products: Completed production + Not delivered
-- 3. In Process: Production orders in progress
-- 4. Shipped: Delivered items
-- ================================================================================
USE GarmentsFactoryDB;
GO

PRINT '======================================================';
PRINT 'CREATING DYNAMIC STOCK MANAGEMENT SYSTEM';
PRINT '======================================================';
PRINT '';

-- ================================================================================
-- 1. GET READY PRODUCTS (Completed, Ready, Undelivered)
-- ================================================================================
PRINT 'Creating sp_GetReadyProducts...';
GO

DROP PROCEDURE IF EXISTS sp_GetReadyProducts;
GO

CREATE PROCEDURE sp_GetReadyProducts
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        po.ProductionOrderID as StockID,
        po.ProductID,
        'BATCH-' + CAST(po.ProductionOrderID AS NVARCHAR(10)) as BatchNo,
        p.ProductName as Product,
        CASE 
            WHEN so.SalesOrderID IS NOT NULL THEN 'Sales Order'
            WHEN d.DealID IS NOT NULL THEN 'Deal'
            ELSE 'Production'
        END as OrderType,
        po.QuantityCompleted as Quantity,
        po.ActualEndDate as DateAdded,
        100 as ProgressPercentage,
        -- Customer Information
        ISNULL(r.CompanyName, d.ClientName) as CustomerName,
        ISNULL(r.ContactPerson, d.ContactPerson) as ContactPerson,
        ISNULL(r.Phone, d.Phone) as Phone,
        -- Order Information
        ISNULL(so.SalesOrderID, d.DealID) as OrderID,
        po.Status as ProductionStatus,
        -- Delivery Status
        CASE 
            WHEN del.DeliveryID IS NULL THEN 'Not Delivered'
            ELSE del.Status
        END as DeliveryStatus,
        del.DeliveryID
    FROM ProductionOrder po
    INNER JOIN Product p ON po.ProductID = p.ProductID
    LEFT JOIN SalesOrder so ON EXISTS (
        SELECT 1 FROM SalesOrderItem soi 
        WHERE soi.SalesOrderID = so.SalesOrderID 
        AND soi.ProductID = po.ProductID
    )
    LEFT JOIN Deal d ON EXISTS (
        SELECT 1 FROM DealItem di 
        WHERE di.DealID = d.DealID 
        AND di.ProductID = po.ProductID
    )
    LEFT JOIN Retailer r ON so.RetailerID = r.RetailerID
    LEFT JOIN Delivery del ON (del.SalesOrderID = so.SalesOrderID OR del.DealID = d.DealID)
        AND (del.Status = 'Pending' OR del.Status = 'In Transit')
    WHERE po.Status = 'Completed'
        AND po.QuantityCompleted > 0
        AND (del.DeliveryID IS NULL OR del.Status IN ('Pending', 'In Transit'))
    ORDER BY po.ActualEndDate DESC;
END
GO

PRINT '✅ sp_GetReadyProducts created';
GO

-- ================================================================================
-- 2. GET IN PROCESS PRODUCTS (Production in Progress)
-- ================================================================================
PRINT 'Creating sp_GetInProcessProducts...';
GO

DROP PROCEDURE IF EXISTS sp_GetInProcessProducts;
GO

CREATE PROCEDURE sp_GetInProcessProducts
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        po.ProductionOrderID as StockID,
        po.ProductID,
        'BATCH-' + CAST(po.ProductionOrderID AS NVARCHAR(10)) as BatchNo,
        p.ProductName as Product,
        CASE 
            WHEN so.SalesOrderID IS NOT NULL THEN 'Sales Order'
            WHEN d.DealID IS NOT NULL THEN 'Deal'
            ELSE 'Production'
        END as OrderType,
        po.QuantityOrdered as TotalQuantity,
        po.QuantityCompleted as CompletedQuantity,
        (po.QuantityOrdered - po.QuantityCompleted) as RemainingQuantity,
        po.StartDate as DateAdded,
        po.ExpectedEndDate,
        -- Calculate progress percentage
        CASE 
            WHEN po.QuantityOrdered > 0 
            THEN CAST((po.QuantityCompleted * 100.0 / po.QuantityOrdered) AS INT)
            ELSE 0
        END as ProgressPercentage,
        -- Customer Information
        ISNULL(r.CompanyName, d.ClientName) as CustomerName,
        ISNULL(r.ContactPerson, d.ContactPerson) as ContactPerson,
        ISNULL(r.Phone, d.Phone) as Phone,
        -- Order Information
        ISNULL(so.SalesOrderID, d.DealID) as OrderID,
        po.Status as ProductionStatus,
        po.Priority,
        -- Days in production
        DATEDIFF(DAY, po.StartDate, GETDATE()) as DaysInProduction,
        DATEDIFF(DAY, GETDATE(), po.ExpectedEndDate) as DaysUntilDeadline
    FROM ProductionOrder po
    INNER JOIN Product p ON po.ProductID = p.ProductID
    LEFT JOIN SalesOrder so ON EXISTS (
        SELECT 1 FROM SalesOrderItem soi 
        WHERE soi.SalesOrderID = so.SalesOrderID 
        AND soi.ProductID = po.ProductID
    )
    LEFT JOIN Deal d ON EXISTS (
        SELECT 1 FROM DealItem di 
        WHERE di.DealID = d.DealID 
        AND di.ProductID = po.ProductID
    )
    LEFT JOIN Retailer r ON so.RetailerID = r.RetailerID
    WHERE po.Status IN ('Pending', 'InProgress')
        OR (po.Status = 'Completed' AND po.QuantityCompleted < po.QuantityOrdered)
    ORDER BY po.Priority DESC, po.StartDate ASC;
END
GO

PRINT '✅ sp_GetInProcessProducts created';
GO

-- ================================================================================
-- 3. GET SHIPPED PRODUCTS (Delivered Items)
-- ================================================================================
PRINT 'Creating sp_GetShippedProducts...';
GO

DROP PROCEDURE IF EXISTS sp_GetShippedProducts;
GO

CREATE PROCEDURE sp_GetShippedProducts
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        del.DeliveryID as StockID,
        po.ProductID,
        'BATCH-' + CAST(po.ProductionOrderID AS NVARCHAR(10)) as BatchNo,
        p.ProductName as Product,
        CASE 
            WHEN del.SalesOrderID IS NOT NULL THEN 'Sales Order'
            WHEN del.DealID IS NOT NULL THEN 'Deal'
            ELSE 'Direct'
        END as OrderType,
        po.QuantityCompleted as Quantity,
        del.DeliveryDate as DateShipped,
        del.DeliveryAddress,
        del.City,
        del.Province,
        -- Customer Information
        del.ReceiverName as CustomerName,
        del.ReceiverPhone as Phone,
        ISNULL(r.CompanyName, d.ClientName) as CompanyName,
        -- Delivery Information
        del.Status as DeliveryStatus,
        del.DeliveredBy,
        CONCAT(e.FirstName, ' ', e.LastName) as DeliveredByName,
        del.Notes as DeliveryNotes,
        -- Dates
        po.ActualEndDate as CompletedDate,
        del.CreatedDate as DeliveryCreatedDate
    FROM Delivery del
    LEFT JOIN SalesOrder so ON del.SalesOrderID = so.SalesOrderID
    LEFT JOIN Deal d ON del.DealID = d.DealID
    LEFT JOIN Retailer r ON so.RetailerID = r.RetailerID
    LEFT JOIN Employee e ON del.DeliveredBy = e.EmployeeID
    LEFT JOIN ProductionOrder po ON (
        EXISTS (SELECT 1 FROM SalesOrderItem soi 
                WHERE soi.SalesOrderID = del.SalesOrderID 
                AND soi.ProductID = po.ProductID)
        OR EXISTS (SELECT 1 FROM DealItem di 
                   WHERE di.DealID = del.DealID 
                   AND di.ProductID = po.ProductID)
    ) AND po.Status = 'Completed'
    LEFT JOIN Product p ON po.ProductID = p.ProductID
    WHERE del.Status = 'Delivered'
    ORDER BY del.DeliveryDate DESC;
END
GO

PRINT '✅ sp_GetShippedProducts created';
GO

-- ================================================================================
-- 4. GET STOCK STATISTICS
-- ================================================================================
PRINT 'Creating sp_GetStockStatistics...';
GO

DROP PROCEDURE IF EXISTS sp_GetStockStatistics;
GO

CREATE PROCEDURE sp_GetStockStatistics
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        -- Ready Products (Completed, not delivered)
        (SELECT COUNT(*) 
         FROM ProductionOrder po
         LEFT JOIN Delivery del ON EXISTS (
             SELECT 1 FROM SalesOrderItem soi 
             WHERE soi.ProductID = po.ProductID 
             AND del.SalesOrderID = soi.SalesOrderID
         ) OR EXISTS (
             SELECT 1 FROM DealItem di 
             WHERE di.ProductID = po.ProductID 
             AND del.DealID = di.DealID
         )
         WHERE po.Status = 'Completed' 
         AND po.QuantityCompleted > 0
         AND (del.DeliveryID IS NULL OR del.Status != 'Delivered')
        ) as ReadyCount,
        
        (SELECT ISNULL(SUM(po.QuantityCompleted), 0)
         FROM ProductionOrder po
         LEFT JOIN Delivery del ON EXISTS (
             SELECT 1 FROM SalesOrderItem soi 
             WHERE soi.ProductID = po.ProductID 
             AND del.SalesOrderID = soi.SalesOrderID
         ) OR EXISTS (
             SELECT 1 FROM DealItem di 
             WHERE di.ProductID = po.ProductID 
             AND del.DealID = di.DealID
         )
         WHERE po.Status = 'Completed' 
         AND po.QuantityCompleted > 0
         AND (del.DeliveryID IS NULL OR del.Status != 'Delivered')
        ) as ReadyQuantity,
        
        -- In Process (Production ongoing)
        (SELECT COUNT(*) 
         FROM ProductionOrder 
         WHERE Status IN ('Pending', 'InProgress')
        ) as InProcessCount,
        
        (SELECT ISNULL(SUM(QuantityOrdered - QuantityCompleted), 0)
         FROM ProductionOrder 
         WHERE Status IN ('Pending', 'InProgress')
        ) as InProcessQuantity,
        
        -- Shipped (Delivered)
        (SELECT COUNT(*) 
         FROM Delivery 
         WHERE Status = 'Delivered'
        ) as ShippedCount,
        
        (SELECT ISNULL(SUM(po.QuantityCompleted), 0)
         FROM Delivery del
         INNER JOIN ProductionOrder po ON EXISTS (
             SELECT 1 FROM SalesOrderItem soi 
             WHERE soi.ProductID = po.ProductID 
             AND del.SalesOrderID = soi.SalesOrderID
         ) OR EXISTS (
             SELECT 1 FROM DealItem di 
             WHERE di.ProductID = po.ProductID 
             AND del.DealID = di.DealID
         )
         WHERE del.Status = 'Delivered' 
         AND po.Status = 'Completed'
        ) as ShippedQuantity,
        
        -- Total
        (SELECT COUNT(*) FROM ProductionOrder) as TotalOrders;
END
GO

PRINT '✅ sp_GetStockStatistics created';
GO

-- ================================================================================
-- VERIFICATION
-- ================================================================================
PRINT '';
PRINT '======================================================';
PRINT 'TESTING PROCEDURES';
PRINT '======================================================';
PRINT '';

PRINT 'Test 1: Get Ready Products...';
EXEC sp_GetReadyProducts;
PRINT '';

PRINT 'Test 2: Get In Process Products...';
EXEC sp_GetInProcessProducts;
PRINT '';

PRINT 'Test 3: Get Shipped Products...';
EXEC sp_GetShippedProducts;
PRINT '';

PRINT 'Test 4: Get Stock Statistics...';
EXEC sp_GetStockStatistics;
PRINT '';

PRINT '======================================================';
PRINT '✅ DYNAMIC STOCK MANAGEMENT SYSTEM CREATED!';
PRINT '======================================================';
PRINT '';
PRINT 'Flow:';
PRINT '1. Approved Orders → Production Orders created';
PRINT '2. Completed Production → Shows in Ready Products';
PRINT '3. During Production → Shows in In Process';
PRINT '4. After Delivery → Shows in Shipped';
PRINT '';
GO
