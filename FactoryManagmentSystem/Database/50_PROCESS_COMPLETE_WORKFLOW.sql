-- =============================================
-- COMPLETE SAMPLE DATA WORKFLOW PROCESSING
-- This script processes all sample orders through:
--   1. Create OrderApproval records
--   2. Approve orders & create production orders
--   3. Assign tailors to production
--   4. Complete tailor work
--   5. Create and complete deliveries
--   6. Update revenue and statistics
-- Date: December 17, 2025
-- =============================================

USE GarmentsFactoryDB;
GO

SET NOCOUNT ON;
SET QUOTED_IDENTIFIER ON;

PRINT '========================================';
PRINT 'PROCESSING COMPLETE WORKFLOW FOR SAMPLE DATA';
PRINT '========================================';
PRINT '';

-- =============================================
-- STEP 1: Create OrderApproval records for new orders
-- =============================================
PRINT '1. Creating OrderApproval records...';

-- For Sales Orders 15-22 (Status = Pending)
INSERT INTO OrderApproval (OrderType, OrderID, SalesOrderID, Status, RequestedByEmployeeID, RequestDate, CreatedDate)
SELECT 
    'SalesOrder',
    so.SalesOrderID,
    so.SalesOrderID,
    'Pending',
    so.SalesRepID,
    so.OrderDate,
    GETDATE()
FROM SalesOrder so
WHERE so.SalesOrderID BETWEEN 15 AND 22
AND NOT EXISTS (SELECT 1 FROM OrderApproval oa WHERE oa.SalesOrderID = so.SalesOrderID);

PRINT '   ✓ Created OrderApproval for Sales Orders 15-22';

-- For Deals 8-15 (Status = Pending)
INSERT INTO OrderApproval (OrderType, OrderID, DealID, Status, RequestedByEmployeeID, RequestDate, CreatedDate)
SELECT 
    'Deal',
    d.DealID,
    d.DealID,
    'Pending',
    d.CreatedBy,
    d.StartDate,
    GETDATE()
FROM Deal d
WHERE d.DealID BETWEEN 8 AND 15
AND NOT EXISTS (SELECT 1 FROM OrderApproval oa WHERE oa.DealID = d.DealID);

PRINT '   ✓ Created OrderApproval for Deals 8-15';
PRINT '';

-- =============================================
-- STEP 2: Approve orders and update statuses
-- =============================================
PRINT '2. Approving orders...';

-- Approve Sales Orders
UPDATE SalesOrder 
SET Status = 'Approved', UpdatedDate = GETDATE()
WHERE SalesOrderID BETWEEN 15 AND 22;

UPDATE OrderApproval
SET Status = 'Approved', ApprovedBy = 1, ApprovalDate = GETDATE(), ApprovalStatus = 'Approved'
WHERE SalesOrderID BETWEEN 15 AND 22;

PRINT '   ✓ Approved 8 Sales Orders';

-- Approve Deals
UPDATE Deal 
SET Status = 'Approved', UpdatedDate = GETDATE()
WHERE DealID BETWEEN 8 AND 15;

UPDATE OrderApproval
SET Status = 'Approved', ApprovedBy = 1, ApprovalDate = GETDATE(), ApprovalStatus = 'Approved'
WHERE DealID BETWEEN 8 AND 15;

PRINT '   ✓ Approved 8 Deals';
PRINT '';

-- =============================================
-- STEP 3: Create Production Orders
-- =============================================
PRINT '3. Creating Production Orders...';

-- Create production orders for Sales Order items
DECLARE @ProductID INT, @Qty INT, @SalesOrderID INT;
DECLARE @OrdersCursor CURSOR;

SET @OrdersCursor = CURSOR FOR
SELECT DISTINCT soi.ProductID, SUM(soi.Quantity) AS Qty, soi.SalesOrderID
FROM SalesOrderItem soi
WHERE soi.SalesOrderID BETWEEN 15 AND 22
GROUP BY soi.SalesOrderID, soi.ProductID;

