-- ================================================================================
-- FIX DELIVERY PROCEDURES - Remove Non-Existent Columns
-- ================================================================================
-- This script fixes sp_UpdateDelivery and sp_UpdateDeliveryStatus
-- to only use columns that actually exist in the Delivery table
-- ================================================================================
USE GarmentsFactoryDB;
GO

PRINT 'Fixing Delivery Update Procedures...';
GO

-- ================================================================================
-- 1. FIX sp_UpdateDelivery
-- ================================================================================
DROP PROCEDURE IF EXISTS sp_UpdateDelivery;
GO

CREATE PROCEDURE sp_UpdateDelivery
    @DeliveryID INT,
    @DeliveredBy INT = NULL,
    @DeliveryDate DATETIME = NULL,
    @DeliveryAddress NVARCHAR(500) = NULL,
    @City NVARCHAR(100) = NULL,
    @Province NVARCHAR(100) = NULL,
    @PostalCode NVARCHAR(20) = NULL,
    @Status NVARCHAR(50) = NULL,
    @ReceiverName NVARCHAR(200) = NULL,
    @ReceiverPhone NVARCHAR(20) = NULL,
    @Notes NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validate delivery exists
    IF NOT EXISTS (SELECT 1 FROM Delivery WHERE DeliveryID = @DeliveryID)
    BEGIN
        RAISERROR('Delivery ID %d not found', 16, 1, @DeliveryID);
        RETURN;
    END
    
    -- Update delivery with only existing columns
    UPDATE Delivery
    SET 
        DeliveredBy = ISNULL(@DeliveredBy, DeliveredBy),
        DeliveryDate = ISNULL(@DeliveryDate, DeliveryDate),
        DeliveryAddress = ISNULL(@DeliveryAddress, DeliveryAddress),
        City = ISNULL(@City, City),
        Province = ISNULL(@Province, Province),
        PostalCode = ISNULL(@PostalCode, PostalCode),
        Status = ISNULL(@Status, Status),
        ReceiverName = ISNULL(@ReceiverName, ReceiverName),
        ReceiverPhone = ISNULL(@ReceiverPhone, ReceiverPhone),
        Notes = ISNULL(@Notes, Notes),
        UpdatedDate = GETDATE()
    WHERE DeliveryID = @DeliveryID;
    
    IF @@ROWCOUNT = 0
    BEGIN
        RAISERROR('Failed to update delivery ID %d', 16, 1, @DeliveryID);
        RETURN;
    END
    
    PRINT 'Delivery updated successfully';
END
GO

PRINT '✅ sp_UpdateDelivery fixed successfully';
GO

-- ================================================================================
-- 2. FIX sp_UpdateDeliveryStatus
-- ================================================================================
DROP PROCEDURE IF EXISTS sp_UpdateDeliveryStatus;
GO

CREATE PROCEDURE sp_UpdateDeliveryStatus
    @DeliveryID INT,
    @Status NVARCHAR(50),
    @TrackingNumber NVARCHAR(100) = NULL,  -- Parameter kept for compatibility but not used
    @Notes NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validate delivery exists
    IF NOT EXISTS (SELECT 1 FROM Delivery WHERE DeliveryID = @DeliveryID)
    BEGIN
        RAISERROR('Delivery ID %d not found', 16, 1, @DeliveryID);
        RETURN;
    END
    
    -- Update delivery status (TrackingNumber column doesn't exist in table, so we skip it)
    UPDATE Delivery
    SET 
        Status = ISNULL(@Status, Status),
        Notes = CASE 
            WHEN @Notes IS NOT NULL AND @Notes != '' THEN 
                CASE 
                    WHEN Notes IS NOT NULL AND Notes != '' THEN Notes + '; ' + @Notes
                    ELSE @Notes
                END
            ELSE Notes
        END,
        DeliveryDate = CASE 
            WHEN @Status = 'Delivered' AND DeliveryDate IS NULL THEN GETDATE() 
            ELSE DeliveryDate 
        END,
        UpdatedDate = GETDATE()
    WHERE DeliveryID = @DeliveryID;
    
    IF @@ROWCOUNT = 0
    BEGIN
        RAISERROR('Failed to update delivery status for ID %d', 16, 1, @DeliveryID);
        RETURN;
    END
    
    PRINT 'Delivery status updated successfully';
END
GO

PRINT '✅ sp_UpdateDeliveryStatus fixed successfully';
GO

-- ================================================================================
-- 3. VERIFY THE FIXES
-- ================================================================================
PRINT '';
PRINT 'Verifying procedures...';
GO

-- Test that procedures exist
IF OBJECT_ID('sp_UpdateDelivery', 'P') IS NOT NULL
    PRINT '✅ sp_UpdateDelivery exists';
ELSE
    PRINT '❌ sp_UpdateDelivery missing';

IF OBJECT_ID('sp_UpdateDeliveryStatus', 'P') IS NOT NULL
    PRINT '✅ sp_UpdateDeliveryStatus exists';
ELSE
    PRINT '❌ sp_UpdateDeliveryStatus missing';

GO

PRINT '';
PRINT '======================================================';
PRINT '✅ ALL DELIVERY PROCEDURES FIXED!';
PRINT '======================================================';
PRINT '';
PRINT 'Changes made:';
PRINT '1. Removed references to non-existent columns:';
PRINT '   - TrackingNumber (removed from UPDATE statement)';
PRINT '   - DeliveryMethod (never existed)';
PRINT '   - DeliveryCost (never existed)';
PRINT '   - ExpectedDeliveryDate (belongs to SalesOrder table)';
PRINT '   - PriorityLevel (belongs to SalesOrder table)';
PRINT '';
PRINT '2. Kept only columns that exist in Delivery table:';
PRINT '   - DeliveryID, SalesOrderID, DealID, DeliveredBy';
PRINT '   - DeliveryDate, DeliveryAddress, City, Province';
PRINT '   - PostalCode, Status, ReceiverName, ReceiverPhone';
PRINT '   - Notes, CreatedDate, UpdatedDate';
PRINT '';
PRINT 'You can now update deliveries without errors!';
GO
