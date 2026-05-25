-- =============================================
-- FIX FILTERED INDEXES AND CLEANUP ORDER APPROVAL
-- Resolves QUOTED_IDENTIFIER error when deleting
-- Date: December 17, 2025
-- =============================================

USE GarmentsFactoryDB;
GO

PRINT '======================================='
PRINT 'STEP 1: Drop Filtered Indexes'
PRINT '======================================='

-- Drop the filtered indexes that are causing issues
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_OrderApproval_SalesOrderID' AND object_id = OBJECT_ID('OrderApproval'))
BEGIN
    DROP INDEX IX_OrderApproval_SalesOrderID ON OrderApproval;
    PRINT '✓ Dropped IX_OrderApproval_SalesOrderID'
END

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_OrderApproval_DealID' AND object_id = OBJECT_ID('OrderApproval'))
BEGIN
    DROP INDEX IX_OrderApproval_DealID ON OrderApproval;
    PRINT '✓ Dropped IX_OrderApproval_DealID'
END

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_OrderApproval_ApprovedBy' AND object_id = OBJECT_ID('OrderApproval'))
BEGIN
    DROP INDEX IX_OrderApproval_ApprovedBy ON OrderApproval;
    PRINT '✓ Dropped IX_OrderApproval_ApprovedBy'
END

GO

PRINT ''
PRINT '======================================='
PRINT 'STEP 2: Recreate Indexes WITHOUT Filters'
PRINT '======================================='

-- Recreate as regular (non-filtered) indexes
CREATE NONCLUSTERED INDEX IX_OrderApproval_SalesOrderID
ON OrderApproval(SalesOrderID);
PRINT '✓ Created IX_OrderApproval_SalesOrderID (no filter)'

CREATE NONCLUSTERED INDEX IX_OrderApproval_DealID
ON OrderApproval(DealID);
PRINT '✓ Created IX_OrderApproval_DealID (no filter)'

CREATE NONCLUSTERED INDEX IX_OrderApproval_ApprovedBy
ON OrderApproval(ApprovedBy);
PRINT '✓ Created IX_OrderApproval_ApprovedBy (no filter)'

GO

PRINT ''
PRINT '======================================='
PRINT 'STEP 3: Delete All OrderApproval Entries'
PRINT '======================================='

DECLARE @RowCount INT;

-- Delete all entries from OrderApproval
DELETE FROM OrderApproval;
SET @RowCount = @@ROWCOUNT;

PRINT '✓ Deleted ' + CAST(@RowCount AS VARCHAR(10)) + ' entries from OrderApproval'

GO

PRINT ''
PRINT '======================================='
PRINT 'STEP 4: Verify Cleanup'
PRINT '======================================='

-- Verify OrderApproval is empty
SELECT COUNT(*) AS [Remaining Entries]
FROM OrderApproval;

-- Verify indexes are in place
SELECT 
    i.name AS [Index Name],
    i.type_desc AS [Index Type],
    i.is_unique AS [Is Unique],
    i.has_filter AS [Has Filter]
FROM sys.indexes i
WHERE i.object_id = OBJECT_ID('OrderApproval')
  AND i.name IS NOT NULL
ORDER BY i.name;

PRINT ''
PRINT '======================================='
PRINT 'CLEANUP COMPLETE!'
PRINT '======================================='
PRINT '✓ Filtered indexes removed'
PRINT '✓ Regular indexes recreated'
PRINT '✓ OrderApproval table emptied'
PRINT '✓ Can now delete deals without errors'
PRINT '======================================='

GO
