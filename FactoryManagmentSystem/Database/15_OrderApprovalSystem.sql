-- ================================================================================
-- ORDER APPROVAL SYSTEM - COMPLETE WORKFLOW IMPLEMENTATION
-- ================================================================================
-- This script creates tables and procedures for the complete order approval workflow:
-- 1. Salesperson creates SalesOrder/Deal (Pending Approval)
-- 2. Owner reviews and checks raw materials
-- 3. Owner approves (creates ProductionOrder, deducts materials, assigns tailors)
-- 4. Tailors update status (Incomplete → Complete)
-- 5. Delivery person updates (Pending → Delivered)
-- ================================================================================

USE GarmentsFactoryDB;
GO

-- ================================================================================
-- STEP 1: CREATE NEW TABLES
-- ================================================================================

-- 1. OrderApproval Table - Links Orders to Owner Approval
-- ================================================================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'OrderApproval')
BEGIN
    CREATE TABLE OrderApproval (
        ApprovalID INT PRIMARY KEY IDENTITY(1,1),
        
        -- Order Reference (can be SalesOrder OR Deal)
        OrderType NVARCHAR(20) NOT NULL,           -- 'SalesOrder' or 'Deal'
        OrderID INT NOT NULL,                      -- FK to SalesOrderID or DealID
        
        -- Approval Status
        Status NVARCHAR(30) DEFAULT 'Pending',     -- Pending, Approved, Rejected
        ApprovedByOwnerID INT NULL,                -- FK to Employee (Owner)
        ApprovalDate DATETIME NULL,
        RejectionReason NVARCHAR(500) NULL,        -- "Insufficient Cotton: Need 500m, Have 200m"
        
        -- Production Order Reference (created after approval)
        ProductionOrderID INT NULL,                -- FK to ProductionOrder (created on approval)
        
        -- Request Information
        RequestedByEmployeeID INT NOT NULL,        -- FK to Employee (Salesperson)
        RequestDate DATETIME DEFAULT GETDATE(),
        
        -- System Fields
        CreatedDate DATETIME DEFAULT GETDATE(),
        UpdatedDate DATETIME NULL,
        
        CONSTRAINT FK_OrderApproval_Owner FOREIGN KEY (ApprovedByOwnerID) 
            REFERENCES Employee(EmployeeID),
        CONSTRAINT FK_OrderApproval_Requester FOREIGN KEY (RequestedByEmployeeID) 
            REFERENCES Employee(EmployeeID),
        CONSTRAINT FK_OrderApproval_ProductionOrder FOREIGN KEY (ProductionOrderID) 
            REFERENCES ProductionOrder(ProductionOrderID)
    );
    PRINT 'Table OrderApproval created successfully.';
END
GO

-- 2. TailorAssignment Table - Links ProductionOrders to Multiple Tailors
-- ================================================================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'TailorAssignment')
BEGIN
    CREATE TABLE TailorAssignment (
        TailorAssignmentID INT PRIMARY KEY IDENTITY(1,1),
        
        ProductionOrderID INT NOT NULL,            -- FK to ProductionOrder
        TailorID INT NOT NULL,                     -- FK to Employee (Tailor role)
        
        -- Assignment Details
        AssignedByOwnerID INT NULL,                -- FK to Employee (Owner who assigned)
        AssignedDate DATETIME DEFAULT GETDATE(),
        
        -- Completion Status
        CompletionStatus NVARCHAR(30) DEFAULT 'Incomplete',  -- Incomplete, InProgress, Complete
        StartedDate DATETIME NULL,
        CompletedDate DATETIME NULL,
        
        -- Notes
        AssignmentNotes NVARCHAR(500) NULL,
        CompletionNotes NVARCHAR(500) NULL,
        
        CONSTRAINT FK_TailorAssignment_ProductionOrder FOREIGN KEY (ProductionOrderID) 
            REFERENCES ProductionOrder(ProductionOrderID) ON DELETE CASCADE,
        CONSTRAINT FK_TailorAssignment_Tailor FOREIGN KEY (TailorID) 
            REFERENCES Employee(EmployeeID),
        CONSTRAINT FK_TailorAssignment_Owner FOREIGN KEY (AssignedByOwnerID) 
            REFERENCES Employee(EmployeeID)
    );
    PRINT 'Table TailorAssignment created successfully.';
END
GO

-- Create Indexes for Performance
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_OrderApproval_Status')
    CREATE NONCLUSTERED INDEX IX_OrderApproval_Status ON OrderApproval(Status);
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_OrderApproval_OrderType_OrderID')
    CREATE NONCLUSTERED INDEX IX_OrderApproval_OrderType_OrderID ON OrderApproval(OrderType, OrderID);
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_TailorAssignment_ProductionOrderID')
    CREATE NONCLUSTERED INDEX IX_TailorAssignment_ProductionOrderID ON TailorAssignment(ProductionOrderID);
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_TailorAssignment_TailorID')
    CREATE NONCLUSTERED INDEX IX_TailorAssignment_TailorID ON TailorAssignment(TailorID);
