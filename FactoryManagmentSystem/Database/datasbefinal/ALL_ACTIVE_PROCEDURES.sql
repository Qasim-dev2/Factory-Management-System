-- =============================================
-- FACTORY MANAGEMENT SYSTEM - ALL ACTIVE PROCEDURES
-- Without Stock Table Procedures
-- Total: 95 Procedures
-- Database: GarmentsFactoryDB
-- =============================================

USE GarmentsFactoryDB;
GO

-- =============================================
-- SECTION 1: AUTHENTICATION (1)
-- =============================================

CREATE OR ALTER PROCEDURE sp_AuthenticateUser
    @Username NVARCHAR(50),
    @PIN NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT e.EmployeeID, e.FirstName, e.LastName, e.Email, e.Phone, e.RoleID, r.RoleName,
           e.DepartmentID, d.DepartmentName, e.IsActive, e.LastLogin
    FROM Employee e
    LEFT JOIN EmployeeRole r ON e.RoleID = r.RoleID
    LEFT JOIN Department d ON e.DepartmentID = d.DepartmentID
    WHERE e.Username = @Username AND e.PIN = @PIN AND e.IsActive = 1;
END
GO

-- =============================================
-- SECTION 2: EMPLOYEE MANAGEMENT (5)
-- =============================================

CREATE OR ALTER PROCEDURE sp_GetEmployees
AS
BEGIN
    SET NOCOUNT ON;
    SELECT e.EmployeeID, e.FirstName, e.LastName, e.FirstName + ' ' + e.LastName AS FullName,
           e.Email, e.Phone, e.CNIC, e.Address, e.EmergencyContact, e.RoleID, r.RoleName,
           e.DepartmentID, d.DepartmentName, e.Salary, e.JoinDate, e.IsActive, e.Username
    FROM Employee e
    LEFT JOIN EmployeeRole r ON e.RoleID = r.RoleID
    LEFT JOIN Department d ON e.DepartmentID = d.DepartmentID
    WHERE e.IsActive = 1
    ORDER BY e.FirstName, e.LastName;
END
GO

CREATE OR ALTER PROCEDURE sp_GetEmployeeById
    @EmployeeID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT e.EmployeeID, e.FirstName, e.LastName, e.Email, e.Phone, e.CNIC, e.Address,
           e.EmergencyContact, e.RoleID, r.RoleName, e.DepartmentID, d.DepartmentName,
           e.Salary, e.JoinDate, e.IsActive, e.Username, e.PIN
    FROM Employee e
    LEFT JOIN EmployeeRole r ON e.RoleID = r.RoleID
    LEFT JOIN Department d ON e.DepartmentID = d.DepartmentID
    WHERE e.EmployeeID = @EmployeeID;
END
GO

CREATE OR ALTER PROCEDURE sp_AddEmployee
    @FirstName NVARCHAR(50), @LastName NVARCHAR(50), @Email NVARCHAR(100), @Phone NVARCHAR(20),
    @CNIC NVARCHAR(15), @Address NVARCHAR(255), @EmergencyContact NVARCHAR(20),
    @RoleID INT, @DepartmentID INT, @Salary DECIMAL(18,2), @JoinDate DATE,
    @Username NVARCHAR(50), @PIN NVARCHAR(50), @Position NVARCHAR(100),
    @NewEmployeeID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        INSERT INTO Employee (FirstName, LastName, Email, Phone, CNIC, Address, EmergencyContact,
                             RoleID, DepartmentID, Salary, JoinDate, Username, PIN, Position, IsActive)
        VALUES (@FirstName, @LastName, @Email, @Phone, @CNIC, @Address, @EmergencyContact,
                @RoleID, @DepartmentID, @Salary, @JoinDate, @Username, @PIN, @Position, 1);
        SET @NewEmployeeID = SCOPE_IDENTITY();
        SELECT 'SUCCESS' AS Status, 'Employee added successfully' AS Message;
    END TRY
    BEGIN CATCH
        SELECT 'ERROR' AS Status, ERROR_MESSAGE() AS Message;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE sp_UpdateEmployee
    @EmployeeID INT, @FirstName NVARCHAR(50), @LastName NVARCHAR(50), @Email NVARCHAR(100),
    @Phone NVARCHAR(20), @CNIC NVARCHAR(15), @Address NVARCHAR(255), @EmergencyContact NVARCHAR(20),
    @RoleID INT, @DepartmentID INT, @Salary DECIMAL(18,2), @JoinDate DATE,
    @Username NVARCHAR(50), @PIN NVARCHAR(50), @Position NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        UPDATE Employee SET FirstName = @FirstName, LastName = @LastName, Email = @Email, Phone = @Phone,
            CNIC = @CNIC, Address = @Address, EmergencyContact = @EmergencyContact, RoleID = @RoleID,
            DepartmentID = @DepartmentID, Salary = @Salary, JoinDate = @JoinDate, Username = @Username,
            PIN = @PIN, Position = @Position
        WHERE EmployeeID = @EmployeeID;
        SELECT 'SUCCESS' AS Status, 'Employee updated successfully' AS Message;
    END TRY
    BEGIN CATCH
        SELECT 'ERROR' AS Status, ERROR_MESSAGE() AS Message;
    END CATCH
END
GO

-- Soft delete to preserve referential integrity
CREATE OR ALTER PROCEDURE sp_DeleteEmployee
    @EmployeeID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        UPDATE Employee SET IsActive = 0 WHERE EmployeeID = @EmployeeID;
        SELECT @@ROWCOUNT AS RowsAffected;
    END TRY
    BEGIN CATCH
        SELECT 0 AS RowsAffected;
    END CATCH
END
GO

-- =============================================
-- SECTION 3: DEPARTMENT & ROLE (7)
-- =============================================

CREATE OR ALTER PROCEDURE sp_GetAllDepartments
AS
BEGIN
    SET NOCOUNT ON;
    SELECT DepartmentID, DepartmentName, Description, IsActive FROM Department WHERE IsActive = 1;
END
GO

CREATE OR ALTER PROCEDURE sp_GetDepartmentById @DepartmentID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT DepartmentID, DepartmentName, Description, IsActive FROM Department WHERE DepartmentID = @DepartmentID;
END
GO

CREATE OR ALTER PROCEDURE sp_AddDepartment @DepartmentName NVARCHAR(100), @Description NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Department (DepartmentName, Description) VALUES (@DepartmentName, @Description);
    SELECT SCOPE_IDENTITY() AS NewDepartmentID;
END
GO

CREATE OR ALTER PROCEDURE sp_UpdateDepartment @DepartmentID INT, @DepartmentName NVARCHAR(100), @Description NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Department SET DepartmentName = @DepartmentName, Description = @Description WHERE DepartmentID = @DepartmentID;
END
GO

CREATE OR ALTER PROCEDURE sp_DeleteDepartment @DepartmentID INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Department SET IsActive = 0 WHERE DepartmentID = @DepartmentID;
END
GO

