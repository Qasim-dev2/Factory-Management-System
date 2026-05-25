-- ================================================================================
-- SIMPLE DATABASE CLEANUP SCRIPT
-- ================================================================================
-- Execute this to remove all sample data
-- ================================================================================

USE GarmentsFactoryDB;
GO

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

PRINT '========================================';
PRINT 'REMOVING ALL SAMPLE DATA';
PRINT '========================================';
GO

-- Delete in correct order to avoid foreign key violations
PRINT 'Clearing TailorTask...';
DELETE FROM TailorTask;
PRINT '  ✅ Deleted ' + CAST(@@ROWCOUNT AS NVARCHAR) + ' rows';
GO

PRINT 'Clearing TailorAssignment...';
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'TailorAssignment')
BEGIN
    DELETE FROM TailorAssignment;
    PRINT '  ✅ Deleted ' + CAST(@@ROWCOUNT AS NVARCHAR) + ' rows';
END
ELSE
    PRINT '  ℹ️  Table does not exist';
GO

PRINT 'Clearing Delivery...';
DELETE FROM Delivery;
PRINT '  ✅ Deleted ' + CAST(@@ROWCOUNT AS NVARCHAR) + ' rows';
GO

PRINT 'Clearing Stock...';
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Stock')
BEGIN
    DELETE FROM Stock;
    PRINT '  ✅ Deleted ' + CAST(@@ROWCOUNT AS NVARCHAR) + ' rows';
END
ELSE
    PRINT '  ℹ️  Table does not exist';
GO

PRINT 'Clearing OrderApproval...';
DELETE FROM OrderApproval;
PRINT '  ✅ Deleted ' + CAST(@@ROWCOUNT AS NVARCHAR) + ' rows';
GO

PRINT 'Clearing ProductionOrder...';
DELETE FROM ProductionOrder;
PRINT '  ✅ Deleted ' + CAST(@@ROWCOUNT AS NVARCHAR) + ' rows';
GO

PRINT 'Clearing SalesOrder...';
DELETE FROM SalesOrder;
PRINT '  ✅ Deleted ' + CAST(@@ROWCOUNT AS NVARCHAR) + ' rows';
GO

PRINT 'Clearing Deal...';
DELETE FROM Deal;
PRINT '  ✅ Deleted ' + CAST(@@ROWCOUNT AS NVARCHAR) + ' rows';
GO

PRINT 'Clearing Retailer...';
DELETE FROM Retailer;
PRINT '  ✅ Deleted ' + CAST(@@ROWCOUNT AS NVARCHAR) + ' rows';
GO

PRINT 'Clearing ProductMaterialRequirement...';
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'ProductMaterialRequirement')
BEGIN
    DELETE FROM ProductMaterialRequirement;
    PRINT '  ✅ Deleted ' + CAST(@@ROWCOUNT AS NVARCHAR) + ' rows';
END
ELSE
    PRINT '  ℹ️  Table does not exist';
GO

PRINT 'Clearing Product...';
DELETE FROM Product;
PRINT '  ✅ Deleted ' + CAST(@@ROWCOUNT AS NVARCHAR) + ' rows';
GO

PRINT 'Clearing Employee...';
DELETE FROM Employee;
PRINT '  ✅ Deleted ' + CAST(@@ROWCOUNT AS NVARCHAR) + ' rows';
GO

-- Reset identity seeds
PRINT '';
PRINT 'Resetting identity seeds...';
DBCC CHECKIDENT ('TailorTask', RESEED, 0);
DBCC CHECKIDENT ('Delivery', RESEED, 0);
DBCC CHECKIDENT ('ProductionOrder', RESEED, 0);
DBCC CHECKIDENT ('OrderApproval', RESEED, 0);
DBCC CHECKIDENT ('SalesOrder', RESEED, 0);
DBCC CHECKIDENT ('Deal', RESEED, 0);
DBCC CHECKIDENT ('Retailer', RESEED, 0);
DBCC CHECKIDENT ('Product', RESEED, 0);
DBCC CHECKIDENT ('Employee', RESEED, 0);
GO

PRINT '';
PRINT '========================================';
PRINT 'FINAL VERIFICATION';
PRINT '========================================';
GO

SELECT 
    'Employees' AS TableName, COUNT(*) AS RecordCount FROM Employee
UNION ALL
SELECT 'Products', COUNT(*) FROM Product
UNION ALL
SELECT 'Retailers', COUNT(*) FROM Retailer
UNION ALL
SELECT 'Sales Orders', COUNT(*) FROM SalesOrder
UNION ALL
SELECT 'Deals', COUNT(*) FROM Deal
UNION ALL
SELECT 'Production Orders', COUNT(*) FROM ProductionOrder
UNION ALL
SELECT 'Deliveries', COUNT(*) FROM Delivery
UNION ALL
SELECT 'Tailor Tasks', COUNT(*) FROM TailorTask
ORDER BY TableName;
GO

PRINT '';
PRINT '✅ ALL SAMPLE DATA REMOVED SUCCESSFULLY';
PRINT '✅ Database is ready for production use';
PRINT '';
PRINT 'Note: Department and EmployeeRole tables were preserved (system configuration)';
GO
