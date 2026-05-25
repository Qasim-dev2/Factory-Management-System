-- ================================================================================
-- AUTOMATED REVENUE INTEGRATION
-- Links Raw Material, Sales Orders, and Deals to Revenue
-- ================================================================================
USE GarmentsFactoryDB;
GO

PRINT '========================================';
PRINT 'AUTOMATED REVENUE INTEGRATION';
PRINT '========================================';

-- ================================================================================
-- STEP 1: UPDATE sp_CreateRawMaterial to AUTO-RECORD PURCHASE
-- ================================================================================
IF OBJECT_ID('sp_CreateRawMaterial', 'P') IS NOT NULL
    DROP PROCEDURE sp_CreateRawMaterial;
GO

CREATE PROCEDURE sp_CreateRawMaterial
    @MaterialName NVARCHAR(100),
    @Category NVARCHAR(50) = NULL,
    @Unit NVARCHAR(20) = NULL,
    @Quantity DECIMAL(18,2) = 0,
    @MinimumStock DECIMAL(18,2) = 0,
    @UnitPrice DECIMAL(18,2) = 0,
    @Supplier NVARCHAR(100) = NULL,
    @SupplierContact NVARCHAR(100) = NULL,
    @Description NVARCHAR(500) = NULL,
    @RawMaterialID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validate material name
        IF @MaterialName IS NULL OR LTRIM(RTRIM(@MaterialName)) = ''
        BEGIN
            RAISERROR('Material name is required.', 16, 1);
            RETURN;
        END

        -- Check for duplicate material name
        IF EXISTS (SELECT 1 FROM RawMaterial WHERE MaterialName = @MaterialName AND IsActive = 1)
        BEGIN
            RAISERROR('Material with this name already exists.', 16, 1);
            RETURN;
        END

        -- Insert Raw Material
        INSERT INTO RawMaterial (
            MaterialName, Category, Unit, Quantity, MinimumStock, UnitPrice,
            Supplier, SupplierContact, Description, LastRestockDate, IsActive, CreatedDate
        )
        VALUES (
            @MaterialName, @Category, @Unit, @Quantity, @MinimumStock, @UnitPrice,
            @Supplier, @SupplierContact, @Description,
            CASE WHEN @Quantity > 0 THEN CAST(GETDATE() AS DATE) ELSE NULL END,
            1, GETDATE()
        );

        SET @RawMaterialID = SCOPE_IDENTITY();

        -- AUTO-RECORD PURCHASE if quantity > 0
        IF @Quantity > 0 AND @UnitPrice > 0
        BEGIN
            DECLARE @TotalAmount DECIMAL(18,2) = @Quantity * @UnitPrice;
            
            INSERT INTO RawMaterialPurchase 
                (RawMaterialID, MaterialName, PurchaseDate, Quantity, Unit, UnitPrice, TotalAmount, SupplierName, Notes)
            VALUES 
                (@RawMaterialID, @MaterialName, GETDATE(), @Quantity, @Unit, @UnitPrice, @TotalAmount, @Supplier, 'Initial stock purchase');
        END

        COMMIT TRANSACTION;

        PRINT 'Raw Material created successfully with ID: ' + CAST(@RawMaterialID AS NVARCHAR);
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

PRINT '✅ sp_CreateRawMaterial updated - auto-records purchase';
GO

-- ================================================================================
-- STEP 2: UPDATE sp_UpdateRawMaterial to TRACK COST CHANGES
-- ================================================================================
IF OBJECT_ID('sp_UpdateRawMaterial', 'P') IS NOT NULL
    DROP PROCEDURE sp_UpdateRawMaterial;
GO

CREATE PROCEDURE sp_UpdateRawMaterial
    @RawMaterialID INT,
    @MaterialName NVARCHAR(100),
    @Category NVARCHAR(50) = NULL,
    @Unit NVARCHAR(20) = NULL,
    @Quantity DECIMAL(18,2) = 0,
    @MinimumStock DECIMAL(18,2) = 0,
    @UnitPrice DECIMAL(18,2) = 0,
    @Supplier NVARCHAR(100) = NULL,
    @SupplierContact NVARCHAR(100) = NULL,
    @Description NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Get old values
        DECLARE @OldQuantity DECIMAL(18,2), @OldUnitPrice DECIMAL(18,2), @OldMaterialName NVARCHAR(100);
        SELECT @OldQuantity = Quantity, @OldUnitPrice = UnitPrice, @OldMaterialName = MaterialName
        FROM RawMaterial WHERE RawMaterialID = @RawMaterialID;

        -- Calculate quantity difference
        DECLARE @QuantityDiff DECIMAL(18,2) = @Quantity - @OldQuantity;

        -- Update Raw Material
        UPDATE RawMaterial
        SET 
            MaterialName = @MaterialName,
            Category = @Category,
            Unit = @Unit,
            Quantity = @Quantity,
            MinimumStock = @MinimumStock,
            UnitPrice = @UnitPrice,
            Supplier = @Supplier,
            SupplierContact = @SupplierContact,
            Description = @Description,
            UpdatedDate = GETDATE(),
            LastRestockDate = CASE WHEN @QuantityDiff > 0 THEN GETDATE() ELSE LastRestockDate END
        WHERE RawMaterialID = @RawMaterialID;

        -- If quantity INCREASED, record as purchase
        IF @QuantityDiff > 0 AND @UnitPrice > 0
        BEGIN
            DECLARE @PurchaseAmount DECIMAL(18,2) = @QuantityDiff * @UnitPrice;
            
            INSERT INTO RawMaterialPurchase 
                (RawMaterialID, MaterialName, PurchaseDate, Quantity, Unit, UnitPrice, TotalAmount, SupplierName, Notes)
            VALUES 
                (@RawMaterialID, @MaterialName, GETDATE(), @QuantityDiff, @Unit, @UnitPrice, @PurchaseAmount, @Supplier, 'Stock update - quantity added');
        END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