CREATE OR ALTER PROCEDURE sp_GetDepartments
AS
BEGIN
    SET NOCOUNT ON;
    SELECT DepartmentID, DepartmentName FROM Department WHERE IsActive = 1 ORDER BY DepartmentName;
END
GO

CREATE OR ALTER PROCEDURE sp_GetEmployeeRoles
AS
BEGIN
    SET NOCOUNT ON;
    SELECT RoleID, RoleName, Description FROM EmployeeRole WHERE IsActive = 1 ORDER BY RoleName;
END
GO

-- =============================================
-- SECTION 4: RETAILER MANAGEMENT (6)
-- =============================================

CREATE OR ALTER PROCEDURE sp_GetAllRetailers
AS
BEGIN
    SET NOCOUNT ON;
    SELECT RetailerID, CompanyName AS RetailerName, ContactPerson, Phone AS PhoneNumber, Email, Address, IsActive
    FROM Retailer WHERE IsActive = 1 ORDER BY CompanyName;
END
GO

CREATE OR ALTER PROCEDURE sp_GetRetailerById @RetailerID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT RetailerID, CompanyName AS RetailerName, ContactPerson, Phone AS PhoneNumber, Email, Address
    FROM Retailer WHERE RetailerID = @RetailerID;
END
GO

CREATE OR ALTER PROCEDURE sp_AddRetailer
    @RetailerName NVARCHAR(100), @ContactPerson NVARCHAR(100), @PhoneNumber NVARCHAR(20),
    @Email NVARCHAR(100), @Address NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Retailer (CompanyName, ContactPerson, Phone, Email, Address, IsActive)
    VALUES (@RetailerName, @ContactPerson, @PhoneNumber, @Email, @Address, 1);
    SELECT SCOPE_IDENTITY() AS NewRetailerID;
END
GO

CREATE OR ALTER PROCEDURE sp_UpdateRetailer
    @RetailerID INT, @RetailerName NVARCHAR(100), @ContactPerson NVARCHAR(100),
    @PhoneNumber NVARCHAR(20), @Email NVARCHAR(100), @Address NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Retailer SET CompanyName = @RetailerName, ContactPerson = @ContactPerson, Phone = @PhoneNumber,
           Email = @Email, Address = @Address WHERE RetailerID = @RetailerID;
END
GO

CREATE OR ALTER PROCEDURE sp_DeleteRetailer @RetailerID INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Retailer SET IsActive = 0 WHERE RetailerID = @RetailerID;
END
GO

CREATE OR ALTER PROCEDURE sp_SearchRetailers @SearchTerm NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT RetailerID, CompanyName AS RetailerName, ContactPerson, Phone AS PhoneNumber, Email, Address
    FROM Retailer WHERE IsActive = 1 AND (CompanyName LIKE '%' + @SearchTerm + '%' OR ContactPerson LIKE '%' + @SearchTerm + '%');
END
GO

CREATE OR ALTER PROCEDURE sp_GetRetailerStatistics
AS
BEGIN
    SET NOCOUNT ON;
    SELECT COUNT(*) AS TotalRetailers,
           (SELECT COUNT(*) FROM Retailer WHERE IsActive = 1) AS ActiveRetailers,
           (SELECT COUNT(*) FROM SalesOrder) AS TotalOrders
    FROM Retailer;
END
GO

-- =============================================
-- SECTION 5: PRODUCT MANAGEMENT (6)
-- =============================================

CREATE OR ALTER PROCEDURE sp_GetAllProducts
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ProductID, ProductName, Description, Category, SalePrice AS Price, CostPrice, IsActive
    FROM Product WHERE IsActive = 1 ORDER BY ProductName;
END
GO

CREATE OR ALTER PROCEDURE sp_GetProductById @ProductID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ProductID, ProductName, Description, Category, SalePrice AS Price, CostPrice
    FROM Product WHERE ProductID = @ProductID;
END
GO

CREATE OR ALTER PROCEDURE sp_AddProduct
    @ProductName NVARCHAR(100), @Description NVARCHAR(500), @Category NVARCHAR(50),
    @Price DECIMAL(18,2), @CostPrice DECIMAL(18,2)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Product (ProductName, Description, Category, SalePrice, CostPrice, IsActive)
    VALUES (@ProductName, @Description, @Category, @Price, @CostPrice, 1);
    SELECT SCOPE_IDENTITY() AS NewProductID;
END
GO

CREATE OR ALTER PROCEDURE sp_UpdateProduct
    @ProductID INT, @ProductName NVARCHAR(100), @Description NVARCHAR(500),
    @Category NVARCHAR(50), @Price DECIMAL(18,2), @CostPrice DECIMAL(18,2)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Product SET ProductName = @ProductName, Description = @Description, Category = @Category,
           SalePrice = @Price, CostPrice = @CostPrice WHERE ProductID = @ProductID;
END
GO

CREATE OR ALTER PROCEDURE sp_DeleteProduct @ProductID INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Product SET IsActive = 0 WHERE ProductID = @ProductID;
END
GO

CREATE OR ALTER PROCEDURE sp_SearchProducts @SearchTerm NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ProductID, ProductName, Description, Category, SalePrice AS Price
    FROM Product WHERE IsActive = 1 AND (ProductName LIKE '%' + @SearchTerm + '%' OR Category LIKE '%' + @SearchTerm + '%');
END
GO

-- =============================================
-- SECTION 6: RAW MATERIAL MANAGEMENT (8)
-- =============================================

CREATE OR ALTER PROCEDURE sp_GetAllRawMaterials
AS
BEGIN
    SET NOCOUNT ON;
    SELECT RawMaterialID, MaterialName, Category, Unit, Quantity, MinimumStock, UnitPrice, Supplier, StockStatus
    FROM RawMaterial WHERE IsActive = 1 ORDER BY MaterialName;
END
GO

CREATE OR ALTER PROCEDURE sp_GetRawMaterialById @RawMaterialID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT RawMaterialID, MaterialName, Category, Unit, Quantity, MinimumStock, UnitPrice, Supplier, Description
    FROM RawMaterial WHERE RawMaterialID = @RawMaterialID;
END
GO

CREATE OR ALTER PROCEDURE sp_CreateRawMaterial
    @MaterialName NVARCHAR(100), @Category NVARCHAR(50), @Unit NVARCHAR(20),
    @Quantity DECIMAL(18,2), @MinimumStock DECIMAL(18,2), @UnitPrice DECIMAL(18,2),
    @Supplier NVARCHAR(100), @Description NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO RawMaterial (MaterialName, Category, Unit, Quantity, MinimumStock, UnitPrice, Supplier, Description, IsActive)
    VALUES (@MaterialName, @Category, @Unit, @Quantity, @MinimumStock, @UnitPrice, @Supplier, @Description, 1);
    SELECT SCOPE_IDENTITY() AS NewRawMaterialID;
END
GO

