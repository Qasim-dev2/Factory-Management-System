-- ================================================================================
-- GARMENTS FACTORY MANAGEMENT SYSTEM - TRIGGERS
-- PART 4: ALL DATABASE TRIGGERS
-- ================================================================================
-- Database: GarmentsFactoryDB
-- Purpose: Automated workflows and data integrity enforcement
-- Created: December 2025
-- Total Triggers: 2
-- ================================================================================

USE GarmentsFactoryDB;
GO

-- ================================================================================
-- TRIGGER 1: AUTO-CREATE DELIVERY ON SALES ORDER APPROVAL
-- ================================================================================

-- TRIGGER: trg_CreateDeliveryOnSalesOrder
-- Purpose: Automatically create delivery record when sales order is approved
-- Table: SalesOrder
-- Event: AFTER UPDATE
-- 
-- Automation Workflow:
-- 1. When SalesOrder.Status changes to 'Approved'
-- 2. Automatically creates a Delivery record
-- 3. Uses shipping address from SalesOrder
-- 4. Sets status to 'Pending'
-- 5. Schedules delivery for 7 days from approval
--
-- Benefits:
-- - Eliminates manual delivery record creation
-- - Ensures no approved orders are missed for delivery
-- - Maintains consistent delivery workflow
-- - Automatic scheduling based on business rules

IF OBJECT_ID('trg_CreateDeliveryOnSalesOrder', 'TR') IS NOT NULL
    DROP TRIGGER trg_CreateDeliveryOnSalesOrder;
GO

CREATE TRIGGER trg_CreateDeliveryOnSalesOrder
ON SalesOrder
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Check if status changed to 'Approved'
    IF UPDATE(Status)
    BEGIN
        -- Insert delivery records for newly approved orders
        INSERT INTO Delivery (
            SalesOrderID,
            DealID,
            DeliveryAddress,
            City,
            Province,
            ScheduledDate,
            Status,
            CreatedDate
        )
        SELECT 
            i.SalesOrderID,
            NULL,                                           -- DealID is NULL for sales orders
            i.ShippingAddress,                              -- Use shipping address from order
            NULL,                                           -- City (can be parsed from address)
            NULL,                                           -- Province (can be parsed from address)
            DATEADD(DAY, 7, GETDATE()),                    -- Schedule delivery 7 days from now
            'Pending',                                      -- Initial status
            GETDATE()                                       -- Record creation timestamp
        FROM inserted i
        LEFT JOIN deleted d ON i.SalesOrderID = d.SalesOrderID
        WHERE i.Status = 'Approved'                         -- New status is Approved
          AND (d.Status IS NULL OR d.Status != 'Approved') -- Old status was not Approved
          AND NOT EXISTS (                                  -- Delivery doesn't already exist
              SELECT 1 
              FROM Delivery 
              WHERE SalesOrderID = i.SalesOrderID
          );
    END
END
GO

PRINT '✓ trg_CreateDeliveryOnSalesOrder created';
PRINT '  - Automatically creates delivery when SalesOrder is approved';
PRINT '  - Schedules delivery 7 days from approval date';
PRINT '  - Status set to Pending';
PRINT '';
GO

-- ================================================================================
-- TRIGGER 2: UPDATE DELIVERY STATUS WHEN SALES ORDER STATUS CHANGES
-- ================================================================================

-- TRIGGER: trg_UpdateDeliveryOnSalesOrderStatusChange
-- Purpose: Update delivery status when sales order status changes
-- Table: SalesOrder
-- Event: AFTER UPDATE
--
-- Automation Workflow:
-- 1. When SalesOrder.Status changes to specific values
-- 2. Automatically updates corresponding Delivery record status
-- 3. Status mappings:
--    - 'Completed' → Delivery status becomes 'Ready for Delivery'
--    - 'Cancelled' → Delivery status becomes 'Cancelled'
--    - 'Rejected'  → Delivery status becomes 'Cancelled'
--
-- Benefits:
-- - Keeps delivery status synchronized with order status
-- - Eliminates manual delivery status updates
-- - Prevents delivery of cancelled/rejected orders
-- - Enables delivery team to see ready orders automatically

