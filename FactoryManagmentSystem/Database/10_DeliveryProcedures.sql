-- ================================================================================
-- DELIVERY MANAGEMENT - STORED PROCEDURES WITH AUTOMATIC WORKFLOW
-- ================================================================================
-- Execute this script in SQL Server Management Studio (SSMS)
-- Make sure you're connected to GarmentsFactoryDB database
-- Matches Delivery table structure from 01_CreateDatabase.sql
-- ================================================================================

USE GarmentsFactoryDB;
GO

-- ================================================================================
-- 1. GET ALL DELIVERIES (For View All Tab)
-- ================================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetAllDeliveries')
    DROP PROCEDURE sp_GetAllDeliveries;
GO

CREATE PROCEDURE sp_GetAllDeliveries
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        d.DeliveryID,
        d.SalesOrderID,
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
        -- Sales Order Information
        so.OrderDate AS OrderDate,
        so.ExpectedDeliveryDate,
        so.TotalAmount AS OrderAmount,
        so.Status AS OrderStatus,
        so.PriorityLevel,
        -- Retailer Information
        r.CompanyName AS RetailerName,
        r.ContactPerson,
        r.Phone AS RetailerPhone,
        r.City AS RetailerCity,
        -- Sales Rep Information
        CONCAT(e.FirstName, ' ', e.LastName) AS SalesRepName,
        -- Delivered By Employee
        CONCAT(emp.FirstName, ' ', emp.LastName) AS DeliveredByName
    FROM Delivery d
    INNER JOIN SalesOrder so ON d.SalesOrderID = so.SalesOrderID
    LEFT JOIN Retailer r ON so.RetailerID = r.RetailerID
    LEFT JOIN Employee e ON so.SalesRepID = e.EmployeeID
    LEFT JOIN Employee emp ON d.DeliveredBy = emp.EmployeeID
    ORDER BY d.CreatedDate DESC;
END
GO

PRINT 'sp_GetAllDeliveries created successfully.';
GO

-- ================================================================================
-- 2. GET DELIVERY BY ID (For Details/Update)
-- ================================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetDeliveryById')
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
        -- Sales Order Information
        so.OrderDate AS OrderDate,
        so.ExpectedDeliveryDate,
        so.TotalAmount AS OrderAmount,
        so.Status AS OrderStatus,
        so.PriorityLevel,
        so.ShippingAddress AS OrderShippingAddress,
        -- Retailer Information
        r.CompanyName AS RetailerName,
        r.ContactPerson,
        r.Phone AS RetailerPhone,
        r.Email AS RetailerEmail,
        r.City AS RetailerCity,
        r.Province AS RetailerProvince,
        -- Sales Rep Information
        CONCAT(e.FirstName, ' ', e.LastName) AS SalesRepName,
        e.Phone AS SalesRepPhone,
        -- Delivered By Employee
        CONCAT(emp.FirstName, ' ', emp.LastName) AS DeliveredByName,
        emp.Phone AS DeliveredByPhone
    FROM Delivery d
    INNER JOIN SalesOrder so ON d.SalesOrderID = so.SalesOrderID
    LEFT JOIN Retailer r ON so.RetailerID = r.RetailerID
    LEFT JOIN Employee e ON so.SalesRepID = e.EmployeeID
    LEFT JOIN Employee emp ON d.DeliveredBy = emp.EmployeeID
    WHERE d.DeliveryID = @DeliveryID;
END
GO

PRINT 'sp_GetDeliveryById created successfully.';
GO

-- ================================================================================
-- 3. GET DELIVERY BY SALES ORDER ID
-- ================================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetDeliveryBySalesOrderId')
    DROP PROCEDURE sp_GetDeliveryBySalesOrderId;
GO

CREATE PROCEDURE sp_GetDeliveryBySalesOrderId
    @SalesOrderID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        d.DeliveryID,
        d.SalesOrderID,
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
        d.UpdatedDate
    FROM Delivery d
    WHERE d.SalesOrderID = @SalesOrderID;
