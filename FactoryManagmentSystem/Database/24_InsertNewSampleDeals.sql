-- ================================================================================
-- NEW SAMPLE DATA FOR DEALS (WORKFLOW-BASED)
-- ================================================================================
-- This script inserts sample deals with the new workflow schema
-- Includes: DealName (DealTitle), RequestedBy (ClientName), Deadline (EndDate), Status
-- ================================================================================

USE GarmentsFactoryDB;
GO

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

PRINT '========================================';
PRINT 'INSERTING NEW SAMPLE DEALS';
PRINT '========================================';
GO

-- First, let's make sure we have some employees and products
-- Check if we have an owner/manager to assign as creator
DECLARE @OwnerID INT;
DECLARE @ManagerID INT;
DECLARE @SalespersonID INT;

SELECT TOP 1 @OwnerID = EmployeeID FROM Employee WHERE RoleID = 1; -- Owner
SELECT TOP 1 @ManagerID = EmployeeID FROM Employee WHERE RoleID = 2; -- Manager  
SELECT TOP 1 @SalespersonID = EmployeeID FROM Employee WHERE RoleID = 3; -- Salesperson

IF @OwnerID IS NULL
BEGIN
    PRINT 'ERROR: No owner found. Please run employee data insertion first.';
    RETURN;
END

PRINT 'Using Owner ID: ' + CAST(@OwnerID AS VARCHAR);
PRINT 'Using Manager ID: ' + CAST(ISNULL(@ManagerID, 0) AS VARCHAR);
GO

-- ================================================================================
-- INSERT SAMPLE DEALS WITH NEW SCHEMA
-- ================================================================================
PRINT '';
PRINT 'Inserting sample deals...';

-- Deal 1: Pending Deal (Waiting for owner approval)
INSERT INTO Deal (
    DealTitle,          -- Maps to DealName in UI
    DealType,
    ClientName,         -- Maps to RequestedBy in UI
    ContactPerson,
    Email,
    Phone,
    EstimatedValue,
    Currency,
    Priority,
    ExpectedDuration,
    StartDate,
    EndDate,            -- Maps to Deadline in UI
    Description,
    KeyTerms,
    PaymentTerms,
    PaymentMethod,
    SpecialRequirements,
    AssignedManagerID,
    Status,
    CreatedBy,
    CreatedDate
) VALUES (
    'Corporate Uniform Order - ABC Ltd',
    'Supply Contract',
    'ABC Corporation',
    'John Smith',
    'john.smith@abc.com',
    '+92-300-1234567',
    250000.00,
    'PKR',
    'High',
    '2 months',
    '2025-12-10',
    '2026-02-10',
    '500 corporate uniforms for new employees',
    'Bulk discount 15%, Quality inspection required',
    'Net 30 days',
    'Bank Transfer',
    'Logo embroidery on all items',
    (SELECT TOP 1 EmployeeID FROM Employee WHERE RoleID = 2),
    'Pending',
    (SELECT TOP 1 EmployeeID FROM Employee WHERE RoleID = 3),
    GETDATE()
);

-- Deal 2: In Progress Deal (Owner approved, tailors working)
INSERT INTO Deal (
    DealTitle,
    DealType,
    ClientName,
    ContactPerson,
    Email,
    Phone,
    EstimatedValue,
    Currency,
    Priority,
    ExpectedDuration,
    StartDate,
    EndDate,
    Description,
    KeyTerms,
    PaymentTerms,
    PaymentMethod,
    SpecialRequirements,
    AssignedManagerID,
    Status,
    CreatedBy,
    CreatedDate
) VALUES (
    'Wedding Collection - Khan Family',
    'Custom Order',
    'Khan Family',
    'Ahmed Khan',
    'ahmed.khan@email.com',
    '+92-321-9876543',
    180000.00,
    'PKR',
    'Critical',
    '3 weeks',
    '2025-12-05',
    '2025-12-25',
    'Complete wedding outfits for family of 12',
    'Premium fabrics, Custom measurements, Multiple fittings',
    '50% advance, 50% on delivery',
    'Cash & Card',
    'Rush delivery required, Multiple fitting sessions',
    (SELECT TOP 1 EmployeeID FROM Employee WHERE RoleID = 2),
    'In Progress',
    (SELECT TOP 1 EmployeeID FROM Employee WHERE RoleID = 1),
    GETDATE() - 5
);

