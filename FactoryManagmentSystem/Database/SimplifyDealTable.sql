-- Simplify Deal Table - Remove unnecessary columns
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Drop constraints first
ALTER TABLE Deal DROP CONSTRAINT DF__Deal__Currency__02084FDA;
ALTER TABLE Deal DROP CONSTRAINT DF__Deal__Priority__02FC7413;
GO

-- Drop columns
ALTER TABLE Deal DROP COLUMN EstimatedValue;
ALTER TABLE Deal DROP COLUMN Currency;
ALTER TABLE Deal DROP COLUMN Priority;
ALTER TABLE Deal DROP COLUMN KeyTerms;
ALTER TABLE Deal DROP COLUMN PaymentTerms;
ALTER TABLE Deal DROP COLUMN PaymentMethod;
ALTER TABLE Deal DROP COLUMN SpecialRequirements;
ALTER TABLE Deal DROP COLUMN AssignedManagerID;
GO

PRINT 'Deal table simplified - removed 8 columns';
GO

-- ================================================================================
-- Update sp_AddDeal with simplified columns
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
    @ExpectedDuration NVARCHAR(50) = NULL,
    @StartDate DATE = NULL,
    @EndDate DATE = NULL,
    @Description NVARCHAR(MAX) = NULL,
    @CreatedBy INT = NULL,
    @DeliveryAddress NVARCHAR(500) = NULL,
    @City NVARCHAR(100) = NULL,
    @Province NVARCHAR(100) = NULL,
    @Status NVARCHAR(50) = 'Pending',
    @NewDealID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO Deal (DealTitle, DealType, ClientName, ContactPerson, Email, Phone,
        ExpectedDuration, StartDate, EndDate, Description, Status, CreatedBy, CreatedDate,
        DeliveryAddress, City, Province)
    VALUES (@DealTitle, @DealType, @ClientName, @ContactPerson, @Email, @Phone,
        @ExpectedDuration, @StartDate, @EndDate, @Description, @Status, @CreatedBy, GETDATE(),
        @DeliveryAddress, @City, @Province);
    
    SET @NewDealID = SCOPE_IDENTITY();
END
GO

PRINT 'sp_AddDeal updated with simplified parameters';
GO

-- ================================================================================
-- Update sp_UpdateDeal with simplified columns
-- ================================================================================
DROP PROCEDURE IF EXISTS sp_UpdateDeal;
GO

CREATE PROCEDURE sp_UpdateDeal
    @DealID INT,
    @DealTitle NVARCHAR(200),
    @DealType NVARCHAR(50) = NULL,
    @ClientName NVARCHAR(200) = NULL,
    @ContactPerson NVARCHAR(100) = NULL,
    @Email NVARCHAR(100) = NULL,
    @Phone NVARCHAR(20) = NULL,
    @ExpectedDuration NVARCHAR(50) = NULL,
    @StartDate DATE = NULL,
    @EndDate DATE = NULL,
    @Description NVARCHAR(MAX) = NULL,
    @DeliveryAddress NVARCHAR(500) = NULL,
    @City NVARCHAR(100) = NULL,
    @Province NVARCHAR(100) = NULL,
    @Status NVARCHAR(50) = 'Pending'
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE Deal
    SET DealTitle = @DealTitle,
        DealType = @DealType,
        ClientName = @ClientName,
        ContactPerson = @ContactPerson,
        Email = @Email,
        Phone = @Phone,
        ExpectedDuration = @ExpectedDuration,
        StartDate = @StartDate,
        EndDate = @EndDate,
        Description = @Description,
        DeliveryAddress = @DeliveryAddress,
        City = @City,
        Province = @Province,
        Status = @Status,
        UpdatedDate = GETDATE()
    WHERE DealID = @DealID;
END
GO

PRINT 'sp_UpdateDeal updated with simplified parameters';
GO

-- ================================================================================
-- Update sp_GetAllDeals
-- ================================================================================
DROP PROCEDURE IF EXISTS sp_GetAllDeals;
GO

CREATE PROCEDURE sp_GetAllDeals
    @SearchTerm NVARCHAR(200) = '',
    @StatusFilter NVARCHAR(50) = 'All'
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        DealID,
        DealTitle,
        DealType,
        ClientName,
        ContactPerson,
        Email,
        Phone,
        ExpectedDuration,
        StartDate,
        EndDate,
        Description,
        Status,
        CreatedBy,
        CreatedDate,
        UpdatedDate,
        DeliveryAddress,
        City,
        Province
    FROM Deal
    WHERE (@SearchTerm = '' OR DealTitle LIKE '%' + @SearchTerm + '%' OR ClientName LIKE '%' + @SearchTerm + '%' OR ContactPerson LIKE '%' + @SearchTerm + '%')
      AND (@StatusFilter = 'All' OR Status = @StatusFilter)
    ORDER BY CreatedDate DESC;
END
GO

PRINT 'sp_GetAllDeals updated';
GO

-- ================================================================================
-- Update sp_GetDealById
-- ================================================================================
DROP PROCEDURE IF EXISTS sp_GetDealById;
GO

CREATE PROCEDURE sp_GetDealById
    @DealID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        DealID,
        DealTitle,
        DealType,
        ClientName,
        ContactPerson,
        Email,
        Phone,
        ExpectedDuration,
        StartDate,
        EndDate,
        Description,
        Status,
        CreatedBy,
        CreatedDate,
        UpdatedDate,
        DeliveryAddress,
        City,
        Province
    FROM Deal
    WHERE DealID = @DealID;
END
GO

PRINT 'sp_GetDealById updated';
GO

PRINT 'All Deal procedures updated successfully!';
