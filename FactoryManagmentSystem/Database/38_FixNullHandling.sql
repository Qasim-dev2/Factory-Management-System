-- Fix NULL handling in delivery procedures
USE GarmentsFactoryDB;
GO

DROP PROCEDURE IF EXISTS sp_GetAllDeliveries;
GO

CREATE PROCEDURE sp_GetAllDeliveries
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        d.DeliveryID,
        d.SalesOrderID,
        d.DealID,
        d.DeliveredBy,
        d.DeliveryDate,
        d.DeliveryAddress,
        d.City,
        d.Province,
        d.PostalCode,
        d.TrackingNumber,
        d.DeliveryMethod,
        d.DeliveryCost,
        ISNULL(d.Status, 'Pending') as Status,
        d.ReceiverName,
        d.ReceiverPhone,
        d.Notes,
        d.CreatedDate,
        d.UpdatedDate,
        -- SalesOrder Info (with NULL handling)
        ISNULL(so.OrderDate, ISNULL(d.CreatedDate, GETDATE())) as OrderDate,
        so.ExpectedDeliveryDate,
        ISNULL(so.TotalAmount, 0) as OrderAmount,
        ISNULL(so.Status, '') as OrderStatus,
        ISNULL(so.PriorityLevel, '') as PriorityLevel,
        -- Deal Info (with NULL handling)
        ISNULL(dl.DealTitle, '') as DealName,
        dl.EndDate as DealDeadline,
        -- Retailer Info (with NULL handling)
        ISNULL(r.CompanyName, ISNULL(dl.ClientName, '')) as RetailerName,
        ISNULL(r.ContactPerson, ISNULL(dl.ContactPerson, '')) as ContactPerson,
        ISNULL(r.Phone, ISNULL(dl.Phone, '')) as RetailerPhone,
        ISNULL(r.City, ISNULL(dl.City, '')) as RetailerCity,
        -- Sales Rep Info (with NULL handling)
        ISNULL(CONCAT(e.FirstName, ' ', e.LastName), '') as SalesRepName,
        -- Delivered By Info (with NULL handling)
        ISNULL(CONCAT(emp.FirstName, ' ', emp.LastName), '') as DeliveredByName
    FROM Delivery d
    LEFT JOIN SalesOrder so ON d.SalesOrderID = so.SalesOrderID
    LEFT JOIN Deal dl ON d.DealID = dl.DealID
    LEFT JOIN Retailer r ON so.RetailerID = r.RetailerID
    LEFT JOIN Employee e ON so.SalesRepID = e.EmployeeID
    LEFT JOIN Employee emp ON d.DeliveredBy = emp.EmployeeID
    ORDER BY d.CreatedDate DESC;
END
GO

PRINT '✅ sp_GetAllDeliveries fixed with NULL handling';
GO

-- Also update sp_UpdateDeliveryStatus to handle NULL Status
DROP PROCEDURE IF EXISTS sp_UpdateDeliveryStatus;
GO

CREATE PROCEDURE sp_UpdateDeliveryStatus
    @DeliveryID INT,
    @Status NVARCHAR(50),
    @TrackingNumber NVARCHAR(100) = NULL,
    @Notes NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validate delivery exists
    IF NOT EXISTS (SELECT 1 FROM Delivery WHERE DeliveryID = @DeliveryID)
    BEGIN
        RAISERROR('Delivery not found', 16, 1);
        RETURN;
    END
    
    -- Update with NULL-safe handling
    UPDATE Delivery
    SET 
        Status = ISNULL(@Status, 'Pending'),
        TrackingNumber = CASE WHEN @TrackingNumber IS NOT NULL THEN @TrackingNumber ELSE TrackingNumber END,
        Notes = CASE WHEN @Notes IS NOT NULL THEN @Notes ELSE Notes END,
        DeliveryDate = CASE WHEN ISNULL(@Status, '') = 'Delivered' AND DeliveryDate IS NULL THEN GETDATE() ELSE DeliveryDate END,
        UpdatedDate = GETDATE()
    WHERE DeliveryID = @DeliveryID;
    
    IF @@ROWCOUNT = 0
    BEGIN
        RAISERROR('Update failed', 16, 1);
        RETURN;
    END
END
GO

PRINT '✅ sp_UpdateDeliveryStatus fixed with NULL handling';
GO

PRINT '✅ ALL NULL HANDLING FIXED!';
GO
