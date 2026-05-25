-- ================================================================================
-- DEAL MODULE - STORED PROCEDURES
-- ================================================================================
-- Execute this script in SSMS after creating the database tables
-- These procedures handle all CRUD operations for the Deal Management module
-- ================================================================================

USE GarmentsFactoryDB;
GO

-- ================================================================================
-- 1. GET ALL DEALS (with employee names and filtering)
-- ================================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetAllDeals')
    DROP PROCEDURE sp_GetAllDeals;
GO

CREATE PROCEDURE sp_GetAllDeals
    @SearchTerm NVARCHAR(100) = '',
    @StatusFilter NVARCHAR(30) = 'All'
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        d.DealID,
        d.DealTitle,
        d.DealType,
        d.ClientName,
        d.ContactPerson,
        d.Email,
        d.Phone,
        d.EstimatedValue,
        d.Currency,
        d.Priority,
        d.ExpectedDuration,
        d.StartDate,
        d.EndDate,
        d.Description,
        d.KeyTerms,
        d.PaymentTerms,
        d.PaymentMethod,
        d.SpecialRequirements,
        d.Status,
        d.AssignedManagerID,
        ISNULL(e.FirstName + ' ' + e.LastName, 'Owner') AS AssignedManagerName,
        d.CreatedBy,
        ISNULL(e2.FirstName + ' ' + e2.LastName, 'Owner') AS CreatedByName,
        d.CreatedDate,
        d.UpdatedDate
    FROM Deal d
    LEFT JOIN Employee e ON d.AssignedManagerID = e.EmployeeID
    LEFT JOIN Employee e2 ON d.CreatedBy = e2.EmployeeID
    WHERE 
        (@SearchTerm = '' OR 
         d.DealTitle LIKE '%' + @SearchTerm + '%' OR
         d.ClientName LIKE '%' + @SearchTerm + '%' OR
         d.ContactPerson LIKE '%' + @SearchTerm + '%' OR
         CAST(d.DealID AS NVARCHAR) LIKE '%' + @SearchTerm + '%')
    AND
        (@StatusFilter = 'All' OR d.Status = @StatusFilter)
    ORDER BY d.CreatedDate DESC;
END
GO

-- ================================================================================
-- 2. GET DEAL BY ID (with full details)
-- ================================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetDealById')
    DROP PROCEDURE sp_GetDealById;
GO

CREATE PROCEDURE sp_GetDealById
    @DealID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        d.DealID,
        d.DealTitle,
        d.DealType,
        d.ClientName,
        d.ContactPerson,
        d.Email,
        d.Phone,
        d.EstimatedValue,
        d.Currency,
        d.Priority,
        d.ExpectedDuration,
        d.StartDate,
        d.EndDate,
        d.Description,
        d.KeyTerms,
        d.PaymentTerms,
        d.PaymentMethod,
        d.SpecialRequirements,
        d.Status,
        d.AssignedManagerID,
        ISNULL(e.FirstName + ' ' + e.LastName, 'Owner') AS AssignedManagerName,
        d.CreatedBy,
        ISNULL(e2.FirstName + ' ' + e2.LastName, 'Owner') AS CreatedByName,
        d.CreatedDate,
        d.UpdatedDate
    FROM Deal d
    LEFT JOIN Employee e ON d.AssignedManagerID = e.EmployeeID
    LEFT JOIN Employee e2 ON d.CreatedBy = e2.EmployeeID
    WHERE d.DealID = @DealID;
END
GO

-- ================================================================================
-- 3. ADD NEW DEAL
-- ================================================================================
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
        
        SELECT @NewDealID AS DealID, 'Deal created successfully' AS Message;
    END TRY
    BEGIN CATCH
        SELECT 
            ERROR_NUMBER() AS ErrorNumber,
            ERROR_MESSAGE() AS ErrorMessage;
    END CATCH
END
GO

-- ================================================================================
-- 4. UPDATE DEAL
-- ================================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_UpdateDeal')
    DROP PROCEDURE sp_UpdateDeal;
GO

