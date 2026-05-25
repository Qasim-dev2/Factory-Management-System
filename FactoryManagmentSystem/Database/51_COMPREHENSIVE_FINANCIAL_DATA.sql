-- =============================================
-- COMPREHENSIVE FINANCIAL SAMPLE DATA
-- Creates realistic profit/loss data for Sept 2025 - Dec 2025
-- Total Monthly Salary: Rs. 748,000 (19 employees)
-- =============================================

USE GarmentsFactoryDB;
GO

SET NOCOUNT ON;

DECLARE @TotalSalary DECIMAL(18,2) = 748000.00;
DECLARE @EmployeeCount INT = 19;

PRINT '========================================';
PRINT 'CREATING COMPREHENSIVE FINANCIAL DATA';
PRINT 'Monthly Salary: Rs. ' + CAST(@TotalSalary AS VARCHAR);
PRINT 'Employee Count: ' + CAST(@EmployeeCount AS VARCHAR);
PRINT '========================================';
PRINT '';

-- =============================================
-- STEP 1: Update Salary Payments (Sept - Dec 2025)
-- =============================================
PRINT '1. Updating Salary Payment Records...';

UPDATE SalaryPayment SET 
    TotalAmount = @TotalSalary,
    EmployeeCount = @EmployeeCount,
    Notes = 'Monthly salaries paid to ' + CAST(@EmployeeCount AS VARCHAR) + ' employees'
WHERE PaymentMonth BETWEEN 9 AND 12 AND PaymentYear = 2025;

-- Add January 2026 payment (already exists)
UPDATE SalaryPayment SET 
    TotalAmount = @TotalSalary,
    EmployeeCount = @EmployeeCount,
    Notes = 'Monthly salaries paid to ' + CAST(@EmployeeCount AS VARCHAR) + ' employees'
WHERE PaymentMonth = 1 AND PaymentYear = 2026;

PRINT '   ✓ Updated salary payments';
PRINT '';

-- =============================================
-- STEP 2: Insert Raw Material Purchases
-- =============================================
PRINT '2. Creating Raw Material Purchase Records...';

-- Delete existing sample purchases
DELETE FROM RawMaterialPurchase WHERE PurchaseID > 0;

-- September 2025 Purchases
INSERT INTO RawMaterialPurchase (RawMaterialID, MaterialName, PurchaseDate, Quantity, Unit, UnitPrice, TotalAmount, SupplierName, InvoiceNumber, Notes, CreatedDate)
VALUES 
(1, 'Cotton Fabric', '2025-09-05', 500, 'Meters', 250, 125000, 'Textile Mills Lahore', 'INV-SEP-001', 'Premium cotton for suits', GETDATE()),
(2, 'Silk Fabric', '2025-09-10', 200, 'Meters', 800, 160000, 'Silk House Faisalabad', 'INV-SEP-002', 'High quality silk', GETDATE()),
(3, 'Buttons', '2025-09-15', 5000, 'Pieces', 5, 25000, 'Button World', 'INV-SEP-003', 'Mixed buttons', GETDATE()),
(4, 'Thread', '2025-09-18', 1000, 'Spools', 50, 50000, 'Thread Factory', 'INV-SEP-004', 'Various colors', GETDATE());

-- October 2025 Purchases
INSERT INTO RawMaterialPurchase (RawMaterialID, MaterialName, PurchaseDate, Quantity, Unit, UnitPrice, TotalAmount, SupplierName, InvoiceNumber, Notes, CreatedDate)
VALUES 
(1, 'Cotton Fabric', '2025-10-03', 600, 'Meters', 250, 150000, 'Textile Mills Lahore', 'INV-OCT-001', 'Bulk order cotton', GETDATE()),
(2, 'Wool Fabric', '2025-10-12', 300, 'Meters', 600, 180000, 'Wool Traders Karachi', 'INV-OCT-002', 'Winter collection', GETDATE()),
(5, 'Zippers', '2025-10-20', 2000, 'Pieces', 20, 40000, 'Zipper Hub', 'INV-OCT-003', 'Premium zippers', GETDATE());

