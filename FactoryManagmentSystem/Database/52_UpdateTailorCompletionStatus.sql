-- Update sp_UpdateTailorCompletionStatus to properly handle status updates
-- and update production order status when all tailors complete

DROP PROCEDURE IF EXISTS sp_UpdateTailorCompletionStatus;
GO

CREATE PROCEDURE sp_UpdateTailorCompletionStatus
    @TailorAssignmentID INT,
    @TailorID INT,
    @NewStatus NVARCHAR(50),
    @CompletionNotes NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @ProductionOrderID INT = NULL;
        DECLARE @AssignmentExists INT = 0;

        -- Check if assignment exists and get ProductionOrderID
        SELECT @AssignmentExists = 1, @ProductionOrderID = ProductionOrderID 
        FROM TailorAssignment
        WHERE AssignmentID = @TailorAssignmentID AND TailorID = @TailorID;

        IF @AssignmentExists = 0
        BEGIN
            SELECT 'Error' AS Result, 'Assignment not found.' AS Message, 0 AS AllTailorsCompleted;
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Update assignment status
        UPDATE TailorAssignment
        SET Status = @NewStatus,
            CompletedDate = CASE 
                WHEN @NewStatus = 'Complete' THEN GETDATE() 
                ELSE CompletedDate 
            END
        WHERE AssignmentID = @TailorAssignmentID AND TailorID = @TailorID;

        IF @@ROWCOUNT = 0
        BEGIN
            SELECT 'Error' AS Result, 'Assignment not found.' AS Message, 0 AS AllTailorsCompleted;
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Check if all tailors for this production order have completed
        DECLARE @AllCompleted BIT = 0;
        DECLARE @TotalTailors INT = 0;
        DECLARE @CompletedTailors INT = 0;

        SELECT @TotalTailors = COUNT(*)
        FROM TailorAssignment
        WHERE ProductionOrderID = @ProductionOrderID;

        SELECT @CompletedTailors = COUNT(*)
        FROM TailorAssignment
        WHERE ProductionOrderID = @ProductionOrderID AND Status = 'Complete';

        IF @TotalTailors > 0 AND @TotalTailors = @CompletedTailors
        BEGIN
            SET @AllCompleted = 1;
            -- Update production order status to Completed
            UPDATE ProductionOrder
            SET Status = 'Completed',
                ActualEndDate = GETDATE(),
                QuantityCompleted = QuantityOrdered,
                UpdatedDate = GETDATE()
            WHERE ProductionOrderID = @ProductionOrderID;

            -- Auto-create delivery when production is completed
            -- Get a delivery person (first available)
            DECLARE @DeliveryPersonID INT;
            SELECT TOP 1 @DeliveryPersonID = EmployeeID
            FROM Employee
            WHERE Position LIKE '%Delivery%' AND IsActive = 1
            ORDER BY EmployeeID;

            IF @DeliveryPersonID IS NOT NULL
            BEGIN
                -- Create delivery without returning result set
                DECLARE @DeliveryResult TABLE (Result NVARCHAR(50), Message NVARCHAR(500), DeliveryID INT);
                INSERT INTO @DeliveryResult
                EXEC sp_CreateDeliveryFromProduction @ProductionOrderID, @DeliveryPersonID;
            END
        END
        ELSE IF @NewStatus = 'InProgress'
        BEGIN
            -- If any tailor starts, update production order to InProgress
            UPDATE ProductionOrder
            SET Status = 'InProgress',
                UpdatedDate = GETDATE()
            WHERE ProductionOrderID = @ProductionOrderID AND Status = 'Pending';
        END

        COMMIT TRANSACTION;

        SELECT
            'Success' AS Result,
            'Status updated successfully.' AS Message,
            @AllCompleted AS AllTailorsCompleted;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SELECT 'Error' AS Result, ERROR_MESSAGE() AS Message, 0 AS AllTailorsCompleted;
    END CATCH
END
GO
