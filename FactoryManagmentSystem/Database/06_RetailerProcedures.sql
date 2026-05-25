-- ================================================================================
-- RETAILER MANAGEMENT - STORED PROCEDURES
-- ================================================================================
-- Execute this script in SQL Server Management Studio (SSMS)
-- Make sure you're connected to GarmentsFactoryDB database
-- ================================================================================

USE GarmentsFactoryDB;
GO

-- ================================================================================
-- 1. GET ALL RETAILERS (For View All Tab)
-- ================================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetAllRetailers')
    DROP PROCEDURE sp_GetAllRetailers;
GO

CREATE PROCEDURE sp_GetAllRetailers
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        r.RetailerID,
        r.CompanyName,
        r.BusinessType,
        r.RegistrationNumber,
        r.TaxId,
        r.ContactPerson,
        r.Designation,
        r.Phone,
        r.Email,
        r.AlternativePhone,
        r.Address,
        r.City,
        r.Province,
        r.PostalCode,
        r.CreditLimit,
        r.PaymentTerms,
        r.DiscountPercentage,
        r.SalesRepID,
        CONCAT(e.FirstName, ' ', e.LastName) AS SalesRepName,
        r.Priority,
        r.BankName,
        r.AccountNumber,
        r.AccountTitle,
        r.BranchCode,
        r.Status,
        r.Website,
        r.Notes,
        r.Tags,
        r.CurrentBalance,
        r.IsActive,
        r.CreatedDate,
        r.UpdatedDate
    FROM Retailer r
    LEFT JOIN Employee e ON r.SalesRepID = e.EmployeeID
    ORDER BY r.CreatedDate DESC;
END
GO

PRINT 'sp_GetAllRetailers created successfully.';
GO

-- ================================================================================
-- 2. GET RETAILER BY ID (For Update/Delete/Details)
-- ================================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetRetailerById')
    DROP PROCEDURE sp_GetRetailerById;
GO

CREATE PROCEDURE sp_GetRetailerById
    @RetailerID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        r.RetailerID,
        r.CompanyName,
        r.BusinessType,
        r.RegistrationNumber,
        r.TaxId,
        r.ContactPerson,
        r.Designation,
        r.Phone,
        r.Email,
        r.AlternativePhone,
        r.Address,
        r.City,
        r.Province,
        r.PostalCode,
        r.CreditLimit,
        r.PaymentTerms,
        r.DiscountPercentage,
        r.SalesRepID,
        CONCAT(e.FirstName, ' ', e.LastName) AS SalesRepName,
        r.Priority,
        r.BankName,
        r.AccountNumber,
        r.AccountTitle,
        r.BranchCode,
        r.Status,
        r.Website,
        r.Notes,
        r.Tags,
        r.CurrentBalance,
        r.IsActive,
        r.CreatedDate,
        r.UpdatedDate
    FROM Retailer r
    LEFT JOIN Employee e ON r.SalesRepID = e.EmployeeID
    WHERE r.RetailerID = @RetailerID;
END
GO

PRINT 'sp_GetRetailerById created successfully.';
GO

-- ================================================================================
-- 3. ADD NEW RETAILER (For Add Tab)
-- ================================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_AddRetailer')
    DROP PROCEDURE sp_AddRetailer;
GO

