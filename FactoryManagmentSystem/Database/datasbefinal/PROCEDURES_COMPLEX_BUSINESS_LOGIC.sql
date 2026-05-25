-- =============================================
-- COMPLEX BUSINESS LOGIC PROCEDURES
-- Advanced operations with multiple table updates
-- Generated: December 17, 2025
-- =============================================

USE GarmentsFactoryDB;
GO

-- ========================================
-- PROCEDURE: sp_ApproveOrderAndCreateProduction
-- Purpose: Approve order and automatically create production orders
-- Complexity: HIGH
-- ========================================
CREATE OR ALTER PROCEDURE sp_ApproveOrderAndCreateProduction
    @ApprovalID INT,
    @ApprovedBy INT,
    @Comments NVARCHAR(1000) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    
    BEGIN TRY
        DECLARE @OrderType NVARCHAR(50);
        DECLARE @OrderID INT;
        DECLARE @SalesOrderID INT = NULL;
        DECLARE @DealID INT = NULL;
        
        -- Get order details
        SELECT @OrderType = OrderType, @OrderID = OrderID, 
               @SalesOrderID = SalesOrderID, @DealID = DealID
        FROM OrderApproval WHERE ApprovalID = @ApprovalID;
        
        -- Update approval status
        UPDATE OrderApproval 
        SET Status = 'Approved',
            ApprovalStatus = 'Approved',
            ApprovedBy = @ApprovedBy,
            ApprovalDate = GETDATE(),
            Comments = @Comments
        WHERE ApprovalID = @ApprovalID;
        
        -- Update order status
        IF @OrderType = 'SalesOrder' AND @SalesOrderID IS NOT NULL
        BEGIN
            UPDATE SalesOrder SET Status = 'Approved', UpdatedDate = GETDATE()
            WHERE SalesOrderID = @SalesOrderID;
            
            -- Create production orders for each item
            INSERT INTO ProductionOrder (ProductID, QuantityOrdered, Status, CreatedByEmployeeID, CreatedDate, StartDate)
            SELECT soi.ProductID, soi.Quantity, 'Pending', @ApprovedBy, GETDATE(), GETDATE()
            FROM SalesOrderItem soi
            WHERE soi.SalesOrderID = @SalesOrderID;
        END
        ELSE IF @OrderType = 'Deal' AND @DealID IS NOT NULL
        BEGIN
            UPDATE Deal SET Status = 'Approved', UpdatedDate = GETDATE()
            WHERE DealID = @DealID;
            
            -- Create production orders for deal items
            INSERT INTO ProductionOrder (ProductID, QuantityOrdered, Status, CreatedByEmployeeID, CreatedDate, StartDate)
            SELECT di.ProductID, di.Quantity, 'Pending', @ApprovedBy, GETDATE(), GETDATE()
            FROM DealItem di
            WHERE di.DealID = @DealID;
        END
        
        COMMIT TRANSACTION;
        SELECT 'SUCCESS' AS Result, 'Order approved and production orders created' AS Message;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SELECT 'ERROR' AS Result, ERROR_MESSAGE() AS Message;
    END CATCH
END
GO

