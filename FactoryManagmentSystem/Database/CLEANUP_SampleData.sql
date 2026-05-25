/*******************************************************************************
 * CLEANUP SAMPLE DATA - GarmentsFactoryDB
 * 
 * Purpose: Remove all sample/test data from database tables
 * 
 * KEEPS DATA IN:
 * - Departments (reference data)
 * - EmployeeRoles (reference data)
 * 
 * REMOVES DATA FROM:
 * - Products
 * - RawMaterials
 * - Deals & DealItems
 * - SalesOrders & SalesOrderItems
 * - ProductionOrders & ProductionOrderItems
 * - Deliveries
 * - Retailers
 * - Employees (and related credentials)
 * - Stock entries
 * - Stock usage records
 * - Product material requirements
 * - Revenue records
 * - All transactional data
 * 
 * WARNING: This will delete ALL data except Departments and EmployeeRoles
 * Make sure to backup your database before running this script!
 * 
 * Created: December 14, 2025
 ******************************************************************************/

USE GarmentsFactoryDB;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

PRINT '============================================================================';
PRINT 'STARTING SAMPLE DATA CLEANUP';
PRINT 'Timestamp: ' + CONVERT(VARCHAR, GETDATE(), 120);
PRINT '============================================================================';
PRINT '';

-- Disable foreign key constraints temporarily for easier deletion
PRINT 'Disabling foreign key constraints...';
EXEC sp_MSforeachtable 'ALTER TABLE ? NOCHECK CONSTRAINT ALL';
PRINT 'Foreign key constraints disabled.';
PRINT '';

-- ============================================================================
-- STEP 1: Delete Order Approvals (depends on multiple tables)
-- ============================================================================
PRINT '-- STEP 1: Deleting Order Approvals...';
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'OrderApproval')
BEGIN
    DELETE FROM OrderApproval;
    PRINT 'Deleted ' + CAST(@@ROWCOUNT AS VARCHAR) + ' records from OrderApproval';
END
PRINT '';

-- ============================================================================
-- STEP 2: Delete Tailor Assignments (depends on multiple tables)
-- ============================================================================
PRINT '-- STEP 2: Deleting Tailor Assignments...';
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'TailorAssignment')
BEGIN
    DELETE FROM TailorAssignment;
    PRINT 'Deleted ' + CAST(@@ROWCOUNT AS VARCHAR) + ' records from TailorAssignment';
END
PRINT '';

-- ============================================================================
-- STEP 3: Delete Stock (depends on Products, ProductionOrders)
-- ============================================================================
PRINT '-- STEP 3: Deleting Stock...';
DELETE FROM Stock;
PRINT 'Deleted ' + CAST(@@ROWCOUNT AS VARCHAR) + ' records from Stock';
PRINT '';

-- ============================================================================
-- STEP 4: Delete Deliveries (depends on SalesOrders, ProductionOrders, Employees)
-- ============================================================================
PRINT '-- STEP 4: Deleting Deliveries...';
DELETE FROM Delivery;
PRINT 'Deleted ' + CAST(@@ROWCOUNT AS VARCHAR) + ' records from Delivery';
PRINT '';

-- ============================================================================
-- STEP 5: Delete Production Orders (depends on SalesOrders, Employees)
-- ============================================================================
PRINT '-- STEP 5: Deleting Production Orders...';
DELETE FROM ProductionOrder;
PRINT 'Deleted ' + CAST(@@ROWCOUNT AS VARCHAR) + ' records from ProductionOrder';
PRINT '';

-- ============================================================================
-- STEP 6: Delete Sales Order Items (depends on SalesOrders)
-- ============================================================================
PRINT '-- STEP 6: Deleting Sales Order Items...';
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'SalesOrderItem')
BEGIN
    DELETE FROM SalesOrderItem;
    PRINT 'Deleted ' + CAST(@@ROWCOUNT AS VARCHAR) + ' records from SalesOrderItem';
END
PRINT '';

