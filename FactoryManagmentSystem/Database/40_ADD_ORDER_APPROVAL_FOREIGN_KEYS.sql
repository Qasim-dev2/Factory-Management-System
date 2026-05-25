-- =============================================
-- ADD FOREIGN KEY CONSTRAINTS TO ORDER APPROVAL
-- Fixes referential integrity issues
-- Date: December 17, 2025
-- =============================================

USE GarmentsFactoryDB;
GO

PRINT '======================================='
PRINT 'STEP 1: Check for Orphaned Records'
PRINT '======================================='

-- Check for invalid SalesOrderID references
SELECT 'OrderApproval records with invalid SalesOrderID' AS Issue,
       COUNT(*) AS RecordCount
FROM OrderApproval oa
WHERE oa.SalesOrderID IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM SalesOrder so WHERE so.SalesOrderID = oa.SalesOrderID);

-- Check for invalid DealID references
SELECT 'OrderApproval records with invalid DealID' AS Issue,
       COUNT(*) AS RecordCount
FROM OrderApproval oa
WHERE oa.DealID IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM Deal d WHERE d.DealID = oa.DealID);

-- Check for invalid ApprovedBy references
SELECT 'OrderApproval records with invalid ApprovedBy' AS Issue,
       COUNT(*) AS RecordCount
FROM OrderApproval oa
WHERE oa.ApprovedBy IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM Employee e WHERE e.EmployeeID = oa.ApprovedBy);

-- Check for invalid RequestedByEmployeeID references
SELECT 'OrderApproval records with invalid RequestedByEmployeeID' AS Issue,
       COUNT(*) AS RecordCount
FROM OrderApproval oa
WHERE oa.RequestedByEmployeeID IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM Employee e WHERE e.EmployeeID = oa.RequestedByEmployeeID);

GO

PRINT '======================================='
PRINT 'STEP 2: Drop Existing Foreign Keys (if any)'
PRINT '======================================='

-- Drop existing foreign keys if they exist
DECLARE @SQL NVARCHAR(MAX) = '';

SELECT @SQL = @SQL + 'ALTER TABLE OrderApproval DROP CONSTRAINT ' + name + ';' + CHAR(13)
FROM sys.foreign_keys
WHERE parent_object_id = OBJECT_ID('OrderApproval');

IF LEN(@SQL) > 0
BEGIN
    PRINT 'Dropping existing foreign keys...'
    EXEC sp_executesql @SQL;
    PRINT 'Existing foreign keys dropped.'
END
ELSE
BEGIN
    PRINT 'No existing foreign keys found (as expected).'
END

GO

PRINT '======================================='
PRINT 'STEP 3: Add Foreign Key Constraints'
PRINT '======================================='

-- Foreign Key 1: OrderApproval.SalesOrderID → SalesOrder.SalesOrderID
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_OrderApproval_SalesOrder')
BEGIN
    ALTER TABLE OrderApproval
    ADD CONSTRAINT FK_OrderApproval_SalesOrder
    FOREIGN KEY (SalesOrderID)
    REFERENCES SalesOrder(SalesOrderID)
    ON DELETE CASCADE;
    
    PRINT '✓ Added FK: OrderApproval.SalesOrderID → SalesOrder.SalesOrderID'
END
ELSE
    PRINT '- FK already exists: FK_OrderApproval_SalesOrder'

GO

-- Foreign Key 2: OrderApproval.DealID → Deal.DealID
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_OrderApproval_Deal')
BEGIN
    ALTER TABLE OrderApproval
    ADD CONSTRAINT FK_OrderApproval_Deal
    FOREIGN KEY (DealID)
    REFERENCES Deal(DealID)
    ON DELETE CASCADE;
    
    PRINT '✓ Added FK: OrderApproval.DealID → Deal.DealID'
END
ELSE
    PRINT '- FK already exists: FK_OrderApproval_Deal'

GO

