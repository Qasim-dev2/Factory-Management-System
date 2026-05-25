-- ================================================================================
-- ADD DELIVERY MAN POSITION & OPTIMIZE DELIVERY MANAGEMENT
-- ================================================================================
-- Created: December 8, 2025
-- Purpose: 
--   1. Add "Delivery Man" position to EmployeeRole table
--   2. Optimize delivery management stored procedures
--   3. Remove all sample data from database
-- ================================================================================

USE GarmentsFactoryDB;
GO

PRINT '========================================';
PRINT 'DELIVERY MAN POSITION & DATABASE CLEANUP';
PRINT '========================================';
GO

-- ================================================================================
-- STEP 1: ADD DELIVERY MAN POSITION
-- ================================================================================

PRINT '';
PRINT 'Step 1: Adding Delivery Man Position...';
GO

-- Check if Delivery Man role already exists
IF NOT EXISTS (SELECT 1 FROM EmployeeRole WHERE RoleName = 'Delivery Man')
BEGIN
    INSERT INTO EmployeeRole (RoleName, Description, IsActive)
    VALUES ('Delivery Man', 'Responsible for delivering orders to customers', 1);
    
    PRINT '✅ Delivery Man position added successfully';
END
ELSE
BEGIN
    PRINT '⚠️  Delivery Man position already exists';
END
GO

-- Display all positions
PRINT '';
PRINT 'Current Employee Positions:';
SELECT RoleID, RoleName, Description, IsActive 
FROM EmployeeRole 
ORDER BY RoleID;
GO

-- ================================================================================
-- STEP 2: OPTIMIZE DELIVERY MANAGEMENT PROCEDURES
-- ================================================================================

PRINT '';
PRINT 'Step 2: Optimizing Delivery Management...';
GO

-- ================================================================================
-- 2.1: Enhanced Get All Deliveries (with Deal support)
-- ================================================================================

