-- =============================================
-- COMPLETE WORKFLOW INTEGRATION
-- Automatically create OrderApproval entries when SalesOrders or Deals are created
-- =============================================
-- This script updates the existing stored procedures to integrate the approval workflow
-- Run this script in SQL Server Management Studio (SSMS) after running 15_OrderApprovalSystem.sql
-- =============================================

USE GarmentsFactoryDB;
GO

PRINT '===============================================';
PRINT 'Starting Workflow Integration Updates';
PRINT '===============================================';
GO

-- =============================================
-- PART 1: Update sp_AddSalesOrder
-- =============================================
PRINT '';
PRINT 'PART 1: Updating sp_AddSalesOrder to create OrderApproval automatically...';
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_AddSalesOrder')
    DROP PROCEDURE sp_AddSalesOrder;
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE sp_AddSalesOrder
    -- Order Information
    @OrderDate DATETIME = NULL,
    @ExpectedDeliveryDate DATE = NULL,
    @PriorityLevel NVARCHAR(20) = 'Medium',
    @Status NVARCHAR(30) = 'Pending',
    
    -- Customer Information
    @RetailerID INT,
    @ShippingAddress NVARCHAR(500) = NULL,
    @SpecialInstructions NVARCHAR(500) = NULL,
    
    -- Payment Information
    @PaymentTerms NVARCHAR(30) = NULL,
    @AdvancePaymentPercent DECIMAL(5,2) = 0,
    @DiscountPercentage DECIMAL(5,2) = 0,
    @PaymentStatus NVARCHAR(20) = 'Pending',
    
    -- Order Summary
    @SubTotal DECIMAL(18,2) = 0,
    @DiscountAmount DECIMAL(18,2) = 0,
    @TaxAmount DECIMAL(18,2) = 0,
    @TotalAmount DECIMAL(18,2),
    
    -- Additional Information
    @SalesRepID INT = NULL,
    @OrderSource NVARCHAR(30) = NULL,
    @InternalNotes NVARCHAR(1000) = NULL,
    @Tags NVARCHAR(200) = NULL,
    
    -- Order Items (XML format)
    @OrderItemsXML XML = NULL,
    
    @NewSalesOrderID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Set default OrderDate if not provided
        IF @OrderDate IS NULL
            SET @OrderDate = GETDATE();
        
        -- Validate required fields
        IF @RetailerID IS NULL
        BEGIN
            RAISERROR('Retailer is required.', 16, 1);
            RETURN;
        END
        
        -- Validate Retailer exists
        IF NOT EXISTS (SELECT 1 FROM Retailer WHERE RetailerID = @RetailerID)
        BEGIN
            RAISERROR('Invalid Retailer ID.', 16, 1);
            RETURN;
        END
        
        -- Validate SalesRepID if provided
        IF @SalesRepID IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Employee WHERE EmployeeID = @SalesRepID)
        BEGIN
            RAISERROR('Invalid Sales Representative ID.', 16, 1);
            RETURN;
        END
        
        -- Insert Sales Order Header
        INSERT INTO SalesOrder (
            OrderDate, ExpectedDeliveryDate, PriorityLevel, Status,
            RetailerID, ShippingAddress, SpecialInstructions,
            PaymentTerms, AdvancePaymentPercent, DiscountPercentage, PaymentStatus,
            SubTotal, DiscountAmount, TaxAmount, TotalAmount,
            SalesRepID, OrderSource, InternalNotes, Tags,
            CreatedDate
        )
        VALUES (
            @OrderDate, @ExpectedDeliveryDate, @PriorityLevel, @Status,
            @RetailerID, @ShippingAddress, @SpecialInstructions,
            @PaymentTerms, @AdvancePaymentPercent, @DiscountPercentage, @PaymentStatus,
            @SubTotal, @DiscountAmount, @TaxAmount, @TotalAmount,
            @SalesRepID, @OrderSource, @InternalNotes, @Tags,
            GETDATE()
        );
        
        SET @NewSalesOrderID = SCOPE_IDENTITY();
        
        -- Insert Sales Order Items from XML
        IF @OrderItemsXML IS NOT NULL
        BEGIN
            INSERT INTO SalesOrderItem (SalesOrderID, ProductID, Size, Color, Quantity, UnitPrice, Discount)
            SELECT 
                @NewSalesOrderID,
                Item.value('(ProductID)[1]', 'INT'),
                Item.value('(Size)[1]', 'NVARCHAR(20)'),
                Item.value('(Color)[1]', 'NVARCHAR(50)'),
                Item.value('(Quantity)[1]', 'INT'),
                Item.value('(UnitPrice)[1]', 'DECIMAL(18,2)'),
                Item.value('(Discount)[1]', 'DECIMAL(18,2)')
            FROM @OrderItemsXML.nodes('/Items/Item') AS Items(Item);
        END

        -- *** WORKFLOW INTEGRATION: Automatically create OrderApproval entry ***
        -- This ensures all sales orders flow through the approval workflow
        INSERT INTO OrderApproval (
            OrderType,
            OrderID,
            RequestedByEmployeeID,
            Status,
            RequestDate
        )
        VALUES (
            'SalesOrder',
            @NewSalesOrderID,
            @SalesRepID,  -- The salesperson who created the order
            'Pending',
            GETDATE()
        );

        DECLARE @ApprovalID INT = SCOPE_IDENTITY();
        
        COMMIT TRANSACTION;
        
        PRINT 'Sales Order added successfully with ID: ' + CAST(@NewSalesOrderID AS VARCHAR(10));
        PRINT 'Order Approval created automatically with ID: ' + CAST(@ApprovalID AS VARCHAR(10));
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