-- Foreign Key 3: OrderApproval.ApprovedBy → Employee.EmployeeID
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_OrderApproval_ApprovedBy_Employee')
BEGIN
    ALTER TABLE OrderApproval
    ADD CONSTRAINT FK_OrderApproval_ApprovedBy_Employee
    FOREIGN KEY (ApprovedBy)
    REFERENCES Employee(EmployeeID)
    ON DELETE NO ACTION;  -- Don't delete approval if employee deleted
    
    PRINT '✓ Added FK: OrderApproval.ApprovedBy → Employee.EmployeeID'
END
ELSE
    PRINT '- FK already exists: FK_OrderApproval_ApprovedBy_Employee'

GO

-- Foreign Key 4: OrderApproval.RequestedByEmployeeID → Employee.EmployeeID
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_OrderApproval_RequestedBy_Employee')
BEGIN
    ALTER TABLE OrderApproval
    ADD CONSTRAINT FK_OrderApproval_RequestedBy_Employee
    FOREIGN KEY (RequestedByEmployeeID)
    REFERENCES Employee(EmployeeID)
    ON DELETE NO ACTION;  -- Don't delete approval if employee deleted
    
    PRINT '✓ Added FK: OrderApproval.RequestedByEmployeeID → Employee.EmployeeID'
END
ELSE
    PRINT '- FK already exists: FK_OrderApproval_RequestedBy_Employee'

GO

PRINT '======================================='
PRINT 'STEP 4: Create Supporting Indexes'
PRINT '======================================='

-- Index on SalesOrderID for better join performance
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_OrderApproval_SalesOrderID' AND object_id = OBJECT_ID('OrderApproval'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_OrderApproval_SalesOrderID
    ON OrderApproval(SalesOrderID)
    WHERE SalesOrderID IS NOT NULL;
    
    PRINT '✓ Created index: IX_OrderApproval_SalesOrderID'
END

-- Index on DealID for better join performance
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_OrderApproval_DealID' AND object_id = OBJECT_ID('OrderApproval'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_OrderApproval_DealID
    ON OrderApproval(DealID)
    WHERE DealID IS NOT NULL;
    
    PRINT '✓ Created index: IX_OrderApproval_DealID'
END

-- Index on ApprovedBy for better employee lookups
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_OrderApproval_ApprovedBy' AND object_id = OBJECT_ID('OrderApproval'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_OrderApproval_ApprovedBy
    ON OrderApproval(ApprovedBy)
    WHERE ApprovedBy IS NOT NULL;
    
    PRINT '✓ Created index: IX_OrderApproval_ApprovedBy'
END

GO

PRINT '======================================='
PRINT 'STEP 5: Verify Foreign Keys'
PRINT '======================================='

-- Display all foreign keys on OrderApproval table
SELECT 
    fk.name AS ForeignKeyName,
    OBJECT_NAME(fk.parent_object_id) AS TableName,
    COL_NAME(fkc.parent_object_id, fkc.parent_column_id) AS ColumnName,
    OBJECT_NAME(fk.referenced_object_id) AS ReferencedTable,
    COL_NAME(fkc.referenced_object_id, fkc.referenced_column_id) AS ReferencedColumn,
    fk.delete_referential_action_desc AS OnDelete
FROM sys.foreign_keys AS fk
INNER JOIN sys.foreign_key_columns AS fkc 
    ON fk.object_id = fkc.constraint_object_id
WHERE OBJECT_NAME(fk.parent_object_id) = 'OrderApproval'
ORDER BY fk.name;

PRINT ''
PRINT '======================================='
PRINT 'FOREIGN KEY SETUP COMPLETE!'
PRINT '======================================='
PRINT 'OrderApproval table now has proper referential integrity:'
PRINT '- SalesOrderID → SalesOrder (ON DELETE CASCADE)'
PRINT '- DealID → Deal (ON DELETE CASCADE)'
PRINT '- ApprovedBy → Employee (ON DELETE NO ACTION)'
PRINT '- RequestedByEmployeeID → Employee (ON DELETE NO ACTION)'
PRINT ''
PRINT 'Benefits:'
PRINT '✓ Data integrity enforced'
PRINT '✓ Invalid references prevented'
PRINT '✓ Auto-cleanup of approvals when orders deleted'
PRINT '✓ Better query performance with indexes'
PRINT '======================================='

GO