OPEN @OrdersCursor;
FETCH NEXT FROM @OrdersCursor INTO @ProductID, @Qty, @SalesOrderID;

WHILE @@FETCH_STATUS = 0
BEGIN
    -- Check if production order already exists
    IF NOT EXISTS (SELECT 1 FROM ProductionOrder po 
                   WHERE po.ProductID = @ProductID 
                   AND EXISTS (SELECT 1 FROM SalesOrder so WHERE so.SalesOrderID = @SalesOrderID))
    BEGIN
        INSERT INTO ProductionOrder (ProductID, QuantityOrdered, Status, Priority, CreatedByEmployeeID, CreatedDate, StartDate)
        VALUES (@ProductID, @Qty, 'Pending', 'Normal', 1, GETDATE(), GETDATE());
    END
    FETCH NEXT FROM @OrdersCursor INTO @ProductID, @Qty, @SalesOrderID;
END

CLOSE @OrdersCursor;
DEALLOCATE @OrdersCursor;

PRINT '   ✓ Created Production Orders for Sales Order items';

-- Create production orders for Deal items
DECLARE @DealID INT;
SET @OrdersCursor = CURSOR FOR
SELECT DISTINCT di.ProductID, SUM(di.Quantity) AS Qty, di.DealID
FROM DealItem di
WHERE di.DealID BETWEEN 8 AND 15
GROUP BY di.DealID, di.ProductID;

OPEN @OrdersCursor;
FETCH NEXT FROM @OrdersCursor INTO @ProductID, @Qty, @DealID;

WHILE @@FETCH_STATUS = 0
BEGIN
    INSERT INTO ProductionOrder (ProductID, QuantityOrdered, Status, Priority, CreatedByEmployeeID, CreatedDate, StartDate)
    VALUES (@ProductID, @Qty, 'Pending', 'Normal', 1, GETDATE(), GETDATE());
    
    FETCH NEXT FROM @OrdersCursor INTO @ProductID, @Qty, @DealID;
END

CLOSE @OrdersCursor;
DEALLOCATE @OrdersCursor;

PRINT '   ✓ Created Production Orders for Deal items';
PRINT '';

-- =============================================
-- STEP 4: Assign Tailors to Production Orders
-- =============================================
PRINT '4. Assigning Tailors to Production Orders...';

-- Get available tailors (RoleID = 5 is Tailor)
DECLARE @TailorID1 INT = 6;   -- rao Zain ali
DECLARE @TailorID2 INT = 16;  -- Zain Ali
DECLARE @TailorID3 INT = 17;  -- Bilal Hassan
DECLARE @TailorID4 INT = 18;  -- Aisha Khan
DECLARE @TailorID5 INT = 19;  -- Samir Hassan

-- Assign tailors to all pending production orders
DECLARE @ProductionOrderID INT, @ProdProductID INT, @ProdQty INT;
DECLARE @TailorIndex INT = 1;

DECLARE ProdCursor CURSOR FOR
SELECT ProductionOrderID, ProductID, QuantityOrdered 
FROM ProductionOrder 
WHERE Status = 'Pending';

OPEN ProdCursor;
FETCH NEXT FROM ProdCursor INTO @ProductionOrderID, @ProdProductID, @ProdQty;

WHILE @@FETCH_STATUS = 0
BEGIN
    -- Rotate through tailors
    DECLARE @AssignedTailor INT;
    SET @AssignedTailor = CASE @TailorIndex % 5
        WHEN 1 THEN @TailorID1
        WHEN 2 THEN @TailorID2
        WHEN 3 THEN @TailorID3
        WHEN 4 THEN @TailorID4
        WHEN 0 THEN @TailorID5
    END;
    
    -- Create assignment if not exists
    IF NOT EXISTS (SELECT 1 FROM TailorAssignment WHERE ProductionOrderID = @ProductionOrderID)
    BEGIN
        INSERT INTO TailorAssignment (ProductionOrderID, TailorID, ProductID, QuantityAssigned, Status, AssignedDate)
        VALUES (@ProductionOrderID, @AssignedTailor, @ProdProductID, @ProdQty, 'Assigned', GETDATE());
    END
    
    SET @TailorIndex = @TailorIndex + 1;
    FETCH NEXT FROM ProdCursor INTO @ProductionOrderID, @ProdProductID, @ProdQty;