PRINT 'sp_AddSalesOrder updated successfully ✓';
GO

-- =============================================
-- PART 2: Update sp_AddDeal
-- =============================================
PRINT '';
PRINT 'PART 2: Updating sp_AddDeal to create OrderApproval automatically...';
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_AddDeal')
    DROP PROCEDURE sp_AddDeal;
GO

CREATE PROCEDURE sp_AddDeal
    @DealTitle NVARCHAR(100),
    @DealType NVARCHAR(50) = NULL,
    @ClientName NVARCHAR(100) = NULL,
    @ContactPerson NVARCHAR(100) = NULL,
    @Email NVARCHAR(100) = NULL,
    @Phone NVARCHAR(20) = NULL,
    @EstimatedValue DECIMAL(18,2) = NULL,
    @Currency NVARCHAR(10) = 'PKR',
    @Priority NVARCHAR(20) = 'Medium',
    @ExpectedDuration NVARCHAR(50) = NULL,
    @StartDate DATE = NULL,
    @EndDate DATE = NULL,
    @Description NVARCHAR(1000) = NULL,
    @KeyTerms NVARCHAR(1000) = NULL,
    @PaymentTerms NVARCHAR(50) = NULL,
    @PaymentMethod NVARCHAR(50) = NULL,
    @SpecialRequirements NVARCHAR(1000) = NULL,
    @AssignedManagerID INT = NULL,
    @Status NVARCHAR(30) = 'Draft',
    @CreatedBy INT = NULL,
    @NewDealID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        INSERT INTO Deal (
            DealTitle, DealType, ClientName, ContactPerson, Email, Phone,
            EstimatedValue, Currency, Priority, ExpectedDuration,
            StartDate, EndDate, Description, KeyTerms, PaymentTerms,
            PaymentMethod, SpecialRequirements, AssignedManagerID,
            Status, CreatedBy, CreatedDate
        )
        VALUES (
            @DealTitle, @DealType, @ClientName, @ContactPerson, @Email, @Phone,
            @EstimatedValue, @Currency, @Priority, @ExpectedDuration,
            @StartDate, @EndDate, @Description, @KeyTerms, @PaymentTerms,
            @PaymentMethod, @SpecialRequirements, @AssignedManagerID,
            @Status, @CreatedBy, GETDATE()
        );
        
        SET @NewDealID = SCOPE_IDENTITY();

        -- *** WORKFLOW INTEGRATION: Automatically create OrderApproval entry ***
        -- Only create approval entry if status is not 'Draft'
        IF @Status != 'Draft'
        BEGIN
            INSERT INTO OrderApproval (
                OrderType,
                OrderID,
                RequestedByEmployeeID,
                Status,
                RequestDate
            )
            VALUES (
                'Deal',
                @NewDealID,
                COALESCE(@AssignedManagerID, @CreatedBy),  -- Manager or creator who submitted the deal
                'Pending',
                GETDATE()
            );

            DECLARE @DealApprovalID INT = SCOPE_IDENTITY();
            PRINT 'Order Approval created automatically with ID: ' + CAST(@DealApprovalID AS VARCHAR(10));
        END
        
        COMMIT TRANSACTION;
        
        SELECT @NewDealID AS DealID, 'Deal created successfully' AS Message;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        SELECT 
            ERROR_NUMBER() AS ErrorNumber,
            ERROR_MESSAGE() AS ErrorMessage;
    END CATCH
END
GO

PRINT 'sp_AddDeal updated successfully ✓';
GO

-- =============================================
-- PART 3: Verification Queries
-- =============================================
PRINT '';
PRINT 'PART 3: Verifying updates...';
GO

-- Check if procedures exist
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_AddSalesOrder')
    PRINT '✓ sp_AddSalesOrder exists';
ELSE
    PRINT '✗ sp_AddSalesOrder NOT FOUND';

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_AddDeal')
    PRINT '✓ sp_AddDeal exists';
ELSE
    PRINT '✗ sp_AddDeal NOT FOUND';

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'OrderApproval')
    PRINT '✓ OrderApproval table exists';
ELSE
    PRINT '✗ OrderApproval table NOT FOUND - Please run 15_OrderApprovalSystem.sql first!';

GO

PRINT '';
PRINT '===============================================';
PRINT 'Workflow Integration Complete!';
PRINT '===============================================';
PRINT '';
PRINT 'WHAT CHANGED:';
PRINT '1. sp_AddSalesOrder now automatically creates an OrderApproval entry';
PRINT '   - Every new SalesOrder will appear in the Order Approval queue';
PRINT '   - Requested by the salesperson who created it';
PRINT '';
PRINT '2. sp_AddDeal now automatically creates an OrderApproval entry';
PRINT '   - Only for non-Draft deals';
PRINT '   - Requested by the manager or creator';
PRINT '';
PRINT 'NEXT STEPS:';
PRINT '1. Test by creating a SalesOrder through your application';
PRINT '2. Check the Order Approval window - it should appear immediately';
PRINT '3. Approve the order to create a Production Order';
PRINT '4. Assign tailors and track completion';
PRINT '';
PRINT 'WORKFLOW: SalesOrder → Approval → Production → Tailor Assignment → Delivery';
PRINT '===============================================';
GO
