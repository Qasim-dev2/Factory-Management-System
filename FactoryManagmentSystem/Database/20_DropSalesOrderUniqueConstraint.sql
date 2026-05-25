-- ================================================================================
-- DROP UNIQUE CONSTRAINT ON SALESORDERID
-- ================================================================================
-- The UNIQUE constraint on SalesOrderID prevents multiple deliveries with NULL
-- SalesOrderID (for Deals). We need to drop this constraint.
-- ================================================================================

USE GarmentsFactoryDB;
GO

-- Find and drop the UNIQUE constraint on SalesOrderID
DECLARE @ConstraintName NVARCHAR(200);
SELECT @ConstraintName = CONSTRAINT_NAME 
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
WHERE TABLE_NAME = 'Delivery' 
AND CONSTRAINT_TYPE = 'UNIQUE'
AND CONSTRAINT_NAME LIKE 'UQ__Delivery%';

IF @ConstraintName IS NOT NULL
BEGIN
    DECLARE @SQL NVARCHAR(500) = 'ALTER TABLE Delivery DROP CONSTRAINT ' + @ConstraintName;
    EXEC sp_executesql @SQL;
    PRINT '✅ Dropped UNIQUE constraint: ' + @ConstraintName;
END
ELSE
BEGIN
    PRINT '⚠️ No UNIQUE constraint found on Delivery table';
END
GO

-- Verify the constraint is gone
SELECT tc.CONSTRAINT_NAME, kcu.COLUMN_NAME 
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc 
JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE kcu ON tc.CONSTRAINT_NAME = kcu.CONSTRAINT_NAME 
WHERE tc.TABLE_NAME = 'Delivery' 
AND tc.CONSTRAINT_TYPE = 'UNIQUE';
GO

PRINT '';
PRINT '✅ UNIQUE constraint dropped successfully';
PRINT '   Now multiple Deal deliveries can be created';
GO