-- ========================================
-- PROCEDURE: sp_AssignTailorsToProductionOrder
-- Purpose: Intelligently assign tailors to production work
-- Complexity: MEDIUM-HIGH
-- ========================================
CREATE OR ALTER PROCEDURE sp_AssignTailorsToProductionOrder
    @ProductionOrderID INT,
    @TailorID INT = NULL  -- If NULL, auto-assign least busy tailor
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    
    BEGIN TRY
        DECLARE @ProductID INT, @Quantity INT, @AssignedTailorID INT;
        
        -- Get production order details
        SELECT @ProductID = ProductID, @Quantity = QuantityOrdered
        FROM ProductionOrder WHERE ProductionOrderID = @ProductionOrderID;
        
        -- Auto-assign tailor if not specified
        IF @TailorID IS NULL
        BEGIN
            SELECT TOP 1 @AssignedTailorID = e.EmployeeID
            FROM Employee e
            LEFT JOIN TailorAssignment ta ON e.EmployeeID = ta.TailorID AND ta.Status IN ('Assigned', 'InProgress')
            WHERE e.RoleID = 5  -- Tailor role
            AND e.IsActive = 1
            GROUP BY e.EmployeeID
            ORDER BY COUNT(ta.AssignmentID) ASC;  -- Least assignments
        END
        ELSE
        BEGIN
            SET @AssignedTailorID = @TailorID;
        END
        
        -- Create assignment
        IF @AssignedTailorID IS NOT NULL
        BEGIN
            INSERT INTO TailorAssignment (ProductionOrderID, TailorID, ProductID, QuantityAssigned, Status, AssignedDate)
            VALUES (@ProductionOrderID, @AssignedTailorID, @ProductID, @Quantity, 'Assigned', GETDATE());
            
            UPDATE ProductionOrder SET Status = 'InProgress' WHERE ProductionOrderID = @ProductionOrderID;
            
            COMMIT TRANSACTION;
            SELECT 'SUCCESS' AS Result, @AssignedTailorID AS TailorID;
        END
        ELSE
        BEGIN
            ROLLBACK TRANSACTION;
            SELECT 'ERROR' AS Result, 'No available tailor found' AS Message;
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SELECT 'ERROR' AS Result, ERROR_MESSAGE() AS Message;
    END CATCH
END
GO

-- ========================================
-- PROCEDURE: sp_CompleteProductionAndCreateDelivery
-- Purpose: Mark production complete and auto-create delivery
-- Complexity: HIGH
-- ========================================
CREATE OR ALTER PROCEDURE sp_CompleteProductionAndCreateDelivery
    @AssignmentID INT,
    @DeliveryPersonID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    
    BEGIN TRY
        DECLARE @ProductionOrderID INT, @SalesOrderID INT, @DealID INT;
        
        -- Update assignment status
        UPDATE TailorAssignment 
        SET Status = 'Complete', CompletedDate = GETDATE()
        WHERE AssignmentID = @AssignmentID;
        
        -- Get production order
        SELECT @ProductionOrderID = ProductionOrderID FROM TailorAssignment WHERE AssignmentID = @AssignmentID;
        
        -- Update production order
        UPDATE ProductionOrder 
        SET Status = 'Completed', ActualEndDate = GETDATE()
        WHERE ProductionOrderID = @ProductionOrderID;
        
        -- Find associated sales order or deal
        SELECT TOP 1 @SalesOrderID = so.SalesOrderID
        FROM SalesOrder so
        JOIN SalesOrderItem soi ON so.SalesOrderID = soi.SalesOrderID
        JOIN ProductionOrder po ON soi.ProductID = po.ProductID
        WHERE po.ProductionOrderID = @ProductionOrderID
        AND so.Status = 'Approved';
        
        IF @SalesOrderID IS NULL
        BEGIN
            SELECT TOP 1 @DealID = d.DealID
            FROM Deal d
            JOIN DealItem di ON d.DealID = di.DealID
            JOIN ProductionOrder po ON di.ProductID = po.ProductID
            WHERE po.ProductionOrderID = @ProductionOrderID
            AND d.Status = 'Approved';
        END
        
        -- Create delivery if order found and no delivery exists
        IF @SalesOrderID IS NOT NULL
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM Delivery WHERE SalesOrderID = @SalesOrderID)
            BEGIN
                INSERT INTO Delivery (SalesOrderID, DeliveredBy, Status, CreatedDate)
                VALUES (@SalesOrderID, @DeliveryPersonID, 'Pending', GETDATE());
            END
        END
        ELSE IF @DealID IS NOT NULL
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM Delivery WHERE DealID = @DealID)
            BEGIN
                INSERT INTO Delivery (DealID, DeliveredBy, Status, CreatedDate)
                VALUES (@DealID, @DeliveryPersonID, 'Pending', GETDATE());
            END
        END
        
        COMMIT TRANSACTION;
        SELECT 'SUCCESS' AS Result;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SELECT 'ERROR' AS Result, ERROR_MESSAGE() AS Message;
    END CATCH
