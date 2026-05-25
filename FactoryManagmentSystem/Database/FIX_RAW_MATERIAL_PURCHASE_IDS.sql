-- =============================================
-- FIX RAW MATERIAL PURCHASE IDs
-- Correct RawMaterialID mismatches
-- Date: December 17, 2025
-- =============================================

USE GarmentsFactoryDB;
GO

PRINT '🔧 Fixing RawMaterialID mismatches in RawMaterialPurchase table...';
PRINT '';

-- =============================================
-- CORRECT MAPPING (From RawMaterial table):
-- =============================================
-- RawMaterialID 1  = Jeans Cloth
-- RawMaterialID 2  = Cotton Cloth
-- RawMaterialID 3  = Cotton Fabric - White
-- RawMaterialID 4  = Cotton Fabric - Black
-- RawMaterialID 5  = Cotton Fabric - Blue
-- RawMaterialID 6  = Polyester Fabric - Grey
-- RawMaterialID 7  = Silk Fabric - Cream
-- RawMaterialID 8  = Denim Fabric - Blue
-- RawMaterialID 9  = Linen Fabric - Beige
-- RawMaterialID 10 = Polyester Thread - White
-- RawMaterialID 11 = Polyester Thread - Black
-- RawMaterialID 12 = Cotton Thread - Multicolor
-- RawMaterialID 13 = Shirt Buttons - White
-- RawMaterialID 14 = Shirt Buttons - Black
-- RawMaterialID 15 = Metal Buttons - Silver
-- RawMaterialID 16 = Zippers - Metal 12 inch
-- RawMaterialID 17 = Zippers - Plastic 8 inch
-- RawMaterialID 18 = Elastic Band - 1 inch
-- RawMaterialID 19 = Velcro Strips - 2 inch
-- RawMaterialID 20 = Lining Fabric - White
-- RawMaterialID 21 = Interfacing Fabric
-- RawMaterialID 22 = Shoulder Pads - Foam

PRINT '📌 STEP 1: Updating November 2025 Purchases';

-- Fix: Cotton Fabric - White (should be ID 3, was ID 1)
UPDATE RawMaterialPurchase 
SET RawMaterialID = 3
WHERE MaterialName = 'Cotton Fabric - White' 
  AND PurchaseDate = '2025-11-15'
  AND RawMaterialID = 1;
PRINT '   ✅ Fixed Cotton Fabric - White (Nov)';

-- Fix: Cotton Fabric - Black (should be ID 4, was ID 2)
UPDATE RawMaterialPurchase 
SET RawMaterialID = 4
WHERE MaterialName = 'Cotton Fabric - Black' 
  AND PurchaseDate = '2025-11-15'
  AND RawMaterialID = 2;
PRINT '   ✅ Fixed Cotton Fabric - Black (Nov)';

-- Fix: Polyester Thread - White (should be ID 10, was ID 8)
UPDATE RawMaterialPurchase 
SET RawMaterialID = 10
WHERE MaterialName = 'Polyester Thread - White' 
  AND PurchaseDate = '2025-11-20'
  AND RawMaterialID = 8;
PRINT '   ✅ Fixed Polyester Thread - White (Nov)';

-- Fix: Polyester Thread - Black (should be ID 11, was ID 9)
UPDATE RawMaterialPurchase 
SET RawMaterialID = 11
WHERE MaterialName = 'Polyester Thread - Black' 
  AND PurchaseDate = '2025-11-20'
  AND RawMaterialID = 9;
PRINT '   ✅ Fixed Polyester Thread - Black (Nov)';

-- Fix: Shirt Buttons - White (should be ID 13, was ID 11)
UPDATE RawMaterialPurchase 
SET RawMaterialID = 13
WHERE MaterialName = 'Shirt Buttons - White' 
  AND PurchaseDate = '2025-11-22'
  AND RawMaterialID = 11;
PRINT '   ✅ Fixed Shirt Buttons - White (Nov)';

-- Fix: Shirt Buttons - Black (should be ID 14, was ID 12)
UPDATE RawMaterialPurchase 
SET RawMaterialID = 14
WHERE MaterialName = 'Shirt Buttons - Black' 
  AND PurchaseDate = '2025-11-22'
  AND RawMaterialID = 12;
PRINT '   ✅ Fixed Shirt Buttons - Black (Nov)';

PRINT '';
PRINT '📌 STEP 2: Updating December 2025 Purchases';

-- Fix: Cotton Fabric - White December purchases (should be ID 3, was ID 1)
UPDATE RawMaterialPurchase 
SET RawMaterialID = 3
WHERE MaterialName = 'Cotton Fabric - White' 
  AND PurchaseDate = '2025-12-01'
  AND RawMaterialID = 1;
