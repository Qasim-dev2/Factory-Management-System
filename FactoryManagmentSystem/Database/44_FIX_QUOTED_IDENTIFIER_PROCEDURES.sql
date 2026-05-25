-- =============================================
-- FIX QUOTED_IDENTIFIER ISSUES FOR SALES ORDER
-- Recreate procedures with proper settings
-- Date: December 17, 2025
-- =============================================

USE GarmentsFactoryDB;
GO

PRINT '======================================='
PRINT 'FIX: QUOTED_IDENTIFIER Issues'
PRINT '======================================='
PRINT ''

-- =============================================
-- 1. Recreate sp_AddSalesOrderItem with proper settings
-- =============================================
IF OBJECT_ID('sp_AddSalesOrderItem', 'P') IS NOT NULL
    DROP PROCEDURE sp_AddSalesOrderItem;
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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

PRINT '✓ Recreated sp_AddSalesOrderItem with QUOTED_IDENTIFIER ON'

-- =============================================
-- 2. Recreate sp_DeleteSalesOrder with proper settings
-- =============================================
IF OBJECT_ID('sp_DeleteSalesOrder', 'P') IS NOT NULL
    DROP PROCEDURE sp_DeleteSalesOrder;
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE sp_DeleteSalesOrder
    @SalesOrderID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Delete order items first (if foreign key allows)
        DELETE FROM SalesOrderItem WHERE SalesOrderID = @SalesOrderID;

        -- Delete the sales order
        DELETE FROM SalesOrder WHERE SalesOrderID = @SalesOrderID;

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

PRINT '✓ Recreated sp_DeleteSalesOrder with QUOTED_IDENTIFIER ON'

-- =============================================
-- 3. Recreate sp_AddSalesOrder with proper settings
-- =============================================
IF OBJECT_ID('sp_AddSalesOrder', 'P') IS NOT NULL
    DROP PROCEDURE sp_AddSalesOrder;
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE sp_AddSalesOrder
    @OrderDate DATETIME = NULL,
    @Status NVARCHAR(60) = 'Pending Approval',
    @RetailerID INT,
    @ShippingAddress NVARCHAR(1000) = NULL,
    @DiscountPercentage DECIMAL(5,2) = 0,
    @SubTotal DECIMAL(18,2) = 0,
    @DiscountAmount DECIMAL(18,2) = 0,
    @TotalAmount DECIMAL(18,2) = 0,
    @SalesRepID INT = NULL,
    @NewSalesOrderID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Insert Sales Order
        INSERT INTO SalesOrder (
            OrderDate, Status, RetailerID, ShippingAddress, DiscountPercentage,
            SubTotal, DiscountAmount, TotalAmount, SalesRepID, CreatedDate
        )
        VALUES (
            ISNULL(@OrderDate, GETDATE()), 'Pending Approval', @RetailerID, @ShippingAddress,
            @DiscountPercentage, @SubTotal, @DiscountAmount, @TotalAmount, @SalesRepID, GETDATE()
        );

        SET @NewSalesOrderID = SCOPE_IDENTITY();

        -- Create approval request automatically
        INSERT INTO OrderApproval (OrderType, OrderID, RequestedByEmployeeID, Status, RequestDate, CreatedDate)
        VALUES ('SalesOrder', @NewSalesOrderID, @SalesRepID, 'Pending', GETDATE(), GETDATE());

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

PRINT '✓ Recreated sp_AddSalesOrder with QUOTED_IDENTIFIER ON'

-- =============================================
-- 4. Also fix Deal procedures
-- =============================================
IF OBJECT_ID('sp_AddDealItem', 'P') IS NOT NULL
    DROP PROCEDURE sp_AddDealItem;
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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

PRINT '✓ Recreated sp_AddDealItem with QUOTED_IDENTIFIER ON'

PRINT ''
PRINT '======================================='
PRINT 'ALL PROCEDURES RECREATED'
PRINT '======================================='
PRINT '✓ All procedures now have QUOTED_IDENTIFIER ON'
PRINT '✓ Can now INSERT and DELETE without errors'
PRINT '======================================='

GO