GO

PRINT '========================================';
PRINT 'Tables created successfully!';
PRINT '- OrderApproval';
PRINT '- TailorAssignment';
PRINT '========================================';
GO

-- ================================================================================
-- STEP 2: CREATE STORED PROCEDURES
-- ================================================================================

-- ================================================================================
-- APPROVAL PROCEDURES (Owner Dashboard)
-- ================================================================================

-- 1. Get All Pending Approvals
-- ================================================================================
IF OBJECT_ID('sp_GetPendingApprovals', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetPendingApprovals;
GO

CREATE PROCEDURE sp_GetPendingApprovals
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        oa.ApprovalID,
        oa.OrderType,
        oa.OrderID,
        oa.Status,
        oa.RequestDate,
        oa.RequestedByEmployeeID,
        
        -- Salesperson Details
        CONCAT(e.FirstName, ' ', e.LastName) AS SalespersonName,
        e.Phone AS SalespersonPhone,
        
        -- Order Details (SalesOrder)
        so.TotalAmount AS SalesOrderAmount,
        so.PriorityLevel AS SalesOrderPriority,
        r.CompanyName AS RetailerName,
        
        -- Order Details (Deal)
        d.EstimatedValue AS DealAmount,
        d.Priority AS DealPriority,
        d.ClientName AS DealClientName
        
    FROM OrderApproval oa
    LEFT JOIN Employee e ON oa.RequestedByEmployeeID = e.EmployeeID
    LEFT JOIN SalesOrder so ON oa.OrderType = 'SalesOrder' AND oa.OrderID = so.SalesOrderID
    LEFT JOIN Retailer r ON so.RetailerID = r.RetailerID
    LEFT JOIN Deal d ON oa.OrderType = 'Deal' AND oa.OrderID = d.DealID
    
    WHERE oa.Status = 'Pending'
    ORDER BY oa.RequestDate DESC;
END
GO

-- 2. Check Raw Materials for Order
-- ================================================================================
IF OBJECT_ID('sp_CheckMaterialsForOrder', 'P') IS NOT NULL
    DROP PROCEDURE sp_CheckMaterialsForOrder;
GO

CREATE PROCEDURE sp_CheckMaterialsForOrder
    @OrderType NVARCHAR(20),
    @OrderID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Temporary table to store material requirements
    CREATE TABLE #MaterialCheck (
        ProductID INT,
        ProductName NVARCHAR(100),
        QuantityOrdered INT,
        RawMaterialID INT,
        MaterialName NVARCHAR(100),
        RequiredQuantity DECIMAL(18,2),
        AvailableQuantity DECIMAL(18,2),
        Unit NVARCHAR(20),
        Status NVARCHAR(20)
    );
    
    -- Get products from SalesOrder or Deal
    IF @OrderType = 'SalesOrder'
    BEGIN
        INSERT INTO #MaterialCheck (ProductID, ProductName, QuantityOrdered)
        SELECT 
            soi.ProductID,
            p.ProductName,
            soi.Quantity
        FROM SalesOrderItem soi
        JOIN Product p ON soi.ProductID = p.ProductID
        WHERE soi.SalesOrderID = @OrderID;
    END
    ELSE IF @OrderType = 'Deal'
    BEGIN
        INSERT INTO #MaterialCheck (ProductID, ProductName, QuantityOrdered)
        SELECT 
            di.ProductID,
            p.ProductName,
            di.Quantity
        FROM DealItem di
        JOIN Product p ON di.ProductID = p.ProductID
        WHERE di.DealID = @OrderID;
    END
    
    -- Calculate material requirements from ProductMaterialRequirement
    UPDATE mc
    SET 
        mc.RawMaterialID = pmr.RawMaterialID,
        mc.MaterialName = rm.MaterialName,
        mc.RequiredQuantity = pmr.QuantityRequired * mc.QuantityOrdered,
        mc.AvailableQuantity = rm.Quantity,
        mc.Unit = rm.Unit,
        mc.Status = CASE 
            WHEN rm.Quantity >= (pmr.QuantityRequired * mc.QuantityOrdered) THEN 'Sufficient'
            ELSE 'Insufficient'
        END
    FROM #MaterialCheck mc
    JOIN ProductMaterialRequirement pmr ON mc.ProductID = pmr.ProductID
    JOIN RawMaterial rm ON pmr.RawMaterialID = rm.RawMaterialID;
    
    -- Return results
    SELECT * FROM #MaterialCheck;
    
    -- Return overall status
    IF EXISTS (SELECT 1 FROM #MaterialCheck WHERE Status = 'Insufficient')
    BEGIN
        SELECT 'Insufficient' AS OverallStatus, 
               'Some materials are insufficient for production' AS Message;
    END
    ELSE
    BEGIN
        SELECT 'Sufficient' AS OverallStatus, 
               'All materials are available for production' AS Message;
    END
    
    DROP TABLE #MaterialCheck;
END
GO

-- 3. Approve Order and Create Production
-- ================================================================================
IF OBJECT_ID('sp_ApproveOrderAndCreateProduction', 'P') IS NOT NULL
    DROP PROCEDURE sp_ApproveOrderAndCreateProduction;
GO

CREATE PROCEDURE sp_ApproveOrderAndCreateProduction
    @ApprovalID INT,
    @OwnerID INT,
    @TailorIDs NVARCHAR(MAX)  -- Comma-separated IDs: "5,12,18"
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    
    BEGIN TRY
        DECLARE @OrderType NVARCHAR(20);
        DECLARE @OrderID INT;
        DECLARE @ProductID INT;
        DECLARE @Quantity INT;
        DECLARE @ProductionOrderID INT;
        DECLARE @MaterialCheckStatus NVARCHAR(20);
        
        -- Get order details
        SELECT @OrderType = OrderType, @OrderID = OrderID
        FROM OrderApproval
        WHERE ApprovalID = @ApprovalID AND Status = 'Pending';
        
        IF @OrderType IS NULL
        BEGIN
            RAISERROR('Approval request not found or already processed', 16, 1);
            RETURN;
        END
        
        -- Check materials availability
        CREATE TABLE #TempMaterialCheck (
            ProductID INT,
            QuantityOrdered INT,
            RawMaterialID INT,
            RequiredQuantity DECIMAL(18,2),
            AvailableQuantity DECIMAL(18,2),
            Status NVARCHAR(20)
        );
        
        -- Get products and check materials
        IF @OrderType = 'SalesOrder'
        BEGIN
            INSERT INTO #TempMaterialCheck (ProductID, QuantityOrdered)
            SELECT ProductID, Quantity
            FROM SalesOrderItem
            WHERE SalesOrderID = @OrderID;
        END
        ELSE
        BEGIN
            INSERT INTO #TempMaterialCheck (ProductID, QuantityOrdered)
            SELECT ProductID, Quantity
            FROM DealItem
            WHERE DealID = @OrderID;
        END
        
        -- Calculate required materials
        UPDATE tmc
        SET 
            tmc.RawMaterialID = pmr.RawMaterialID,
            tmc.RequiredQuantity = pmr.QuantityRequired * tmc.QuantityOrdered,
            tmc.AvailableQuantity = rm.Quantity,
            tmc.Status = CASE 
                WHEN rm.Quantity >= (pmr.QuantityRequired * tmc.QuantityOrdered) THEN 'Sufficient'
                ELSE 'Insufficient'
            END
        FROM #TempMaterialCheck tmc
        JOIN ProductMaterialRequirement pmr ON tmc.ProductID = pmr.ProductID
        JOIN RawMaterial rm ON pmr.RawMaterialID = rm.RawMaterialID;
        
        -- Check if any material is insufficient
        IF EXISTS (SELECT 1 FROM #TempMaterialCheck WHERE Status = 'Insufficient')
        BEGIN
            DECLARE @InsufficientMaterials NVARCHAR(MAX);
            SELECT @InsufficientMaterials = STRING_AGG(
                rm.MaterialName + ' (Need: ' + CAST(tmc.RequiredQuantity AS NVARCHAR) + 
                ', Have: ' + CAST(tmc.AvailableQuantity AS NVARCHAR) + ' ' + rm.Unit + ')',
                '; '
            )
            FROM #TempMaterialCheck tmc
            JOIN RawMaterial rm ON tmc.RawMaterialID = rm.RawMaterialID
            WHERE tmc.Status = 'Insufficient';
            
            DROP TABLE #TempMaterialCheck;
            RAISERROR('Insufficient raw materials: %s', 16, 1, @InsufficientMaterials);
            RETURN;
        END
        
        -- Create ProductionOrder for each product in the order
        DECLARE product_cursor CURSOR FOR
        SELECT ProductID, QuantityOrdered FROM #TempMaterialCheck;
        
        OPEN product_cursor;
        FETCH NEXT FROM product_cursor INTO @ProductID, @Quantity;
        
        WHILE @@FETCH_STATUS = 0
        BEGIN
            -- Create Production Order (without CreatedByEmployeeID to avoid FK constraint issues)
            INSERT INTO ProductionOrder (
                ProductID, 
                QuantityOrdered, 
                Status, 
                Priority,
                StartDate,
                ExpectedEndDate
            )
            VALUES (
                @ProductID, 
                @Quantity, 
                'Pending',
                'Normal',
                GETDATE(),
                DATEADD(DAY, 14, GETDATE())
            );
            
            SET @ProductionOrderID = SCOPE_IDENTITY();
            
            -- Deduct raw materials
            UPDATE rm
            SET Quantity = rm.Quantity - tmc.RequiredQuantity,
                LastRestockDate = GETDATE()
            FROM RawMaterial rm
            JOIN #TempMaterialCheck tmc ON rm.RawMaterialID = tmc.RawMaterialID
            WHERE tmc.ProductID = @ProductID;
            
            -- Create ProductionOrderItem entries
            INSERT INTO ProductionOrderItem (ProductionOrderID, RawMaterialID, QuantityRequired)
            SELECT 
                @ProductionOrderID,
                pmr.RawMaterialID,
                pmr.QuantityRequired * @Quantity
            FROM ProductMaterialRequirement pmr
            WHERE pmr.ProductID = @ProductID;
            
            -- Assign tailors
            IF @TailorIDs IS NOT NULL AND LEN(@TailorIDs) > 0
            BEGIN
                INSERT INTO TailorAssignment (
                    ProductionOrderID,
                    TailorID,
                    CompletionStatus
                )
                SELECT 
                    @ProductionOrderID,
                    CAST(value AS INT),
                    'Incomplete'
                FROM STRING_SPLIT(@TailorIDs, ',');
            END
            
            FETCH NEXT FROM product_cursor INTO @ProductID, @Quantity;
        END
        
        CLOSE product_cursor;
        DEALLOCATE product_cursor;
        
        -- Update OrderApproval (removed ApprovedByOwnerID to avoid FK constraint issues)
        UPDATE OrderApproval
        SET 
            Status = 'Approved',
            ApprovalDate = GETDATE(),
            ProductionOrderID = @ProductionOrderID,
            UpdatedDate = GETDATE()
        WHERE ApprovalID = @ApprovalID;
        
        -- Update original order status (NO DELIVERY CREATED HERE - only after tailors complete)
        IF @OrderType = 'SalesOrder'
        BEGIN
            UPDATE SalesOrder
            SET Status = 'InProduction',
                UpdatedDate = GETDATE()
            WHERE SalesOrderID = @OrderID;
        END
        ELSE
        BEGIN
            UPDATE Deal
            SET Status = 'InProduction',  -- Changed from 'Active' to match workflow
                UpdatedDate = GETDATE()
            WHERE DealID = @OrderID;
        END
        
        DROP TABLE #TempMaterialCheck;
        
        COMMIT TRANSACTION;
        
        SELECT 'Success' AS Result, 
               'Order approved and production started successfully' AS Message,
               @ProductionOrderID AS ProductionOrderID;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

-- 4. Reject Order
-- ================================================================================
IF OBJECT_ID('sp_RejectOrder', 'P') IS NOT NULL
    DROP PROCEDURE sp_RejectOrder;
GO

CREATE PROCEDURE sp_RejectOrder
    @ApprovalID INT,
    @OwnerID INT,
    @RejectionReason NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Update OrderApproval (removed ApprovedByOwnerID to avoid FK constraint issues)
    UPDATE OrderApproval
    SET 
        Status = 'Rejected',
        ApprovalDate = GETDATE(),
        RejectionReason = @RejectionReason,
        UpdatedDate = GETDATE()
    WHERE ApprovalID = @ApprovalID AND Status = 'Pending';
    
    IF @@ROWCOUNT > 0
    BEGIN
        SELECT 'Success' AS Result, 'Order rejected successfully' AS Message;
    END
    ELSE
    BEGIN
        RAISERROR('Approval request not found or already processed', 16, 1);
    END
END
GO

-- 5. Get Available Tailors
-- ================================================================================
IF OBJECT_ID('sp_GetAvailableTailors', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetAvailableTailors;
GO

CREATE PROCEDURE sp_GetAvailableTailors
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        e.EmployeeID,
        CONCAT(e.FirstName, ' ', e.LastName) AS TailorName,
        e.Specialization,
        e.PieceRate,
        e.TotalPiecesCompleted,
        e.Phone,
        e.Email,
        
        -- Count active assignments
        (SELECT COUNT(*) 
         FROM TailorAssignment ta 
         WHERE ta.TailorID = e.EmployeeID 
         AND ta.CompletionStatus IN ('Incomplete', 'InProgress')) AS ActiveAssignments
         
    FROM Employee e
    JOIN EmployeeRole er ON e.RoleID = er.RoleID
    WHERE er.RoleName = 'Tailor' 
    AND e.IsActive = 1
    ORDER BY ActiveAssignments ASC, e.TotalPiecesCompleted DESC;
END
GO

-- 6. Get Approval History
-- ================================================================================
IF OBJECT_ID('sp_GetApprovalHistory', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetApprovalHistory;
GO

CREATE PROCEDURE sp_GetApprovalHistory
    @Status NVARCHAR(30) = NULL  -- NULL = All, 'Approved', 'Rejected', 'Pending'
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        oa.ApprovalID,
        oa.OrderType,
        oa.OrderID,
        oa.Status,
        oa.RequestDate,
        oa.ApprovalDate,
        oa.RejectionReason,
        
        -- Requester (Salesperson)
        CONCAT(req.FirstName, ' ', req.LastName) AS RequestedBy,
        
        -- Approver (Owner)
        CONCAT(own.FirstName, ' ', own.LastName) AS ApprovedBy,
        
        -- Order Details
        CASE 
            WHEN oa.OrderType = 'SalesOrder' THEN CAST(so.TotalAmount AS NVARCHAR)
            WHEN oa.OrderType = 'Deal' THEN CAST(d.EstimatedValue AS NVARCHAR)
        END AS OrderValue,
        
        CASE 
            WHEN oa.OrderType = 'SalesOrder' THEN r.CompanyName
            WHEN oa.OrderType = 'Deal' THEN d.ClientName
        END AS CustomerName
        
    FROM OrderApproval oa
    LEFT JOIN Employee req ON oa.RequestedByEmployeeID = req.EmployeeID
    LEFT JOIN Employee own ON oa.ApprovedByOwnerID = own.EmployeeID
    LEFT JOIN SalesOrder so ON oa.OrderType = 'SalesOrder' AND oa.OrderID = so.SalesOrderID
    LEFT JOIN Retailer r ON so.RetailerID = r.RetailerID
    LEFT JOIN Deal d ON oa.OrderType = 'Deal' AND oa.OrderID = d.DealID
    
    WHERE (@Status IS NULL OR oa.Status = @Status)
    ORDER BY oa.RequestDate DESC;
END
GO

-- ================================================================================
-- TAILOR PROCEDURES (Tailor Dashboard)
-- ================================================================================

-- 7. Get Tailor's Assignments
-- ================================================================================
IF OBJECT_ID('sp_GetTailorAssignments', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetTailorAssignments;
GO

CREATE PROCEDURE sp_GetTailorAssignments
    @TailorID INT,
    @Status NVARCHAR(30) = NULL  -- NULL = All, 'Incomplete', 'InProgress', 'Complete'
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        ta.TailorAssignmentID,
        ta.ProductionOrderID,
        ta.CompletionStatus,
        ta.AssignedDate,
        ta.StartedDate,
        ta.CompletedDate,
        ta.AssignmentNotes,
        
        -- Production Order Details
        po.QuantityOrdered,
        po.Status AS ProductionStatus,
        po.Priority,
        po.ExpectedEndDate,
        
        -- Product Details
        p.ProductID,
        p.ProductName,
        p.Category,
        p.Material,
        
        -- Count total tailors on this order
        (SELECT COUNT(*) FROM TailorAssignment WHERE ProductionOrderID = ta.ProductionOrderID) AS TotalTailors,
        
        -- Count completed tailors
        (SELECT COUNT(*) FROM TailorAssignment 
         WHERE ProductionOrderID = ta.ProductionOrderID 
         AND CompletionStatus = 'Complete') AS CompletedTailors
         
    FROM TailorAssignment ta
    JOIN ProductionOrder po ON ta.ProductionOrderID = po.ProductionOrderID
    JOIN Product p ON po.ProductID = p.ProductID
    
    WHERE ta.TailorID = @TailorID
    AND (@Status IS NULL OR ta.CompletionStatus = @Status)
    ORDER BY 
        CASE ta.CompletionStatus
            WHEN 'Incomplete' THEN 1
            WHEN 'InProgress' THEN 2
            WHEN 'Complete' THEN 3
        END,
        ta.AssignedDate DESC;
END
GO

-- 8. Update Tailor Completion Status
-- ================================================================================
IF OBJECT_ID('sp_UpdateTailorCompletionStatus', 'P') IS NOT NULL
    DROP PROCEDURE sp_UpdateTailorCompletionStatus;
GO

CREATE PROCEDURE sp_UpdateTailorCompletionStatus
    @TailorAssignmentID INT,
    @TailorID INT,
    @NewStatus NVARCHAR(30),  -- 'InProgress' or 'Complete'
    @CompletionNotes NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    
    BEGIN TRY
        DECLARE @ProductionOrderID INT;
        DECLARE @AllTailorsCompleted BIT = 0;
        DECLARE @SalesOrderID INT;
        DECLARE @DealID INT;
        DECLARE @OrderType NVARCHAR(20);
        DECLARE @DeliveryID INT;
        
        -- Get production order ID first
        SELECT @ProductionOrderID = ProductionOrderID
        FROM TailorAssignment
        WHERE TailorAssignmentID = @TailorAssignmentID;
        
        IF @ProductionOrderID IS NULL
        BEGIN
            RAISERROR('Assignment not found', 16, 1);
            RETURN;
        END
        
        -- Update ALL tailor assignments for this production order (they work together)
        IF @NewStatus = 'InProgress'
        BEGIN
            -- When one tailor starts, mark ALL as InProgress
            UPDATE TailorAssignment
            SET 
                CompletionStatus = 'InProgress',
                StartedDate = CASE WHEN StartedDate IS NULL THEN GETDATE() ELSE StartedDate END
            WHERE ProductionOrderID = @ProductionOrderID
            AND CompletionStatus = 'Incomplete';
        END
        ELSE IF @NewStatus = 'Complete'
        BEGIN
            -- When one tailor completes, mark ALL as Complete
            UPDATE TailorAssignment
            SET 
                CompletionStatus = 'Complete',
                CompletedDate = GETDATE(),
                CompletionNotes = @CompletionNotes
            WHERE ProductionOrderID = @ProductionOrderID;
            
            SET @AllTailorsCompleted = 1;
        END
        
        -- If status changed to Complete, update production and create delivery
        IF @AllTailorsCompleted = 1
        BEGIN
            -- Update production order status
            UPDATE ProductionOrder
            SET 
                Status = 'Completed',
                QuantityCompleted = QuantityOrdered,
                ActualEndDate = GETDATE(),
                UpdatedDate = GETDATE()
            WHERE ProductionOrderID = @ProductionOrderID;
            
            -- Update ALL assigned tailors' total pieces
            UPDATE e
            SET TotalPiecesCompleted = TotalPiecesCompleted + 
                (SELECT QuantityOrdered FROM ProductionOrder WHERE ProductionOrderID = @ProductionOrderID)
            FROM Employee e
            JOIN TailorAssignment ta ON e.EmployeeID = ta.TailorID
            WHERE ta.ProductionOrderID = @ProductionOrderID;
            
            -- AUTOMATICALLY CREATE DELIVERY when production is completed
            -- Get order details from OrderApproval
            SELECT 
                @OrderType = oa.OrderType,
                @SalesOrderID = CASE WHEN oa.OrderType = 'SalesOrder' THEN oa.OrderID ELSE NULL END,
                @DealID = CASE WHEN oa.OrderType = 'Deal' THEN oa.OrderID ELSE NULL END
            FROM OrderApproval oa
            WHERE oa.ProductionOrderID = @ProductionOrderID
            AND oa.Status = 'Approved';
            
            -- Create delivery for BOTH SalesOrders AND Deals
            IF @SalesOrderID IS NOT NULL
            BEGIN
                -- Check if delivery doesn't already exist for SalesOrder
                IF NOT EXISTS (SELECT 1 FROM Delivery WHERE SalesOrderID = @SalesOrderID AND DealID IS NULL)
                BEGIN
                    -- Create delivery record for SalesOrder
                    INSERT INTO Delivery (
                        SalesOrderID,
                        DealID,
                        DeliveryAddress,
                        City,
                        Province,
                        Status,
                        ReceiverName,
                        ReceiverPhone,
                        CreatedDate
                    )
                    SELECT 
                        so.SalesOrderID,
                        NULL,
                        so.ShippingAddress,
                        ret.City,
                        ret.Province,
                        'Pending',
                        ret.ContactPerson,
                        ret.Phone,
                        GETDATE()
                    FROM SalesOrder so
                    JOIN Retailer ret ON so.RetailerID = ret.RetailerID
                    WHERE so.SalesOrderID = @SalesOrderID;
                    
                    SET @DeliveryID = SCOPE_IDENTITY();
                    
                    -- Update SalesOrder status
                    UPDATE SalesOrder
                    SET Status = 'ReadyForDelivery',
                        UpdatedDate = GETDATE()
                    WHERE SalesOrderID = @SalesOrderID;
                END
            END
            ELSE IF @DealID IS NOT NULL
            BEGIN
                -- Check if delivery doesn't already exist for Deal
                IF NOT EXISTS (SELECT 1 FROM Delivery WHERE DealID = @DealID AND SalesOrderID IS NULL)
                BEGIN
                    -- Create delivery record for Deal
                    INSERT INTO Delivery (
                        SalesOrderID,
                        DealID,
                        DeliveryAddress,
                        City,
                        Province,
                        Status,
                        ReceiverName,
                        ReceiverPhone,
                        CreatedDate
                    )
                    SELECT 
                        NULL,
                        d.DealID,
                        ISNULL(d.DeliveryAddress, 'Not specified'),
                        ISNULL(d.City, 'Not specified'),
                        ISNULL(d.Province, 'Not specified'),
                        'Pending',
                        d.ContactPerson,
                        d.Phone,
                        GETDATE()
                    FROM Deal d
                    WHERE d.DealID = @DealID;
                    
                    SET @DeliveryID = SCOPE_IDENTITY();
                    
                    -- Update Deal status
                    UPDATE Deal
                    SET Status = 'ReadyForDelivery',
                        UpdatedDate = GETDATE()
                    WHERE DealID = @DealID;
                END
            END
        END
        
        COMMIT TRANSACTION;
        
        SELECT 'Success' AS Result, 
               'Status updated successfully' AS Message,
               @AllTailorsCompleted AS AllTailorsCompleted,
               @DeliveryID AS DeliveryID;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

-- ================================================================================
-- DELIVERY PROCEDURES (Delivery Dashboard)
-- ================================================================================

-- 9. Get Completed Productions for Delivery
-- ================================================================================
IF OBJECT_ID('sp_GetCompletedProductionsForDelivery', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetCompletedProductionsForDelivery;
GO

CREATE PROCEDURE sp_GetCompletedProductionsForDelivery
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        po.ProductionOrderID,
        po.ProductID,
        p.ProductName,
        po.QuantityOrdered,
        po.ActualEndDate AS CompletedDate,
        
        -- Get original order details
        oa.OrderType,
        oa.OrderID,
        
        -- SalesOrder details
        so.SalesOrderID,
        so.ShippingAddress,
        r.CompanyName AS CustomerName,
        r.Phone AS CustomerPhone,
        r.City,
        r.Province,
        
        -- Check if delivery already exists
        CASE WHEN d.DeliveryID IS NOT NULL THEN 1 ELSE 0 END AS HasDelivery,
        d.Status AS DeliveryStatus
        
    FROM ProductionOrder po
    JOIN Product p ON po.ProductID = p.ProductID
    LEFT JOIN OrderApproval oa ON po.ProductionOrderID = oa.ProductionOrderID
    LEFT JOIN SalesOrder so ON oa.OrderType = 'SalesOrder' AND oa.OrderID = so.SalesOrderID
    LEFT JOIN Retailer r ON so.RetailerID = r.RetailerID
    LEFT JOIN Delivery d ON so.SalesOrderID = d.SalesOrderID
    
    WHERE po.Status = 'Completed'
    AND oa.Status = 'Approved'
    ORDER BY po.ActualEndDate DESC;
END
GO

-- 10. Get Delivery Assignments
-- ================================================================================
IF OBJECT_ID('sp_GetDeliveryAssignments', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetDeliveryAssignments;
GO

CREATE PROCEDURE sp_GetDeliveryAssignments
    @DeliveryPersonID INT = NULL,
    @Status NVARCHAR(50) = NULL  -- NULL = All, 'Pending', 'InTransit', 'Delivered'
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        d.DeliveryID,
        d.SalesOrderID,
        d.DealID,
        d.Status,
        d.DeliveryDate,
        d.DeliveryAddress,
        d.City,
        d.Province,
        d.TrackingNumber,
        d.ReceiverName,
        d.ReceiverPhone,
        d.Notes,
        d.CreatedDate,
        
        -- Order details (SalesOrder or Deal)
        CASE 
            WHEN d.SalesOrderID IS NOT NULL THEN 'SalesOrder'
            WHEN d.DealID IS NOT NULL THEN 'Deal'
        END AS OrderType,
        
        -- SalesOrder details
        so.OrderDate AS SalesOrderDate,
        so.TotalAmount AS SalesOrderAmount,
        
        -- Deal details
        de.CreatedDate AS DealDate,
        de.EstimatedValue AS DealAmount,
        
        -- Customer details (Retailer or Deal Client)
        COALESCE(r.CompanyName, de.ClientName) AS CustomerName,
        COALESCE(r.Phone, de.ClientPhone) AS CustomerPhone,
        COALESCE(r.ContactPerson, de.ClientContactPerson) AS ContactPerson,
        
        -- Delivery person
        CONCAT(e.FirstName, ' ', e.LastName) AS DeliveryPersonName
        
    FROM Delivery d
    LEFT JOIN SalesOrder so ON d.SalesOrderID = so.SalesOrderID
    LEFT JOIN Retailer r ON so.RetailerID = r.RetailerID
    LEFT JOIN Deal de ON d.DealID = de.DealID
    LEFT JOIN Employee e ON d.DeliveredBy = e.EmployeeID
    
    WHERE (@DeliveryPersonID IS NULL OR d.DeliveredBy = @DeliveryPersonID)
    AND (@Status IS NULL OR d.Status = @Status)
    ORDER BY 
        CASE d.Status
            WHEN 'Pending' THEN 1
            WHEN 'InTransit' THEN 2
            WHEN 'Delivered' THEN 3
        END,
        d.CreatedDate DESC;
END
GO

-- 11. Update Delivery Status
-- ================================================================================
IF OBJECT_ID('sp_UpdateDeliveryStatus', 'P') IS NOT NULL
    DROP PROCEDURE sp_UpdateDeliveryStatus;
GO

CREATE PROCEDURE sp_UpdateDeliveryStatus
    @DeliveryID INT,
    @DeliveryPersonID INT,
    @NewStatus NVARCHAR(50),  -- 'InTransit' or 'Delivered'
    @Notes NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE Delivery
    SET 
        Status = @NewStatus,
        DeliveredBy = @DeliveryPersonID,
        DeliveryDate = CASE WHEN @NewStatus = 'Delivered' THEN GETDATE() ELSE DeliveryDate END,
        Notes = ISNULL(@Notes, Notes),
        UpdatedDate = GETDATE()
    WHERE DeliveryID = @DeliveryID;
    
    IF @@ROWCOUNT > 0
    BEGIN
        -- Update SalesOrder or Deal status
        IF @NewStatus = 'Delivered'
        BEGIN
            -- Update SalesOrder if exists
            UPDATE so
            SET Status = 'Delivered',
                UpdatedDate = GETDATE()
            FROM SalesOrder so
            JOIN Delivery d ON so.SalesOrderID = d.SalesOrderID
            WHERE d.DeliveryID = @DeliveryID AND d.SalesOrderID IS NOT NULL;
            
            -- Update Deal if exists
            UPDATE de
            SET Status = 'Delivered',
                UpdatedDate = GETDATE()
            FROM Deal de
            JOIN Delivery d ON de.DealID = d.DealID
            WHERE d.DeliveryID = @DeliveryID AND d.DealID IS NOT NULL;
        END
        
        SELECT 'Success' AS Result, 
               'Delivery status updated successfully' AS Message;
    END
    ELSE
    BEGIN
        RAISERROR('Delivery not found', 16, 1);
    END
END
GO

-- 12. Create Delivery from Production Order
-- ================================================================================
IF OBJECT_ID('sp_CreateDeliveryFromProduction', 'P') IS NOT NULL
    DROP PROCEDURE sp_CreateDeliveryFromProduction;
GO

CREATE PROCEDURE sp_CreateDeliveryFromProduction
    @ProductionOrderID INT,
    @DeliveryPersonID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    
    BEGIN TRY
        DECLARE @SalesOrderID INT;
        DECLARE @DeliveryID INT;
        
        -- Get SalesOrder from ProductionOrder
        SELECT @SalesOrderID = oa.OrderID
        FROM OrderApproval oa
        WHERE oa.ProductionOrderID = @ProductionOrderID
        AND oa.OrderType = 'SalesOrder';
        
        IF @SalesOrderID IS NULL
        BEGIN
            RAISERROR('Sales order not found for this production order', 16, 1);
            RETURN;
        END
        
        -- Check if delivery already exists
        IF EXISTS (SELECT 1 FROM Delivery WHERE SalesOrderID = @SalesOrderID)
        BEGIN
            RAISERROR('Delivery already exists for this order', 16, 1);
            RETURN;
        END
        
        -- Create delivery record
        INSERT INTO Delivery (
            SalesOrderID,
            DeliveredBy,
            DeliveryAddress,
            City,
            Province,
            Status,
            ReceiverName,
            ReceiverPhone
        )
        SELECT 
            so.SalesOrderID,
            @DeliveryPersonID,
            so.ShippingAddress,
            r.City,
            r.Province,
            'Pending',
            r.ContactPerson,
            r.Phone
        FROM SalesOrder so
        JOIN Retailer r ON so.RetailerID = r.RetailerID
        WHERE so.SalesOrderID = @SalesOrderID;
        
        SET @DeliveryID = SCOPE_IDENTITY();
        
        COMMIT TRANSACTION;
        
        SELECT 'Success' AS Result, 
               'Delivery created successfully' AS Message,
               @DeliveryID AS DeliveryID;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

-- ================================================================================
-- SCRIPT COMPLETION
-- ================================================================================
PRINT '========================================';
PRINT 'ORDER APPROVAL SYSTEM SETUP COMPLETE!';
PRINT '';
PRINT 'Tables Created (2):';
PRINT '  1. OrderApproval';
PRINT '  2. TailorAssignment';
PRINT '';
PRINT 'Stored Procedures Created (12):';
PRINT 'APPROVAL PROCEDURES:';
PRINT '  1. sp_GetPendingApprovals';
PRINT '  2. sp_CheckMaterialsForOrder';
PRINT '  3. sp_ApproveOrderAndCreateProduction';
PRINT '  4. sp_RejectOrder';
PRINT '  5. sp_GetAvailableTailors';
PRINT '  6. sp_GetApprovalHistory';
PRINT '';
PRINT 'TAILOR PROCEDURES:';
PRINT '  7. sp_GetTailorAssignments';
PRINT '  8. sp_UpdateTailorCompletionStatus';
PRINT '';
PRINT 'DELIVERY PROCEDURES:';
PRINT '  9. sp_GetCompletedProductionsForDelivery';
PRINT '  10. sp_GetDeliveryAssignments';
PRINT '  11. sp_UpdateDeliveryStatus';
PRINT '  12. sp_CreateDeliveryFromProduction';
PRINT '';
PRINT 'Ready for Owner Dashboard integration!';
PRINT '========================================';
GO
