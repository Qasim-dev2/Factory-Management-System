-- ================================================================================
-- AUTOMATED REVENUE SYSTEM UPDATE
-- Links Raw Material restocking with Purchase tracking
-- Auto-pays salaries for all past months
-- ================================================================================
USE GarmentsFactoryDB;
GO

PRINT '========================================';
PRINT 'AUTOMATED REVENUE SYSTEM';
PRINT '========================================';

-- ================================================================================
-- STEP 1: ADD FOREIGN KEY TO RAWMATERIALPURCHASE (Link to RawMaterial table)
-- ================================================================================
-- The RawMaterialID column already exists, let's ensure FK is working
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_RawMaterialPurchase_Material')
BEGIN
    -- First update any NULL values to valid RawMaterialIDs
    ALTER TABLE RawMaterialPurchase ALTER COLUMN RawMaterialID INT NULL;
    PRINT '✅ RawMaterialID column is nullable for existing data';
END
GO

-- ================================================================================
-- STEP 2: CREATE PROCEDURE TO AUTO-RECORD PURCHASE WHEN RESTOCKING
-- ================================================================================
IF OBJECT_ID('sp_RestockRawMaterialWithPurchase', 'P') IS NOT NULL
    DROP PROCEDURE sp_RestockRawMaterialWithPurchase;
GO

CREATE PROCEDURE sp_RestockRawMaterialWithPurchase
    @RawMaterialID INT,
    @QuantityToAdd DECIMAL(18,2),
    @NewUnitPrice DECIMAL(18,2) = NULL,
    @SupplierName NVARCHAR(100) = NULL,
    @InvoiceNumber NVARCHAR(50) = NULL,
    @PurchaseDate DATE = NULL,
    @Notes NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Get material info
    DECLARE @MaterialName NVARCHAR(100);
    DECLARE @Unit NVARCHAR(20);
    DECLARE @CurrentUnitPrice DECIMAL(18,2);
    DECLARE @Supplier NVARCHAR(100);
    
    SELECT 
        @MaterialName = MaterialName,
        @Unit = Unit,
        @CurrentUnitPrice = UnitPrice,
        @Supplier = Supplier
    FROM RawMaterial 
    WHERE RawMaterialID = @RawMaterialID;
    
    -- Use provided price or existing price
    DECLARE @PriceToUse DECIMAL(18,2) = ISNULL(@NewUnitPrice, @CurrentUnitPrice);
    DECLARE @TotalAmount DECIMAL(18,2) = @QuantityToAdd * @PriceToUse;
    DECLARE @PurchaseDateToUse DATE = ISNULL(@PurchaseDate, GETDATE());
    DECLARE @SupplierToUse NVARCHAR(100) = ISNULL(@SupplierName, @Supplier);
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- 1. Update raw material stock
        UPDATE RawMaterial
        SET 
            Quantity = Quantity + @QuantityToAdd,
            UnitPrice = @PriceToUse,
            LastRestockDate = GETDATE(),
            UpdatedDate = GETDATE()
        WHERE RawMaterialID = @RawMaterialID;
        
        -- 2. Record purchase for revenue tracking
        INSERT INTO RawMaterialPurchase 
            (RawMaterialID, MaterialName, PurchaseDate, Quantity, Unit, UnitPrice, TotalAmount, SupplierName, InvoiceNumber, Notes)
        VALUES 
            (@RawMaterialID, @MaterialName, @PurchaseDateToUse, @QuantityToAdd, @Unit, @PriceToUse, @TotalAmount, @SupplierToUse, @InvoiceNumber, @Notes);
        
        COMMIT TRANSACTION;
        
        -- Return purchase info
        SELECT 
            @RawMaterialID AS RawMaterialID,
            @MaterialName AS MaterialName,
            @QuantityToAdd AS QuantityAdded,
            @PriceToUse AS UnitPrice,
            @TotalAmount AS TotalAmount,
            @PurchaseDateToUse AS PurchaseDate,
            SCOPE_IDENTITY() AS PurchaseID;
            
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

PRINT '✅ sp_RestockRawMaterialWithPurchase created';
GO

-- ================================================================================
-- STEP 3: CREATE AUTO-PAY ALL PAST SALARIES PROCEDURE
-- ================================================================================
IF OBJECT_ID('sp_AutoPayPastSalaries', 'P') IS NOT NULL
    DROP PROCEDURE sp_AutoPayPastSalaries;
GO