CREATE PROCEDURE sp_AddRetailer
    -- Company Information
    @CompanyName NVARCHAR(100),
    @BusinessType NVARCHAR(50) = NULL,
    @RegistrationNumber NVARCHAR(50) = NULL,
    @TaxId NVARCHAR(50) = NULL,
    
    -- Contact Information
    @ContactPerson NVARCHAR(100) = NULL,
    @Designation NVARCHAR(50) = NULL,
    @Phone NVARCHAR(20) = NULL,
    @Email NVARCHAR(100) = NULL,
    @AlternativePhone NVARCHAR(20) = NULL,
    
    -- Location Information
    @Address NVARCHAR(500) = NULL,
    @City NVARCHAR(50) = NULL,
    @Province NVARCHAR(50) = NULL,
    @PostalCode NVARCHAR(10) = NULL,
    
    -- Business Terms
    @CreditLimit DECIMAL(18,2) = 0,
    @PaymentTerms NVARCHAR(30) = NULL,
    @DiscountPercentage DECIMAL(5,2) = 0,
    @SalesRepID INT = NULL,
    @Priority NVARCHAR(20) = 'Regular',
    
    -- Banking Information
    @BankName NVARCHAR(100) = NULL,
    @AccountNumber NVARCHAR(50) = NULL,
    @AccountTitle NVARCHAR(100) = NULL,
    @BranchCode NVARCHAR(20) = NULL,
    
    -- Additional Information
    @Status NVARCHAR(20) = 'Active',
    @Website NVARCHAR(200) = NULL,
    @Notes NVARCHAR(1000) = NULL,
    @Tags NVARCHAR(200) = NULL,
    
    @NewRetailerID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validate required fields
        IF @CompanyName IS NULL OR LTRIM(RTRIM(@CompanyName)) = ''
        BEGIN
            RAISERROR('Company Name is required.', 16, 1);
            RETURN;
        END
        
        -- Validate SalesRepID if provided
        IF @SalesRepID IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Employee WHERE EmployeeID = @SalesRepID)
        BEGIN
            RAISERROR('Invalid Sales Representative ID.', 16, 1);
            RETURN;
        END
        
        -- Insert new retailer
        INSERT INTO Retailer (
            CompanyName, BusinessType, RegistrationNumber, TaxId,
            ContactPerson, Designation, Phone, Email, AlternativePhone,
            Address, City, Province, PostalCode,
            CreditLimit, PaymentTerms, DiscountPercentage, SalesRepID, Priority,
            BankName, AccountNumber, AccountTitle, BranchCode,
            Status, Website, Notes, Tags,
            CurrentBalance, IsActive, CreatedDate
        )
        VALUES (
            @CompanyName, @BusinessType, @RegistrationNumber, @TaxId,
            @ContactPerson, @Designation, @Phone, @Email, @AlternativePhone,
            @Address, @City, @Province, @PostalCode,
            @CreditLimit, @PaymentTerms, @DiscountPercentage, @SalesRepID, @Priority,
            @BankName, @AccountNumber, @AccountTitle, @BranchCode,
            @Status, @Website, @Notes, @Tags,
            0, 1, GETDATE()
        );
        
        SET @NewRetailerID = SCOPE_IDENTITY();
        
        COMMIT TRANSACTION;
        
        PRINT 'Retailer added successfully with ID: ' + CAST(@NewRetailerID AS VARCHAR(10));
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

PRINT 'sp_AddRetailer created successfully.';
GO

-- ================================================================================
-- 4. UPDATE RETAILER (For Update Tab)
-- ================================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_UpdateRetailer')
    DROP PROCEDURE sp_UpdateRetailer;
GO

CREATE PROCEDURE sp_UpdateRetailer
    @RetailerID INT,
    
    -- Company Information
    @CompanyName NVARCHAR(100),
    @BusinessType NVARCHAR(50) = NULL,
    @RegistrationNumber NVARCHAR(50) = NULL,
    @TaxId NVARCHAR(50) = NULL,
    
    -- Contact Information
    @ContactPerson NVARCHAR(100) = NULL,
    @Designation NVARCHAR(50) = NULL,
    @Phone NVARCHAR(20) = NULL,
    @Email NVARCHAR(100) = NULL,
    @AlternativePhone NVARCHAR(20) = NULL,
    
    -- Location Information
    @Address NVARCHAR(500) = NULL,
    @City NVARCHAR(50) = NULL,
    @Province NVARCHAR(50) = NULL,
    @PostalCode NVARCHAR(10) = NULL,
    
    -- Business Terms
    @CreditLimit DECIMAL(18,2) = 0,
    @PaymentTerms NVARCHAR(30) = NULL,
    @DiscountPercentage DECIMAL(5,2) = 0,
    @SalesRepID INT = NULL,
    @Priority NVARCHAR(20) = 'Regular',
    
    -- Banking Information
    @BankName NVARCHAR(100) = NULL,
    @AccountNumber NVARCHAR(50) = NULL,
    @AccountTitle NVARCHAR(100) = NULL,
    @BranchCode NVARCHAR(20) = NULL,
    
    -- Additional Information
    @Status NVARCHAR(20) = 'Active',
    @Website NVARCHAR(200) = NULL,
    @Notes NVARCHAR(1000) = NULL,
    @Tags NVARCHAR(200) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validate retailer exists
        IF NOT EXISTS (SELECT 1 FROM Retailer WHERE RetailerID = @RetailerID)
        BEGIN
            RAISERROR('Retailer not found.', 16, 1);
            RETURN;
        END
        
        -- Validate required fields
        IF @CompanyName IS NULL OR LTRIM(RTRIM(@CompanyName)) = ''
        BEGIN
            RAISERROR('Company Name is required.', 16, 1);
            RETURN;
        END
        
        -- Validate SalesRepID if provided
        IF @SalesRepID IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Employee WHERE EmployeeID = @SalesRepID)
        BEGIN
            RAISERROR('Invalid Sales Representative ID.', 16, 1);
            RETURN;
        END
        
        -- Update retailer
        UPDATE Retailer
        SET 
            CompanyName = @CompanyName,
            BusinessType = @BusinessType,
            RegistrationNumber = @RegistrationNumber,
            TaxId = @TaxId,
            ContactPerson = @ContactPerson,
            Designation = @Designation,
            Phone = @Phone,
            Email = @Email,
            AlternativePhone = @AlternativePhone,
            Address = @Address,
            City = @City,
            Province = @Province,
            PostalCode = @PostalCode,
            CreditLimit = @CreditLimit,
            PaymentTerms = @PaymentTerms,
            DiscountPercentage = @DiscountPercentage,
            SalesRepID = @SalesRepID,
            Priority = @Priority,
            BankName = @BankName,
            AccountNumber = @AccountNumber,
            AccountTitle = @AccountTitle,
            BranchCode = @BranchCode,
            Status = @Status,
            Website = @Website,
            Notes = @Notes,
            Tags = @Tags,
            UpdatedDate = GETDATE()
        WHERE RetailerID = @RetailerID;
        
        COMMIT TRANSACTION;
        
        PRINT 'Retailer updated successfully.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