END

CLOSE ProdCursor;
DEALLOCATE ProdCursor;

PRINT '   ✓ Assigned tailors to all production orders';
PRINT '';

-- =============================================
-- STEP 5: Process Some Orders Through Complete Workflow
-- (Simulate different stages - some completed, some in progress)
-- =============================================
PRINT '5. Processing orders through various stages...';

-- Complete 60% of tailor assignments (simulate work done)
UPDATE TailorAssignment 
SET Status = 'Complete',
    CompletedDate = DATEADD(HOUR, -AssignmentID, GETDATE())
WHERE AssignmentID IN (
    SELECT TOP 60 PERCENT AssignmentID 
    FROM TailorAssignment 
    WHERE Status = 'Assigned'
    ORDER BY AssignmentID
);

PRINT '   ✓ Completed 60% of tailor assignments';

-- Update 20% to InProgress
UPDATE TailorAssignment 
SET Status = 'InProgress'
WHERE AssignmentID IN (
    SELECT TOP 10 AssignmentID 
    FROM TailorAssignment 
    WHERE Status = 'Assigned'
    ORDER BY AssignmentID
);

PRINT '   ✓ Set 20% of remaining assignments to InProgress';

-- Update production orders based on tailor completion
UPDATE po
SET po.Status = 'Completed',
    po.ActualEndDate = GETDATE()
FROM ProductionOrder po
WHERE EXISTS (
    SELECT 1 FROM TailorAssignment ta 
    WHERE ta.ProductionOrderID = po.ProductionOrderID 
    AND ta.Status = 'Complete'
)
AND po.Status = 'Pending';

UPDATE po
SET po.Status = 'InProgress'
FROM ProductionOrder po
WHERE EXISTS (
    SELECT 1 FROM TailorAssignment ta 
    WHERE ta.ProductionOrderID = po.ProductionOrderID 
    AND ta.Status = 'InProgress'
)
AND po.Status = 'Pending';

PRINT '   ✓ Updated production order statuses';
PRINT '';

-- =============================================
-- STEP 6: Create Deliveries for Completed Orders
-- =============================================
PRINT '6. Creating Deliveries...';

-- Create deliveries for approved sales orders
INSERT INTO Delivery (SalesOrderID, DeliveredBy, DeliveryDate, DeliveryAddress, City, Province, Status, ReceiverName, ReceiverPhone, Notes, CreatedDate)
SELECT 
    so.SalesOrderID,
    9, -- Muhammad Khan (Delivery Person)
    DATEADD(DAY, 3, so.OrderDate),
    so.ShippingAddress,
    r.City,
    'Punjab',
    'Pending',
    r.ContactPerson,
    r.Phone,
    'Delivery for Sales Order #' + CAST(so.SalesOrderID AS VARCHAR(10)),
    GETDATE()
FROM SalesOrder so
JOIN Retailer r ON so.RetailerID = r.RetailerID
WHERE so.SalesOrderID BETWEEN 15 AND 22
AND NOT EXISTS (SELECT 1 FROM Delivery d WHERE d.SalesOrderID = so.SalesOrderID);

PRINT '   ✓ Created deliveries for Sales Orders';

-- Create deliveries for approved deals
INSERT INTO Delivery (DealID, DeliveredBy, DeliveryDate, DeliveryAddress, City, Province, Status, ReceiverName, ReceiverPhone, Notes, CreatedDate)
SELECT 
    d.DealID,
    20, -- Another delivery person
    DATEADD(DAY, 3, d.StartDate),
    d.DeliveryAddress,
    d.City,
    d.Province,
    'Pending',
    d.ContactPerson,
    d.Phone,
    'Delivery for Deal: ' + d.DealTitle,
    GETDATE()