CREATE OR ALTER PROCEDURE sp_UpdateRawMaterial
    @RawMaterialID INT, @MaterialName NVARCHAR(100), @Category NVARCHAR(50), @Unit NVARCHAR(20),
    @Quantity DECIMAL(18,2), @MinimumStock DECIMAL(18,2), @UnitPrice DECIMAL(18,2),
    @Supplier NVARCHAR(100), @Description NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE RawMaterial SET MaterialName = @MaterialName, Category = @Category, Unit = @Unit,
           Quantity = @Quantity, MinimumStock = @MinimumStock, UnitPrice = @UnitPrice,
           Supplier = @Supplier, Description = @Description WHERE RawMaterialID = @RawMaterialID;
END
GO

CREATE OR ALTER PROCEDURE sp_DeleteRawMaterial @RawMaterialID INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE RawMaterial SET IsActive = 0 WHERE RawMaterialID = @RawMaterialID;
END
GO

CREATE OR ALTER PROCEDURE sp_SearchRawMaterials @SearchTerm NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT RawMaterialID, MaterialName, Category, Unit, Quantity, UnitPrice, Supplier
    FROM RawMaterial WHERE IsActive = 1 AND (MaterialName LIKE '%' + @SearchTerm + '%' OR Category LIKE '%' + @SearchTerm + '%');
END
GO

CREATE OR ALTER PROCEDURE sp_GetRawMaterialStatistics
AS
BEGIN
    SET NOCOUNT ON;
    SELECT COUNT(*) AS TotalMaterials,
           SUM(CASE WHEN Quantity <= MinimumStock THEN 1 ELSE 0 END) AS LowStockCount,
           SUM(Quantity * UnitPrice) AS TotalValue
    FROM RawMaterial WHERE IsActive = 1;
END
GO

CREATE OR ALTER PROCEDURE sp_RestockRawMaterial @RawMaterialID INT, @Quantity DECIMAL(18,2)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE RawMaterial SET Quantity = Quantity + @Quantity, LastRestockDate = GETDATE() WHERE RawMaterialID = @RawMaterialID;
END
GO

CREATE OR ALTER PROCEDURE sp_DeductRawMaterialStock @RawMaterialID INT, @Quantity DECIMAL(18,2)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE RawMaterial SET Quantity = Quantity - @Quantity WHERE RawMaterialID = @RawMaterialID AND Quantity >= @Quantity;
    IF @@ROWCOUNT = 0 SELECT 'ERROR' AS Status, 'Insufficient stock' AS Message;
    ELSE SELECT 'SUCCESS' AS Status;
END
GO

-- =============================================
-- SECTION 7: SALES ORDER MANAGEMENT (12)
-- =============================================

CREATE OR ALTER PROCEDURE sp_GetAllSalesOrders
AS
BEGIN
    SET NOCOUNT ON;
    SELECT so.SalesOrderID, so.RetailerID, r.CompanyName AS RetailerName, so.OrderDate, so.TotalAmount, so.Status
    FROM SalesOrder so
    LEFT JOIN Retailer r ON so.RetailerID = r.RetailerID
    ORDER BY so.OrderDate DESC;
END
GO

CREATE OR ALTER PROCEDURE sp_GetSalesOrderById @SalesOrderID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT so.SalesOrderID, so.RetailerID, r.CompanyName AS RetailerName, so.OrderDate, so.TotalAmount, so.Status,
           so.ShippingAddress, so.SpecialInstructions, so.DiscountPercentage
    FROM SalesOrder so
    LEFT JOIN Retailer r ON so.RetailerID = r.RetailerID
    WHERE so.SalesOrderID = @SalesOrderID;
END
GO

CREATE OR ALTER PROCEDURE sp_AddSalesOrder
    @RetailerID INT, @EmployeeID INT, @OrderDate DATE, @TotalAmount DECIMAL(18,2),
    @Status NVARCHAR(50), @Notes NVARCHAR(500), @NewOrderID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        INSERT INTO SalesOrder (RetailerID, SalesRepID, OrderDate, TotalAmount, Status, InternalNotes)
        VALUES (@RetailerID, @EmployeeID, @OrderDate, @TotalAmount, @Status, @Notes);
        SET @NewOrderID = SCOPE_IDENTITY();
        -- Auto-create approval record
        INSERT INTO OrderApproval (OrderType, SalesOrderID, Status, RequestDate, RequestedBy)
        VALUES ('SalesOrder', @NewOrderID, 'Pending', GETDATE(), @EmployeeID);
        COMMIT TRANSACTION;
        SELECT 'SUCCESS' AS Status;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SELECT 'ERROR' AS Status, ERROR_MESSAGE() AS Message;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE sp_AddSalesOrderItem
    @SalesOrderID INT, @ProductID INT, @Quantity INT, @UnitPrice DECIMAL(18,2)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO SalesOrderItem (SalesOrderID, ProductID, Quantity, UnitPrice) VALUES (@SalesOrderID, @ProductID, @Quantity, @UnitPrice);
END
GO

CREATE OR ALTER PROCEDURE sp_UpdateSalesOrder
    @SalesOrderID INT, @RetailerID INT, @OrderDate DATE, @TotalAmount DECIMAL(18,2), @Status NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE SalesOrder SET RetailerID = @RetailerID, OrderDate = @OrderDate, TotalAmount = @TotalAmount, Status = @Status
    WHERE SalesOrderID = @SalesOrderID;
END
GO

CREATE OR ALTER PROCEDURE sp_DeleteSalesOrder @SalesOrderID INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM SalesOrderItem WHERE SalesOrderID = @SalesOrderID;
    DELETE FROM SalesOrder WHERE SalesOrderID = @SalesOrderID;
END
GO

CREATE OR ALTER PROCEDURE sp_GetRetailersForOrder
AS
BEGIN
    SET NOCOUNT ON;
    SELECT RetailerID, CompanyName AS RetailerName, ContactPerson, Phone, Email FROM Retailer WHERE IsActive = 1;
END
GO

CREATE OR ALTER PROCEDURE sp_GetSalespersonsForOrder
AS
BEGIN
    SET NOCOUNT ON;
    SELECT e.EmployeeID, e.FirstName + ' ' + e.LastName AS FullName
    FROM Employee e INNER JOIN EmployeeRole r ON e.RoleID = r.RoleID
    WHERE r.RoleName IN ('Salesperson', 'Sales Manager') AND e.IsActive = 1;
END
GO

CREATE OR ALTER PROCEDURE sp_GetProductsForOrder
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ProductID, ProductName, SalePrice AS Price, Category FROM Product WHERE IsActive = 1;
END
GO

CREATE OR ALTER PROCEDURE sp_SearchSalesOrders @SearchTerm NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT so.SalesOrderID, r.CompanyName AS RetailerName, so.OrderDate, so.TotalAmount, so.Status
    FROM SalesOrder so LEFT JOIN Retailer r ON so.RetailerID = r.RetailerID
    WHERE r.CompanyName LIKE '%' + @SearchTerm + '%' OR CAST(so.SalesOrderID AS NVARCHAR) LIKE '%' + @SearchTerm + '%';
END
GO

