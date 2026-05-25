-- ================================================================================
-- 🚀 GARMENTS FACTORY DATABASE - COMPLETE SETUP SCRIPT
-- ================================================================================
-- Database: GarmentsFactoryDB
-- Server: QASIM\SQLEXPRESS
-- Purpose: Master setup script - Execute this to set up entire database
-- Version: 1.0
-- Date: December 2025
-- ================================================================================
-- 
-- EXECUTION ORDER:
-- This script references all files in the correct order for complete setup.
-- Execute each file separately in SQL Server Management Studio (SSMS).
-- 
-- ESTIMATED TIME: 5-10 minutes for complete setup
-- 
-- ================================================================================

USE master;
GO

PRINT '========================================';
PRINT '🏭 GARMENTS FACTORY DATABASE SETUP';
PRINT '========================================';
PRINT '';
PRINT 'Server: QASIM\SQLEXPRESS';
PRINT 'Database: GarmentsFactoryDB';
PRINT 'Setup Date: ' + CONVERT(VARCHAR, GETDATE(), 120);
PRINT '';
PRINT '========================================';
GO

-- ================================================================================
-- STEP 1: DATABASE CREATION (IF NOT EXISTS)
-- ================================================================================

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'GarmentsFactoryDB')
BEGIN
    PRINT 'Creating database: GarmentsFactoryDB...';
    CREATE DATABASE GarmentsFactoryDB;
    PRINT '✓ Database created successfully';
END
ELSE
BEGIN
    PRINT '⚠ Database already exists: GarmentsFactoryDB';
    PRINT '  Continuing with setup...';
END
GO

USE GarmentsFactoryDB;
GO

PRINT '';
PRINT '========================================';
PRINT 'SETUP INSTRUCTIONS';
PRINT '========================================';
PRINT '';
PRINT 'Execute the following files IN ORDER:';
PRINT '';
PRINT '📁 PHASE 1: DATABASE STRUCTURE';
PRINT '-------------------------------';
PRINT '1. 95_CompleteDatabase_Schema.sql';
PRINT '   → Creates all 21 tables';
PRINT '   → Creates 24 foreign key relationships';
PRINT '   → Creates 24 performance indexes';
PRINT '   → Time: ~2 minutes';
PRINT '';
PRINT '📁 PHASE 2: STORED PROCEDURES';
PRINT '-----------------------------';
PRINT '2. 96_StoredProcedures_Part1_Core.sql';
PRINT '   → Authentication (3 procedures)';
PRINT '   → Department Management (6 procedures)';
PRINT '   → Employee Management (8 procedures)';
PRINT '   → Product Management (8 procedures)';
PRINT '   → Raw Material Management (9 procedures)';
PRINT '   → Retailer Management (6 procedures)';
PRINT '   → Total: ~40 procedures';
PRINT '   → Time: ~1 minute';
PRINT '';
PRINT '3. 97_StoredProcedures_Part2_Sales.sql';
PRINT '   → Sales Order Management (9 procedures)';
PRINT '   → Deal Management (10 procedures)';
PRINT '   → Order Approval & Workflow (4 procedures)';
PRINT '   → Total: ~25 procedures';
PRINT '   → Time: ~1 minute';
PRINT '';
PRINT '4. 98_StoredProcedures_Part3_Production.sql';
PRINT '   → Production Order Management (5 procedures)';
PRINT '   → Tailor Assignment (5 procedures)';
PRINT '   → Delivery Management (5 procedures)';
PRINT '   → Stock & Material Usage (5 procedures)';
PRINT '   → Salary Management (6 procedures)';
PRINT '   → Revenue & Financial Analytics (10 procedures)';
PRINT '   → Total: ~35 procedures';
PRINT '   → Time: ~1 minute';
PRINT '';
PRINT '📁 PHASE 3: AUTOMATION';
PRINT '----------------------';
PRINT '5. 99_Triggers_Complete.sql';
PRINT '   → trg_CreateDeliveryOnSalesOrder';
PRINT '   → trg_UpdateDeliveryOnSalesOrderStatusChange';
PRINT '   → Total: 2 triggers';
PRINT '   → Time: <1 minute';
PRINT '';
PRINT '📁 PHASE 4: REFERENCE DOCUMENTATION (OPTIONAL)';
PRINT '-----------------------------------------------';
PRINT '6. 100_QuickReference_AllProcedures.sql';
PRINT '   → Complete procedure catalog';
PRINT '   → Usage examples';
PRINT '   → Time: <1 minute';
PRINT '';
PRINT '========================================';
PRINT 'TOTAL SETUP TIME: 5-10 minutes';
PRINT '========================================';
PRINT '';
GO

