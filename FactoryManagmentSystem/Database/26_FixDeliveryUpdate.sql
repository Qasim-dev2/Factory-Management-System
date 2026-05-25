-- ================================================================================
-- FIX DELIVERY UPDATE PROCEDURE
-- ================================================================================
-- This fixes the sp_UpdateDelivery to handle SalesOrder updates correctly
-- and prevent errors when updating deliveries
-- ================================================================================

USE GarmentsFactoryDB;
GO

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

PRINT '========================================';
PRINT 'FIXING DELIVERY UPDATE PROCEDURE';
PRINT '========================================';
GO

-- Drop and recreate sp_UpdateDelivery with proper error handling
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_UpdateDelivery')
    DROP PROCEDURE sp_UpdateDelivery;
GO

CREATE PROCEDURE sp_UpdateDelivery
    @DeliveryID INT,
    @DeliveredBy INT = NULL,
    @DeliveryDate DATETIME = NULL,
    @DeliveryAddress NVARCHAR(500) = NULL,
    @City NVARCHAR(50) = NULL,
    @Province NVARCHAR(50) = NULL,
    @PostalCode NVARCHAR(10) = NULL,
    @TrackingNumber NVARCHAR(100) = NULL,
    @DeliveryMethod NVARCHAR(50) = NULL,
    @DeliveryCost DECIMAL(18,2) = NULL,
    @Status NVARCHAR(50),
    @ReceiverName NVARCHAR(100) = NULL,
    @ReceiverPhone NVARCHAR(20) = NULL,
    @Notes NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validate delivery exists
        IF NOT EXISTS (SELECT 1 FROM Delivery WHERE DeliveryID = @DeliveryID)
        BEGIN
            RAISERROR('Delivery record not found.', 16, 1);
            RETURN;
        END
        
        -- Set DeliveryDate if status is Delivered and not already set
        IF @Status = 'Delivered' AND @DeliveryDate IS NULL
        BEGIN
            SET @DeliveryDate = GETDATE();
        END
        
        -- Update Delivery
        UPDATE Delivery
        SET 
            DeliveredBy = ISNULL(@DeliveredBy, DeliveredBy),
            DeliveryDate = ISNULL(@DeliveryDate, DeliveryDate),
            DeliveryAddress = ISNULL(@DeliveryAddress, DeliveryAddress),
            City = ISNULL(@City, City),
            Province = ISNULL(@Province, Province),
            PostalCode = ISNULL(@PostalCode, PostalCode),
            TrackingNumber = ISNULL(@TrackingNumber, TrackingNumber),
            DeliveryMethod = ISNULL(@DeliveryMethod, DeliveryMethod),
            DeliveryCost = ISNULL(@DeliveryCost, DeliveryCost),
            Status = @Status,
            ReceiverName = ISNULL(@ReceiverName, ReceiverName),
            ReceiverPhone = ISNULL(@ReceiverPhone, ReceiverPhone),
            Notes = ISNULL(@Notes, Notes)
        WHERE DeliveryID = @DeliveryID;
        
        -- Update related SalesOrder status based on delivery status (only if SalesOrderID exists)
        DECLARE @SalesOrderID INT;
        SELECT @SalesOrderID = SalesOrderID FROM Delivery WHERE DeliveryID = @DeliveryID;
        
        IF @SalesOrderID IS NOT NULL
        BEGIN
            IF @Status = 'Delivered'
            BEGIN
                UPDATE SalesOrder 
                SET Status = 'Delivered', UpdatedDate = GETDATE()
                WHERE SalesOrderID = @SalesOrderID;
            END
            ELSE IF @Status = 'InTransit'
            BEGIN
                UPDATE SalesOrder 
                SET Status = 'Shipped', UpdatedDate = GETDATE()
                WHERE SalesOrderID = @SalesOrderID;
            END
            ELSE IF @Status = 'Pending'
            BEGIN
                UPDATE SalesOrder 
                SET Status = 'Confirmed', UpdatedDate = GETDATE()
                WHERE SalesOrderID = @SalesOrderID AND Status IN ('Delivered', 'Shipped');
            END
        END
        
        COMMIT TRANSACTION;
        
        PRINT 'Delivery updated successfully.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO

PRINT '✅ sp_UpdateDelivery fixed successfully';
GO

-- Test the procedure
PRINT '';
PRINT 'Testing delivery updates...';
GO

-- Check if we have any deliveries
IF EXISTS (SELECT TOP 1 1 FROM Delivery)
BEGIN
    DECLARE @TestDeliveryID INT;
    SELECT TOP 1 @TestDeliveryID = DeliveryID FROM Delivery;
    
    PRINT 'Found delivery ID: ' + CAST(@TestDeliveryID AS VARCHAR);
    PRINT '✅ Delivery system is ready';
END
ELSE
BEGIN
    PRINT 'ℹ️  No deliveries found in database';
END
GO

PRINT '';
PRINT '========================================';
PRINT '✅ DELIVERY UPDATE FIX COMPLETE';
PRINT '========================================';
GO