END
GO

PRINT 'sp_GetDeliveryBySalesOrderId created successfully.';
GO

-- ================================================================================
-- 4. UPDATE DELIVERY (For Manual Updates)
-- ================================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_UpdateDelivery')
    DROP PROCEDURE sp_UpdateDelivery;
GO

CREATE PROCEDURE sp_UpdateDelivery
    @DeliveryID INT,
    @DeliveredBy INT = NULL,
    @DeliveryDate DATETIME = NULL,
    @DeliveryAddress NVARCHAR(500) = NULL,
    @City NVARCHAR(50) = NULL,
    @Province NVARCHAR(50) = NULL,
    @PostalCode NVARCHAR(10) = NULL,
    @TrackingNumber NVARCHAR(100) = NULL,
    @DeliveryMethod NVARCHAR(50) = NULL,
    @DeliveryCost DECIMAL(18,2) = NULL,
    @Status NVARCHAR(50),
    @ReceiverName NVARCHAR(100) = NULL,
    @ReceiverPhone NVARCHAR(20) = NULL,
    @Notes NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validate delivery exists
        IF NOT EXISTS (SELECT 1 FROM Delivery WHERE DeliveryID = @DeliveryID)
        BEGIN
            RAISERROR('Delivery record not found.', 16, 1);
            RETURN;
        END
        
        -- Set DeliveryDate if status is Delivered and not already set
        IF @Status = 'Delivered' AND @DeliveryDate IS NULL
        BEGIN
            SET @DeliveryDate = GETDATE();
        END
        
        -- Update Delivery
        UPDATE Delivery
        SET 
            DeliveredBy = ISNULL(@DeliveredBy, DeliveredBy),
            DeliveryDate = ISNULL(@DeliveryDate, DeliveryDate),
            DeliveryAddress = ISNULL(@DeliveryAddress, DeliveryAddress),
            City = ISNULL(@City, City),
            Province = ISNULL(@Province, Province),
            PostalCode = ISNULL(@PostalCode, PostalCode),
            TrackingNumber = ISNULL(@TrackingNumber, TrackingNumber),
            DeliveryMethod = ISNULL(@DeliveryMethod, DeliveryMethod),
            DeliveryCost = ISNULL(@DeliveryCost, DeliveryCost),
            Status = @Status,
            ReceiverName = ISNULL(@ReceiverName, ReceiverName),
            ReceiverPhone = ISNULL(@ReceiverPhone, ReceiverPhone),
            Notes = ISNULL(@Notes, Notes),
            UpdatedDate = GETDATE()
        WHERE DeliveryID = @DeliveryID;
        
        -- Update related SalesOrder status based on delivery status
        DECLARE @SalesOrderID INT;
        SELECT @SalesOrderID = SalesOrderID FROM Delivery WHERE DeliveryID = @DeliveryID;
        
        IF @Status = 'Delivered'
        BEGIN
            UPDATE SalesOrder 
            SET Status = 'Delivered', UpdatedDate = GETDATE()
            WHERE SalesOrderID = @SalesOrderID;
        END
        ELSE IF @Status = 'InTransit'
        BEGIN
            UPDATE SalesOrder 
            SET Status = 'Shipped', UpdatedDate = GETDATE()
            WHERE SalesOrderID = @SalesOrderID;
        END
        ELSE IF @Status = 'Pending'
        BEGIN
            UPDATE SalesOrder 
            SET Status = 'Confirmed', UpdatedDate = GETDATE()
            WHERE SalesOrderID = @SalesOrderID AND Status IN ('Delivered', 'Shipped');
        END
        
        COMMIT TRANSACTION;
        
        PRINT 'Delivery updated successfully.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

PRINT 'sp_UpdateDelivery created successfully.';
GO