CREATE OR ALTER PROCEDURE sp_GetSalesOrderStatistics
AS
BEGIN
    SET NOCOUNT ON;
    SELECT COUNT(*) AS TotalOrders, SUM(TotalAmount) AS TotalRevenue,
           SUM(CASE WHEN Status = 'Pending' THEN 1 ELSE 0 END) AS PendingOrders,
           SUM(CASE WHEN Status = 'Delivered' THEN 1 ELSE 0 END) AS DeliveredOrders
    FROM SalesOrder;
END
GO

CREATE OR ALTER PROCEDURE sp_UpdateSalesOrderStatus @SalesOrderID INT, @Status NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE SalesOrder SET Status = @Status WHERE SalesOrderID = @SalesOrderID;
END
GO

-- =============================================
-- SECTION 8: DEAL MANAGEMENT (12)
-- =============================================

CREATE OR ALTER PROCEDURE sp_GetAllDeals
AS
BEGIN
    SET NOCOUNT ON;
    SELECT DealID, DealTitle, ClientName, ContactPerson, EstimatedValue AS TotalAmount, Status, StartDate, EndDate
    FROM Deal ORDER BY StartDate DESC;
END
GO

CREATE OR ALTER PROCEDURE sp_GetDealById @DealID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT DealID, DealTitle, ClientName, ContactPerson, Email, Phone, EstimatedValue, Status, StartDate, EndDate, Description
    FROM Deal WHERE DealID = @DealID;
END
GO

CREATE OR ALTER PROCEDURE sp_AddDeal
    @DealTitle NVARCHAR(100), @ClientName NVARCHAR(100), @ContactPerson NVARCHAR(100),
    @Email NVARCHAR(100), @Phone NVARCHAR(20), @TotalAmount DECIMAL(18,2),
    @Status NVARCHAR(50), @StartDate DATE, @CreatedBy INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        INSERT INTO Deal (DealTitle, ClientName, ContactPerson, Email, Phone, EstimatedValue, Status, StartDate, CreatedBy)
        VALUES (@DealTitle, @ClientName, @ContactPerson, @Email, @Phone, @TotalAmount, @Status, @StartDate, @CreatedBy);
        DECLARE @NewDealID INT = SCOPE_IDENTITY();
        INSERT INTO OrderApproval (OrderType, DealID, Status, RequestDate, RequestedBy)
        VALUES ('Deal', @NewDealID, 'Pending', GETDATE(), @CreatedBy);
        COMMIT TRANSACTION;
        SELECT @NewDealID AS NewDealID;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SELECT -1 AS NewDealID, ERROR_MESSAGE() AS ErrorMessage;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE sp_UpdateDeal
    @DealID INT, @DealTitle NVARCHAR(100), @ClientName NVARCHAR(100), @ContactPerson NVARCHAR(100),
    @Email NVARCHAR(100), @Phone NVARCHAR(20), @TotalAmount DECIMAL(18,2), @Status NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Deal SET DealTitle = @DealTitle, ClientName = @ClientName, ContactPerson = @ContactPerson,
           Email = @Email, Phone = @Phone, EstimatedValue = @TotalAmount, Status = @Status WHERE DealID = @DealID;
END
GO

CREATE OR ALTER PROCEDURE sp_DeleteDeal @DealID INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM DealItem WHERE DealID = @DealID;
    DELETE FROM OrderApproval WHERE DealID = @DealID;
    DELETE FROM Deal WHERE DealID = @DealID;
END
GO

CREATE OR ALTER PROCEDURE sp_GetDealStatistics
AS
BEGIN
    SET NOCOUNT ON;
    SELECT COUNT(*) AS TotalDeals, SUM(EstimatedValue) AS TotalValue,
           SUM(CASE WHEN Status = 'Pending' THEN 1 ELSE 0 END) AS PendingDeals,
           SUM(CASE WHEN Status = 'Approved' THEN 1 ELSE 0 END) AS ApprovedDeals
    FROM Deal;
END
GO

CREATE OR ALTER PROCEDURE sp_GetDealsByStatus @Status NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT DealID, DealTitle, ClientName, EstimatedValue AS TotalAmount, Status FROM Deal WHERE Status = @Status;
END
GO

CREATE OR ALTER PROCEDURE sp_GetDealsByEmployee @EmployeeID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT DealID, DealTitle, ClientName, EstimatedValue AS TotalAmount, Status FROM Deal WHERE CreatedBy = @EmployeeID;
END
GO

CREATE OR ALTER PROCEDURE sp_GetDealItems @DealID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT di.DealItemID, di.ProductID, p.ProductName, di.Quantity, di.UnitPrice
    FROM DealItem di LEFT JOIN Product p ON di.ProductID = p.ProductID WHERE di.DealID = @DealID;
END
GO

CREATE OR ALTER PROCEDURE sp_AddDealItem @DealID INT, @ProductID INT, @Quantity INT, @UnitPrice DECIMAL(18,2)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO DealItem (DealID, ProductID, Quantity, UnitPrice) VALUES (@DealID, @ProductID, @Quantity, @UnitPrice);
END
GO

CREATE OR ALTER PROCEDURE sp_UpdateDealItem @DealItemID INT, @Quantity INT, @UnitPrice DECIMAL(18,2)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE DealItem SET Quantity = @Quantity, UnitPrice = @UnitPrice WHERE DealItemID = @DealItemID;
END
GO

CREATE OR ALTER PROCEDURE sp_DeleteDealItem @DealItemID INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM DealItem WHERE DealItemID = @DealItemID;
END
GO

-- =============================================
-- SECTION 9: ORDER APPROVAL (8)
-- =============================================

CREATE OR ALTER PROCEDURE sp_GetPendingApprovals
AS
BEGIN
    SET NOCOUNT ON;
    SELECT oa.ApprovalID, oa.OrderType, oa.SalesOrderID, oa.DealID, oa.Status, oa.RequestDate,
           CASE WHEN oa.OrderType = 'SalesOrder' THEN so.TotalAmount ELSE d.EstimatedValue END AS OrderAmount,
           CASE WHEN oa.OrderType = 'SalesOrder' THEN r.CompanyName ELSE d.ClientName END AS CustomerName
    FROM OrderApproval oa
    LEFT JOIN SalesOrder so ON oa.SalesOrderID = so.SalesOrderID
    LEFT JOIN Deal d ON oa.DealID = d.DealID
    LEFT JOIN Retailer r ON so.RetailerID = r.RetailerID
    WHERE oa.Status = 'Pending' ORDER BY oa.RequestDate;
END
GO

