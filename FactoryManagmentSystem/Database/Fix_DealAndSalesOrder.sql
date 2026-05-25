-- Fix Deal and Sales Order Issues
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ================================================================================
-- 1. Fix sp_AddDeal - Add @Status parameter
-- ================================================================================
DROP PROCEDURE IF EXISTS sp_AddDeal;
GO

CREATE PROCEDURE sp_AddDeal
    @DealTitle NVARCHAR(200),
    @DealType NVARCHAR(50) = NULL,
    @ClientName NVARCHAR(200) = NULL,
    @ContactPerson NVARCHAR(100) = NULL,
    @Email NVARCHAR(100) = NULL,
    @Phone NVARCHAR(20) = NULL,
    @EstimatedValue DECIMAL(18,2) = 0,
    @Currency NVARCHAR(10) = 'PKR',
    @Priority NVARCHAR(20) = 'Medium',
    @ExpectedDuration NVARCHAR(50) = NULL,
    @StartDate DATE = NULL,
    @EndDate DATE = NULL,
    @Description NVARCHAR(MAX) = NULL,
    @KeyTerms NVARCHAR(MAX) = NULL,
    @PaymentTerms NVARCHAR(100) = NULL,
    @PaymentMethod NVARCHAR(50) = NULL,
    @SpecialRequirements NVARCHAR(MAX) = NULL,
    @AssignedManagerID INT = NULL,
    @CreatedBy INT = NULL,
    @DeliveryAddress NVARCHAR(500) = NULL,
    @City NVARCHAR(100) = NULL,
    @Province NVARCHAR(100) = NULL,
    @Status NVARCHAR(50) = 'Pending',
    @NewDealID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO Deal (DealTitle, DealType, ClientName, ContactPerson, Email, Phone, EstimatedValue, Currency, Priority,
        ExpectedDuration, StartDate, EndDate, Description, KeyTerms, PaymentTerms, PaymentMethod, SpecialRequirements,
        AssignedManagerID, Status, CreatedBy, CreatedDate, DeliveryAddress, City, Province)
    VALUES (@DealTitle, @DealType, @ClientName, @ContactPerson, @Email, @Phone, @EstimatedValue, @Currency, @Priority,
        @ExpectedDuration, @StartDate, @EndDate, @Description, @KeyTerms, @PaymentTerms, @PaymentMethod, @SpecialRequirements,
        @AssignedManagerID, @Status, @CreatedBy, GETDATE(), @DeliveryAddress, @City, @Province);
    
    SET @NewDealID = SCOPE_IDENTITY();
END
GO

PRINT 'sp_AddDeal fixed - added @Status parameter';
GO

-- ================================================================================
-- 2. Fix sp_GetRetailersForOrder - Remove non-existent columns
-- ================================================================================
DROP PROCEDURE IF EXISTS sp_GetRetailersForOrder;
GO

CREATE PROCEDURE sp_GetRetailersForOrder
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        r.RetailerID,
        r.CompanyName,
        r.ContactPerson,
        r.Phone,
        r.Email,
        r.City,
        r.Province,
        r.Address AS ShippingAddress,
        NULL AS PaymentTerms,
        0.00 AS DiscountPercentage,
        r.Status
    FROM Retailer r
    WHERE r.IsActive = 1 AND r.Status = 'Active'
    ORDER BY r.CompanyName;
END
GO

PRINT 'sp_GetRetailersForOrder fixed - removed PaymentTerms and DiscountPercentage columns';
GO
