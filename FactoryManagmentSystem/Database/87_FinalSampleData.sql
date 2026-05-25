-- ================================================================================
-- FINAL COMPLETE SAMPLE DATA INSERT
-- Works with actual database structure
-- ================================================================================
USE GarmentsFactoryDB;
GO

PRINT '========================================';
PRINT 'INSERTING FRESH SAMPLE DATA';
PRINT '========================================';

-- ================================================================================
-- STEP 1: INSERT SALES ORDERS (October - December 2025)
-- ================================================================================
PRINT 'Step 1: Inserting Sales Orders...';

-- Clear existing sales orders
DELETE FROM SalesOrderItem;
DELETE FROM SalesOrder;
GO

-- October 2025 Sales Orders
INSERT INTO SalesOrder (OrderDate, Status, RetailerID, ShippingAddress, DiscountPercentage, SubTotal, TotalAmount, SalesRepID) VALUES
('2025-10-05', 'Delivered', 1, 'Shop 15, Anarkali Bazaar, Lahore', 0, 85000, 85000, 7),
('2025-10-08', 'Delivered', 2, 'Plot 25, Tariq Road, Karachi', 0, 62000, 62000, 8),
('2025-10-12', 'Delivered', 3, 'D-Ground, Faisalabad', 0, 145000, 145000, 7),
('2025-10-18', 'Delivered', 4, 'F-7 Markaz, Islamabad', 0, 48000, 48000, 9),
('2025-10-22', 'Delivered', 5, 'Hussain Agahi, Multan', 0, 92000, 92000, 8),
('2025-10-28', 'Delivered', 6, 'Industrial Area, Sialkot', 0, 180000, 180000, 7);

-- November 2025 Sales Orders (Wedding Season - Higher)
INSERT INTO SalesOrder (OrderDate, Status, RetailerID, ShippingAddress, DiscountPercentage, SubTotal, TotalAmount, SalesRepID) VALUES
('2025-11-02', 'Delivered', 1, 'Shop 15, Anarkali Bazaar, Lahore', 0, 125000, 125000, 7),
('2025-11-05', 'Delivered', 3, 'D-Ground, Faisalabad', 0, 195000, 195000, 8),
('2025-11-08', 'Delivered', 2, 'Plot 25, Tariq Road, Karachi', 0, 78000, 78000, 7),
('2025-11-12', 'Delivered', 6, 'Industrial Area, Sialkot', 0, 250000, 250000, 9),
('2025-11-18', 'Delivered', 5, 'Hussain Agahi, Multan', 0, 115000, 115000, 8),
('2025-11-22', 'Delivered', 4, 'F-7 Markaz, Islamabad', 0, 68000, 68000, 7),
('2025-11-25', 'Delivered', 1, 'Qissa Khwani Bazaar, Peshawar', 0, 88000, 88000, 9),
('2025-11-28', 'Delivered', 2, 'Raja Bazaar, Rawalpindi', 0, 45000, 45000, 8);

-- December 2025 Sales Orders (Current Month)
INSERT INTO SalesOrder (OrderDate, Status, RetailerID, ShippingAddress, DiscountPercentage, SubTotal, TotalAmount, SalesRepID) VALUES
('2025-12-01', 'Delivered', 1, 'Shop 15, Anarkali Bazaar, Lahore', 0, 95000, 95000, 7),
('2025-12-03', 'Delivered', 2, 'Plot 25, Tariq Road, Karachi', 0, 72000, 72000, 8),
('2025-12-05', 'Shipped', 3, 'D-Ground, Faisalabad', 0, 168000, 168000, 7),
('2025-12-07', 'Shipped', 6, 'Industrial Area, Sialkot', 0, 220000, 220000, 9),
('2025-12-09', 'Confirmed', 5, 'Hussain Agahi, Multan', 0, 85000, 85000, 8),
('2025-12-10', 'Confirmed', 4, 'F-7 Markaz, Islamabad', 0, 55000, 55000, 7);

PRINT '✅ 20 Sales Orders inserted';
GO

-- ================================================================================
-- STEP 2: RECALCULATE MONTHLY REVENUE
-- ================================================================================
PRINT 'Step 2: Recalculating Monthly Revenue...';

-- Delete and recalculate
DELETE FROM MonthlyRevenue;
GO

-- October 2025
DECLARE @OctSales DECIMAL(18,2) = (SELECT ISNULL(SUM(TotalAmount), 0) FROM SalesOrder WHERE YEAR(OrderDate) = 2025 AND MONTH(OrderDate) = 10 AND Status IN ('Delivered', 'Completed', 'Shipped', 'Confirmed'));
DECLARE @OctDeals DECIMAL(18,2) = (SELECT ISNULL(SUM(TotalAmount), 0) FROM Deal WHERE YEAR(StartDate) = 2025 AND MONTH(StartDate) = 10 AND Status IN ('Completed', 'Approved'));

INSERT INTO MonthlyRevenue ([Year], [Month], MonthName, SalesIncome, DealIncome, SalariesPaid, TotalSalaries, RawMaterialCost, MiscExpense, Notes)
VALUES (2025, 10, 'October', @OctSales, @OctDeals, 1, 
        (SELECT ISNULL(SUM(Salary), 0) FROM Employee WHERE IsActive = 1),
        120000, 35000, 'October - Wedding season starting');
