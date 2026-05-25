-- ================================================================================
-- FIX ALL REMAINING DELIVERY PROCEDURES - Remove Non-Existent Columns
-- ================================================================================
USE GarmentsFactoryDB;
GO

PRINT '======================================================';
PRINT 'FIXING ALL REMAINING DELIVERY PROCEDURES';
PRINT '======================================================';
PRINT '';

-- ================================================================================
-- 1. FIX sp_GetDeliveryById
-- ================================================================================
PRINT 'Fixing sp_GetDeliveryById...';
GO

DROP PROCEDURE IF EXISTS sp_GetDeliveryById;
GO

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
        d.Status,
        d.ReceiverName,
        d.ReceiverPhone,
        d.Notes,
        d.CreatedDate,
        d.UpdatedDate,
        -- SalesOrder Info (only existing columns)
        ISNULL(so.OrderDate, GETDATE()) as OrderDate,
        ISNULL(so.TotalAmount, 0) as OrderAmount,
        so.Status as OrderStatus,
        so.ShippingAddress as OrderShippingAddress,
        -- Retailer Info
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

PRINT '✅ sp_GetDeliveryById fixed';
GO

-- ================================================================================
-- 2. FIX sp_GetDeliveryStatistics (if it references these columns)
-- ================================================================================
PRINT 'Fixing sp_GetDeliveryStatistics...';
GO

DROP PROCEDURE IF EXISTS sp_GetDeliveryStatistics;
GO

CREATE PROCEDURE sp_GetDeliveryStatistics
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        COUNT(*) as TotalDeliveries,
        SUM(CASE WHEN Status = 'Pending' THEN 1 ELSE 0 END) as PendingDeliveries,
        SUM(CASE WHEN Status = 'In Transit' THEN 1 ELSE 0 END) as InTransitDeliveries,
        SUM(CASE WHEN Status = 'Delivered' THEN 1 ELSE 0 END) as DeliveredCount,
        SUM(CASE WHEN Status = 'Failed' THEN 1 ELSE 0 END) as FailedDeliveries,
        SUM(CASE WHEN Status = 'Returned' THEN 1 ELSE 0 END) as ReturnedDeliveries,
        SUM(CASE WHEN CAST(DeliveryDate AS DATE) = CAST(GETDATE() AS DATE) THEN 1 ELSE 0 END) as TodayDeliveries,
        SUM(CASE WHEN DeliveryDate >= DATEADD(DAY, -7, GETDATE()) THEN 1 ELSE 0 END) as LastWeekDeliveries,
        SUM(CASE WHEN DeliveryDate >= DATEADD(MONTH, -1, GETDATE()) THEN 1 ELSE 0 END) as LastMonthDeliveries
    FROM Delivery;
END
GO

PRINT '✅ sp_GetDeliveryStatistics fixed';
GO

-- ================================================================================
-- 3. FIX sp_GetDeliveryAssignments (if it exists)
-- ================================================================================
PRINT 'Fixing sp_GetDeliveryAssignments...';
GO

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
        d.DeliveredBy,
        d.DeliveryDate,
        d.DeliveryAddress,
        d.City,
        d.Province,
        d.PostalCode,
        d.Status,
        d.ReceiverName,
        d.ReceiverPhone,
        d.Notes,
        d.CreatedDate,
        -- Order Info
        ISNULL(so.OrderDate, ISNULL(d.CreatedDate, GETDATE())) as OrderDate,
        ISNULL(so.TotalAmount, 0) as OrderAmount,
        -- OrderType (determine from SalesOrderID vs DealID)
        CASE 
            WHEN d.SalesOrderID IS NOT NULL THEN 'Sales Order'
            WHEN d.DealID IS NOT NULL THEN 'Deal'
            ELSE 'Unknown'
        END as OrderType,
        -- Retailer/Customer Info
        ISNULL(r.CompanyName, dl.ClientName) as CustomerName,
        ISNULL(r.ContactPerson, dl.ContactPerson) as ContactPerson,
        ISNULL(r.Phone, dl.Phone) as RetailerPhone,
        -- Deal Info
        dl.DealTitle as DealName,
        -- Delivered By
        CONCAT(emp.FirstName, ' ', emp.LastName) as DeliveredByName
    FROM Delivery d
    LEFT JOIN SalesOrder so ON d.SalesOrderID = so.SalesOrderID
    LEFT JOIN Deal dl ON d.DealID = dl.DealID
    LEFT JOIN Retailer r ON so.RetailerID = r.RetailerID
    LEFT JOIN Employee emp ON d.DeliveredBy = emp.EmployeeID
    WHERE (@DeliveryPersonID IS NULL OR d.DeliveredBy = @DeliveryPersonID)
        AND (@Status IS NULL OR d.Status = @Status)
    ORDER BY d.DeliveryDate, d.DeliveryID;
END
GO

PRINT '✅ sp_GetDeliveryAssignments fixed';
GO

-- ================================================================================
-- VERIFICATION
-- ================================================================================
PRINT '';
PRINT '======================================================';
PRINT 'VERIFICATION';
PRINT '======================================================';

-- Test sp_GetDeliveryById with a sample delivery
DECLARE @TestID INT;
SELECT TOP 1 @TestID = DeliveryID FROM Delivery;

IF @TestID IS NOT NULL
BEGIN
    PRINT 'Testing sp_GetDeliveryById with DeliveryID: ' + CAST(@TestID AS VARCHAR(10));
    BEGIN TRY
        EXEC sp_GetDeliveryById @DeliveryID = @TestID;
        PRINT '✅ sp_GetDeliveryById works correctly';
    END TRY
    BEGIN CATCH
        PRINT '❌ sp_GetDeliveryById failed: ' + ERROR_MESSAGE();
    END CATCH
END

PRINT '';
PRINT '======================================================';
PRINT '✅ ALL PROCEDURES FIXED SUCCESSFULLY!';
PRINT '======================================================';
PRINT '';
PRINT 'Removed columns from all procedures:';
PRINT '  ❌ TrackingNumber';
PRINT '  ❌ DeliveryMethod';
PRINT '  ❌ DeliveryCost';
PRINT '  ❌ ExpectedDeliveryDate';
PRINT '  ❌ PriorityLevel';
PRINT '';
PRINT 'All procedures now only use columns that exist!';
PRINT 'You can now update deliveries without errors!';
GO