CREATE OR ALTER PROCEDURE sp_ApproveOrderAndCreateProduction @ApprovalID INT, @ApprovedBy INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        DECLARE @OrderType NVARCHAR(50), @SalesOrderID INT, @DealID INT;
        SELECT @OrderType = OrderType, @SalesOrderID = SalesOrderID, @DealID = DealID FROM OrderApproval WHERE ApprovalID = @ApprovalID;
        
        UPDATE OrderApproval SET Status = 'Approved', ApprovedDate = GETDATE(), ApprovedBy = @ApprovedBy WHERE ApprovalID = @ApprovalID;
        
        IF @OrderType = 'SalesOrder'
        BEGIN
            UPDATE SalesOrder SET Status = 'Approved' WHERE SalesOrderID = @SalesOrderID;
            INSERT INTO ProductionOrder (ProductID, QuantityOrdered, Status, StartDate)
            SELECT ProductID, Quantity, 'Pending', GETDATE() FROM SalesOrderItem WHERE SalesOrderID = @SalesOrderID;
        END
        ELSE IF @OrderType = 'Deal'
        BEGIN
            UPDATE Deal SET Status = 'Approved' WHERE DealID = @DealID;
            INSERT INTO ProductionOrder (ProductID, QuantityOrdered, Status, StartDate)
            SELECT ProductID, Quantity, 'Pending', GETDATE() FROM DealItem WHERE DealID = @DealID;
        END
        COMMIT TRANSACTION;
        SELECT 'SUCCESS' AS Status;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SELECT 'ERROR' AS Status, ERROR_MESSAGE() AS Message;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE sp_RejectOrder @ApprovalID INT, @RejectedBy INT, @Reason NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        DECLARE @OrderType NVARCHAR(50), @SalesOrderID INT, @DealID INT;
        SELECT @OrderType = OrderType, @SalesOrderID = SalesOrderID, @DealID = DealID FROM OrderApproval WHERE ApprovalID = @ApprovalID;
        
        UPDATE OrderApproval SET Status = 'Rejected', RejectedDate = GETDATE(), RejectedBy = @RejectedBy, RejectionReason = @Reason WHERE ApprovalID = @ApprovalID;
        
        IF @OrderType = 'SalesOrder' UPDATE SalesOrder SET Status = 'Rejected' WHERE SalesOrderID = @SalesOrderID;
        ELSE IF @OrderType = 'Deal' UPDATE Deal SET Status = 'Rejected' WHERE DealID = @DealID;
        COMMIT TRANSACTION;
        SELECT 'SUCCESS' AS Status;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SELECT 'ERROR' AS Status, ERROR_MESSAGE() AS Message;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE sp_CheckMaterialsForOrder @ApprovalID INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @OrderType NVARCHAR(50), @SalesOrderID INT, @DealID INT;
    SELECT @OrderType = OrderType, @SalesOrderID = SalesOrderID, @DealID = DealID FROM OrderApproval WHERE ApprovalID = @ApprovalID;
    
    IF @OrderType = 'SalesOrder'
        SELECT p.ProductName, soi.Quantity AS Required, ISNULL(rm.Quantity, 0) AS Available
        FROM SalesOrderItem soi
        JOIN Product p ON soi.ProductID = p.ProductID
        LEFT JOIN ProductMaterialRequirement pmr ON p.ProductID = pmr.ProductID
        LEFT JOIN RawMaterial rm ON pmr.RawMaterialID = rm.RawMaterialID
        WHERE soi.SalesOrderID = @SalesOrderID;
    ELSE
        SELECT p.ProductName, di.Quantity AS Required, ISNULL(rm.Quantity, 0) AS Available
        FROM DealItem di
        JOIN Product p ON di.ProductID = p.ProductID
        LEFT JOIN ProductMaterialRequirement pmr ON p.ProductID = pmr.ProductID
        LEFT JOIN RawMaterial rm ON pmr.RawMaterialID = rm.RawMaterialID
        WHERE di.DealID = @DealID;
END
GO

CREATE OR ALTER PROCEDURE sp_GetAvailableTailors
AS
BEGIN
    SET NOCOUNT ON;
    SELECT e.EmployeeID, e.FirstName + ' ' + e.LastName AS TailorName,
           (SELECT COUNT(*) FROM TailorAssignment ta WHERE ta.TailorID = e.EmployeeID AND ta.Status != 'Completed') AS ActiveAssignments
    FROM Employee e INNER JOIN EmployeeRole r ON e.RoleID = r.RoleID
    WHERE r.RoleName = 'Tailor' AND e.IsActive = 1;
END
GO

CREATE OR ALTER PROCEDURE sp_GetApprovalHistory
AS
BEGIN
    SET NOCOUNT ON;
    SELECT oa.ApprovalID, oa.OrderType, oa.Status, oa.RequestDate, oa.ApprovedDate, oa.RejectedDate,
           CASE WHEN oa.OrderType = 'SalesOrder' THEN so.TotalAmount ELSE d.EstimatedValue END AS OrderAmount
    FROM OrderApproval oa
    LEFT JOIN SalesOrder so ON oa.SalesOrderID = so.SalesOrderID
    LEFT JOIN Deal d ON oa.DealID = d.DealID
    ORDER BY oa.RequestDate DESC;
END
GO

CREATE OR ALTER PROCEDURE sp_GetTailorAssignments @TailorID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ta.AssignmentID, ta.ProductionOrderID, ta.TailorID, e.FirstName + ' ' + e.LastName AS TailorName,
           p.ProductName, po.QuantityOrdered, ta.Status AS AssignmentStatus, ta.AssignedDate
    FROM TailorAssignment ta
    INNER JOIN ProductionOrder po ON ta.ProductionOrderID = po.ProductionOrderID
    INNER JOIN Product p ON po.ProductID = p.ProductID
    INNER JOIN Employee e ON ta.TailorID = e.EmployeeID
    WHERE (@TailorID IS NULL OR ta.TailorID = @TailorID) ORDER BY ta.AssignedDate DESC;
END
GO

CREATE OR ALTER PROCEDURE sp_UpdateTailorCompletionStatus @AssignmentID INT, @Status NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE TailorAssignment SET Status = @Status, CompletedDate = CASE WHEN @Status = 'Completed' THEN GETDATE() ELSE NULL END
    WHERE AssignmentID = @AssignmentID;
END
GO

-- =============================================
-- SECTION 10: PRODUCTION ORDER (10)
-- =============================================

CREATE OR ALTER PROCEDURE sp_GetAllProductionOrders
AS
BEGIN
    SET NOCOUNT ON;
    SELECT po.ProductionOrderID, po.ProductID, p.ProductName, po.QuantityOrdered, po.QuantityCompleted, po.Status, po.StartDate
    FROM ProductionOrder po LEFT JOIN Product p ON po.ProductID = p.ProductID ORDER BY po.StartDate DESC;
END
GO

CREATE OR ALTER PROCEDURE sp_GetProductionOrderById @ProductionOrderID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT po.ProductionOrderID, po.ProductID, p.ProductName, po.QuantityOrdered, po.QuantityCompleted, po.Status, po.StartDate, po.ExpectedEndDate
    FROM ProductionOrder po LEFT JOIN Product p ON po.ProductID = p.ProductID WHERE po.ProductionOrderID = @ProductionOrderID;
END
GO