GO

-- November 2025
DECLARE @NovSales DECIMAL(18,2) = (SELECT ISNULL(SUM(TotalAmount), 0) FROM SalesOrder WHERE YEAR(OrderDate) = 2025 AND MONTH(OrderDate) = 11 AND Status IN ('Delivered', 'Completed', 'Shipped', 'Confirmed'));
DECLARE @NovDeals DECIMAL(18,2) = (SELECT ISNULL(SUM(TotalAmount), 0) FROM Deal WHERE YEAR(StartDate) = 2025 AND MONTH(StartDate) = 11 AND Status IN ('Completed', 'Approved'));

INSERT INTO MonthlyRevenue ([Year], [Month], MonthName, SalesIncome, DealIncome, SalariesPaid, TotalSalaries, RawMaterialCost, MiscExpense, Notes)
VALUES (2025, 11, 'November', @NovSales, @NovDeals, 1, 
        (SELECT ISNULL(SUM(Salary), 0) FROM Employee WHERE IsActive = 1),
        180000, 55000, 'November - Wedding Season Peak');
GO

-- December 2025
DECLARE @DecSales DECIMAL(18,2) = (SELECT ISNULL(SUM(TotalAmount), 0) FROM SalesOrder WHERE YEAR(OrderDate) = 2025 AND MONTH(OrderDate) = 12 AND Status IN ('Delivered', 'Completed', 'Shipped', 'Confirmed'));
DECLARE @DecDeals DECIMAL(18,2) = (SELECT ISNULL(SUM(TotalAmount), 0) FROM Deal WHERE YEAR(StartDate) = 2025 AND MONTH(StartDate) = 12 AND Status IN ('Completed', 'Approved', 'Active'));

INSERT INTO MonthlyRevenue ([Year], [Month], MonthName, SalesIncome, DealIncome, SalariesPaid, TotalSalaries, RawMaterialCost, MiscExpense, Notes)
VALUES (2025, 12, 'December', @DecSales, @DecDeals, 0, 0, 150000, 45000, 'December - Year End (Salaries Pending)');
GO

PRINT '✅ Monthly Revenue recalculated';
GO

-- ================================================================================
-- VERIFICATION
-- ================================================================================
PRINT '';
PRINT '========================================';
PRINT 'FINAL DATA VERIFICATION';
PRINT '========================================';

PRINT '';
PRINT 'Data Counts:';
SELECT 'Employees' AS [Table], COUNT(*) AS [Count] FROM Employee WHERE IsActive = 1 UNION ALL
SELECT 'Products', COUNT(*) FROM Product UNION ALL
SELECT 'Retailers', COUNT(*) FROM Retailer UNION ALL
SELECT 'Sales Orders', COUNT(*) FROM SalesOrder UNION ALL
SELECT 'Deals', COUNT(*) FROM Deal UNION ALL
SELECT 'Deliveries', COUNT(*) FROM Delivery;

PRINT '';
PRINT 'Total Employee Salaries:';
SELECT FORMAT(SUM(Salary), 'N0') AS [Total Monthly Salary] FROM Employee WHERE IsActive = 1;

PRINT '';
PRINT 'Sales Orders by Month (2025):';
SELECT MONTH(OrderDate) AS [Month], COUNT(*) AS [Orders], FORMAT(SUM(TotalAmount), 'N0') AS [Total Amount]
FROM SalesOrder 
WHERE YEAR(OrderDate) = 2025
GROUP BY MONTH(OrderDate)
ORDER BY MONTH(OrderDate);

PRINT '';
PRINT 'Deals by Month (2025):';
SELECT MONTH(StartDate) AS [Month], COUNT(*) AS [Deals], FORMAT(SUM(TotalAmount), 'N0') AS [Total Amount]
FROM Deal 
WHERE YEAR(StartDate) = 2025
GROUP BY MONTH(StartDate)
ORDER BY MONTH(StartDate);

PRINT '';
PRINT 'MONTHLY REVENUE (2025):';
SELECT 
    MonthName,
    FORMAT(SalesIncome, 'N0') AS [Sales],
    FORMAT(DealIncome, 'N0') AS [Deals],
    FORMAT(SalesIncome + DealIncome, 'N0') AS [Total Income],
    FORMAT(TotalSalaries, 'N0') AS [Salaries],
    FORMAT(RawMaterialCost, 'N0') AS [Raw Material],
    FORMAT(MiscExpense, 'N0') AS [Misc],
    FORMAT(TotalSalaries + RawMaterialCost + MiscExpense, 'N0') AS [Total Expense],
    FORMAT(SalesIncome + DealIncome - TotalSalaries - RawMaterialCost - MiscExpense, 'N0') AS [Net Profit],
    CASE WHEN SalariesPaid = 1 THEN '✅ Paid' ELSE '⏳ Pending' END AS [Salary Status]
FROM MonthlyRevenue 
WHERE [Year] = 2025
ORDER BY [Month];

PRINT '';
PRINT '========================================';
PRINT '✅ SAMPLE DATA COMPLETE!';
PRINT '========================================';
GO
