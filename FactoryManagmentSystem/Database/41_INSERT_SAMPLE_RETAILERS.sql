-- =============================================
-- INSERT SAMPLE RETAILERS
-- Complete data with all attributes filled
-- Date: December 17, 2025
-- =============================================

USE GarmentsFactoryDB;
GO

PRINT '======================================='
PRINT 'INSERTING SAMPLE RETAILERS'
PRINT '======================================='

-- Check if retailers already exist
IF EXISTS (SELECT 1 FROM Retailer WHERE CompanyName IN ('Fashion Hub Lahore', 'Elite Garments Karachi'))
BEGIN
    PRINT '⚠️ Sample retailers already exist. Skipping insert.'
    PRINT 'To re-insert, delete existing retailers first.'
END
ELSE
BEGIN
    -- Insert 15 diverse retailers across Pakistan
    INSERT INTO Retailer (
        CompanyName, 
        ContactPerson, 
        Phone, 
        Email, 
        AlternativePhone, 
        Address, 
        City, 
        Province, 
        PostalCode, 
        Status, 
        IsActive, 
        CreatedDate, 
        UpdatedDate
    )
    VALUES
    -- Lahore Retailers
    (
        'Fashion Hub Lahore',
        'Ahmed Hassan',
        '0300-1234567',
        'info@fashionhublahore.com',
        '042-35123456',
        'Main Boulevard, Gulberg III',
        'Lahore',
        'Punjab',
        '54000',
        'Active',
        1,
        GETDATE(),
        GETDATE()
    ),
    (
        'Royal Textile Trading Co',
        'Muhammad Saeed',
        '0321-9876543',
        'sales@royaltextile.pk',
        '042-37654321',
        'Hall Road, Anarkali Bazaar',
        'Lahore',
        'Punjab',
        '54010',
        'Active',
        1,
        GETDATE(),
        GETDATE()
    ),
    (
        'Elite Garments Johar Town',
        'Fatima Khan',
        '0313-5551234',
        'elitegarments@gmail.com',
        '042-35771122',
        'Block H, Johar Town',
        'Lahore',
        'Punjab',
        '54782',
        'Active',
        1,
        GETDATE(),
        GETDATE()
    ),

    -- Karachi Retailers
    (
        'Elite Garments Karachi',
        'Imran Ali',
        '0333-7654321',
        'karachi@elitegarments.pk',
        '021-35678901',
        'Tariq Road, PECHS',
        'Karachi',
        'Sindh',
        '75400',
        'Active',
        1,
        GETDATE(),
        GETDATE()
    ),
    (
        'Metro Fashion Store',
        'Ayesha Siddiqui',
        '0345-1122334',
        'metro.fashion@hotmail.com',
        '021-32123456',
        'Clifton Block 2, Main Khayaban-e-Roomi',
        'Karachi',
        'Sindh',
        '75600',
        'Active',
        1,
        GETDATE(),
        GETDATE()
    ),
    (
        'Saddar Wholesale Textiles',
        'Rashid Mahmood',
        '0300-9988776',
        'saddar.textiles@yahoo.com',
        '021-32445566',
        'Empress Market, Saddar',
        'Karachi',
        'Sindh',
        '74400',
        'Active',
        1,
        GETDATE(),
        GETDATE()
    ),

    -- Islamabad/Rawalpindi Retailers
    (
        'Capital Garments House',
        'Usman Tariq',
        '0331-4567890',
        'capital.garments@gmail.com',
        '051-5123456',
        'F-7 Markaz, Jinnah Super',
        'Islamabad',
        'Islamabad Capital Territory',
        '44000',
        'Active',
        1,
        GETDATE(),
        GETDATE()
    ),
    (
        'Pindi Fashion Gallery',
        'Zainab Aslam',
        '0322-7778889',
        'pindi.fashion@outlook.com',
        '051-5567788',
        'Murree Road, Commercial Market',
        'Rawalpindi',
        'Punjab',
        '46000',
        'Active',
        1,
        GETDATE(),
        GETDATE()
    ),

    -- Faisalabad Retailers
    (
        'Manchester Textile Hub',
        'Shahid Iqbal',
        '0305-6667778',
        'manchester.fsd@gmail.com',
        '041-8765432',
        'Ghulam Muhammad Abad, D-Ground',
        'Faisalabad',
        'Punjab',
        '38000',
        'Active',
        1,
        GETDATE(),
        GETDATE()
    ),
    (
        'Punjab Garments Corporation',
        'Bilal Ahmed',
        '0323-4445556',
        'punjab.garments@hotmail.com',
        '041-8556677',
        'Rail Bazaar, Main Market',
        'Faisalabad',
        'Punjab',
        '38100',
        'Active',
        1,
        GETDATE(),
        GETDATE()
    ),

    -- Multan Retailer
    (
        'Southern Textile Traders',
        'Kashif Mahmood',
        '0306-3332221',
        'southern.multan@yahoo.com',
        '061-4556677',
        'Hussain Agahi Bazaar',
        'Multan',
        'Punjab',
        '60000',
        'Active',
        1,
        GETDATE(),
        GETDATE()
    ),

    -- Peshawar Retailer
    (
        'Khyber Fashion Market',
        'Naveed Shah',
        '0334-2221110',
        'khyber.fashion@gmail.com',
        '091-5667788',
        'Qissa Khwani Bazaar',
        'Peshawar',
        'Khyber Pakhtunkhwa',
        '25000',
        'Active',
        1,
        GETDATE(),
        GETDATE()
    ),

    -- Quetta Retailer
    (
        'Balochistan Garments Co',
        'Hamza Kakar',
        '0333-9998887',
        'balochistan.garments@hotmail.com',
        '081-2887766',
        'Jinnah Road, Liaquat Bazaar',
        'Quetta',
        'Balochistan',
        '87300',
        'Active',
        1,
        GETDATE(),
        GETDATE()
    ),

    -- Sialkot Retailer
    (
        'Export Quality Garments',
        'Tariq Hussain',
        '0300-5554443',
        'export.quality@gmail.com',
        '052-4556677',
        'Paris Road, Cantt Area',
        'Sialkot',
        'Punjab',
        '51310',
        'Active',
        1,
        GETDATE(),
        GETDATE()
    ),

    -- Inactive Retailer (for testing)
    (
        'Closed Fashion Store',
        'Former Owner',
        '0300-0000000',
        'closed.store@test.com',
        '042-00000000',
        'Old Location, Archived',
        'Lahore',
        'Punjab',
        '54000',
        'Inactive',
        0,
        DATEADD(YEAR, -2, GETDATE()),
        GETDATE()
    );

    PRINT '✓ 15 sample retailers inserted successfully!'
    PRINT ''