-- ================================================================================
-- VERIFICATION CHECKLIST
-- ================================================================================

PRINT '';
PRINT '========================================';
PRINT '✓ VERIFICATION CHECKLIST';
PRINT '========================================';
PRINT '';
PRINT 'After completing all files, run these verification queries:';
PRINT '';
PRINT '-- 1. Verify Tables (Expected: 21)';
PRINT 'SELECT COUNT(*) AS TableCount';
PRINT 'FROM sys.tables';
PRINT 'WHERE type = ''U'' AND is_ms_shipped = 0;';
PRINT '';
PRINT '-- 2. Verify Stored Procedures (Expected: 157)';
PRINT 'SELECT COUNT(*) AS ProcedureCount';
PRINT 'FROM sys.procedures';
PRINT 'WHERE is_ms_shipped = 0';
PRINT '  AND name NOT LIKE ''sp_%diagram%'';';
PRINT '';
PRINT '-- 3. Verify Triggers (Expected: 2)';
PRINT 'SELECT COUNT(*) AS TriggerCount';
PRINT 'FROM sys.triggers';
PRINT 'WHERE is_ms_shipped = 0;';
PRINT '';
PRINT '-- 4. Verify Foreign Keys (Expected: 24)';
PRINT 'SELECT COUNT(*) AS ForeignKeyCount';
PRINT 'FROM sys.foreign_keys;';
PRINT '';
PRINT '-- 5. Verify Indexes (Expected: 24+)';
PRINT 'SELECT COUNT(*) AS IndexCount';
PRINT 'FROM sys.indexes';
PRINT 'WHERE is_primary_key = 0 AND is_unique_constraint = 0';
PRINT '  AND type > 0;';
PRINT '';
PRINT '========================================';
GO

-- ================================================================================
-- QUICK START SAMPLE DATA (OPTIONAL)
-- ================================================================================

PRINT '';
PRINT '========================================';
PRINT '📊 SAMPLE DATA (OPTIONAL)';
PRINT '========================================';
PRINT '';
PRINT 'If you want to test with sample data, execute:';
PRINT '';
PRINT '• 02_InsertSampleData.sql (if exists)';
PRINT '• 23_CleanupSampleData.sql (to reset)';
PRINT '• 24_InsertNewSampleDeals.sql (new samples)';
PRINT '• 41_AddSampleEmployees.sql (sample employees)';
PRINT '';
PRINT 'Note: Sample data is NOT required for production use';
PRINT '';
PRINT '========================================';
GO

-- ================================================================================
-- COMMON WORKFLOWS AFTER SETUP
-- ================================================================================

PRINT '';
PRINT '========================================';
PRINT '🔄 COMMON WORKFLOWS';
PRINT '========================================';
PRINT '';
PRINT 'WORKFLOW 1: Create New Employee';
PRINT '--------------------------------';
PRINT 'DECLARE @EmpID INT;';
PRINT 'EXEC sp_AddEmployee';
PRINT '    @FirstName = ''Ahmed'',';
PRINT '    @LastName = ''Khan'',';
PRINT '    @Email = ''ahmed@factory.com'',';
PRINT '    @DepartmentID = 1,';
PRINT '    @JobTitle = ''Senior Tailor'',';
PRINT '    @Salary = 35000,';
PRINT '    @Username = ''akhan'',';
PRINT '    @Password = ''secure_hash'',';
PRINT '    @NewEmployeeID = @EmpID OUTPUT;';
PRINT '';
PRINT 'WORKFLOW 2: Create Sales Order';
PRINT '-------------------------------';
PRINT 'DECLARE @OrderID INT, @ItemID INT;';
PRINT '-- Create order (auto-creates approval)';
PRINT 'EXEC sp_AddSalesOrder';
PRINT '    @RetailerID = 1,';
PRINT '    @ShippingAddress = ''123 Main St'',';
PRINT '    @SalesRepID = 5,';
PRINT '    @NewSalesOrderID = @OrderID OUTPUT;';
PRINT '-- Add item (auto-updates total)';
PRINT 'EXEC sp_AddSalesOrderItem';
PRINT '    @SalesOrderID = @OrderID,';
PRINT '    @ProductID = 1,';
PRINT '    @Quantity = 100,';
PRINT '    @UnitPrice = 500,';
PRINT '    @SalesOrderItemID = @ItemID OUTPUT;';
PRINT '';
PRINT 'WORKFLOW 3: Approve Order';
PRINT '-------------------------';
PRINT 'EXEC sp_ApproveOrderAndCreateProduction';
PRINT '    @ApprovalID = 1,';
PRINT '    @OwnerID = 1,';
PRINT '    @TailorIDs = ''10,11,12'';';
PRINT '-- Auto-creates: Production + Delivery';
PRINT '';
PRINT '========================================';
GO