CREATE PROCEDURE sp_UpdateDeal
    @DealID INT,
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
    @Status NVARCHAR(30) = 'Draft'
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Deal WHERE DealID = @DealID)
        BEGIN
            SELECT 'Deal not found' AS Message;
            RETURN;
        END
        
        UPDATE Deal
        SET 
            DealTitle = @DealTitle,
            DealType = @DealType,
            ClientName = @ClientName,
            ContactPerson = @ContactPerson,
            Email = @Email,
            Phone = @Phone,
            EstimatedValue = @EstimatedValue,
            Currency = @Currency,
            Priority = @Priority,
            ExpectedDuration = @ExpectedDuration,
            StartDate = @StartDate,
            EndDate = @EndDate,
            Description = @Description,
            KeyTerms = @KeyTerms,
            PaymentTerms = @PaymentTerms,
            PaymentMethod = @PaymentMethod,
            SpecialRequirements = @SpecialRequirements,
            AssignedManagerID = @AssignedManagerID,
            Status = @Status,
            UpdatedDate = GETDATE()
        WHERE DealID = @DealID;
        
        SELECT 'Deal updated successfully' AS Message;
    END TRY
    BEGIN CATCH
        SELECT 
            ERROR_NUMBER() AS ErrorNumber,
            ERROR_MESSAGE() AS ErrorMessage;
    END CATCH
END
GO

-- ================================================================================
-- 5. DELETE DEAL (cascades to DealItems)
-- ================================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_DeleteDeal')
    DROP PROCEDURE sp_DeleteDeal;
GO

CREATE PROCEDURE sp_DeleteDeal
    @DealID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Deal WHERE DealID = @DealID)
        BEGIN
            SELECT 'Deal not found' AS Message;
            RETURN;
        END
        
        -- Delete deal (DealItems will be cascade deleted due to FK constraint)
        DELETE FROM Deal WHERE DealID = @DealID;
        
        SELECT 'Deal deleted successfully' AS Message;
    END TRY
    BEGIN CATCH
        SELECT 
            ERROR_NUMBER() AS ErrorNumber,
            ERROR_MESSAGE() AS ErrorMessage;
    END CATCH
END
GO

-- ================================================================================
-- 6. GET DEAL STATISTICS (for dashboard cards)
-- ================================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetDealStatistics')
    DROP PROCEDURE sp_GetDealStatistics;
GO

CREATE PROCEDURE sp_GetDealStatistics
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        COUNT(*) AS TotalDeals,
        SUM(CASE WHEN Status = 'Pending' THEN 1 ELSE 0 END) AS PendingDeals,
        SUM(CASE WHEN Status = 'Draft' THEN 1 ELSE 0 END) AS DraftDeals,
        SUM(CASE WHEN Status = 'Under Review' THEN 1 ELSE 0 END) AS UnderReviewDeals,
        SUM(CASE WHEN Status = 'Pending Approval' THEN 1 ELSE 0 END) AS PendingApprovalDeals,
        SUM(CASE WHEN Status = 'Approved' THEN 1 ELSE 0 END) AS ApprovedDeals,
        SUM(CASE WHEN Status = 'Active' THEN 1 ELSE 0 END) AS ActiveDeals,
        SUM(CASE WHEN Status = 'In Progress' THEN 1 ELSE 0 END) AS InProgressDeals,
        SUM(CASE WHEN Status = 'Completed' THEN 1 ELSE 0 END) AS CompletedDeals,
        SUM(CASE WHEN Status = 'Cancelled' THEN 1 ELSE 0 END) AS CancelledDeals,
        SUM(ISNULL(EstimatedValue, 0)) AS TotalEstimatedValue,
        AVG(ISNULL(EstimatedValue, 0)) AS AverageEstimatedValue
    FROM Deal;
END
GO

-- ================================================================================
-- 7. GET DEAL ITEMS (products in a deal)
-- ================================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetDealItems')
    DROP PROCEDURE sp_GetDealItems;
GO

CREATE PROCEDURE sp_GetDealItems
    @DealID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        di.DealItemID,
        di.DealID,
        di.ProductID,
        p.ProductName,
        p.Category,
        p.SKU,
        di.Quantity,
        di.UnitPrice,
        (di.Quantity * di.UnitPrice) AS TotalPrice
    FROM DealItem di
    INNER JOIN Product p ON di.ProductID = p.ProductID
    WHERE di.DealID = @DealID
    ORDER BY di.DealItemID;
END
GO

-- ================================================================================
-- 8. ADD DEAL ITEM (add product to deal)
-- ================================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_AddDealItem')
    DROP PROCEDURE sp_AddDealItem;
GO

CREATE PROCEDURE sp_AddDealItem
    @DealID INT,
    @ProductID INT,
    @Quantity INT,
    @UnitPrice DECIMAL(18,2),
    @NewDealItemID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- Validate Deal exists
        IF NOT EXISTS (SELECT 1 FROM Deal WHERE DealID = @DealID)
        BEGIN
            SELECT 'Deal not found' AS Message;
            RETURN;
        END
        
        -- Validate Product exists
        IF NOT EXISTS (SELECT 1 FROM Product WHERE ProductID = @ProductID)
        BEGIN
            SELECT 'Product not found' AS Message;
            RETURN;
        END
        
        INSERT INTO DealItem (DealID, ProductID, Quantity, UnitPrice)
        VALUES (@DealID, @ProductID, @Quantity, @UnitPrice);
        
        SET @NewDealItemID = SCOPE_IDENTITY();
        
        SELECT @NewDealItemID AS DealItemID, 'Deal item added successfully' AS Message;
    END TRY
    BEGIN CATCH
        SELECT 
            ERROR_NUMBER() AS ErrorNumber,
            ERROR_MESSAGE() AS ErrorMessage;
    END CATCH
