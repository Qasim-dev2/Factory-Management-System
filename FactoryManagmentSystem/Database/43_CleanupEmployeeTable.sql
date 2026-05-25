-- ================================================================================
-- Script: 43_CleanupEmployeeTable.sql
-- Purpose: Remove unnecessary columns from Employee table
-- Date: December 9, 2025
-- Description: Clean up Employee table to keep only essential fields
-- ================================================================================

USE GarmentsFactoryDB;
GO

PRINT '========================================';
PRINT 'Starting Employee Table Cleanup';
PRINT '========================================';
PRINT '';

-- Drop unnecessary columns from Employee table
PRINT 'Dropping unnecessary columns from Employee table...';

-- Drop Salesperson-specific fields
IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Employee') AND name = 'CommissionRate')
BEGIN
    ALTER TABLE Employee DROP COLUMN CommissionRate;
    PRINT '✓ Dropped CommissionRate column';
END

IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Employee') AND name = 'SalesTarget')
BEGIN
    ALTER TABLE Employee DROP COLUMN SalesTarget;
    PRINT '✓ Dropped SalesTarget column';
END

IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Employee') AND name = 'TotalSales')
BEGIN
    -- Drop default constraint first
    DECLARE @ConstraintName nvarchar(200)
    SELECT @ConstraintName = Name FROM sys.default_constraints 
    WHERE parent_object_id = OBJECT_ID('Employee') AND parent_column_id = (SELECT column_id FROM sys.columns WHERE object_id = OBJECT_ID('Employee') AND name = 'TotalSales')
    
    IF @ConstraintName IS NOT NULL
        EXEC('ALTER TABLE Employee DROP CONSTRAINT ' + @ConstraintName)
    
    ALTER TABLE Employee DROP COLUMN TotalSales;
    PRINT '✓ Dropped TotalSales column';
END

IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Employee') AND name = 'SalesRegion')
BEGIN
    ALTER TABLE Employee DROP COLUMN SalesRegion;
    PRINT '✓ Dropped SalesRegion column';
END

-- Drop Tailor-specific fields
IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Employee') AND name = 'Specialization')
BEGIN
    ALTER TABLE Employee DROP COLUMN Specialization;
    PRINT '✓ Dropped Specialization column';
END

IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Employee') AND name = 'PieceRate')
BEGIN
    ALTER TABLE Employee DROP COLUMN PieceRate;
    PRINT '✓ Dropped PieceRate column';
END

IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Employee') AND name = 'TotalPiecesCompleted')
BEGIN
    -- Drop default constraint first
    DECLARE @ConstraintName2 nvarchar(200)
    SELECT @ConstraintName2 = Name FROM sys.default_constraints 
    WHERE parent_object_id = OBJECT_ID('Employee') AND parent_column_id = (SELECT column_id FROM sys.columns WHERE object_id = OBJECT_ID('Employee') AND name = 'TotalPiecesCompleted')
    
    IF @ConstraintName2 IS NOT NULL
        EXEC('ALTER TABLE Employee DROP CONSTRAINT ' + @ConstraintName2)
    
    ALTER TABLE Employee DROP COLUMN TotalPiecesCompleted;
    PRINT '✓ Dropped TotalPiecesCompleted column';
END

-- Drop other unnecessary fields
IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Employee') AND name = 'ShiftType')
BEGIN
    ALTER TABLE Employee DROP COLUMN ShiftType;
    PRINT '✓ Dropped ShiftType column';
END

IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Employee') AND name = 'Notes')
BEGIN
    ALTER TABLE Employee DROP COLUMN Notes;
    PRINT '✓ Dropped Notes column';
END

IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Employee') AND name = 'UpdatedDate')
BEGIN
    ALTER TABLE Employee DROP COLUMN UpdatedDate;
    PRINT '✓ Dropped UpdatedDate column';
END

IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Employee') AND name = 'PasswordHash')
BEGIN
    ALTER TABLE Employee DROP COLUMN PasswordHash;
    PRINT '✓ Dropped PasswordHash column';
END

PRINT '';
PRINT '========================================';
PRINT 'Employee Table Cleanup Complete!';
PRINT '========================================';
PRINT '';
PRINT 'Final Employee Table Structure:';
PRINT '- EmployeeID (INT, PK, IDENTITY)';
PRINT '- FirstName (NVARCHAR(50), NOT NULL)';
PRINT '- LastName (NVARCHAR(50), NOT NULL)';
PRINT '- Email (NVARCHAR(100))';
PRINT '- Phone (NVARCHAR(20))';
PRINT '- DepartmentID (INT, NOT NULL, FK)';
PRINT '- RoleID (INT, NOT NULL, FK)';
PRINT '- Salary (DECIMAL(18,2))';
PRINT '- JoinDate (DATE)';
PRINT '- Address (NVARCHAR(500))';
PRINT '- EmergencyContact (NVARCHAR(100))';
PRINT '- CNIC (NVARCHAR(15))';
PRINT '- IsActive (BIT)';
PRINT '- CreatedDate (DATETIME)';
PRINT '- Username (NVARCHAR(50))';
PRINT '- PIN (NVARCHAR(4))';
PRINT '- LastLogin (DATETIME)';
PRINT '';

-- Display current Employee table structure
PRINT 'Current Employee columns:';
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Employee'
ORDER BY ORDINAL_POSITION;

GO
