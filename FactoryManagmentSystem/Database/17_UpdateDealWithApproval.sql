-- =============================================
-- Update sp_AddDeal to automatically create OrderApproval entry
-- =============================================
USE GarmentsFactoryDB;
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

        -- *** NEW: Automatically create OrderApproval entry ***
        -- Only create approval entry if status is not 'Draft'
        IF @Status != 'Draft'
        BEGIN
            INSERT INTO OrderApproval (
                OrderType,
                OrderID,
                RequestedByEmployeeID,
                Priority,
                Status,
                RequestDate
            )
            VALUES (
                'Deal',
                @NewDealID,
                COALESCE(@AssignedManagerID, @CreatedBy),  -- Manager or creator who submitted the deal
                @Priority,
                'Pending',
                GETDATE()
            );

            DECLARE @ApprovalID INT = SCOPE_IDENTITY();
            PRINT 'Order Approval created with ID: ' + CAST(@ApprovalID AS VARCHAR(10));
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

PRINT 'sp_AddDeal updated successfully - now creates OrderApproval automatically for non-draft deals.';
GO
