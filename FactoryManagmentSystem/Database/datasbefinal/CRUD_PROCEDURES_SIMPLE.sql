-- =============================================
-- SIMPLE CRUD PROCEDURES
-- Basic Create, Read, Update, Delete operations
-- Generated: December 17, 2025
-- =============================================

USE GarmentsFactoryDB;
GO

-- ========================================
-- EMPLOYEE CRUD PROCEDURES
-- ========================================

-- CREATE
CREATE OR ALTER PROCEDURE sp_AddEmployee
    @FirstName NVARCHAR(100),
    @LastName NVARCHAR(100),
    @Email NVARCHAR(200),
    @Phone NVARCHAR(20),
    @DepartmentID INT,
    @RoleID INT,
    @Salary DECIMAL(18,2),
    @Address NVARCHAR(500) = NULL,
    @CNIC NVARCHAR(20) = NULL,
    @Username NVARCHAR(100) = NULL,
    @NewEmployeeID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Employee (FirstName, LastName, Email, Phone, DepartmentID, RoleID, Salary, Address, CNIC, Username, IsActive, CreatedDate)
    VALUES (@FirstName, @LastName, @Email, @Phone, @DepartmentID, @RoleID, @Salary, @Address, @CNIC, @Username, 1, GETDATE());
    SET @NewEmployeeID = SCOPE_IDENTITY();
END
GO

-- READ ALL
CREATE OR ALTER PROCEDURE sp_GetEmployees
AS
BEGIN
    SET NOCOUNT ON;
    SELECT e.*, r.RoleName, d.DepartmentName 
    FROM Employee e
    LEFT JOIN EmployeeRole r ON e.RoleID = r.RoleID
    LEFT JOIN Department d ON e.DepartmentID = d.DepartmentID
    ORDER BY e.EmployeeID;
END
GO

-- READ BY ID
CREATE OR ALTER PROCEDURE sp_GetEmployeeById
    @EmployeeID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT e.*, r.RoleName, d.DepartmentName
    FROM Employee e
    LEFT JOIN EmployeeRole r ON e.RoleID = r.RoleID
    LEFT JOIN Department d ON e.DepartmentID = d.DepartmentID
    WHERE e.EmployeeID = @EmployeeID;
END
GO

-- UPDATE
CREATE OR ALTER PROCEDURE sp_UpdateEmployee
    @EmployeeID INT,
    @FirstName NVARCHAR(100),
    @LastName NVARCHAR(100),
    @Email NVARCHAR(200),
    @Phone NVARCHAR(20),
    @DepartmentID INT,
    @RoleID INT,
    @Salary DECIMAL(18,2),
    @Address NVARCHAR(500) = NULL
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
        Address = @Address
    WHERE EmployeeID = @EmployeeID;
END
GO

-- DELETE
CREATE OR ALTER PROCEDURE sp_DeleteEmployee
    @EmployeeID INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Employee SET IsActive = 0 WHERE EmployeeID = @EmployeeID;
END
GO

-- ========================================
-- DEPARTMENT CRUD PROCEDURES
-- ========================================

CREATE OR ALTER PROCEDURE sp_AddDepartment
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

CREATE OR ALTER PROCEDURE sp_GetAllDepartments
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM Department WHERE IsActive = 1 ORDER BY DepartmentName;
END
GO

CREATE OR ALTER PROCEDURE sp_GetDepartmentById
    @DepartmentID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM Department WHERE DepartmentID = @DepartmentID;
END
GO

CREATE OR ALTER PROCEDURE sp_UpdateDepartment
    @DepartmentID INT,
    @DepartmentName NVARCHAR(200),
    @Description NVARCHAR(1000) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Department 
    SET DepartmentName = @DepartmentName, Description = @Description
    WHERE DepartmentID = @DepartmentID;
END
GO

CREATE OR ALTER PROCEDURE sp_DeleteDepartment
    @DepartmentID INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Department SET IsActive = 0 WHERE DepartmentID = @DepartmentID;
END
GO

-- ========================================
-- RETAILER CRUD PROCEDURES
-- ========================================

CREATE OR ALTER PROCEDURE sp_AddRetailer
    @ContactPerson NVARCHAR(200),
    @Phone NVARCHAR(20),
    @Email NVARCHAR(200) = NULL,
    @Address NVARCHAR(500) = NULL,
    @City NVARCHAR(100) = NULL,
    @NewRetailerID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Retailer (ContactPerson, Phone, Email, Address, City, CreatedDate, IsActive)
    VALUES (@ContactPerson, @Phone, @Email, @Address, @City, GETDATE(), 1);
    SET @NewRetailerID = SCOPE_IDENTITY();
END
GO