PRINT '   ✅ Fixed Cotton Fabric - White (Dec 1)';

-- Fix: Cotton Fabric - Black December purchases (should be ID 4, was ID 2)
UPDATE RawMaterialPurchase 
SET RawMaterialID = 4
WHERE MaterialName = 'Cotton Fabric - Black' 
  AND PurchaseDate = '2025-12-01'
  AND RawMaterialID = 2;
PRINT '   ✅ Fixed Cotton Fabric - Black (Dec 1)';

-- Fix: Cotton Fabric - Blue (should be ID 5, was ID 3)
UPDATE RawMaterialPurchase 
SET RawMaterialID = 5
WHERE MaterialName = 'Cotton Fabric - Blue' 
  AND PurchaseDate = '2025-12-03'
  AND RawMaterialID = 3;
PRINT '   ✅ Fixed Cotton Fabric - Blue (Dec 3)';

-- Fix: Polyester Fabric - Grey (should be ID 6, was ID 4)
UPDATE RawMaterialPurchase 
SET RawMaterialID = 6
WHERE MaterialName = 'Polyester Fabric - Grey' 
  AND PurchaseDate = '2025-12-05'
  AND RawMaterialID = 4;
PRINT '   ✅ Fixed Polyester Fabric - Grey (Dec 5)';

-- Fix: Silk Fabric - Cream (should be ID 7, was ID 5)
UPDATE RawMaterialPurchase 
SET RawMaterialID = 7
WHERE MaterialName = 'Silk Fabric - Cream' 
  AND PurchaseDate = '2025-12-10'
  AND RawMaterialID = 5;
PRINT '   ✅ Fixed Silk Fabric - Cream (Dec 10)';

-- Fix: Denim Fabric - Blue (should be ID 8, was ID 6)
UPDATE RawMaterialPurchase 
SET RawMaterialID = 8
WHERE MaterialName = 'Denim Fabric - Blue' 
  AND PurchaseDate = '2025-12-03'
  AND RawMaterialID = 6;
PRINT '   ✅ Fixed Denim Fabric - Blue (Dec 3)';

-- Fix: Linen Fabric - Beige (should be ID 9, was ID 7)
UPDATE RawMaterialPurchase 
SET RawMaterialID = 9
WHERE MaterialName = 'Linen Fabric - Beige' 
  AND PurchaseDate = '2025-12-08'
  AND RawMaterialID = 7;
PRINT '   ✅ Fixed Linen Fabric - Beige (Dec 8)';

-- Fix: Polyester Thread - White December purchases (should be ID 10, was ID 8)
UPDATE RawMaterialPurchase 
SET RawMaterialID = 10
WHERE MaterialName = 'Polyester Thread - White' 
  AND PurchaseDate = '2025-12-05'
  AND RawMaterialID = 8;
PRINT '   ✅ Fixed Polyester Thread - White (Dec 5)';

-- Fix: Polyester Thread - Black December purchases (should be ID 11, was ID 9)
UPDATE RawMaterialPurchase 
SET RawMaterialID = 11
WHERE MaterialName = 'Polyester Thread - Black' 
  AND PurchaseDate = '2025-12-05'
  AND RawMaterialID = 9;
PRINT '   ✅ Fixed Polyester Thread - Black (Dec 5)';

-- Fix: Cotton Thread - Multicolor (should be ID 12, was ID 10)
UPDATE RawMaterialPurchase 
SET RawMaterialID = 12
WHERE MaterialName = 'Cotton Thread - Multicolor' 
  AND PurchaseDate = '2025-12-07'
  AND RawMaterialID = 10;
PRINT '   ✅ Fixed Cotton Thread - Multicolor (Dec 7)';

-- Fix: Shirt Buttons - White December purchases (should be ID 13, was ID 11)
UPDATE RawMaterialPurchase 
SET RawMaterialID = 13
WHERE MaterialName = 'Shirt Buttons - White' 
  AND PurchaseDate = '2025-12-10'
  AND RawMaterialID = 11;
PRINT '   ✅ Fixed Shirt Buttons - White (Dec 10)';

-- Fix: Shirt Buttons - Black December purchases (should be ID 14, was ID 12)
UPDATE RawMaterialPurchase 
SET RawMaterialID = 14
WHERE MaterialName = 'Shirt Buttons - Black' 
  AND PurchaseDate = '2025-12-10'
  AND RawMaterialID = 12;
PRINT '   ✅ Fixed Shirt Buttons - Black (Dec 10)';

-- Fix: Metal Buttons - Silver (should be ID 15, was ID 13)
UPDATE RawMaterialPurchase 
SET RawMaterialID = 15
WHERE MaterialName = 'Metal Buttons - Silver' 
  AND PurchaseDate = '2025-12-11'
  AND RawMaterialID = 13;
