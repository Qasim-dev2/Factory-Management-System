-- ================================================================================
-- GARMENTS FACTORY MANAGEMENT SYSTEM - USEFUL QUERIES
-- ================================================================================
-- This file contains useful queries for testing and verification
-- Updated to match the new merged Employee table structure
-- (SalespersonDetails and TailorDetails merged into Employee)
-- ================================================================================

USE GarmentsFactoryDB;
GO

-- ================================================================================
-- VIEW ALL TABLES DATA
-- ================================================================================

-- 1. View all Departments
SELECT * FROM Department;

-- 2. View all Employee Roles
SELECT * FROM EmployeeRole;

-- 3. View all Employees with Department and Role names
SELECT 
    e.EmployeeID,
    CONCAT(e.FirstName, ' ', e.LastName) AS FullName,
    e.CNIC,
    e.Phone,
    e.Email,
    d.DepartmentName,
    r.RoleName AS Position,
    e.ShiftType,
    e.Salary,
    e.JoinDate,
    e.Address,
    e.EmergencyContact,
    e.IsActive
FROM Employee e
INNER JOIN Department d ON e.DepartmentID = d.DepartmentID
INNER JOIN EmployeeRole r ON e.RoleID = r.RoleID
ORDER BY e.EmployeeID;

-- 4. View all Tailors with their details (from merged Employee table)
SELECT 
    e.EmployeeID,
    CONCAT(e.FirstName, ' ', e.LastName) AS FullName,
    e.Phone,
    e.Email,
    e.Specialization,
    e.PieceRate,
    e.TotalPiecesCompleted,
    e.Salary,
    e.ShiftType
FROM Employee e
INNER JOIN EmployeeRole r ON e.RoleID = r.RoleID
WHERE r.RoleName = 'Tailor'
ORDER BY e.FirstName, e.LastName;

-- 5. View all Salespersons with their details (from merged Employee table)
SELECT 
    e.EmployeeID,
    CONCAT(e.FirstName, ' ', e.LastName) AS FullName,
    e.Phone,
    e.Email,
    e.CommissionRate,
    e.SalesTarget,
    e.TotalSales,
    e.SalesRegion,
    e.Salary,
    e.ShiftType
FROM Employee e
INNER JOIN EmployeeRole r ON e.RoleID = r.RoleID
WHERE r.RoleName = 'Salesperson'
ORDER BY e.FirstName, e.LastName;

-- 6. View all Products with Stock
SELECT 
    p.ProductID,
    p.ProductName,
    p.SKU,
    p.Category,
    p.AvailableSizes AS Sizes,
    p.AvailableColors AS Colors,
    p.SalePrice,
    p.CostPrice,
    p.StockQuantity,
    p.MinimumStock,
    p.ProductionStatus,
    CASE 
        WHEN p.StockQuantity <= 0 THEN 'OUT OF STOCK'
        WHEN p.StockQuantity <= p.MinimumStock THEN 'LOW STOCK'
        ELSE 'IN STOCK'
    END AS StockStatus
FROM Product p
ORDER BY p.Category, p.ProductName;

-- 7. View Stock Entries with Product details
SELECT 
    s.StockID,
    p.ProductName,
    p.Category,
    s.BatchNo,
    s.EntryDate,
    s.Quantity,
    s.StockStatus,
    s.ProgressPercentage,
    s.Location,
    s.Notes
FROM Stock s
INNER JOIN Product p ON s.ProductID = p.ProductID
ORDER BY s.EntryDate DESC;

-- 8. View all Raw Materials
SELECT 
    RawMaterialID,
    MaterialName,
    Category,
    Unit,
    UnitPrice,
    Quantity,
    MinimumStock,
    CASE 
        WHEN Quantity <= 0 THEN 'OUT OF STOCK'
        WHEN Quantity <= MinimumStock THEN 'LOW STOCK'
        ELSE 'IN STOCK'
    END AS StockStatus,
    Supplier,
    Description
FROM RawMaterial
ORDER BY Category, MaterialName;

-- 9. View all Retailers with Sales Rep info
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
    r.PaymentTerms,
    r.DiscountPercentage,
    r.Priority,
    r.Status,
    CONCAT(e.FirstName, ' ', e.LastName) AS SalesRepName
FROM Retailer r
LEFT JOIN Employee e ON r.SalesRepID = e.EmployeeID
ORDER BY r.CompanyName;

