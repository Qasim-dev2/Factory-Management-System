-- =============================================
-- FIX: Automatic Delivery Creation When Tailor Completes Task
-- Issue: Deliveries not being created because no delivery personnel exist
-- Solution: 1) Add delivery personnel, 2) Improve error handling
-- =============================================

USE GarmentsFactoryDB;
GO

PRINT '🚚 Setting up Automatic Delivery Creation System...';
PRINT '';

-- =============================================
-- STEP 1: Add Delivery Personnel
-- =============================================
PRINT '📦 Step 1: Adding Delivery Personnel...';

-- Check if delivery personnel exist
IF NOT EXISTS (SELECT 1 FROM Employee WHERE Position LIKE '%Delivery%' OR Position LIKE '%Driver%')
BEGIN
    PRINT '   → No delivery personnel found, creating sample delivery staff...';
    
    -- Add 2 delivery persons
    INSERT INTO Employee (FirstName, LastName, Position, Phone, Email, HireDate, Salary, IsActive, CreatedDate)
    VALUES 
        ('Muhammad', 'Khan', 'Delivery Driver', '0300-1234567', 'mkhan.delivery@factory.com', GETDATE(), 30000, 1, GETDATE()),
        ('Ahmed', 'Ali', 'Delivery Person', '0301-7654321', 'aali.delivery@factory.com', GETDATE(), 28000, 1, GETDATE());
    
    PRINT '   ✅ Added 2 delivery personnel';
    
    -- Show added employees
    SELECT EmployeeID, FirstName + ' ' + LastName AS Name, Position, Phone, IsActive
    FROM Employee
    WHERE Position LIKE '%Delivery%' OR Position LIKE '%Driver%'
    ORDER BY EmployeeID DESC;
END
ELSE
BEGIN
    PRINT '   ✅ Delivery personnel already exist';
    
    -- Show existing delivery personnel
    SELECT EmployeeID, FirstName + ' ' + LastName AS Name, Position, Phone, IsActive
    FROM Employee
    WHERE Position LIKE '%Delivery%' OR Position LIKE '%Driver%'
    ORDER BY IsActive DESC, EmployeeID;
END

PRINT '';

-- =============================================
-- STEP 2: Enhance sp_UpdateTailorCompletionStatus with Better Logging
-- =============================================
PRINT '📝 Step 2: Enhancing sp_UpdateTailorCompletionStatus...';

IF OBJECT_ID('sp_UpdateTailorCompletionStatus', 'P') IS NOT NULL
    DROP PROCEDURE sp_UpdateTailorCompletionStatus;
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

            -- ✅ ENHANCED: Auto-create delivery when production is completed
            DECLARE @DeliveryPersonID INT;
            DECLARE @DeliveryCreated INT = 0;
            
            -- Get a delivery person (first available active delivery person)
            SELECT TOP 1 @DeliveryPersonID = EmployeeID
            FROM Employee
            WHERE (Position LIKE '%Delivery%' OR Position LIKE '%Driver%') 
              AND IsActive = 1
            ORDER BY EmployeeID;

            IF @DeliveryPersonID IS NOT NULL
            BEGIN
                -- ✅ Create delivery and capture result
                DECLARE @DeliveryResult TABLE (Result NVARCHAR(50), Message NVARCHAR(500), DeliveryID INT);
                
                INSERT INTO @DeliveryResult
                EXEC sp_CreateDeliveryFromProduction @ProductionOrderID, @DeliveryPersonID;
                
                -- Check if delivery was created successfully
                IF EXISTS (SELECT 1 FROM @DeliveryResult WHERE Result = 'Success')
                BEGIN
                    SET @DeliveryCreated = 1;
                    PRINT '✅ Delivery automatically created for Production Order #' + CAST(@ProductionOrderID AS NVARCHAR);
                END
                ELSE
                BEGIN
                    -- Log warning but don't fail the transaction
                    PRINT '⚠️ Warning: Could not create delivery for Production Order #' + CAST(@ProductionOrderID AS NVARCHAR);
                END
            END
            ELSE
            BEGIN
                -- ✅ WARNING: No delivery personnel available
                PRINT '⚠️ Warning: No delivery personnel available. Delivery not created for Production Order #' + CAST(@ProductionOrderID AS NVARCHAR);
                PRINT '   Action Required: Add employees with "Delivery" or "Driver" in their Position field.';
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
            'Status updated successfully.' + 
            CASE 
                WHEN @AllCompleted = 1 AND @DeliveryPersonID IS NOT NULL 
                THEN ' Production completed and delivery created automatically.' 
                WHEN @AllCompleted = 1 AND @DeliveryPersonID IS NULL
                THEN ' Production completed but no delivery personnel available.'
                ELSE ''
            END AS Message,
            @AllCompleted AS AllTailorsCompleted;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SELECT 'Error' AS Result, ERROR_MESSAGE() AS Message, 0 AS AllTailorsCompleted;
    END CATCH
END
GO

PRINT '✅ sp_UpdateTailorCompletionStatus enhanced with better delivery creation';
PRINT '';

-- =============================================
-- STEP 3: Test the System
-- =============================================
PRINT '🧪 Step 3: Verification...';
PRINT '';

-- Check delivery personnel
PRINT '📋 Active Delivery Personnel:';
SELECT 
    EmployeeID, 
    FirstName + ' ' + LastName AS [Name], 
    Position, 
    Phone,
    CASE WHEN IsActive = 1 THEN 'Active' ELSE 'Inactive' END AS [Status]
FROM Employee
WHERE (Position LIKE '%Delivery%' OR Position LIKE '%Driver%')
  AND IsActive = 1
ORDER BY EmployeeID;

PRINT '';

-- Check if procedure exists
IF OBJECT_ID('sp_UpdateTailorCompletionStatus', 'P') IS NOT NULL
BEGIN
    PRINT '✅ sp_UpdateTailorCompletionStatus exists and ready';
END

IF OBJECT_ID('sp_CreateDeliveryFromProduction', 'P') IS NOT NULL
BEGIN
    PRINT '✅ sp_CreateDeliveryFromProduction exists and ready';
END

PRINT '';
PRINT '========================================';
PRINT '✅ AUTOMATIC DELIVERY CREATION READY!';
PRINT '========================================';
PRINT '';
PRINT '📝 How it works:';
PRINT '   1. Tailor clicks "Complete Task" button';
PRINT '   2. System checks if ALL tailors completed their tasks';
PRINT '   3. If yes: Production Order marked as "Completed"';
PRINT '   4. System automatically finds available delivery person';
PRINT '   5. Delivery record created with status "Pending"';
PRINT '   6. Delivery scheduled 3 days from completion date';
PRINT '';
PRINT '📌 Important Notes:';
PRINT '   • Delivery is created ONLY when ALL tailors complete';
PRINT '   • System assigns first available delivery person';
PRINT '   • If no delivery personnel exist, warning is shown';
PRINT '   • Delivery address taken from SalesOrder or Deal';
PRINT '';
PRINT '🎯 Next Steps:';
PRINT '   1. Have a tailor complete their task in the application';
PRINT '   2. Check Delivery Management to see auto-created delivery';
PRINT '   3. Delivery person can then manage the delivery';
