-- Final fix for SalesOrder data
USE GarmentsFactoryDB;
GO

SET QUOTED_IDENTIFIER ON;
GO

DELETE FROM SalesOrderItem;
DELETE FROM SalesOrder;
GO

INSERT INTO SalesOrder (OrderDate, Status, RetailerID, ShippingAddress, DiscountPercentage, SubTotal, TotalAmount, SalesRepID) VALUES
('2025-10-05', 'Delivered', 2, 'Lahore', 0, 85000, 85000, 14),
('2025-10-08', 'Delivered', 3, 'Karachi', 0, 62000, 62000, 15),
('2025-10-12', 'Delivered', 4, 'Faisalabad', 0, 145000, 145000, 14),
('2025-10-18', 'Delivered', 5, 'Islamabad', 0, 48000, 48000, 16),
('2025-10-22', 'Delivered', 6, 'Multan', 0, 92000, 92000, 15),
('2025-10-28', 'Delivered', 2, 'Sialkot', 0, 180000, 180000, 14),
('2025-11-02', 'Delivered', 3, 'Lahore', 0, 125000, 125000, 14),
('2025-11-05', 'Delivered', 4, 'Faisalabad', 0, 195000, 195000, 15),
('2025-11-08', 'Delivered', 5, 'Karachi', 0, 78000, 78000, 14),
('2025-11-12', 'Delivered', 6, 'Sialkot', 0, 250000, 250000, 16),
('2025-11-18', 'Delivered', 2, 'Multan', 0, 115000, 115000, 15),
('2025-11-22', 'Delivered', 3, 'Islamabad', 0, 68000, 68000, 14),
('2025-11-25', 'Delivered', 4, 'Peshawar', 0, 88000, 88000, 16),
('2025-11-28', 'Delivered', 5, 'Rawalpindi', 0, 45000, 45000, 15),
('2025-12-01', 'Delivered', 2, 'Lahore', 0, 95000, 95000, 14),
('2025-12-03', 'Delivered', 3, 'Karachi', 0, 72000, 72000, 15),
('2025-12-05', 'Shipped', 4, 'Faisalabad', 0, 168000, 168000, 14),
('2025-12-07', 'Shipped', 5, 'Sialkot', 0, 220000, 220000, 16),
('2025-12-09', 'Confirmed', 6, 'Multan', 0, 85000, 85000, 15),
('2025-12-10', 'Confirmed', 2, 'Islamabad', 0, 55000, 55000, 14);
GO

-- Recalculate Monthly Revenue
DELETE FROM MonthlyRevenue;
GO

-- Get actual salary sum
DECLARE @TotalSalary DECIMAL(18,2) = (SELECT ISNULL(SUM(Salary), 0) FROM Employee WHERE IsActive = 1);
PRINT 'Total Monthly Salaries: ' + CAST(@TotalSalary AS VARCHAR);
GO

-- October
DECLARE @OctSales DECIMAL(18,2) = (SELECT ISNULL(SUM(TotalAmount), 0) FROM SalesOrder WHERE YEAR(OrderDate) = 2025 AND MONTH(OrderDate) = 10 AND Status IN ('Delivered', 'Completed', 'Shipped', 'Confirmed'));
DECLARE @OctDeals DECIMAL(18,2) = (SELECT ISNULL(SUM(TotalAmount), 0) FROM Deal WHERE YEAR(StartDate) = 2025 AND MONTH(StartDate) = 10 AND Status IN ('Completed', 'Approved'));
DECLARE @Sal1 DECIMAL(18,2) = (SELECT ISNULL(SUM(Salary), 0) FROM Employee WHERE IsActive = 1);
INSERT INTO MonthlyRevenue ([Year], [Month], MonthName, SalesIncome, DealIncome, SalariesPaid, TotalSalaries, RawMaterialCost, MiscExpense, Notes)
VALUES (2025, 10, 'October', @OctSales, @OctDeals, 1, @Sal1, 120000, 35000, 'October - Wedding season starting');
GO

-- November
DECLARE @NovSales DECIMAL(18,2) = (SELECT ISNULL(SUM(TotalAmount), 0) FROM SalesOrder WHERE YEAR(OrderDate) = 2025 AND MONTH(OrderDate) = 11 AND Status IN ('Delivered', 'Completed', 'Shipped', 'Confirmed'));
DECLARE @NovDeals DECIMAL(18,2) = (SELECT ISNULL(SUM(TotalAmount), 0) FROM Deal WHERE YEAR(StartDate) = 2025 AND MONTH(StartDate) = 11 AND Status IN ('Completed', 'Approved'));
DECLARE @Sal2 DECIMAL(18,2) = (SELECT ISNULL(SUM(Salary), 0) FROM Employee WHERE IsActive = 1);
INSERT INTO MonthlyRevenue ([Year], [Month], MonthName, SalesIncome, DealIncome, SalariesPaid, TotalSalaries, RawMaterialCost, MiscExpense, Notes)
VALUES (2025, 11, 'November', @NovSales, @NovDeals, 1, @Sal2, 180000, 55000, 'November - Wedding Season Peak');
GO

-- December  
DECLARE @DecSales DECIMAL(18,2) = (SELECT ISNULL(SUM(TotalAmount), 0) FROM SalesOrder WHERE YEAR(OrderDate) = 2025 AND MONTH(OrderDate) = 12 AND Status IN ('Delivered', 'Completed', 'Shipped', 'Confirmed'));
DECLARE @DecDeals DECIMAL(18,2) = (SELECT ISNULL(SUM(TotalAmount), 0) FROM Deal WHERE YEAR(StartDate) = 2025 AND MONTH(StartDate) = 12 AND Status IN ('Completed', 'Approved', 'Active'));
INSERT INTO MonthlyRevenue ([Year], [Month], MonthName, SalesIncome, DealIncome, SalariesPaid, TotalSalaries, RawMaterialCost, MiscExpense, Notes)
VALUES (2025, 12, 'December', @DecSales, @DecDeals, 0, 0, 150000, 45000, 'December - Salaries Pending');
GO

-- Final verification
PRINT 'FINAL REVENUE DATA:';
SELECT MonthName, 
    FORMAT(SalesIncome, 'N0') AS Sales,
    FORMAT(DealIncome, 'N0') AS Deals,
    FORMAT(SalesIncome + DealIncome, 'N0') AS [Total Income],
    FORMAT(TotalSalaries + RawMaterialCost + MiscExpense, 'N0') AS [Total Expense],
    FORMAT(SalesIncome + DealIncome - TotalSalaries - RawMaterialCost - MiscExpense, 'N0') AS [Net Profit]
FROM MonthlyRevenue WHERE [Year] = 2025;
GO
