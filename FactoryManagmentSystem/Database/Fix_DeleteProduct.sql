-- Fix sp_DeleteProduct to handle foreign key constraints
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

DROP PROCEDURE IF EXISTS sp_DeleteProduct;
GO

CREATE PROCEDURE sp_DeleteProduct
    @ProductID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRANSACTION;
    
    BEGIN TRY
        -- Delete related records first to avoid foreign key constraint violations
        DELETE FROM ProductMaterialRequirement WHERE ProductID = @ProductID;
        DELETE FROM DealItem WHERE ProductID = @ProductID;
        DELETE FROM SalesOrderItem WHERE ProductID = @ProductID;
        DELETE FROM TailorAssignment WHERE ProductID = @ProductID;
        DELETE FROM ProductionOrder WHERE ProductID = @ProductID;
        DELETE FROM Stock WHERE ProductID = @ProductID;
        
        -- Finally delete the product
        DELETE FROM Product WHERE ProductID = @ProductID;
        
        COMMIT TRANSACTION;
        RETURN 0;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
        RETURN -1;
    END CATCH
END
GO

PRINT 'sp_DeleteProduct updated successfully to handle foreign key constraints';
