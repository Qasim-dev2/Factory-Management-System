-- Update sp_GetDealStatistics to use the new workflow statuses
USE GarmentsFactoryDB;
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetDealStatistics')
    DROP PROCEDURE sp_GetDealStatistics;
GO

CREATE PROCEDURE sp_GetDealStatistics
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        COUNT(*) AS TotalDeals,
        SUM(CASE WHEN Status = 'Pending' THEN 1 ELSE 0 END) AS PendingDeals,
        SUM(CASE WHEN Status = 'Draft' THEN 1 ELSE 0 END) AS DraftDeals,
        SUM(CASE WHEN Status = 'Under Review' THEN 1 ELSE 0 END) AS UnderReviewDeals,
        SUM(CASE WHEN Status = 'Pending Approval' THEN 1 ELSE 0 END) AS PendingApprovalDeals,
        SUM(CASE WHEN Status = 'Approved' THEN 1 ELSE 0 END) AS ApprovedDeals,
        SUM(CASE WHEN Status = 'Active' THEN 1 ELSE 0 END) AS ActiveDeals,
        SUM(CASE WHEN Status = 'In Progress' THEN 1 ELSE 0 END) AS InProgressDeals,
        SUM(CASE WHEN Status = 'Completed' THEN 1 ELSE 0 END) AS CompletedDeals,
        SUM(CASE WHEN Status = 'Cancelled' THEN 1 ELSE 0 END) AS CancelledDeals,
        SUM(ISNULL(EstimatedValue, 0)) AS TotalEstimatedValue,
        AVG(ISNULL(EstimatedValue, 0)) AS AverageEstimatedValue
    FROM Deal;
END
GO

PRINT 'sp_GetDealStatistics updated successfully for workflow statuses';
GO