-- 10. View Sales Orders with Retailer and Salesperson info
SELECT 
    so.SalesOrderID,
    so.OrderDate,
    ret.CompanyName AS RetailerName,
    ret.ContactPerson,
    CONCAT(e.FirstName, ' ', e.LastName) AS SalespersonName,
    so.ExpectedDeliveryDate,
    so.PriorityLevel,
    so.Status,
    so.PaymentStatus,
    so.SubTotal,
    so.DiscountAmount,
    so.TotalAmount,
    so.InternalNotes
FROM SalesOrder so
INNER JOIN Retailer ret ON so.RetailerID = ret.RetailerID
LEFT JOIN Employee e ON so.SalesRepID = e.EmployeeID
ORDER BY so.OrderDate DESC;

-- 11. View Sales Order Items with details
SELECT 
    soi.SalesOrderItemID,
    so.SalesOrderID,
    ret.CompanyName AS RetailerName,
    p.ProductName,
    p.SKU,
    soi.Size,
    soi.Color,
    soi.Quantity,
    soi.UnitPrice,
    soi.Discount,
    soi.TotalPrice
FROM SalesOrderItem soi
INNER JOIN SalesOrder so ON soi.SalesOrderID = so.SalesOrderID
INNER JOIN Retailer ret ON so.RetailerID = ret.RetailerID
INNER JOIN Product p ON soi.ProductID = p.ProductID
ORDER BY so.SalesOrderID, soi.SalesOrderItemID;

-- 12. View all Deals with Manager info
SELECT 
    d.DealID,
    d.DealTitle,
    d.DealType,
    d.ClientName,
    d.ContactPerson,
    d.Email,
    d.Phone,
    d.EstimatedValue,
    d.Currency,
    d.Priority,
    d.StartDate,
    d.EndDate,
    d.Status,
    CONCAT(e.FirstName, ' ', e.LastName) AS AssignedManager
FROM Deal d
LEFT JOIN Employee e ON d.AssignedManagerID = e.EmployeeID
ORDER BY d.CreatedDate DESC;

-- 13. View Production Orders with details
SELECT 
    po.ProductionOrderID,
    p.ProductName,
    p.Category,
    po.QuantityOrdered,
    po.QuantityCompleted,
    (po.QuantityOrdered - po.QuantityCompleted) AS Remaining,
    CAST(po.QuantityCompleted * 100.0 / NULLIF(po.QuantityOrdered, 0) AS DECIMAL(5,2)) AS ProgressPercent,
    po.StartDate,
    po.ExpectedEndDate,
    po.Status,
    po.Priority,
    CONCAT(e.FirstName, ' ', e.LastName) AS CreatedBy
FROM ProductionOrder po
INNER JOIN Product p ON po.ProductID = p.ProductID
LEFT JOIN Employee e ON po.CreatedByEmployeeID = e.EmployeeID
ORDER BY po.StartDate DESC;

-- 14. View Tailor Tasks with details (updated for merged Employee table)
SELECT 
    tt.TailorTaskID,
    CONCAT(e.FirstName, ' ', e.LastName) AS TailorName,
    e.Specialization,
    p.ProductName,
    tt.QuantityAssigned,
    tt.QuantityCompleted,
    (tt.QuantityAssigned - tt.QuantityCompleted) AS Remaining,
    CAST(tt.QuantityCompleted * 100.0 / NULLIF(tt.QuantityAssigned, 0) AS DECIMAL(5,2)) AS ProgressPercent,
    tt.Status,
    tt.StartDate,
    tt.EndDate,
    tt.Notes
FROM TailorTask tt
INNER JOIN Employee e ON tt.EmployeeID = e.EmployeeID
INNER JOIN ProductionOrder po ON tt.ProductionOrderID = po.ProductionOrderID
INNER JOIN Product p ON po.ProductID = p.ProductID
ORDER BY tt.TailorTaskID;

-- 15. View Stock Usage (Raw Material Consumption) - updated for merged Employee
SELECT 
    su.StockUsageID,
    CONCAT(e.FirstName, ' ', e.LastName) AS WorkerName,
    rm.MaterialName,
    rm.Category AS MaterialCategory,
    su.QuantityUsed,
    rm.Unit,
    (su.QuantityUsed * rm.UnitPrice) AS TotalCost,
    su.UsageDate,
    su.Notes
