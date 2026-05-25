-- =============================================
-- TRIGGERS & AUTOMATION
-- Database triggers for automatic operations
-- Generated: December 17, 2025
-- =============================================

USE GarmentsFactoryDB;
GO

/*
TRIGGERS CURRENTLY IMPLEMENTED:

NOTE: This system primarily uses stored procedures for business logic
rather than triggers to maintain explicit control flow.

POTENTIAL TRIGGERS FOR FUTURE IMPLEMENTATION:

1. TRIGGER: trg_UpdateSalesOrderTotal
   Table: SalesOrderItem
   Action: AFTER INSERT, UPDATE, DELETE
   Purpose: Auto-calculate SalesOrder.TotalAmount
   
2. TRIGGER: trg_UpdateDealTotal
   Table: DealItem
   Action: AFTER INSERT, UPDATE, DELETE
   Purpose: Auto-calculate Deal.TotalAmount
   
3. TRIGGER: trg_LogEmployeeChanges
   Table: Employee
   Action: AFTER UPDATE
   Purpose: Audit employee record changes
   
4. TRIGGER: trg_PreventDeleteActiveOrder
   Table: SalesOrder, Deal
   Action: INSTEAD OF DELETE
   Purpose: Prevent deletion of orders in progress
   
5. TRIGGER: trg_AutoCreateDelivery
   Table: ProductionOrder
   Action: AFTER UPDATE
   Purpose: Auto-create delivery when production completes
   Condition: Status changes to 'Completed'
   
6. TRIGGER: trg_UpdateStockOnProduction
   Table: TailorAssignment
   Action: AFTER UPDATE
   Purpose: Update stock when production completes
   Condition: Status changes to 'Complete'
   
7. TRIGGER: trg_CheckMaterialAvailability
   Table: ProductionOrder
   Action: INSTEAD OF INSERT
   Purpose: Verify raw materials before production
   
8. TRIGGER: trg_UpdateMonthlyRevenue
   Table: SalesOrder, Deal
   Action: AFTER UPDATE
   Purpose: Auto-update revenue when order delivered
   Condition: Status = 'Delivered'

WHY STORED PROCEDURES OVER TRIGGERS:

✓ Explicit control: Business logic is visible and testable
✓ Better debugging: Easier to trace execution
✓ Transaction management: Full control over commits/rollbacks
✓ Error handling: Clear error messages to frontend
✓ Performance: Can optimize specific operations
✓ Security: Can grant execute permissions granularly

CURRENT AUTOMATION APPROACH:
- Frontend calls specific stored procedures
- Procedures handle multi-step operations atomically
- Clear success/failure responses
- No hidden trigger side-effects
*/

-- EXAMPLE: Auto-update SalesOrder total when items change
/*
CREATE OR ALTER TRIGGER trg_UpdateSalesOrderTotal
ON SalesOrderItem
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE so
    SET so.TotalAmount = (
        SELECT ISNULL(SUM(Quantity * UnitPrice), 0)
        FROM SalesOrderItem
        WHERE SalesOrderID = so.SalesOrderID
    ),
    so.UpdatedDate = GETDATE()
    FROM SalesOrder so
    WHERE so.SalesOrderID IN (
        SELECT DISTINCT SalesOrderID FROM inserted
        UNION
        SELECT DISTINCT SalesOrderID FROM deleted
    );
END
GO
*/

-- EXAMPLE: Prevent deletion of active orders
/*
CREATE OR ALTER TRIGGER trg_PreventDeleteActiveOrder
ON SalesOrder
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    IF EXISTS (SELECT 1 FROM deleted WHERE Status IN ('InProgress', 'Approved'))
    BEGIN
        RAISERROR('Cannot delete orders that are in progress or approved', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
    
    DELETE FROM SalesOrder WHERE SalesOrderID IN (SELECT SalesOrderID FROM deleted);
END
GO
*/

PRINT '✓ Triggers documentation created';
PRINT '✓ Note: System uses stored procedures for primary automation';
GO
