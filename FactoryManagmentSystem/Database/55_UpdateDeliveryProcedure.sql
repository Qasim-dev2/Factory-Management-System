-- Update sp_UpdateDelivery procedure to remove deleted columns
USE GarmentsFactoryDB;
GO

DROP PROCEDURE IF EXISTS sp_UpdateDelivery;
GO

CREATE PROCEDURE sp_UpdateDelivery
    @DeliveryID INT,
    @DeliveredBy INT = NULL,
    @DeliveryDate DATETIME = NULL,
    @DeliveryAddress NVARCHAR(255) = NULL,
    @City NVARCHAR(100) = NULL,
    @Province NVARCHAR(100) = NULL,
    @PostalCode NVARCHAR(20) = NULL,
    @Status NVARCHAR(50),
    @ReceiverName NVARCHAR(100) = NULL,
    @ReceiverPhone NVARCHAR(50) = NULL,
    @Notes NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Delivery
    SET 
        DeliveredBy = ISNULL(@DeliveredBy, DeliveredBy),
        DeliveryDate = ISNULL(@DeliveryDate, DeliveryDate),
        DeliveryAddress = ISNULL(@DeliveryAddress, DeliveryAddress),
        City = ISNULL(@City, City),
        Province = ISNULL(@Province, Province),
        PostalCode = ISNULL(@PostalCode, PostalCode),
        Status = @Status,
        ReceiverName = ISNULL(@ReceiverName, ReceiverName),
        ReceiverPhone = ISNULL(@ReceiverPhone, ReceiverPhone),
        Notes = ISNULL(@Notes, Notes),
        UpdatedDate = GETDATE()
    WHERE DeliveryID = @DeliveryID;

    SELECT @@ROWCOUNT AS RowsAffected;
END
GO

PRINT 'sp_UpdateDelivery updated successfully!';
