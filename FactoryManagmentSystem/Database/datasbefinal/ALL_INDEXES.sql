-- =============================================
-- FACTORY MANAGEMENT SYSTEM - ALL INDEXES
-- Database: GarmentsFactoryDB
-- Total: 25 Indexes
-- =============================================

USE GarmentsFactoryDB;
GO

-- =============================================
-- EMPLOYEE TABLE INDEXES (4)
-- =============================================

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Employee_DepartmentID')
    CREATE NONCLUSTERED INDEX IX_Employee_DepartmentID ON Employee(DepartmentID);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Employee_RoleID')
    CREATE NONCLUSTERED INDEX IX_Employee_RoleID ON Employee(RoleID);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Employee_Username')
    CREATE NONCLUSTERED INDEX IX_Employee_Username ON Employee(Username);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Employee_IsActive')
    CREATE NONCLUSTERED INDEX IX_Employee_IsActive ON Employee(IsActive);

PRINT '✓ Employee indexes created (4)';
GO

-- =============================================
-- SALES ORDER TABLE INDEXES (3)
-- =============================================

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_SalesOrder_RetailerID')
    CREATE NONCLUSTERED INDEX IX_SalesOrder_RetailerID ON SalesOrder(RetailerID);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_SalesOrder_Status')
    CREATE NONCLUSTERED INDEX IX_SalesOrder_Status ON SalesOrder(Status);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_SalesOrder_OrderDate')
    CREATE NONCLUSTERED INDEX IX_SalesOrder_OrderDate ON SalesOrder(OrderDate);

PRINT '✓ SalesOrder indexes created (3)';
GO

-- =============================================
-- SALES ORDER ITEM TABLE INDEX (1)
-- =============================================

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_SalesOrderItem_SalesOrderID')
    CREATE NONCLUSTERED INDEX IX_SalesOrderItem_SalesOrderID ON SalesOrderItem(SalesOrderID);

PRINT '✓ SalesOrderItem index created (1)';
GO

-- =============================================
-- DEAL TABLE INDEXES (2)
-- =============================================

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Deal_Status')
    CREATE NONCLUSTERED INDEX IX_Deal_Status ON Deal(Status);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Deal_CreatedBy')
    CREATE NONCLUSTERED INDEX IX_Deal_CreatedBy ON Deal(CreatedBy);

PRINT '✓ Deal indexes created (2)';
GO

-- =============================================
-- PRODUCTION ORDER TABLE INDEXES (2)
-- =============================================

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_ProductionOrder_Status')
    CREATE NONCLUSTERED INDEX IX_ProductionOrder_Status ON ProductionOrder(Status);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_ProductionOrder_ProductID')
    CREATE NONCLUSTERED INDEX IX_ProductionOrder_ProductID ON ProductionOrder(ProductID);

PRINT '✓ ProductionOrder indexes created (2)';
GO

-- =============================================
-- TAILOR ASSIGNMENT TABLE INDEXES (2)
-- =============================================

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_TailorAssignment_TailorID')
    CREATE NONCLUSTERED INDEX IX_TailorAssignment_TailorID ON TailorAssignment(TailorID);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_TailorAssignment_Status')
    CREATE NONCLUSTERED INDEX IX_TailorAssignment_Status ON TailorAssignment(Status);

PRINT '✓ TailorAssignment indexes created (2)';
GO

-- =============================================
-- DELIVERY TABLE INDEXES (3)
-- =============================================

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Delivery_Status')
    CREATE NONCLUSTERED INDEX IX_Delivery_Status ON Delivery(Status);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Delivery_SalesOrderID')
    CREATE NONCLUSTERED INDEX IX_Delivery_SalesOrderID ON Delivery(SalesOrderID);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Delivery_DealID')
    CREATE NONCLUSTERED INDEX IX_Delivery_DealID ON Delivery(DealID);

PRINT '✓ Delivery indexes created (3)';
GO

-- =============================================
-- ORDER APPROVAL TABLE INDEXES (3)
-- =============================================

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_OrderApproval_SalesOrderID')
    CREATE NONCLUSTERED INDEX IX_OrderApproval_SalesOrderID ON OrderApproval(SalesOrderID);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_OrderApproval_DealID')
    CREATE NONCLUSTERED INDEX IX_OrderApproval_DealID ON OrderApproval(DealID);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_OrderApproval_Status')
    CREATE NONCLUSTERED INDEX IX_OrderApproval_Status ON OrderApproval(Status);

PRINT '✓ OrderApproval indexes created (3)';
GO

-- =============================================
-- RETAILER TABLE INDEX (1)
-- =============================================

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Retailer_SalesRepID')
    CREATE NONCLUSTERED INDEX IX_Retailer_SalesRepID ON Retailer(SalesRepID);

PRINT '✓ Retailer index created (1)';
GO

-- =============================================
-- MONTHLY REVENUE TABLE INDEX (1)
-- =============================================

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_MonthlyRevenue_Year')
    CREATE NONCLUSTERED INDEX IX_MonthlyRevenue_Year ON MonthlyRevenue([Year]);

PRINT '✓ MonthlyRevenue index created (1)';
GO

-- =============================================
-- RAW MATERIAL TABLE INDEX (1)
-- =============================================

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_RawMaterial_Category')
    CREATE NONCLUSTERED INDEX IX_RawMaterial_Category ON RawMaterial(Category);

PRINT '✓ RawMaterial index created (1)';
GO

-- =============================================
-- PRODUCT TABLE INDEX (1)
-- =============================================

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Product_Category')
    CREATE NONCLUSTERED INDEX IX_Product_Category ON Product(Category);

PRINT '✓ Product index created (1)';
GO

-- =============================================
-- VIEW ALL INDEXES
-- =============================================

/*
SELECT 
    t.name AS TableName,
    i.name AS IndexName,
    i.type_desc AS IndexType,
    c.name AS ColumnName
FROM sys.indexes i
INNER JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
INNER JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
INNER JOIN sys.tables t ON i.object_id = t.object_id
WHERE i.name LIKE 'IX_%'
ORDER BY t.name, i.name;
*/

PRINT '';
PRINT '========================================';
PRINT 'ALL INDEXES CREATED SUCCESSFULLY';
PRINT 'Total: 25 Indexes';
PRINT '========================================';
PRINT '';
PRINT 'Index Summary by Table:';
PRINT '- Employee: 4 indexes';
PRINT '- SalesOrder: 3 indexes';
PRINT '- SalesOrderItem: 1 index';
PRINT '- Deal: 2 indexes';
PRINT '- ProductionOrder: 2 indexes';
PRINT '- TailorAssignment: 2 indexes';
PRINT '- Delivery: 3 indexes';
PRINT '- OrderApproval: 3 indexes';
PRINT '- Retailer: 1 index';
PRINT '- MonthlyRevenue: 1 index';
PRINT '- RawMaterial: 1 index';
PRINT '- Product: 1 index';
PRINT '========================================';
GO