-- ================================================================================
-- 5. DELETE DELIVERY (For Delete Operation)
-- ================================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_DeleteDelivery')
    DROP PROCEDURE sp_DeleteDelivery;
GO

CREATE PROCEDURE sp_DeleteDelivery
    @DeliveryID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validate delivery exists
        IF NOT EXISTS (SELECT 1 FROM Delivery WHERE DeliveryID = @DeliveryID)
        BEGIN
            RAISERROR('Delivery record not found.', 16, 1);
            RETURN;
        END
        
        -- Delete delivery
        DELETE FROM Delivery WHERE DeliveryID = @DeliveryID;
        
        COMMIT TRANSACTION;
        
        PRINT 'Delivery deleted successfully.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

PRINT 'sp_DeleteDelivery created successfully.';
GO

-- ================================================================================
-- 6. SEARCH DELIVERIES (For Search/Filter functionality)
-- ================================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_SearchDeliveries')
    DROP PROCEDURE sp_SearchDeliveries;
GO

CREATE PROCEDURE sp_SearchDeliveries
    @SearchTerm NVARCHAR(100) = NULL,
    @Status NVARCHAR(50) = NULL,
    @DeliveryMethod NVARCHAR(50) = NULL,
    @StartDate DATE = NULL,
    @EndDate DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        d.DeliveryID,
        d.SalesOrderID,
        d.DeliveryDate,
        d.Status,
        d.DeliveryMethod,
        d.TrackingNumber,
        d.DeliveryCost,
        r.CompanyName AS RetailerName,
        r.ContactPerson,
        r.City AS RetailerCity,
        so.TotalAmount AS OrderAmount,
        CONCAT(e.FirstName, ' ', e.LastName) AS SalesRepName,
        CONCAT(emp.FirstName, ' ', emp.LastName) AS DeliveredByName
    FROM Delivery d
    INNER JOIN SalesOrder so ON d.SalesOrderID = so.SalesOrderID
    LEFT JOIN Retailer r ON so.RetailerID = r.RetailerID
    LEFT JOIN Employee e ON so.SalesRepID = e.EmployeeID
    LEFT JOIN Employee emp ON d.DeliveredBy = emp.EmployeeID
    WHERE 
        (@SearchTerm IS NULL OR 
         r.CompanyName LIKE '%' + @SearchTerm + '%' OR
         r.ContactPerson LIKE '%' + @SearchTerm + '%' OR
         d.TrackingNumber LIKE '%' + @SearchTerm + '%' OR
         CAST(d.DeliveryID AS NVARCHAR) LIKE '%' + @SearchTerm + '%')
        AND (@Status IS NULL OR d.Status = @Status)
        AND (@DeliveryMethod IS NULL OR d.DeliveryMethod = @DeliveryMethod)
        AND (@StartDate IS NULL OR CAST(d.DeliveryDate AS DATE) >= @StartDate)
        AND (@EndDate IS NULL OR CAST(d.DeliveryDate AS DATE) <= @EndDate)
    ORDER BY d.CreatedDate DESC;
END
GO

PRINT 'sp_SearchDeliveries created successfully.';
GO

-- ================================================================================
-- 7. GET DELIVERY STATISTICS (For Dashboard)
-- ================================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetDeliveryStatistics')
    DROP PROCEDURE sp_GetDeliveryStatistics;
GO

