-- ================================================================================
-- FIX DEAL TOTALS AND AUTO-CALCULATE AMOUNTS
-- ================================================================================
USE GarmentsFactoryDB;
GO

PRINT '========================================';
PRINT 'FIX DEAL TOTALS';
PRINT '========================================';

-- ================================================================================
-- STEP 1: UPDATE ALL DEAL TOTALS FROM DealItems
-- ================================================================================
UPDATE d
SET TotalAmount = ISNULL((
    SELECT SUM(di.Quantity * di.UnitPrice)
    FROM DealItem di
    WHERE di.DealID = d.DealID
), 0)
FROM Deal d;
GO

PRINT '✅ Deal totals updated from DealItems';

-- Check results
SELECT DealID, DealTitle, TotalAmount, Status 
FROM Deal 
WHERE TotalAmount > 0;
GO

-- ================================================================================
-- STEP 2: UPDATE sp_AddDealItem to AUTO-UPDATE DEAL TOTAL
-- ================================================================================
IF OBJECT_ID('sp_AddDealItem', 'P') IS NOT NULL
    DROP PROCEDURE sp_AddDealItem;
GO

CREATE PROCEDURE sp_AddDealItem
    @DealID INT,
    @ProductID INT,
    @Quantity INT,
    @UnitPrice DECIMAL(18,2),
    @DealItemID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Insert the deal item
        INSERT INTO DealItem (DealID, ProductID, Quantity, UnitPrice)
        VALUES (@DealID, @ProductID, @Quantity, @UnitPrice);

        SET @DealItemID = SCOPE_IDENTITY();

        -- AUTO-UPDATE DEAL TOTAL
        UPDATE Deal
        SET TotalAmount = (
            SELECT ISNULL(SUM(di.Quantity * di.UnitPrice), 0)
            FROM DealItem di
            WHERE di.DealID = @DealID
        )
        WHERE DealID = @DealID;

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

PRINT '✅ sp_AddDealItem updated - auto-calculates deal total';
GO

-- ================================================================================
-- STEP 3: UPDATE sp_CreateSalesOrder to SET TotalAmount FROM Items
-- ================================================================================
-- First check existing procedure
IF OBJECT_ID('sp_UpdateSalesOrderTotal', 'P') IS NOT NULL
    DROP PROCEDURE sp_UpdateSalesOrderTotal;
GO

CREATE PROCEDURE sp_UpdateSalesOrderTotal
    @SalesOrderID INT
AS
BEGIN
    UPDATE SalesOrder
    SET TotalAmount = (
        SELECT ISNULL(SUM(soi.Quantity * soi.UnitPrice), 0)
        FROM SalesOrderItem soi
        WHERE soi.SalesOrderID = @SalesOrderID
    )
    WHERE SalesOrderID = @SalesOrderID;
END
GO

PRINT '✅ sp_UpdateSalesOrderTotal created';
GO

-- ================================================================================
-- STEP 4: UPDATE sp_AddSalesOrderItem to AUTO-UPDATE ORDER TOTAL
-- ================================================================================
IF OBJECT_ID('sp_AddSalesOrderItem', 'P') IS NOT NULL
    DROP PROCEDURE sp_AddSalesOrderItem;
GO

CREATE PROCEDURE sp_AddSalesOrderItem
    @SalesOrderID INT,
    @ProductID INT,
    @Quantity INT,
    @UnitPrice DECIMAL(18,2),
    @SalesOrderItemID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Insert the order item
        INSERT INTO SalesOrderItem (SalesOrderID, ProductID, Quantity, UnitPrice)
        VALUES (@SalesOrderID, @ProductID, @Quantity, @UnitPrice);

        SET @SalesOrderItemID = SCOPE_IDENTITY();

        -- AUTO-UPDATE ORDER TOTAL
        UPDATE SalesOrder
        SET TotalAmount = (
            SELECT ISNULL(SUM(soi.Quantity * soi.UnitPrice), 0)
            FROM SalesOrderItem soi
            WHERE soi.SalesOrderID = @SalesOrderID
        )
        WHERE SalesOrderID = @SalesOrderID;

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

PRINT '✅ sp_AddSalesOrderItem updated - auto-calculates order total';
GO

-- ================================================================================
-- STEP 5: RE-CALCULATE ALL SALES ORDER TOTALS
-- ================================================================================
UPDATE so
SET TotalAmount = ISNULL((
    SELECT SUM(soi.Quantity * soi.UnitPrice)
    FROM SalesOrderItem soi
    WHERE soi.SalesOrderID = so.SalesOrderID
), 0)
FROM SalesOrder so
WHERE (TotalAmount IS NULL OR TotalAmount = 0) 
  AND EXISTS (SELECT 1 FROM SalesOrderItem WHERE SalesOrderID = so.SalesOrderID);
GO

PRINT '✅ Sales order totals recalculated';
GO

-- ================================================================================
-- VERIFICATION
-- ================================================================================
PRINT '';
PRINT 'Revenue Check for December 2025:';
EXEC sp_GetRevenueByDateRange '2025-12-01', '2025-12-31';
GO

PRINT '';
PRINT '========================================';
PRINT '✅ DEAL & ORDER TOTALS FIXED!';
PRINT '========================================';
GO