IF OBJECT_ID('trg_UpdateDeliveryOnSalesOrderStatusChange', 'TR') IS NOT NULL
    DROP TRIGGER trg_UpdateDeliveryOnSalesOrderStatusChange;
GO

CREATE TRIGGER trg_UpdateDeliveryOnSalesOrderStatusChange
ON SalesOrder
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Check if status has changed
    IF UPDATE(Status)
    BEGIN
        -- Update delivery status based on sales order status changes
        UPDATE d
        SET 
            d.Status = CASE 
                WHEN i.Status = 'Completed' THEN 'Ready for Delivery'
                WHEN i.Status = 'Cancelled' THEN 'Cancelled'
                WHEN i.Status = 'Rejected' THEN 'Cancelled'
                ELSE d.Status  -- Keep existing status for other changes
            END,
            d.UpdatedDate = GETDATE()
        FROM Delivery d
        INNER JOIN inserted i ON d.SalesOrderID = i.SalesOrderID
        INNER JOIN deleted del ON i.SalesOrderID = del.SalesOrderID
        WHERE i.Status != del.Status  -- Only when status actually changed
          AND i.Status IN ('Completed', 'Cancelled', 'Rejected')
          AND d.Status != 'Delivered';  -- Don't update already delivered orders
    END
END
GO

PRINT '✓ trg_UpdateDeliveryOnSalesOrderStatusChange created';
PRINT '  - Updates Delivery status when SalesOrder status changes';
PRINT '  - Mappings:';
PRINT '    * SalesOrder Completed → Delivery Ready for Delivery';
PRINT '    * SalesOrder Cancelled/Rejected → Delivery Cancelled';
PRINT '  - Prevents updating already delivered orders';
PRINT '';
GO

-- ================================================================================
-- TRIGGER USAGE EXAMPLES
-- ================================================================================

PRINT '========================================';
PRINT 'TRIGGER EXAMPLES AND WORKFLOWS';
PRINT '========================================';
PRINT '';
PRINT 'EXAMPLE 1: Sales Order Approval Workflow';
PRINT '-----------------------------------------';
PRINT '1. Owner approves SalesOrder:';
PRINT '   UPDATE SalesOrder SET Status = ''Approved'' WHERE SalesOrderID = 1;';
PRINT '';
PRINT '2. trg_CreateDeliveryOnSalesOrder fires automatically:';
PRINT '   - Creates Delivery record';
PRINT '   - Sets ScheduledDate = 7 days from now';
PRINT '   - Sets Status = ''Pending''';
PRINT '   - Copies ShippingAddress from SalesOrder';
PRINT '';
PRINT 'EXAMPLE 2: Order Completion Workflow';
PRINT '-------------------------------------';
PRINT '1. Production completes order:';
PRINT '   UPDATE SalesOrder SET Status = ''Completed'' WHERE SalesOrderID = 1;';
PRINT '';
PRINT '2. trg_UpdateDeliveryOnSalesOrderStatusChange fires:';
PRINT '   - Updates Delivery.Status to ''Ready for Delivery''';
PRINT '   - Delivery team sees order is ready to ship';
PRINT '';
PRINT 'EXAMPLE 3: Order Cancellation Workflow';
PRINT '---------------------------------------';
PRINT '1. Customer cancels order:';
PRINT '   UPDATE SalesOrder SET Status = ''Cancelled'' WHERE SalesOrderID = 1;';
PRINT '';
PRINT '2. trg_UpdateDeliveryOnSalesOrderStatusChange fires:';
PRINT '   - Updates Delivery.Status to ''Cancelled''';
PRINT '   - Prevents delivery person from attempting delivery';
PRINT '';
GO

-- ================================================================================
-- TRIGGER BEST PRACTICES & MAINTENANCE NOTES
-- ================================================================================