-- November 2025 Purchases
INSERT INTO RawMaterialPurchase (RawMaterialID, MaterialName, PurchaseDate, Quantity, Unit, UnitPrice, TotalAmount, SupplierName, InvoiceNumber, Notes, CreatedDate)
VALUES 
(1, 'Cotton Fabric', '2025-11-05', 800, 'Meters', 250, 200000, 'Textile Mills Lahore', 'INV-NOV-001', 'Large order - winter season', GETDATE()),
(2, 'Silk Fabric', '2025-11-15', 250, 'Meters', 800, 200000, 'Silk House Faisalabad', 'INV-NOV-002', 'Wedding season stock', GETDATE()),
(3, 'Buttons', '2025-11-20', 8000, 'Pieces', 5, 40000, 'Button World', 'INV-NOV-003', 'Bulk buttons', GETDATE());

-- December 2025 Purchases
INSERT INTO RawMaterialPurchase (RawMaterialID, MaterialName, PurchaseDate, Quantity, Unit, UnitPrice, TotalAmount, SupplierName, InvoiceNumber, Notes, CreatedDate)
VALUES 
(1, 'Cotton Fabric', '2025-12-01', 700, 'Meters', 260, 182000, 'Textile Mills Lahore', 'INV-DEC-001', 'December stock', GETDATE()),
(2, 'Premium Wool', '2025-12-05', 400, 'Meters', 700, 280000, 'Wool Traders Karachi', 'INV-DEC-002', 'Premium winter collection', GETDATE()),
(4, 'Thread', '2025-12-10', 1500, 'Spools', 55, 82500, 'Thread Factory', 'INV-DEC-003', 'Restocking threads', GETDATE());

PRINT '   ✓ Created 14 raw material purchases';
PRINT '';

-- =============================================
-- STEP 3: Insert Miscellaneous Expenses
-- =============================================
PRINT '3. Creating Misc Expense Records...';

DELETE FROM MiscExpense WHERE ExpenseID > 0;

-- September 2025 Expenses
INSERT INTO MiscExpense (ExpenseDate, Amount, Category, Description, PaidTo, PaymentMethod, ReceiptNumber, CreatedDate)
VALUES 
('2025-09-05', 35000, 'Utilities', 'Electricity Bill September', 'K-Electric', 'Bank Transfer', 'UTIL-SEP-001', GETDATE()),
('2025-09-10', 15000, 'Utilities', 'Gas Bill September', 'Sui Gas', 'Bank Transfer', 'UTIL-SEP-002', GETDATE()),
('2025-09-15', 25000, 'Rent', 'Workshop Rent September', 'Landlord Ahmed', 'Cash', 'RENT-SEP-001', GETDATE()),
('2025-09-20', 8000, 'Transport', 'Delivery Vehicle Fuel', 'Shell Station', 'Cash', 'TRANS-SEP-001', GETDATE());

-- October 2025 Expenses
INSERT INTO MiscExpense (ExpenseDate, Amount, Category, Description, PaidTo, PaymentMethod, ReceiptNumber, CreatedDate)
VALUES 
('2025-10-05', 38000, 'Utilities', 'Electricity Bill October', 'K-Electric', 'Bank Transfer', 'UTIL-OCT-001', GETDATE()),
('2025-10-10', 16000, 'Utilities', 'Gas Bill October', 'Sui Gas', 'Bank Transfer', 'UTIL-OCT-002', GETDATE()),
('2025-10-15', 25000, 'Rent', 'Workshop Rent October', 'Landlord Ahmed', 'Cash', 'RENT-OCT-001', GETDATE()),
('2025-10-22', 12000, 'Maintenance', 'Sewing Machine Repair', 'Tech Repairs', 'Cash', 'MAINT-OCT-001', GETDATE()),
('2025-10-25', 9000, 'Transport', 'Delivery Vehicle Fuel', 'Shell Station', 'Cash', 'TRANS-OCT-001', GETDATE());

-- November 2025 Expenses
INSERT INTO MiscExpense (ExpenseDate, Amount, Category, Description, PaidTo, PaymentMethod, ReceiptNumber, CreatedDate)
VALUES 
('2025-11-05', 42000, 'Utilities', 'Electricity Bill November', 'K-Electric', 'Bank Transfer', 'UTIL-NOV-001', GETDATE()),
('2025-11-10', 18000, 'Utilities', 'Gas Bill November', 'Sui Gas', 'Bank Transfer', 'UTIL-NOV-002', GETDATE()),
('2025-11-15', 25000, 'Rent', 'Workshop Rent November', 'Landlord Ahmed', 'Cash', 'RENT-NOV-001', GETDATE()),
('2025-11-18', 15000, 'Marketing', 'Social Media Ads', 'Meta Ads', 'Card', 'MKT-NOV-001', GETDATE()),
('2025-11-25', 10000, 'Transport', 'Delivery Vehicle Fuel', 'Shell Station', 'Cash', 'TRANS-NOV-001', GETDATE());

