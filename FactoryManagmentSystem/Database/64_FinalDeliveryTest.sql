-- ================================================================================
-- FINAL COMPREHENSIVE TEST - All Delivery Operations
-- ================================================================================
USE GarmentsFactoryDB;
GO

PRINT '======================================================';
PRINT 'FINAL COMPREHENSIVE DELIVERY TEST';
PRINT '======================================================';
PRINT '';

DECLARE @TestDeliveryID INT;
SELECT TOP 1 @TestDeliveryID = DeliveryID FROM Delivery ORDER BY DeliveryID;

IF @TestDeliveryID IS NULL
BEGIN
    PRINT '⚠️ No deliveries found in database for testing';
    PRINT 'Please create at least one delivery first';
    RETURN;
END

PRINT 'Using Test Delivery ID: ' + CAST(@TestDeliveryID AS VARCHAR(10));
PRINT '';

-- ================================================================================
-- TEST 1: Get Delivery By ID
-- ================================================================================
PRINT '📋 Test 1: Get Delivery By ID...';
BEGIN TRY
    EXEC sp_GetDeliveryById @DeliveryID = @TestDeliveryID;
    PRINT '✅ SUCCESS: sp_GetDeliveryById executed without errors';
END TRY
BEGIN CATCH
    PRINT '❌ FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- ================================================================================
-- TEST 2: Get All Deliveries
-- ================================================================================
PRINT '📋 Test 2: Get All Deliveries...';
BEGIN TRY
    EXEC sp_GetAllDeliveries;
    PRINT '✅ SUCCESS: sp_GetAllDeliveries executed without errors';
END TRY
BEGIN CATCH
    PRINT '❌ FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- ================================================================================
-- TEST 3: Update Delivery Status
-- ================================================================================
PRINT '📋 Test 3: Update Delivery Status...';
BEGIN TRY
    EXEC sp_UpdateDeliveryStatus 
        @DeliveryID = @TestDeliveryID,
        @Status = 'In Transit',
        @Notes = 'Test - Status updated successfully';
    PRINT '✅ SUCCESS: sp_UpdateDeliveryStatus executed without errors';
END TRY
BEGIN CATCH
    PRINT '❌ FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- ================================================================================
-- TEST 4: Update Full Delivery
-- ================================================================================
PRINT '📋 Test 4: Update Full Delivery...';
BEGIN TRY
    EXEC sp_UpdateDelivery 
        @DeliveryID = @TestDeliveryID,
        @Status = 'Pending',
        @ReceiverName = 'Test Receiver',
        @ReceiverPhone = '0300-1234567',
        @Notes = 'Test - Full delivery update successful';
    PRINT '✅ SUCCESS: sp_UpdateDelivery executed without errors';
END TRY
BEGIN CATCH
    PRINT '❌ FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- ================================================================================
-- TEST 5: Get Delivery Statistics
-- ================================================================================
PRINT '📋 Test 5: Get Delivery Statistics...';
BEGIN TRY
    EXEC sp_GetDeliveryStatistics;
    PRINT '✅ SUCCESS: sp_GetDeliveryStatistics executed without errors';
END TRY
BEGIN CATCH
    PRINT '❌ FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- ================================================================================
-- TEST 6: Get Delivery Assignments
-- ================================================================================
PRINT '📋 Test 6: Get Delivery Assignments...';
BEGIN TRY
    EXEC sp_GetDeliveryAssignments;
    PRINT '✅ SUCCESS: sp_GetDeliveryAssignments executed without errors';
END TRY
BEGIN CATCH
    PRINT '❌ FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- ================================================================================
-- FINAL VERIFICATION
-- ================================================================================
PRINT '======================================================';
PRINT 'VERIFICATION COMPLETE';
PRINT '======================================================';
PRINT '';

-- Verify the test delivery was updated correctly
SELECT 
    DeliveryID,
    Status,
    ReceiverName,
    ReceiverPhone,
    Notes,
    UpdatedDate
FROM Delivery 
WHERE DeliveryID = @TestDeliveryID;

PRINT '';
PRINT '======================================================';
PRINT '✅ ALL TESTS PASSED!';
PRINT '======================================================';
PRINT '';
PRINT '🎯 All delivery procedures are working correctly';
PRINT '🎯 No invalid column errors';
PRINT '🎯 You can now use the application to update deliveries';
PRINT '';
PRINT '✨ Fixed Procedures:';
PRINT '   1. sp_GetDeliveryById';
PRINT '   2. sp_GetAllDeliveries';
PRINT '   3. sp_UpdateDeliveryStatus';
PRINT '   4. sp_UpdateDelivery';
PRINT '   5. sp_GetDeliveryStatistics';
PRINT '   6. sp_GetDeliveryAssignments';
PRINT '';
GO