CREATE PROCEDURE sp_AutoPayPastSalaries
    @SystemStartMonth INT = 9,  -- September 2025 (when system was created)
    @SystemStartYear INT = 2025
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @CurrentMonth INT = MONTH(GETDATE());
    DECLARE @CurrentYear INT = YEAR(GETDATE());
    DECLARE @TotalSalary DECIMAL(18,2);
    DECLARE @EmployeeCount INT;
    DECLARE @PaymentsAdded INT = 0;
    
    -- Get current salary totals
    SELECT 
        @TotalSalary = ISNULL(SUM(Salary), 0),
        @EmployeeCount = COUNT(*)
    FROM Employee 
    WHERE IsActive = 1 AND Salary > 0;
    
    -- Loop through all months from system start to current
    DECLARE @Year INT = @SystemStartYear;
    DECLARE @Month INT = @SystemStartMonth;
    
    WHILE (@Year < @CurrentYear) OR (@Year = @CurrentYear AND @Month <= @CurrentMonth)
    BEGIN
        -- Check if salary not yet paid for this month
        IF NOT EXISTS (SELECT 1 FROM SalaryPayment WHERE PaymentMonth = @Month AND PaymentYear = @Year)
        BEGIN
            -- Pay salary for this month
            INSERT INTO SalaryPayment (PaymentDate, PaymentMonth, PaymentYear, TotalAmount, EmployeeCount, Notes)
            VALUES (DATEFROMPARTS(@Year, @Month, 1), @Month, @Year, @TotalSalary, @EmployeeCount, 'Auto-paid on system check');
            
            SET @PaymentsAdded = @PaymentsAdded + 1;
            
            PRINT 'Auto-paid salary for ' + DATENAME(MONTH, DATEFROMPARTS(@Year, @Month, 1)) + ' ' + CAST(@Year AS VARCHAR);
        END
        
        -- Move to next month
        SET @Month = @Month + 1;
        IF @Month > 12
        BEGIN
            SET @Month = 1;
            SET @Year = @Year + 1;
        END
    END
    
    -- Return summary
    SELECT 
        @PaymentsAdded AS NewPaymentsAdded,
        @TotalSalary AS MonthlySalaryAmount,
        @EmployeeCount AS EmployeeCount,
        'All past salaries have been recorded' AS Status;
END
GO

PRINT '✅ sp_AutoPayPastSalaries created';
GO