FROM StockUsage su
INNER JOIN Employee e ON su.EmployeeID = e.EmployeeID
INNER JOIN RawMaterial rm ON su.RawMaterialID = rm.RawMaterialID
ORDER BY su.UsageDate DESC;

-- 16. View Deliveries with details
SELECT 
    d.DeliveryID,
    so.SalesOrderID,
    ret.CompanyName AS RetailerName,
    ret.ContactPerson,
    CONCAT(e.FirstName, ' ', e.LastName) AS DeliveredBy,
    d.DeliveryDate,
    d.DeliveryAddress,
    d.City,
    d.Province,
    d.TrackingNumber,
    d.DeliveryMethod,
    d.DeliveryCost,
    d.Status,
    d.ReceiverName,
    d.ReceiverPhone,
    so.TotalAmount AS OrderAmount
FROM Delivery d
INNER JOIN SalesOrder so ON d.SalesOrderID = so.SalesOrderID
INNER JOIN Retailer ret ON so.RetailerID = ret.RetailerID
LEFT JOIN Employee e ON d.DeliveredBy = e.EmployeeID
ORDER BY d.DeliveryID;

-- ================================================================================
-- SUMMARY REPORTS
-- ================================================================================

-- Sales Summary by Salesperson (updated for merged Employee table)
SELECT 
    e.EmployeeID,
    CONCAT(e.FirstName, ' ', e.LastName) AS SalespersonName,
    e.SalesRegion,
    e.CommissionRate,
    e.SalesTarget,
    e.TotalSales,
    COUNT(so.SalesOrderID) AS TotalOrders,
    SUM(so.TotalAmount) AS OrdersTotal,
    AVG(so.TotalAmount) AS AverageOrderValue,
    CASE 
        WHEN e.SalesTarget > 0 THEN CAST(e.TotalSales * 100.0 / e.SalesTarget AS DECIMAL(5,2))
        ELSE 0 
    END AS TargetAchievementPercent
FROM Employee e
INNER JOIN EmployeeRole r ON e.RoleID = r.RoleID
LEFT JOIN SalesOrder so ON e.EmployeeID = so.SalesRepID
WHERE r.RoleName = 'Salesperson'
GROUP BY e.EmployeeID, e.FirstName, e.LastName, e.SalesRegion, 
         e.CommissionRate, e.SalesTarget, e.TotalSales
ORDER BY OrdersTotal DESC;

-- Production Summary by Tailor (updated for merged Employee table)
SELECT 
    e.EmployeeID,
    CONCAT(e.FirstName, ' ', e.LastName) AS TailorName,
    e.Specialization,
    e.PieceRate,
    e.TotalPiecesCompleted,
    COUNT(tt.TailorTaskID) AS TotalTasks,
    SUM(tt.QuantityAssigned) AS TotalAssigned,
    SUM(tt.QuantityCompleted) AS TotalCompletedTasks,
    CAST(SUM(tt.QuantityCompleted) * 100.0 / NULLIF(SUM(tt.QuantityAssigned), 0) AS DECIMAL(5,2)) AS CompletionRate,
    (e.TotalPiecesCompleted * e.PieceRate) AS TotalEarnings
FROM Employee e
INNER JOIN EmployeeRole r ON e.RoleID = r.RoleID
LEFT JOIN TailorTask tt ON e.EmployeeID = tt.EmployeeID
WHERE r.RoleName = 'Tailor'
GROUP BY e.EmployeeID, e.FirstName, e.LastName, e.Specialization, 
         e.PieceRate, e.TotalPiecesCompleted
ORDER BY CompletionRate DESC;

-- Employee Count by Department
SELECT 
    d.DepartmentName,
    COUNT(e.EmployeeID) AS EmployeeCount,
    SUM(CASE WHEN e.IsActive = 1 THEN 1 ELSE 0 END) AS ActiveCount,
    SUM(CASE WHEN e.IsActive = 0 THEN 1 ELSE 0 END) AS InactiveCount,
    AVG(e.Salary) AS AverageSalary
FROM Department d
LEFT JOIN Employee e ON d.DepartmentID = e.DepartmentID
GROUP BY d.DepartmentID, d.DepartmentName
ORDER BY EmployeeCount DESC;

-- Employee Count by Position/Role
SELECT 
    r.RoleName AS Position,
    COUNT(e.EmployeeID) AS EmployeeCount,
    AVG(e.Salary) AS AverageSalary,
    MIN(e.Salary) AS MinSalary,
    MAX(e.Salary) AS MaxSalary
