-- ================================================================================
-- FIX ALL IDENTITY VALUES
-- Reseeds all tables to prevent duplicate key errors
-- ================================================================================
USE GarmentsFactoryDB;
GO

PRINT '========================================';
PRINT 'CHECKING AND FIXING IDENTITY VALUES';
PRINT '========================================';
PRINT '';

-- Deal Table
DECLARE @MaxDealID INT = (SELECT ISNULL(MAX(DealID), 0) FROM Deal);
PRINT 'Deal - Max ID: ' + CAST(@MaxDealID AS NVARCHAR);
IF @MaxDealID > 0
    DBCC CHECKIDENT ('Deal', RESEED, @MaxDealID);
GO

-- SalesOrder Table
DECLARE @MaxSalesOrderID INT = (SELECT ISNULL(MAX(SalesOrderID), 0) FROM SalesOrder);
PRINT 'SalesOrder - Max ID: ' + CAST(@MaxSalesOrderID AS NVARCHAR);
IF @MaxSalesOrderID > 0
    DBCC CHECKIDENT ('SalesOrder', RESEED, @MaxSalesOrderID);
GO

-- ProductionOrder Table
DECLARE @MaxProductionOrderID INT = (SELECT ISNULL(MAX(ProductionOrderID), 0) FROM ProductionOrder);
PRINT 'ProductionOrder - Max ID: ' + CAST(@MaxProductionOrderID AS NVARCHAR);
IF @MaxProductionOrderID > 0
    DBCC CHECKIDENT ('ProductionOrder', RESEED, @MaxProductionOrderID);
GO

-- Delivery Table
DECLARE @MaxDeliveryID INT = (SELECT ISNULL(MAX(DeliveryID), 0) FROM Delivery);
PRINT 'Delivery - Max ID: ' + CAST(@MaxDeliveryID AS NVARCHAR);
IF @MaxDeliveryID > 0
    DBCC CHECKIDENT ('Delivery', RESEED, @MaxDeliveryID);
GO

-- OrderApproval Table
DECLARE @MaxApprovalID INT = (SELECT ISNULL(MAX(ApprovalID), 0) FROM OrderApproval);
PRINT 'OrderApproval - Max ID: ' + CAST(@MaxApprovalID AS NVARCHAR);
IF @MaxApprovalID > 0
    DBCC CHECKIDENT ('OrderApproval', RESEED, @MaxApprovalID);
GO

-- Retailer Table
DECLARE @MaxRetailerID INT = (SELECT ISNULL(MAX(RetailerID), 0) FROM Retailer);
PRINT 'Retailer - Max ID: ' + CAST(@MaxRetailerID AS NVARCHAR);
IF @MaxRetailerID > 0
    DBCC CHECKIDENT ('Retailer', RESEED, @MaxRetailerID);
GO

-- RawMaterial Table
DECLARE @MaxRawMaterialID INT = (SELECT ISNULL(MAX(RawMaterialID), 0) FROM RawMaterial);
PRINT 'RawMaterial - Max ID: ' + CAST(@MaxRawMaterialID AS NVARCHAR);
IF @MaxRawMaterialID > 0
    DBCC CHECKIDENT ('RawMaterial', RESEED, @MaxRawMaterialID);
GO

PRINT '';
PRINT '========================================';
PRINT '✅ ALL IDENTITY VALUES FIXED!';
PRINT '========================================';
PRINT 'You can now add new deals, sales orders, etc. without duplicate key errors.';
GO
