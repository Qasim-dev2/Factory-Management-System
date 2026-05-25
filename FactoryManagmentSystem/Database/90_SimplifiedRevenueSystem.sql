-- ================================================================================
-- SIMPLIFIED REVENUE SYSTEM
-- Track purchases, expenses, and calculate profit for any date range
-- ================================================================================
USE GarmentsFactoryDB;
GO

PRINT '========================================';
PRINT 'CREATING SIMPLIFIED REVENUE SYSTEM';
PRINT '========================================';

-- ================================================================================
-- STEP 1: CREATE RAW MATERIAL PURCHASE TABLE
-- ================================================================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'RawMaterialPurchase')
BEGIN
    CREATE TABLE RawMaterialPurchase (
        PurchaseID INT PRIMARY KEY IDENTITY(1,1),
        RawMaterialID INT NULL,
        MaterialName NVARCHAR(100) NOT NULL,
        PurchaseDate DATE NOT NULL DEFAULT GETDATE(),
        Quantity DECIMAL(18,2) NOT NULL,
        Unit NVARCHAR(20) NULL,
        UnitPrice DECIMAL(18,2) NOT NULL,
        TotalAmount DECIMAL(18,2) NOT NULL,
        SupplierName NVARCHAR(100) NULL,
        InvoiceNumber NVARCHAR(50) NULL,
        Notes NVARCHAR(500) NULL,
        CreatedDate DATETIME DEFAULT GETDATE(),
        
        CONSTRAINT FK_RawMaterialPurchase_Material FOREIGN KEY (RawMaterialID) 
            REFERENCES RawMaterial(RawMaterialID)
    );
    PRINT '✅ RawMaterialPurchase table created';
END
ELSE
    PRINT '⏭️ RawMaterialPurchase table already exists';
GO

CREATE INDEX IX_RawMaterialPurchase_Date ON RawMaterialPurchase(PurchaseDate);
GO

-- ================================================================================
-- STEP 2: CREATE MISC EXPENSE TABLE
-- ================================================================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'MiscExpense')
BEGIN
    CREATE TABLE MiscExpense (
        ExpenseID INT PRIMARY KEY IDENTITY(1,1),
        ExpenseDate DATE NOT NULL DEFAULT GETDATE(),
        Amount DECIMAL(18,2) NOT NULL,
        Category NVARCHAR(50) NULL,
        Description NVARCHAR(500) NULL,
        PaidTo NVARCHAR(100) NULL,
        PaymentMethod NVARCHAR(50) NULL,
        ReceiptNumber NVARCHAR(50) NULL,
        CreatedDate DATETIME DEFAULT GETDATE()
    );
    PRINT '✅ MiscExpense table created';
END
ELSE
    PRINT '⏭️ MiscExpense table already exists';
GO

CREATE INDEX IX_MiscExpense_Date ON MiscExpense(ExpenseDate);
GO

-- ================================================================================
-- STEP 3: CREATE SALARY PAYMENT TABLE (Optional - for tracking paid salaries)
-- ================================================================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'SalaryPayment')
BEGIN
    CREATE TABLE SalaryPayment (
        PaymentID INT PRIMARY KEY IDENTITY(1,1),
        PaymentDate DATE NOT NULL DEFAULT GETDATE(),
        PaymentMonth INT NOT NULL,
        PaymentYear INT NOT NULL,
        TotalAmount DECIMAL(18,2) NOT NULL,
        EmployeeCount INT NOT NULL,
        Notes NVARCHAR(500) NULL,
        CreatedDate DATETIME DEFAULT GETDATE(),
        
        CONSTRAINT UQ_SalaryPayment_MonthYear UNIQUE(PaymentMonth, PaymentYear)
    );
    PRINT '✅ SalaryPayment table created';
END
ELSE
    PRINT '⏭️ SalaryPayment table already exists';
GO

-- ================================================================================
-- STEP 4: CREATE STORED PROCEDURES
-- ================================================================================
PRINT 'Creating stored procedures...';
GO

-- 4.1: Get Revenue Summary for Date Range
IF OBJECT_ID('sp_GetRevenueByDateRange', 'P') IS NOT NULL DROP PROCEDURE sp_GetRevenueByDateRange;
GO

