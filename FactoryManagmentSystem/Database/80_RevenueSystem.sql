-- ================================================================================
-- REVENUE MANAGEMENT SYSTEM - Simple & Complete
-- For Pakistani Garment Factory
-- ================================================================================
USE GarmentsFactoryDB;
GO

PRINT '========================================';
PRINT 'CREATING REVENUE MANAGEMENT SYSTEM';
PRINT '========================================';
PRINT '';

-- ================================================================================
-- STEP 1: CREATE MONTHLY REVENUE TABLE
-- ================================================================================
PRINT 'Step 1: Creating MonthlyRevenue table...';

IF OBJECT_ID('dbo.MonthlyRevenue', 'U') IS NOT NULL
    DROP TABLE dbo.MonthlyRevenue;
GO

CREATE TABLE dbo.MonthlyRevenue (
    RevenueID INT IDENTITY(1,1) PRIMARY KEY,
    [Year] INT NOT NULL,
    [Month] INT NOT NULL,
    MonthName NVARCHAR(20),
    
    -- Income (from Sales & Deals)
    SalesIncome DECIMAL(18,2) DEFAULT 0,
    DealIncome DECIMAL(18,2) DEFAULT 0,
    
    -- Expenses
    SalariesPaid BIT DEFAULT 0,
    TotalSalaries DECIMAL(18,2) DEFAULT 0,
    RawMaterialCost DECIMAL(18,2) DEFAULT 0,
    MiscExpense DECIMAL(18,2) DEFAULT 0,
    
    -- Calculated columns
    TotalIncome AS (SalesIncome + DealIncome),
    TotalExpense AS (TotalSalaries + RawMaterialCost + MiscExpense),
    NetProfit AS (SalesIncome + DealIncome - TotalSalaries - RawMaterialCost - MiscExpense),
    
    Notes NVARCHAR(500) NULL,
    CreatedDate DATETIME DEFAULT GETDATE(),
    UpdatedDate DATETIME DEFAULT GETDATE(),
    
    CONSTRAINT UQ_MonthlyRevenue_YearMonth UNIQUE([Year], [Month])
);
GO

CREATE INDEX IX_MonthlyRevenue_Year ON dbo.MonthlyRevenue([Year]);
GO

PRINT '✅ MonthlyRevenue table created';
GO

-- ================================================================================
-- STEP 2: CREATE STORED PROCEDURES
-- ================================================================================
PRINT 'Step 2: Creating stored procedures...';
GO

-- 2.1: Calculate/Refresh Monthly Revenue
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
    
    -- Calculate Sales Income (from completed SalesOrders)
    SELECT @Sales = ISNULL(SUM(TotalAmount), 0)
    FROM dbo.SalesOrder
    WHERE YEAR(OrderDate) = @Year 
      AND MONTH(OrderDate) = @Month
      AND Status IN ('Completed', 'Delivered', 'Approved');
    
    -- Calculate Deal Income (from completed Deals)
    SELECT @Deals = ISNULL(SUM(TotalAmount), 0)
    FROM dbo.Deal
    WHERE YEAR(StartDate) = @Year 
      AND MONTH(StartDate) = @Month
      AND Status IN ('Completed', 'Finalized', 'Approved');
    
    -- Calculate Raw Material Cost (if you have StockUsage or similar table)
    -- For now we'll use a placeholder - adjust if you have purchase table
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

PRINT '✅ sp_CalculateMonthlyRevenue created';
GO

