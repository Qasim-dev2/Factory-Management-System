-- ================================================================================
-- FIX sp_GetAllDeliveries - Remove Non-Existent Columns
-- ================================================================================
USE GarmentsFactoryDB;
GO

PRINT 'Fixing sp_GetAllDeliveries procedure...';
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
        ISNULL(d.Status, 'Pending') as Status,
        d.ReceiverName,
        d.ReceiverPhone,
        d.Notes,
        d.CreatedDate,
        d.UpdatedDate,
        -- SalesOrder Info (with NULL handling)
        ISNULL(so.OrderDate, ISNULL(d.CreatedDate, GETDATE())) as OrderDate,
        ISNULL(so.TotalAmount, 0) as OrderAmount,
        ISNULL(so.Status, '') as OrderStatus,
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
    LEFT JOIN Employee e ON so.SalesRepID = e.EmployeeID OR dl.CreatedBy = e.EmployeeID
    LEFT JOIN Employee emp ON d.DeliveredBy = emp.EmployeeID
    ORDER BY 
        CASE WHEN d.Status = 'Pending' THEN 1
             WHEN d.Status = 'In Transit' THEN 2
             WHEN d.Status = 'Delivered' THEN 3
             ELSE 4 END,
        d.DeliveryDate DESC,
        d.DeliveryID DESC;
END
GO

PRINT '✅ sp_GetAllDeliveries fixed successfully';
GO

PRINT '';
PRINT 'Changes made:';
PRINT '- Removed non-existent columns from Delivery table (TrackingNumber, DeliveryMethod, DeliveryCost)';
PRINT '- Removed non-existent columns from SalesOrder table (ExpectedDeliveryDate, PriorityLevel)';
PRINT '- Removed non-existent columns from Deal table (RetailerID, AssignedTo)';
PRINT '- Fixed joins to use correct column names (CreatedBy instead of AssignedTo)';
PRINT '- All columns now reference correct tables';
GO
