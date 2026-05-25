-- =============================================
-- Update sp_AddSalesOrder to automatically create OrderApproval entry
-- =============================================
USE GarmentsFactoryDB;
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

        -- *** NEW: Automatically create OrderApproval entry ***
        -- This ensures all sales orders flow through the approval workflow
        INSERT INTO OrderApproval (
            OrderType,
            OrderID,
            RequestedByEmployeeID,
            Priority,
            Status,
            RequestDate
        )
        VALUES (
            'SalesOrder',
            @NewSalesOrderID,
            @SalesRepID,  -- The salesperson who created the order
            @PriorityLevel,
            'Pending',
            GETDATE()
        );

        DECLARE @ApprovalID INT = SCOPE_IDENTITY();
        
        COMMIT TRANSACTION;
        
        PRINT 'Sales Order added successfully with ID: ' + CAST(@NewSalesOrderID AS VARCHAR(10));
        PRINT 'Order Approval created with ID: ' + CAST(@ApprovalID AS VARCHAR(10));
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

PRINT 'sp_AddSalesOrder updated successfully - now creates OrderApproval automatically.';
GO