-- December 2025 Expenses
INSERT INTO MiscExpense (ExpenseDate, Amount, Category, Description, PaidTo, PaymentMethod, ReceiptNumber, CreatedDate)
VALUES 
('2025-12-05', 45000, 'Utilities', 'Electricity Bill December', 'K-Electric', 'Bank Transfer', 'UTIL-DEC-001', GETDATE()),
('2025-12-10', 22000, 'Utilities', 'Gas Bill December (Winter)', 'Sui Gas', 'Bank Transfer', 'UTIL-DEC-002', GETDATE()),
('2025-12-15', 25000, 'Rent', 'Workshop Rent December', 'Landlord Ahmed', 'Cash', 'RENT-DEC-001', GETDATE()),
('2025-12-12', 50000, 'Bonus', 'Staff Eid Bonus', 'Employees', 'Cash', 'BONUS-DEC-001', GETDATE()),
('2025-12-16', 11000, 'Transport', 'Delivery Vehicle Fuel', 'Shell Station', 'Cash', 'TRANS-DEC-001', GETDATE());

PRINT '   ✓ Created 19 misc expense records';
PRINT '';

-- =============================================
-- STEP 4: Create HIGH-VALUE Deals for Previous Months
-- =============================================
PRINT '4. Creating High-Value Deals for Previous Months...';

-- Big deals for September (Delivered - generates revenue)
INSERT INTO Deal (DealTitle, ClientName, ContactPerson, Phone, StartDate, EndDate, TotalAmount, Status, DeliveryAddress, City, Province, CreatedBy, CreatedDate)
VALUES 
('Corporate Uniform Contract - Bank Al-Habib', 'Bank Al-Habib', 'Mr. Zahid Shah', '0321-1234567', '2025-09-01', '2025-09-20', 850000, 'Delivered', '123 Banking Street', 'Karachi', 'Sindh', 1, '2025-09-01'),
('School Uniform Bulk Order - LGS', 'Lahore Grammar School', 'Mrs. Fatima Khan', '0300-8765432', '2025-09-05', '2025-09-25', 620000, 'Delivered', '45 Education Road', 'Lahore', 'Punjab', 1, '2025-09-05'),
('Hotel Staff Uniforms - Pearl Continental', 'PC Hotels', 'Mr. Hassan Ali', '0333-5551234', '2025-09-10', '2025-09-30', 450000, 'Delivered', '67 Mall Road', 'Lahore', 'Punjab', 1, '2025-09-10');

-- Big deals for October (Delivered)
INSERT INTO Deal (DealTitle, ClientName, ContactPerson, Phone, StartDate, EndDate, TotalAmount, Status, DeliveryAddress, City, Province, CreatedBy, CreatedDate)
VALUES 
('Hospital Scrubs Order - Shaukat Khanum', 'Shaukat Khanum Hospital', 'Dr. Ayesha Malik', '0321-9876543', '2025-10-01', '2025-10-20', 780000, 'Delivered', '7-A Block R', 'Lahore', 'Punjab', 1, '2025-10-01'),
('Restaurant Chain Uniforms - Salt n Pepper', 'Salt n Pepper', 'Mr. Imran Butt', '0300-1112233', '2025-10-10', '2025-10-30', 520000, 'Delivered', 'M.M Alam Road', 'Lahore', 'Punjab', 1, '2025-10-10'),
('Factory Workers Uniforms - Packages Ltd', 'Packages Limited', 'Mr. Tariq Aziz', '0345-4445556', '2025-10-15', '2025-10-31', 680000, 'Delivered', 'Industrial Estate', 'Lahore', 'Punjab', 1, '2025-10-15');

-- Big deals for November (Delivered)
INSERT INTO Deal (DealTitle, ClientName, ContactPerson, Phone, StartDate, EndDate, TotalAmount, Status, DeliveryAddress, City, Province, CreatedBy, CreatedDate)
VALUES 
('Wedding Event Staff Uniforms', 'Royal Events Management', 'Mr. Bilal Ahmed', '0333-7778889', '2025-11-01', '2025-11-15', 920000, 'Delivered', '234 Event Plaza', 'Lahore', 'Punjab', 1, '2025-11-01'),
('Airline Crew Uniforms - PIA', 'Pakistan International Airlines', 'Mr. Khalid Mehmood', '0321-6667778', '2025-11-05', '2025-11-25', 1250000, 'Delivered', 'Jinnah Airport', 'Karachi', 'Sindh', 1, '2025-11-05'),
('Security Guards Uniforms - Securicor', 'Securicor Pakistan', 'Mr. Asif Raza', '0300-9990001', '2025-11-10', '2025-11-28', 550000, 'Delivered', '89 Security Road', 'Islamabad', 'Punjab', 1, '2025-11-10');

