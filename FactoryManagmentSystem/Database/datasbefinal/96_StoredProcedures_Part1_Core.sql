-- ================================================================================
-- GARMENTS FACTORY MANAGEMENT SYSTEM - STORED PROCEDURES
-- PART 1: CORE MANAGEMENT PROCEDURES
-- ================================================================================
-- Database: GarmentsFactoryDB
-- Purpose: Employee, Department, Role, Product, Raw Material, and Retailer Management
-- Created: December 2025
-- Total Procedures in this file: ~40 procedures
-- ================================================================================

USE GarmentsFactoryDB;
GO

-- ================================================================================
-- SECTION 1: AUTHENTICATION & USER MANAGEMENT
-- ================================================================================

-- PROCEDURE: sp_AuthenticateUser
-- Purpose: Authenticate user login with username and PIN
-- Used by: Login screen in WPF application
-- Parameters: @Username, @PIN
-- Returns: User details if authentication successful
IF OBJECT_ID('sp_AuthenticateUser', 'P') IS NOT NULL
    DROP PROCEDURE sp_AuthenticateUser;
GO

CREATE PROCEDURE sp_AuthenticateUser
    @Username NVARCHAR(100),
    @PIN NVARCHAR(8)
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Return employee details if credentials match
    SELECT 
        e.EmployeeID,
        e.FirstName,
        e.LastName,
        e.FirstName + ' ' + e.LastName AS FullName,
        e.Email,
        e.Phone,
        e.Username,
        e.LastLogin,
        e.DepartmentID,
        d.DepartmentName,
        e.RoleID,
        r.RoleName AS Role
    FROM Employee e
    JOIN Department d ON e.DepartmentID = d.DepartmentID
    JOIN EmployeeRole r ON e.RoleID = r.RoleID
    WHERE e.Username = @Username 
      AND e.PIN = @PIN 
      AND e.IsActive = 1;
END
GO

PRINT '✓ sp_AuthenticateUser created';
GO

-- PROCEDURE: sp_UpdateLastLogin
-- Purpose: Update employee's last login timestamp
-- Used by: Login system after successful authentication
IF OBJECT_ID('sp_UpdateLastLogin', 'P') IS NOT NULL
    DROP PROCEDURE sp_UpdateLastLogin;
GO

CREATE PROCEDURE sp_UpdateLastLogin
    @EmployeeID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE Employee 
    SET LastLogin = GETDATE()
    WHERE EmployeeID = @EmployeeID;
END
GO

PRINT '✓ sp_UpdateLastLogin created';
GO

-- PROCEDURE: sp_UpdateEmployeeCredentials
-- Purpose: Update employee username and PIN
-- Used by: Admin panel for credential management
IF OBJECT_ID('sp_UpdateEmployeeCredentials', 'P') IS NOT NULL
    DROP PROCEDURE sp_UpdateEmployeeCredentials;
GO

CREATE PROCEDURE sp_UpdateEmployeeCredentials
    @EmployeeID INT,
    @Username NVARCHAR(100),
    @PIN NVARCHAR(8)
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE Employee
    SET Username = @Username,
        PIN = @PIN
    WHERE EmployeeID = @EmployeeID;
END
GO

PRINT '✓ sp_UpdateEmployeeCredentials created';
GO

-- ================================================================================
-- SECTION 2: DEPARTMENT MANAGEMENT
-- ================================================================================