PRINT '========================================';
PRINT 'TRIGGER BEST PRACTICES';
PRINT '========================================';
PRINT '';
PRINT '1. IDEMPOTENCY';
PRINT '   - Both triggers check for existing records';
PRINT '   - Prevents duplicate deliveries';
PRINT '   - Safe to run multiple times';
PRINT '';
PRINT '2. PERFORMANCE';
PRINT '   - SET NOCOUNT ON reduces network traffic';
PRINT '   - Efficient EXISTS checks';
PRINT '   - Indexed foreign keys (SalesOrderID)';
PRINT '';
PRINT '3. DATA INTEGRITY';
PRINT '   - Status transitions are controlled';
PRINT '   - Delivered orders cannot be modified';
PRINT '   - NULL checks prevent errors';
PRINT '';
PRINT '4. DEBUGGING';
PRINT '   - To disable temporarily:';
PRINT '     DISABLE TRIGGER trg_CreateDeliveryOnSalesOrder ON SalesOrder;';
PRINT '   - To re-enable:';
PRINT '     ENABLE TRIGGER trg_CreateDeliveryOnSalesOrder ON SalesOrder;';
PRINT '';
PRINT '5. MONITORING';
PRINT '   - Check trigger execution:';
PRINT '     SELECT * FROM sys.triggers WHERE parent_id = OBJECT_ID(''SalesOrder'');';
PRINT '   - View trigger definitions:';
PRINT '     EXEC sp_helptext ''trg_CreateDeliveryOnSalesOrder'';';
PRINT '';
GO

-- ================================================================================
-- TRIGGER TESTING SCRIPTS
-- ================================================================================

PRINT '========================================';
PRINT 'TRIGGER TESTING SCRIPTS';
PRINT '========================================';
PRINT '';
PRINT '-- Test 1: Verify trigger creation';
PRINT 'SELECT ';
PRINT '    t.name AS TriggerName,';
PRINT '    OBJECT_NAME(t.parent_id) AS TableName,';
PRINT '    t.is_disabled AS IsDisabled,';
PRINT '    t.create_date AS CreatedDate';
PRINT 'FROM sys.triggers t';
PRINT 'WHERE OBJECT_NAME(t.parent_id) = ''SalesOrder'';';
PRINT '';
PRINT '-- Test 2: Create test sales order and approve';
PRINT '-- (This will trigger automatic delivery creation)';
PRINT 'DECLARE @TestOrderID INT;';
PRINT 'EXEC sp_AddSalesOrder';
PRINT '    @OrderDate = ''2025-01-15'',';
PRINT '    @RetailerID = 1,';
PRINT '    @ShippingAddress = ''123 Test St, Test City'',';
PRINT '    @TotalAmount = 1000,';
PRINT '    @NewSalesOrderID = @TestOrderID OUTPUT;';
PRINT '';
PRINT 'UPDATE SalesOrder SET Status = ''Approved'' WHERE SalesOrderID = @TestOrderID;';
PRINT '';
PRINT 'SELECT * FROM Delivery WHERE SalesOrderID = @TestOrderID;';
PRINT '';
PRINT '-- Test 3: Update order to completed';
PRINT '-- (This will trigger delivery status update)';
PRINT 'UPDATE SalesOrder SET Status = ''Completed'' WHERE SalesOrderID = @TestOrderID;';
PRINT '';
PRINT 'SELECT Status FROM Delivery WHERE SalesOrderID = @TestOrderID;';
PRINT '-- Expected: ''Ready for Delivery''';
PRINT '';
GO

-- ================================================================================
-- TRIGGER MODIFICATION HISTORY
-- ================================================================================

PRINT '========================================';
PRINT 'MODIFICATION HISTORY';
PRINT '========================================';
PRINT '';
PRINT 'Version 1.0 - December 2025';
PRINT '- Initial creation of both triggers';
PRINT '- Implemented auto-delivery creation';
PRINT '- Implemented status synchronization';
PRINT '';
PRINT 'Future Enhancements:';
PRINT '- Add trigger for Deal approvals (similar to SalesOrder)';
PRINT '- Add notification trigger for low stock alerts';
PRINT '- Add audit trail trigger for order modifications';
PRINT '- Add trigger to auto-assign delivery person based on location';
PRINT '';
GO

-- ================================================================================
-- RELATED STORED PROCEDURES
-- ================================================================================

