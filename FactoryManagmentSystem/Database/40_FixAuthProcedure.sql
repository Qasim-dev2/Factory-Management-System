-- Fix the stored procedure with correct column names
USE GarmentsFactoryDB;
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
      AND ISNULL(IsActive, 1) = 1;
    
    IF @EmployeeID IS NOT NULL
    BEGIN
        -- Update last login time
        UPDATE Employee 
        SET LastLogin = GETDATE() 
        WHERE EmployeeID = @EmployeeID;
        
        -- Return employee details with Role from EmployeeRole table
        SELECT 
            e.EmployeeID,
            e.FirstName,
            e.LastName,
            CONCAT(e.FirstName, ' ', e.LastName) as FullName,
            er.RoleName as Role,
            e.Username,
            e.Email,
            e.Phone,
            ISNULL(e.IsActive, 1) as IsActive,
            e.LastLogin
        FROM Employee e
        LEFT JOIN EmployeeRole er ON e.RoleID = er.RoleID
        WHERE e.EmployeeID = @EmployeeID;
    END
    ELSE
    BEGIN
        -- Return empty result for failed login
        SELECT NULL as EmployeeID;
    END
END
GO

PRINT '✅ sp_AuthenticateUser fixed with correct columns';
GO