END
GO

-- ========================================
-- PROCEDURE: sp_PayMonthlySalaries
-- Purpose: Process monthly salary payment for all employees
-- Complexity: MEDIUM-HIGH
-- ========================================
CREATE OR ALTER PROCEDURE sp_PayMonthlySalaries
    @PaymentMonth INT,
    @PaymentYear INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    
    BEGIN TRY
        DECLARE @TotalSalary DECIMAL(18,2);
        DECLARE @EmployeeCount INT;
        
        -- Check if already paid
        IF EXISTS (SELECT 1 FROM SalaryPayment WHERE PaymentMonth = @PaymentMonth AND PaymentYear = @PaymentYear)
        BEGIN
            ROLLBACK TRANSACTION;
            SELECT 'ERROR' AS Result, 'Salaries already paid for this month' AS Message;
            RETURN;
        END
        
        -- Calculate totals
        SELECT @TotalSalary = SUM(Salary), @EmployeeCount = COUNT(*)
        FROM Employee WHERE IsActive = 1;
        
        -- Insert payment record
        INSERT INTO SalaryPayment (PaymentDate, PaymentMonth, PaymentYear, TotalAmount, EmployeeCount, CreatedDate, Notes)
        VALUES (GETDATE(), @PaymentMonth, @PaymentYear, @TotalSalary, @EmployeeCount, GETDATE(), 
                'Monthly salaries paid to ' + CAST(@EmployeeCount AS VARCHAR) + ' employees');
        
        -- Update monthly revenue
        UPDATE MonthlyRevenue
        SET TotalSalaries = @TotalSalary, SalariesPaid = 1, UpdatedDate = GETDATE()
        WHERE Year = @PaymentYear AND Month = @PaymentMonth;
        
        -- If no revenue record exists, create one
        IF @@ROWCOUNT = 0
        BEGIN
            DECLARE @MonthName NVARCHAR(20);
            SET @MonthName = DATENAME(MONTH, DATEFROMPARTS(@PaymentYear, @PaymentMonth, 1));
            
            INSERT INTO MonthlyRevenue (Year, Month, MonthName, TotalSalaries, SalariesPaid, CreatedDate)
            VALUES (@PaymentYear, @PaymentMonth, @MonthName, @TotalSalary, 1, GETDATE());
        END
        
        COMMIT TRANSACTION;
        SELECT 'SUCCESS' AS Result, @TotalSalary AS TotalPaid, @EmployeeCount AS EmployeeCount;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SELECT 'ERROR' AS Result, ERROR_MESSAGE() AS Message;
    END CATCH
END
GO