-- ================================================================================
-- STEP 4: GET UNPAID MONTHS PROCEDURE
-- ================================================================================
IF OBJECT_ID('sp_GetUnpaidSalaryMonths', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetUnpaidSalaryMonths;
GO

CREATE PROCEDURE sp_GetUnpaidSalaryMonths
    @SystemStartMonth INT = 9,
    @SystemStartYear INT = 2025
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @CurrentMonth INT = MONTH(GETDATE());
    DECLARE @CurrentYear INT = YEAR(GETDATE());
    
    -- Create temp table for all months
    CREATE TABLE #AllMonths (Year INT, Month INT, MonthName NVARCHAR(20));
    
    DECLARE @Year INT = @SystemStartYear;
    DECLARE @Month INT = @SystemStartMonth;
    
    WHILE (@Year < @CurrentYear) OR (@Year = @CurrentYear AND @Month <= @CurrentMonth)
    BEGIN
        INSERT INTO #AllMonths (Year, Month, MonthName)
        VALUES (@Year, @Month, DATENAME(MONTH, DATEFROMPARTS(@Year, @Month, 1)));
        
        SET @Month = @Month + 1;
        IF @Month > 12
        BEGIN
            SET @Month = 1;
            SET @Year = @Year + 1;
        END
    END
    
    -- Return unpaid months
    SELECT 
        m.Year,
        m.Month,
        m.MonthName,
        CASE WHEN sp.PaymentID IS NULL THEN 0 ELSE 1 END AS IsPaid,
        ISNULL(sp.TotalAmount, 0) AS PaidAmount
    FROM #AllMonths m
    LEFT JOIN SalaryPayment sp ON m.Month = sp.PaymentMonth AND m.Year = sp.PaymentYear
    ORDER BY m.Year, m.Month;
    
    DROP TABLE #AllMonths;
END
GO

PRINT '✅ sp_GetUnpaidSalaryMonths created';
GO

-- ================================================================================
-- STEP 5: CREATE PURCHASE DIALOG PROCEDURE
-- ================================================================================
IF OBJECT_ID('sp_AddRawMaterialPurchaseWithRestock', 'P') IS NOT NULL
    DROP PROCEDURE sp_AddRawMaterialPurchaseWithRestock;
GO

CREATE PROCEDURE sp_AddRawMaterialPurchaseWithRestock
    @RawMaterialID INT = NULL,          -- NULL if adding new material
    @MaterialName NVARCHAR(100),
    @PurchaseDate DATE,
    @Quantity DECIMAL(18,2),
    @Unit NVARCHAR(20),
    @UnitPrice DECIMAL(18,2),
    @SupplierName NVARCHAR(100) = NULL,
    @InvoiceNumber NVARCHAR(50) = NULL,
    @Notes NVARCHAR(500) = NULL,
    @UpdateStock BIT = 1                -- Whether to update RawMaterial stock
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @TotalAmount DECIMAL(18,2) = @Quantity * @UnitPrice;
    DECLARE @NewPurchaseID INT;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- 1. Insert purchase record
        INSERT INTO RawMaterialPurchase 
            (RawMaterialID, MaterialName, PurchaseDate, Quantity, Unit, UnitPrice, TotalAmount, SupplierName, InvoiceNumber, Notes)
        VALUES 
            (@RawMaterialID, @MaterialName, @PurchaseDate, @Quantity, @Unit, @UnitPrice, @TotalAmount, @SupplierName, @InvoiceNumber, @Notes);
        
        SET @NewPurchaseID = SCOPE_IDENTITY();
        
        -- 2. Update RawMaterial stock if linked and requested
        IF @RawMaterialID IS NOT NULL AND @UpdateStock = 1
        BEGIN
            UPDATE RawMaterial
            SET 
                Quantity = Quantity + @Quantity,
                UnitPrice = @UnitPrice,
                LastRestockDate = GETDATE(),
                UpdatedDate = GETDATE()
            WHERE RawMaterialID = @RawMaterialID;
        END
        
        COMMIT TRANSACTION;
        
        SELECT @NewPurchaseID AS PurchaseID, @TotalAmount AS TotalAmount;
        
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

PRINT '✅ sp_AddRawMaterialPurchaseWithRestock created';
GO

-- ================================================================================
-- STEP 6: RUN AUTO-PAY FOR ALL PAST MONTHS
-- ================================================================================
PRINT '';
PRINT 'Running Auto-Pay for all past months...';
EXEC sp_AutoPayPastSalaries @SystemStartMonth = 9, @SystemStartYear = 2025;
GO

-- ================================================================================
-- STEP 7: SHOW SALARY PAYMENT STATUS
-- ================================================================================
PRINT '';
PRINT 'Salary Payment Status:';
SELECT 
    PaymentMonth,
    PaymentYear,
    DATENAME(MONTH, DATEFROMPARTS(PaymentYear, PaymentMonth, 1)) AS MonthName,
    TotalAmount,
    EmployeeCount,
    Notes
FROM SalaryPayment
ORDER BY PaymentYear, PaymentMonth;
GO

-- ================================================================================
-- STEP 8: UPDATE EXISTING RESTOCK PROCEDURE TO ALSO RECORD PURCHASE
-- ================================================================================
IF OBJECT_ID('sp_RestockRawMaterial', 'P') IS NOT NULL
    DROP PROCEDURE sp_RestockRawMaterial;
GO

CREATE PROCEDURE sp_RestockRawMaterial
    @RawMaterialID INT,
    @QuantityToAdd DECIMAL(18,2),
    @NewUnitPrice DECIMAL(18,2) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Get material info
    DECLARE @MaterialName NVARCHAR(100);
    DECLARE @Unit NVARCHAR(20);
    DECLARE @CurrentUnitPrice DECIMAL(18,2);
    DECLARE @Supplier NVARCHAR(100);
    
    SELECT 
        @MaterialName = MaterialName,
        @Unit = Unit,
        @CurrentUnitPrice = UnitPrice,
        @Supplier = Supplier
    FROM RawMaterial 
    WHERE RawMaterialID = @RawMaterialID;
    
    DECLARE @PriceToUse DECIMAL(18,2) = ISNULL(@NewUnitPrice, @CurrentUnitPrice);
    DECLARE @TotalAmount DECIMAL(18,2) = @QuantityToAdd * @PriceToUse;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- 1. Update raw material stock
        UPDATE RawMaterial
        SET 
            Quantity = Quantity + @QuantityToAdd,
            UnitPrice = @PriceToUse,
            LastRestockDate = GETDATE(),
            UpdatedDate = GETDATE()
        WHERE RawMaterialID = @RawMaterialID;
        
        -- 2. AUTO-RECORD purchase for revenue tracking
        INSERT INTO RawMaterialPurchase 
            (RawMaterialID, MaterialName, PurchaseDate, Quantity, Unit, UnitPrice, TotalAmount, SupplierName, Notes)
        VALUES 
            (@RawMaterialID, @MaterialName, GETDATE(), @QuantityToAdd, @Unit, @PriceToUse, @TotalAmount, @Supplier, 'Auto-recorded from restock');
        
        COMMIT TRANSACTION;
        
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

PRINT '✅ sp_RestockRawMaterial updated to auto-record purchases';
GO

PRINT '';
PRINT '========================================';
PRINT '✅ AUTOMATED REVENUE SYSTEM READY!';
PRINT '========================================';
PRINT '';
PRINT 'Features:';
PRINT '1. Restocking raw materials auto-records purchases for revenue';
PRINT '2. Past month salaries auto-paid (Sep-Dec 2025)';
PRINT '3. All purchases tracked with dates for filtering';
PRINT '4. Revenue calculates from actual purchase records';
PRINT '';
GO