CREATE OR ALTER PROCEDURE sp_CreateProductionOrder
    @ProductID INT, @QuantityOrdered INT, @StartDate DATE, @ExpectedEndDate DATE
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO ProductionOrder (ProductID, QuantityOrdered, StartDate, ExpectedEndDate, Status)
    VALUES (@ProductID, @QuantityOrdered, @StartDate, @ExpectedEndDate, 'Pending');
    SELECT SCOPE_IDENTITY() AS NewProductionOrderID;
END
GO

CREATE OR ALTER PROCEDURE sp_UpdateProductionOrder
    @ProductionOrderID INT, @QuantityOrdered INT, @QuantityCompleted INT, @Status NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE ProductionOrder SET QuantityOrdered = @QuantityOrdered, QuantityCompleted = @QuantityCompleted, Status = @Status
    WHERE ProductionOrderID = @ProductionOrderID;
END
GO

CREATE OR ALTER PROCEDURE sp_DeleteProductionOrder @ProductionOrderID INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM TailorAssignment WHERE ProductionOrderID = @ProductionOrderID;
    DELETE FROM ProductionOrder WHERE ProductionOrderID = @ProductionOrderID;
END
GO

CREATE OR ALTER PROCEDURE sp_SearchProductionOrders @SearchTerm NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT po.ProductionOrderID, p.ProductName, po.QuantityOrdered, po.Status
    FROM ProductionOrder po LEFT JOIN Product p ON po.ProductID = p.ProductID
    WHERE p.ProductName LIKE '%' + @SearchTerm + '%';
END
GO

CREATE OR ALTER PROCEDURE sp_GetProductionOrderStatistics
AS
BEGIN
    SET NOCOUNT ON;
    SELECT COUNT(*) AS TotalOrders,
           SUM(CASE WHEN Status = 'Pending' THEN 1 ELSE 0 END) AS PendingOrders,
           SUM(CASE WHEN Status = 'In Progress' THEN 1 ELSE 0 END) AS InProgressOrders,
           SUM(CASE WHEN Status = 'Completed' THEN 1 ELSE 0 END) AS CompletedOrders
    FROM ProductionOrder;
END
GO

CREATE OR ALTER PROCEDURE sp_GetProductionOrderItems @ProductionOrderID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT poi.ProductionOrderItemID, poi.RawMaterialID, rm.MaterialName, poi.QuantityRequired, poi.QuantityUsed
    FROM ProductionOrderItem poi LEFT JOIN RawMaterial rm ON poi.RawMaterialID = rm.RawMaterialID
    WHERE poi.ProductionOrderID = @ProductionOrderID;
END
GO

CREATE OR ALTER PROCEDURE sp_AddProductionOrderItem @ProductionOrderID INT, @RawMaterialID INT, @QuantityRequired DECIMAL(18,2)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO ProductionOrderItem (ProductionOrderID, RawMaterialID, QuantityRequired) VALUES (@ProductionOrderID, @RawMaterialID, @QuantityRequired);
END
GO

CREATE OR ALTER PROCEDURE sp_UpdateProductionOrderItem @ProductionOrderItemID INT, @QuantityUsed DECIMAL(18,2)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE ProductionOrderItem SET QuantityUsed = @QuantityUsed WHERE ProductionOrderItemID = @ProductionOrderItemID;
END
GO

CREATE OR ALTER PROCEDURE sp_DeleteProductionOrderItem @ProductionOrderItemID INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM ProductionOrderItem WHERE ProductionOrderItemID = @ProductionOrderItemID;
END
GO

-- =============================================
-- SECTION 11: DELIVERY MANAGEMENT (8)
-- =============================================

CREATE OR ALTER PROCEDURE sp_GetAllDeliveries
AS
BEGIN
    SET NOCOUNT ON;
    SELECT d.DeliveryID, d.SalesOrderID, d.DealID, d.DeliveryAddress, d.Status, d.ScheduledDate, d.DeliveredDate,
           CASE WHEN d.SalesOrderID IS NOT NULL THEN r.CompanyName ELSE dl.ClientName END AS CustomerName
    FROM Delivery d
    LEFT JOIN SalesOrder so ON d.SalesOrderID = so.SalesOrderID
    LEFT JOIN Retailer r ON so.RetailerID = r.RetailerID
    LEFT JOIN Deal dl ON d.DealID = dl.DealID
    ORDER BY d.ScheduledDate DESC;
END
GO

CREATE OR ALTER PROCEDURE sp_GetDeliveryById @DeliveryID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT d.DeliveryID, d.SalesOrderID, d.DealID, d.DeliveryAddress, d.City, d.Province, d.Status, d.ScheduledDate, d.DeliveredDate
    FROM Delivery d WHERE d.DeliveryID = @DeliveryID;
END
GO

CREATE OR ALTER PROCEDURE sp_GetDeliveryBySalesOrderId @SalesOrderID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT DeliveryID, SalesOrderID, DeliveryAddress, Status, ScheduledDate, DeliveredDate FROM Delivery WHERE SalesOrderID = @SalesOrderID;
END
GO

CREATE OR ALTER PROCEDURE sp_UpdateDelivery
    @DeliveryID INT, @DeliveryAddress NVARCHAR(500), @City NVARCHAR(50), @Province NVARCHAR(50), @ScheduledDate DATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Delivery SET DeliveryAddress = @DeliveryAddress, City = @City, Province = @Province, ScheduledDate = @ScheduledDate
    WHERE DeliveryID = @DeliveryID;
END
GO

CREATE OR ALTER PROCEDURE sp_UpdateDeliveryStatus @DeliveryID INT, @Status NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        UPDATE Delivery SET Status = @Status, DeliveredDate = CASE WHEN @Status = 'Delivered' THEN GETDATE() ELSE NULL END
        WHERE DeliveryID = @DeliveryID;
        
        IF @Status = 'Delivered'
        BEGIN
            DECLARE @SalesOrderID INT, @DealID INT;
            SELECT @SalesOrderID = SalesOrderID, @DealID = DealID FROM Delivery WHERE DeliveryID = @DeliveryID;
            IF @SalesOrderID IS NOT NULL UPDATE SalesOrder SET Status = 'Delivered' WHERE SalesOrderID = @SalesOrderID;
            IF @DealID IS NOT NULL UPDATE Deal SET Status = 'Delivered' WHERE DealID = @DealID;
        END
        COMMIT TRANSACTION;
        SELECT 'SUCCESS' AS Status;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SELECT 'ERROR' AS Status, ERROR_MESSAGE() AS Message;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE sp_DeleteDelivery @DeliveryID INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM Delivery WHERE DeliveryID = @DeliveryID;
END
GO

CREATE OR ALTER PROCEDURE sp_SearchDeliveries @SearchTerm NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT d.DeliveryID, d.DeliveryAddress, d.Status, d.ScheduledDate
    FROM Delivery d WHERE d.DeliveryAddress LIKE '%' + @SearchTerm + '%';
END
GO