CREATE PROCEDURE sp_GetRevenueByDateRange
    @StartDate DATE,
    @EndDate DATE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Sales Income
    DECLARE @SalesIncome DECIMAL(18,2) = (
        SELECT ISNULL(SUM(TotalAmount), 0) 
        FROM SalesOrder 
        WHERE CAST(OrderDate AS DATE) BETWEEN @StartDate AND @EndDate
          AND Status IN ('Delivered', 'Completed', 'Shipped', 'Confirmed', 'Approved')
    );
    
    -- Deal Income
    DECLARE @DealIncome DECIMAL(18,2) = (
        SELECT ISNULL(SUM(TotalAmount), 0) 
        FROM Deal 
        WHERE StartDate BETWEEN @StartDate AND @EndDate
          AND Status IN ('Completed', 'Approved', 'Active', 'Finalized')
    );
    
    -- Raw Material Purchases
    DECLARE @RawMaterialCost DECIMAL(18,2) = (
        SELECT ISNULL(SUM(TotalAmount), 0) 
        FROM RawMaterialPurchase 
        WHERE PurchaseDate BETWEEN @StartDate AND @EndDate
    );
    
    -- Misc Expenses
    DECLARE @MiscExpense DECIMAL(18,2) = (
        SELECT ISNULL(SUM(Amount), 0) 
        FROM MiscExpense 
        WHERE ExpenseDate BETWEEN @StartDate AND @EndDate
    );
    
    -- Salary (for the months in the date range)
    DECLARE @Salary DECIMAL(18,2) = (
        SELECT ISNULL(SUM(TotalAmount), 0) 
        FROM SalaryPayment 
        WHERE PaymentDate BETWEEN @StartDate AND @EndDate
    );
    
    -- Return summary
    SELECT 
        @StartDate AS StartDate,
        @EndDate AS EndDate,
        @SalesIncome AS SalesIncome,
        @DealIncome AS DealIncome,
        (@SalesIncome + @DealIncome) AS TotalIncome,
        @RawMaterialCost AS RawMaterialCost,
        @MiscExpense AS MiscExpense,
        @Salary AS SalaryExpense,
        (@RawMaterialCost + @MiscExpense + @Salary) AS TotalExpense,
        (@SalesIncome + @DealIncome - @RawMaterialCost - @MiscExpense - @Salary) AS NetProfit;
END
GO

PRINT '✅ sp_GetRevenueByDateRange created';
GO

-- 4.2: Get Sales Orders in Date Range
IF OBJECT_ID('sp_GetSalesOrdersByDateRange', 'P') IS NOT NULL DROP PROCEDURE sp_GetSalesOrdersByDateRange;
GO

CREATE PROCEDURE sp_GetSalesOrdersByDateRange
    @StartDate DATE,
    @EndDate DATE
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        so.SalesOrderID,
        so.OrderDate,
        r.CompanyName AS RetailerName,
        so.Status,
        so.TotalAmount
    FROM SalesOrder so
    LEFT JOIN Retailer r ON so.RetailerID = r.RetailerID
    WHERE CAST(so.OrderDate AS DATE) BETWEEN @StartDate AND @EndDate
      AND so.Status IN ('Delivered', 'Completed', 'Shipped', 'Confirmed', 'Approved')
    ORDER BY so.OrderDate DESC;
END
GO

PRINT '✅ sp_GetSalesOrdersByDateRange created';
GO

-- 4.3: Get Deals in Date Range
IF OBJECT_ID('sp_GetDealsByDateRange', 'P') IS NOT NULL DROP PROCEDURE sp_GetDealsByDateRange;
GO

CREATE PROCEDURE sp_GetDealsByDateRange
    @StartDate DATE,
    @EndDate DATE
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        DealID,
        DealTitle,
        ClientName,
        StartDate,
        Status,
        TotalAmount
    FROM Deal
    WHERE StartDate BETWEEN @StartDate AND @EndDate
      AND Status IN ('Completed', 'Approved', 'Active', 'Finalized')
    ORDER BY StartDate DESC;
END
GO

PRINT '✅ sp_GetDealsByDateRange created';
GO

-- 4.4: Get Raw Material Purchases in Date Range
IF OBJECT_ID('sp_GetPurchasesByDateRange', 'P') IS NOT NULL DROP PROCEDURE sp_GetPurchasesByDateRange;
GO

CREATE PROCEDURE sp_GetPurchasesByDateRange
    @StartDate DATE,
    @EndDate DATE
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        PurchaseID,
        MaterialName,
        PurchaseDate,
        Quantity,
        Unit,
        UnitPrice,
        TotalAmount,
        SupplierName
    FROM RawMaterialPurchase
    WHERE PurchaseDate BETWEEN @StartDate AND @EndDate
    ORDER BY PurchaseDate DESC;
END
GO

PRINT '✅ sp_GetPurchasesByDateRange created';
GO