END

GO

PRINT '======================================='
PRINT 'RETAILER SUMMARY'
PRINT '======================================='

-- Display summary
SELECT 
    COUNT(*) AS TotalRetailers,
    SUM(CASE WHEN IsActive = 1 THEN 1 ELSE 0 END) AS ActiveRetailers,
    SUM(CASE WHEN IsActive = 0 THEN 1 ELSE 0 END) AS InactiveRetailers
FROM Retailer;

PRINT ''
PRINT 'Active Retailers by City:'
SELECT 
    City,
    Province,
    COUNT(*) AS RetailerCount
FROM Retailer
WHERE IsActive = 1
GROUP BY City, Province
ORDER BY COUNT(*) DESC, City;

PRINT ''
PRINT '======================================='
PRINT 'SAMPLE RETAILERS LIST'
PRINT '======================================='

-- Display all retailers
SELECT 
    RetailerID,
    CompanyName,
    ContactPerson,
    Phone,
    City,
    Province,
    Status,
    IsActive
FROM Retailer
ORDER BY RetailerID;

GO

PRINT ''
PRINT '======================================='
PRINT 'DATA VALIDATION CHECK'
PRINT '======================================='

-- Check for NULL values (should be zero for required fields)
SELECT 
    'Retailers with NULL CompanyName' AS Issue,
    COUNT(*) AS Count
FROM Retailer
WHERE CompanyName IS NULL;

SELECT 
    'Retailers with NULL ContactPerson' AS Issue,
    COUNT(*) AS Count
FROM Retailer
WHERE ContactPerson IS NULL;

SELECT 
    'Retailers with NULL Phone' AS Issue,
    COUNT(*) AS Count
FROM Retailer
WHERE Phone IS NULL;

SELECT 
    'Retailers with NULL Email' AS Issue,
    COUNT(*) AS Count
FROM Retailer
WHERE Email IS NULL;

SELECT 
    'Retailers with NULL City' AS Issue,
    COUNT(*) AS Count
FROM Retailer
WHERE City IS NULL;

PRINT ''
PRINT '✅ ALL ATTRIBUTES FILLED - NO NULL VALUES!'
PRINT '======================================='
PRINT 'SAMPLE RETAILERS INSERTION COMPLETE'
PRINT '======================================='

GO
