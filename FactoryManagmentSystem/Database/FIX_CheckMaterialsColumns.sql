-- =============================================
-- FIX: sp_CheckMaterialsForOrder - Add Missing Columns
-- Issue: C# code expects ProductID, QuantityOrdered, RawMaterialID
-- but stored procedure wasn't returning them
-- =============================================

USE GarmentsFactoryDB;
GO

PRINT '🔧 Fixing sp_CheckMaterialsForOrder column mismatch...';

IF OBJECT_ID('sp_CheckMaterialsForOrder', 'P') IS NOT NULL
    DROP PROCEDURE sp_CheckMaterialsForOrder;
GO

CREATE PROCEDURE sp_CheckMaterialsForOrder
    @OrderType NVARCHAR(50),  -- 'SalesOrder' or 'Deal'
    @OrderID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Create temp table for material check
    CREATE TABLE #MaterialCheck (
        ProductID INT,
        ProductName NVARCHAR(100),
        QuantityOrdered INT,
        RawMaterialID INT,
        MaterialName NVARCHAR(100),
        RequiredQuantity DECIMAL(18,2),
        AvailableQuantity DECIMAL(18,2),
        Unit NVARCHAR(20),
        Status NVARCHAR(20)
    );
    
    -- Get products from order
    IF @OrderType = 'SalesOrder'
    BEGIN
        INSERT INTO #MaterialCheck (ProductID, ProductName, QuantityOrdered)
        SELECT 
            soi.ProductID,
            p.ProductName,
            soi.Quantity
        FROM SalesOrderItem soi
        INNER JOIN Product p ON soi.ProductID = p.ProductID
        WHERE soi.SalesOrderID = @OrderID;
    END
    ELSE IF @OrderType = 'Deal'
    BEGIN
        INSERT INTO #MaterialCheck (ProductID, ProductName, QuantityOrdered)
        SELECT 
            di.ProductID,
            p.ProductName,
            di.Quantity
        FROM DealItem di
        INNER JOIN Product p ON di.ProductID = p.ProductID
        WHERE di.DealID = @OrderID;
    END
    
    -- Calculate material requirements
    UPDATE mc
    SET 
        mc.RawMaterialID = pmr.RawMaterialID,
        mc.MaterialName = rm.MaterialName,
        mc.RequiredQuantity = pmr.QuantityRequired * mc.QuantityOrdered,
        mc.AvailableQuantity = rm.Quantity,
        mc.Unit = rm.Unit,
        mc.Status = CASE 
            WHEN rm.Quantity >= (pmr.QuantityRequired * mc.QuantityOrdered) THEN 'Sufficient'
            ELSE 'Insufficient'
        END
    FROM #MaterialCheck mc
    LEFT JOIN ProductMaterialRequirement pmr ON mc.ProductID = pmr.ProductID
    LEFT JOIN RawMaterial rm ON pmr.RawMaterialID = rm.RawMaterialID
    WHERE pmr.RawMaterialID IS NOT NULL;
    
    -- ✅ FIX: Return ALL columns expected by C# code
    SELECT 
        ProductID,           -- ✅ Added
        ProductName,
        QuantityOrdered,     -- ✅ Added
        RawMaterialID,       -- ✅ Added (nullable)
        MaterialName,
        RequiredQuantity,
        AvailableQuantity,
        Unit,
        Status,
        CASE 
            WHEN Status = 'Insufficient' 
            THEN (RequiredQuantity - AvailableQuantity) 
            ELSE 0 
        END AS Shortage
    FROM #MaterialCheck
    WHERE RawMaterialID IS NOT NULL  -- Only show items with material requirements
    ORDER BY Status DESC, ProductName;
    
    -- Return overall status (second result set)
    IF EXISTS (SELECT 1 FROM #MaterialCheck WHERE Status = 'Insufficient')
    BEGIN
        DECLARE @InsufficientCount INT = (SELECT COUNT(*) FROM #MaterialCheck WHERE Status = 'Insufficient');
        SELECT 
            'Insufficient' AS OverallStatus, 
            CAST(@InsufficientCount AS NVARCHAR) + ' material(s) are insufficient for production' AS Message;
    END
    ELSE
    BEGIN
        SELECT 
            'Sufficient' AS OverallStatus, 
            'All materials are available for production' AS Message;
    END
    
    DROP TABLE #MaterialCheck;
END
GO

PRINT '✅ sp_CheckMaterialsForOrder fixed - now returns all required columns';
GO

-- Test the fix
PRINT '';
PRINT '🧪 Testing with Sales Order ID 2...';
EXEC sp_CheckMaterialsForOrder @OrderType = 'SalesOrder', @OrderID = 2;
GO

PRINT '';
PRINT '✅ Fix complete! Material check should now work without errors.';