PRINT 'sp_UpdateRetailer created successfully.';
GO

-- ================================================================================
-- 5. DELETE RETAILER (For Delete Tab)
-- ================================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_DeleteRetailer')
    DROP PROCEDURE sp_DeleteRetailer;
GO

CREATE PROCEDURE sp_DeleteRetailer
    @RetailerID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validate retailer exists
        IF NOT EXISTS (SELECT 1 FROM Retailer WHERE RetailerID = @RetailerID)
        BEGIN
            RAISERROR('Retailer not found.', 16, 1);
            RETURN;
        END
        
        -- Check if retailer has any sales orders
        IF EXISTS (SELECT 1 FROM SalesOrder WHERE RetailerID = @RetailerID)
        BEGIN
            RAISERROR('Cannot delete retailer with existing sales orders. Please remove or reassign orders first.', 16, 1);
            RETURN;
        END
        
        -- Delete retailer
        DELETE FROM Retailer WHERE RetailerID = @RetailerID;
        
        COMMIT TRANSACTION;
        
        PRINT 'Retailer deleted successfully.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

PRINT 'sp_DeleteRetailer created successfully.';
GO

-- ================================================================================
-- 6. GET ALL SALES REPRESENTATIVES (For Dropdown in Add/Update Retailer)
-- ================================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetSalesRepresentatives')
    DROP PROCEDURE sp_GetSalesRepresentatives;
GO

CREATE PROCEDURE sp_GetSalesRepresentatives
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        e.EmployeeID,
        CONCAT(e.FirstName, ' ', e.LastName) AS FullName,
        e.Email,
        e.Phone,
        d.DepartmentName
    FROM Employee e
    INNER JOIN EmployeeRole r ON e.RoleID = r.RoleID
    INNER JOIN Department d ON e.DepartmentID = d.DepartmentID
    WHERE r.RoleName LIKE '%Sales%' 
       OR r.RoleName LIKE '%Representative%'
       OR r.RoleName LIKE '%Salesperson%'
       AND e.IsActive = 1
    ORDER BY e.FirstName, e.LastName;
END
GO

PRINT 'sp_GetSalesRepresentatives created successfully.';
GO

-- ================================================================================
-- 7. SEARCH RETAILERS (For Search/Filter functionality)
-- ================================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_SearchRetailers')
    DROP PROCEDURE sp_SearchRetailers;
GO

