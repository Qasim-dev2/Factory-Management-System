-- Fix TailorAssignment table to properly show products and allow production order tracking
-- This script:
-- 1. Removes the restrictive CHECK constraint
-- 2. Updates existing assignments with ProductID
-- 3. Creates ProductionOrders for existing assignments
-- 4. Links assignments to production orders

USE GarmentsFactoryDB;
GO

-- 1. Drop the CHECK constraint that prevents tracking both production orders and source orders
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.CHECK_CONSTRAINTS WHERE CONSTRAINT_NAME = 'CHK_TailorAssignment_OneOrder')
BEGIN
    ALTER TABLE TailorAssignment DROP CONSTRAINT CHK_TailorAssignment_OneOrder;
    PRINT 'Dropped CHECK constraint CHK_TailorAssignment_OneOrder';
END
GO

-- 2. Update existing TailorAssignments to have ProductID from their source orders
-- For assignments linked to Deals
UPDATE ta 
SET ta.ProductID = di.ProductID
FROM TailorAssignment ta
JOIN DealItem di ON ta.DealID = di.DealID
WHERE ta.DealID IS NOT NULL AND ta.ProductID IS NULL;

-- For assignments linked to Sales Orders
UPDATE ta 
SET ta.ProductID = soi.ProductID
FROM TailorAssignment ta
JOIN SalesOrderItem soi ON ta.SalesOrderID = soi.SalesOrderID
WHERE ta.SalesOrderID IS NOT NULL AND ta.ProductID IS NULL;

PRINT 'Updated TailorAssignments with ProductID from source orders';
GO

-- 3. Create ProductionOrders for existing TailorAssignments that don't have one
DECLARE @AssignmentID INT;
DECLARE @ProductID INT;
DECLARE @QuantityAssigned INT;
DECLARE @NewProductionOrderID INT;

DECLARE assignment_cursor CURSOR FOR
SELECT AssignmentID, ProductID, QuantityAssigned
FROM TailorAssignment
WHERE ProductionOrderID IS NULL AND ProductID IS NOT NULL;

OPEN assignment_cursor;
FETCH NEXT FROM assignment_cursor INTO @AssignmentID, @ProductID, @QuantityAssigned;

WHILE @@FETCH_STATUS = 0
BEGIN
    -- Create ProductionOrder
    INSERT INTO ProductionOrder (ProductID, QuantityOrdered, Status, Priority, CreatedDate, StartDate)
    VALUES (@ProductID, @QuantityAssigned, 'Pending', 'Normal', GETDATE(), GETDATE());
    
    SET @NewProductionOrderID = SCOPE_IDENTITY();
    
    -- Link TailorAssignment to ProductionOrder
    UPDATE TailorAssignment
    SET ProductionOrderID = @NewProductionOrderID
    WHERE AssignmentID = @AssignmentID;
    
    PRINT 'Created ProductionOrder ' + CAST(@NewProductionOrderID AS NVARCHAR) + ' for Assignment ' + CAST(@AssignmentID AS NVARCHAR);
    
    FETCH NEXT FROM assignment_cursor INTO @AssignmentID, @ProductID, @QuantityAssigned;
END

CLOSE assignment_cursor;
DEALLOCATE assignment_cursor;
GO

-- 4. Verify the changes
SELECT 
    ta.AssignmentID,
    ta.TailorID,
    ta.ProductionOrderID,
    ta.ProductID,
    p.ProductName,
    ta.QuantityAssigned,
    ta.Status,
    po.Status AS ProductionStatus
FROM TailorAssignment ta
LEFT JOIN Product p ON ta.ProductID = p.ProductID
LEFT JOIN ProductionOrder po ON ta.ProductionOrderID = po.ProductionOrderID
ORDER BY ta.AssignmentID;
GO

PRINT 'TailorAssignment fix completed successfully!';