-- PROCEDURE: sp_GetAllDepartments
-- Purpose: Retrieve all active departments
-- Used by: Department dropdown lists, department management screens
IF OBJECT_ID('sp_GetAllDepartments', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetAllDepartments;
GO

CREATE PROCEDURE sp_GetAllDepartments
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        DepartmentID,
        DepartmentName,
        Description,
        CreatedDate,
        IsActive
    FROM Department
    WHERE IsActive = 1
    ORDER BY DepartmentName;
END
GO

PRINT '✓ sp_GetAllDepartments created';
GO

-- PROCEDURE: sp_GetDepartmentById
-- Purpose: Get specific department details
IF OBJECT_ID('sp_GetDepartmentById', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetDepartmentById;
GO

CREATE PROCEDURE sp_GetDepartmentById
    @DepartmentID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        DepartmentID,
        DepartmentName,
        Description,
        CreatedDate,
        IsActive
    FROM Department
    WHERE DepartmentID = @DepartmentID;
END
GO

PRINT '✓ sp_GetDepartmentById created';
GO

-- PROCEDURE: sp_AddDepartment
-- Purpose: Create a new department
IF OBJECT_ID('sp_AddDepartment', 'P') IS NOT NULL
    DROP PROCEDURE sp_AddDepartment;
GO

CREATE PROCEDURE sp_AddDepartment
    @DepartmentName NVARCHAR(200),
    @Description NVARCHAR(1000) = NULL,
    @NewDepartmentID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO Department (DepartmentName, Description, CreatedDate, IsActive)
    VALUES (@DepartmentName, @Description, GETDATE(), 1);
    
    SET @NewDepartmentID = SCOPE_IDENTITY();
END
GO

PRINT '✓ sp_AddDepartment created';
GO

-- PROCEDURE: sp_UpdateDepartment
-- Purpose: Update department information
IF OBJECT_ID('sp_UpdateDepartment', 'P') IS NOT NULL
    DROP PROCEDURE sp_UpdateDepartment;
GO

CREATE PROCEDURE sp_UpdateDepartment
    @DepartmentID INT,
    @DepartmentName NVARCHAR(200),
    @Description NVARCHAR(1000) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE Department
    SET DepartmentName = @DepartmentName,
        Description = @Description
    WHERE DepartmentID = @DepartmentID;
END
GO

PRINT '✓ sp_UpdateDepartment created';
GO

-- PROCEDURE: sp_DeleteDepartment
-- Purpose: Soft delete department (mark as inactive)
IF OBJECT_ID('sp_DeleteDepartment', 'P') IS NOT NULL
    DROP PROCEDURE sp_DeleteDepartment;
GO

CREATE PROCEDURE sp_DeleteDepartment
    @DepartmentID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE Department
    SET IsActive = 0
    WHERE DepartmentID = @DepartmentID;
END
GO

PRINT '✓ sp_DeleteDepartment created';
GO

-- PROCEDURE: sp_GetDepartmentsWithEmployeeCount
-- Purpose: Get departments with employee counts for statistics
IF OBJECT_ID('sp_GetDepartmentsWithEmployeeCount', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetDepartmentsWithEmployeeCount;
GO

CREATE PROCEDURE sp_GetDepartmentsWithEmployeeCount
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        d.DepartmentID,
        d.DepartmentName,
        d.Description,
        COUNT(e.EmployeeID) AS EmployeeCount
    FROM Department d
    LEFT JOIN Employee e ON d.DepartmentID = e.DepartmentID AND e.IsActive = 1
    WHERE d.IsActive = 1
    GROUP BY d.DepartmentID, d.DepartmentName, d.Description
    ORDER BY d.DepartmentName;
END
GO

PRINT '✓ sp_GetDepartmentsWithEmployeeCount created';
GO

-- ================================================================================
-- SECTION 3: EMPLOYEE MANAGEMENT
-- ================================================================================

-- PROCEDURE: sp_GetEmployees
-- Purpose: Retrieve all active employees with department and role information (with pagination)
-- Used by: Employee management screens, reports
IF OBJECT_ID('sp_GetEmployees', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetEmployees;
GO

CREATE PROCEDURE sp_GetEmployees
    @PageNumber INT = 1,
    @PageSize INT = 50,
    @SearchTerm NVARCHAR(200) = ''
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @Offset INT = (@PageNumber - 1) * @PageSize;
    
    -- Get total count
    DECLARE @TotalCount INT;
    SELECT @TotalCount = COUNT(*)
    FROM Employee e
    WHERE e.IsActive = 1
        AND (@SearchTerm = '' 
            OR e.FirstName LIKE '%' + @SearchTerm + '%'
            OR e.LastName LIKE '%' + @SearchTerm + '%'
            OR e.Email LIKE '%' + @SearchTerm + '%'
            OR e.Username LIKE '%' + @SearchTerm + '%');
    
    -- Get paginated results with total count
    SELECT 
        e.EmployeeID,
        e.FirstName,
        e.LastName,
        e.Email,
        e.Phone,
        e.DepartmentID,
        d.DepartmentName,
        e.RoleID,
        r.RoleName,
        e.Salary,
        e.JoinDate,
        e.Address,
        e.EmergencyContact,
        e.CNIC,
        e.IsActive,
        e.CreatedDate,
        e.Username,
        e.Position,
        @TotalCount AS TotalCount
    FROM Employee e
    JOIN Department d ON e.DepartmentID = d.DepartmentID
    JOIN EmployeeRole r ON e.RoleID = r.RoleID
    WHERE e.IsActive = 1
        AND (@SearchTerm = '' 
            OR e.FirstName LIKE '%' + @SearchTerm + '%'
            OR e.LastName LIKE '%' + @SearchTerm + '%'
            OR e.Email LIKE '%' + @SearchTerm + '%'
            OR e.Username LIKE '%' + @SearchTerm + '%')
    ORDER BY e.FirstName, e.LastName
    OFFSET @Offset ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END
GO

PRINT '✓ sp_GetEmployees created';
GO

-- PROCEDURE: sp_GetEmployeeById
-- Purpose: Get specific employee details
IF OBJECT_ID('sp_GetEmployeeById', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetEmployeeById;
GO

CREATE PROCEDURE sp_GetEmployeeById
    @EmployeeID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        e.EmployeeID,
        e.FirstName,
        e.LastName,
        e.Email,
        e.Phone,
        e.DepartmentID,
        d.DepartmentName,
        e.RoleID,
        r.RoleName,
        e.Salary,
        e.JoinDate,
        e.Address,
        e.EmergencyContact,
        e.CNIC,
        e.IsActive,
        e.CreatedDate,
        e.Username,
        e.LastLogin,
        e.PIN,
        e.Position
    FROM Employee e
    JOIN Department d ON e.DepartmentID = d.DepartmentID
    JOIN EmployeeRole r ON e.RoleID = r.RoleID
    WHERE e.EmployeeID = @EmployeeID;
END
GO

PRINT '✓ sp_GetEmployeeById created';
GO

-- PROCEDURE: sp_AddEmployee
-- Purpose: Create a new employee record
-- Used by: HR/Admin screens for adding new employees
IF OBJECT_ID('sp_AddEmployee', 'P') IS NOT NULL
    DROP PROCEDURE sp_AddEmployee;
GO

CREATE PROCEDURE sp_AddEmployee
    @FirstName NVARCHAR(100),
    @LastName NVARCHAR(100),
    @Email NVARCHAR(200) = NULL,
    @Phone NVARCHAR(40) = NULL,
    @DepartmentID INT,
    @RoleID INT,
    @Salary DECIMAL(18,2) = NULL,
    @JoinDate DATE = NULL,
    @Address NVARCHAR(1000) = NULL,
    @EmergencyContact NVARCHAR(200) = NULL,
    @CNIC NVARCHAR(30) = NULL,
    @Username NVARCHAR(100) = NULL,
    @PIN NVARCHAR(8) = NULL,
    @Position NVARCHAR(200) = NULL,
    @NewEmployeeID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO Employee (
        FirstName, LastName, Email, Phone, DepartmentID, RoleID, Salary, JoinDate,
        Address, EmergencyContact, CNIC, IsActive, CreatedDate, Username, PIN, Position
    )
    VALUES (
        @FirstName, @LastName, @Email, @Phone, @DepartmentID, @RoleID, @Salary, @JoinDate,
        @Address, @EmergencyContact, @CNIC, 1, GETDATE(), @Username, @PIN, @Position
    );
    
    SET @NewEmployeeID = SCOPE_IDENTITY();
END
GO

PRINT '✓ sp_AddEmployee created';
GO

-- PROCEDURE: sp_UpdateEmployee
-- Purpose: Update employee information
IF OBJECT_ID('sp_UpdateEmployee', 'P') IS NOT NULL
    DROP PROCEDURE sp_UpdateEmployee;
GO

CREATE PROCEDURE sp_UpdateEmployee
    @EmployeeID INT,
    @FirstName NVARCHAR(100),
    @LastName NVARCHAR(100),
    @Email NVARCHAR(200) = NULL,
    @Phone NVARCHAR(40) = NULL,
    @DepartmentID INT,
    @RoleID INT,
    @Salary DECIMAL(18,2) = NULL,
    @JoinDate DATE = NULL,
    @Address NVARCHAR(1000) = NULL,
    @EmergencyContact NVARCHAR(200) = NULL,
    @CNIC NVARCHAR(30) = NULL,
    @Position NVARCHAR(200) = NULL,
    @Username NVARCHAR(100) = NULL,
    @PIN NVARCHAR(8) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE Employee
    SET FirstName = @FirstName,
        LastName = @LastName,
        Email = @Email,
        Phone = @Phone,
        DepartmentID = @DepartmentID,
        RoleID = @RoleID,
        Salary = @Salary,
        JoinDate = @JoinDate,
        Address = @Address,
        EmergencyContact = @EmergencyContact,
        CNIC = @CNIC,
        Position = @Position,
        Username = @Username,
        PIN = @PIN
    WHERE EmployeeID = @EmployeeID;
END
GO

PRINT '✓ sp_UpdateEmployee created';
GO

-- PROCEDURE: sp_DeleteEmployee
-- Purpose: Permanently delete employee (hard delete)
IF OBJECT_ID('sp_DeleteEmployee', 'P') IS NOT NULL
    DROP PROCEDURE sp_DeleteEmployee;
GO

CREATE PROCEDURE sp_DeleteEmployee
    @EmployeeID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Permanently delete the employee record
    DELETE FROM Employee
    WHERE EmployeeID = @EmployeeID;
    
    -- Return number of rows affected
    SELECT @@ROWCOUNT AS RowsAffected;
END
GO

PRINT '✓ sp_DeleteEmployee created';
GO

-- PROCEDURE: sp_GetEmployeesByDepartment
-- Purpose: Get all employees in a specific department
IF OBJECT_ID('sp_GetEmployeesByDepartment', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetEmployeesByDepartment;
GO

CREATE PROCEDURE sp_GetEmployeesByDepartment
    @DepartmentID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        e.EmployeeID,
        e.FirstName,
        e.LastName,
        e.Email,
        e.Phone,
        r.RoleName,
        e.Salary,
        e.JoinDate
    FROM Employee e
    JOIN EmployeeRole r ON e.RoleID = r.RoleID
    WHERE e.DepartmentID = @DepartmentID 
      AND e.IsActive = 1
    ORDER BY e.FirstName, e.LastName;
END
GO

PRINT '✓ sp_GetEmployeesByDepartment created';
GO

-- PROCEDURE: sp_GetEmployeeRoles
-- Purpose: Get all employee roles for dropdown lists
IF OBJECT_ID('sp_GetEmployeeRoles', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetEmployeeRoles;
GO

CREATE PROCEDURE sp_GetEmployeeRoles
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        RoleID,
        RoleName,
        Description
    FROM EmployeeRole
    WHERE IsActive = 1
    ORDER BY RoleName;
END
GO

PRINT '✓ sp_GetEmployeeRoles created';
GO

-- ================================================================================
-- SECTION 4: PRODUCT MANAGEMENT
-- ================================================================================

-- PROCEDURE: sp_GetAllProducts
-- Purpose: Retrieve all active products
-- Used by: Product management, order creation, inventory screens
IF OBJECT_ID('sp_GetAllProducts', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetAllProducts;
GO

CREATE PROCEDURE sp_GetAllProducts
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        ProductID,
        ProductName,
        Description,
        Category,
        Brand,
        SalePrice,
        Material,
        AvailableSizes,
        AvailableColors,
        ProductionStatus,
        SKU,
        IsActive,
        CreatedDate,
        UpdatedDate
    FROM Product
    WHERE IsActive = 1
    ORDER BY ProductName;
END
GO

PRINT '✓ sp_GetAllProducts created';
GO

-- PROCEDURE: sp_GetProductById
-- Purpose: Get specific product details
IF OBJECT_ID('sp_GetProductById', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetProductById;
GO

CREATE PROCEDURE sp_GetProductById
    @ProductID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        ProductID,
        ProductName,
        Description,
        Category,
        Brand,
        SalePrice,
        Material,
        AvailableSizes,
        AvailableColors,
        ProductionStatus,
        SKU,
        IsActive,
        CreatedDate,
        UpdatedDate
    FROM Product
    WHERE ProductID = @ProductID;
END
GO

PRINT '✓ sp_GetProductById created';
GO

-- PROCEDURE: sp_AddProduct
-- Purpose: Create a new product
-- Used by: Product management screen for adding new products
IF OBJECT_ID('sp_AddProduct', 'P') IS NOT NULL
    DROP PROCEDURE sp_AddProduct;
GO

CREATE PROCEDURE sp_AddProduct
    @ProductName NVARCHAR(200),
    @Description NVARCHAR(2000) = NULL,
    @Category NVARCHAR(100) = NULL,
    @Brand NVARCHAR(200) = NULL,
    @SalePrice DECIMAL(18,2),
    @Material NVARCHAR(100) = NULL,
    @AvailableSizes NVARCHAR(200) = NULL,
    @AvailableColors NVARCHAR(400) = NULL,
    @ProductionStatus NVARCHAR(60) = 'Active',
    @SKU NVARCHAR(100) = NULL,
    @NewProductID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO Product (
        ProductName, Description, Category, Brand, SalePrice, Material,
        AvailableSizes, AvailableColors, ProductionStatus, SKU, IsActive, CreatedDate
    )
    VALUES (
        @ProductName, @Description, @Category, @Brand, @SalePrice, @Material,
        @AvailableSizes, @AvailableColors, @ProductionStatus, @SKU, 1, GETDATE()
    );
    
    SET @NewProductID = SCOPE_IDENTITY();
END
GO

PRINT '✓ sp_AddProduct created';
GO

-- PROCEDURE: sp_UpdateProduct
-- Purpose: Update product information
IF OBJECT_ID('sp_UpdateProduct', 'P') IS NOT NULL
    DROP PROCEDURE sp_UpdateProduct;
GO

CREATE PROCEDURE sp_UpdateProduct
    @ProductID INT,
    @ProductName NVARCHAR(200),
    @Description NVARCHAR(2000) = NULL,
    @Category NVARCHAR(100) = NULL,
    @Brand NVARCHAR(200) = NULL,
    @SalePrice DECIMAL(18,2),
    @Material NVARCHAR(100) = NULL,
    @AvailableSizes NVARCHAR(200) = NULL,
    @AvailableColors NVARCHAR(400) = NULL,
    @ProductionStatus NVARCHAR(60) = NULL,
    @SKU NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE Product
    SET ProductName = @ProductName,
        Description = @Description,
        Category = @Category,
        Brand = @Brand,
        SalePrice = @SalePrice,
        Material = @Material,
        AvailableSizes = @AvailableSizes,
        AvailableColors = @AvailableColors,
        ProductionStatus = @ProductionStatus,
        SKU = @SKU,
        UpdatedDate = GETDATE()
    WHERE ProductID = @ProductID;
END
GO

PRINT '✓ sp_UpdateProduct created';
GO

-- PROCEDURE: sp_DeleteProduct
-- Purpose: Soft delete product (mark as inactive)
IF OBJECT_ID('sp_DeleteProduct', 'P') IS NOT NULL
    DROP PROCEDURE sp_DeleteProduct;
GO

CREATE PROCEDURE sp_DeleteProduct
    @ProductID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE Product
    SET IsActive = 0,
        UpdatedDate = GETDATE()
    WHERE ProductID = @ProductID;
END
GO

PRINT '✓ sp_DeleteProduct created';
GO

-- PROCEDURE: sp_SearchProducts
-- Purpose: Search products by name, category, or SKU
IF OBJECT_ID('sp_SearchProducts', 'P') IS NOT NULL
    DROP PROCEDURE sp_SearchProducts;
GO

CREATE PROCEDURE sp_SearchProducts
    @SearchTerm NVARCHAR(200)
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        ProductID,
        ProductName,
        Description,
        Category,
        Brand,
        SalePrice,
        SKU,
        ProductionStatus
    FROM Product
    WHERE IsActive = 1
      AND (ProductName LIKE '%' + @SearchTerm + '%'
           OR Category LIKE '%' + @SearchTerm + '%'
           OR SKU LIKE '%' + @SearchTerm + '%')
    ORDER BY ProductName;
END
GO

PRINT '✓ sp_SearchProducts created';
GO

-- ================================================================================
-- SECTION 5: RAW MATERIAL MANAGEMENT
-- ================================================================================

-- PROCEDURE: sp_GetAllRawMaterials
-- Purpose: Retrieve all active raw materials with stock status
-- Used by: Raw material management, inventory screens
IF OBJECT_ID('sp_GetAllRawMaterials', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetAllRawMaterials;
GO

CREATE PROCEDURE sp_GetAllRawMaterials
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        RawMaterialID,
        MaterialName,
        Category,
        Unit,
        Quantity,
        MinimumStock,
        UnitPrice,
        Supplier,
        SupplierContact,
        Description,
        StockStatus,
        (Quantity * UnitPrice) AS TotalValue,
        LastRestockDate,
        IsActive,
        CreatedDate,
        UpdatedDate
    FROM RawMaterial
    WHERE IsActive = 1
    ORDER BY MaterialName;
END
GO

PRINT '✓ sp_GetAllRawMaterials created';
GO

-- PROCEDURE: sp_GetRawMaterialById
-- Purpose: Get specific raw material details
IF OBJECT_ID('sp_GetRawMaterialById', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetRawMaterialById;
GO

CREATE PROCEDURE sp_GetRawMaterialById
    @RawMaterialID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        RawMaterialID,
        MaterialName,
        Category,
        Unit,
        Quantity,
        MinimumStock,
        UnitPrice,
        Supplier,
        SupplierContact,
        Description,
        StockStatus,
        LastRestockDate,
        IsActive,
        CreatedDate,
        UpdatedDate
    FROM RawMaterial
    WHERE RawMaterialID = @RawMaterialID;
END
GO

PRINT '✓ sp_GetRawMaterialById created';
GO

-- PROCEDURE: sp_CreateRawMaterial
-- Purpose: Create new raw material and AUTO-RECORD PURCHASE if quantity > 0
-- Used by: Raw material management screen
-- Automation: Automatically creates RawMaterialPurchase record
IF OBJECT_ID('sp_CreateRawMaterial', 'P') IS NOT NULL
    DROP PROCEDURE sp_CreateRawMaterial;
GO

CREATE PROCEDURE sp_CreateRawMaterial
    @MaterialName NVARCHAR(200),
    @Category NVARCHAR(100) = NULL,
    @Unit NVARCHAR(40) = NULL,
    @Quantity DECIMAL(18,2) = 0,
    @MinimumStock DECIMAL(18,2) = 0,
    @UnitPrice DECIMAL(18,2) = 0,
    @Supplier NVARCHAR(200) = NULL,
    @SupplierContact NVARCHAR(200) = NULL,
    @Description NVARCHAR(1000) = NULL,
    @RawMaterialID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Insert Raw Material
        INSERT INTO RawMaterial (
            MaterialName, Category, Unit, Quantity, MinimumStock, UnitPrice,
            Supplier, SupplierContact, Description, LastRestockDate, IsActive, CreatedDate
        )
        VALUES (
            @MaterialName, @Category, @Unit, @Quantity, @MinimumStock, @UnitPrice,
            @Supplier, @SupplierContact, @Description,
            CASE WHEN @Quantity > 0 THEN CAST(GETDATE() AS DATE) ELSE NULL END,
            1, GETDATE()
        );

        SET @RawMaterialID = SCOPE_IDENTITY();

        -- AUTO-RECORD PURCHASE if quantity > 0
        IF @Quantity > 0 AND @UnitPrice > 0
        BEGIN
            DECLARE @TotalAmount DECIMAL(18,2) = @Quantity * @UnitPrice;
            
            INSERT INTO RawMaterialPurchase 
                (RawMaterialID, MaterialName, PurchaseDate, Quantity, Unit, UnitPrice, TotalAmount, SupplierName, Notes)
            VALUES 
                (@RawMaterialID, @MaterialName, GETDATE(), @Quantity, @Unit, @UnitPrice, @TotalAmount, @Supplier, 'Initial stock purchase');
        END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

PRINT '✓ sp_CreateRawMaterial created (with auto-purchase recording)';
GO

-- PROCEDURE: sp_UpdateRawMaterial
-- Purpose: Update raw material and AUTO-RECORD PURCHASE if quantity increased
-- Automation: Automatically creates RawMaterialPurchase record for quantity increases
IF OBJECT_ID('sp_UpdateRawMaterial', 'P') IS NOT NULL
    DROP PROCEDURE sp_UpdateRawMaterial;
GO

CREATE PROCEDURE sp_UpdateRawMaterial
    @RawMaterialID INT,
    @MaterialName NVARCHAR(200),
    @Category NVARCHAR(100) = NULL,
    @Unit NVARCHAR(40) = NULL,
    @Quantity DECIMAL(18,2) = 0,
    @MinimumStock DECIMAL(18,2) = 0,
    @UnitPrice DECIMAL(18,2) = 0,
    @Supplier NVARCHAR(200) = NULL,
    @SupplierContact NVARCHAR(200) = NULL,
    @Description NVARCHAR(1000) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Get old values
        DECLARE @OldQuantity DECIMAL(18,2), @OldUnitPrice DECIMAL(18,2);
        SELECT @OldQuantity = Quantity, @OldUnitPrice = UnitPrice
        FROM RawMaterial WHERE RawMaterialID = @RawMaterialID;

        -- Calculate quantity difference
        DECLARE @QuantityDiff DECIMAL(18,2) = @Quantity - @OldQuantity;

        -- Update Raw Material
        UPDATE RawMaterial
        SET 
            MaterialName = @MaterialName,
            Category = @Category,
            Unit = @Unit,
            Quantity = @Quantity,
            MinimumStock = @MinimumStock,
            UnitPrice = @UnitPrice,
            Supplier = @Supplier,
            SupplierContact = @SupplierContact,
            Description = @Description,
            UpdatedDate = GETDATE(),
            LastRestockDate = CASE WHEN @QuantityDiff > 0 THEN GETDATE() ELSE LastRestockDate END
        WHERE RawMaterialID = @RawMaterialID;

        -- If quantity INCREASED, record as purchase
        IF @QuantityDiff > 0 AND @UnitPrice > 0
        BEGIN
            DECLARE @PurchaseAmount DECIMAL(18,2) = @QuantityDiff * @UnitPrice;
            
            INSERT INTO RawMaterialPurchase 
                (RawMaterialID, MaterialName, PurchaseDate, Quantity, Unit, UnitPrice, TotalAmount, SupplierName, Notes)
            VALUES 
                (@RawMaterialID, @MaterialName, GETDATE(), @QuantityDiff, @Unit, @UnitPrice, @PurchaseAmount, @Supplier, 'Stock update - quantity added');
        END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

PRINT '✓ sp_UpdateRawMaterial created (with auto-purchase recording)';
GO

-- PROCEDURE: sp_RestockRawMaterial
-- Purpose: Restock raw material and AUTO-RECORD PURCHASE
-- Automation: Automatically creates RawMaterialPurchase record
IF OBJECT_ID('sp_RestockRawMaterial', 'P') IS NOT NULL
    DROP PROCEDURE sp_RestockRawMaterial;
GO

CREATE PROCEDURE sp_RestockRawMaterial
    @RawMaterialID INT,
    @Quantity DECIMAL(18,2),
    @UnitPrice DECIMAL(18,2),
    @Supplier NVARCHAR(200) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Get material details
        DECLARE @MaterialName NVARCHAR(200), @Unit NVARCHAR(40);
        SELECT @MaterialName = MaterialName, @Unit = Unit
        FROM RawMaterial WHERE RawMaterialID = @RawMaterialID;

        -- Update quantity
        UPDATE RawMaterial
        SET Quantity = Quantity + @Quantity,
            LastRestockDate = GETDATE(),
            UnitPrice = @UnitPrice,
            Supplier = ISNULL(@Supplier, Supplier),
            UpdatedDate = GETDATE()
        WHERE RawMaterialID = @RawMaterialID;

        -- AUTO-RECORD PURCHASE
        DECLARE @TotalAmount DECIMAL(18,2) = @Quantity * @UnitPrice;
        
        INSERT INTO RawMaterialPurchase 
            (RawMaterialID, MaterialName, PurchaseDate, Quantity, Unit, UnitPrice, TotalAmount, SupplierName, Notes)
        VALUES 
            (@RawMaterialID, @MaterialName, GETDATE(), @Quantity, @Unit, @UnitPrice, @TotalAmount, @Supplier, 'Restock purchase');

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

PRINT '✓ sp_RestockRawMaterial created (with auto-purchase recording)';
GO

-- PROCEDURE: sp_DeleteRawMaterial
-- Purpose: Soft delete raw material (mark as inactive)
IF OBJECT_ID('sp_DeleteRawMaterial', 'P') IS NOT NULL
    DROP PROCEDURE sp_DeleteRawMaterial;
GO

CREATE PROCEDURE sp_DeleteRawMaterial
    @RawMaterialID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE RawMaterial
    SET IsActive = 0,
        UpdatedDate = GETDATE()
    WHERE RawMaterialID = @RawMaterialID;
END
GO

PRINT '✓ sp_DeleteRawMaterial created';
GO

-- PROCEDURE: sp_SearchRawMaterials
-- Purpose: Search raw materials by name or category
IF OBJECT_ID('sp_SearchRawMaterials', 'P') IS NOT NULL
    DROP PROCEDURE sp_SearchRawMaterials;
GO

CREATE PROCEDURE sp_SearchRawMaterials
    @SearchTerm NVARCHAR(200)
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        RawMaterialID,
        MaterialName,
        Category,
        Unit,
        Quantity,
        MinimumStock,
        UnitPrice,
        Supplier,
        StockStatus
    FROM RawMaterial
    WHERE IsActive = 1
      AND (MaterialName LIKE '%' + @SearchTerm + '%'
           OR Category LIKE '%' + @SearchTerm + '%')
    ORDER BY MaterialName;
END
GO

PRINT '✓ sp_SearchRawMaterials created';
GO

-- ================================================================================
-- SECTION 6: RETAILER MANAGEMENT
-- ================================================================================

-- PROCEDURE: sp_GetAllRetailers
-- Purpose: Retrieve all active retailers
-- Used by: Retailer management, sales order creation
IF OBJECT_ID('sp_GetAllRetailers', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetAllRetailers;
GO

CREATE PROCEDURE sp_GetAllRetailers
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        RetailerID,
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
    FROM Retailer
    WHERE IsActive = 1
    ORDER BY CompanyName;
END
GO

PRINT '✓ sp_GetAllRetailers created';
GO

-- PROCEDURE: sp_GetRetailerById
-- Purpose: Get specific retailer details
IF OBJECT_ID('sp_GetRetailerById', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetRetailerById;
GO

CREATE PROCEDURE sp_GetRetailerById
    @RetailerID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        RetailerID,
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
    FROM Retailer
    WHERE RetailerID = @RetailerID;
END
GO

PRINT '✓ sp_GetRetailerById created';
GO

-- PROCEDURE: sp_AddRetailer
-- Purpose: Create a new retailer
-- Used by: Retailer management screen
IF OBJECT_ID('sp_AddRetailer', 'P') IS NOT NULL
    DROP PROCEDURE sp_AddRetailer;
GO

CREATE PROCEDURE sp_AddRetailer
    @CompanyName NVARCHAR(200),
    @ContactPerson NVARCHAR(200) = NULL,
    @Phone NVARCHAR(40) = NULL,
    @Email NVARCHAR(200) = NULL,
    @AlternativePhone NVARCHAR(40) = NULL,
    @Address NVARCHAR(1000) = NULL,
    @City NVARCHAR(100) = NULL,
    @Province NVARCHAR(100) = NULL,
    @PostalCode NVARCHAR(20) = NULL,
    @Status NVARCHAR(40) = 'Active',
    @NewRetailerID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO Retailer (
        CompanyName, ContactPerson, Phone, Email, AlternativePhone,
        Address, City, Province, PostalCode, Status, IsActive, CreatedDate
    )
    VALUES (
        @CompanyName, @ContactPerson, @Phone, @Email, @AlternativePhone,
        @Address, @City, @Province, @PostalCode, @Status, 1, GETDATE()
    );
    
    SET @NewRetailerID = SCOPE_IDENTITY();
END
GO

PRINT '✓ sp_AddRetailer created';
GO

-- PROCEDURE: sp_UpdateRetailer
-- Purpose: Update retailer information
IF OBJECT_ID('sp_UpdateRetailer', 'P') IS NOT NULL
    DROP PROCEDURE sp_UpdateRetailer;
GO

CREATE PROCEDURE sp_UpdateRetailer
    @RetailerID INT,
    @CompanyName NVARCHAR(200),
    @ContactPerson NVARCHAR(200) = NULL,
    @Phone NVARCHAR(40) = NULL,
    @Email NVARCHAR(200) = NULL,
    @AlternativePhone NVARCHAR(40) = NULL,
    @Address NVARCHAR(1000) = NULL,
    @City NVARCHAR(100) = NULL,
    @Province NVARCHAR(100) = NULL,
    @PostalCode NVARCHAR(20) = NULL,
    @Status NVARCHAR(40) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE Retailer
    SET CompanyName = @CompanyName,
        ContactPerson = @ContactPerson,
        Phone = @Phone,
        Email = @Email,
        AlternativePhone = @AlternativePhone,
        Address = @Address,
        City = @City,
        Province = @Province,
        PostalCode = @PostalCode,
        Status = @Status,
        UpdatedDate = GETDATE()
    WHERE RetailerID = @RetailerID;
END
GO

PRINT '✓ sp_UpdateRetailer created';
GO

-- PROCEDURE: sp_DeleteRetailer
-- Purpose: Soft delete retailer (mark as inactive)
IF OBJECT_ID('sp_DeleteRetailer', 'P') IS NOT NULL
    DROP PROCEDURE sp_DeleteRetailer;
GO

CREATE PROCEDURE sp_DeleteRetailer
    @RetailerID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE Retailer
    SET IsActive = 0,
        UpdatedDate = GETDATE()
    WHERE RetailerID = @RetailerID;
END
GO

PRINT '✓ sp_DeleteRetailer created';
GO

-- PROCEDURE: sp_SearchRetailers
-- Purpose: Search retailers by company name, city, or contact person
IF OBJECT_ID('sp_SearchRetailers', 'P') IS NOT NULL
    DROP PROCEDURE sp_SearchRetailers;
GO

CREATE PROCEDURE sp_SearchRetailers
    @SearchTerm NVARCHAR(200)
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        RetailerID,
        CompanyName,
        ContactPerson,
        Phone,
        Email,
        City,
        Province,
        Status
    FROM Retailer
    WHERE IsActive = 1
      AND (CompanyName LIKE '%' + @SearchTerm + '%'
           OR ContactPerson LIKE '%' + @SearchTerm + '%'
           OR City LIKE '%' + @SearchTerm + '%')
    ORDER BY CompanyName;
END
GO

PRINT '✓ sp_SearchRetailers created';
GO

-- ================================================================================
-- END OF PART 1: CORE MANAGEMENT PROCEDURES
-- ================================================================================
PRINT '';
PRINT '========================================';
PRINT 'PART 1 COMPLETE: Core Management Procedures';
PRINT 'Total: ~40 procedures created';
PRINT '========================================';
GO