PRINT '✅ sp_UpdateRawMaterial updated - auto-records purchases on stock increase';
GO

-- ================================================================================
-- STEP 3: UPDATE sp_GetRevenueByDateRange to INCLUDE ALL STATUSES
-- ================================================================================
IF OBJECT_ID('sp_GetRevenueByDateRange', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetRevenueByDateRange;
GO

CREATE PROCEDURE sp_GetRevenueByDateRange
    @StartDate DATE,
    @EndDate DATE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Sales Income - Include orders with any "positive" status
    DECLARE @SalesIncome DECIMAL(18,2) = (
        SELECT ISNULL(SUM(TotalAmount), 0) 
        FROM SalesOrder 
        WHERE CAST(OrderDate AS DATE) BETWEEN @StartDate AND @EndDate
          AND Status NOT IN ('Cancelled', 'Rejected', 'Pending')
    );
    
    -- Deal Income - Include deals with any "positive" status
    DECLARE @DealIncome DECIMAL(18,2) = (
        SELECT ISNULL(SUM(TotalAmount), 0) 
        FROM Deal 
        WHERE CAST(StartDate AS DATE) BETWEEN @StartDate AND @EndDate
          AND Status NOT IN ('Cancelled', 'Rejected', 'Pending')
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
    
    -- Salary Payments
    DECLARE @Salary DECIMAL(18,2) = (
        SELECT ISNULL(SUM(TotalAmount), 0) 
        FROM SalaryPayment 
        WHERE PaymentDate BETWEEN @StartDate AND @EndDate
    );
    
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

PRINT '✅ sp_GetRevenueByDateRange updated - includes all valid order statuses';
GO

-- ================================================================================
-- STEP 4: UPDATE sp_GetSalesOrdersByDateRange to INCLUDE MORE STATUSES
-- ================================================================================
IF OBJECT_ID('sp_GetSalesOrdersByDateRange', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetSalesOrdersByDateRange;
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
      AND so.Status NOT IN ('Cancelled', 'Rejected', 'Pending')
    ORDER BY so.OrderDate DESC;
END
GO

PRINT '✅ sp_GetSalesOrdersByDateRange updated';
GO

-- ================================================================================
-- STEP 5: UPDATE sp_GetDealsByDateRange to INCLUDE MORE STATUSES
-- ================================================================================
IF OBJECT_ID('sp_GetDealsByDateRange', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetDealsByDateRange;
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
    WHERE CAST(StartDate AS DATE) BETWEEN @StartDate AND @EndDate
      AND Status NOT IN ('Cancelled', 'Rejected', 'Pending')
    ORDER BY StartDate DESC;
END
GO

PRINT '✅ sp_GetDealsByDateRange updated';
GO

-- ================================================================================
-- STEP 6: VERIFY DATA
-- ================================================================================
PRINT '';
PRINT 'Checking Sales Orders in December 2025:';
SELECT SalesOrderID, OrderDate, Status, TotalAmount 
FROM SalesOrder 
WHERE MONTH(OrderDate) = 12 AND YEAR(OrderDate) = 2025
ORDER BY OrderDate DESC;
GO

PRINT '';
PRINT 'Checking Raw Material Purchases:';
SELECT TOP 10 PurchaseID, MaterialName, PurchaseDate, Quantity, UnitPrice, TotalAmount 
FROM RawMaterialPurchase 
ORDER BY PurchaseDate DESC;
GO

PRINT '';
PRINT '========================================';
PRINT '✅ REVENUE INTEGRATION COMPLETE!';
PRINT '========================================';
PRINT '';
PRINT 'Changes made:';
PRINT '1. CreateRawMaterial - Auto-records initial purchase';
PRINT '2. UpdateRawMaterial - Auto-records when stock increases';
PRINT '3. Revenue queries - Include all non-cancelled/rejected orders';
PRINT '';
GO