-- Deal 3: Completed Deal (Tailors finished, ready for delivery)
INSERT INTO Deal (
    DealTitle,
    DealType,
    ClientName,
    ContactPerson,
    Email,
    Phone,
    EstimatedValue,
    Currency,
    Priority,
    ExpectedDuration,
    StartDate,
    EndDate,
    Description,
    KeyTerms,
    PaymentTerms,
    PaymentMethod,
    SpecialRequirements,
    AssignedManagerID,
    Status,
    CreatedBy,
    CreatedDate
) VALUES (
    'Restaurant Staff Uniforms - Dine Fine',
    'Partnership',
    'Dine Fine Restaurant Chain',
    'Sara Ali',
    'sara@dinefine.com',
    '+92-300-5551234',
    95000.00,
    'PKR',
    'Medium',
    '1 month',
    '2025-11-15',
    '2025-12-15',
    '120 chef coats and waiter uniforms',
    'Standard sizes, Monthly recurring order potential',
    'Net 15 days',
    'Bank Transfer',
    'Standard sizing chart provided',
    (SELECT TOP 1 EmployeeID FROM Employee WHERE RoleID = 2),
    'Completed',
    (SELECT TOP 1 EmployeeID FROM Employee WHERE RoleID = 3),
    GETDATE() - 10
);

-- Deal 4: Delivered Deal (Customer received products)
INSERT INTO Deal (
    DealTitle,
    DealType,
    ClientName,
    ContactPerson,
    Email,
    Phone,
    EstimatedValue,
    Currency,
    Priority,
    ExpectedDuration,
    StartDate,
    EndDate,
    Description,
    KeyTerms,
    PaymentTerms,
    PaymentMethod,
    SpecialRequirements,
    AssignedManagerID,
    Status,
    CreatedBy,
    CreatedDate
) VALUES (
    'School Uniform Order - City Grammar',
    'Supply Contract',
    'City Grammar School',
    'Principal Fatima',
    'admin@citygrammar.edu',
    '+92-42-35551234',
    320000.00,
    'PKR',
    'High',
    '6 weeks',
    '2025-10-01',
    '2025-11-15',
    '800 school uniforms for students',
    'Annual contract, Quality standards compliance',
    'Net 45 days',
    'Cheque',
    'Size chart by grade level',
    (SELECT TOP 1 EmployeeID FROM Employee WHERE RoleID = 2),
    'Delivered',
    (SELECT TOP 1 EmployeeID FROM Employee WHERE RoleID = 1),
    GETDATE() - 30
);

-- Deal 5: Cancelled Deal (Owner rejected)
INSERT INTO Deal (
    DealTitle,
    DealType,
    ClientName,
    ContactPerson,
    Email,
    Phone,
    EstimatedValue,
    Currency,
    Priority,
    ExpectedDuration,
    StartDate,
    EndDate,
    Description,
    KeyTerms,
    PaymentTerms,
    PaymentMethod,
    SpecialRequirements,
    AssignedManagerID,
    Status,
    CreatedBy,
    CreatedDate
) VALUES (
    'Budget Casual Wear - XYZ Retail',
    'Partnership',
    'XYZ Retail Store',
    'Hassan Ali',
    'hassan@xyzretail.com',
    '+92-300-9998888',
    45000.00,
    'PKR',
    'Low',
    '2 weeks',
    '2025-12-01',
    '2025-12-15',
    'Low-quality casual wear bulk order',
    'Very low margins, High volume required',
    'Net 60 days',
    'Credit Terms',
    'Below standard quality acceptable',
    NULL,
    'Cancelled',
    (SELECT TOP 1 EmployeeID FROM Employee WHERE RoleID = 3),
    GETDATE() - 3
);

PRINT '  ✅ Inserted 5 sample deals';
PRINT '    - 1 Pending (waiting approval)';
PRINT '    - 1 In Progress (owner approved)';
PRINT '    - 1 Completed (ready for delivery)';
PRINT '    - 1 Delivered (customer received)';
PRINT '    - 1 Cancelled (owner rejected)';
GO

-- ================================================================================
-- VERIFY DATA
-- ================================================================================
PRINT '';
PRINT '========================================';
PRINT 'VERIFICATION';
PRINT '========================================';
GO

SELECT 
    DealID,
    DealTitle AS 'Deal Name',
    ClientName AS 'Requested By',
    EndDate AS 'Deadline',
    Status,
    EstimatedValue AS 'Value',
    Priority,
    CreatedDate
FROM Deal
ORDER BY DealID DESC;
GO

-- Show statistics by status
SELECT 
    Status,
    COUNT(*) AS 'Count',
    SUM(EstimatedValue) AS 'Total Value'
FROM Deal
GROUP BY Status
ORDER BY 
    CASE Status
        WHEN 'Pending' THEN 1
        WHEN 'In Progress' THEN 2
        WHEN 'Completed' THEN 3
        WHEN 'Delivered' THEN 4
        WHEN 'Cancelled' THEN 5
        ELSE 6
    END;
GO

PRINT '';
PRINT '✅ SAMPLE DEALS INSERTED SUCCESSFULLY';
PRINT '✅ You can now test the workflow: Pending → In Progress → Completed → Delivered';
PRINT '';
GO