-- ========================================
-- PROCEDURE: sp_CalculateMonthlyRevenue
-- Purpose: Calculate complete monthly P&L
-- Complexity: HIGH
-- ========================================
CREATE OR ALTER PROCEDURE sp_CalculateMonthlyRevenue
    @Year INT,
    @Month INT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @SalesIncome DECIMAL(18,2) = 0;
    DECLARE @DealIncome DECIMAL(18,2) = 0;
    DECLARE @TotalSalaries DECIMAL(18,2) = 0;
    DECLARE @RawMaterialCost DECIMAL(18,2) = 0;
    DECLARE @MiscExpense DECIMAL(18,2) = 0;
    DECLARE @MonthName NVARCHAR(20);
    
    SET @MonthName = DATENAME(MONTH, DATEFROMPARTS(@Year, @Month, 1));
    
    -- Calculate Sales Income
    SELECT @SalesIncome = ISNULL(SUM(TotalAmount), 0)
    FROM SalesOrder
    WHERE Status = 'Delivered'
    AND YEAR(OrderDate) = @Year
    AND MONTH(OrderDate) = @Month;
    
    -- Calculate Deal Income
    SELECT @DealIncome = ISNULL(SUM(TotalAmount), 0)
    FROM Deal
    WHERE Status = 'Delivered'
    AND YEAR(StartDate) = @Year
    AND MONTH(StartDate) = @Month;
    
    -- Get Salaries
    SELECT @TotalSalaries = ISNULL(TotalAmount, 0)
    FROM SalaryPayment
    WHERE PaymentYear = @Year AND PaymentMonth = @Month;
    
    -- Calculate Raw Material Cost
    SELECT @RawMaterialCost = ISNULL(SUM(TotalAmount), 0)
    FROM RawMaterialPurchase
    WHERE YEAR(PurchaseDate) = @Year
    AND MONTH(PurchaseDate) = @Month;
    
    -- Calculate Misc Expenses
    SELECT @MiscExpense = ISNULL(SUM(Amount), 0)
    FROM MiscExpense
    WHERE YEAR(ExpenseDate) = @Year
    AND MONTH(ExpenseDate) = @Month;
    
    -- Update or Insert
    IF EXISTS (SELECT 1 FROM MonthlyRevenue WHERE Year = @Year AND Month = @Month)
    BEGIN
        UPDATE MonthlyRevenue
        SET SalesIncome = @SalesIncome,
            DealIncome = @DealIncome,
            TotalSalaries = @TotalSalaries,
            RawMaterialCost = @RawMaterialCost,
            MiscExpense = @MiscExpense,
            UpdatedDate = GETDATE()
        WHERE Year = @Year AND Month = @Month;
    END
    ELSE
    BEGIN
        INSERT INTO MonthlyRevenue (Year, Month, MonthName, SalesIncome, DealIncome, TotalSalaries, RawMaterialCost, MiscExpense, CreatedDate)
        VALUES (@Year, @Month, @MonthName, @SalesIncome, @DealIncome, @TotalSalaries, @RawMaterialCost, @MiscExpense, GETDATE());
    END
    
    -- Return results
    SELECT Year, Month, MonthName, SalesIncome, DealIncome, TotalIncome, TotalSalaries, RawMaterialCost, MiscExpense, TotalExpense, NetProfit
    FROM MonthlyRevenue
    WHERE Year = @Year AND Month = @Month;
END
GO

-- ========================================
-- PROCEDURE: sp_AddRawMaterialPurchaseWithRestock
-- Purpose: Purchase material and automatically restock
-- Complexity: MEDIUM
-- ========================================
CREATE OR ALTER PROCEDURE sp_AddRawMaterialPurchaseWithRestock
    @RawMaterialID INT,
    @Quantity DECIMAL(18,2),
    @UnitPrice DECIMAL(18,2),
    @SupplierName NVARCHAR(300),
    @InvoiceNumber NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    
    BEGIN TRY
        DECLARE @TotalAmount DECIMAL(18,2) = @Quantity * @UnitPrice;
        DECLARE @MaterialName NVARCHAR(300), @Unit NVARCHAR(50);
        
        -- Get material details
        SELECT @MaterialName = MaterialName, @Unit = Unit
        FROM RawMaterial WHERE RawMaterialID = @RawMaterialID;
        
        -- Insert purchase record
        INSERT INTO RawMaterialPurchase (RawMaterialID, MaterialName, PurchaseDate, Quantity, Unit, UnitPrice, TotalAmount, SupplierName, InvoiceNumber, CreatedDate)
        VALUES (@RawMaterialID, @MaterialName, GETDATE(), @Quantity, @Unit, @UnitPrice, @TotalAmount, @SupplierName, @InvoiceNumber, GETDATE());
        
        -- Update stock quantity
        UPDATE RawMaterial
        SET StockQuantity = StockQuantity + @Quantity, UpdatedDate = GETDATE()
        WHERE RawMaterialID = @RawMaterialID;
        
        COMMIT TRANSACTION;
        SELECT 'SUCCESS' AS Result, SCOPE_IDENTITY() AS PurchaseID, @TotalAmount AS TotalAmount;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SELECT 'ERROR' AS Result, ERROR_MESSAGE() AS Message;
    END CATCH
END
GO

PRINT '✓ Complex business logic procedures created successfully!';
PRINT '✓ Total procedures: 6';
GO
