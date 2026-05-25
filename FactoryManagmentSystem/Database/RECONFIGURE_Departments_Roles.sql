/*******************************************************************************
 * RECONFIGURE DEPARTMENTS AND ROLES - GarmentsFactoryDB
 * 
 * Purpose: Reset departments and roles to specific business structure
 * 
 * NEW STRUCTURE:
 * - 3 Departments: Sales, Production, Delivery
 * - 5 Roles: Delivery Person, Tailor, Sales Person, Sales Manager, Production Manager
 * 
 * Created: December 14, 2025
 ******************************************************************************/

USE GarmentsFactoryDB;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

PRINT '============================================================================';
PRINT 'RECONFIGURING DEPARTMENTS AND ROLES';
PRINT 'Timestamp: ' + CONVERT(VARCHAR, GETDATE(), 120);
PRINT '============================================================================';
PRINT '';

-- ============================================================================
-- STEP 1: Clear existing Departments (keep structure, remove data)
-- ============================================================================
PRINT '-- STEP 1: Clearing existing departments...';
DELETE FROM Department;
PRINT 'Existing departments cleared.';
PRINT '';

-- ============================================================================
-- STEP 2: Clear existing Employee Roles (keep structure, remove data)
-- ============================================================================
PRINT '-- STEP 2: Clearing existing roles...';
DELETE FROM EmployeeRole;
PRINT 'Existing roles cleared.';
PRINT '';

-- ============================================================================
-- STEP 3: Reset Identity Seeds
-- ============================================================================
PRINT '-- STEP 3: Resetting identity seeds...';
DBCC CHECKIDENT ('Department', RESEED, 0);
DBCC CHECKIDENT ('EmployeeRole', RESEED, 0);
PRINT 'Identity seeds reset.';
PRINT '';

-- ============================================================================
-- STEP 4: Insert New Departments (3 departments)
-- ============================================================================
PRINT '-- STEP 4: Creating new departments...';

INSERT INTO Department (DepartmentName, Description, IsActive, CreatedDate) VALUES
('Sales', 'Handles customer relationships, orders, and sales operations', 1, GETDATE()),
('Production', 'Manages garment manufacturing and tailoring operations', 1, GETDATE()),
('Delivery', 'Responsible for order delivery and logistics', 1, GETDATE());

PRINT 'Created 3 departments:';
PRINT '  1. Sales Department';
PRINT '  2. Production Department';
PRINT '  3. Delivery Department';
PRINT '';

-- ============================================================================
-- STEP 5: Insert New Employee Roles (5 roles)
-- ============================================================================
PRINT '-- STEP 5: Creating new employee roles...';

INSERT INTO EmployeeRole (RoleName, Description) VALUES
('Owner', 'System owner with full access to all features and data'),
('Sales Manager', 'Manages sales team, oversees deals and sales orders'),
('Sales Person', 'Handles customer orders, deals, and retailer relationships'),
('Production Manager', 'Oversees production operations and manages tailors'),
('Tailor', 'Creates garments and completes production orders'),
('Delivery Person', 'Delivers finished orders to customers');

PRINT 'Created 6 roles (including Owner):';
PRINT '  1. Owner (Full System Access)';
PRINT '  2. Sales Manager';
PRINT '  3. Sales Person';
PRINT '  4. Production Manager';
PRINT '  5. Tailor';
PRINT '  6. Delivery Person';
PRINT '';

-- ============================================================================
-- STEP 6: Create Owner Account
-- ============================================================================
PRINT '-- STEP 6: Creating Owner account...';

-- Insert Owner employee (RoleID = 1 for Owner)
-- Using Sales department as default (DepartmentID = 1)
INSERT INTO Employee (FirstName, LastName, Email, Phone, RoleID, DepartmentID, JoinDate, Salary, IsActive, Username, PIN, CreatedDate)
VALUES ('System', 'Owner', 'owner@factory.com', '0300-0000000', 1, 1, GETDATE(), 100000, 1, 'owner', '1234', GETDATE());

DECLARE @OwnerID INT = SCOPE_IDENTITY();

PRINT 'Owner account created successfully!';
PRINT '';
PRINT '============================================';
PRINT '     OWNER LOGIN CREDENTIALS';
PRINT '============================================';
PRINT '  Username: owner';
PRINT '  PIN: 1234';
PRINT '  Employee ID: ' + CAST(@OwnerID AS VARCHAR);
PRINT '  Role: Owner (Full Access)';
PRINT '============================================';
PRINT '';
PRINT 'IMPORTANT: Change the PIN after first login!';
PRINT '';