-- ================================================================================
-- DASHBOARD PROCEDURES
-- ================================================================================

PRINT '';
PRINT '========================================';
PRINT '📈 DASHBOARD PROCEDURES';
PRINT '========================================';
PRINT '';
PRINT 'Owner Dashboard:';
PRINT '  EXEC sp_GetOwnerDashboardStatistics;';
PRINT '  EXEC sp_GetPendingApprovals;';
PRINT '  EXEC sp_GetProfitLoss @StartDate, @EndDate;';
PRINT '';
PRINT 'Sales Manager Dashboard:';
PRINT '  EXEC sp_GetSalesManagerStatistics;';
PRINT '  EXEC sp_GetTopSellingProducts @TopCount = 10;';
PRINT '  EXEC sp_GetRevenueByDateRange @StartDate, @EndDate;';
PRINT '';
PRINT 'Production Manager Dashboard:';
PRINT '  EXEC sp_GetProductionManagerStatistics;';
PRINT '  EXEC sp_GetLowStockRawMaterials;';
PRINT '  EXEC sp_GetAllProductionOrders;';
PRINT '';
PRINT 'Delivery Person Dashboard:';
PRINT '  EXEC sp_GetDeliveriesByPerson @DeliveryPersonID;';
PRINT '  EXEC sp_GetDeliveryStatistics;';
PRINT '';
PRINT '========================================';
GO

-- ================================================================================
-- AUTOMATION FEATURES
-- ================================================================================

PRINT '';
PRINT '========================================';
PRINT '⚙️ BUILT-IN AUTOMATION';
PRINT '========================================';
PRINT '';
PRINT '✓ Order Totals: Auto-calculated when items added';
PRINT '✓ Approval Requests: Auto-created for orders/deals';
PRINT '✓ Purchase Recording: Auto-recorded for materials';
PRINT '✓ Delivery Creation: Auto-created when order approved';
PRINT '✓ Delivery Status: Auto-synced with order status';
PRINT '✓ Salary Generation: Auto-generated monthly';
PRINT '✓ Stock Deduction: Auto-deducted from BOM';
PRINT '✓ Material Alerts: Low stock detection';
PRINT '';
PRINT '========================================';
GO

-- ================================================================================
-- TROUBLESHOOTING
-- ================================================================================

PRINT '';
PRINT '========================================';
PRINT '🔧 TROUBLESHOOTING';
PRINT '========================================';
PRINT '';
PRINT 'Issue: Procedure not found';
PRINT 'Solution: Re-execute appropriate Part file (96, 97, or 98)';
PRINT '';
PRINT 'Issue: Trigger not firing';
PRINT 'Solution: Check if disabled:';
PRINT '  SELECT name, is_disabled FROM sys.triggers;';
PRINT '  ENABLE TRIGGER trg_Name ON TableName;';
PRINT '';
PRINT 'Issue: Foreign key violation';
PRINT 'Solution: Check relationships:';
PRINT '  SELECT * FROM sys.foreign_keys;';
PRINT '';
PRINT 'Issue: Need to reset database';
PRINT 'Solution:';
PRINT '  USE master;';
PRINT '  DROP DATABASE GarmentsFactoryDB;';
PRINT '  -- Then re-run all setup files';
PRINT '';
PRINT '========================================';
GO

-- ================================================================================
-- MAINTENANCE SCRIPTS
-- ================================================================================