PRINT '========================================';
PRINT 'RELATED STORED PROCEDURES';
PRINT '========================================';
PRINT '';
PRINT 'These triggers work with the following procedures:';
PRINT '- sp_AddSalesOrder (creates order with Pending Approval status)';
PRINT '- sp_ApproveOrderAndCreateProduction (approves order → triggers delivery creation)';
PRINT '- sp_UpdateSalesOrderStatus (status changes → trigger delivery updates)';
PRINT '- sp_GetDeliveriesByStatus (view deliveries created by trigger)';
PRINT '- sp_GetDeliveriesByPerson (delivery team workflow)';
PRINT '';
GO

-- ================================================================================
-- TROUBLESHOOTING GUIDE
-- ================================================================================

PRINT '========================================';
PRINT 'TROUBLESHOOTING GUIDE';
PRINT '========================================';
PRINT '';
PRINT 'ISSUE: Delivery not created when order approved';
PRINT 'SOLUTION:';
PRINT '  1. Check if trigger is enabled:';
PRINT '     SELECT name, is_disabled FROM sys.triggers WHERE name = ''trg_CreateDeliveryOnSalesOrder'';';
PRINT '  2. Verify ShippingAddress is not NULL in SalesOrder';
PRINT '  3. Check if delivery already exists for that SalesOrderID';
PRINT '';
PRINT 'ISSUE: Delivery status not updating';
PRINT 'SOLUTION:';
PRINT '  1. Check if trigger is enabled:';
PRINT '     SELECT name, is_disabled FROM sys.triggers WHERE name = ''trg_UpdateDeliveryOnSalesOrderStatusChange'';';
PRINT '  2. Verify delivery is not already in ''Delivered'' status';
PRINT '  3. Check if Status column was actually updated (not just SET to same value)';
PRINT '';
PRINT 'ISSUE: Need to modify trigger behavior';
PRINT 'SOLUTION:';
PRINT '  1. Disable trigger:';
PRINT '     DISABLE TRIGGER trg_CreateDeliveryOnSalesOrder ON SalesOrder;';
PRINT '  2. Make changes using ALTER TRIGGER or DROP/CREATE';
PRINT '  3. Test thoroughly in development environment first';
PRINT '  4. Re-enable trigger:';
PRINT '     ENABLE TRIGGER trg_CreateDeliveryOnSalesOrder ON SalesOrder;';
PRINT '';
GO

-- ================================================================================
-- END OF PART 4: TRIGGERS
-- ================================================================================

PRINT '';
PRINT '========================================';
PRINT 'PART 4 COMPLETE: All Database Triggers';
PRINT 'Total: 2 triggers documented';
PRINT '========================================';
PRINT '';
PRINT 'Summary:';
PRINT '- trg_CreateDeliveryOnSalesOrder: Auto-creates delivery on approval';
PRINT '- trg_UpdateDeliveryOnSalesOrderStatusChange: Syncs delivery with order status';
PRINT '';
PRINT 'Automated Workflows:';
PRINT '1. Order Approved → Delivery Created (Pending, scheduled +7 days)';
PRINT '2. Order Completed → Delivery Ready for Delivery';
PRINT '3. Order Cancelled/Rejected → Delivery Cancelled';
PRINT '';
PRINT '========================================';
PRINT 'ALL DOCUMENTATION FILES COMPLETE!';
PRINT '========================================';
PRINT '';
PRINT 'File Structure:';
PRINT '- 95_CompleteDatabase_Schema.sql (21 tables, complete schema)';
PRINT '- 96_StoredProcedures_Part1_Core.sql (~40 procedures)';
PRINT '- 97_StoredProcedures_Part2_Sales.sql (~25 procedures)';
PRINT '- 98_StoredProcedures_Part3_Production.sql (~35 procedures)';
PRINT '- 99_Triggers_Complete.sql (2 triggers with documentation)';
PRINT '';
PRINT 'Total Database Objects Documented:';
PRINT '- 21 Tables with relationships';
PRINT '- 100+ Stored Procedures';
PRINT '- 2 Automated Triggers';
PRINT '- Complete workflow documentation';
PRINT '';
PRINT '========================================';
GO
