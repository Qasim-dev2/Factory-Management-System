-- ================================================================================
-- AUTHENTICATION SYSTEM SETUP (Simple PIN-based Login)
-- Add login credentials to Employee table
-- ================================================================================

USE GarmentsFactoryDB;
GO

PRINT '==================== SETTING UP AUTHENTICATION ====================';
GO

-- ================================================================================
-- STEP 1: Add Authentication Columns to Employee Table
-- ================================================================================
PRINT 'Step 1: Adding authentication columns...';
GO

-- Check if columns already exist before adding
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Employee' AND COLUMN_NAME = 'Username')
BEGIN
    ALTER TABLE Employee ADD Username NVARCHAR(50) NULL;
    PRINT '✅ Username column added';
END
ELSE
    PRINT '⚠️ Username column already exists';

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Employee' AND COLUMN_NAME = 'PIN')
BEGIN
    ALTER TABLE Employee ADD PIN NVARCHAR(4) NULL;
    PRINT '✅ PIN column added (4-digit)';
END
ELSE
    PRINT '⚠️ PIN column already exists';

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Employee' AND COLUMN_NAME = 'IsActive')
BEGIN
    ALTER TABLE Employee ADD IsActive BIT DEFAULT 1;
    PRINT '✅ IsActive column added';
END
ELSE
    PRINT '⚠️ IsActive column already exists';

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Employee' AND COLUMN_NAME = 'LastLogin')
BEGIN
    ALTER TABLE Employee ADD LastLogin DATETIME NULL;
    PRINT '✅ LastLogin column added';
END
ELSE
    PRINT '⚠️ LastLogin column already exists';
GO

-- ================================================================================
-- STEP 2: Add Unique Constraint on Username
-- ================================================================================
PRINT 'Step 2: Adding unique constraint on Username...';
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'UQ_Employee_Username')
BEGIN
    CREATE UNIQUE INDEX UQ_Employee_Username ON Employee(Username) WHERE Username IS NOT NULL;
    PRINT '✅ Unique constraint on Username created';
END
ELSE
    PRINT '⚠️ Unique constraint already exists';
GO

-- ================================================================================
-- STEP 3: Create Login Stored Procedure
-- ================================================================================
PRINT 'Step 3: Creating login stored procedure...';
GO

DROP PROCEDURE IF EXISTS sp_AuthenticateUser;
GO

CREATE PROCEDURE sp_AuthenticateUser
    @Username NVARCHAR(50),
    @PIN NVARCHAR(4)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @EmployeeID INT;
    
    -- Check if user exists and PIN matches
    SELECT 
        @EmployeeID = EmployeeID
    FROM Employee
    WHERE Username = @Username 
      AND PIN = @PIN 
      AND IsActive = 1;
    
    IF @EmployeeID IS NOT NULL
    BEGIN
        -- Update last login time
        UPDATE Employee 
        SET LastLogin = GETDATE() 
        WHERE EmployeeID = @EmployeeID;
        
        -- Return employee details
        SELECT 
            EmployeeID,
            FirstName,
            LastName,
            CONCAT(FirstName, ' ', LastName) as FullName,
            Role,
            Department,
            Username,
            Email,
            Phone,
            IsActive,
            LastLogin
        FROM Employee
        WHERE EmployeeID = @EmployeeID;
    END
    ELSE
    BEGIN
        -- Return empty result for failed login
        SELECT NULL as EmployeeID;
    END
END
GO

PRINT '✅ sp_AuthenticateUser created (PIN-based)';
GO

PRINT '';
PRINT '==================== AUTHENTICATION SETUP COMPLETE ====================';
PRINT '✅ Employee table ready for authentication';
PRINT '✅ Next: Add sample employees with credentials';
GO