END
GO

-- ================================================================================
-- 9. UPDATE DEAL ITEM
-- ================================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_UpdateDealItem')
    DROP PROCEDURE sp_UpdateDealItem;
GO

CREATE PROCEDURE sp_UpdateDealItem
    @DealItemID INT,
    @ProductID INT,
    @Quantity INT,
    @UnitPrice DECIMAL(18,2)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM DealItem WHERE DealItemID = @DealItemID)
        BEGIN
            SELECT 'Deal item not found' AS Message;
            RETURN;
        END
        
        UPDATE DealItem
        SET 
            ProductID = @ProductID,
            Quantity = @Quantity,
            UnitPrice = @UnitPrice
        WHERE DealItemID = @DealItemID;
        
        SELECT 'Deal item updated successfully' AS Message;
    END TRY
    BEGIN CATCH
        SELECT 
            ERROR_NUMBER() AS ErrorNumber,
            ERROR_MESSAGE() AS ErrorMessage;
    END CATCH
END
GO

-- ================================================================================
-- 10. DELETE DEAL ITEM
-- ================================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_DeleteDealItem')
    DROP PROCEDURE sp_DeleteDealItem;
GO

CREATE PROCEDURE sp_DeleteDealItem
    @DealItemID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM DealItem WHERE DealItemID = @DealItemID)
        BEGIN
            SELECT 'Deal item not found' AS Message;
            RETURN;
        END
        
        DELETE FROM DealItem WHERE DealItemID = @DealItemID;
        
        SELECT 'Deal item deleted successfully' AS Message;
    END TRY
    BEGIN CATCH
        SELECT 
            ERROR_NUMBER() AS ErrorNumber,
            ERROR_MESSAGE() AS ErrorMessage;
    END CATCH
END
GO

-- ================================================================================
-- 11. GET DEALS BY STATUS
-- ================================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetDealsByStatus')
    DROP PROCEDURE sp_GetDealsByStatus;
GO

CREATE PROCEDURE sp_GetDealsByStatus
    @Status NVARCHAR(30)
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        d.DealID,
        d.DealTitle,
        d.ClientName,
        d.EstimatedValue,
        d.Currency,
        d.Priority,
        d.StartDate,
        d.EndDate,
        d.Status,
        ISNULL(e.FirstName + ' ' + e.LastName, 'Owner') AS AssignedManagerName,
        d.CreatedDate
    FROM Deal d
    LEFT JOIN Employee e ON d.AssignedManagerID = e.EmployeeID
    WHERE d.Status = @Status
    ORDER BY d.CreatedDate DESC;
END
GO

-- ================================================================================
-- 12. GET DEALS BY EMPLOYEE (created by specific employee)
-- ================================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetDealsByEmployee')
    DROP PROCEDURE sp_GetDealsByEmployee;
GO

CREATE PROCEDURE sp_GetDealsByEmployee
    @EmployeeID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        d.DealID,
        d.DealTitle,
        d.ClientName,
        d.EstimatedValue,
        d.Currency,
        d.Priority,
        d.Status,
        d.StartDate,
        d.EndDate,
        d.CreatedDate
    FROM Deal d
    WHERE d.CreatedBy = @EmployeeID OR d.AssignedManagerID = @EmployeeID
    ORDER BY d.CreatedDate DESC;
END
GO

-- ================================================================================
-- PROCEDURES CREATED SUCCESSFULLY!
-- ================================================================================
PRINT '========================================';
PRINT 'DEAL MODULE PROCEDURES CREATED!';
PRINT '12 Stored Procedures have been created:';
PRINT '1. sp_GetAllDeals';
PRINT '2. sp_GetDealById';
PRINT '3. sp_AddDeal';
PRINT '4. sp_UpdateDeal';
PRINT '5. sp_DeleteDeal';
PRINT '6. sp_GetDealStatistics';
PRINT '7. sp_GetDealItems';
PRINT '8. sp_AddDealItem';
PRINT '9. sp_UpdateDealItem';
PRINT '10. sp_DeleteDealItem';
PRINT '11. sp_GetDealsByStatus';
PRINT '12. sp_GetDealsByEmployee';
PRINT '========================================';
GO