CREATE PROCEDURE sp_GetDeliveryStatistics
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        COUNT(*) AS TotalDeliveries,
        SUM(CASE WHEN Status = 'Pending' THEN 1 ELSE 0 END) AS PendingDeliveries,
        SUM(CASE WHEN Status = 'InTransit' THEN 1 ELSE 0 END) AS InTransitDeliveries,
        SUM(CASE WHEN Status = 'Delivered' THEN 1 ELSE 0 END) AS DeliveredCount,
        SUM(CASE WHEN Status = 'Failed' THEN 1 ELSE 0 END) AS FailedDeliveries,
        SUM(CASE WHEN Status = 'Returned' THEN 1 ELSE 0 END) AS ReturnedDeliveries,
        SUM(CASE WHEN CAST(DeliveryDate AS DATE) = CAST(GETDATE() AS DATE) THEN 1 ELSE 0 END) AS TodayDeliveries,
        SUM(CASE WHEN DeliveryDate >= DATEADD(DAY, -7, GETDATE()) THEN 1 ELSE 0 END) AS LastWeekDeliveries,
        SUM(CASE WHEN DeliveryDate >= DATEADD(MONTH, -1, GETDATE()) THEN 1 ELSE 0 END) AS LastMonthDeliveries,
        SUM(DeliveryCost) AS TotalDeliveryCost,
        AVG(DeliveryCost) AS AverageDeliveryCost
    FROM Delivery;
END
GO

PRINT 'sp_GetDeliveryStatistics created successfully.';
GO

-- ================================================================================
-- 8. TRIGGER: AUTO-CREATE DELIVERY WHEN SALES ORDER IS CREATED
-- ================================================================================
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_CreateDeliveryOnSalesOrder')
    DROP TRIGGER trg_CreateDeliveryOnSalesOrder;
GO

CREATE TRIGGER trg_CreateDeliveryOnSalesOrder
ON SalesOrder
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Insert Delivery record for each new Sales Order
    INSERT INTO Delivery (
        SalesOrderID,
        DeliveryDate,
        DeliveryAddress,
        Status,
        CreatedDate
    )
    SELECT 
        i.SalesOrderID,
        GETDATE(),
        i.ShippingAddress,
        CASE 
            WHEN i.Status = 'Delivered' THEN 'Delivered'
            WHEN i.Status = 'Shipped' THEN 'InTransit'
            ELSE 'Pending'
        END,
        GETDATE()
    FROM inserted i;
    
    PRINT 'Delivery record(s) created automatically for new Sales Order(s).';
END
GO

PRINT 'trg_CreateDeliveryOnSalesOrder created successfully.';
GO

-- ================================================================================
-- 9. TRIGGER: AUTO-UPDATE DELIVERY STATUS WHEN SALES ORDER STATUS CHANGES
-- ================================================================================
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_UpdateDeliveryOnSalesOrderStatusChange')
    DROP TRIGGER trg_UpdateDeliveryOnSalesOrderStatusChange;
GO

CREATE TRIGGER trg_UpdateDeliveryOnSalesOrderStatusChange
ON SalesOrder
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Only proceed if Status column was actually updated
    IF UPDATE(Status)
    BEGIN
        -- Update Delivery Status based on Sales Order Status
        UPDATE d
        SET 
            Status = CASE 
                WHEN i.Status = 'Delivered' THEN 'Delivered'
                WHEN i.Status = 'Shipped' THEN 'InTransit'
                WHEN i.Status = 'Cancelled' THEN 'Failed'
                ELSE 'Pending'
            END,
            DeliveryDate = CASE 
                WHEN i.Status = 'Delivered' AND d.DeliveryDate IS NULL THEN GETDATE()
                ELSE d.DeliveryDate
            END,
            UpdatedDate = GETDATE()
        FROM Delivery d
        INNER JOIN inserted i ON d.SalesOrderID = i.SalesOrderID
        INNER JOIN deleted old ON i.SalesOrderID = old.SalesOrderID
        WHERE i.Status != old.Status; -- Only update if status actually changed
        
        PRINT 'Delivery status updated automatically based on Sales Order status change.';
    END
END
GO

PRINT 'trg_UpdateDeliveryOnSalesOrderStatusChange created successfully.';
GO

-- ================================================================================
-- 10. UPDATE DELIVERY STATUS (Quick Status Update)
-- ================================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_UpdateDeliveryStatus')
    DROP PROCEDURE sp_UpdateDeliveryStatus;
GO