-- ============================================================================
-- STEP 7: Delete Sales Orders (depends on Retailers, Employees, Products)
-- ============================================================================
PRINT '-- STEP 7: Deleting Sales Orders...';
DELETE FROM SalesOrder;
PRINT 'Deleted ' + CAST(@@ROWCOUNT AS VARCHAR) + ' records from SalesOrder';
PRINT '';

-- ============================================================================
-- STEP 8: Delete Deal Items (depends on Deals)
-- ============================================================================
PRINT '-- STEP 8: Deleting Deal Items...';
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'DealItem')
BEGIN
    DELETE FROM DealItem;
    PRINT 'Deleted ' + CAST(@@ROWCOUNT AS VARCHAR) + ' records from DealItem';
END
PRINT '';

-- ============================================================================
-- STEP 9: Delete Deals (depends on Retailers, Employees, Products)
-- ============================================================================
PRINT '-- STEP 9: Deleting Deals...';
DELETE FROM Deal;
PRINT 'Deleted ' + CAST(@@ROWCOUNT AS VARCHAR) + ' records from Deal';
PRINT '';

-- ============================================================================
-- STEP 10: Delete Product Material Requirements
-- ============================================================================
PRINT '-- STEP 10: Deleting Product Material Requirements...';
DELETE FROM ProductMaterialRequirement;
PRINT 'Deleted ' + CAST(@@ROWCOUNT AS VARCHAR) + ' records from ProductMaterialRequirement';
PRINT '';

-- ============================================================================
-- STEP 11: Delete Revenue Records
-- ============================================================================
PRINT '-- STEP 11: Deleting Revenue Records...';
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'MonthlyRevenue')
BEGIN
    DELETE FROM MonthlyRevenue;
    PRINT 'Deleted ' + CAST(@@ROWCOUNT AS VARCHAR) + ' records from MonthlyRevenue';
END

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'MiscExpense')
BEGIN
    DELETE FROM MiscExpense;
    PRINT 'Deleted ' + CAST(@@ROWCOUNT AS VARCHAR) + ' records from MiscExpense';
END

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'RawMaterialPurchase')
BEGIN
    DELETE FROM RawMaterialPurchase;
    PRINT 'Deleted ' + CAST(@@ROWCOUNT AS VARCHAR) + ' records from RawMaterialPurchase';
END

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'SalaryPayment')
BEGIN
    DELETE FROM SalaryPayment;
    PRINT 'Deleted ' + CAST(@@ROWCOUNT AS VARCHAR) + ' records from SalaryPayment';
END
PRINT '';

-- ============================================================================
-- STEP 12: Delete Retailers
-- ============================================================================
PRINT '-- STEP 12: Deleting Retailers...';
DELETE FROM Retailer;
PRINT 'Deleted ' + CAST(@@ROWCOUNT AS VARCHAR) + ' records from Retailer';
PRINT '';

-- ============================================================================
-- STEP 13: Delete Products
-- ============================================================================
PRINT '-- STEP 13: Deleting Products...';
DELETE FROM Product;
PRINT 'Deleted ' + CAST(@@ROWCOUNT AS VARCHAR) + ' records from Product';
PRINT '';

-- ============================================================================
-- STEP 14: Delete Raw Materials
-- ============================================================================
PRINT '-- STEP 14: Deleting Raw Materials...';
DELETE FROM RawMaterial;
PRINT 'Deleted ' + CAST(@@ROWCOUNT AS VARCHAR) + ' records from RawMaterial';
PRINT '';

-- ============================================================================
-- STEP 15: Delete Employees
-- ============================================================================
PRINT '-- STEP 15: Deleting Employees...';
DELETE FROM Employee;
PRINT 'Deleted ' + CAST(@@ROWCOUNT AS VARCHAR) + ' records from Employee';
PRINT '';

-- ============================================================================
-- STEP 19: Re-enable foreign key constraints
-- ============================================================================
PRINT 'Re-enabling foreign key constraints...';
EXEC sp_MSforeachtable 'ALTER TABLE ? WITH CHECK CHECK CONSTRAINT ALL';
PRINT 'Foreign key constraints re-enabled.';
PRINT '';

