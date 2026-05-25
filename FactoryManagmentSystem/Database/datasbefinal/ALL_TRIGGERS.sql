-- =============================================
-- FACTORY MANAGEMENT SYSTEM - ALL TRIGGERS
-- Database: GarmentsFactoryDB
-- Total: 2 Triggers
-- =============================================

USE GarmentsFactoryDB;
GO

-- =============================================
-- TRIGGER 1: AUTO-CREATE DELIVERY ON SALES ORDER APPROVAL
-- Table: SalesOrder
-- Event: AFTER UPDATE
-- Purpose: Auto-creates delivery when order is approved
-- =============================================

IF OBJECT_ID('trg_CreateDeliveryOnSalesOrder', 'TR') IS NOT NULL
    DROP TRIGGER trg_CreateDeliveryOnSalesOrder;
GO

CREATE TRIGGER trg_CreateDeliveryOnSalesOrder
ON SalesOrder
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF UPDATE(Status)
    BEGIN
        INSERT INTO Delivery (SalesOrderID, DealID, DeliveryAddress, City, Province, ScheduledDate, Status, CreatedDate)
        SELECT 
            i.SalesOrderID,
            NULL,
            i.ShippingAddress,
            NULL,
            NULL,
            DATEADD(DAY, 7, GETDATE()),  -- Schedule 7 days from approval
            'Pending',
            GETDATE()
        FROM inserted i
        LEFT JOIN deleted d ON i.SalesOrderID = d.SalesOrderID
        WHERE i.Status = 'Approved'
          AND (d.Status IS NULL OR d.Status != 'Approved')
          AND NOT EXISTS (SELECT 1 FROM Delivery WHERE SalesOrderID = i.SalesOrderID);
    END
END
GO

PRINT '✓ trg_CreateDeliveryOnSalesOrder created';
GO

-- =============================================
-- TRIGGER 2: UPDATE DELIVERY STATUS ON ORDER STATUS CHANGE
-- Table: SalesOrder
-- Event: AFTER UPDATE
-- Purpose: Syncs delivery status when order status changes
-- =============================================

IF OBJECT_ID('trg_UpdateDeliveryOnSalesOrderStatusChange', 'TR') IS NOT NULL
    DROP TRIGGER trg_UpdateDeliveryOnSalesOrderStatusChange;
GO

CREATE TRIGGER trg_UpdateDeliveryOnSalesOrderStatusChange
ON SalesOrder
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF UPDATE(Status)
    BEGIN
        UPDATE d
        SET 
            d.Status = CASE 
                WHEN i.Status = 'Completed' THEN 'Ready for Delivery'
                WHEN i.Status = 'Cancelled' THEN 'Cancelled'
                WHEN i.Status = 'Rejected' THEN 'Cancelled'
                ELSE d.Status
            END,
            d.UpdatedDate = GETDATE()
        FROM Delivery d
        INNER JOIN inserted i ON d.SalesOrderID = i.SalesOrderID
        INNER JOIN deleted del ON i.SalesOrderID = del.SalesOrderID
        WHERE i.Status != del.Status
          AND i.Status IN ('Completed', 'Cancelled', 'Rejected')
          AND d.Status != 'Delivered';
    END
END
GO

PRINT '✓ trg_UpdateDeliveryOnSalesOrderStatusChange created';
GO

-- =============================================
-- TRIGGER MANAGEMENT COMMANDS
-- =============================================

/*
-- Disable triggers temporarily:
DISABLE TRIGGER trg_CreateDeliveryOnSalesOrder ON SalesOrder;
DISABLE TRIGGER trg_UpdateDeliveryOnSalesOrderStatusChange ON SalesOrder;

-- Re-enable triggers:
ENABLE TRIGGER trg_CreateDeliveryOnSalesOrder ON SalesOrder;
ENABLE TRIGGER trg_UpdateDeliveryOnSalesOrderStatusChange ON SalesOrder;

-- View all triggers:
SELECT name, is_disabled FROM sys.triggers WHERE parent_id = OBJECT_ID('SalesOrder');
*/

PRINT '';
PRINT '========================================';
PRINT 'ALL TRIGGERS CREATED SUCCESSFULLY';
PRINT 'Total: 2 Triggers';
PRINT '========================================';
GO