CREATE OR ALTER PROCEDURE sp_GetAllRetailers
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM Retailer WHERE IsActive = 1 ORDER BY ContactPerson;
END
GO

CREATE OR ALTER PROCEDURE sp_GetRetailerById
    @RetailerID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM Retailer WHERE RetailerID = @RetailerID;
END
GO

CREATE OR ALTER PROCEDURE sp_UpdateRetailer
    @RetailerID INT,
    @ContactPerson NVARCHAR(200),
    @Phone NVARCHAR(20),
    @Email NVARCHAR(200) = NULL,
    @Address NVARCHAR(500) = NULL,
    @City NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Retailer 
    SET ContactPerson = @ContactPerson,
        Phone = @Phone,
        Email = @Email,
        Address = @Address,
        City = @City
    WHERE RetailerID = @RetailerID;
END
GO

CREATE OR ALTER PROCEDURE sp_DeleteRetailer
    @RetailerID INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Retailer SET IsActive = 0 WHERE RetailerID = @RetailerID;
END
GO

-- ========================================
-- PRODUCT CRUD PROCEDURES
-- ========================================

CREATE OR ALTER PROCEDURE sp_AddProduct
    @ProductName NVARCHAR(300),
    @Description NVARCHAR(1000) = NULL,
    @Category NVARCHAR(100) = NULL,
    @SalePrice DECIMAL(18,2),
    @SKU NVARCHAR(100) = NULL,
    @NewProductID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Product (ProductName, Description, Category, SalePrice, SKU, IsActive, CreatedDate)
    VALUES (@ProductName, @Description, @Category, @SalePrice, @SKU, 1, GETDATE());
    SET @NewProductID = SCOPE_IDENTITY();
END
GO

CREATE OR ALTER PROCEDURE sp_GetAllProducts
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM Product WHERE IsActive = 1 ORDER BY ProductName;
END
GO

CREATE OR ALTER PROCEDURE sp_GetProductById
    @ProductID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM Product WHERE ProductID = @ProductID;
END
GO

CREATE OR ALTER PROCEDURE sp_UpdateProduct
    @ProductID INT,
    @ProductName NVARCHAR(300),
    @Description NVARCHAR(1000) = NULL,
    @Category NVARCHAR(100) = NULL,
    @SalePrice DECIMAL(18,2)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Product 
    SET ProductName = @ProductName,
        Description = @Description,
        Category = @Category,
        SalePrice = @SalePrice,
        UpdatedDate = GETDATE()
    WHERE ProductID = @ProductID;
END
GO

CREATE OR ALTER PROCEDURE sp_DeleteProduct
    @ProductID INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Product SET IsActive = 0, UpdatedDate = GETDATE() WHERE ProductID = @ProductID;
END
GO

-- ========================================
-- RAW MATERIAL CRUD PROCEDURES
-- ========================================

CREATE OR ALTER PROCEDURE sp_CreateRawMaterial
    @MaterialName NVARCHAR(300),
    @Category NVARCHAR(100) = NULL,
    @Unit NVARCHAR(50) = NULL,
    @UnitCost DECIMAL(18,2) = 0,
    @ReorderLevel DECIMAL(18,2) = 0,
    @NewMaterialID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO RawMaterial (MaterialName, Category, Unit, UnitCost, ReorderLevel, StockQuantity, CreatedDate)
    VALUES (@MaterialName, @Category, @Unit, @UnitCost, @ReorderLevel, 0, GETDATE());
    SET @NewMaterialID = SCOPE_IDENTITY();
END
GO

CREATE OR ALTER PROCEDURE sp_GetAllRawMaterials
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM RawMaterial ORDER BY MaterialName;
END
GO

CREATE OR ALTER PROCEDURE sp_GetRawMaterialById
    @RawMaterialID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM RawMaterial WHERE RawMaterialID = @RawMaterialID;
END
GO

CREATE OR ALTER PROCEDURE sp_UpdateRawMaterial
    @RawMaterialID INT,
    @MaterialName NVARCHAR(300),
    @Category NVARCHAR(100) = NULL,
    @Unit NVARCHAR(50) = NULL,
    @UnitCost DECIMAL(18,2),
    @ReorderLevel DECIMAL(18,2)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE RawMaterial 
    SET MaterialName = @MaterialName,
        Category = @Category,
        Unit = @Unit,
        UnitCost = @UnitCost,
        ReorderLevel = @ReorderLevel,
        UpdatedDate = GETDATE()
    WHERE RawMaterialID = @RawMaterialID;
END
GO

CREATE OR ALTER PROCEDURE sp_DeleteRawMaterial
    @RawMaterialID INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM RawMaterial WHERE RawMaterialID = @RawMaterialID;
END
GO

PRINT '✓ Simple CRUD procedures created successfully!';
PRINT '✓ Total procedures: 30';
GO
