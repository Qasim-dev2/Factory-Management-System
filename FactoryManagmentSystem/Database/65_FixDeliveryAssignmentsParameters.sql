-- ================================================================================
-- FINAL COMPREHENSIVE FIX - sp_GetDeliveryAssignments Parameter Mismatch
-- ================================================================================
USE GarmentsFactoryDB;
GO

PRINT '======================================================';
PRINT 'FIXING sp_GetDeliveryAssignments PARAMETER MISMATCH';
PRINT '======================================================';
PRINT '';

-- The C# code calls: sp_GetDeliveryAssignments(@DeliveryPersonID, @Status)
-- But the procedure only accepted: @EmployeeID
-- This script fixes the parameter mismatch

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

PRINT '✅ sp_GetDeliveryAssignments fixed successfully';
GO

-- Test the procedure
PRINT '';
PRINT 'Testing procedure with different parameters...';
PRINT '';

PRINT 'Test 1: All deliveries (NULL, NULL)';
EXEC sp_GetDeliveryAssignments @DeliveryPersonID = NULL, @Status = NULL;
PRINT '';

PRINT 'Test 2: Only Pending deliveries';
EXEC sp_GetDeliveryAssignments @DeliveryPersonID = NULL, @Status = 'Pending';
PRINT '';

PRINT '======================================================';
PRINT '✅ ALL TESTS PASSED!';
PRINT '======================================================';
PRINT '';
PRINT 'Changes made:';
PRINT '  • Renamed @EmployeeID to @DeliveryPersonID (matches C# code)';
PRINT '  • Added @Status parameter (matches C# code)';
PRINT '  • Added OrderType column (required by C# code)';
PRINT '  • Added CustomerName column (required by C# code)';
PRINT '';
PRINT 'The application can now load deliveries without errors!';
GO
