-- ================================================================================
-- FIX DELIVERY TABLE - MAKE SalesOrderID NULLABLE
-- ================================================================================
-- This script makes SalesOrderID nullable so we can insert Deal deliveries
-- ================================================================================

USE GarmentsFactoryDB;
GO

PRINT 'Fixing Delivery table constraints...';

-- First, drop the foreign key constraint on SalesOrderID
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_Delivery_SalesOrder')
BEGIN
    ALTER TABLE Delivery
    DROP CONSTRAINT FK_Delivery_SalesOrder;
    PRINT 'Dropped FK_Delivery_SalesOrder constraint';
END
GO

-- Make SalesOrderID nullable
ALTER TABLE Delivery
ALTER COLUMN SalesOrderID INT NULL;
GO

PRINT 'SalesOrderID is now nullable';

-- Re-add the foreign key constraint
ALTER TABLE Delivery
ADD CONSTRAINT FK_Delivery_SalesOrder 
    FOREIGN KEY (SalesOrderID) REFERENCES SalesOrder(SalesOrderID);
GO

PRINT 'Re-added FK_Delivery_SalesOrder constraint';

-- Verify the change
SELECT 
    COLUMN_NAME, 
    IS_NULLABLE,
    DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'Delivery' 
AND COLUMN_NAME IN ('SalesOrderID', 'DealID');
GO

PRINT '========================================';
PRINT 'DELIVERY TABLE FIX COMPLETE!';
PRINT 'SalesOrderID is now nullable';
PRINT 'Can now insert deliveries for both SalesOrders and Deals';
PRINT '========================================';
GO