-- 2.2: Pay Salaries for a Month
IF OBJECT_ID('dbo.sp_PayMonthlySalaries', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_PayMonthlySalaries;
GO

CREATE PROCEDURE dbo.sp_PayMonthlySalaries
    @Year INT,
    @Month INT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @TotalSalary DECIMAL(18,2);
    
    -- Sum all active employee salaries
    SELECT @TotalSalary = ISNULL(SUM(Salary), 0)
    FROM dbo.Employee
    WHERE IsActive = 1 AND Salary > 0;
    
    -- Ensure record exists
    EXEC dbo.sp_CalculateMonthlyRevenue @Year, @Month;
    
    -- Mark as paid
    UPDATE dbo.MonthlyRevenue
    SET SalariesPaid = 1, 
        TotalSalaries = @TotalSalary,
        UpdatedDate = GETDATE()
    WHERE [Year] = @Year AND [Month] = @Month;
    
    -- Return updated record
    SELECT * FROM dbo.MonthlyRevenue WHERE [Year] = @Year AND [Month] = @Month;
END
GO

PRINT '✅ sp_PayMonthlySalaries created';
GO

-- 2.3: Add Misc Expense
IF OBJECT_ID('dbo.sp_AddMiscExpense', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_AddMiscExpense;
GO

CREATE PROCEDURE dbo.sp_AddMiscExpense
    @Year INT,
    @Month INT,
    @Amount DECIMAL(18,2),
    @Description NVARCHAR(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Ensure record exists
    EXEC dbo.sp_CalculateMonthlyRevenue @Year, @Month;
    
    -- Add to misc expense
    UPDATE dbo.MonthlyRevenue
    SET MiscExpense = MiscExpense + @Amount,
        Notes = CASE 
            WHEN Notes IS NULL THEN @Description 
            WHEN @Description IS NOT NULL THEN Notes + '; ' + @Description
            ELSE Notes
        END,
        UpdatedDate = GETDATE()
    WHERE [Year] = @Year AND [Month] = @Month;
    
    -- Return updated record
    SELECT * FROM dbo.MonthlyRevenue WHERE [Year] = @Year AND [Month] = @Month;
END
GO

PRINT '✅ sp_AddMiscExpense created';
GO

-- 2.4: Add Raw Material Cost
IF OBJECT_ID('dbo.sp_AddRawMaterialCost', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_AddRawMaterialCost;
GO

CREATE PROCEDURE dbo.sp_AddRawMaterialCost
    @Year INT,
    @Month INT,
    @Amount DECIMAL(18,2)
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Ensure record exists
    EXEC dbo.sp_CalculateMonthlyRevenue @Year, @Month;
    
    -- Add to raw material cost
    UPDATE dbo.MonthlyRevenue
    SET RawMaterialCost = RawMaterialCost + @Amount,
        UpdatedDate = GETDATE()
    WHERE [Year] = @Year AND [Month] = @Month;
    
    -- Return updated record
    SELECT * FROM dbo.MonthlyRevenue WHERE [Year] = @Year AND [Month] = @Month;
END
GO

PRINT '✅ sp_AddRawMaterialCost created';
GO

-- 2.5: Get Yearly Revenue Report
IF OBJECT_ID('dbo.sp_GetYearlyRevenue', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_GetYearlyRevenue;
GO

CREATE PROCEDURE dbo.sp_GetYearlyRevenue
    @Year INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        RevenueID,
        [Year],
        [Month],
        MonthName,
        SalesIncome,
        DealIncome,
        TotalIncome,
        SalariesPaid,
        TotalSalaries,
        RawMaterialCost,
        MiscExpense,
        TotalExpense,
        NetProfit,
        Notes
    FROM dbo.MonthlyRevenue
    WHERE [Year] = @Year
    ORDER BY [Month];
END
GO

PRINT '✅ sp_GetYearlyRevenue created';
GO

-- 2.6: Get Single Month Revenue
IF OBJECT_ID('dbo.sp_GetMonthRevenue', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_GetMonthRevenue;
GO

CREATE PROCEDURE dbo.sp_GetMonthRevenue
    @Year INT,
    @Month INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Calculate first to ensure data is fresh
    EXEC dbo.sp_CalculateMonthlyRevenue @Year, @Month;
    
    -- Return the record
    SELECT * FROM dbo.MonthlyRevenue WHERE [Year] = @Year AND [Month] = @Month;
END
GO

PRINT '✅ sp_GetMonthRevenue created';
GO

-- 2.7: Reset Misc Expense (if needed)
IF OBJECT_ID('dbo.sp_ResetMiscExpense', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_ResetMiscExpense;
GO

CREATE PROCEDURE dbo.sp_ResetMiscExpense
    @Year INT,
    @Month INT
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE dbo.MonthlyRevenue
    SET MiscExpense = 0,
        Notes = NULL,
        UpdatedDate = GETDATE()
    WHERE [Year] = @Year AND [Month] = @Month;
    
    SELECT * FROM dbo.MonthlyRevenue WHERE [Year] = @Year AND [Month] = @Month;
END
GO

PRINT '✅ sp_ResetMiscExpense created';
GO

-- ================================================================================
-- STEP 3: ADD SAMPLE DATA FOR PAKISTANI GARMENT FACTORY
-- ================================================================================
PRINT '';
PRINT 'Step 3: Adding sample data...';
GO

-- 3.1: Sample Monthly Revenue Data for 2024 & 2025
INSERT INTO dbo.MonthlyRevenue ([Year], [Month], MonthName, SalesIncome, DealIncome, SalariesPaid, TotalSalaries, RawMaterialCost, MiscExpense, Notes)
VALUES
-- 2024 Data
(2024, 1, 'January', 450000, 120000, 1, 180000, 85000, 25000, 'Eid preparation season'),
(2024, 2, 'February', 380000, 95000, 1, 180000, 72000, 18000, 'Regular month'),
(2024, 3, 'March', 520000, 180000, 1, 180000, 95000, 22000, 'Pre-Ramadan orders'),
(2024, 4, 'April', 680000, 250000, 1, 185000, 120000, 35000, 'Eid-ul-Fitr rush'),
(2024, 5, 'May', 420000, 110000, 1, 185000, 78000, 20000, 'Post-Eid slowdown'),
(2024, 6, 'June', 390000, 85000, 1, 185000, 70000, 18000, 'Summer season'),
(2024, 7, 'July', 480000, 150000, 1, 190000, 88000, 22000, 'Independence Day orders'),
(2024, 8, 'August', 550000, 200000, 1, 190000, 105000, 28000, 'August 14 celebrations'),
(2024, 9, 'September', 620000, 180000, 1, 190000, 110000, 30000, 'Eid-ul-Adha preparation'),
(2024, 10, 'October', 580000, 160000, 1, 195000, 100000, 25000, 'Post-Eid, wedding season starts'),
(2024, 11, 'November', 720000, 280000, 1, 195000, 135000, 40000, 'Wedding season peak'),
(2024, 12, 'December', 650000, 220000, 1, 200000, 120000, 35000, 'Year-end orders'),

-- 2025 Data (current year)
(2025, 1, 'January', 480000, 130000, 1, 200000, 90000, 28000, 'New year orders'),
(2025, 2, 'February', 420000, 100000, 1, 200000, 78000, 22000, 'Valentine collections'),
(2025, 3, 'March', 580000, 200000, 1, 205000, 110000, 30000, 'Ramadan preparation'),
(2025, 4, 'April', 750000, 320000, 1, 205000, 145000, 45000, 'Eid-ul-Fitr peak'),
(2025, 5, 'May', 450000, 120000, 1, 205000, 85000, 25000, 'Post-Eid'),
(2025, 6, 'June', 400000, 95000, 1, 210000, 75000, 20000, 'Summer slow'),
(2025, 7, 'July', 520000, 160000, 1, 210000, 95000, 28000, 'Independence prep'),
(2025, 8, 'August', 600000, 220000, 1, 210000, 115000, 32000, 'August 14 peak'),
(2025, 9, 'September', 550000, 180000, 1, 215000, 100000, 28000, 'Eid-ul-Adha'),
(2025, 10, 'October', 620000, 200000, 1, 215000, 115000, 30000, 'Wedding season'),
(2025, 11, 'November', 780000, 350000, 1, 220000, 150000, 45000, 'Wedding peak'),
(2025, 12, 'December', 700000, 280000, 0, 0, 130000, 38000, 'December - salaries pending');

PRINT '✅ Sample monthly revenue data added for 2024 & 2025';
GO

-- ================================================================================
-- STEP 4: VERIFY INSTALLATION
-- ================================================================================
PRINT '';
PRINT '========================================';
PRINT 'VERIFICATION';
PRINT '========================================';

-- Check table
IF OBJECT_ID('dbo.MonthlyRevenue', 'U') IS NOT NULL
    PRINT '✅ Table: MonthlyRevenue exists';
ELSE
    PRINT '❌ Table: MonthlyRevenue MISSING';

-- Check procedures
IF OBJECT_ID('dbo.sp_CalculateMonthlyRevenue', 'P') IS NOT NULL
    PRINT '✅ Procedure: sp_CalculateMonthlyRevenue exists';
    
IF OBJECT_ID('dbo.sp_PayMonthlySalaries', 'P') IS NOT NULL
    PRINT '✅ Procedure: sp_PayMonthlySalaries exists';
    
IF OBJECT_ID('dbo.sp_AddMiscExpense', 'P') IS NOT NULL
    PRINT '✅ Procedure: sp_AddMiscExpense exists';
    
IF OBJECT_ID('dbo.sp_AddRawMaterialCost', 'P') IS NOT NULL
    PRINT '✅ Procedure: sp_AddRawMaterialCost exists';
    
IF OBJECT_ID('dbo.sp_GetYearlyRevenue', 'P') IS NOT NULL
    PRINT '✅ Procedure: sp_GetYearlyRevenue exists';
    
IF OBJECT_ID('dbo.sp_GetMonthRevenue', 'P') IS NOT NULL
    PRINT '✅ Procedure: sp_GetMonthRevenue exists';

-- Show sample data
PRINT '';
PRINT 'Sample Data for 2025:';
SELECT [Month], MonthName, 
       FORMAT(TotalIncome, 'N0') AS Income,
       FORMAT(TotalExpense, 'N0') AS Expense,
       FORMAT(NetProfit, 'N0') AS Profit,
       CASE WHEN SalariesPaid = 1 THEN 'Paid' ELSE 'Pending' END AS Salary
FROM dbo.MonthlyRevenue 
WHERE [Year] = 2025
ORDER BY [Month];

PRINT '';
PRINT '========================================';
PRINT '✅ REVENUE SYSTEM CREATED SUCCESSFULLY!';
PRINT '========================================';
GO