-- Big deals for December (Mix of Delivered and In Progress)
INSERT INTO Deal (DealTitle, ClientName, ContactPerson, Phone, StartDate, EndDate, TotalAmount, Status, DeliveryAddress, City, Province, CreatedBy, CreatedDate)
VALUES 
('Winter Collection - Khaadi Outlet', 'Khaadi Retail', 'Ms. Sana Saeed', '0321-2223334', '2025-12-01', '2025-12-15', 1100000, 'Delivered', 'Dolmen Mall', 'Karachi', 'Sindh', 1, '2025-12-01'),
('Corporate Suits - Engro Corp', 'Engro Corporation', 'Mr. Farhan Malik', '0333-4445556', '2025-12-05', '2025-12-20', 750000, 'Delivered', 'Engro Tower', 'Karachi', 'Sindh', 1, '2025-12-05'),
('Year-End Bulk Order - Metro Cash', 'Metro Cash & Carry', 'Mr. Naveed Iqbal', '0345-6667778', '2025-12-10', '2025-12-25', 890000, 'Approved', 'Metro Store', 'Lahore', 'Punjab', 1, '2025-12-10');

PRINT '   ✓ Created 12 high-value deals';
PRINT '';

-- =============================================
-- STEP 5: Add Deal Items for New Deals
-- =============================================
PRINT '5. Adding items to new deals...';

-- Get the starting DealID for new deals
DECLARE @StartDealID INT = (SELECT MAX(DealID) - 11 FROM Deal);

-- Add items for each deal (5-10 items per deal with high quantities)
DECLARE @d INT = @StartDealID;
WHILE @d <= @StartDealID + 11
BEGIN
    INSERT INTO DealItem (DealID, ProductID, Quantity, UnitPrice)
    SELECT @d, ProductID, 
           CASE WHEN @d % 3 = 0 THEN 150 WHEN @d % 3 = 1 THEN 200 ELSE 180 END,
           Price
    FROM Product 
    WHERE ProductID IN (
        SELECT TOP 5 ProductID FROM Product ORDER BY NEWID()
    );
    SET @d = @d + 1;
END

PRINT '   ✓ Added items to all deals';
PRINT '';

-- =============================================
-- STEP 6: Create Monthly Revenue Records
-- =============================================
PRINT '6. Creating Monthly Revenue Records...';

DELETE FROM MonthlyRevenue WHERE RevenueID > 0;

-- Calculate actuals for each month
-- September 2025
INSERT INTO MonthlyRevenue (Year, Month, MonthName, SalesIncome, DealIncome, SalariesPaid, TotalSalaries, RawMaterialCost, MiscExpense, TotalIncome, TotalExpense, NetProfit, Notes, CreatedDate)
VALUES (
    2025, 9, 'September',
    -- Sales Income (estimate from earlier orders)
    125000,
    -- Deal Income (3 deals = 850K + 620K + 450K = 1.92M)
    1920000,
    1, -- Salaries Paid
    @TotalSalary,
    -- Raw Material (Sept purchases = 360K)
    360000,
    -- Misc Expenses (Sept = 83K)
    83000,
    -- Total Income
    125000 + 1920000,
    -- Total Expense
    @TotalSalary + 360000 + 83000,
    -- Net Profit
    (125000 + 1920000) - (@TotalSalary + 360000 + 83000),
    'Strong month with large corporate deals',
    GETDATE()
);

-- October 2025
INSERT INTO MonthlyRevenue (Year, Month, MonthName, SalesIncome, DealIncome, SalariesPaid, TotalSalaries, RawMaterialCost, MiscExpense, TotalIncome, TotalExpense, NetProfit, Notes, CreatedDate)
VALUES (
    2025, 10, 'October',
    150000,
    -- Deal Income (3 deals = 780K + 520K + 680K = 1.98M)
    1980000,
    1,
    @TotalSalary,
    -- Raw Material (Oct = 370K)
    370000,
    -- Misc (Oct = 100K)
    100000,
    150000 + 1980000,
    @TotalSalary + 370000 + 100000,
    (150000 + 1980000) - (@TotalSalary + 370000 + 100000),
    'Excellent hospital and restaurant contracts',
    GETDATE()
);