-- 4.5: Get Misc Expenses in Date Range
IF OBJECT_ID('sp_GetExpensesByDateRange', 'P') IS NOT NULL DROP PROCEDURE sp_GetExpensesByDateRange;
GO

CREATE PROCEDURE sp_GetExpensesByDateRange
    @StartDate DATE,
    @EndDate DATE
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        ExpenseID,
        ExpenseDate,
        Category,
        Description,
        Amount,
        PaidTo
    FROM MiscExpense
    WHERE ExpenseDate BETWEEN @StartDate AND @EndDate
    ORDER BY ExpenseDate DESC;
END
GO

PRINT '✅ sp_GetExpensesByDateRange created';
GO

-- 4.6: Add Raw Material Purchase
IF OBJECT_ID('sp_AddRawMaterialPurchase', 'P') IS NOT NULL DROP PROCEDURE sp_AddRawMaterialPurchase;
GO

CREATE PROCEDURE sp_AddRawMaterialPurchase
    @MaterialName NVARCHAR(100),
    @PurchaseDate DATE,
    @Quantity DECIMAL(18,2),
    @Unit NVARCHAR(20),
    @UnitPrice DECIMAL(18,2),
    @SupplierName NVARCHAR(100) = NULL,
    @InvoiceNumber NVARCHAR(50) = NULL,
    @Notes NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @TotalAmount DECIMAL(18,2) = @Quantity * @UnitPrice;
    
    INSERT INTO RawMaterialPurchase (MaterialName, PurchaseDate, Quantity, Unit, UnitPrice, TotalAmount, SupplierName, InvoiceNumber, Notes)
    VALUES (@MaterialName, @PurchaseDate, @Quantity, @Unit, @UnitPrice, @TotalAmount, @SupplierName, @InvoiceNumber, @Notes);
    
    SELECT SCOPE_IDENTITY() AS PurchaseID, @TotalAmount AS TotalAmount;
END
GO

PRINT '✅ sp_AddRawMaterialPurchase created';
GO

-- 4.7: Add Misc Expense
IF OBJECT_ID('sp_AddMiscExpense', 'P') IS NOT NULL DROP PROCEDURE sp_AddMiscExpense;
GO

CREATE PROCEDURE sp_AddMiscExpense
    @ExpenseDate DATE,
    @Amount DECIMAL(18,2),
    @Category NVARCHAR(50) = NULL,
    @Description NVARCHAR(500) = NULL,
    @PaidTo NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO MiscExpense (ExpenseDate, Amount, Category, Description, PaidTo)
    VALUES (@ExpenseDate, @Amount, @Category, @Description, @PaidTo);
    
    SELECT SCOPE_IDENTITY() AS ExpenseID;
END
GO

PRINT '✅ sp_AddMiscExpense created';
GO

-- 4.8: Pay Monthly Salary
IF OBJECT_ID('sp_PayMonthlySalary', 'P') IS NOT NULL DROP PROCEDURE sp_PayMonthlySalary;
GO

CREATE PROCEDURE sp_PayMonthlySalary
    @Month INT,
    @Year INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Check if already paid
    IF EXISTS (SELECT 1 FROM SalaryPayment WHERE PaymentMonth = @Month AND PaymentYear = @Year)
    BEGIN
        SELECT 'Already Paid' AS Status, 0 AS TotalAmount, 0 AS EmployeeCount;
        RETURN;
    END
    
    -- Calculate total salary
    DECLARE @TotalSalary DECIMAL(18,2) = (SELECT ISNULL(SUM(Salary), 0) FROM Employee WHERE IsActive = 1);
    DECLARE @EmpCount INT = (SELECT COUNT(*) FROM Employee WHERE IsActive = 1 AND Salary > 0);
    DECLARE @PayDate DATE = DATEFROMPARTS(@Year, @Month, 1);
    
    -- Insert payment record
    INSERT INTO SalaryPayment (PaymentDate, PaymentMonth, PaymentYear, TotalAmount, EmployeeCount)
    VALUES (@PayDate, @Month, @Year, @TotalSalary, @EmpCount);
    
    SELECT 'Paid' AS Status, @TotalSalary AS TotalAmount, @EmpCount AS EmployeeCount;
END
GO

PRINT '✅ sp_PayMonthlySalary created';
GO

-- 4.9: Get Current Month Salary Status
IF OBJECT_ID('sp_GetMonthlySalaryStatus', 'P') IS NOT NULL DROP PROCEDURE sp_GetMonthlySalaryStatus;
GO

