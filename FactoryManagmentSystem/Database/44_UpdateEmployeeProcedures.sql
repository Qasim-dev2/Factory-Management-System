-- ================================================================================
-- Script: 44_UpdateEmployeeProcedures.sql
-- Purpose: Update employee procedures to match cleaned Employee table
-- Date: December 9, 2025
-- Description: Remove obsolete fields and add Username/PIN fields
-- ================================================================================

USE GarmentsFactoryDB;
GO

PRINT '========================================';
PRINT 'Updating Employee Procedures';
PRINT '========================================';
PRINT '';

-- ================================================================================
-- 1. DROP OLD PROCEDURE
-- ================================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_AddEmployee')
BEGIN
    DROP PROCEDURE sp_AddEmployee;
    PRINT '✓ Dropped old sp_AddEmployee';
END
GO

-- ================================================================================
-- 2. CREATE UPDATED sp_AddEmployee
-- ================================================================================
CREATE PROCEDURE sp_AddEmployee
    @FirstName NVARCHAR(50),
    @LastName NVARCHAR(50),
    @Email NVARCHAR(100),
    @Phone NVARCHAR(20),
    @CNIC NVARCHAR(15),
    @Address NVARCHAR(500),
    @EmergencyContact NVARCHAR(100),
    @DepartmentID INT,
    @RoleID INT,
    @Salary DECIMAL(18,2),
    @JoinDate DATE = NULL,
    @Username NVARCHAR(50),
    @PIN NVARCHAR(4),
    @NewEmployeeID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validate minimum salary
        IF @Salary < 25000
        BEGIN
            SELECT 'ERROR' AS Status, 'Minimum salary must be Rs. 25,000 or above.' AS Message, 0 AS EmployeeID;
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Check if Username already exists
        IF EXISTS (SELECT 1 FROM Employee WHERE Username = @Username)
        BEGIN
            SELECT 'ERROR' AS Status, 'Username already exists. Please choose a different username.' AS Message, 0 AS EmployeeID;
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Check if CNIC already exists
        IF EXISTS (SELECT 1 FROM Employee WHERE CNIC = @CNIC)
        BEGIN
            SELECT 'ERROR' AS Status, 'CNIC already registered. Please check the CNIC number.' AS Message, 0 AS EmployeeID;
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Check if Email already exists
        IF EXISTS (SELECT 1 FROM Employee WHERE Email = @Email)
        BEGIN
            SELECT 'ERROR' AS Status, 'Email already registered. Please use a different email.' AS Message, 0 AS EmployeeID;
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Set default JoinDate if not provided
        IF @JoinDate IS NULL
            SET @JoinDate = GETDATE();
        
        INSERT INTO Employee (
            FirstName, 
            LastName, 
            Email, 
            Phone, 
            CNIC, 
            Address, 
            EmergencyContact,
            DepartmentID, 
            RoleID, 
            Salary, 
            JoinDate,
            Username,
            PIN,
            IsActive, 
            CreatedDate
        )
        VALUES (
            @FirstName, 
            @LastName, 
            @Email, 
            @Phone, 
            @CNIC, 
            @Address, 
            @EmergencyContact,
            @DepartmentID, 
            @RoleID, 
            @Salary, 
            @JoinDate,
            @Username,
            @PIN,
            1, 
            GETDATE()
        );
        
        SET @NewEmployeeID = SCOPE_IDENTITY();
        
        COMMIT TRANSACTION;
        
        SELECT 'SUCCESS' AS Status, 'Employee added successfully.' AS Message, @NewEmployeeID AS EmployeeID;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        SELECT 'ERROR' AS Status, ERROR_MESSAGE() AS Message, 0 AS EmployeeID;
    END CATCH
END
GO
PRINT '✓ Created sp_AddEmployee with new fields';
PRINT '';

-- ================================================================================
-- 3. UPDATE sp_UpdateEmployee
-- ================================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_UpdateEmployee')
BEGIN
    DROP PROCEDURE sp_UpdateEmployee;
    PRINT '✓ Dropped old sp_UpdateEmployee';
END
GO

CREATE PROCEDURE sp_UpdateEmployee
    @EmployeeID INT,
    @FirstName NVARCHAR(50),
    @LastName NVARCHAR(50),
    @Email NVARCHAR(100),
    @Phone NVARCHAR(20),
    @CNIC NVARCHAR(15),
    @Address NVARCHAR(500),
    @EmergencyContact NVARCHAR(100),
    @DepartmentID INT,
    @RoleID INT,
    @Salary DECIMAL(18,2),
    @JoinDate DATE,
    @Username NVARCHAR(50),
    @PIN NVARCHAR(4)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validate minimum salary
        IF @Salary < 25000
        BEGIN
            SELECT 'ERROR' AS Status, 'Minimum salary must be Rs. 25,000 or above.' AS Message;
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Check if Username already exists (excluding current employee)
        IF EXISTS (SELECT 1 FROM Employee WHERE Username = @Username AND EmployeeID != @EmployeeID)
        BEGIN
            SELECT 'ERROR' AS Status, 'Username already exists. Please choose a different username.' AS Message;
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Check if CNIC already exists (excluding current employee)
        IF EXISTS (SELECT 1 FROM Employee WHERE CNIC = @CNIC AND EmployeeID != @EmployeeID)
        BEGIN
            SELECT 'ERROR' AS Status, 'CNIC already registered.' AS Message;
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Check if Email already exists (excluding current employee)
        IF EXISTS (SELECT 1 FROM Employee WHERE Email = @Email AND EmployeeID != @EmployeeID)
        BEGIN
            SELECT 'ERROR' AS Status, 'Email already registered.' AS Message;
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        UPDATE Employee
        SET 
            FirstName = @FirstName,
            LastName = @LastName,
            Email = @Email,
            Phone = @Phone,
            CNIC = @CNIC,
            Address = @Address,
            EmergencyContact = @EmergencyContact,
            DepartmentID = @DepartmentID,
            RoleID = @RoleID,
            Salary = @Salary,
            JoinDate = @JoinDate,
            Username = @Username,
            PIN = @PIN
        WHERE EmployeeID = @EmployeeID;
        
        COMMIT TRANSACTION;
        
        SELECT 'SUCCESS' AS Status, 'Employee updated successfully.' AS Message;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        SELECT 'ERROR' AS Status, ERROR_MESSAGE() AS Message;
    END CATCH
END
GO
PRINT '✓ Created sp_UpdateEmployee with new fields';
PRINT '';

PRINT '========================================';
PRINT 'Employee Procedures Updated Successfully!';
PRINT '========================================';
PRINT '';
PRINT 'Updated Procedures:';
PRINT '1. sp_AddEmployee - Includes Username, PIN, validates salary >= 25000';
PRINT '2. sp_UpdateEmployee - Includes Username, PIN, validates uniqueness';
PRINT '';
PRINT 'Removed Fields:';
PRINT '- ShiftType, Notes, CommissionRate, SalesTarget';
PRINT '- SalesRegion, Specialization, PieceRate';
PRINT '';
PRINT 'New Fields:';
PRINT '- Username (NVARCHAR(50), unique, required)';
PRINT '- PIN (NVARCHAR(4), required)';
PRINT '';
GO