-- November 2025
INSERT INTO MonthlyRevenue (Year, Month, MonthName, SalesIncome, DealIncome, SalariesPaid, TotalSalaries, RawMaterialCost, MiscExpense, TotalIncome, TotalExpense, NetProfit, Notes, CreatedDate)
VALUES (
    2025, 11, 'November',
    180000,
    -- Deal Income (3 deals = 920K + 1.25M + 550K = 2.72M)
    2720000,
    1,
    @TotalSalary,
    -- Raw Material (Nov = 440K)
    440000,
    -- Misc (Nov = 110K)
    110000,
    180000 + 2720000,
    @TotalSalary + 440000 + 110000,
    (180000 + 2720000) - (@TotalSalary + 440000 + 110000),
    'Record month! PIA contract boosted revenue',
    GETDATE()
);

-- December 2025 (Current Month)
INSERT INTO MonthlyRevenue (Year, Month, MonthName, SalesIncome, DealIncome, SalariesPaid, TotalSalaries, RawMaterialCost, MiscExpense, TotalIncome, TotalExpense, NetProfit, Notes, CreatedDate)
VALUES (
    2025, 12, 'December',
    -- Sales from delivered orders (68,900)
    68900,
    -- Deal Income (Delivered: 1.1M + 750K + existing 199.5K = 2.05M)
    2049500,
    1,
    @TotalSalary,
    -- Raw Material (Dec = 544.5K)
    544500,
    -- Misc (Dec = 153K including bonus)
    153000,
    68900 + 2049500,
    @TotalSalary + 544500 + 153000,
    (68900 + 2049500) - (@TotalSalary + 544500 + 153000),
    'Strong December with winter collection. Staff bonuses paid.',
    GETDATE()
);

PRINT '   ✓ Created 4 monthly revenue records';
PRINT '';

-- =============================================
-- STEP 7: Create Deliveries for New Deals
-- =============================================
PRINT '7. Creating deliveries for new deals...';

INSERT INTO Delivery (DealID, DeliveredBy, DeliveryDate, DeliveryAddress, City, Province, Status, ReceiverName, ReceiverPhone, Notes, CreatedDate)
SELECT 
    d.DealID,
    9, -- Delivery person
    d.EndDate,
    d.DeliveryAddress,
    d.City,
    d.Province,
    CASE WHEN d.Status = 'Delivered' THEN 'Delivered' ELSE 'Pending' END,
    d.ContactPerson,
    d.Phone,
    'Delivery for: ' + d.DealTitle,
    GETDATE()
FROM Deal d
WHERE d.DealID >= @StartDealID
AND NOT EXISTS (SELECT 1 FROM Delivery del WHERE del.DealID = d.DealID);

PRINT '   ✓ Created deliveries for new deals';
PRINT '';

-- =============================================
-- FINAL SUMMARY
-- =============================================
PRINT '========================================';
PRINT 'FINANCIAL DATA CREATED SUCCESSFULLY!';
PRINT '========================================';
PRINT '';

PRINT '💰 MONTHLY REVENUE SUMMARY:';
SELECT 
    MonthName,
    Year,
    FORMAT(TotalIncome, 'N0') AS [Total Income],
    FORMAT(TotalExpense, 'N0') AS [Total Expense],
    FORMAT(NetProfit, 'N0') AS [Net Profit],
    CASE WHEN NetProfit > 0 THEN '✓ PROFIT' ELSE '✗ LOSS' END AS [Status]
FROM MonthlyRevenue
ORDER BY Year, Month;

PRINT '';
PRINT '📊 SALARY PAYMENTS:';
SELECT PaymentMonth, PaymentYear, FORMAT(TotalAmount, 'N0') AS Amount, EmployeeCount 
FROM SalaryPayment 
WHERE PaymentYear >= 2025
ORDER BY PaymentYear, PaymentMonth;

PRINT '';
PRINT '🤝 DEALS BY STATUS:';
SELECT Status, COUNT(*) AS Count, FORMAT(SUM(TotalAmount), 'N0') AS TotalValue
FROM Deal
GROUP BY Status;

GO
