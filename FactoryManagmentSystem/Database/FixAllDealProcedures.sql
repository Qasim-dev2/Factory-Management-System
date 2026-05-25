-- ================================================================================
-- COMPLETE FIX FOR ALL DEAL PROCEDURES - Updated for simplified Deal table
-- ================================================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ================================================================================
-- 1. sp_GetDealStatistics - Remove EstimatedValue references
-- ================================================================================
DROP PROCEDURE IF EXISTS sp_GetDealStatistics;
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
        0 AS TotalEstimatedValue,
        0 AS AverageEstimatedValue
    FROM Deal;
END
GO

PRINT 'sp_GetDealStatistics updated - removed EstimatedValue';
GO

-- ================================================================================
-- 2. sp_GetDealItems
-- ================================================================================
DROP PROCEDURE IF EXISTS sp_GetDealItems;
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
    WHERE di.DealID = @DealID;
END
GO

PRINT 'sp_GetDealItems updated';
GO

-- ================================================================================
-- 3. sp_AddDealItem
-- ================================================================================
DROP PROCEDURE IF EXISTS sp_AddDealItem;
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
    
    INSERT INTO DealItem (DealID, ProductID, Quantity, UnitPrice)
    VALUES (@DealID, @ProductID, @Quantity, @UnitPrice);
    
    SET @NewDealItemID = SCOPE_IDENTITY();
END
GO

PRINT 'sp_AddDealItem updated';
GO

-- ================================================================================
-- 4. sp_UpdateDealItem
-- ================================================================================
DROP PROCEDURE IF EXISTS sp_UpdateDealItem;
GO

CREATE PROCEDURE sp_UpdateDealItem
    @DealItemID INT,
    @ProductID INT,
    @Quantity INT,
    @UnitPrice DECIMAL(18,2)
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE DealItem
    SET ProductID = @ProductID,
        Quantity = @Quantity,
        UnitPrice = @UnitPrice
    WHERE DealItemID = @DealItemID;
END
GO

PRINT 'sp_UpdateDealItem updated';
GO

-- ================================================================================
-- 5. sp_DeleteDealItem
-- ================================================================================
DROP PROCEDURE IF EXISTS sp_DeleteDealItem;
GO

CREATE PROCEDURE sp_DeleteDealItem
    @DealItemID INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM DealItem WHERE DealItemID = @DealItemID;
END
GO

PRINT 'sp_DeleteDealItem updated';
GO

-- ================================================================================
-- 6. sp_DeleteDeal
-- ================================================================================
DROP PROCEDURE IF EXISTS sp_DeleteDeal;
GO

CREATE PROCEDURE sp_DeleteDeal
    @DealID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRANSACTION;
    BEGIN TRY
        -- Delete deal items first
        DELETE FROM DealItem WHERE DealID = @DealID;
        
        -- Delete the deal
        DELETE FROM Deal WHERE DealID = @DealID;
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

PRINT 'sp_DeleteDeal updated';
GO

PRINT '=================================================================';
PRINT 'All Deal procedures updated successfully for simplified table!';
PRINT '=================================================================';