-- ============================================================================
-- VERIFICATION: Display Current Setup
-- ============================================================================
PRINT '============================================================================';
PRINT 'VERIFICATION - Current Configuration';
PRINT '============================================================================';
PRINT '';

PRINT 'DEPARTMENTS:';
SELECT 
    DepartmentID,
    DepartmentName,
    Description
FROM Department
ORDER BY DepartmentID;

PRINT '';
PRINT 'EMPLOYEE ROLES:';
SELECT 
    RoleID,
    RoleName,
    Description
FROM EmployeeRole
ORDER BY RoleID;

PRINT '';
PRINT 'EMPLOYEES:';
SELECT 
    EmployeeID,
    FirstName + ' ' + LastName AS FullName,
    r.RoleName,
    d.DepartmentName AS Department,
    Username
FROM Employee e
JOIN EmployeeRole r ON e.RoleID = r.RoleID
JOIN Department d ON e.DepartmentID = d.DepartmentID;

PRINT '';
PRINT '============================================================================';
PRINT 'RECONFIGURATION COMPLETED SUCCESSFULLY';
PRINT 'Timestamp: ' + CONVERT(VARCHAR, GETDATE(), 120);
PRINT '============================================================================';
PRINT '';
PRINT 'Your system is now configured with:';
PRINT '  ✓ 3 Departments (Sales, Production, Delivery)';
PRINT '  ✓ 6 Roles (Owner, Sales Manager, Sales Person, Production Manager, Tailor, Delivery Person)';
PRINT '  ✓ 1 Owner account ready to use';
PRINT '';
PRINT 'Next Steps:';
PRINT '  1. Login with owner credentials: username "owner", password "owner123"';
PRINT '  2. Add more employees through the Owner Dashboard';
PRINT '  3. Assign employees to appropriate departments and roles';
PRINT '  4. Start adding products, retailers, and other business data';
PRINT '';

GO

/*******************************************************************************
 * DEPARTMENT AND ROLE MAPPING GUIDE
 ******************************************************************************/

/*
BUSINESS STRUCTURE:

┌─────────────────────────────────────────────────────────────────┐
│                         OWNER                                    │
│                    (Full System Access)                          │
└─────────────────────────────────────────────────────────────────┘
                              │
          ┌───────────────────┼───────────────────┐
          │                   │                   │
    ┌─────▼─────┐       ┌────▼─────┐      ┌─────▼──────┐
    │   SALES   │       │ PRODUCTION│      │  DELIVERY  │
    │   DEPT    │       │   DEPT    │      │    DEPT    │
    └───────────┘       └───────────┘      └────────────┘
          │                   │                   │
    ┌─────┴─────┐       ┌────┴─────┐            │
    │           │       │          │             │
Sales       Sales    Production  Tailor      Delivery
Manager     Person   Manager               Person


ROLE PERMISSIONS:

1. OWNER
   - Full system access
   - Manage all departments
   - View all reports
   - Manage employees
   - System configuration

2. SALES MANAGER
   - Manage sales team
   - Approve deals
   - View sales reports
   - Manage retailers
   - Create sales orders

3. SALES PERSON
   - Create deals
   - Create sales orders
   - Manage retailer relationships
   - View own sales data

4. PRODUCTION MANAGER
   - Manage production team
   - Assign production orders
   - Monitor production status
   - Manage raw materials
   - Assign tailors to orders

5. TAILOR
   - View assigned production orders
   - Update production status
   - Record material usage
   - Mark orders as complete

6. DELIVERY PERSON
   - View assigned deliveries
   - Update delivery status
   - Mark deliveries as complete
   - Record delivery details


DEPARTMENT ASSIGNMENTS:

Sales Department:
  - Sales Manager (manages department)
  - Sales Person (reports to Sales Manager)

Production Department:
  - Production Manager (manages department)
  - Tailor (reports to Production Manager)

Delivery Department:
  - Delivery Person (independent role)


WORKFLOW EXAMPLE:

1. Sales Person creates a Deal/Sales Order
2. Sales Manager approves the order
3. Production Manager assigns to Tailor
4. Tailor completes the garment
5. Delivery Person delivers to customer
6. Owner monitors entire process


DATABASE STRUCTURE:

Employee Table:
  - EmployeeID (PK)
  - FirstName, LastName
  - Email, Phone
  - RoleID (FK -> EmployeeRole)
  - DepartmentID (FK -> Department)
  - Username, PasswordHash
  - HireDate, Salary
  - IsActive

EmployeeRole Table:
  - RoleID (PK)
  - RoleName
  - Description

Department Table:
  - DepartmentID (PK)
  - Name
  - Description
*/

/*******************************************************************************
 * END OF RECONFIGURATION SCRIPT
 ******************************************************************************/