CREATE PROCEDURE sp_UpdateDeliveryStatus
    @DeliveryID INT,
    @Status NVARCHAR(50),
    @TrackingNumber NVARCHAR(100) = NULL,
    @Notes NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validate delivery exists
        IF NOT EXISTS (SELECT 1 FROM Delivery WHERE DeliveryID = @DeliveryID)
        BEGIN
            RAISERROR('Delivery record not found.', 16, 1);
            RETURN;
        END
        
        DECLARE @SalesOrderID INT;
        SELECT @SalesOrderID = SalesOrderID FROM Delivery WHERE DeliveryID = @DeliveryID;
        
        -- Update Delivery Status
        UPDATE Delivery
        SET 
            Status = @Status,
            TrackingNumber = ISNULL(@TrackingNumber, TrackingNumber),
            Notes = ISNULL(@Notes, Notes),
            DeliveryDate = CASE 
                WHEN @Status = 'Delivered' AND DeliveryDate IS NULL THEN GETDATE()
                ELSE DeliveryDate
            END,
            UpdatedDate = GETDATE()
        WHERE DeliveryID = @DeliveryID;
        
        -- Update SalesOrder Status accordingly
        IF @Status = 'Delivered'
        BEGIN
            UPDATE SalesOrder 
            SET Status = 'Delivered', UpdatedDate = GETDATE()
            WHERE SalesOrderID = @SalesOrderID;
        END
        ELSE IF @Status = 'InTransit'
        BEGIN
            UPDATE SalesOrder 
            SET Status = 'Shipped', UpdatedDate = GETDATE()
            WHERE SalesOrderID = @SalesOrderID;
        END
        ELSE IF @Status = 'Pending'
        BEGIN
            -- Revert to previous status if needed
            UPDATE SalesOrder 
            SET Status = 'Confirmed', UpdatedDate = GETDATE()
            WHERE SalesOrderID = @SalesOrderID AND Status IN ('Delivered', 'Shipped');
        END
        
        COMMIT TRANSACTION;
        
        PRINT 'Delivery status updated successfully.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

PRINT 'sp_UpdateDeliveryStatus created successfully.';
GO

-- ================================================================================
-- STORED PROCEDURES AND TRIGGERS CREATION COMPLETE!
-- ================================================================================
PRINT '';
PRINT '========================================';
PRINT 'DELIVERY MANAGEMENT PROCEDURES AND TRIGGERS CREATED SUCCESSFULLY!';
PRINT 'Total Procedures: 8';
PRINT 'Total Triggers: 2';
PRINT '';
PRINT 'Procedures Created:';
PRINT '1. sp_GetAllDeliveries';
PRINT '2. sp_GetDeliveryById';
PRINT '3. sp_GetDeliveryBySalesOrderId';
PRINT '4. sp_UpdateDelivery';
PRINT '5. sp_DeleteDelivery';
PRINT '6. sp_SearchDeliveries';
PRINT '7. sp_GetDeliveryStatistics';
PRINT '8. sp_UpdateDeliveryStatus';
PRINT '';
PRINT 'Triggers Created:';
PRINT '1. trg_CreateDeliveryOnSalesOrder - Auto-creates Delivery when SalesOrder is inserted';
PRINT '2. trg_UpdateDeliveryOnSalesOrderStatusChange - Auto-updates Delivery status when SalesOrder status changes';
PRINT '';
PRINT 'AUTOMATIC WORKFLOW:';
PRINT '- When a Sales Order is created → Delivery record is automatically created';
PRINT '- When Sales Order status changes to "Delivered" → Delivery status updates to "Delivered"';
PRINT '- When Sales Order status changes to "Shipped" → Delivery status updates to "InTransit"';
PRINT '- When Sales Order status changes back → Delivery status synchronizes accordingly';
PRINT '';
PRINT 'Next Step: Execute this script in SSMS';
PRINT 'Then we will create the DeliveryDataService in C#.';
PRINT '========================================';
GO