CREATE OR ALTER PROCEDURE sp_GetDeliveryStatistics
AS
BEGIN
    SET NOCOUNT ON;
    SELECT COUNT(*) AS TotalDeliveries,
           SUM(CASE WHEN Status = 'Pending' THEN 1 ELSE 0 END) AS PendingDeliveries,
           SUM(CASE WHEN Status = 'In Transit' THEN 1 ELSE 0 END) AS InTransitDeliveries,
           SUM(CASE WHEN Status = 'Delivered' THEN 1 ELSE 0 END) AS CompletedDeliveries
    FROM Delivery;
END
GO

CREATE OR ALTER PROCEDURE sp_GetDeliveryAssignments @DeliveryPersonID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT d.DeliveryID, d.DeliveryAddress, d.Status, d.ScheduledDate,
           CASE WHEN d.SalesOrderID IS NOT NULL THEN 'SalesOrder' ELSE 'Deal' END AS OrderType
    FROM Delivery d WHERE (@DeliveryPersonID IS NULL OR d.DeliveredBy = @DeliveryPersonID);
END
GO

-- =============================================
-- SECTION 12: REVENUE & FINANCIAL (12)
-- =============================================

CREATE OR ALTER PROCEDURE sp_GetRevenueByDateRange @StartDate DATE, @EndDate DATE
AS
BEGIN
    SET NOCOUNT ON;
    SELECT SUM(TotalAmount) AS TotalRevenue, COUNT(*) AS OrderCount FROM SalesOrder WHERE Status = 'Delivered' AND OrderDate BETWEEN @StartDate AND @EndDate;
END
GO

CREATE OR ALTER PROCEDURE sp_GetSalesOrdersByDateRange @StartDate DATE, @EndDate DATE
AS
BEGIN
    SET NOCOUNT ON;
    SELECT SalesOrderID, TotalAmount, OrderDate, Status FROM SalesOrder WHERE OrderDate BETWEEN @StartDate AND @EndDate;
END
GO

CREATE OR ALTER PROCEDURE sp_GetDealsByDateRange @StartDate DATE, @EndDate DATE
AS
BEGIN
    SET NOCOUNT ON;
    SELECT DealID, EstimatedValue AS TotalAmount, StartDate, Status FROM Deal WHERE StartDate BETWEEN @StartDate AND @EndDate;
END
GO

CREATE OR ALTER PROCEDURE sp_GetPurchasesByDateRange @StartDate DATE, @EndDate DATE
AS
BEGIN
    SET NOCOUNT ON;
    SELECT RawMaterialPurchaseID, TotalAmount, PurchaseDate FROM RawMaterialPurchase WHERE PurchaseDate BETWEEN @StartDate AND @EndDate;
END
GO

CREATE OR ALTER PROCEDURE sp_GetExpensesByDateRange @StartDate DATE, @EndDate DATE
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ExpenseID, Amount, ExpenseDate, Category FROM MiscExpense WHERE ExpenseDate BETWEEN @StartDate AND @EndDate;
END
GO

CREATE OR ALTER PROCEDURE sp_AddRawMaterialPurchase
    @RawMaterialID INT, @Quantity DECIMAL(18,2), @UnitPrice DECIMAL(18,2), @PurchaseDate DATE
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO RawMaterialPurchase (RawMaterialID, Quantity, UnitPrice, TotalAmount, PurchaseDate)
    VALUES (@RawMaterialID, @Quantity, @UnitPrice, @Quantity * @UnitPrice, @PurchaseDate);
    UPDATE RawMaterial SET Quantity = Quantity + @Quantity WHERE RawMaterialID = @RawMaterialID;
END
GO

CREATE OR ALTER PROCEDURE sp_AddMiscExpense @Category NVARCHAR(50), @Amount DECIMAL(18,2), @Description NVARCHAR(500), @ExpenseDate DATE
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO MiscExpense (Category, Amount, Description, ExpenseDate) VALUES (@Category, @Amount, @Description, @ExpenseDate);
END
GO

CREATE OR ALTER PROCEDURE sp_GetMonthlySalaryStatus @Month INT, @Year INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT CASE WHEN EXISTS (SELECT 1 FROM SalaryPayment WHERE PaymentMonth = @Month AND PaymentYear = @Year) THEN 1 ELSE 0 END AS IsPaid,
           (SELECT SUM(Salary) FROM Employee WHERE IsActive = 1) AS TotalSalary;
END
GO

CREATE OR ALTER PROCEDURE sp_PayMonthlySalary @Month INT, @Year INT
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM SalaryPayment WHERE PaymentMonth = @Month AND PaymentYear = @Year)
    BEGIN
        INSERT INTO SalaryPayment (PaymentMonth, PaymentYear, TotalAmount, PaymentDate, EmployeeCount)
        SELECT @Month, @Year, SUM(Salary), GETDATE(), COUNT(*) FROM Employee WHERE IsActive = 1;
        SELECT 'SUCCESS' AS Status;
    END
    ELSE SELECT 'ALREADY_PAID' AS Status;
END
GO

CREATE OR ALTER PROCEDURE sp_GetUnpaidSalaryMonths
AS
BEGIN
    SET NOCOUNT ON;
    -- Returns months where salaries haven't been paid
    SELECT DISTINCT MONTH(OrderDate) AS Month, YEAR(OrderDate) AS Year
    FROM SalesOrder WHERE NOT EXISTS (SELECT 1 FROM SalaryPayment sp WHERE sp.PaymentMonth = MONTH(SalesOrder.OrderDate) AND sp.PaymentYear = YEAR(SalesOrder.OrderDate));
END
GO

CREATE OR ALTER PROCEDURE sp_GetMonthRevenue @Month INT, @Year INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT COALESCE(SUM(TotalAmount), 0) AS Revenue FROM SalesOrder WHERE Status = 'Delivered' AND MONTH(OrderDate) = @Month AND YEAR(OrderDate) = @Year;
END
GO

CREATE OR ALTER PROCEDURE sp_CalculateMonthlyRevenue @Month INT, @Year INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @SalesIncome DECIMAL(18,2), @DealIncome DECIMAL(18,2), @Salaries DECIMAL(18,2), @Materials DECIMAL(18,2), @Expenses DECIMAL(18,2);
    
    SELECT @SalesIncome = COALESCE(SUM(TotalAmount), 0) FROM SalesOrder WHERE Status = 'Delivered' AND MONTH(OrderDate) = @Month AND YEAR(OrderDate) = @Year;
    SELECT @DealIncome = COALESCE(SUM(EstimatedValue), 0) FROM Deal WHERE Status = 'Delivered' AND MONTH(StartDate) = @Month AND YEAR(StartDate) = @Year;
    SELECT @Salaries = COALESCE(SUM(TotalAmount), 0) FROM SalaryPayment WHERE PaymentMonth = @Month AND PaymentYear = @Year;
    SELECT @Materials = COALESCE(SUM(TotalAmount), 0) FROM RawMaterialPurchase WHERE MONTH(PurchaseDate) = @Month AND YEAR(PurchaseDate) = @Year;
    SELECT @Expenses = COALESCE(SUM(Amount), 0) FROM MiscExpense WHERE MONTH(ExpenseDate) = @Month AND YEAR(ExpenseDate) = @Year;
    
    SELECT @SalesIncome AS SalesIncome, @DealIncome AS DealIncome, (@SalesIncome + @DealIncome) AS TotalIncome,
           @Salaries AS Salaries, @Materials AS MaterialCost, @Expenses AS MiscExpenses,
           (@Salaries + @Materials + @Expenses) AS TotalExpenses,
           ((@SalesIncome + @DealIncome) - (@Salaries + @Materials + @Expenses)) AS NetProfit;
