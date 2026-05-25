-- ================================================================================
-- GARMENTS FACTORY DATABASE - COMPLETE PROCEDURE REFERENCE
-- ================================================================================
-- Database: GarmentsFactoryDB
-- Purpose: Complete alphabetical listing of all 157 stored procedures
-- Format: Name | Purpose | Usage Example
-- Created: December 2025
-- ================================================================================

USE GarmentsFactoryDB;
GO

PRINT '========================================';
PRINT 'COMPLETE STORED PROCEDURE CATALOG';
PRINT 'Total Procedures: 157';
PRINT '========================================';
PRINT '';

-- ================================================================================
-- ALPHABETICAL INDEX OF ALL PROCEDURES
-- ================================================================================

/*
=================================================================================
A
=================================================================================

sp_AddDeal
    Purpose: Create new deal with auto-approval request
    Category: Sales Management
    Example:
        DECLARE @DealID INT;
        EXEC sp_AddDeal
            @DealTitle = 'Corporate Uniform Deal',
            @ClientName = 'ABC Corporation',
            @TotalAmount = 50000,
            @CreatedBy = 5,
            @NewDealID = @DealID OUTPUT;

sp_AddDealItem
    Purpose: Add item to deal and AUTO-UPDATE deal total
    Category: Sales Management
    Example:
        DECLARE @ItemID INT;
        EXEC sp_AddDealItem
            @DealID = 1,
            @ProductID = 3,
            @Quantity = 200,
            @UnitPrice = 250,
            @DealItemID = @ItemID OUTPUT;

sp_AddDepartment
    Purpose: Create new department
    Category: Core Management
    Example:
        DECLARE @DeptID INT;
        EXEC sp_AddDepartment
            @DepartmentName = 'Quality Control',
            @Description = 'Quality assurance and testing',
            @Budget = 500000,
            @NewDepartmentID = @DeptID OUTPUT;

sp_AddEmployee
    Purpose: Create new employee with credentials
    Category: Core Management
    Example:
        DECLARE @EmpID INT;
        EXEC sp_AddEmployee
            @FirstName = 'Ahmed',
            @LastName = 'Khan',
            @Email = 'ahmed@factory.com',
            @DepartmentID = 1,
            @JobTitle = 'Senior Tailor',
            @Salary = 35000,
            @Username = 'akhan',
            @Password = 'hashed_password',
            @NewEmployeeID = @EmpID OUTPUT;

sp_AddMiscExpense
    Purpose: Record miscellaneous expense
    Category: Financial Management
    Example:
        EXEC sp_AddMiscExpense
            @ExpenseDate = '2025-12-15',
            @Category = 'Utilities',
            @Description = 'Electricity Bill December',
            @Amount = 25000,
            @RecordedBy = 1;

sp_AddProduct
    Purpose: Create new product
    Category: Core Management
    Example:
        DECLARE @ProdID INT;
        EXEC sp_AddProduct
            @ProductName = 'Business Shirt',
            @SKU = 'BS-001',
            @Description = 'Formal business shirt',
            @Category = 'Shirts',
            @UnitPrice = 1200,
            @NewProductID = @ProdID OUTPUT;

sp_AddProductionOrderItem
    Purpose: Add item to production order
    Category: Production Management
    Example:
        EXEC sp_AddProductionOrderItem
            @ProductionOrderID = 1,
            @ProductID = 2,
            @Quantity = 50;

sp_AddProductMaterialRequirement
    Purpose: Define material requirements for product (Bill of Materials)
    Category: Core Management
    Example:
        EXEC sp_AddProductMaterialRequirement
            @ProductID = 1,
            @RawMaterialID = 5,
            @QuantityRequired = 2.5;  -- 2.5 meters per product

sp_AddRawMaterialCost
    Purpose: Record raw material cost
    Category: Financial Management
    Example:
        EXEC sp_AddRawMaterialCost
            @RawMaterialID = 1,
            @Cost = 15000,
            @RecordDate = '2025-12-15';

sp_AddRawMaterialPurchase
    Purpose: Record raw material purchase
    Category: Stock Management
    Example:
        EXEC sp_AddRawMaterialPurchase
            @RawMaterialID = 1,
            @Quantity = 500,
            @UnitPrice = 150,
            @Supplier = 'ABC Textiles',
            @PurchaseDate = '2025-12-15',
            @RecordedBy = 1;

sp_AddRawMaterialPurchaseWithRestock
    Purpose: Purchase and restock material in one step
    Category: Stock Management
    Example:
        EXEC sp_AddRawMaterialPurchaseWithRestock
            @RawMaterialID = 1,
            @Quantity = 1000,
            @UnitPrice = 145,
            @Supplier = 'XYZ Suppliers';

sp_AddRetailer
    Purpose: Create new retailer/customer
    Category: Core Management
    Example:
        DECLARE @RetailerID INT;
        EXEC sp_AddRetailer
            @CompanyName = 'Fashion Point',
            @ContactPerson = 'Ali Ahmed',
            @Email = 'ali@fashionpoint.com',
            @Phone = '0300-1234567',
            @Address = '123 Mall Road, Lahore',
            @NewRetailerID = @RetailerID OUTPUT;

sp_AddSalesOrder
    Purpose: Create sales order with AUTO-APPROVAL request
    Category: Sales Management
    Example:
        DECLARE @OrderID INT;
        EXEC sp_AddSalesOrder
            @OrderDate = '2025-12-15',
            @RetailerID = 1,
            @ShippingAddress = '456 Commercial Area, Karachi',
            @TotalAmount = 150000,
            @SalesRepID = 5,
            @NewSalesOrderID = @OrderID OUTPUT;

sp_AddSalesOrderItem
    Purpose: Add item to sales order and AUTO-UPDATE order total
    Category: Sales Management
    Example:
        DECLARE @ItemID INT;
        EXEC sp_AddSalesOrderItem
            @SalesOrderID = 1,
            @ProductID = 2,
            @Quantity = 100,
            @UnitPrice = 1500,
            @SalesOrderItemID = @ItemID OUTPUT;

sp_AddStockEntry
    Purpose: Add stock entry record
    Category: Stock Management
    Example:
        EXEC sp_AddStockEntry
            @ProductID = 1,
            @QuantityAdded = 100,
            @EntryDate = '2025-12-15',
            @RecordedBy = 1;

sp_ApproveOrder
    Purpose: Approve an order (simplified version)
    Category: Workflow Management
    Example:
        EXEC sp_ApproveOrder
            @ApprovalID = 1,
            @OwnerID = 1;

sp_ApproveOrderAndCreateProduction
    Purpose: Approve order, check materials, create production + tailor assignments
    Category: Workflow Management
    Automation: Creates ProductionOrder and TailorAssignments automatically
    Example:
        EXEC sp_ApproveOrderAndCreateProduction
            @ApprovalID = 1,
            @OwnerID = 1,
            @TailorIDs = '10,11,12';  -- Comma-separated tailor employee IDs

sp_AssignTailor
    Purpose: Assign tailor to production order
    Category: Production Management
    Example:
        EXEC sp_AssignTailor
            @TailorID = 10,
            @ProductionOrderID = 1,
            @ProductID = 2,
            @QuantityAssigned = 50;

sp_AuthenticateUser
    Purpose: Validate user login credentials
    Category: Authentication
    Example:
        EXEC sp_AuthenticateUser
            @Username = 'akhan',
            @Password = 'hashed_password';

sp_AutoPayPastSalaries
    Purpose: AUTO-GENERATE salary records for all employees for current month
    Category: Financial Management
    Automation: Creates Salary records automatically for all active employees
    Example:
        EXEC sp_AutoPayPastSalaries;

=================================================================================
C
=================================================================================

sp_CalculateMonthlyRevenue
    Purpose: Calculate revenue for specific month
    Category: Financial Analytics
    Example:
        EXEC sp_CalculateMonthlyRevenue
            @Year = 2025,
            @Month = 12;

sp_CalculateProductionOrderMaterialRequirements
    Purpose: Calculate total materials needed for production order
    Category: Production Management
    Example:
        EXEC sp_CalculateProductionOrderMaterialRequirements
            @ProductionOrderID = 1;

sp_CheckMaterialAvailability
    Purpose: Check if materials available for production
    Category: Stock Management
    Example:
        EXEC sp_CheckMaterialAvailability
            @ProductID = 1,
            @Quantity = 100;

sp_CheckMaterialsAvailability
    Purpose: Check materials availability (alternative)
    Category: Stock Management

sp_CheckMaterialsForOrder
    Purpose: Check materials for specific order
    Category: Stock Management
    Example:
        EXEC sp_CheckMaterialsForOrder
            @OrderID = 1,
            @OrderType = 'SalesOrder';

sp_CreateDeliveryFromProduction
    Purpose: Create delivery from completed production
    Category: Delivery Management
    Example:
        EXEC sp_CreateDeliveryFromProduction
            @ProductionOrderID = 1,
            @DeliveryPersonID = 15;

sp_CreateProductionOrder
    Purpose: Create new production order
    Category: Production Management
    Example:
        DECLARE @ProdOrderID INT;
        EXEC sp_CreateProductionOrder
            @ProductID = 1,
            @QuantityOrdered = 200,
            @Priority = 'High',
            @CreatedByEmployeeID = 1,
            @NewProductionOrderID = @ProdOrderID OUTPUT;

sp_CreateRawMaterial
    Purpose: Create material and AUTO-RECORD initial purchase
    Category: Core Management
    Automation: Automatically records purchase in PurchaseHistory
    Example:
        DECLARE @MaterialID INT;
        EXEC sp_CreateRawMaterial
            @MaterialName = 'Cotton Fabric',
            @Quantity = 1000,
            @Unit = 'Meters',
            @UnitPrice = 150,
            @Supplier = 'ABC Textiles',
            @MinimumStockLevel = 500,
            @RecordedBy = 1,
            @NewRawMaterialID = @MaterialID OUTPUT;

=================================================================================
D
=================================================================================

sp_DeductRawMaterialStock
    Purpose: Deduct materials for production order
    Category: Stock Management
    Automation: Deducts based on ProductMaterialRequirement
    Example:
        EXEC sp_DeductRawMaterialStock
            @ProductionOrderID = 1,
            @DeductedBy = 1;

sp_DeleteDeal
    Purpose: Delete deal (cascades to items)
    Category: Sales Management
    Example:
        EXEC sp_DeleteDeal @DealID = 1;

sp_DeleteDealItem
    Purpose: Delete deal item and update deal total
    Category: Sales Management
    Example:
        EXEC sp_DeleteDealItem @DealItemID = 5;

sp_DeleteDepartment
    Purpose: Delete department
    Category: Core Management
    Example:
        EXEC sp_DeleteDepartment @DepartmentID = 1;

sp_DeleteEmployee
    Purpose: Delete employee (soft delete - sets IsActive = 0)
    Category: Core Management
    Example:
        EXEC sp_DeleteEmployee @EmployeeID = 10;

sp_DeleteProduct
    Purpose: Delete product
    Category: Core Management
    Example:
        EXEC sp_DeleteProduct @ProductID = 5;

sp_DeleteProductionOrder
    Purpose: Delete production order
    Category: Production Management
    Example:
        EXEC sp_DeleteProductionOrder @ProductionOrderID = 1;

sp_DeleteProductionOrderItem
    Purpose: Delete production order item
    Category: Production Management
    Example:
        EXEC sp_DeleteProductionOrderItem @ProductionOrderItemID = 1;

sp_DeleteProductMaterialRequirement
    Purpose: Delete product material requirement
    Category: Core Management
    Example:
        EXEC sp_DeleteProductMaterialRequirement
            @ProductID = 1,
            @RawMaterialID = 5;

sp_DeleteRawMaterial
    Purpose: Delete raw material
    Category: Core Management
    Example:
        EXEC sp_DeleteRawMaterial @RawMaterialID = 1;

sp_DeleteRetailer
    Purpose: Delete retailer
    Category: Core Management
    Example:
        EXEC sp_DeleteRetailer @RetailerID = 1;

sp_DeleteSalesOrder
    Purpose: Delete sales order (cascades to items)
    Category: Sales Management
    Example:
        EXEC sp_DeleteSalesOrder @SalesOrderID = 1;

sp_DeleteStockEntry
    Purpose: Delete stock entry
    Category: Stock Management
    Example:
        EXEC sp_DeleteStockEntry @StockEntryID = 1;

sp_DeleteStockUsage
    Purpose: Delete stock usage record
    Category: Stock Management
    Example:
        EXEC sp_DeleteStockUsage @StockUsageID = 1;

=================================================================================
G
=================================================================================

sp_GetAllDeals
    Purpose: Get all deals with client information
    Category: Sales Management
    Example:
        EXEC sp_GetAllDeals;

sp_GetAllDeliveries
    Purpose: Get all deliveries with order info
    Category: Delivery Management
    Example:
        EXEC sp_GetAllDeliveries;

sp_GetAllDepartments
    Purpose: Get all departments
    Category: Core Management
    Example:
        EXEC sp_GetAllDepartments;

sp_GetAllProductionOrders
    Purpose: Get all production orders
    Category: Production Management
    Example:
        EXEC sp_GetAllProductionOrders;

sp_GetAllProductMaterialRequirements
    Purpose: Get all product material requirements (BOM)
    Category: Core Management
    Example:
        EXEC sp_GetAllProductMaterialRequirements;

sp_GetAllProducts
    Purpose: Get all products
    Category: Core Management
    Example:
        EXEC sp_GetAllProducts;

sp_GetAllRawMaterials
    Purpose: Get all raw materials
    Category: Core Management
    Example:
        EXEC sp_GetAllRawMaterials;

sp_GetAllRetailers
    Purpose: Get all retailers
    Category: Core Management
    Example:
        EXEC sp_GetAllRetailers;

sp_GetAllSalesOrders
    Purpose: Get all sales orders
    Category: Sales Management
    Example:
        EXEC sp_GetAllSalesOrders;

sp_GetAllStockEntries
    Purpose: Get all stock entries
    Category: Stock Management
    Example:
        EXEC sp_GetAllStockEntries;

sp_GetAllStockUsage
    Purpose: Get all stock usage records
    Category: Stock Management
    Example:
        EXEC sp_GetAllStockUsage;

sp_GetApprovalHistory
    Purpose: Get approval history for orders
    Category: Workflow Management
    Example:
        EXEC sp_GetApprovalHistory
            @OrderType = 'SalesOrder',
            @OrderID = 1;

sp_GetAvailableTailors
    Purpose: Get available tailors for assignment
    Category: Production Management
    Example:
        EXEC sp_GetAvailableTailors;

sp_GetDealById
    Purpose: Get deal details with items
    Category: Sales Management
    Example:
        EXEC sp_GetDealById @DealID = 1;

sp_GetDealItems
    Purpose: Get items for specific deal
    Category: Sales Management
    Example:
        EXEC sp_GetDealItems @DealID = 1;

sp_GetDealsByDateRange
    Purpose: Get deals in date range (revenue tracking)
    Category: Sales Management
    Example:
        EXEC sp_GetDealsByDateRange
            @StartDate = '2025-12-01',
            @EndDate = '2025-12-31';

sp_GetDealsByEmployee
    Purpose: Get deals created by employee
    Category: Sales Management
    Example:
        EXEC sp_GetDealsByEmployee @EmployeeID = 5;

sp_GetDealsByStatus
    Purpose: Get deals by status
    Category: Sales Management
    Example:
        EXEC sp_GetDealsByStatus @Status = 'Approved';

sp_GetDealStatistics
    Purpose: Get deal statistics for dashboard
    Category: Analytics
    Example:
        EXEC sp_GetDealStatistics;

sp_GetDeliveryAssignments
    Purpose: Get delivery assignments
    Category: Delivery Management
    Example:
        EXEC sp_GetDeliveryAssignments;

sp_GetDeliveryById
    Purpose: Get delivery details
    Category: Delivery Management
    Example:
        EXEC sp_GetDeliveryById @DeliveryID = 1;

sp_GetDeliveryPersonnel
    Purpose: Get all delivery personnel
    Category: Delivery Management
    Example:
        EXEC sp_GetDeliveryPersonnel;

sp_GetDeliveryStatistics
    Purpose: Get delivery statistics for dashboard
    Category: Analytics
    Example:
        EXEC sp_GetDeliveryStatistics;

sp_GetDepartmentById
    Purpose: Get single department details
    Category: Core Management
    Example:
        EXEC sp_GetDepartmentById @DepartmentID = 1;

sp_GetDepartments
    Purpose: Get all departments (alias)
    Category: Core Management
    Example:
        EXEC sp_GetDepartments;

sp_GetDepartmentsWithEmployeeCount
    Purpose: Get departments with employee counts
    Category: Core Management
    Example:
        EXEC sp_GetDepartmentsWithEmployeeCount;

sp_GetEmployeeById
    Purpose: Get employee details (all 24 fields)
    Category: Core Management
    Example:
        EXEC sp_GetEmployeeById @EmployeeID = 5;

sp_GetEmployeeRoles
    Purpose: Get distinct employee roles
    Category: Core Management
    Example:
        EXEC sp_GetEmployeeRoles;

sp_GetEmployees
    Purpose: Get all employees (alias)
    Category: Core Management
    Example:
        EXEC sp_GetEmployees;

sp_GetEmployeesByDepartment
    Purpose: Get employees in specific department
    Category: Core Management
    Example:
        EXEC sp_GetEmployeesByDepartment @DepartmentID = 1;

sp_GetExpensesByDateRange
    Purpose: Calculate expenses (salaries + materials)
    Category: Financial Analytics
    Example:
        EXEC sp_GetExpensesByDateRange
            @StartDate = '2025-12-01',
            @EndDate = '2025-12-31';

sp_GetInProcessProducts
    Purpose: Get products currently in production
    Category: Production Management
    Example:
        EXEC sp_GetInProcessProducts;

sp_GetLowStockRawMaterials
    Purpose: Get materials below minimum stock level
    Category: Stock Management
    Example:
        EXEC sp_GetLowStockRawMaterials;

sp_GetMonthlySalaryStatus
    Purpose: Get salary payment status for month
    Category: Financial Management
    Example:
        EXEC sp_GetMonthlySalaryStatus
            @Year = 2025,
            @Month = 12;

sp_GetMonthRevenue
    Purpose: Get revenue for specific month
    Category: Financial Analytics
    Example:
        EXEC sp_GetMonthRevenue
            @Year = 2025,
            @Month = 12;

sp_GetPendingApprovals
    Purpose: Get pending approval requests (owner dashboard)
    Category: Workflow Management
    Example:
        EXEC sp_GetPendingApprovals;

sp_GetProductById
    Purpose: Get product details
    Category: Core Management
    Example:
        EXEC sp_GetProductById @ProductID = 1;

sp_GetProductionDepartmentStats
    Purpose: Get production department statistics
    Category: Analytics
    Example:
        EXEC sp_GetProductionDepartmentStats;

sp_GetProductionOrderById
    Purpose: Get production order details
    Category: Production Management
    Example:
        EXEC sp_GetProductionOrderById @ProductionOrderID = 1;

sp_GetProductionOrderItems
    Purpose: Get items in production order
    Category: Production Management
    Example:
        EXEC sp_GetProductionOrderItems @ProductionOrderID = 1;

sp_GetProductionOrderStatistics
    Purpose: Get production order statistics
    Category: Analytics
    Example:
        EXEC sp_GetProductionOrderStatistics;

sp_GetProductionOrdersByStatus
    Purpose: Get production orders by status
    Category: Production Management
    Example:
        EXEC sp_GetProductionOrdersByStatus @Status = 'In Progress';

sp_GetProductMaterials
    Purpose: Get materials required for product
    Category: Core Management
    Example:
        EXEC sp_GetProductMaterials @ProductID = 1;

sp_GetProductsForOrder
    Purpose: Get products available for orders
    Category: Core Management
    Example:
        EXEC sp_GetProductsForOrder;

sp_GetProductsForStock
    Purpose: Get products for stock management
    Category: Stock Management
    Example:
        EXEC sp_GetProductsForStock;

sp_GetPurchaseHistory
    Purpose: Get purchase history for materials
    Category: Stock Management
    Example:
        EXEC sp_GetPurchaseHistory
            @RawMaterialID = NULL,  -- All materials
            @StartDate = '2025-12-01',
            @EndDate = '2025-12-31';

sp_GetPurchasesByDateRange
    Purpose: Get purchases in date range
    Category: Stock Management
    Example:
        EXEC sp_GetPurchasesByDateRange
            @StartDate = '2025-12-01',
            @EndDate = '2025-12-31';

sp_GetRawMaterialById
    Purpose: Get raw material details
    Category: Core Management
    Example:
        EXEC sp_GetRawMaterialById @RawMaterialID = 1;

sp_GetRawMaterialStatistics
    Purpose: Get raw material statistics
    Category: Analytics
    Example:
        EXEC sp_GetRawMaterialStatistics;

sp_GetReadyProducts
    Purpose: Get products ready for delivery
    Category: Production Management
    Example:
        EXEC sp_GetReadyProducts;

sp_GetRetailerById
    Purpose: Get retailer details
    Category: Core Management
    Example:
        EXEC sp_GetRetailerById @RetailerID = 1;

sp_GetRetailersForOrder
    Purpose: Get retailers available for orders
    Category: Core Management
    Example:
        EXEC sp_GetRetailersForOrder;

sp_GetRetailerStatistics
    Purpose: Get retailer statistics
    Category: Analytics
    Example:
        EXEC sp_GetRetailerStatistics;

sp_GetRetailersWithOutstandingBalance
    Purpose: Get retailers with unpaid balances
    Category: Financial Management
    Example:
        EXEC sp_GetRetailersWithOutstandingBalance;

sp_GetRevenueByDateRange
    Purpose: Calculate revenue from orders + deals
    Category: Financial Analytics
    Example:
        EXEC sp_GetRevenueByDateRange
            @StartDate = '2025-12-01',
            @EndDate = '2025-12-31';

sp_GetSalesDepartmentStats
    Purpose: Get sales department statistics
    Category: Analytics
    Example:
        EXEC sp_GetSalesDepartmentStats;

sp_GetSalesManagerStatistics
    Purpose: Get sales manager dashboard statistics
    Category: Analytics
    Example:
        EXEC sp_GetSalesManagerStatistics;

sp_GetSalesOrderById
    Purpose: Get sales order with items
    Category: Sales Management
    Example:
        EXEC sp_GetSalesOrderById @SalesOrderID = 1;

sp_GetSalesOrdersByDateRange
    Purpose: Get sales orders in date range
    Category: Sales Management
    Example:
        EXEC sp_GetSalesOrdersByDateRange
            @StartDate = '2025-12-01',
            @EndDate = '2025-12-31';

sp_GetSalesOrderStatistics
    Purpose: Get sales order statistics
    Category: Analytics
    Example:
        EXEC sp_GetSalesOrderStatistics;

sp_GetSalespersonsForOrder
    Purpose: Get salespersons for order assignment
    Category: Core Management
    Example:
        EXEC sp_GetSalespersonsForOrder;

sp_GetSalesRepresentatives
    Purpose: Get all sales representatives
    Category: Core Management
    Example:
        EXEC sp_GetSalesRepresentatives;

sp_GetShippedProducts
    Purpose: Get shipped products
    Category: Delivery Management
    Example:
        EXEC sp_GetShippedProducts;

sp_GetStockById
    Purpose: Get stock entry details
    Category: Stock Management
    Example:
        EXEC sp_GetStockById @StockID = 1;

sp_GetStockByProduct
    Purpose: Get stock for specific product
    Category: Stock Management
    Example:
        EXEC sp_GetStockByProduct @ProductID = 1;

sp_GetStockManagement
    Purpose: Get stock management overview
    Category: Stock Management
    Example:
        EXEC sp_GetStockManagement;

sp_GetStockStatistics
    Purpose: Get stock statistics
    Category: Analytics
    Example:
        EXEC sp_GetStockStatistics;

sp_GetStockUsageByEmployee
    Purpose: Get stock usage by employee
    Category: Stock Management
    Example:
        EXEC sp_GetStockUsageByEmployee @EmployeeID = 1;

sp_GetStockUsageById
    Purpose: Get stock usage details
    Category: Stock Management
    Example:
        EXEC sp_GetStockUsageById @StockUsageID = 1;

sp_GetStockUsageByMaterial
    Purpose: Get usage for specific material
    Category: Stock Management
    Example:
        EXEC sp_GetStockUsageByMaterial @RawMaterialID = 1;

sp_GetStockUsageByProductionOrder
    Purpose: Get stock usage for production order
    Category: Stock Management
    Example:
        EXEC sp_GetStockUsageByProductionOrder @ProductionOrderID = 1;

sp_GetStockUsageHistory
    Purpose: Get stock usage history
    Category: Stock Management
    Example:
        EXEC sp_GetStockUsageHistory
            @RawMaterialID = NULL,
            @StartDate = '2025-12-01',
            @EndDate = '2025-12-31';

sp_GetStockUsageStatistics
    Purpose: Get stock usage statistics
    Category: Analytics
    Example:
        EXEC sp_GetStockUsageStatistics;

sp_GetTailorAssignments
    Purpose: Get all tailor assignments
    Category: Production Management
    Example:
        EXEC sp_GetTailorAssignments;

sp_GetTailorAssignmentsByTailor
    Purpose: Get assignments for specific tailor
    Category: Production Management
    Example:
        EXEC sp_GetTailorAssignmentsByTailor @TailorID = 10;

sp_GetTailorsForAssignment
    Purpose: Get tailors available for assignment
    Category: Production Management
    Example:
        EXEC sp_GetTailorsForAssignment;

sp_GetTailorWorkload
    Purpose: Get current workload for tailor
    Category: Production Management
    Example:
        EXEC sp_GetTailorWorkload @TailorID = 10;

sp_GetTopSellingProducts
    Purpose: Get top selling products
    Category: Financial Analytics
    Example:
        EXEC sp_GetTopSellingProducts
            @TopCount = 10,
            @StartDate = '2025-12-01',
            @EndDate = '2025-12-31';

sp_GetUnpaidSalaryMonths
    Purpose: Get months with unpaid salaries
    Category: Financial Management
    Example:
        EXEC sp_GetUnpaidSalaryMonths @EmployeeID = 5;

sp_GetYearlyRevenue
    Purpose: Get revenue for entire year
    Category: Financial Analytics
    Example:
        EXEC sp_GetYearlyRevenue @Year = 2025;

=================================================================================
P
=================================================================================

sp_PayMonthlySalaries
    Purpose: Pay all salaries for specific month
    Category: Financial Management
    Example:
        EXEC sp_PayMonthlySalaries
            @Year = 2025,
            @Month = 12;

sp_PayMonthlySalary
    Purpose: Pay salary for specific employee
    Category: Financial Management
    Example:
        EXEC sp_PayMonthlySalary
            @EmployeeID = 5,
            @Year = 2025,
            @Month = 12;

=================================================================================
R
=================================================================================

sp_RecordStockUsage
    Purpose: Record stock usage for production
    Category: Stock Management
    Example:
        EXEC sp_RecordStockUsage
            @RawMaterialID = 1,
            @ProductionOrderID = 1,
            @QuantityUsed = 50,
            @UsedBy = 1,
            @Purpose = 'Production Order #1';

sp_RejectOrder
    Purpose: Reject approval request
    Category: Workflow Management
    Example:
        EXEC sp_RejectOrder
            @ApprovalID = 1,
            @OwnerID = 1,
            @Comments = 'Insufficient materials';

sp_ResetMiscExpense
    Purpose: Reset miscellaneous expense records
    Category: Financial Management
    Example:
        EXEC sp_ResetMiscExpense;

sp_RestockRawMaterial
    Purpose: Restock material and AUTO-RECORD purchase
    Category: Stock Management
    Automation: Automatically records purchase in PurchaseHistory
    Example:
        EXEC sp_RestockRawMaterial
            @RawMaterialID = 1,
            @QuantityToAdd = 500,
            @RecordedBy = 1;

sp_RestockRawMaterialWithPurchase
    Purpose: Restock with purchase details
    Category: Stock Management
    Example:
        EXEC sp_RestockRawMaterialWithPurchase
            @RawMaterialID = 1,
            @Quantity = 500,
            @UnitPrice = 150,
            @Supplier = 'ABC Textiles';

=================================================================================
S
=================================================================================

sp_SearchProductionOrders
    Purpose: Search production orders
    Category: Production Management
    Example:
        EXEC sp_SearchProductionOrders
            @SearchTerm = 'Shirt',
            @Status = 'In Progress';

sp_SearchProducts
    Purpose: Search products by name/SKU
    Category: Core Management
    Example:
        EXEC sp_SearchProducts @SearchTerm = 'Shirt';

sp_SearchRawMaterials
    Purpose: Search raw materials
    Category: Core Management
    Example:
        EXEC sp_SearchRawMaterials @SearchTerm = 'Cotton';

sp_SearchRetailers
    Purpose: Search retailers
    Category: Core Management
    Example:
        EXEC sp_SearchRetailers @SearchTerm = 'Fashion';

sp_SearchSalesOrders
    Purpose: Search sales orders
    Category: Sales Management
    Example:
        EXEC sp_SearchSalesOrders
            @SearchTerm = 'ABC Corp',
            @Status = 'Approved';

sp_SearchStockEntries
    Purpose: Search stock entries
    Category: Stock Management
    Example:
        EXEC sp_SearchStockEntries @SearchTerm = 'Shirt';

sp_SearchStockUsage
    Purpose: Search stock usage records
    Category: Stock Management
    Example:
        EXEC sp_SearchStockUsage @SearchTerm = 'Cotton';

=================================================================================
U
=================================================================================

sp_UpdateAssignmentStatus
    Purpose: Update tailor assignment status
    Category: Production Management
    Example:
        EXEC sp_UpdateAssignmentStatus
            @AssignmentID = 1,
            @Status = 'Complete';

sp_UpdateDeal
    Purpose: Update deal information
    Category: Sales Management
    Example:
        EXEC sp_UpdateDeal
            @DealID = 1,
            @DealTitle = 'Updated Title',
            @Status = 'In Progress';

sp_UpdateDealItem
    Purpose: Update deal item
    Category: Sales Management
    Example:
        EXEC sp_UpdateDealItem
            @DealItemID = 1,
            @Quantity = 250,
            @UnitPrice = 275;

sp_UpdateDelivery
    Purpose: Update delivery information
    Category: Delivery Management
    Example:
        EXEC sp_UpdateDelivery
            @DeliveryID = 1,
            @Status = 'Delivered',
            @ActualDeliveryDate = '2025-12-15';

sp_UpdateDeliveryStatus
    Purpose: Update delivery status
    Category: Delivery Management
    Example:
        EXEC sp_UpdateDeliveryStatus
            @DeliveryID = 1,
            @Status = 'In Transit';

sp_UpdateDepartment
    Purpose: Update department information
    Category: Core Management
    Example:
        EXEC sp_UpdateDepartment
            @DepartmentID = 1,
            @DepartmentName = 'Updated Name',
            @Budget = 600000;

sp_UpdateEmployee
    Purpose: Update employee information (all 24 fields)
    Category: Core Management
    Example:
        EXEC sp_UpdateEmployee
            @EmployeeID = 5,
            @FirstName = 'Ahmed',
            @Salary = 40000,
            @JobTitle = 'Lead Tailor';

sp_UpdateEmployeeCredentials
    Purpose: Update employee username/password
    Category: Authentication
    Example:
        EXEC sp_UpdateEmployeeCredentials
            @EmployeeID = 5,
            @Username = 'akhan_new',
            @Password = 'new_hashed_password';

sp_UpdateLastLogin
    Purpose: Track employee last login timestamp
    Category: Authentication
    Example:
        EXEC sp_UpdateLastLogin @EmployeeID = 5;

sp_UpdateProduct
    Purpose: Update product information
    Category: Core Management
    Example:
        EXEC sp_UpdateProduct
            @ProductID = 1,
            @ProductName = 'Updated Shirt',
            @UnitPrice = 1300;

sp_UpdateProductionOrder
    Purpose: Update production order
    Category: Production Management
    Example:
        EXEC sp_UpdateProductionOrder
            @ProductionOrderID = 1,
            @Status = 'Completed',
            @QuantityProduced = 200;

sp_UpdateProductionOrderItem
    Purpose: Update production order item
    Category: Production Management
    Example:
        EXEC sp_UpdateProductionOrderItem
            @ProductionOrderItemID = 1,
            @Quantity = 60;

sp_UpdateProductMaterialRequirement
    Purpose: Update product material requirement
    Category: Core Management
    Example:
        EXEC sp_UpdateProductMaterialRequirement
            @ProductID = 1,
            @RawMaterialID = 5,
            @QuantityRequired = 3.0;

sp_UpdateRawMaterial
    Purpose: Update material and AUTO-RECORD purchase if quantity increases
    Category: Core Management
    Automation: Records purchase if Quantity increased
    Example:
        EXEC sp_UpdateRawMaterial
            @RawMaterialID = 1,
            @MaterialName = 'Premium Cotton',
            @Quantity = 1500,  -- If increased, auto-records purchase
            @UnitPrice = 160;

sp_UpdateRetailer
    Purpose: Update retailer information
    Category: Core Management
    Example:
        EXEC sp_UpdateRetailer
            @RetailerID = 1,
            @CompanyName = 'Fashion Point Ltd',
            @Phone = '0300-9999999';

sp_UpdateRetailerBalance
    Purpose: Update retailer balance
    Category: Financial Management
    Example:
        EXEC sp_UpdateRetailerBalance
            @RetailerID = 1,
            @Balance = 50000;

sp_UpdateSalesOrder
    Purpose: Update sales order
    Category: Sales Management
    Example:
        EXEC sp_UpdateSalesOrder
            @SalesOrderID = 1,
            @Status = 'In Production',
            @TotalAmount = 175000;

sp_UpdateSalesOrderStatus
    Purpose: Update sales order status
    Category: Sales Management
    Example:
        EXEC sp_UpdateSalesOrderStatus
            @SalesOrderID = 1,
            @Status = 'Completed';

sp_UpdateSalesOrderTotal
    Purpose: Recalculate sales order total
    Category: Sales Management
    Example:
        EXEC sp_UpdateSalesOrderTotal @SalesOrderID = 1;

sp_UpdateStockEntry
    Purpose: Update stock entry
    Category: Stock Management
    Example:
        EXEC sp_UpdateStockEntry
            @StockEntryID = 1,
            @QuantityAdded = 150;

sp_UpdateStockStatus
    Purpose: Update stock status
    Category: Stock Management
    Example:
        EXEC sp_UpdateStockStatus
            @ProductID = 1,
            @Status = 'Available';

sp_UpdateTailorCompletionStatus
    Purpose: Update tailor completion status
    Category: Production Management
    Example:
        EXEC sp_UpdateTailorCompletionStatus
            @AssignmentID = 1,
            @CompletionPercentage = 75;

sp_UpdateTailorProgress
    Purpose: Update tailor progress with quantity
    Category: Production Management
    Example:
        EXEC sp_UpdateTailorProgress
            @TailorAssignmentID = 1,
            @QuantityCompleted = 45;

*/

