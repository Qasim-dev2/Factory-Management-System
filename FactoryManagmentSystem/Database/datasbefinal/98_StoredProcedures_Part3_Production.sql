-- ================================================================================
-- GARMENTS FACTORY MANAGEMENT SYSTEM - STORED PROCEDURES
-- PART 3: PRODUCTION & FINANCIAL PROCEDURES
-- ================================================================================
-- Database: GarmentsFactoryDB
-- Purpose: Production, Tailor, Delivery, Stock, Salary, Revenue Management
-- Created: December 2025
-- Total Procedures in this file: ~70 procedures
-- ================================================================================

USE GarmentsFactoryDB;
GO

-- ================================================================================
-- SECTION 1: PRODUCTION ORDER MANAGEMENT
-- ================================================================================

-- PROCEDURE: sp_GetAllProductionOrders
-- Purpose: Retrieve all production orders
IF OBJECT_ID('sp_GetAllProductionOrders', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetAllProductionOrders;
GO

CREATE PROCEDURE sp_GetAllProductionOrders
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        po.ProductionOrderID,
        po.ProductID,
        p.ProductName,
        po.QuantityOrdered,
        po.QuantityProduced,
        po.Status,
        po.Priority,
        po.StartDate,
        po.EndDate,
        po.CreatedByEmployeeID,
        e.FirstName + ' ' + e.LastName AS CreatedBy,
        po.CreatedDate
    FROM ProductionOrder po
    LEFT JOIN Product p ON po.ProductID = p.ProductID
    LEFT JOIN Employee e ON po.CreatedByEmployeeID = e.EmployeeID
    ORDER BY po.CreatedDate DESC;
END
GO

PRINT '✓ sp_GetAllProductionOrders created';
GO

-- PROCEDURE: sp_GetProductionOrderById
-- Purpose: Get specific production order with details
IF OBJECT_ID('sp_GetProductionOrderById', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetProductionOrderById;
GO

CREATE PROCEDURE sp_GetProductionOrderById
    @ProductionOrderID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        po.ProductionOrderID,
        po.ProductID,
        p.ProductName,
        po.QuantityOrdered,
        po.QuantityProduced,
        po.Status,
        po.Priority,
        po.StartDate,
        po.EndDate,
        po.CreatedByEmployeeID,
        e.FirstName + ' ' + e.LastName AS CreatedBy,
        po.CreatedDate,
        po.UpdatedDate
    FROM ProductionOrder po
    LEFT JOIN Product p ON po.ProductID = p.ProductID
    LEFT JOIN Employee e ON po.CreatedByEmployeeID = e.EmployeeID
    WHERE po.ProductionOrderID = @ProductionOrderID;
END
GO

PRINT '✓ sp_GetProductionOrderById created';
GO

-- PROCEDURE: sp_UpdateProductionOrder
-- Purpose: Update production order details
IF OBJECT_ID('sp_UpdateProductionOrder', 'P') IS NOT NULL
    DROP PROCEDURE sp_UpdateProductionOrder;
GO

CREATE PROCEDURE sp_UpdateProductionOrder
    @ProductionOrderID INT,
    @ProductID INT = NULL,
    @QuantityOrdered INT = NULL,
    @QuantityProduced INT = NULL,
    @Status NVARCHAR(50) = NULL,
    @Priority NVARCHAR(50) = NULL,
    @StartDate DATE = NULL,
    @EndDate DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE ProductionOrder
    SET ProductID = ISNULL(@ProductID, ProductID),
        QuantityOrdered = ISNULL(@QuantityOrdered, QuantityOrdered),
        QuantityProduced = ISNULL(@QuantityProduced, QuantityProduced),
        Status = ISNULL(@Status, Status),
        Priority = ISNULL(@Priority, Priority),
        StartDate = ISNULL(@StartDate, StartDate),
        EndDate = @EndDate,
        UpdatedDate = GETDATE()
    WHERE ProductionOrderID = @ProductionOrderID;
END
GO

PRINT '✓ sp_UpdateProductionOrder created';
GO

-- PROCEDURE: sp_DeleteProductionOrder
-- Purpose: Delete production order
IF OBJECT_ID('sp_DeleteProductionOrder', 'P') IS NOT NULL
    DROP PROCEDURE sp_DeleteProductionOrder;
GO

CREATE PROCEDURE sp_DeleteProductionOrder
    @ProductionOrderID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    DELETE FROM ProductionOrder WHERE ProductionOrderID = @ProductionOrderID;
END
GO

PRINT '✓ sp_DeleteProductionOrder created';
GO

-- PROCEDURE: sp_GetProductionOrdersByStatus
-- Purpose: Get production orders by status
IF OBJECT_ID('sp_GetProductionOrdersByStatus', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetProductionOrdersByStatus;
GO

CREATE PROCEDURE sp_GetProductionOrdersByStatus
    @Status NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        po.ProductionOrderID,
        p.ProductName,
        po.QuantityOrdered,
        po.QuantityProduced,
        po.Status,
        po.Priority,
        po.StartDate
    FROM ProductionOrder po
    JOIN Product p ON po.ProductID = p.ProductID
    WHERE po.Status = @Status
    ORDER BY po.Priority DESC, po.StartDate;
END
GO

PRINT '✓ sp_GetProductionOrdersByStatus created';
GO

-- ================================================================================
-- SECTION 2: TAILOR ASSIGNMENT & TRACKING
-- ================================================================================

-- PROCEDURE: sp_GetAllTailorAssignments
-- Purpose: Get all tailor assignments
IF OBJECT_ID('sp_GetAllTailorAssignments', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetAllTailorAssignments;
GO

CREATE PROCEDURE sp_GetAllTailorAssignments
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        ta.TailorAssignmentID,
        ta.TailorID,
        e.FirstName + ' ' + e.LastName AS TailorName,
        ta.ProductionOrderID,
        ta.SalesOrderID,
        ta.DealID,
        ta.ProductID,
        p.ProductName,
        ta.QuantityAssigned,
        ta.QuantityCompleted,
        ta.AssignedDate,
        ta.CompletedDate,
        ta.Status
    FROM TailorAssignment ta
    JOIN Employee e ON ta.TailorID = e.EmployeeID
    LEFT JOIN Product p ON ta.ProductID = p.ProductID
    ORDER BY ta.AssignedDate DESC;
END
GO

PRINT '✓ sp_GetAllTailorAssignments created';
GO

-- PROCEDURE: sp_GetTailorAssignmentsByTailor
-- Purpose: Get assignments for specific tailor
IF OBJECT_ID('sp_GetTailorAssignmentsByTailor', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetTailorAssignmentsByTailor;
GO

CREATE PROCEDURE sp_GetTailorAssignmentsByTailor
    @TailorID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        ta.TailorAssignmentID,
        ta.ProductionOrderID,
        ta.SalesOrderID,
        ta.DealID,
        ta.ProductID,
        p.ProductName,
        ta.QuantityAssigned,
        ta.QuantityCompleted,
        ta.AssignedDate,
        ta.CompletedDate,
        ta.Status
    FROM TailorAssignment ta
    LEFT JOIN Product p ON ta.ProductID = p.ProductID
    WHERE ta.TailorID = @TailorID
    ORDER BY ta.AssignedDate DESC;
END
GO

PRINT '✓ sp_GetTailorAssignmentsByTailor created';
GO

-- PROCEDURE: sp_UpdateTailorProgress
-- Purpose: Update tailor assignment progress
IF OBJECT_ID('sp_UpdateTailorProgress', 'P') IS NOT NULL
    DROP PROCEDURE sp_UpdateTailorProgress;
GO

CREATE PROCEDURE sp_UpdateTailorProgress
    @TailorAssignmentID INT,
    @QuantityCompleted INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @QuantityAssigned INT;

        SELECT @QuantityAssigned = QuantityAssigned 
        FROM TailorAssignment 
        WHERE TailorAssignmentID = @TailorAssignmentID;

        UPDATE TailorAssignment
        SET QuantityCompleted = @QuantityCompleted,
            Status = CASE 
                WHEN @QuantityCompleted >= @QuantityAssigned THEN 'Complete'
                WHEN @QuantityCompleted > 0 THEN 'In Progress'
                ELSE 'Incomplete'
            END,
            CompletedDate = CASE 
                WHEN @QuantityCompleted >= @QuantityAssigned THEN GETDATE()
                ELSE NULL
            END
        WHERE TailorAssignmentID = @TailorAssignmentID;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

PRINT '✓ sp_UpdateTailorProgress created';
GO

-- PROCEDURE: sp_GetTailorWorkload
-- Purpose: Get current workload for tailor
IF OBJECT_ID('sp_GetTailorWorkload', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetTailorWorkload;
GO

CREATE PROCEDURE sp_GetTailorWorkload
    @TailorID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        COUNT(*) AS TotalAssignments,
        SUM(CASE WHEN Status = 'Incomplete' THEN 1 ELSE 0 END) AS IncompleteAssignments,
        SUM(CASE WHEN Status = 'In Progress' THEN 1 ELSE 0 END) AS InProgressAssignments,
        SUM(CASE WHEN Status = 'Complete' THEN 1 ELSE 0 END) AS CompletedAssignments,
        SUM(QuantityAssigned - QuantityCompleted) AS RemainingQuantity
    FROM TailorAssignment
    WHERE TailorID = @TailorID;
END
GO

PRINT '✓ sp_GetTailorWorkload created';
GO

-- PROCEDURE: sp_GetProductionManagerStatistics
-- Purpose: Get statistics for production manager dashboard
IF OBJECT_ID('sp_GetProductionManagerStatistics', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetProductionManagerStatistics;
GO

CREATE PROCEDURE sp_GetProductionManagerStatistics
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        COUNT(*) AS TotalOrders,
        SUM(CASE WHEN Status = 'Pending' THEN 1 ELSE 0 END) AS PendingOrders,
        SUM(CASE WHEN Status = 'In Progress' THEN 1 ELSE 0 END) AS InProgressOrders,
        SUM(CASE WHEN Status = 'Completed' THEN 1 ELSE 0 END) AS CompletedOrders,
        SUM(QuantityOrdered) AS TotalQuantityOrdered,
        SUM(QuantityProduced) AS TotalQuantityProduced
    FROM ProductionOrder;
END
GO

PRINT '✓ sp_GetProductionManagerStatistics created';
GO

-- ================================================================================
-- SECTION 3: DELIVERY MANAGEMENT
-- ================================================================================

-- PROCEDURE: sp_GetAllDeliveries
-- Purpose: Get all deliveries with order information
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
        d.DeliveryPersonID,
        e.FirstName + ' ' + e.LastName AS DeliveryPerson,
        d.DeliveryAddress,
        d.City,
        d.Province,
        d.ScheduledDate,
        d.ActualDeliveryDate,
        d.Status,
        d.Notes,
        d.CreatedDate
    FROM Delivery d
    LEFT JOIN Employee e ON d.DeliveryPersonID = e.EmployeeID
    ORDER BY d.ScheduledDate DESC;
END
GO

PRINT '✓ sp_GetAllDeliveries created';
GO

-- PROCEDURE: sp_GetDeliveriesByPerson
-- Purpose: Get deliveries assigned to specific delivery person
IF OBJECT_ID('sp_GetDeliveriesByPerson', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetDeliveriesByPerson;
GO

CREATE PROCEDURE sp_GetDeliveriesByPerson
    @DeliveryPersonID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        d.DeliveryID,
        d.SalesOrderID,
        d.DealID,
        d.DeliveryAddress,
        d.City,
        d.Province,
        d.ScheduledDate,
        d.ActualDeliveryDate,
        d.Status,
        d.Notes,
        CASE 
            WHEN d.SalesOrderID IS NOT NULL THEN (SELECT r.CompanyName FROM SalesOrder so JOIN Retailer r ON so.RetailerID = r.RetailerID WHERE so.SalesOrderID = d.SalesOrderID)
            WHEN d.DealID IS NOT NULL THEN (SELECT ClientName FROM Deal WHERE DealID = d.DealID)
        END AS CustomerName
    FROM Delivery d
    WHERE d.DeliveryPersonID = @DeliveryPersonID
    ORDER BY d.ScheduledDate DESC;
END
GO

PRINT '✓ sp_GetDeliveriesByPerson created';
GO

-- PROCEDURE: sp_UpdateDeliveryStatus
-- Purpose: Update delivery status
IF OBJECT_ID('sp_UpdateDeliveryStatus', 'P') IS NOT NULL
    DROP PROCEDURE sp_UpdateDeliveryStatus;
GO

CREATE PROCEDURE sp_UpdateDeliveryStatus
    @DeliveryID INT,
    @Status NVARCHAR(50),
    @ActualDeliveryDate DATETIME = NULL,
    @Notes NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE Delivery
    SET Status = @Status,
        ActualDeliveryDate = ISNULL(@ActualDeliveryDate, ActualDeliveryDate),
        Notes = ISNULL(@Notes, Notes),
        UpdatedDate = GETDATE()
    WHERE DeliveryID = @DeliveryID;
END
GO

PRINT '✓ sp_UpdateDeliveryStatus created';
GO

-- PROCEDURE: sp_GetDeliveriesByStatus
-- Purpose: Get deliveries filtered by status
IF OBJECT_ID('sp_GetDeliveriesByStatus', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetDeliveriesByStatus;
GO

CREATE PROCEDURE sp_GetDeliveriesByStatus
    @Status NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        d.DeliveryID,
        d.SalesOrderID,
        d.DealID,
        d.DeliveryPersonID,
        e.FirstName + ' ' + e.LastName AS DeliveryPerson,
        d.DeliveryAddress,
        d.City,
        d.ScheduledDate,
        d.Status
    FROM Delivery d
    LEFT JOIN Employee e ON d.DeliveryPersonID = e.EmployeeID
    WHERE d.Status = @Status
    ORDER BY d.ScheduledDate;
END
GO

PRINT '✓ sp_GetDeliveriesByStatus created';
GO

-- PROCEDURE: sp_GetDeliveryStatistics
-- Purpose: Get delivery statistics for dashboard
IF OBJECT_ID('sp_GetDeliveryStatistics', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetDeliveryStatistics;
GO

CREATE PROCEDURE sp_GetDeliveryStatistics
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        COUNT(*) AS TotalDeliveries,
        SUM(CASE WHEN Status = 'Pending' THEN 1 ELSE 0 END) AS PendingDeliveries,
        SUM(CASE WHEN Status = 'In Transit' THEN 1 ELSE 0 END) AS InTransitDeliveries,
        SUM(CASE WHEN Status = 'Delivered' THEN 1 ELSE 0 END) AS DeliveredCount,
        SUM(CASE WHEN Status = 'Failed' THEN 1 ELSE 0 END) AS FailedDeliveries
    FROM Delivery;
END
GO

PRINT '✓ sp_GetDeliveryStatistics created';
GO

-- ================================================================================
-- SECTION 4: STOCK & MATERIAL USAGE TRACKING
-- ================================================================================

-- PROCEDURE: sp_GetLowStockRawMaterials
-- Purpose: Get raw materials below minimum stock level
IF OBJECT_ID('sp_GetLowStockRawMaterials', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetLowStockRawMaterials;
GO

CREATE PROCEDURE sp_GetLowStockRawMaterials
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        RawMaterialID,
        MaterialName,
        Quantity AS CurrentStock,
        MinimumStockLevel,
        Unit,
        (MinimumStockLevel - Quantity) AS ShortfallAmount,
        Supplier,
        UnitPrice
    FROM RawMaterial
    WHERE Quantity < MinimumStockLevel
    ORDER BY (MinimumStockLevel - Quantity) DESC;
END
GO

PRINT '✓ sp_GetLowStockRawMaterials created';
GO

-- PROCEDURE: sp_RecordStockUsage
-- Purpose: Record stock usage for production
IF OBJECT_ID('sp_RecordStockUsage', 'P') IS NOT NULL
    DROP PROCEDURE sp_RecordStockUsage;
GO

CREATE PROCEDURE sp_RecordStockUsage
    @RawMaterialID INT,
    @ProductionOrderID INT = NULL,
    @QuantityUsed DECIMAL(18,2),
    @UsedBy INT,
    @Purpose NVARCHAR(200) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Check available quantity
        DECLARE @AvailableQuantity DECIMAL(18,2);
        SELECT @AvailableQuantity = Quantity FROM RawMaterial WHERE RawMaterialID = @RawMaterialID;

        IF @AvailableQuantity < @QuantityUsed
        BEGIN
            RAISERROR('Insufficient stock. Available: %f, Requested: %f', 16, 1, @AvailableQuantity, @QuantityUsed);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Deduct from stock
        UPDATE RawMaterial
        SET Quantity = Quantity - @QuantityUsed,
            UpdatedDate = GETDATE()
        WHERE RawMaterialID = @RawMaterialID;

        -- Record usage
        INSERT INTO StockUsage (RawMaterialID, ProductionOrderID, QuantityUsed, UsedDate, UsedBy, Purpose, CreatedDate)
        VALUES (@RawMaterialID, @ProductionOrderID, @QuantityUsed, GETDATE(), @UsedBy, @Purpose, GETDATE());

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

PRINT '✓ sp_RecordStockUsage created';
GO

-- PROCEDURE: sp_GetStockUsageHistory
-- Purpose: Get stock usage history
IF OBJECT_ID('sp_GetStockUsageHistory', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetStockUsageHistory;
GO

CREATE PROCEDURE sp_GetStockUsageHistory
    @RawMaterialID INT = NULL,
    @StartDate DATE = NULL,
    @EndDate DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        su.StockUsageID,
        su.RawMaterialID,
        rm.MaterialName,
        su.ProductionOrderID,
        su.QuantityUsed,
        rm.Unit,
        su.UsedDate,
        su.UsedBy,
        e.FirstName + ' ' + e.LastName AS UsedByName,
        su.Purpose
    FROM StockUsage su
    JOIN RawMaterial rm ON su.RawMaterialID = rm.RawMaterialID
    LEFT JOIN Employee e ON su.UsedBy = e.EmployeeID
    WHERE (@RawMaterialID IS NULL OR su.RawMaterialID = @RawMaterialID)
      AND (@StartDate IS NULL OR CAST(su.UsedDate AS DATE) >= @StartDate)
      AND (@EndDate IS NULL OR CAST(su.UsedDate AS DATE) <= @EndDate)
    ORDER BY su.UsedDate DESC;
END
GO

PRINT '✓ sp_GetStockUsageHistory created';
GO

-- PROCEDURE: sp_GetPurchaseHistory
-- Purpose: Get purchase history for raw materials
IF OBJECT_ID('sp_GetPurchaseHistory', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetPurchaseHistory;
GO

CREATE PROCEDURE sp_GetPurchaseHistory
    @RawMaterialID INT = NULL,
    @StartDate DATE = NULL,
    @EndDate DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        ph.PurchaseID,
        ph.RawMaterialID,
        rm.MaterialName,
        ph.QuantityPurchased,
        rm.Unit,
        ph.UnitPrice,
        ph.TotalCost,
        ph.Supplier,
        ph.PurchaseDate,
        ph.RecordedBy,
        e.FirstName + ' ' + e.LastName AS RecordedByName,
        ph.Notes
    FROM PurchaseHistory ph
    JOIN RawMaterial rm ON ph.RawMaterialID = rm.RawMaterialID
    LEFT JOIN Employee e ON ph.RecordedBy = e.EmployeeID
    WHERE (@RawMaterialID IS NULL OR ph.RawMaterialID = @RawMaterialID)
      AND (@StartDate IS NULL OR CAST(ph.PurchaseDate AS DATE) >= @StartDate)
      AND (@EndDate IS NULL OR CAST(ph.PurchaseDate AS DATE) <= @EndDate)
    ORDER BY ph.PurchaseDate DESC;
END
GO

PRINT '✓ sp_GetPurchaseHistory created';
GO

-- PROCEDURE: sp_DeductRawMaterialStock
-- Purpose: Deduct stock when production order approved
IF OBJECT_ID('sp_DeductRawMaterialStock', 'P') IS NOT NULL
    DROP PROCEDURE sp_DeductRawMaterialStock;
GO

CREATE PROCEDURE sp_DeductRawMaterialStock
    @ProductionOrderID INT,
    @DeductedBy INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @ProductID INT, @QuantityOrdered INT;

        -- Get production order details
        SELECT @ProductID = ProductID, @QuantityOrdered = QuantityOrdered
        FROM ProductionOrder
        WHERE ProductionOrderID = @ProductionOrderID;

        -- Deduct materials based on product requirements
        DECLARE material_cursor CURSOR FOR
        SELECT pmr.RawMaterialID, pmr.QuantityRequired * @QuantityOrdered AS TotalRequired
        FROM ProductMaterialRequirement pmr
        WHERE pmr.ProductID = @ProductID;

        DECLARE @RawMaterialID INT, @TotalRequired DECIMAL(18,2);

        OPEN material_cursor;
        FETCH NEXT FROM material_cursor INTO @RawMaterialID, @TotalRequired;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            -- Check stock availability
            DECLARE @Available DECIMAL(18,2);
            SELECT @Available = Quantity FROM RawMaterial WHERE RawMaterialID = @RawMaterialID;

            IF @Available < @TotalRequired
            BEGIN
                DECLARE @MaterialName NVARCHAR(100);
                SELECT @MaterialName = MaterialName FROM RawMaterial WHERE RawMaterialID = @RawMaterialID;
                RAISERROR('Insufficient stock for %s. Available: %f, Required: %f', 16, 1, @MaterialName, @Available, @TotalRequired);
                CLOSE material_cursor;
                DEALLOCATE material_cursor;
                ROLLBACK TRANSACTION;
                RETURN;
            END

            -- Deduct from stock
            UPDATE RawMaterial
            SET Quantity = Quantity - @TotalRequired,
                UpdatedDate = GETDATE()
            WHERE RawMaterialID = @RawMaterialID;

            -- Record usage
            INSERT INTO StockUsage (RawMaterialID, ProductionOrderID, QuantityUsed, UsedDate, UsedBy, Purpose, CreatedDate)
            VALUES (@RawMaterialID, @ProductionOrderID, @TotalRequired, GETDATE(), @DeductedBy, 
                    'Production Order #' + CAST(@ProductionOrderID AS NVARCHAR), GETDATE());

            FETCH NEXT FROM material_cursor INTO @RawMaterialID, @TotalRequired;
        END

        CLOSE material_cursor;
        DEALLOCATE material_cursor;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

PRINT '✓ sp_DeductRawMaterialStock created';
GO

-- ================================================================================
-- SECTION 5: SALARY MANAGEMENT & PAYROLL
-- ================================================================================

-- PROCEDURE: sp_GetAllSalaries
-- Purpose: Get all salary records
IF OBJECT_ID('sp_GetAllSalaries', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetAllSalaries;
GO

CREATE PROCEDURE sp_GetAllSalaries
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        s.SalaryID,
        s.EmployeeID,
        e.FirstName + ' ' + e.LastName AS EmployeeName,
        d.DepartmentName,
        s.BaseSalary,
        s.Allowances,
        s.Deductions,
        s.NetSalary,
        s.SalaryMonth,
        s.SalaryYear,
        s.PaymentDate,
        s.PaymentStatus,
        s.CreatedDate
    FROM Salary s
    JOIN Employee e ON s.EmployeeID = e.EmployeeID
    LEFT JOIN Department d ON e.DepartmentID = d.DepartmentID
    ORDER BY s.SalaryYear DESC, s.SalaryMonth DESC;
END
GO

PRINT '✓ sp_GetAllSalaries created';
GO

-- PROCEDURE: sp_GetSalaryByEmployee
-- Purpose: Get salary records for specific employee
IF OBJECT_ID('sp_GetSalaryByEmployee', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetSalaryByEmployee;
GO

CREATE PROCEDURE sp_GetSalaryByEmployee
    @EmployeeID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        s.SalaryID,
        s.BaseSalary,
        s.Allowances,
        s.Deductions,
        s.NetSalary,
        s.SalaryMonth,
        s.SalaryYear,
        s.PaymentDate,
        s.PaymentStatus,
        s.CreatedDate
    FROM Salary s
    WHERE s.EmployeeID = @EmployeeID
    ORDER BY s.SalaryYear DESC, s.SalaryMonth DESC;
END
GO

PRINT '✓ sp_GetSalaryByEmployee created';
GO

-- PROCEDURE: sp_AddSalary
-- Purpose: Add new salary record
IF OBJECT_ID('sp_AddSalary', 'P') IS NOT NULL
    DROP PROCEDURE sp_AddSalary;
GO

CREATE PROCEDURE sp_AddSalary
    @EmployeeID INT,
    @BaseSalary DECIMAL(18,2),
    @Allowances DECIMAL(18,2) = 0,
    @Deductions DECIMAL(18,2) = 0,
    @SalaryMonth INT,
    @SalaryYear INT,
    @PaymentDate DATE = NULL,
    @PaymentStatus NVARCHAR(50) = 'Pending',
    @NewSalaryID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @NetSalary DECIMAL(18,2) = @BaseSalary + @Allowances - @Deductions;
    
    INSERT INTO Salary (
        EmployeeID, BaseSalary, Allowances, Deductions, NetSalary,
        SalaryMonth, SalaryYear, PaymentDate, PaymentStatus, CreatedDate
    )
    VALUES (
        @EmployeeID, @BaseSalary, @Allowances, @Deductions, @NetSalary,
        @SalaryMonth, @SalaryYear, @PaymentDate, @PaymentStatus, GETDATE()
    );
    
    SET @NewSalaryID = SCOPE_IDENTITY();
END
GO

PRINT '✓ sp_AddSalary created';
GO

-- PROCEDURE: sp_UpdateSalary
-- Purpose: Update salary record
IF OBJECT_ID('sp_UpdateSalary', 'P') IS NOT NULL
    DROP PROCEDURE sp_UpdateSalary;
GO

CREATE PROCEDURE sp_UpdateSalary
    @SalaryID INT,
    @BaseSalary DECIMAL(18,2) = NULL,
    @Allowances DECIMAL(18,2) = NULL,
    @Deductions DECIMAL(18,2) = NULL,
    @PaymentDate DATE = NULL,
    @PaymentStatus NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE Salary
    SET BaseSalary = ISNULL(@BaseSalary, BaseSalary),
        Allowances = ISNULL(@Allowances, Allowances),
        Deductions = ISNULL(@Deductions, Deductions),
        NetSalary = ISNULL(@BaseSalary, BaseSalary) + ISNULL(@Allowances, Allowances) - ISNULL(@Deductions, Deductions),
        PaymentDate = ISNULL(@PaymentDate, PaymentDate),
        PaymentStatus = ISNULL(@PaymentStatus, PaymentStatus),
        UpdatedDate = GETDATE()
    WHERE SalaryID = @SalaryID;
END
GO

PRINT '✓ sp_UpdateSalary created';
GO

-- PROCEDURE: sp_GetPendingSalaries
-- Purpose: Get pending salary payments
IF OBJECT_ID('sp_GetPendingSalaries', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetPendingSalaries;
GO

CREATE PROCEDURE sp_GetPendingSalaries
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        s.SalaryID,
        s.EmployeeID,
        e.FirstName + ' ' + e.LastName AS EmployeeName,
        s.NetSalary,
        s.SalaryMonth,
        s.SalaryYear,
        s.PaymentStatus
    FROM Salary s
    JOIN Employee e ON s.EmployeeID = e.EmployeeID
    WHERE s.PaymentStatus = 'Pending'
    ORDER BY s.SalaryYear DESC, s.SalaryMonth DESC;
END
GO

PRINT '✓ sp_GetPendingSalaries created';
GO

-- PROCEDURE: sp_AutoPayPastSalaries
-- Purpose: Auto-generate salary records for past months
-- Automation: Creates salary records based on employee base salary
IF OBJECT_ID('sp_AutoPayPastSalaries', 'P') IS NOT NULL
    DROP PROCEDURE sp_AutoPayPastSalaries;
GO

CREATE PROCEDURE sp_AutoPayPastSalaries
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @CurrentYear INT = YEAR(GETDATE());
        DECLARE @CurrentMonth INT = MONTH(GETDATE());
        DECLARE @EmployeeID INT, @BaseSalary DECIMAL(18,2);

        -- Create cursor for all active employees
        DECLARE employee_cursor CURSOR FOR
        SELECT EmployeeID, Salary FROM Employee WHERE IsActive = 1;

        OPEN employee_cursor;
        FETCH NEXT FROM employee_cursor INTO @EmployeeID, @BaseSalary;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            -- Check if salary exists for current month
            IF NOT EXISTS (
                SELECT 1 FROM Salary 
                WHERE EmployeeID = @EmployeeID 
                  AND SalaryYear = @CurrentYear 
                  AND SalaryMonth = @CurrentMonth
            )
            BEGIN
                -- Insert salary record
                INSERT INTO Salary (
                    EmployeeID, BaseSalary, Allowances, Deductions, NetSalary,
                    SalaryMonth, SalaryYear, PaymentStatus, CreatedDate
                )
                VALUES (
                    @EmployeeID, @BaseSalary, 0, 0, @BaseSalary,
                    @CurrentMonth, @CurrentYear, 'Pending', GETDATE()
                );
            END

            FETCH NEXT FROM employee_cursor INTO @EmployeeID, @BaseSalary;
        END

        CLOSE employee_cursor;
        DEALLOCATE employee_cursor;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

PRINT '✓ sp_AutoPayPastSalaries created (auto-generates monthly salaries)';
GO

-- ================================================================================
-- SECTION 6: REVENUE & FINANCIAL ANALYTICS
-- ================================================================================

-- PROCEDURE: sp_GetRevenueByDateRange
-- Purpose: Calculate revenue from sales orders and deals in date range
IF OBJECT_ID('sp_GetRevenueByDateRange', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetRevenueByDateRange;
GO

CREATE PROCEDURE sp_GetRevenueByDateRange
    @StartDate DATE,
    @EndDate DATE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Revenue from Sales Orders
    SELECT 
        'SalesOrder' AS RevenueSource,
        COUNT(*) AS OrderCount,
        SUM(TotalAmount) AS TotalRevenue
    FROM SalesOrder
    WHERE CAST(OrderDate AS DATE) BETWEEN @StartDate AND @EndDate
      AND Status IN ('Approved', 'In Production', 'Completed', 'Delivered')

    UNION ALL

    -- Revenue from Deals
    SELECT 
        'Deal' AS RevenueSource,
        COUNT(*) AS OrderCount,
        SUM(TotalAmount) AS TotalRevenue
    FROM Deal
    WHERE CAST(StartDate AS DATE) BETWEEN @StartDate AND @EndDate
      AND Status IN ('Approved', 'In Progress', 'Completed');
END
GO

PRINT '✓ sp_GetRevenueByDateRange created';
GO

-- PROCEDURE: sp_GetMonthlyRevenue
-- Purpose: Get revenue broken down by month
IF OBJECT_ID('sp_GetMonthlyRevenue', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetMonthlyRevenue;
GO

CREATE PROCEDURE sp_GetMonthlyRevenue
    @Year INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Monthly sales order revenue
    SELECT 
        MONTH(OrderDate) AS Month,
        YEAR(OrderDate) AS Year,
        'SalesOrder' AS Source,
        SUM(TotalAmount) AS Revenue
    FROM SalesOrder
    WHERE YEAR(OrderDate) = @Year
      AND Status IN ('Approved', 'In Production', 'Completed', 'Delivered')
    GROUP BY MONTH(OrderDate), YEAR(OrderDate)

    UNION ALL

    -- Monthly deal revenue
    SELECT 
        MONTH(StartDate) AS Month,
        YEAR(StartDate) AS Year,
        'Deal' AS Source,
        SUM(TotalAmount) AS Revenue
    FROM Deal
    WHERE YEAR(StartDate) = @Year
      AND Status IN ('Approved', 'In Progress', 'Completed')
    GROUP BY MONTH(StartDate), YEAR(StartDate)
    
    ORDER BY Month, Source;
END
GO

PRINT '✓ sp_GetMonthlyRevenue created';
GO

-- PROCEDURE: sp_GetExpensesByDateRange
-- Purpose: Calculate expenses (salaries + material purchases)
IF OBJECT_ID('sp_GetExpensesByDateRange', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetExpensesByDateRange;
GO

CREATE PROCEDURE sp_GetExpensesByDateRange
    @StartDate DATE,
    @EndDate DATE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Salary expenses
    SELECT 
        'Salary' AS ExpenseType,
        COUNT(*) AS TransactionCount,
        SUM(NetSalary) AS TotalExpense
    FROM Salary
    WHERE PaymentDate BETWEEN @StartDate AND @EndDate
      AND PaymentStatus = 'Paid'

    UNION ALL

    -- Material purchase expenses
    SELECT 
        'Material Purchase' AS ExpenseType,
        COUNT(*) AS TransactionCount,
        SUM(TotalCost) AS TotalExpense
    FROM PurchaseHistory
    WHERE CAST(PurchaseDate AS DATE) BETWEEN @StartDate AND @EndDate;
END
GO

PRINT '✓ sp_GetExpensesByDateRange created';
GO

-- PROCEDURE: sp_GetProfitLoss
-- Purpose: Calculate profit/loss (revenue - expenses)
IF OBJECT_ID('sp_GetProfitLoss', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetProfitLoss;
GO

CREATE PROCEDURE sp_GetProfitLoss
    @StartDate DATE,
    @EndDate DATE
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @Revenue DECIMAL(18,2) = 0;
    DECLARE @Expenses DECIMAL(18,2) = 0;
    
    -- Calculate revenue
    SELECT @Revenue = ISNULL(SUM(TotalAmount), 0)
    FROM (
        SELECT TotalAmount FROM SalesOrder 
        WHERE CAST(OrderDate AS DATE) BETWEEN @StartDate AND @EndDate
          AND Status IN ('Approved', 'In Production', 'Completed', 'Delivered')
        UNION ALL
        SELECT TotalAmount FROM Deal 
        WHERE CAST(StartDate AS DATE) BETWEEN @StartDate AND @EndDate
          AND Status IN ('Approved', 'In Progress', 'Completed')
    ) AS Revenue;
    
    -- Calculate expenses
    SELECT @Expenses = ISNULL(SUM(Expense), 0)
    FROM (
        SELECT NetSalary AS Expense FROM Salary 
        WHERE PaymentDate BETWEEN @StartDate AND @EndDate AND PaymentStatus = 'Paid'
        UNION ALL
        SELECT TotalCost AS Expense FROM PurchaseHistory 
        WHERE CAST(PurchaseDate AS DATE) BETWEEN @StartDate AND @EndDate
    ) AS Expenses;
    
    -- Return result
    SELECT 
        @Revenue AS TotalRevenue,
        @Expenses AS TotalExpenses,
        (@Revenue - @Expenses) AS NetProfitLoss,
        CASE 
            WHEN (@Revenue - @Expenses) > 0 THEN 'Profit'
            WHEN (@Revenue - @Expenses) < 0 THEN 'Loss'
            ELSE 'Break Even'
        END AS Status;
END
GO

PRINT '✓ sp_GetProfitLoss created';
GO

-- PROCEDURE: sp_GetTopSellingProducts
-- Purpose: Get top selling products by quantity or revenue
IF OBJECT_ID('sp_GetTopSellingProducts', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetTopSellingProducts;
GO

CREATE PROCEDURE sp_GetTopSellingProducts
    @TopCount INT = 10,
    @StartDate DATE = NULL,
    @EndDate DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT TOP (@TopCount)
        p.ProductID,
        p.ProductName,
        SUM(soi.Quantity) AS TotalQuantitySold,
        SUM(soi.Quantity * soi.UnitPrice) AS TotalRevenue,
        COUNT(DISTINCT so.SalesOrderID) AS OrderCount
    FROM Product p
    JOIN SalesOrderItem soi ON p.ProductID = soi.ProductID
    JOIN SalesOrder so ON soi.SalesOrderID = so.SalesOrderID
    WHERE (@StartDate IS NULL OR CAST(so.OrderDate AS DATE) >= @StartDate)
      AND (@EndDate IS NULL OR CAST(so.OrderDate AS DATE) <= @EndDate)
      AND so.Status NOT IN ('Cancelled', 'Rejected', 'Pending')
    GROUP BY p.ProductID, p.ProductName
    ORDER BY TotalRevenue DESC;
END
GO

PRINT '✓ sp_GetTopSellingProducts created';
GO

-- PROCEDURE: sp_GetDepartmentAnalytics
-- Purpose: Get analytics for each department
IF OBJECT_ID('sp_GetDepartmentAnalytics', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetDepartmentAnalytics;
GO

CREATE PROCEDURE sp_GetDepartmentAnalytics
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        d.DepartmentID,
        d.DepartmentName,
        COUNT(e.EmployeeID) AS EmployeeCount,
        SUM(e.Salary) AS TotalSalaryExpense,
        AVG(e.Salary) AS AverageSalary,
        d.Budget
    FROM Department d
    LEFT JOIN Employee e ON d.DepartmentID = e.DepartmentID AND e.IsActive = 1
    GROUP BY d.DepartmentID, d.DepartmentName, d.Budget
    ORDER BY d.DepartmentName;
END
GO

PRINT '✓ sp_GetDepartmentAnalytics created';
GO

-- PROCEDURE: sp_GetOwnerDashboardStatistics
-- Purpose: Get comprehensive statistics for owner dashboard
IF OBJECT_ID('sp_GetOwnerDashboardStatistics', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetOwnerDashboardStatistics;
GO

CREATE PROCEDURE sp_GetOwnerDashboardStatistics
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Overall statistics
    SELECT 
        (SELECT COUNT(*) FROM Employee WHERE IsActive = 1) AS TotalEmployees,
        (SELECT COUNT(*) FROM SalesOrder WHERE Status = 'Pending Approval') AS PendingSalesOrders,
        (SELECT COUNT(*) FROM Deal WHERE Status = 'Pending Approval') AS PendingDeals,
        (SELECT COUNT(*) FROM OrderApproval WHERE Status = 'Pending') AS TotalPendingApprovals,
        (SELECT COUNT(*) FROM ProductionOrder WHERE Status IN ('Pending', 'In Progress')) AS ActiveProductionOrders,
        (SELECT COUNT(*) FROM Delivery WHERE Status IN ('Pending', 'In Transit')) AS ActiveDeliveries,
        (SELECT COUNT(*) FROM RawMaterial WHERE Quantity < MinimumStockLevel) AS LowStockMaterials;
END
GO

PRINT '✓ sp_GetOwnerDashboardStatistics created';
GO

-- PROCEDURE: sp_GetSalesManagerStatistics
-- Purpose: Get statistics for sales manager dashboard
IF OBJECT_ID('sp_GetSalesManagerStatistics', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetSalesManagerStatistics;
GO

CREATE PROCEDURE sp_GetSalesManagerStatistics
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        (SELECT COUNT(*) FROM SalesOrder) AS TotalSalesOrders,
        (SELECT COUNT(*) FROM SalesOrder WHERE Status = 'Pending Approval') AS PendingOrders,
        (SELECT COUNT(*) FROM SalesOrder WHERE Status = 'Approved') AS ApprovedOrders,
        (SELECT COUNT(*) FROM Deal) AS TotalDeals,
        (SELECT COUNT(*) FROM Deal WHERE Status = 'Pending Approval') AS PendingDeals,
        (SELECT SUM(TotalAmount) FROM SalesOrder WHERE Status NOT IN ('Cancelled', 'Rejected')) AS TotalSalesRevenue,
        (SELECT SUM(TotalAmount) FROM Deal WHERE Status NOT IN ('Cancelled', 'Rejected')) AS TotalDealRevenue,
        (SELECT COUNT(*) FROM Retailer) AS TotalRetailers;
END
GO

PRINT '✓ sp_GetSalesManagerStatistics created';
GO

-- ================================================================================
-- END OF PART 3: PRODUCTION & FINANCIAL PROCEDURES
-- ================================================================================
PRINT '';
PRINT '========================================';
PRINT 'PART 3 COMPLETE: Production & Financial Procedures';
PRINT 'Total: ~35 procedures created';
PRINT '========================================';
GO
