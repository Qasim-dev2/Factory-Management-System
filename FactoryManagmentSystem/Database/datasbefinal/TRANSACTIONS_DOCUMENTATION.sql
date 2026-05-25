-- =============================================
-- TRANSACTION-BASED PROCEDURES
-- Procedures using BEGIN TRANSACTION/COMMIT/ROLLBACK
-- Generated: December 17, 2025
-- =============================================

USE GarmentsFactoryDB;
GO

/*
KEY PROCEDURES WITH TRANSACTION HANDLING:

1. sp_ApproveOrderAndCreateProduction
   - Approves order
   - Updates order status
   - Creates production orders
   - Rollback if any step fails

2. sp_AssignTailorsToProductionOrder
   - Finds available tailor
   - Creates assignment
   - Updates production status
   - Atomic operation

3. sp_CompleteProductionAndCreateDelivery
   - Completes tailor assignment
   - Updates production order
   - Creates delivery record
   - Ensures data consistency

4. sp_PayMonthlySalaries
   - Checks for duplicate payments
   - Calculates total salary
   - Updates revenue records
   - All-or-nothing payment

5. sp_AddRawMaterialPurchaseWithRestock
   - Records purchase
   - Updates stock quantity
   - Atomic inventory update

6. sp_AddSalesOrderWithItems (if exists)
   - Creates sales order
   - Adds multiple items
   - Calculates totals
   - Rollback on failure

7. sp_DeleteSalesOrder (Cascade)
   - Deletes order items
   - Deletes delivery records
   - Deletes approval records
   - Ensures referential integrity

TRANSACTION PATTERN USED:
```
BEGIN TRANSACTION;
BEGIN TRY
    -- Operations
    COMMIT TRANSACTION;
    SELECT 'SUCCESS';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    SELECT 'ERROR', ERROR_MESSAGE();
END CATCH
```

ISOLATION LEVELS:
- Default: READ COMMITTED
- Financial operations: SERIALIZABLE (for critical money transactions)
- Reporting queries: READ UNCOMMITTED (for performance)
