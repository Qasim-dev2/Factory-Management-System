-- Fix Delivery table and procedures
-- 1. Remove TrackingNumber, DeliveryMethod, DeliveryCost columns
-- 2. Fix sp_GetDeliveryAssignments to remove EstimatedValue reference
-- 3. Create sp_CreateDeliveryFromProduction for automatic delivery creation

USE GarmentsFactoryDB;
GO

-- 1. Drop columns from Delivery table
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Delivery' AND COLUMN_NAME = 'TrackingNumber')
BEGIN
    ALTER TABLE Delivery DROP COLUMN TrackingNumber;
    PRINT 'Dropped TrackingNumber column';
END

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Delivery' AND COLUMN_NAME = 'DeliveryMethod')
BEGIN
    ALTER TABLE Delivery DROP COLUMN DeliveryMethod;
    PRINT 'Dropped DeliveryMethod column';
END

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Delivery' AND COLUMN_NAME = 'DeliveryCost')
BEGIN
    ALTER TABLE Delivery DROP COLUMN DeliveryCost;
    PRINT 'Dropped DeliveryCost column';
END
GO

-- 2. Update sp_GetDeliveryAssignments to remove EstimatedValue reference
DROP PROCEDURE IF EXISTS sp_GetDeliveryAssignments;
GO

CREATE PROCEDURE sp_GetDeliveryAssignments
    @DeliveryPersonID INT = NULL,
    @Status NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        d.DeliveryID,
        d.SalesOrderID,
        d.DealID,
        d.Status,
        d.DeliveryDate,
        d.DeliveryAddress,
        d.City,
        d.Province,
        d.ReceiverName,
        d.ReceiverPhone,
        d.Notes,
        d.CreatedDate,

        -- Order type
        CASE
            WHEN d.SalesOrderID IS NOT NULL THEN 'SalesOrder'
            WHEN d.DealID IS NOT NULL THEN 'Deal'
        END AS OrderType,

        -- SalesOrder details
        so.OrderDate AS SalesOrderDate,
        so.TotalAmount AS OrderAmount,

        -- Deal details
        de.CreatedDate AS DealDate,

        -- Customer details
        COALESCE(r.CompanyName, de.ClientName) AS CustomerName,
        COALESCE(r.Phone, de.Phone) AS CustomerPhone,
        COALESCE(r.ContactPerson, de.ContactPerson) AS ContactPerson,

        -- Delivery person
        CONCAT(e.FirstName, ' ', e.LastName) AS DeliveryPersonName

    FROM Delivery d
    LEFT JOIN SalesOrder so ON d.SalesOrderID = so.SalesOrderID
    LEFT JOIN Retailer r ON so.RetailerID = r.RetailerID
    LEFT JOIN Deal de ON d.DealID = de.DealID
    LEFT JOIN Employee e ON d.DeliveredBy = e.EmployeeID

    WHERE (@DeliveryPersonID IS NULL OR d.DeliveredBy = @DeliveryPersonID)
    AND (@Status IS NULL OR d.Status = @Status)
    ORDER BY
        CASE d.Status
            WHEN 'Pending' THEN 1
            WHEN 'InTransit' THEN 2
            WHEN 'Delivered' THEN 3
        END,
        d.CreatedDate DESC;
END
GO

-- 3. Create procedure to automatically create delivery when production completes
DROP PROCEDURE IF EXISTS sp_CreateDeliveryFromProduction;
GO

CREATE PROCEDURE sp_CreateDeliveryFromProduction
    @ProductionOrderID INT,
    @DeliveryPersonID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @SalesOrderID INT = NULL;
        DECLARE @DealID INT = NULL;
        DECLARE @DeliveryAddress NVARCHAR(255) = NULL;
        DECLARE @City NVARCHAR(100) = NULL;
        DECLARE @Province NVARCHAR(100) = NULL;
        DECLARE @PostalCode NVARCHAR(20) = NULL;
        DECLARE @ReceiverName NVARCHAR(100) = NULL;
        DECLARE @ReceiverPhone NVARCHAR(50) = NULL;
        DECLARE @NewDeliveryID INT;

        -- Get order details from TailorAssignment
        SELECT TOP 1
            @SalesOrderID = SalesOrderID,
            @DealID = DealID
        FROM TailorAssignment
        WHERE ProductionOrderID = @ProductionOrderID;

        -- Get delivery details based on order type
        IF @SalesOrderID IS NOT NULL
        BEGIN
            -- Get from SalesOrder
            SELECT
                @DeliveryAddress = ISNULL(so.ShippingAddress, 'Address not specified'),
                @ReceiverName = ISNULL(r.ContactPerson, 'N/A'),
                @ReceiverPhone = ISNULL(r.Phone, 'N/A')
            FROM SalesOrder so
            LEFT JOIN Retailer r ON so.RetailerID = r.RetailerID
            WHERE so.SalesOrderID = @SalesOrderID;
        END
        ELSE IF @DealID IS NOT NULL
        BEGIN
            -- Get from Deal
            SELECT
                @DeliveryAddress = ISNULL(de.DeliveryAddress, 'Address not specified'),
                @ReceiverName = ISNULL(de.ContactPerson, 'N/A'),
                @ReceiverPhone = ISNULL(de.Phone, 'N/A')
            FROM Deal de
            WHERE de.DealID = @DealID;
        END

        -- Ensure we have at least a delivery address
        IF @DeliveryAddress IS NULL
            SET @DeliveryAddress = 'Address not specified';
        IF @ReceiverName IS NULL
            SET @ReceiverName = 'N/A';
        IF @ReceiverPhone IS NULL
            SET @ReceiverPhone = 'N/A';

        -- Create delivery record
        INSERT INTO Delivery (
            SalesOrderID,
            DealID,
            DeliveredBy,
            DeliveryDate,
            DeliveryAddress,
            City,
            Province,
            PostalCode,
            Status,
            ReceiverName,
            ReceiverPhone,
            Notes,
            CreatedDate
        )
        VALUES (
            @SalesOrderID,
            @DealID,
            @DeliveryPersonID,
            DATEADD(DAY, 3, GETDATE()), -- Expected delivery in 3 days
            @DeliveryAddress,
            @City,
            @Province,
            @PostalCode,
            'Pending',
            @ReceiverName,
            @ReceiverPhone,
            'Auto-generated from production completion',
            GETDATE()
        );

        SET @NewDeliveryID = SCOPE_IDENTITY();

        COMMIT TRANSACTION;

        SELECT 
            'Success' AS Result, 
            'Delivery created successfully.' AS Message,
            @NewDeliveryID AS DeliveryID;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SELECT 
            'Error' AS Result, 
            ERROR_MESSAGE() AS Message,
            NULL AS DeliveryID;
    END CATCH
END
GO

PRINT 'Delivery table and procedures updated successfully!';