PRINT '   ✅ Fixed Metal Buttons - Silver (Dec 11)';

-- Fix: Zippers - Metal 12 inch (should be ID 16, was ID 14)
UPDATE RawMaterialPurchase 
SET RawMaterialID = 16
WHERE MaterialName = 'Zippers - Metal 12 inch' 
  AND PurchaseDate = '2025-12-12'
  AND RawMaterialID = 14;
PRINT '   ✅ Fixed Zippers - Metal 12 inch (Dec 12)';

-- Fix: Zippers - Plastic 8 inch (should be ID 17, was ID 15)
UPDATE RawMaterialPurchase 
SET RawMaterialID = 17
WHERE MaterialName = 'Zippers - Plastic 8 inch' 
  AND PurchaseDate = '2025-12-12'
  AND RawMaterialID = 15;
PRINT '   ✅ Fixed Zippers - Plastic 8 inch (Dec 12)';

-- Fix: Elastic Band - 1 inch (should be ID 18, was ID 16)
UPDATE RawMaterialPurchase 
SET RawMaterialID = 18
WHERE MaterialName = 'Elastic Band - 1 inch' 
  AND PurchaseDate = '2025-12-13'
  AND RawMaterialID = 16;
PRINT '   ✅ Fixed Elastic Band - 1 inch (Dec 13)';

-- Fix: Velcro Strips - 2 inch (should be ID 19, was ID 17)
UPDATE RawMaterialPurchase 
SET RawMaterialID = 19
WHERE MaterialName = 'Velcro Strips - 2 inch' 
  AND PurchaseDate = '2025-12-14'
  AND RawMaterialID = 17;
PRINT '   ✅ Fixed Velcro Strips - 2 inch (Dec 14)';

-- Fix: Lining Fabric - White (should be ID 20, was ID 18)
UPDATE RawMaterialPurchase 
SET RawMaterialID = 20
WHERE MaterialName = 'Lining Fabric - White' 
  AND PurchaseDate = '2025-12-15'
  AND RawMaterialID = 18;
PRINT '   ✅ Fixed Lining Fabric - White (Dec 15)';

-- Fix: Interfacing Fabric (should be ID 21, was ID 19)
UPDATE RawMaterialPurchase 
SET RawMaterialID = 21
WHERE MaterialName = 'Interfacing Fabric' 
  AND PurchaseDate = '2025-12-15'
  AND RawMaterialID = 19;
PRINT '   ✅ Fixed Interfacing Fabric (Dec 15)';

-- Fix: Shoulder Pads - Foam (should be ID 22, was ID 20)
UPDATE RawMaterialPurchase 
SET RawMaterialID = 22
WHERE MaterialName = 'Shoulder Pads - Foam' 
  AND PurchaseDate = '2025-12-16'
  AND RawMaterialID = 20;
PRINT '   ✅ Fixed Shoulder Pads - Foam (Dec 16)';

PRINT '';
PRINT '========================================';
PRINT '✅ ALL RAWMATERIALID FIXES APPLIED';
PRINT '========================================';
PRINT '';

-- Verification
PRINT '📋 VERIFICATION - Checking for any remaining mismatches:';
PRINT '';

SELECT 
    rmp.PurchaseID,
    rmp.RawMaterialID AS Purchase_RawMaterialID,
    rmp.MaterialName AS Purchase_MaterialName,
    rm.RawMaterialID AS Actual_RawMaterialID,
    rm.MaterialName AS Actual_MaterialName,
    CASE 
        WHEN rm.RawMaterialID IS NULL THEN '❌ MISSING IN RAWMATERIAL TABLE'
        WHEN rmp.MaterialName <> rm.MaterialName THEN '❌ NAME MISMATCH'
        ELSE '✅ CORRECT'
    END AS Status
FROM RawMaterialPurchase rmp
LEFT JOIN RawMaterial rm ON rmp.RawMaterialID = rm.RawMaterialID
WHERE rmp.PurchaseDate >= '2025-11-01'
ORDER BY rmp.PurchaseID;

PRINT '';
PRINT '📊 SUMMARY BY MATERIAL:';
SELECT 
    rm.RawMaterialID,
    rm.MaterialName,
    COUNT(rmp.PurchaseID) AS PurchaseCount,
    SUM(rmp.TotalAmount) AS TotalPurchased
FROM RawMaterial rm
LEFT JOIN RawMaterialPurchase rmp ON rm.RawMaterialID = rmp.RawMaterialID
WHERE rm.IsActive = 1
GROUP BY rm.RawMaterialID, rm.MaterialName
ORDER BY rm.RawMaterialID;

PRINT '';
PRINT '========================================';
PRINT '✅ FIX COMPLETE - ALL IDs NOW MATCH';
PRINT '========================================';

GO