CREATE PROCEDURE sp_GetMonthlySalaryStatus
    @Month INT,
    @Year INT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @TotalSalary DECIMAL(18,2) = (SELECT ISNULL(SUM(Salary), 0) FROM Employee WHERE IsActive = 1);
    DECLARE @EmpCount INT = (SELECT COUNT(*) FROM Employee WHERE IsActive = 1 AND Salary > 0);
    
    SELECT 
        @Month AS [Month],
        @Year AS [Year],
        @TotalSalary AS TotalSalary,
        @EmpCount AS EmployeeCount,
        CASE WHEN EXISTS (SELECT 1 FROM SalaryPayment WHERE PaymentMonth = @Month AND PaymentYear = @Year)
             THEN 1 ELSE 0 END AS IsPaid;
END
GO

PRINT '✅ sp_GetMonthlySalaryStatus created';
GO

-- ================================================================================
-- STEP 5: INSERT SAMPLE DATA
-- ================================================================================
PRINT 'Inserting sample data...';
GO

-- Sample Raw Material Purchases (Oct-Dec 2025)
INSERT INTO RawMaterialPurchase (MaterialName, PurchaseDate, Quantity, Unit, UnitPrice, TotalAmount, SupplierName, Notes) VALUES
('Cotton Fabric - White', '2025-10-05', 500, 'Meters', 280, 140000, 'Al-Madina Textiles', 'October stock'),
('Thread - White', '2025-10-10', 100, 'Spools', 45, 4500, 'Thread Masters', 'October supply'),
('Buttons - White', '2025-10-15', 50, 'Dozen', 60, 3000, 'Button World', 'For formal shirts'),
('Cotton Fabric - Blue', '2025-11-02', 400, 'Meters', 300, 120000, 'Al-Madina Textiles', 'November order'),
('Denim Fabric', '2025-11-10', 200, 'Meters', 520, 104000, 'Denim House', 'For jeans production'),
('Zippers - 7 inch', '2025-11-18', 200, 'Pieces', 35, 7000, 'Zipper Zone', 'November stock'),
('Cotton Fabric - White', '2025-12-01', 600, 'Meters', 280, 168000, 'Al-Madina Textiles', 'December stock'),
('Lawn Fabric - Printed', '2025-12-05', 300, 'Meters', 450, 135000, 'Gul Ahmed Fabrics', 'For kurtas');

PRINT '✅ 8 Raw Material Purchases inserted';
GO

-- Sample Misc Expenses (Oct-Dec 2025)
INSERT INTO MiscExpense (ExpenseDate, Amount, Category, Description, PaidTo) VALUES
('2025-10-05', 15000, 'Utilities', 'Electricity Bill - October', 'LESCO'),
('2025-10-10', 8000, 'Utilities', 'Gas Bill - October', 'SNGPL'),
('2025-10-15', 5000, 'Maintenance', 'Sewing Machine Repair', 'Technician'),
('2025-10-20', 12000, 'Transport', 'Delivery Van Fuel', 'Petrol Station'),
('2025-11-05', 16000, 'Utilities', 'Electricity Bill - November', 'LESCO'),
('2025-11-08', 9000, 'Utilities', 'Gas Bill - November', 'SNGPL'),
('2025-11-15', 25000, 'Rent', 'Warehouse Rent', 'Landlord'),
('2025-11-22', 8000, 'Maintenance', 'Generator Service', 'Mechanic'),
('2025-12-03', 18000, 'Utilities', 'Electricity Bill - December', 'LESCO'),
('2025-12-08', 10000, 'Utilities', 'Gas Bill - December', 'SNGPL'),
('2025-12-10', 30000, 'Bonus', 'Staff Year-End Bonus', 'Employees');

PRINT '✅ 11 Misc Expenses inserted';
GO

-- Sample Salary Payments
INSERT INTO SalaryPayment (PaymentDate, PaymentMonth, PaymentYear, TotalAmount, EmployeeCount, Notes) VALUES
('2025-10-01', 10, 2025, 450000, 15, 'October Salaries'),
('2025-11-01', 11, 2025, 450000, 15, 'November Salaries');
-- December not paid yet

PRINT '✅ 2 Salary Payments inserted (Oct, Nov - Dec pending)';
GO

-- ================================================================================
-- VERIFICATION
-- ================================================================================
PRINT '';
PRINT '========================================';
PRINT 'TESTING DATE RANGE QUERY';
PRINT '========================================';

-- Test for November 2025
EXEC sp_GetRevenueByDateRange '2025-11-01', '2025-11-30';
GO

PRINT '';
PRINT '✅ SIMPLIFIED REVENUE SYSTEM READY!';
PRINT '========================================';
GO
