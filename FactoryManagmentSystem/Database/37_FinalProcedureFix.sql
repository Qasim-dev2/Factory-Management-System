-- Fix procedures with CORRECT Retailer column names
USE GarmentsFactoryDB;
GO

DROP PROCEDURE IF EXISTS sp_GetAllDeliveries;
DROP PROCEDURE IF EXISTS sp_GetDeliveryById;
GO

-- ================================================================================
-- sp_GetAllDeliveries - CORRECTED
-- ================================================================================
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
        d.Status,
        d.ReceiverName,
        d.ReceiverPhone,
        d.Notes,
        d.CreatedDate,
        d.UpdatedDate,
        -- SalesOrder Info
        ISNULL(so.OrderDate, GETDATE()) as OrderDate,
        so.ExpectedDeliveryDate,
        ISNULL(so.TotalAmount, 0) as OrderAmount,
        so.Status as OrderStatus,
        so.PriorityLevel,
        -- Deal Info
        dl.DealTitle as DealName,
        dl.EndDate as DealDeadline,
        -- Retailer Info (CompanyName, not RetailerName!)
        ISNULL(r.CompanyName, dl.ClientName) as RetailerName,
        ISNULL(r.ContactPerson, dl.ContactPerson) as ContactPerson,
        ISNULL(r.Phone, dl.Phone) as RetailerPhone,
        ISNULL(r.City, dl.City) as RetailerCity,
        -- Sales Rep Info
        CONCAT(e.FirstName, ' ', e.LastName) as SalesRepName,
        -- Delivered By Info
        CONCAT(emp.FirstName, ' ', emp.LastName) as DeliveredByName
    FROM Delivery d
    LEFT JOIN SalesOrder so ON d.SalesOrderID = so.SalesOrderID
    LEFT JOIN Deal dl ON d.DealID = dl.DealID
    LEFT JOIN Retailer r ON so.RetailerID = r.RetailerID
    LEFT JOIN Employee e ON so.SalesRepID = e.EmployeeID
    LEFT JOIN Employee emp ON d.DeliveredBy = emp.EmployeeID
    ORDER BY d.CreatedDate DESC;
END
GO

-- ================================================================================
-- sp_GetDeliveryById - CORRECTED
-- ================================================================================
CREATE PROCEDURE sp_GetDeliveryById
    @DeliveryID INT
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
        d.Status,
        d.ReceiverName,
        d.ReceiverPhone,
        d.Notes,
        d.CreatedDate,
        d.UpdatedDate,
        -- SalesOrder Info
        ISNULL(so.OrderDate, GETDATE()) as OrderDate,
        so.ExpectedDeliveryDate,
        ISNULL(so.TotalAmount, 0) as OrderAmount,
        so.Status as OrderStatus,
        so.PriorityLevel,
        so.ShippingAddress as OrderShippingAddress,
        -- Retailer Info (CompanyName!)
        r.CompanyName as RetailerName,
        r.ContactPerson,
        r.Phone as RetailerPhone,
        r.Email as RetailerEmail,
        r.City as RetailerCity,
        r.Province as RetailerProvince,
        -- Sales Rep Info
        CONCAT(e.FirstName, ' ', e.LastName) as SalesRepName,
        e.Phone as SalesRepPhone,
        -- Delivered By Info
        CONCAT(emp.FirstName, ' ', emp.LastName) as DeliveredByName,
        emp.Phone as DeliveredByPhone
    FROM Delivery d
    LEFT JOIN SalesOrder so ON d.SalesOrderID = so.SalesOrderID
    LEFT JOIN Deal dl ON d.DealID = dl.DealID
    LEFT JOIN Retailer r ON so.RetailerID = r.RetailerID
    LEFT JOIN Employee e ON so.SalesRepID = e.EmployeeID
    LEFT JOIN Employee emp ON d.DeliveredBy = emp.EmployeeID
    WHERE d.DeliveryID = @DeliveryID;
END
GO

PRINT '✅ ALL PROCEDURES FULLY CORRECTED!';
GO
