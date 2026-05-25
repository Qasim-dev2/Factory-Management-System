
CREATE PROCEDURE sp_ApproveOrderAndCreat

        -- Assign tailors to production order
        IF @TailorIDs IS NOT NULL AND LEN(@TailorIDs) > 0
        BEGIN
            EXEC sp_AssignTailorsToProductionOrder
                @ProductionOrderID = @ProductionOrderID,
                @TailorIDs = @TailorIDs,
                @ProductID = @ProductID,
                @QuantityOrdered = @QuantityOrdered;
        ENDeProduction
    @ApprovalID INT,
    @OwnerID INT,
    @TailorIDs NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @OrderType NVARCHAR(50), @Orde

(1 rows affected)
