-- Fix sp_DeleteRawMaterial to handle correct table references
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

DROP PROCEDURE IF EXISTS sp_DeleteRawMaterial;
GO

CREATE PROCEDURE sp_DeleteRawMaterial
    @RawMaterialID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRANSACTION;
    
    BEGIN TRY
        -- Check if material is used in product material requirements
        IF EXISTS (SELECT 1 FROM ProductMaterialRequirement WHERE RawMaterialID = @RawMaterialID)
        BEGIN
            -- Delete from ProductMaterialRequirement first
            DELETE FROM ProductMaterialRequirement WHERE RawMaterialID = @RawMaterialID;
        END
        
        -- Now delete the raw material
        DELETE FROM RawMaterial WHERE RawMaterialID = @RawMaterialID;
        
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

PRINT 'sp_DeleteRawMaterial fixed successfully';
