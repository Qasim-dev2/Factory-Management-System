-- =============================================
-- STORED PROCEDURE: Deduct Raw Material Stock for Production Orders
-- Description: Deducts material quantities when production order is created
-- =============================================

USE GarmentsFactoryDB;
GO

-- Drop if exists
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_DeductRawMaterialStock')
    DROP PROCEDURE sp_DeductRawMaterialStock;
GO

CREATE PROCEDURE sp_DeductRawMaterialStock
    @RawMaterialID INT,
    @QuantityToDeduct DECIMAL(18,2)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validate raw material exists
        IF NOT EXISTS (SELECT 1 FROM RawMaterial WHERE RawMaterialID = @RawMaterialID AND IsActive = 1)
        BEGIN
            RAISERROR('Raw Material not found or inactive.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Validate quantity to deduct is positive
        IF @QuantityToDeduct <= 0
        BEGIN
            RAISERROR('Quantity to deduct must be greater than zero.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Get current quantity
        DECLARE @CurrentQuantity DECIMAL(18,2);
        SELECT @CurrentQuantity = Quantity 
        FROM RawMaterial 
        WHERE RawMaterialID = @RawMaterialID;
        
        -- Check if sufficient stock available
        IF @CurrentQuantity < @QuantityToDeduct
        BEGIN
            DECLARE @ErrorMsg NVARCHAR(500);
            SET @ErrorMsg = 'Insufficient stock. Available: ' + CAST(@CurrentQuantity AS NVARCHAR(20)) + 
                           ', Requested: ' + CAST(@QuantityToDeduct AS NVARCHAR(20));
            RAISERROR(@ErrorMsg, 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Deduct stock (subtract quantity)
        UPDATE RawMaterial
        SET 
            Quantity = Quantity - @QuantityToDeduct,  -- SUBTRACT
            UpdatedDate = GETDATE()
        WHERE RawMaterialID = @RawMaterialID;
        
        COMMIT TRANSACTION;
        
        -- Return success message
        SELECT 
            @RawMaterialID AS RawMaterialID,
            @QuantityToDeduct AS QuantityDeducted,
            (Quantity) AS RemainingStock,
            'Stock deducted successfully' AS Message
        FROM RawMaterial
        WHERE RawMaterialID = @RawMaterialID;
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

PRINT 'sp_DeductRawMaterialStock created successfully.';
PRINT 'This procedure deducts material quantities when production orders are created.';
GO

-- Test the procedure (optional)
-- EXEC sp_DeductRawMaterialStock @RawMaterialID = 1, @QuantityToDeduct = 10.5;