END
GO

-- =============================================
-- SECTION 13: PRODUCT MATERIAL REQUIREMENTS (7)
-- =============================================

CREATE OR ALTER PROCEDURE sp_AddProductMaterialRequirement @ProductID INT, @RawMaterialID INT, @QuantityPerUnit DECIMAL(18,4)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO ProductMaterialRequirement (ProductID, RawMaterialID, QuantityPerUnit) VALUES (@ProductID, @RawMaterialID, @QuantityPerUnit);
END
GO

CREATE OR ALTER PROCEDURE sp_UpdateProductMaterialRequirement @RequirementID INT, @QuantityPerUnit DECIMAL(18,4)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE ProductMaterialRequirement SET QuantityPerUnit = @QuantityPerUnit WHERE RequirementID = @RequirementID;
END
GO

CREATE OR ALTER PROCEDURE sp_DeleteProductMaterialRequirement @RequirementID INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM ProductMaterialRequirement WHERE RequirementID = @RequirementID;
END
GO

CREATE OR ALTER PROCEDURE sp_GetProductMaterials @ProductID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT pmr.RequirementID, pmr.RawMaterialID, rm.MaterialName, pmr.QuantityPerUnit, rm.Quantity AS AvailableStock
    FROM ProductMaterialRequirement pmr LEFT JOIN RawMaterial rm ON pmr.RawMaterialID = rm.RawMaterialID
    WHERE pmr.ProductID = @ProductID;
END
GO

CREATE OR ALTER PROCEDURE sp_CalculateProductionOrderMaterialRequirements @ProductionOrderID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT rm.RawMaterialID, rm.MaterialName, (pmr.QuantityPerUnit * po.QuantityOrdered) AS RequiredQuantity, rm.Quantity AS AvailableQuantity
    FROM ProductionOrder po
    INNER JOIN ProductMaterialRequirement pmr ON po.ProductID = pmr.ProductID
    INNER JOIN RawMaterial rm ON pmr.RawMaterialID = rm.RawMaterialID
    WHERE po.ProductionOrderID = @ProductionOrderID;
END
GO

CREATE OR ALTER PROCEDURE sp_CheckMaterialsAvailability @ProductID INT, @Quantity INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT rm.MaterialName, (pmr.QuantityPerUnit * @Quantity) AS Required, rm.Quantity AS Available,
           CASE WHEN rm.Quantity >= (pmr.QuantityPerUnit * @Quantity) THEN 'Available' ELSE 'Insufficient' END AS Status
    FROM ProductMaterialRequirement pmr
    INNER JOIN RawMaterial rm ON pmr.RawMaterialID = rm.RawMaterialID
    WHERE pmr.ProductID = @ProductID;
END
GO

CREATE OR ALTER PROCEDURE sp_GetAllProductMaterialRequirements
AS
BEGIN
    SET NOCOUNT ON;
    SELECT pmr.RequirementID, pmr.ProductID, p.ProductName, pmr.RawMaterialID, rm.MaterialName, pmr.QuantityPerUnit
    FROM ProductMaterialRequirement pmr
    LEFT JOIN Product p ON pmr.ProductID = p.ProductID
    LEFT JOIN RawMaterial rm ON pmr.RawMaterialID = rm.RawMaterialID;
END
GO

-- =============================================
-- SECTION 14: DEPARTMENT ANALYTICS (6)
-- =============================================

CREATE OR ALTER PROCEDURE sp_GetDepartmentsWithEmployeeCount
AS
BEGIN
    SET NOCOUNT ON;
    SELECT d.DepartmentID, d.DepartmentName, COUNT(e.EmployeeID) AS EmployeeCount
    FROM Department d LEFT JOIN Employee e ON d.DepartmentID = e.DepartmentID AND e.IsActive = 1
    WHERE d.IsActive = 1 GROUP BY d.DepartmentID, d.DepartmentName;
END
GO

CREATE OR ALTER PROCEDURE sp_GetEmployeesByDepartment @DepartmentID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT EmployeeID, FirstName, LastName, Email, Phone, Salary FROM Employee WHERE DepartmentID = @DepartmentID AND IsActive = 1;
END
GO

CREATE OR ALTER PROCEDURE sp_GetProductionDepartmentStats
AS
BEGIN
    SET NOCOUNT ON;
    SELECT COUNT(*) AS TotalOrders, SUM(QuantityOrdered) AS TotalQuantity,
           SUM(CASE WHEN Status = 'Completed' THEN 1 ELSE 0 END) AS CompletedOrders
    FROM ProductionOrder;
END
GO

CREATE OR ALTER PROCEDURE sp_GetSalesDepartmentStats
AS
BEGIN
    SET NOCOUNT ON;
    SELECT COUNT(*) AS TotalOrders, SUM(TotalAmount) AS TotalRevenue,
           SUM(CASE WHEN Status = 'Delivered' THEN TotalAmount ELSE 0 END) AS DeliveredRevenue
    FROM SalesOrder;
END
GO

CREATE OR ALTER PROCEDURE sp_GetTailorProductionPerformance
AS
BEGIN
    SET NOCOUNT ON;
    SELECT e.EmployeeID, e.FirstName + ' ' + e.LastName AS TailorName,
           COUNT(ta.AssignmentID) AS TotalAssignments,
           SUM(CASE WHEN ta.Status = 'Completed' THEN 1 ELSE 0 END) AS CompletedAssignments
    FROM Employee e
    INNER JOIN EmployeeRole r ON e.RoleID = r.RoleID
    LEFT JOIN TailorAssignment ta ON e.EmployeeID = ta.TailorID
    WHERE r.RoleName = 'Tailor' AND e.IsActive = 1
    GROUP BY e.EmployeeID, e.FirstName, e.LastName;
END
GO

CREATE OR ALTER PROCEDURE sp_GetSalespersonSalesPerformance
AS
BEGIN
    SET NOCOUNT ON;
    SELECT e.EmployeeID, e.FirstName + ' ' + e.LastName AS SalespersonName,
           COUNT(so.SalesOrderID) AS TotalOrders, COALESCE(SUM(so.TotalAmount), 0) AS TotalSales
    FROM Employee e
    INNER JOIN EmployeeRole r ON e.RoleID = r.RoleID
    LEFT JOIN SalesOrder so ON e.EmployeeID = so.SalesRepID
    WHERE r.RoleName IN ('Salesperson', 'Sales Manager') AND e.IsActive = 1
    GROUP BY e.EmployeeID, e.FirstName, e.LastName;
END
GO

PRINT '✓ All 95 Active Procedures Created Successfully!';
GO