CREATE PROCEDURE sp_SearchRetailers
    @SearchTerm NVARCHAR(100) = NULL,
    @Status NVARCHAR(20) = NULL,
    @City NVARCHAR(50) = NULL,
    @Priority NVARCHAR(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        r.RetailerID,
        r.CompanyName,
        r.BusinessType,
        r.ContactPerson,
        r.Phone,
        r.Email,
        r.City,
        r.Province,
        r.CreditLimit,
        r.CurrentBalance,
        r.Priority,
        r.Status,
        CONCAT(e.FirstName, ' ', e.LastName) AS SalesRepName,
        r.CreatedDate
    FROM Retailer r
    LEFT JOIN Employee e ON r.SalesRepID = e.EmployeeID
    WHERE 
        (@SearchTerm IS NULL OR 
         r.CompanyName LIKE '%' + @SearchTerm + '%' OR
         r.ContactPerson LIKE '%' + @SearchTerm + '%' OR
         r.Phone LIKE '%' + @SearchTerm + '%' OR
         r.Email LIKE '%' + @SearchTerm + '%')
        AND (@Status IS NULL OR r.Status = @Status)
        AND (@City IS NULL OR r.City = @City)
        AND (@Priority IS NULL OR r.Priority = @Priority)
    ORDER BY r.CreatedDate DESC;
END
GO

PRINT 'sp_SearchRetailers created successfully.';
GO

-- ================================================================================
-- 8. GET RETAILER STATISTICS (For Dashboard/Summary)
-- ================================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetRetailerStatistics')
    DROP PROCEDURE sp_GetRetailerStatistics;
GO

CREATE PROCEDURE sp_GetRetailerStatistics
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        COUNT(*) AS TotalRetailers,
        SUM(CASE WHEN Status = 'Active' THEN 1 ELSE 0 END) AS ActiveRetailers,
        SUM(CASE WHEN Status = 'Inactive' THEN 1 ELSE 0 END) AS InactiveRetailers,
        SUM(CASE WHEN Status = 'Blocked' THEN 1 ELSE 0 END) AS BlockedRetailers,
        SUM(CASE WHEN Priority = 'VIP' THEN 1 ELSE 0 END) AS VIPRetailers,
        SUM(CASE WHEN Priority = 'Premium' THEN 1 ELSE 0 END) AS PremiumRetailers,
        SUM(CreditLimit) AS TotalCreditLimit,
        SUM(CurrentBalance) AS TotalOutstandingBalance,
        AVG(CreditLimit) AS AverageCreditLimit
    FROM Retailer
    WHERE IsActive = 1;
END
GO

PRINT 'sp_GetRetailerStatistics created successfully.';
GO

-- ================================================================================
-- 9. UPDATE RETAILER BALANCE (For Payment/Order transactions)
-- ================================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_UpdateRetailerBalance')
    DROP PROCEDURE sp_UpdateRetailerBalance;
GO

CREATE PROCEDURE sp_UpdateRetailerBalance
    @RetailerID INT,
    @Amount DECIMAL(18,2),
    @TransactionType NVARCHAR(20) -- 'Credit' or 'Debit'
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validate retailer exists
        IF NOT EXISTS (SELECT 1 FROM Retailer WHERE RetailerID = @RetailerID)
        BEGIN
            RAISERROR('Retailer not found.', 16, 1);
            RETURN;
        END
        
        -- Update balance based on transaction type
        IF @TransactionType = 'Credit'
        BEGIN
            UPDATE Retailer
            SET CurrentBalance = CurrentBalance + @Amount,
                UpdatedDate = GETDATE()
            WHERE RetailerID = @RetailerID;
        END
        ELSE IF @TransactionType = 'Debit'
        BEGIN
            UPDATE Retailer
            SET CurrentBalance = CurrentBalance - @Amount,
                UpdatedDate = GETDATE()
            WHERE RetailerID = @RetailerID;
        END
        ELSE
        BEGIN
            RAISERROR('Invalid transaction type. Use ''Credit'' or ''Debit''.', 16, 1);
            RETURN;
        END
        
        COMMIT TRANSACTION;
        
        PRINT 'Retailer balance updated successfully.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

PRINT 'sp_UpdateRetailerBalance created successfully.';
GO

-- ================================================================================
-- 10. GET RETAILERS WITH OUTSTANDING BALANCES (For Reports)
-- ================================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetRetailersWithOutstandingBalance')
    DROP PROCEDURE sp_GetRetailersWithOutstandingBalance;
GO

CREATE PROCEDURE sp_GetRetailersWithOutstandingBalance
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        r.RetailerID,
        r.CompanyName,
        r.ContactPerson,
        r.Phone,
        r.Email,
        r.CreditLimit,
        r.CurrentBalance,
        (r.CreditLimit - r.CurrentBalance) AS AvailableCredit,
        r.PaymentTerms,
        CONCAT(e.FirstName, ' ', e.LastName) AS SalesRepName,
        r.Status
    FROM Retailer r
    LEFT JOIN Employee e ON r.SalesRepID = e.EmployeeID
    WHERE r.CurrentBalance > 0
    ORDER BY r.CurrentBalance DESC;
END
GO

PRINT 'sp_GetRetailersWithOutstandingBalance created successfully.';
GO

-- ================================================================================
-- STORED PROCEDURES CREATION COMPLETE!
-- ================================================================================
PRINT '';
PRINT '========================================';
PRINT 'RETAILER PROCEDURES CREATED SUCCESSFULLY!';
PRINT 'Total Procedures: 10';
PRINT '';
PRINT 'Procedures Created:';
PRINT '1. sp_GetAllRetailers';
PRINT '2. sp_GetRetailerById';
PRINT '3. sp_AddRetailer';
PRINT '4. sp_UpdateRetailer';
PRINT '5. sp_DeleteRetailer';
PRINT '6. sp_GetSalesRepresentatives';
PRINT '7. sp_SearchRetailers';
PRINT '8. sp_GetRetailerStatistics';
PRINT '9. sp_UpdateRetailerBalance';
PRINT '10. sp_GetRetailersWithOutstandingBalance';
PRINT '';
PRINT 'Next Step: Execute this script in SSMS';
PRINT 'Then we will create the RetailerDataService.';
PRINT '========================================';
GO
