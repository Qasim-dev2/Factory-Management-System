-- ================================================================================
-- FIX DELIVERY STATISTICS PROCEDURE
-- ================================================================================
-- This fixes sp_GetDeliveryStatistics to return correct column names
-- ================================================================================

USE GarmentsFactoryDB;
GO

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

PRINT '========================================';
PRINT 'FIXING DELIVERY STATISTICS PROCEDURE';
PRINT '========================================';
GO

-- Drop and recreate sp_GetDeliveryStatistics
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetDeliveryStatistics')
    DROP PROCEDURE sp_GetDeliveryStatistics;
GO

CREATE PROCEDURE sp_GetDeliveryStatistics
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        COUNT(*) AS TotalDeliveries,
        SUM(CASE WHEN Status = 'Pending' THEN 1 ELSE 0 END) AS PendingDeliveries,
        SUM(CASE WHEN Status = 'InTransit' THEN 1 ELSE 0 END) AS InTransitDeliveries,
        SUM(CASE WHEN Status = 'Delivered' THEN 1 ELSE 0 END) AS DeliveredCount,
        SUM(CASE WHEN Status = 'Failed' THEN 1 ELSE 0 END) AS FailedDeliveries,
        SUM(CASE WHEN Status = 'Returned' THEN 1 ELSE 0 END) AS ReturnedDeliveries,
        SUM(CASE WHEN CAST(DeliveryDate AS DATE) = CAST(GETDATE() AS DATE) THEN 1 ELSE 0 END) AS TodayDeliveries,
        SUM(CASE WHEN DeliveryDate >= DATEADD(DAY, -7, GETDATE()) THEN 1 ELSE 0 END) AS LastWeekDeliveries,
        SUM(CASE WHEN DeliveryDate >= DATEADD(MONTH, -1, GETDATE()) THEN 1 ELSE 0 END) AS LastMonthDeliveries,
        ISNULL(SUM(DeliveryCost), 0) AS TotalDeliveryCost,
        ISNULL(AVG(DeliveryCost), 0) AS AverageDeliveryCost
    FROM Delivery;
END
GO

PRINT '✅ sp_GetDeliveryStatistics created successfully';
GO

-- Test the procedure
PRINT '';
PRINT 'Testing statistics...';
EXEC sp_GetDeliveryStatistics;
GO

PRINT '';
PRINT '========================================';
PRINT '✅ DELIVERY STATISTICS FIX COMPLETE';
PRINT '========================================';
GO
