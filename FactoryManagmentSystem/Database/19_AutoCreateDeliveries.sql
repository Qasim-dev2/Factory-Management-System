-- ================================================================================
-- AUTO-CREATE DELIVERIES FOR COMPLETED ORDERS
-- ================================================================================
-- This procedure automatically creates deliveries for orders where:
-- 1. All production orders are completed
-- 2. Order status is 'ReadyForDelivery'
-- 3. No delivery exists yet
-- ================================================================================

USE GarmentsFactoryDB;
GO

-- Drop if exists
IF OBJECT_ID('sp_AutoCreateDeliveriesForCompletedOrders', 'P') IS NOT NULL
    DROP PROCEDURE sp_AutoCreateDeliveriesForCompletedOrders;
GO

CREATE PROCEDURE sp_AutoCreateDeliveriesForCompletedOrders
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @CreatedCount INT = 0;
    
    BEGIN TRY
        -- Create deliveries for SalesOrders that are ReadyForDelivery
        INSERT INTO Delivery (
            SalesOrderID,
            DealID,
            DeliveryAddress,
            City,
            Province,
            Status,
            ReceiverName,
            ReceiverPhone,
            CreatedDate
        )
        SELECT 
            so.SalesOrderID,
            NULL,
            so.ShippingAddress,
            ret.City,
            ret.Province,
            'Pending',
            ret.ContactPerson,
            ret.Phone,
            GETDATE()
        FROM SalesOrder so
        JOIN Retailer ret ON so.RetailerID = ret.RetailerID
        WHERE so.Status = 'ReadyForDelivery'
        AND NOT EXISTS (SELECT 1 FROM Delivery WHERE SalesOrderID = so.SalesOrderID);
        
        SET @CreatedCount = @CreatedCount + @@ROWCOUNT;
        
        -- Create deliveries for Deals that are ReadyForDelivery
        INSERT INTO Delivery (
            SalesOrderID,
            DealID,
            DeliveryAddress,
            City,
            Province,
            Status,
            ReceiverName,
            ReceiverPhone,
            CreatedDate
        )
        SELECT 
            NULL,
            d.DealID,
            ISNULL(d.DeliveryAddress, 'Not specified'),
            ISNULL(d.City, 'Not specified'),
            ISNULL(d.Province, 'Not specified'),
            'Pending',
            d.ContactPerson,
            d.Phone,
            GETDATE()
        FROM Deal d
        WHERE d.Status = 'ReadyForDelivery'
        AND NOT EXISTS (SELECT 1 FROM Delivery WHERE DealID = d.DealID);
        
        SET @CreatedCount = @CreatedCount + @@ROWCOUNT;
        
        SELECT 'Success' AS Result, 
               @CreatedCount AS DeliveriesCreated,
               'Deliveries created automatically' AS Message;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        SELECT 'Error' AS Result, 
               0 AS DeliveriesCreated,
               @ErrorMessage AS Message;
    END CATCH
END
GO

PRINT '✅ Procedure Created: sp_AutoCreateDeliveriesForCompletedOrders';
GO

-- Test it
EXEC sp_AutoCreateDeliveriesForCompletedOrders;
GO