FROM Deal d
WHERE d.DealID BETWEEN 8 AND 15
AND NOT EXISTS (SELECT 1 FROM Delivery del WHERE del.DealID = d.DealID);

PRINT '   ✓ Created deliveries for Deals';
PRINT '';

-- =============================================
-- STEP 7: Complete Some Deliveries
-- =============================================
PRINT '7. Completing some deliveries...';

-- Mark 50% of deliveries as Delivered
UPDATE Delivery
SET Status = 'Delivered',
    DeliveryDate = GETDATE()
WHERE DeliveryID IN (
    SELECT TOP 50 PERCENT DeliveryID
    FROM Delivery
    WHERE Status = 'Pending'
    ORDER BY DeliveryID
);

PRINT '   ✓ Marked 50% of deliveries as Delivered';

-- Update corresponding order statuses
UPDATE so
SET so.Status = 'Delivered', so.UpdatedDate = GETDATE()
FROM SalesOrder so
WHERE EXISTS (SELECT 1 FROM Delivery d WHERE d.SalesOrderID = so.SalesOrderID AND d.Status = 'Delivered');

UPDATE d
SET d.Status = 'Delivered', d.UpdatedDate = GETDATE()
FROM Deal d
WHERE EXISTS (SELECT 1 FROM Delivery del WHERE del.DealID = d.DealID AND del.Status = 'Delivered');

PRINT '   ✓ Updated order statuses to Delivered';
PRINT '';

-- =============================================
-- STEP 8: Final Statistics and Summary
-- =============================================
PRINT '========================================';
PRINT 'WORKFLOW PROCESSING COMPLETE!';
PRINT '========================================';
PRINT '';

-- Sales Orders Summary
PRINT '📦 SALES ORDERS SUMMARY:';
SELECT Status, COUNT(*) AS OrderCount, SUM(TotalAmount) AS TotalValue
FROM SalesOrder
WHERE SalesOrderID >= 15
GROUP BY Status;

-- Deals Summary
PRINT '';
PRINT '🤝 DEALS SUMMARY:';
SELECT Status, COUNT(*) AS DealCount, SUM(TotalAmount) AS TotalValue
FROM Deal
WHERE DealID >= 8
GROUP BY Status;

-- Production Summary
PRINT '';
PRINT '🏭 PRODUCTION ORDERS SUMMARY:';
SELECT Status, COUNT(*) AS ProductionCount
FROM ProductionOrder
GROUP BY Status;

-- Tailor Assignments Summary
PRINT '';
PRINT '👔 TAILOR ASSIGNMENTS SUMMARY:';
SELECT Status, COUNT(*) AS AssignmentCount
FROM TailorAssignment
GROUP BY Status;

-- Deliveries Summary
PRINT '';
PRINT '🚚 DELIVERIES SUMMARY:';
SELECT Status, COUNT(*) AS DeliveryCount
FROM Delivery
GROUP BY Status;

-- Revenue Summary
PRINT '';
PRINT '💰 REVENUE SUMMARY:';
SELECT 
    'Delivered Sales Orders' AS Category,
    COUNT(*) AS Count,
    ISNULL(SUM(TotalAmount), 0) AS Revenue
FROM SalesOrder WHERE Status = 'Delivered'
UNION ALL
SELECT 
    'Delivered Deals',
    COUNT(*),
    ISNULL(SUM(TotalAmount), 0)
FROM Deal WHERE Status = 'Delivered'
UNION ALL
SELECT 
    'Pending Revenue (Orders)',
    COUNT(*),
    ISNULL(SUM(TotalAmount), 0)
FROM SalesOrder WHERE Status IN ('Pending', 'Approved')
UNION ALL
SELECT 
    'Pending Revenue (Deals)',
    COUNT(*),
    ISNULL(SUM(TotalAmount), 0)
FROM Deal WHERE Status IN ('Pending', 'Approved');

PRINT '';
PRINT '========================================';
PRINT '✓ ALL SAMPLE DATA PROCESSED SUCCESSFULLY';
PRINT '========================================';

GO