PRINT '';
PRINT '========================================';
PRINT '🔄 MAINTENANCE';
PRINT '========================================';
PRINT '';
PRINT 'Database Backup:';
PRINT '  BACKUP DATABASE GarmentsFactoryDB';
PRINT '  TO DISK = ''C:\Backups\GarmentsFactoryDB.bak''';
PRINT '  WITH FORMAT, COMPRESSION;';
PRINT '';
PRINT 'Database Size:';
PRINT '  EXEC sp_spaceused;';
PRINT '';
PRINT 'Performance Check:';
PRINT '  -- Check for missing indexes';
PRINT '  EXEC sp_helpindex ''TableName'';';
PRINT '';
PRINT 'Cleanup Old Data:';
PRINT '  -- Delete old logs, archives, etc.';
PRINT '  -- (Create custom cleanup procedures as needed)';
PRINT '';
PRINT '========================================';
GO

-- ================================================================================
-- SECURITY RECOMMENDATIONS
-- ================================================================================

PRINT '';
PRINT '========================================';
PRINT '🔒 SECURITY RECOMMENDATIONS';
PRINT '========================================';
PRINT '';
PRINT '1. Password Hashing:';
PRINT '   - Use BCrypt or similar for password hashing';
PRINT '   - Never store plain text passwords';
PRINT '   - Implement in application layer';
PRINT '';
PRINT '2. User Permissions:';
PRINT '   - Create database roles for different user types';
PRINT '   - Grant minimum required permissions';
PRINT '   - Use Windows Authentication where possible';
PRINT '';
PRINT '3. SQL Injection Prevention:';
PRINT '   - All procedures use parameterized queries';
PRINT '   - Never concatenate user input in SQL';
PRINT '   - Validate input in application layer';
PRINT '';
PRINT '4. Backup Strategy:';
PRINT '   - Daily full backups';
PRINT '   - Hourly transaction log backups';
PRINT '   - Test restore procedures regularly';
PRINT '';
PRINT '5. Audit Trail:';
PRINT '   - All tables have CreatedDate/UpdatedDate';
PRINT '   - Consider adding audit tables for sensitive data';
PRINT '   - Log all authentication attempts';
PRINT '';
PRINT '========================================';
GO

-- ================================================================================
-- FINAL STATUS
-- ================================================================================

PRINT '';
PRINT '========================================';
PRINT '✅ SETUP SCRIPT COMPLETE';
PRINT '========================================';
PRINT '';
PRINT 'Next Steps:';
PRINT '1. Execute files 95-99 in order';
PRINT '2. Run verification queries';
PRINT '3. Insert sample data (optional)';
PRINT '4. Test authentication';
PRINT '5. Test dashboard procedures';
PRINT '';
PRINT '📚 Documentation Files:';
PRINT '• 00_MASTER_DATABASE_INDEX.md - Complete overview';
PRINT '• 100_QuickReference_AllProcedures.sql - All procedures';
PRINT '• ER_Diagram.md - Visual database structure';
PRINT '';
PRINT '========================================';
PRINT '🎉 READY FOR PRODUCTION!';
PRINT '========================================';
GO

-- ================================================================================
-- QUICK VERIFICATION SCRIPT
-- ================================================================================

-- Uncomment and run after setup to verify:

/*
PRINT '';
PRINT '========================================';
PRINT 'DATABASE VERIFICATION';
PRINT '========================================';

SELECT 'Tables' AS ObjectType, COUNT(*) AS Count
FROM sys.tables
WHERE type = 'U' AND is_ms_shipped = 0

UNION ALL

SELECT 'Procedures', COUNT(*)
FROM sys.procedures
WHERE is_ms_shipped = 0 AND name NOT LIKE '%diagram%'

UNION ALL

SELECT 'Triggers', COUNT(*)
FROM sys.triggers
WHERE is_ms_shipped = 0

UNION ALL

SELECT 'Foreign Keys', COUNT(*)
FROM sys.foreign_keys

UNION ALL

SELECT 'Indexes', COUNT(*)
FROM sys.indexes
WHERE is_primary_key = 0 AND is_unique_constraint = 0 AND type > 0;

PRINT '';
PRINT '✓ Verification complete!';
PRINT '';
*/
GO