FROM EmployeeRole r
LEFT JOIN Employee e ON r.RoleID = e.RoleID
GROUP BY r.RoleID, r.RoleName
ORDER BY EmployeeCount DESC;

-- Low Stock Alert (Products)
SELECT 
    p.ProductID,
    p.ProductName,
    p.SKU,
    p.Category,
    p.StockQuantity AS CurrentStock,
    p.MinimumStock,
    (p.MinimumStock - p.StockQuantity) AS ShortageAmount,
    p.Supplier,
    p.SalePrice
FROM Product p
WHERE p.StockQuantity <= p.MinimumStock
ORDER BY (p.MinimumStock - p.StockQuantity) DESC;

-- Low Stock Alert (Raw Materials)
SELECT 
    RawMaterialID,
    MaterialName,
    Category,
    Quantity AS CurrentStock,
    MinimumStock,
    (MinimumStock - Quantity) AS ShortageAmount,
    Supplier,
    UnitPrice
FROM RawMaterial
WHERE Quantity <= MinimumStock
ORDER BY (MinimumStock - Quantity) DESC;

-- Monthly Sales Summary
SELECT 
    YEAR(so.OrderDate) AS Year,
    MONTH(so.OrderDate) AS Month,
    DATENAME(MONTH, so.OrderDate) AS MonthName,
    COUNT(so.SalesOrderID) AS TotalOrders,
    SUM(so.TotalAmount) AS TotalSales,
    AVG(so.TotalAmount) AS AverageOrderValue,
    SUM(CASE WHEN so.PaymentStatus = 'Paid' THEN so.TotalAmount ELSE 0 END) AS PaidAmount,
    SUM(CASE WHEN so.PaymentStatus = 'Pending' THEN so.TotalAmount ELSE 0 END) AS PendingAmount
FROM SalesOrder so
GROUP BY YEAR(so.OrderDate), MONTH(so.OrderDate), DATENAME(MONTH, so.OrderDate)
ORDER BY Year DESC, Month DESC;

-- Retailer Performance Summary
SELECT 
    r.RetailerID,
    r.CompanyName,
    r.City,
    r.Priority,
    COUNT(so.SalesOrderID) AS TotalOrders,
    SUM(so.TotalAmount) AS TotalPurchases,
    AVG(so.TotalAmount) AS AverageOrderValue,
    MAX(so.OrderDate) AS LastOrderDate,
    r.CreditLimit,
    r.CurrentBalance
FROM Retailer r
LEFT JOIN SalesOrder so ON r.RetailerID = so.RetailerID
GROUP BY r.RetailerID, r.CompanyName, r.City, r.Priority, 
         r.CreditLimit, r.CurrentBalance
ORDER BY TotalPurchases DESC;

-- Pending Deliveries
SELECT 
    d.DeliveryID,
    so.SalesOrderID,
    ret.CompanyName,
    ret.ContactPerson,
    ret.Phone,
    d.DeliveryAddress,
    d.City,
    so.OrderDate,
    so.ExpectedDeliveryDate,
    DATEDIFF(DAY, GETDATE(), so.ExpectedDeliveryDate) AS DaysUntilDue,
    so.TotalAmount,
    d.Status
FROM Delivery d
INNER JOIN SalesOrder so ON d.SalesOrderID = so.SalesOrderID
INNER JOIN Retailer ret ON so.RetailerID = ret.RetailerID
WHERE d.Status IN ('Pending', 'InTransit')
ORDER BY so.ExpectedDeliveryDate;

-- Active Deals Summary
SELECT 
    d.DealID,
    d.DealTitle,
    d.DealType,
    d.ClientName,
    d.EstimatedValue,
    d.Currency,
    d.Priority,
    d.Status,
    d.StartDate,
    d.EndDate,
    DATEDIFF(DAY, GETDATE(), d.EndDate) AS DaysRemaining,
    CONCAT(e.FirstName, ' ', e.LastName) AS AssignedManager
FROM Deal d
LEFT JOIN Employee e ON d.AssignedManagerID = e.EmployeeID
WHERE d.Status IN ('Active', 'Under Review', 'Pending Approval')
ORDER BY d.Priority DESC, d.EndDate;

PRINT 'Queries executed successfully!';
GO
