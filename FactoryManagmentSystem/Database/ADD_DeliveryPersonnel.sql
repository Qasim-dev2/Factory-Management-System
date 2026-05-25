-- =============================================
-- FIX: Add Delivery Personnel for Automatic Delivery
-- =============================================

USE GarmentsFactoryDB;
GO

PRINT '🚚 Adding Delivery Personnel...';

-- Check if delivery personnel exist
IF NOT EXISTS (SELECT 1 FROM Employee WHERE Position LIKE '%Delivery%' OR Position LIKE '%Driver%')
BEGIN
    -- Get Delivery Department ID
    DECLARE @DeliveryDeptID INT;
    SELECT @DeliveryDeptID = DepartmentID FROM Department WHERE DepartmentName = 'Delivery';
    
    IF @DeliveryDeptID IS NULL
    BEGIN
        -- Create Delivery department if it doesn't exist
        INSERT INTO Department (DepartmentName, Description, CreatedDate, IsActive)
        VALUES ('Delivery', 'Responsible for order delivery and logistics', GETDATE(), 1);
        SET @DeliveryDeptID = SCOPE_IDENTITY();
    END
    
    -- Add 2 delivery persons
    INSERT INTO Employee (FirstName, LastName, Position, Phone, Email, DepartmentID, RoleID, JoinDate, Salary, IsActive, CreatedDate)
    VALUES 
        ('Muhammad', 'Khan', 'Delivery Driver', '0300-1234567', 'mkhan@factory.com', @DeliveryDeptID, 3, GETDATE(), 30000, 1, GETDATE()),
        ('Ahmed', 'Ali', 'Delivery Person', '0301-7654321', 'aali@factory.com', @DeliveryDeptID, 3, GETDATE(), 28000, 1, GETDATE());
    
    PRINT '✅ Added 2 delivery personnel';
END
ELSE
BEGIN
    PRINT '✅ Delivery personnel already exist';
END

-- Show delivery personnel
PRINT '';
PRINT '📋 Active Delivery Personnel:';
SELECT 
    EmployeeID, 
    FirstName + ' ' + LastName AS [Name], 
    Position, 
    Phone,
    CASE WHEN IsActive = 1 THEN 'Active' ELSE 'Inactive' END AS [Status]
FROM Employee
WHERE (Position LIKE '%Delivery%' OR Position LIKE '%Driver%')
ORDER BY IsActive DESC, EmployeeID;

PRINT '';
PRINT '✅ Delivery personnel ready for automatic delivery creation!';
PRINT '';
PRINT '📝 How it works now:';
PRINT '   1. When ALL tailors complete their tasks on a production order';
PRINT '   2. System automatically creates a delivery record';
PRINT '   3. Assigns to first available delivery person';
PRINT '   4. Delivery status set to "Pending"';
PRINT '   5. Scheduled for 3 days after production completion';
GO
