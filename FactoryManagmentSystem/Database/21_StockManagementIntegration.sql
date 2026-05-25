-- ================================================================================
-- STOCK MANAGEMENT INTEGRATION - AUTOMATIC FLOW
-- ================================================================================
-- Created: December 8, 2025
-- Purpose: Integrate Stock Management with automatic order workflow
--
-- WORKFLOW:
-- 1. Order Approved → InProduction (Stock: "InProcess")
-- 2. All Tailors Complete → ReadyForDelivery (Stock: "Ready")  
-- 3. Delivery Created Automatically (Still "Ready")
-- 4. Delivery Status = "Delivered" → (Stock: "Shipped")
-- ================================================================================

USE GarmentsFactoryDB;
GO

PRINT '========================================';
PRINT 'STOCK MANAGEMENT INTEGRATION';
PRINT '========================================';
GO

-- ================================================================================
-- PROCEDURE 1: GET STOCK MANAGEMENT SUMMARY
-- ================================================================================
-- Returns counts and details for stock management dashboard
-- Categories: Total Entries, Ready Products, In Process, Shipped
-- ================================================================================

IF OBJECT_ID('sp_GetStockManagement', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetStockManagement;
GO

CREATE PROCEDURE sp_GetStockManagement
    @Status NVARCHAR(50) = NULL  -- NULL = Summary only, 'InProcess'/'Ready'/'Shipped' = Details
AS
BEGIN
    SET NOCOUNT ON;

    -- Return summary counts
    IF @Status IS NULL
    BEGIN
        SELECT 
            -- Total stock entries (all production orders ever created)
            (SELECT COUNT(DISTINCT po.ProductionOrderID) 
             FROM ProductionOrder po) AS TotalStockEntries,
            
            -- Ready products (completed but not shipped)
            (SELECT COUNT(DISTINCT po.ProductionOrderID)
             FROM ProductionOrder po
             INNER JOIN OrderApproval oa ON po.ProductionOrderID = oa.ProductionOrderID
             WHERE po.Status = 'Completed'
             AND NOT EXISTS (
                 SELECT 1 FROM Delivery d 
                 WHERE ((d.SalesOrderID = oa.OrderID AND oa.OrderType = 'SalesOrder') 
                     OR (d.DealID = oa.OrderID AND oa.OrderType = 'Deal'))
                 AND d.Status = 'Delivered'
             )) AS ReadyProducts,
            
            -- In process (production started but not completed)
            (SELECT COUNT(DISTINCT po.ProductionOrderID)
             FROM ProductionOrder po
             WHERE po.Status = 'InProgress') AS InProcess,
            
            -- Shipped (delivered)
            (SELECT COUNT(DISTINCT d.DeliveryID)
             FROM Delivery d
             WHERE d.Status = 'Delivered') AS Shipped;
    END
    
    -- Return detailed list based on status
    ELSE
    BEGIN
        IF @Status = 'InProcess'
        BEGIN
            -- Show production orders currently in progress
            SELECT 
                po.ProductionOrderID AS StockID,
                CAST(po.ProductionOrderID AS NVARCHAR) AS BatchNo,
                p.ProductName AS Product,
                po.QuantityOrdered AS InProcessQty,
                po.StartDate AS DateAdded,
                'InProcess' AS Status,
                oa.OrderType AS OrderType,
                CASE 
                    WHEN oa.OrderType = 'SalesOrder' THEN 
                        (SELECT r.CompanyName FROM Retailer r 
                         JOIN SalesOrder so ON r.RetailerID = so.RetailerID 
                         WHERE so.SalesOrderID = oa.OrderID)
                    WHEN oa.OrderType = 'Deal' THEN 
                        (SELECT ClientName FROM Deal d WHERE d.DealID = oa.OrderID)
                END AS CustomerName
            FROM ProductionOrder po
            INNER JOIN OrderApproval oa ON po.ProductionOrderID = oa.ProductionOrderID
            INNER JOIN Product p ON po.ProductID = p.ProductID
            WHERE po.Status = 'InProgress'
            ORDER BY po.StartDate DESC;
        END
        
        ELSE IF @Status = 'Ready'
        BEGIN
            -- Show completed production ready for delivery
            SELECT 
                po.ProductionOrderID AS StockID,
                CAST(po.ProductionOrderID AS NVARCHAR) AS BatchNo,
                p.ProductName AS Product,
                po.QuantityCompleted AS ReadyQty,
                po.ActualEndDate AS DateAdded,
                'Ready' AS Status,
                oa.OrderType AS OrderType,
                CASE 
                    WHEN oa.OrderType = 'SalesOrder' THEN 
                        (SELECT r.CompanyName FROM Retailer r 
                         JOIN SalesOrder so ON r.RetailerID = so.RetailerID 
                         WHERE so.SalesOrderID = oa.OrderID)
                    WHEN oa.OrderType = 'Deal' THEN 
                        (SELECT ClientName FROM Deal d WHERE d.DealID = oa.OrderID)
                END AS CustomerName
            FROM ProductionOrder po
            INNER JOIN OrderApproval oa ON po.ProductionOrderID = oa.ProductionOrderID
            INNER JOIN Product p ON po.ProductID = p.ProductID
            WHERE po.Status = 'Completed'
            AND NOT EXISTS (
                SELECT 1 FROM Delivery d 
                WHERE ((d.SalesOrderID = oa.OrderID AND oa.OrderType = 'SalesOrder') 
                    OR (d.DealID = oa.OrderID AND oa.OrderType = 'Deal'))
                AND d.Status = 'Delivered'
            )
            ORDER BY po.ActualEndDate DESC;
        END
        
        ELSE IF @Status = 'Shipped'
        BEGIN
            -- Show delivered products
            SELECT 
                d.DeliveryID AS StockID,
                CAST(oa.ProductionOrderID AS NVARCHAR) AS BatchNo,
                p.ProductName AS Product,
                po.QuantityCompleted AS ShippedQty,
                d.DeliveryDate AS DateAdded,
                'Shipped' AS Status,
                CASE 
                    WHEN d.SalesOrderID IS NOT NULL THEN 'SalesOrder'
                    WHEN d.DealID IS NOT NULL THEN 'Deal'
                END AS OrderType,
                CASE 
                    WHEN d.SalesOrderID IS NOT NULL THEN 
                        (SELECT r.CompanyName FROM Retailer r 
                         JOIN SalesOrder so ON r.RetailerID = so.RetailerID 
                         WHERE so.SalesOrderID = d.SalesOrderID)
                    WHEN d.DealID IS NOT NULL THEN 
                        (SELECT ClientName FROM Deal dd WHERE dd.DealID = d.DealID)
                END AS CustomerName
            FROM Delivery d
            INNER JOIN OrderApproval oa ON 
                ((d.SalesOrderID = oa.OrderID AND oa.OrderType = 'SalesOrder') 
                OR (d.DealID = oa.OrderID AND oa.OrderType = 'Deal'))
            INNER JOIN ProductionOrder po ON po.ProductionOrderID = oa.ProductionOrderID
            INNER JOIN Product p ON po.ProductID = p.ProductID
            WHERE d.Status = 'Delivered'
            ORDER BY d.DeliveryDate DESC;
        END
    END
END
GO

PRINT '✅ sp_GetStockManagement created successfully';
GO

-- ================================================================================
-- PROCEDURE 2: UPDATE DELIVERY STATUS (ENHANCED)
-- ================================================================================
-- Now updates Stock status to 'Shipped' when delivery is marked as Delivered
-- ================================================================================

IF OBJECT_ID('sp_UpdateDeliveryStatus', 'P') IS NOT NULL
    DROP PROCEDURE sp_UpdateDeliveryStatus;
GO

CREATE PROCEDURE sp_UpdateDeliveryStatus
    @DeliveryID INT,
    @NewStatus NVARCHAR(50),
    @ActualDeliveryDate DATETIME = NULL,
    @DeliveryNotes NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Update delivery record
        UPDATE Delivery
        SET Status = @NewStatus,
            DeliveryDate = CASE 
                WHEN @NewStatus = 'Delivered' THEN COALESCE(@ActualDeliveryDate, GETDATE())
                ELSE DeliveryDate 
            END,
            Notes = COALESCE(@DeliveryNotes, Notes),
            UpdatedDate = GETDATE()
        WHERE DeliveryID = @DeliveryID;
        
        -- If status is "Delivered", update the order status
        IF @NewStatus = 'Delivered'
        BEGIN
            -- Update SalesOrder if exists
            UPDATE so
            SET so.Status = 'Delivered',
                so.UpdatedDate = GETDATE()
            FROM SalesOrder so
            INNER JOIN Delivery d ON so.SalesOrderID = d.SalesOrderID
            WHERE d.DeliveryID = @DeliveryID;
            
            -- Update Deal if exists
            UPDATE dl
            SET dl.Status = 'Delivered',
                dl.UpdatedDate = GETDATE()
            FROM Deal dl
            INNER JOIN Delivery d ON dl.DealID = d.DealID
            WHERE d.DeliveryID = @DeliveryID;
        END
        
        COMMIT TRANSACTION;
        
        SELECT 'Success' AS Result, 
               'Delivery status updated successfully' AS Message;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        SELECT 'Error' AS Result, 
               ERROR_MESSAGE() AS Message;
    END CATCH
END
GO

PRINT '✅ sp_UpdateDeliveryStatus updated successfully';
GO

-- ================================================================================
-- TEST THE PROCEDURES
-- ================================================================================

PRINT '';
PRINT '========================================';
PRINT 'TESTING STOCK MANAGEMENT INTEGRATION';
PRINT '========================================';
GO

-- Test 1: Get summary
PRINT 'Test 1: Get Stock Summary';
EXEC sp_GetStockManagement;
GO

-- Test 2: Get In Process items
PRINT '';
PRINT 'Test 2: Get In Process Stock';
EXEC sp_GetStockManagement @Status = 'InProcess';
GO

-- Test 3: Get Ready Products
PRINT '';
PRINT 'Test 3: Get Ready Products';
EXEC sp_GetStockManagement @Status = 'Ready';
GO

-- Test 4: Get Shipped Products
PRINT '';
PRINT 'Test 4: Get Shipped Products';
EXEC sp_GetStockManagement @Status = 'Shipped';
GO

PRINT '';
PRINT '✅ Stock Management Integration completed successfully';
PRINT '   Ready to integrate with UI';
GO
