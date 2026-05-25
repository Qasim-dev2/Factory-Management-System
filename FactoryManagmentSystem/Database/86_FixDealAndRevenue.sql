-- ================================================================================
-- FIX DEAL TABLE AND REVENUE CALCULATIONS
-- Adds TotalAmount to Deal table and updates Revenue procedures
-- ================================================================================
USE GarmentsFactoryDB;
GO

PRINT '========================================';
PRINT 'FIXING DEAL TABLE AND REVENUE SYSTEM';
PRINT '========================================';

-- ================================================================================
-- STEP 1: ADD TOTALAMOUNT COLUMN TO DEAL TABLE
-- ================================================================================
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Deal' AND COLUMN_NAME = 'TotalAmount')
BEGIN
    ALTER TABLE Deal ADD TotalAmount DECIMAL(18,2) DEFAULT 0;
    PRINT '✅ TotalAmount column added to Deal table';
END
GO

-- ================================================================================
-- STEP 2: CLEAN UP AND INSERT FRESH SAMPLE DATA
-- ================================================================================
PRINT 'Step 2: Cleaning and inserting fresh Deal data...';

-- Clear existing deals
DELETE FROM DealItem;
DELETE FROM Deal;
DBCC CHECKIDENT ('Deal', RESEED, 0);
DBCC CHECKIDENT ('DealItem', RESEED, 0);
GO

-- Insert Deals with TotalAmount (October - December 2025)
-- October 2025 Deals
INSERT INTO Deal (DealTitle, DealType, ClientName, ContactPerson, Email, Phone, StartDate, EndDate, Description, Status, TotalAmount) VALUES
('Eid Collection Supply', 'Supply Contract', 'Karachi Wholesale Market', 'Saleem Ahmed', 'saleem@kwm.com', '0321-1112233', '2025-10-01', '2025-10-30', 'Eid special collection supply', 'Completed', 180000),
('Corporate Uniforms', 'Partnership', 'Bank Al-Habib', 'HR Department', 'hr@abl.com', '021-111225522', '2025-10-15', '2025-11-15', 'Staff uniform supply contract', 'Completed', 250000);

-- November 2025 Deals (Wedding Season)
INSERT INTO Deal (DealTitle, DealType, ClientName, ContactPerson, Email, Phone, StartDate, EndDate, Description, Status, TotalAmount) VALUES
('Wedding Season Bulk', 'Supply Contract', 'Lahore Bridal Market', 'Asif Iqbal', 'asif@lbm.com', '0300-4445566', '2025-11-01', '2025-11-30', 'Wedding season bulk order', 'Completed', 350000),
('Export Order - UK', 'Export', 'British Asian Fashions', 'James Khan', 'james@baf.co.uk', '+44-7891234567', '2025-11-10', '2025-12-10', 'Export quality garments for UK market', 'Completed', 420000),
('Hotel Staff Uniforms', 'Partnership', 'Pearl Continental Hotels', 'Procurement Dept', 'procurement@pc.com', '042-111505505', '2025-11-15', '2025-12-15', 'Staff uniforms for PC hotels', 'Completed', 280000);

-- December 2025 Deals
INSERT INTO Deal (DealTitle, DealType, ClientName, ContactPerson, Email, Phone, StartDate, EndDate, Description, Status, TotalAmount) VALUES
('Year End Clearance', 'Supply Contract', 'Faisalabad Mega Mart', 'Naveed Khan', 'naveed@fmm.com', '041-2515151', '2025-12-01', '2025-12-31', 'Year end bulk purchase', 'Approved', 320000),
('New Year Collection', 'Partnership', 'Islamabad Fashion Week', 'Event Manager', 'events@ifw.pk', '051-2876543', '2025-12-05', '2025-12-25', 'Fashion week collection supply', 'Approved', 150000),
('School Uniforms 2026', 'Supply Contract', 'Punjab Education Dept', 'Procurement', 'proc@ped.gov.pk', '042-99210000', '2025-12-10', '2026-02-28', 'School uniforms for govt schools', 'Pending', 500000);