PRINT '';
PRINT '========================================';
PRINT 'CATEGORY BREAKDOWN';
PRINT '========================================';
PRINT 'Authentication: 3 procedures';
PRINT 'Core Management (Dept/Emp/Product/Material/Retailer): 43 procedures';
PRINT 'Sales Management (Orders/Deals): 19 procedures';
PRINT 'Production Management: 15 procedures';
PRINT 'Delivery Management: 8 procedures';
PRINT 'Stock Management: 25 procedures';
PRINT 'Financial Management: 15 procedures';
PRINT 'Analytics & Statistics: 15 procedures';
PRINT 'Workflow Management: 4 procedures';
PRINT 'System Procedures: ~10 procedures';
PRINT '';
PRINT 'Total: 157 stored procedures';
PRINT '========================================';
GO

PRINT '';
PRINT '========================================';
PRINT 'KEY AUTOMATION FEATURES';
PRINT '========================================';
PRINT '';
PRINT '✓ sp_AddSalesOrder → Auto-creates OrderApproval';
PRINT '✓ sp_AddDeal → Auto-creates OrderApproval';
PRINT '✓ sp_AddSalesOrderItem → Auto-updates order total';
PRINT '✓ sp_AddDealItem → Auto-updates deal total';
PRINT '✓ sp_CreateRawMaterial → Auto-records initial purchase';
PRINT '✓ sp_UpdateRawMaterial → Auto-records purchase if qty increases';
PRINT '✓ sp_RestockRawMaterial → Auto-records purchase';
PRINT '✓ sp_ApproveOrderAndCreateProduction → Creates production + tailors';
PRINT '✓ sp_AutoPayPastSalaries → Auto-generates monthly salaries';
PRINT '✓ sp_DeductRawMaterialStock → Auto-deducts based on BOM';
PRINT '';
PRINT 'Plus 2 automated triggers:';
PRINT '✓ trg_CreateDeliveryOnSalesOrder';
PRINT '✓ trg_UpdateDeliveryOnSalesOrderStatusChange';
PRINT '========================================';
GO