-- ============================================================================
-- STEP 20: Reset Identity Seeds (Start from 1 again)
-- ============================================================================
PRINT '-- STEP 20: Resetting Identity Seeds...';

-- Reset all identity seeds
DBCC CHECKIDENT ('Product', RESEED, 0);
DBCC CHECKIDENT ('RawMaterial', RESEED, 0);
DBCC CHECKIDENT ('Retailer', RESEED, 0);
DBCC CHECKIDENT ('Employee', RESEED, 0);
DBCC CHECKIDENT ('Deal', RESEED, 0);
DBCC CHECKIDENT ('SalesOrder', RESEED, 0);
DBCC CHECKIDENT ('ProductionOrder', RESEED, 0);
DBCC CHECKIDENT ('Delivery', RESEED, 0);
DBCC CHECKIDENT ('Stock', RESEED, 0);

PRINT 'Identity seeds reset successfully.';
PRINT '';

-- ============================================================================
-- VERIFICATION: Check remaining data
-- ============================================================================
PRINT '============================================================================';
PRINT 'VERIFICATION - Remaining Data Count';
PRINT '============================================================================';

PRINT 'Tables with DATA PRESERVED (should have records):';
SELECT 'Department' AS TableName, COUNT(*) AS RecordCount FROM Department
UNION ALL
SELECT 'EmployeeRole', COUNT(*) FROM EmployeeRole;

PRINT '';
PRINT 'Tables with DATA REMOVED (should be 0):';
SELECT 'Product' AS TableName, COUNT(*) AS RecordCount FROM Product
UNION ALL SELECT 'RawMaterial', COUNT(*) FROM RawMaterial
UNION ALL SELECT 'Retailer', COUNT(*) FROM Retailer
UNION ALL SELECT 'Employee', COUNT(*) FROM Employee
UNION ALL SELECT 'Deal', COUNT(*) FROM Deal
UNION ALL SELECT 'SalesOrder', COUNT(*) FROM SalesOrder
UNION ALL SELECT 'ProductionOrder', COUNT(*) FROM ProductionOrder
UNION ALL SELECT 'Delivery', COUNT(*) FROM Delivery
UNION ALL SELECT 'Stock', COUNT(*) FROM Stock
UNION ALL SELECT 'ProductMaterialRequirement', COUNT(*) FROM ProductMaterialRequirement;

PRINT '';

PRINT '============================================================================';
PRINT 'CLEANUP COMPLETED SUCCESSFULLY';
PRINT 'Timestamp: ' + CONVERT(VARCHAR, GETDATE(), 120);
PRINT '============================================================================';
PRINT '';
PRINT 'Next Steps:';
PRINT '1. Your database is now clean and ready for production data';
PRINT '2. Departments and EmployeeRoles are preserved';
PRINT '3. All identity seeds have been reset to start from 1';
PRINT '4. Add your real production data when ready';
PRINT '';
PRINT 'IMPORTANT NOTES:';
PRINT '- You will need to create at least one Employee with credentials to login';
PRINT '- Run the authentication setup script if you need default admin user';
PRINT '- Consider backing up this clean state before adding production data';

GO

/*******************************************************************************
 * QUICK ADMIN USER CREATION (OPTIONAL)
 * 
 * Uncomment the section below to create a default admin user for testing
 ******************************************************************************/

/*
-- Create default Owner/Admin user
PRINT '';
PRINT 'Creating default admin user...';

-- Insert admin employee
INSERT INTO Employee (FirstName, LastName, Email, Phone, RoleID, DepartmentID, HireDate, Salary, IsActive)
VALUES ('Admin', 'User', 'admin@factory.com', '0300-0000000', 1, 1, GETDATE(), 50000, 1);

DECLARE @AdminEmployeeID INT = SCOPE_IDENTITY();

PRINT 'Default admin user created:';
PRINT '  Username: admin';
PRINT '  Password: admin123';
PRINT '  Employee ID: ' + CAST(@AdminEmployeeID AS VARCHAR);

PRINT '';
*/

/*******************************************************************************
 * END OF CLEANUP SCRIPT
 ******************************************************************************/