PRINT '✅ 8 Deals inserted with TotalAmount';
GO

-- ================================================================================
-- STEP 3: UPDATE REVENUE STORED PROCEDURE
-- ================================================================================
PRINT 'Step 3: Updating Revenue stored procedure...';

IF OBJECT_ID('dbo.sp_CalculateMonthlyRevenue', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_CalculateMonthlyRevenue;
GO

CREATE PROCEDURE dbo.sp_CalculateMonthlyRevenue
    @Year INT,
    @Month INT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @MonthName NVARCHAR(20) = DATENAME(MONTH, DATEFROMPARTS(@Year, @Month, 1));
    DECLARE @Sales DECIMAL(18,2) = 0;
    DECLARE @Deals DECIMAL(18,2) = 0;
    DECLARE @RawMat DECIMAL(18,2) = 0;
    
    -- Calculate Sales Income (from SalesOrders with valid statuses)
    SELECT @Sales = ISNULL(SUM(TotalAmount), 0)
    FROM dbo.SalesOrder
    WHERE YEAR(OrderDate) = @Year 
      AND MONTH(OrderDate) = @Month
      AND Status IN ('Completed', 'Delivered', 'Shipped', 'Confirmed', 'Approved');
    
    -- Calculate Deal Income (from Deals with valid statuses)
    SELECT @Deals = ISNULL(SUM(TotalAmount), 0)
    FROM dbo.Deal
    WHERE YEAR(StartDate) = @Year 
      AND MONTH(StartDate) = @Month
      AND Status IN ('Completed', 'Finalized', 'Approved', 'Active');
    
    -- Raw material cost placeholder (can be enhanced later)
    SET @RawMat = 0;
    
    -- Insert or Update
    IF NOT EXISTS (SELECT 1 FROM dbo.MonthlyRevenue WHERE [Year]=@Year AND [Month]=@Month)
    BEGIN
        INSERT INTO dbo.MonthlyRevenue ([Year], [Month], MonthName, SalesIncome, DealIncome, RawMaterialCost)
        VALUES (@Year, @Month, @MonthName, @Sales, @Deals, @RawMat);
    END
    ELSE
    BEGIN
        UPDATE dbo.MonthlyRevenue 
        SET SalesIncome = @Sales, 
            DealIncome = @Deals,
            RawMaterialCost = @RawMat,
            UpdatedDate = GETDATE()
        WHERE [Year] = @Year AND [Month] = @Month;
    END
    
    -- Return the record
    SELECT * FROM dbo.MonthlyRevenue WHERE [Year] = @Year AND [Month] = @Month;
END
GO

PRINT '✅ sp_CalculateMonthlyRevenue updated';
GO

-- ================================================================================
-- STEP 4: UPDATE MONTHLY REVENUE DATA
-- ================================================================================
PRINT 'Step 4: Refreshing Monthly Revenue data...';

-- Clear existing revenue data
DELETE FROM MonthlyRevenue;
GO

-- October 2025
DECLARE @OctSales DECIMAL(18,2) = (SELECT ISNULL(SUM(TotalAmount), 0) FROM SalesOrder WHERE YEAR(OrderDate) = 2025 AND MONTH(OrderDate) = 10 AND Status IN ('Delivered', 'Completed', 'Shipped', 'Confirmed'));
DECLARE @OctDeals DECIMAL(18,2) = (SELECT ISNULL(SUM(TotalAmount), 0) FROM Deal WHERE YEAR(StartDate) = 2025 AND MONTH(StartDate) = 10 AND Status IN ('Completed', 'Approved'));

INSERT INTO MonthlyRevenue ([Year], [Month], MonthName, SalesIncome, DealIncome, SalariesPaid, TotalSalaries, RawMaterialCost, MiscExpense, Notes)
VALUES (2025, 10, 'October', @OctSales, @OctDeals, 1, 809000, 120000, 35000, 'October - Wedding season starting');
GO

-- November 2025
DECLARE @NovSales DECIMAL(18,2) = (SELECT ISNULL(SUM(TotalAmount), 0) FROM SalesOrder WHERE YEAR(OrderDate) = 2025 AND MONTH(OrderDate) = 11 AND Status IN ('Delivered', 'Completed', 'Shipped', 'Confirmed'));
DECLARE @NovDeals DECIMAL(18,2) = (SELECT ISNULL(SUM(TotalAmount), 0) FROM Deal WHERE YEAR(StartDate) = 2025 AND MONTH(StartDate) = 11 AND Status IN ('Completed', 'Approved'));

INSERT INTO MonthlyRevenue ([Year], [Month], MonthName, SalesIncome, DealIncome, SalariesPaid, TotalSalaries, RawMaterialCost, MiscExpense, Notes)
VALUES (2025, 11, 'November', @NovSales, @NovDeals, 1, 809000, 180000, 55000, 'November - Wedding Season Peak');
GO

-- December 2025
DECLARE @DecSales DECIMAL(18,2) = (SELECT ISNULL(SUM(TotalAmount), 0) FROM SalesOrder WHERE YEAR(OrderDate) = 2025 AND MONTH(OrderDate) = 12 AND Status IN ('Delivered', 'Completed', 'Shipped', 'Confirmed'));
DECLARE @DecDeals DECIMAL(18,2) = (SELECT ISNULL(SUM(TotalAmount), 0) FROM Deal WHERE YEAR(StartDate) = 2025 AND MONTH(StartDate) = 12 AND Status IN ('Completed', 'Approved', 'Active'));

INSERT INTO MonthlyRevenue ([Year], [Month], MonthName, SalesIncome, DealIncome, SalariesPaid, TotalSalaries, RawMaterialCost, MiscExpense, Notes)
VALUES (2025, 12, 'December', @DecSales, @DecDeals, 0, 0, 150000, 45000, 'December - Year End (Salaries Pending)');
GO

PRINT '✅ Monthly Revenue data refreshed';
GO

-- ================================================================================
-- VERIFICATION
-- ================================================================================
PRINT '';
PRINT '========================================';
PRINT 'VERIFICATION';
PRINT '========================================';

PRINT 'Sales Orders by Month:';
SELECT MONTH(OrderDate) AS [Month], COUNT(*) AS [Orders], FORMAT(SUM(TotalAmount), 'N0') AS [Total]
FROM SalesOrder 
WHERE YEAR(OrderDate) = 2025
GROUP BY MONTH(OrderDate)
ORDER BY MONTH(OrderDate);

PRINT '';
PRINT 'Deals by Month:';
SELECT MONTH(StartDate) AS [Month], COUNT(*) AS [Deals], FORMAT(SUM(TotalAmount), 'N0') AS [Total]
FROM Deal 
WHERE YEAR(StartDate) = 2025
GROUP BY MONTH(StartDate)
ORDER BY MONTH(StartDate);

PRINT '';
PRINT 'Monthly Revenue Summary:';
SELECT [Month], MonthName, 
       FORMAT(SalesIncome, 'N0') AS [SalesIncome],
       FORMAT(DealIncome, 'N0') AS [DealIncome],
       FORMAT(SalesIncome + DealIncome, 'N0') AS [TotalIncome],
       FORMAT(TotalSalaries + RawMaterialCost + MiscExpense, 'N0') AS [TotalExpense],
       FORMAT(SalesIncome + DealIncome - TotalSalaries - RawMaterialCost - MiscExpense, 'N0') AS [NetProfit],
       CASE WHEN SalariesPaid = 1 THEN 'Paid' ELSE 'Pending' END AS [Salaries]
FROM MonthlyRevenue 
WHERE [Year] = 2025
ORDER BY [Month];

PRINT '';
PRINT '✅ DEAL TABLE AND REVENUE SYSTEM FIXED!';
PRINT '========================================';
GO