IF OBJECT_ID('sp_GetAllDeliveries', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetAllDeliveries;
GO

CREATE PROCEDURE sp_GetAllDeliveries
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        d.DeliveryID,
        d.SalesOrderID,
        d.DealID,
        d.DeliveredBy,
        d.DeliveryDate,
        d.DeliveryAddress,
        d.City,
        d.Province,
        d.PostalCode,
        d.TrackingNumber,
        d.DeliveryMethod,
        d.DeliveryCost,
        d.Status,
        d.ReceiverName,
        d.ReceiverPhone,
        d.Notes,
        d.CreatedDate,
        d.UpdatedDate,
        -- Order Type
        CASE 
            WHEN d.SalesOrderID IS NOT NULL THEN 'SalesOrder'
            WHEN d.DealID IS NOT NULL THEN 'Deal'
            ELSE 'Unknown'
        END AS OrderType,
        -- Sales Order Information
        so.OrderDate AS OrderDate,
        so.ExpectedDeliveryDate,
        so.TotalAmount AS OrderAmount,
        so.Status AS OrderStatus,
        so.PriorityLevel,
        -- Deal Information
        dl.StartDate AS DealDate,
        dl.EstimatedValue AS DealAmount,
        dl.Status AS DealStatus,
        dl.ClientName,
        -- Retailer Information (for SalesOrder)
        r.CompanyName AS RetailerName,
        r.ContactPerson,
        r.Phone AS RetailerPhone,
        r.City AS RetailerCity,
        -- Customer Name (unified)
        CASE 
            WHEN d.SalesOrderID IS NOT NULL THEN r.CompanyName
            WHEN d.DealID IS NOT NULL THEN dl.ClientName
            ELSE 'Unknown'
        END AS CustomerName,
        -- Sales Rep/Manager Information
        CASE 
            WHEN d.SalesOrderID IS NOT NULL THEN CONCAT(e.FirstName, ' ', e.LastName)
            WHEN d.DealID IS NOT NULL THEN CONCAT(emp2.FirstName, ' ', emp2.LastName)
            ELSE NULL
        END AS HandlerName,
        -- Delivery Person Information
        CONCAT(emp3.FirstName, ' ', emp3.LastName) AS DeliveryPersonName,
        emp3.Phone AS DeliveryPersonPhone,
        emp3.Email AS DeliveryPersonEmail
    FROM Delivery d
    LEFT JOIN SalesOrder so ON d.SalesOrderID = so.SalesOrderID
    LEFT JOIN Deal dl ON d.DealID = dl.DealID
    LEFT JOIN Retailer r ON so.RetailerID = r.RetailerID
    LEFT JOIN Employee e ON so.SalesRepID = e.EmployeeID
    LEFT JOIN Employee emp2 ON dl.AssignedManagerID = emp2.EmployeeID
    LEFT JOIN Employee emp3 ON d.DeliveredBy = emp3.EmployeeID
    ORDER BY d.CreatedDate DESC;
END
GO

PRINT '✅ sp_GetAllDeliveries optimized';
GO

-- ================================================================================
-- 2.2: Enhanced Get Delivery By ID
-- ================================================================================

IF OBJECT_ID('sp_GetDeliveryById', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetDeliveryById;
GO

CREATE PROCEDURE sp_GetDeliveryById
    @DeliveryID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        d.DeliveryID,
        d.SalesOrderID,
        d.DealID,
        d.DeliveredBy,
        d.DeliveryDate,
        d.DeliveryAddress,
        d.City,
        d.Province,
        d.PostalCode,
        d.TrackingNumber,
        d.DeliveryMethod,
        d.DeliveryCost,
        d.Status,
        d.ReceiverName,
        d.ReceiverPhone,
        d.Notes,
        d.CreatedDate,
        d.UpdatedDate,
        -- Order Type
        CASE 
            WHEN d.SalesOrderID IS NOT NULL THEN 'SalesOrder'
            WHEN d.DealID IS NOT NULL THEN 'Deal'
            ELSE 'Unknown'
        END AS OrderType,
        -- Customer Information
        CASE 
            WHEN d.SalesOrderID IS NOT NULL THEN r.CompanyName
            WHEN d.DealID IS NOT NULL THEN dl.ClientName
            ELSE 'Unknown'
        END AS CustomerName,
        CASE 
            WHEN d.SalesOrderID IS NOT NULL THEN r.Phone
            WHEN d.DealID IS NOT NULL THEN dl.Phone
            ELSE NULL
        END AS CustomerPhone,
        -- Order Amount
        CASE 
            WHEN d.SalesOrderID IS NOT NULL THEN so.TotalAmount
            WHEN d.DealID IS NOT NULL THEN dl.EstimatedValue
            ELSE 0
        END AS OrderAmount,
        -- Delivery Person
        CONCAT(emp.FirstName, ' ', emp.LastName) AS DeliveryPersonName,
        emp.Phone AS DeliveryPersonPhone
    FROM Delivery d
    LEFT JOIN SalesOrder so ON d.SalesOrderID = so.SalesOrderID
    LEFT JOIN Deal dl ON d.DealID = dl.DealID
    LEFT JOIN Retailer r ON so.RetailerID = r.RetailerID
    LEFT JOIN Employee emp ON d.DeliveredBy = emp.EmployeeID
    WHERE d.DeliveryID = @DeliveryID;
END
GO

PRINT '✅ sp_GetDeliveryById optimized';
GO

-- ================================================================================
-- 2.3: Enhanced Update Delivery Status
-- ================================================================================

IF OBJECT_ID('sp_UpdateDeliveryStatus', 'P') IS NOT NULL
    DROP PROCEDURE sp_UpdateDeliveryStatus;
GO

CREATE PROCEDURE sp_UpdateDeliveryStatus
    @DeliveryID INT,
    @NewStatus NVARCHAR(50),
    @DeliveredBy INT = NULL,
    @ActualDeliveryDate DATETIME = NULL,
    @ReceiverName NVARCHAR(100) = NULL,
    @ReceiverPhone NVARCHAR(20) = NULL,
    @Notes NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Update delivery record
        UPDATE Delivery
        SET Status = @NewStatus,
            DeliveredBy = COALESCE(@DeliveredBy, DeliveredBy),
            DeliveryDate = CASE 
                WHEN @NewStatus = 'Delivered' THEN COALESCE(@ActualDeliveryDate, GETDATE())
                ELSE DeliveryDate 
            END,
            ReceiverName = COALESCE(@ReceiverName, ReceiverName),
            ReceiverPhone = COALESCE(@ReceiverPhone, ReceiverPhone),
            Notes = COALESCE(@Notes, Notes),
            UpdatedDate = GETDATE()
        WHERE DeliveryID = @DeliveryID;
        
        -- If status is "Delivered", update the source order status
        IF @NewStatus = 'Delivered'
        BEGIN
            -- Update SalesOrder if exists
            UPDATE so
            SET so.Status = 'Delivered',
                so.UpdatedDate = GETDATE()
            FROM SalesOrder so
            INNER JOIN Delivery d ON so.SalesOrderID = d.SalesOrderID
            WHERE d.DeliveryID = @DeliveryID;
            
            -- Update Deal if exists
            UPDATE dl
            SET dl.Status = 'Delivered',
                dl.UpdatedDate = GETDATE()
            FROM Deal dl
            INNER JOIN Delivery d ON dl.DealID = d.DealID
            WHERE d.DeliveryID = @DeliveryID;
        END
        
        COMMIT TRANSACTION;
        
        SELECT 'Success' AS Result, 
               'Delivery status updated successfully' AS Message;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        SELECT 'Error' AS Result, 
               ERROR_MESSAGE() AS Message;
    END CATCH
END
GO

PRINT '✅ sp_UpdateDeliveryStatus optimized';
GO

-- ================================================================================
-- 2.4: Get Delivery Statistics
-- ================================================================================

IF OBJECT_ID('sp_GetDeliveryStatistics', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetDeliveryStatistics;
GO

CREATE PROCEDURE sp_GetDeliveryStatistics
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        (SELECT COUNT(*) FROM Delivery) AS TotalDeliveries,
        (SELECT COUNT(*) FROM Delivery WHERE Status = 'Pending') AS PendingDeliveries,
        (SELECT COUNT(*) FROM Delivery WHERE Status = 'In Transit') AS InTransitDeliveries,
        (SELECT COUNT(*) FROM Delivery WHERE Status = 'Delivered') AS DeliveredCount,
        (SELECT COUNT(*) FROM Delivery WHERE Status = 'Failed') AS FailedDeliveries,
        (SELECT COALESCE(SUM(DeliveryCost), 0) FROM Delivery WHERE Status = 'Delivered') AS TotalDeliveryCost,
        (SELECT COUNT(*) FROM Delivery WHERE CAST(DeliveryDate AS DATE) = CAST(GETDATE() AS DATE)) AS TodayDeliveries;
END
GO

PRINT '✅ sp_GetDeliveryStatistics created';
GO

-- ================================================================================
-- 2.5: Get Available Delivery Personnel
-- ================================================================================

IF OBJECT_ID('sp_GetDeliveryPersonnel', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetDeliveryPersonnel;
GO

CREATE PROCEDURE sp_GetDeliveryPersonnel
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        e.EmployeeID,
        CONCAT(e.FirstName, ' ', e.LastName) AS FullName,
        e.Phone,
        e.Email,
        e.Address,
        -- Count of active deliveries
        (SELECT COUNT(*) 
         FROM Delivery d 
         WHERE d.DeliveredBy = e.EmployeeID 
         AND d.Status IN ('Pending', 'In Transit')) AS ActiveDeliveries,
        -- Count of completed deliveries
        (SELECT COUNT(*) 
         FROM Delivery d 
         WHERE d.DeliveredBy = e.EmployeeID 
         AND d.Status = 'Delivered') AS CompletedDeliveries
    FROM Employee e
    INNER JOIN EmployeeRole er ON e.RoleID = er.RoleID
    WHERE er.RoleName = 'Delivery Man'
    AND e.IsActive = 1
    ORDER BY ActiveDeliveries ASC, CONCAT(e.FirstName, ' ', e.LastName);
END
GO

PRINT '✅ sp_GetDeliveryPersonnel created';
GO

-- ================================================================================
-- STEP 3: REMOVE ALL SAMPLE DATA
-- ================================================================================

PRINT '';
PRINT 'Step 3: Removing all sample data...';
GO

-- Clear data in correct order (respecting foreign keys)
DECLARE @ErrorOccurred BIT = 0;

BEGIN TRY
    -- Delete TailorTask first (depends on ProductionOrder and Employee)
    DELETE FROM TailorTask;
    PRINT '  ✅ Cleared TailorTask (' + CAST(@@ROWCOUNT AS NVARCHAR) + ' rows)';
END TRY
BEGIN CATCH
    PRINT '  ⚠️  TailorTask: ' + ERROR_MESSAGE();
    SET @ErrorOccurred = 1;
END CATCH

BEGIN TRY
    -- Delete Delivery (depends on SalesOrder and Deal)
    DELETE FROM Delivery;
    PRINT '  ✅ Cleared Delivery (' + CAST(@@ROWCOUNT AS NVARCHAR) + ' rows)';
END TRY
BEGIN CATCH
    PRINT '  ⚠️  Delivery: ' + ERROR_MESSAGE();
    SET @ErrorOccurred = 1;
END CATCH

BEGIN TRY
    -- Delete ProductionOrder (depends on OrderApproval, Product, Employee)
    DELETE FROM ProductionOrder;
    PRINT '  ✅ Cleared ProductionOrder (' + CAST(@@ROWCOUNT AS NVARCHAR) + ' rows)';
END TRY
BEGIN CATCH
    PRINT '  ⚠️  ProductionOrder: ' + ERROR_MESSAGE();
    SET @ErrorOccurred = 1;
END CATCH

BEGIN TRY
    -- Delete OrderApproval (depends on SalesOrder and Deal)
    DELETE FROM OrderApproval;
    PRINT '  ✅ Cleared OrderApproval (' + CAST(@@ROWCOUNT AS NVARCHAR) + ' rows)';
END TRY
BEGIN CATCH
    PRINT '  ⚠️  OrderApproval: ' + ERROR_MESSAGE();
    SET @ErrorOccurred = 1;
END CATCH

BEGIN TRY
    -- Delete SalesOrder (depends on Retailer, Employee)
    DELETE FROM SalesOrder;
    PRINT '  ✅ Cleared SalesOrder (' + CAST(@@ROWCOUNT AS NVARCHAR) + ' rows)';
END TRY
BEGIN CATCH
    PRINT '  ⚠️  SalesOrder: ' + ERROR_MESSAGE();
    SET @ErrorOccurred = 1;
END CATCH

BEGIN TRY
    -- Delete Deal (depends on Employee)
    DELETE FROM Deal;
    PRINT '  ✅ Cleared Deal (' + CAST(@@ROWCOUNT AS NVARCHAR) + ' rows)';
END TRY
BEGIN CATCH
    PRINT '  ⚠️  Deal: ' + ERROR_MESSAGE();
    SET @ErrorOccurred = 1;
END CATCH

BEGIN TRY
    -- Delete Retailer (no dependencies)
    DELETE FROM Retailer;
    PRINT '  ✅ Cleared Retailer (' + CAST(@@ROWCOUNT AS NVARCHAR) + ' rows)';
END TRY
BEGIN CATCH
    PRINT '  ⚠️  Retailer: ' + ERROR_MESSAGE();
    SET @ErrorOccurred = 1;
END CATCH

BEGIN TRY
    -- Delete Product (no dependencies)
    DELETE FROM Product;
    PRINT '  ✅ Cleared Product (' + CAST(@@ROWCOUNT AS NVARCHAR) + ' rows)';
END TRY
BEGIN CATCH
    PRINT '  ⚠️  Product: ' + ERROR_MESSAGE();
    SET @ErrorOccurred = 1;
END CATCH

BEGIN TRY
    -- Delete Employee (depends on Department, EmployeeRole)
    DELETE FROM Employee;
    PRINT '  ✅ Cleared Employee (' + CAST(@@ROWCOUNT AS NVARCHAR) + ' rows)';
END TRY
BEGIN CATCH
    PRINT '  ⚠️  Employee: ' + ERROR_MESSAGE();
    SET @ErrorOccurred = 1;
END CATCH

BEGIN TRY
    -- Delete RawMaterial (no dependencies)
    IF EXISTS (SELECT * FROM sys.tables WHERE name = 'RawMaterial')
    BEGIN
        DELETE FROM RawMaterial;
        PRINT '  ✅ Cleared RawMaterial (' + CAST(@@ROWCOUNT AS NVARCHAR) + ' rows)';
    END
END TRY
BEGIN CATCH
    PRINT '  ⚠️  RawMaterial: ' + ERROR_MESSAGE();
    SET @ErrorOccurred = 1;
END CATCH

BEGIN TRY
    -- Delete Inventory (no dependencies)
    IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Inventory')
    BEGIN
        DELETE FROM Inventory;
        PRINT '  ✅ Cleared Inventory (' + CAST(@@ROWCOUNT AS NVARCHAR) + ' rows)';
    END
END TRY
BEGIN CATCH
    PRINT '  ⚠️  Inventory: ' + ERROR_MESSAGE();
    SET @ErrorOccurred = 1;
END CATCH

-- DO NOT delete Department and EmployeeRole (system configuration data)
PRINT '  ℹ️  Kept Department and EmployeeRole (system configuration)';

-- Reset identity seeds to start from 1
BEGIN TRY
    DBCC CHECKIDENT ('TailorTask', RESEED, 0);
    DBCC CHECKIDENT ('Delivery', RESEED, 0);
    DBCC CHECKIDENT ('ProductionOrder', RESEED, 0);
    DBCC CHECKIDENT ('OrderApproval', RESEED, 0);
    DBCC CHECKIDENT ('SalesOrder', RESEED, 0);
    DBCC CHECKIDENT ('Deal', RESEED, 0);
    DBCC CHECKIDENT ('Retailer', RESEED, 0);
    DBCC CHECKIDENT ('Product', RESEED, 0);
    DBCC CHECKIDENT ('Employee', RESEED, 0);
    IF EXISTS (SELECT * FROM sys.tables WHERE name = 'RawMaterial')
        DBCC CHECKIDENT ('RawMaterial', RESEED, 0);
    IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Inventory')
        DBCC CHECKIDENT ('Inventory', RESEED, 0);
    PRINT '  ✅ Reset all identity seeds';
END TRY
BEGIN CATCH
    PRINT '  ⚠️  Error resetting seeds: ' + ERROR_MESSAGE();
END CATCH

IF @ErrorOccurred = 0
BEGIN
    PRINT '';
    PRINT '✅ All sample data removed successfully';
    PRINT '✅ Database is now clean and ready for production use';
END
ELSE
BEGIN
    PRINT '';
    PRINT '⚠️  Data cleanup completed with some warnings (see above)';
END
GO

-- ================================================================================
-- STEP 4: VERIFY CLEANUP
-- ================================================================================

PRINT '';
PRINT '========================================';
PRINT 'VERIFICATION SUMMARY';
PRINT '========================================';
GO

-- Show record counts
SELECT 
    'Departments' AS TableName, COUNT(*) AS RecordCount FROM Department
UNION ALL
SELECT 'Employee Roles', COUNT(*) FROM EmployeeRole
UNION ALL
SELECT 'Employees', COUNT(*) FROM Employee
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

-- Show available positions
PRINT '';
PRINT 'Available Employee Positions:';
SELECT RoleID, RoleName, Description 
FROM EmployeeRole 
WHERE IsActive = 1
ORDER BY RoleID;
GO

PRINT '';
PRINT '========================================';
PRINT '✅ DELIVERY MAN SETUP & CLEANUP COMPLETE';
PRINT '========================================';
PRINT '';
PRINT 'Next Steps:';
PRINT '1. Add employees through the Employee Management UI';
PRINT '2. Assign Delivery Man role to delivery personnel';
PRINT '3. Use optimized delivery management procedures';
PRINT '';
GO
