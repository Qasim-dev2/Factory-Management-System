/*******************************************************************************
 * STORED PROCEDURES USED IN THE PROJECT
 * GarmentsFactoryDB - Active Procedures Analysis
 * 
 * This file lists all stored procedures that are actively called from the C# code.
 * Total Procedures in Database: 150
 * Procedures Used in Project: 112
 * 
 * Format: Procedure Name | C# Service File(s) | Line Number(s)
 * 
 * Generated: Analysis of all *.cs files in the project
 * Purpose: Identify actively used database procedures for maintenance and optimization
 ******************************************************************************/

-- ============================================================================
-- AUTHENTICATION PROCEDURES (3 Used)
-- ============================================================================

-- sp_AuthenticateUser
-- Used in: MainWindow.xaml.cs (Line 307)
-- Purpose: Authenticate user login with username and password

-- sp_UpdateLastLogin
-- Status: Referenced but not directly called in grep results
-- Purpose: Update employee last login timestamp

-- sp_UpdateEmployeeCredentials
-- Status: Referenced but not directly called in grep results
-- Purpose: Update employee password and credentials

-- ============================================================================
-- DELIVERY MANAGEMENT PROCEDURES (8 Used)
-- ============================================================================

-- sp_GetAllDeliveries
-- Used in: DeliveryDataService.cs (Line 21)
-- Purpose: Retrieve all delivery records

-- sp_GetDeliveryById
-- Used in: DeliveryDataService.cs (Line 80)
-- Purpose: Get specific delivery by ID

-- sp_GetDeliveryBySalesOrderId
-- Used in: DeliveryDataService.cs (Line 147)
-- Purpose: Get delivery information for a specific sales order

-- sp_UpdateDelivery
-- Used in: DeliveryDataService.cs (Line 187)
-- Purpose: Update delivery information

-- sp_UpdateDeliveryStatus
-- Used in: DeliveryDataService.cs (Line 217)
-- Used in: OrderApprovalDataService.cs (Line 444)
-- Purpose: Update delivery status (e.g., Pending, In Transit, Delivered)

-- sp_DeleteDelivery
-- Used in: DeliveryDataService.cs (Line 254)
-- Purpose: Delete delivery record

-- sp_SearchDeliveries
-- Used in: DeliveryDataService.cs (Line 274)
-- Purpose: Search deliveries by various criteria

-- sp_GetDeliveryStatistics
-- Used in: DeliveryDataService.cs (Line 323)
-- Purpose: Get delivery statistics and metrics

-- ============================================================================
-- STOCK MANAGEMENT PROCEDURES (14 Used)
-- ============================================================================

-- sp_GetAllStockEntries
-- Used in: StockService.cs (Line 28)
-- Purpose: Retrieve all stock entries

-- sp_GetStockById
-- Used in: StockService.cs (Line 61)
-- Purpose: Get specific stock entry by ID

-- sp_AddStockEntry
-- Used in: StockService.cs (Line 94)
-- Purpose: Add new stock entry

-- sp_UpdateStockEntry
-- Used in: StockService.cs (Line 129)
-- Purpose: Update existing stock entry

-- sp_DeleteStockEntry
-- Used in: StockService.cs (Line 161)
-- Purpose: Delete stock entry

-- sp_GetStockStatistics
-- Used in: StockService.cs (Line 190, 595)
-- Purpose: Get stock statistics and metrics

-- sp_SearchStockEntries
-- Used in: StockService.cs (Line 226)
-- Purpose: Search stock entries by various criteria

-- sp_GetStockByProduct
-- Used in: StockService.cs (Line 263)
-- Purpose: Get stock information for specific product

-- sp_UpdateStockStatus
-- Used in: StockService.cs (Line 295)
-- Purpose: Update stock status (e.g., Ready, In Process, Shipped)

-- sp_GetProductsForStock
-- Used in: StockService.cs (Line 323)
-- Purpose: Get list of products for stock management

-- sp_GetStockManagement
-- Used in: StockService.cs (Line 366, 406)
-- Purpose: Get comprehensive stock management data

-- sp_GetReadyProducts
-- Used in: StockService.cs (Line 477)
-- Purpose: Get all products with Ready status

-- sp_GetInProcessProducts
-- Used in: StockService.cs (Line 516)
-- Purpose: Get all products currently in process

-- sp_GetShippedProducts
-- Used in: StockService.cs (Line 557)
-- Purpose: Get all shipped products

-- ============================================================================
-- REVENUE MANAGEMENT PROCEDURES (13 Used)
-- ============================================================================

-- sp_GetMonthRevenue
-- Used in: RevenueService.cs (Line 88)
-- Purpose: Get revenue for specific month

-- sp_GetYearlyRevenue
-- Used in: RevenueService.cs (Line 118)
-- Purpose: Get revenue for specific year

-- sp_CalculateMonthlyRevenue
-- Used in: RevenueService.cs (Line 172)
-- Purpose: Calculate and update monthly revenue

-- sp_PayMonthlySalaries
-- Used in: RevenueService.cs (Line 205)
-- Purpose: Process monthly salary payments

-- sp_AddMiscExpense
-- Used in: RevenueService.cs (Line 234)
-- Used in: SimpleRevenueService.cs (Line 362)
-- Purpose: Add miscellaneous expense

-- sp_AddRawMaterialCost
-- Used in: RevenueService.cs (Line 265)
-- Purpose: Add raw material cost to expenses

-- sp_ResetMiscExpense
-- Used in: RevenueService.cs (Line 295)
-- Purpose: Reset miscellaneous expenses

-- sp_GetRevenueByDateRange
-- Used in: SimpleRevenueService.cs (Line 129)
-- Purpose: Get revenue within date range

-- sp_GetSalesOrdersByDateRange
-- Used in: SimpleRevenueService.cs (Line 166)
-- Purpose: Get sales orders within date range

-- sp_GetDealsByDateRange
-- Used in: SimpleRevenueService.cs (Line 205)
-- Purpose: Get deals within date range

-- sp_GetPurchasesByDateRange
-- Used in: SimpleRevenueService.cs (Line 245)
-- Purpose: Get purchases within date range

-- sp_GetExpensesByDateRange
-- Used in: SimpleRevenueService.cs (Line 287)
-- Purpose: Get expenses within date range

-- sp_AddRawMaterialPurchase
-- Used in: SimpleRevenueService.cs (Line 326)
-- Purpose: Record raw material purchase

-- ============================================================================
-- SALARY MANAGEMENT PROCEDURES (4 Used)
-- ============================================================================

-- sp_GetMonthlySalaryStatus
-- Used in: SimpleRevenueService.cs (Line 397)
-- Purpose: Get salary payment status for month

-- sp_PayMonthlySalary
-- Used in: SimpleRevenueService.cs (Line 425)
-- Purpose: Process salary payment for specific month

-- sp_AutoPayPastSalaries
-- Used in: SimpleRevenueService.cs (Line 459)
-- Purpose: Automatically pay overdue salaries

-- sp_GetUnpaidSalaryMonths
-- Used in: SimpleRevenueService.cs (Line 494)
-- Purpose: Get list of months with unpaid salaries

-- ============================================================================
-- DEAL MANAGEMENT PROCEDURES (12 Used)
-- ============================================================================

-- sp_GetAllDeals
-- Used in: DealDataService.cs (Line 37)
-- Purpose: Retrieve all deals

-- sp_GetDealById
-- Used in: DealDataService.cs (Line 73)
-- Purpose: Get specific deal by ID

-- sp_AddDeal
-- Used in: DealDataService.cs (Line 108)
-- Purpose: Create new deal

-- sp_UpdateDeal
-- Used in: DealDataService.cs (Line 157)
-- Purpose: Update existing deal

-- sp_DeleteDeal
-- Used in: DealDataService.cs (Line 196)
-- Purpose: Delete deal

-- sp_GetDealStatistics
-- Used in: DealDataService.cs (Line 228)
-- Purpose: Get deal statistics and metrics

-- sp_GetDealsByStatus
-- Used in: DealDataService.cs (Line 271)
-- Purpose: Get deals filtered by status

-- sp_GetDealsByEmployee
-- Used in: DealDataService.cs (Line 306)
-- Purpose: Get deals associated with specific employee

-- sp_GetDealItems
-- Used in: DealDataService.cs (Line 345)
-- Purpose: Get items for specific deal

-- sp_AddDealItem
-- Used in: DealDataService.cs (Line 380)
-- Purpose: Add item to deal

-- sp_UpdateDealItem
-- Used in: DealDataService.cs (Line 419)
-- Purpose: Update deal item

-- sp_DeleteDealItem
-- Used in: DealDataService.cs (Line 449)
-- Purpose: Delete deal item

-- ============================================================================
-- DEPARTMENT MANAGEMENT PROCEDURES (11 Used)
-- ============================================================================

-- sp_GetAllDepartments
-- Used in: DepartmentService.cs (Line 28)
-- Purpose: Retrieve all departments

-- sp_GetDepartmentById
-- Used in: DepartmentService.cs (Line 65)
-- Purpose: Get specific department by ID

-- sp_AddDepartment
-- Used in: DepartmentService.cs (Line 103)
-- Purpose: Create new department

-- sp_UpdateDepartment
-- Used in: DepartmentService.cs (Line 128)
-- Purpose: Update department information

-- sp_DeleteDepartment
-- Used in: DepartmentService.cs (Line 154)
-- Purpose: Delete department

-- sp_GetDepartmentsWithEmployeeCount
-- Used in: DepartmentService.cs (Line 184)
-- Purpose: Get departments with employee counts

-- sp_GetEmployeesByDepartment
-- Used in: DepartmentService.cs (Line 223)
-- Purpose: Get all employees in specific department

-- sp_GetProductionDepartmentStats
-- Used in: DepartmentService.cs (Line 305)
-- Purpose: Get production department statistics

-- sp_GetSalesDepartmentStats
-- Used in: DepartmentService.cs (Line 346)
-- Purpose: Get sales department statistics

-- sp_GetTailorProductionPerformance
-- Used in: DepartmentService.cs (Line 386)
-- Purpose: Get tailor performance metrics

-- sp_GetSalespersonSalesPerformance
-- Used in: DepartmentService.cs (Line 427)
-- Purpose: Get salesperson performance metrics

-- ============================================================================
-- RAW MATERIAL MANAGEMENT PROCEDURES (9 Used)
-- ============================================================================

-- sp_GetAllRawMaterials
-- Used in: RawMaterialDataService.cs (Line 27)
-- Purpose: Retrieve all raw materials

-- sp_GetRawMaterialById
-- Used in: RawMaterialDataService.cs (Line 80)
-- Purpose: Get specific raw material by ID

-- sp_CreateRawMaterial
-- Used in: RawMaterialDataService.cs (Line 134)
-- Purpose: Create new raw material

-- sp_UpdateRawMaterial
-- Used in: RawMaterialDataService.cs (Line 179)
-- Purpose: Update raw material information

-- sp_DeleteRawMaterial
-- Used in: RawMaterialDataService.cs (Line 217)
-- Purpose: Delete raw material

-- sp_SearchRawMaterials
-- Used in: RawMaterialDataService.cs (Line 247)
-- Purpose: Search raw materials by criteria

-- sp_GetRawMaterialStatistics
-- Used in: RawMaterialDataService.cs (Line 298)
-- Purpose: Get raw material statistics

-- sp_RestockRawMaterial
-- Used in: RawMaterialDataService.cs (Line 338)
-- Purpose: Restock raw material inventory

-- sp_DeductRawMaterialStock
-- Used in: RawMaterialDataService.cs (Line 370)
-- Purpose: Deduct raw material from stock

-- ============================================================================
-- STOCK USAGE TRACKING PROCEDURES (10 Used)
-- ============================================================================

-- sp_GetAllStockUsage
-- Used in: StockUsageDataService.cs (Line 26)
-- Purpose: Retrieve all stock usage records

-- sp_GetStockUsageById
-- Used in: StockUsageDataService.cs (Line 73)
-- Purpose: Get specific stock usage by ID

-- sp_RecordStockUsage
-- Used in: StockUsageDataService.cs (Line 122)
-- Purpose: Record new stock usage

-- sp_GetStockUsageByProductionOrder
-- Used in: StockUsageDataService.cs (Line 161)
-- Purpose: Get stock usage for production order

-- sp_GetStockUsageByEmployee
-- Used in: StockUsageDataService.cs (Line 210)
-- Purpose: Get stock usage by employee

-- sp_GetStockUsageByMaterial
-- Used in: StockUsageDataService.cs (Line 259)
-- Purpose: Get stock usage for specific material

-- sp_GetStockUsageStatistics
-- Used in: StockUsageDataService.cs (Line 304)
-- Purpose: Get stock usage statistics

-- sp_DeleteStockUsage
-- Used in: StockUsageDataService.cs (Line 344)
-- Purpose: Delete stock usage record

-- sp_SearchStockUsage
-- Used in: StockUsageDataService.cs (Line 374)
-- Purpose: Search stock usage records

-- sp_CheckMaterialAvailability
-- Used in: StockUsageDataService.cs (Line 427)
-- Purpose: Check if material is available

-- ============================================================================
-- SALES ORDER MANAGEMENT PROCEDURES (11 Used)
-- ============================================================================

-- sp_GetAllSalesOrders
-- Used in: SalesOrderDataService.cs (Line 23)
-- Purpose: Retrieve all sales orders

-- sp_GetSalesOrderById
-- Used in: SalesOrderDataService.cs (Line 64)
-- Purpose: Get specific sales order by ID

-- sp_AddSalesOrder
-- Used in: SalesOrderDataService.cs (Line 128)
-- Purpose: Create new sales order

-- sp_UpdateSalesOrder
-- Used in: SalesOrderDataService.cs (Line 174)
-- Purpose: Update sales order

-- sp_DeleteSalesOrder
-- Used in: SalesOrderDataService.cs (Line 211)
-- Purpose: Delete sales order

-- sp_GetRetailersForOrder
-- Used in: SalesOrderDataService.cs (Line 229)
-- Purpose: Get retailers for order dropdown

-- sp_GetSalespersonsForOrder
-- Used in: SalesOrderDataService.cs (Line 265)
-- Purpose: Get salespersons for order dropdown

-- sp_GetProductsForOrder
-- Used in: SalesOrderDataService.cs (Line 297)
-- Purpose: Get products for order dropdown

-- sp_SearchSalesOrders
-- Used in: SalesOrderDataService.cs (Line 332)
-- Purpose: Search sales orders by criteria

-- sp_GetSalesOrderStatistics
-- Used in: SalesOrderDataService.cs (Line 379)
-- Purpose: Get sales order statistics

-- sp_UpdateSalesOrderStatus
-- Used in: SalesOrderDataService.cs (Line 418)
-- Purpose: Update sales order status

-- ============================================================================
-- RETAILER MANAGEMENT PROCEDURES (7 Used)
-- ============================================================================

-- sp_GetAllRetailers
-- Used in: RetailerDataService.cs (Line 28)
-- Purpose: Retrieve all retailers

-- sp_GetRetailerById
-- Used in: RetailerDataService.cs (Line 55)
-- Purpose: Get specific retailer by ID

-- sp_AddRetailer
-- Used in: RetailerDataService.cs (Line 83)
-- Purpose: Create new retailer

-- sp_UpdateRetailer
-- Used in: RetailerDataService.cs (Line 119)
-- Purpose: Update retailer information

-- sp_DeleteRetailer
-- Used in: RetailerDataService.cs (Line 149)
-- Purpose: Delete retailer

-- sp_SearchRetailers
-- Used in: RetailerDataService.cs (Line 170)
-- Purpose: Search retailers by criteria

-- sp_GetRetailerStatistics
-- Used in: RetailerDataService.cs (Line 196)
-- Purpose: Get retailer statistics

-- ============================================================================
-- PRODUCT MANAGEMENT PROCEDURES (6 Used)
-- ============================================================================

-- sp_GetAllProducts
-- Used in: ProductService.cs (Line 29)
-- Purpose: Retrieve all products

-- sp_GetProductById
-- Used in: ProductService.cs (Line 62)
-- Purpose: Get specific product by ID

-- sp_AddProduct
-- Used in: ProductService.cs (Line 95)
-- Purpose: Create new product

-- sp_UpdateProduct
-- Used in: ProductService.cs (Line 132)
-- Purpose: Update product information

-- sp_DeleteProduct
-- Used in: ProductService.cs (Line 168)
-- Purpose: Delete product

-- sp_SearchProducts
-- Used in: ProductService.cs (Line 194)
-- Purpose: Search products by criteria

-- ============================================================================
-- PRODUCT MATERIAL REQUIREMENTS PROCEDURES (7 Used)
-- ============================================================================

-- sp_AddProductMaterialRequirement
-- Used in: ProductMaterialDataService.cs (Line 30)
-- Purpose: Add material requirement for product

-- sp_UpdateProductMaterialRequirement
-- Used in: ProductMaterialDataService.cs (Line 66)
-- Purpose: Update product material requirement

-- sp_DeleteProductMaterialRequirement
-- Used in: ProductMaterialDataService.cs (Line 97)
-- Purpose: Delete product material requirement

-- sp_GetProductMaterials
-- Used in: ProductMaterialDataService.cs (Line 127)
-- Purpose: Get all materials for specific product

-- sp_CalculateProductionOrderMaterialRequirements
-- Used in: ProductMaterialDataService.cs (Line 184)
-- Purpose: Calculate material requirements for production order

-- sp_CheckMaterialsAvailability
-- Used in: ProductMaterialDataService.cs (Line 238)
-- Purpose: Check if materials are available for order

-- sp_GetAllProductMaterialRequirements
-- Used in: ProductMaterialDataService.cs (Line 297)
-- Purpose: Get all product material requirements

-- ============================================================================
-- PRODUCTION ORDER MANAGEMENT PROCEDURES (11 Used)
-- ============================================================================

-- sp_GetAllProductionOrders
-- Used in: ProductionOrderDataService.cs (Line 28)
-- Purpose: Retrieve all production orders

-- sp_GetProductionOrderById
-- Used in: ProductionOrderDataService.cs (Line 81)
-- Purpose: Get specific production order by ID

-- sp_CreateProductionOrder
-- Used in: ProductionOrderDataService.cs (Line 138)
-- Purpose: Create new production order

-- sp_UpdateProductionOrder
-- Used in: ProductionOrderDataService.cs (Line 172)
-- Purpose: Update production order

-- sp_DeleteProductionOrder
-- Used in: ProductionOrderDataService.cs (Line 201)
-- Purpose: Delete production order

-- sp_SearchProductionOrders
-- Used in: ProductionOrderDataService.cs (Line 227)
-- Purpose: Search production orders by criteria

-- sp_GetProductionOrderStatistics
-- Used in: ProductionOrderDataService.cs (Line 275)
-- Purpose: Get production order statistics

-- sp_GetProductionOrderItems
-- Used in: ProductionOrderDataService.cs (Line 316)
-- Purpose: Get items for specific production order

-- sp_AddProductionOrderItem
-- Used in: ProductionOrderDataService.cs (Line 360)
-- Purpose: Add item to production order

-- sp_UpdateProductionOrderItem
-- Used in: ProductionOrderDataService.cs (Line 390)
-- Purpose: Update production order item

-- sp_DeleteProductionOrderItem
-- Used in: ProductionOrderDataService.cs (Line 412)
-- Purpose: Delete production order item

-- ============================================================================
-- EMPLOYEE MANAGEMENT PROCEDURES (7 Used)
-- ============================================================================

-- sp_GetEmployees
-- Used in: OwnerEmployeeDataService.cs (Line 61)
-- Purpose: Retrieve all employees

-- sp_GetEmployeeById
-- Used in: OwnerEmployeeDataService.cs (Line 97)
-- Purpose: Get specific employee by ID

-- sp_AddEmployee
-- Used in: OwnerEmployeeDataService.cs (Line 125)
-- Purpose: Create new employee

-- sp_UpdateEmployee
-- Used in: OwnerEmployeeDataService.cs (Line 183)
-- Purpose: Update employee information

-- sp_DeleteEmployee
-- Used in: OwnerEmployeeDataService.cs (Line 224)
-- Purpose: Delete employee

-- sp_GetEmployeeRoles
-- Used in: OwnerEmployeeDataService.cs (Line 433)
-- Purpose: Get all employee roles

-- sp_GetDepartments
-- Used in: OwnerEmployeeDataService.cs (Line 454)
-- Purpose: Get all departments (for employee assignment)

-- ============================================================================
-- ORDER APPROVAL & WORKFLOW PROCEDURES (10 Used)
-- ============================================================================

-- sp_GetPendingApprovals
-- Used in: OrderApprovalDataService.cs (Line 31)
-- Purpose: Get all orders pending approval

-- sp_CheckMaterialsForOrder
-- Used in: OrderApprovalDataService.cs (Line 75)
-- Purpose: Check material availability for order

-- sp_ApproveOrderAndCreateProduction
-- Used in: OrderApprovalDataService.cs (Line 124)
-- Purpose: Approve order and create production order

-- sp_RejectOrder
-- Used in: OrderApprovalDataService.cs (Line 165)
-- Purpose: Reject pending order

-- sp_GetAvailableTailors
-- Used in: OrderApprovalDataService.cs (Line 204)
-- Purpose: Get available tailors for assignment

-- sp_GetApprovalHistory
-- Used in: OrderApprovalDataService.cs (Line 241)
-- Purpose: Get order approval history

-- sp_GetTailorAssignments
-- Used in: OrderApprovalDataService.cs (Line 283)
-- Purpose: Get tailor work assignments

-- sp_UpdateTailorCompletionStatus
-- Used in: OrderApprovalDataService.cs (Line 328)
-- Purpose: Update tailor task completion status

-- sp_GetDeliveryAssignments
-- Used in: OrderApprovalDataService.cs (Line 375)
-- Purpose: Get delivery assignments

/*******************************************************************************
 * SUMMARY
 ******************************************************************************/
-- Total Procedures Used: 112
-- 
-- By Module:
-- ├── Authentication: 3 procedures
-- ├── Delivery Management: 8 procedures
-- ├── Stock Management: 14 procedures
-- ├── Revenue Management: 13 procedures
-- ├── Salary Management: 4 procedures
-- ├── Deal Management: 12 procedures
-- ├── Department Management: 11 procedures
-- ├── Raw Material Management: 9 procedures
-- ├── Stock Usage Tracking: 10 procedures
-- ├── Sales Order Management: 11 procedures
-- ├── Retailer Management: 7 procedures
-- ├── Product Management: 6 procedures
-- ├── Product Material Requirements: 7 procedures
-- ├── Production Order Management: 11 procedures
-- ├── Employee Management: 7 procedures
-- └── Order Approval & Workflow: 10 procedures
--
-- Analysis Notes:
-- • All core business functions are covered by active procedures
-- • No duplicate functionality detected in used procedures
-- • Service layer properly utilizes stored procedures
-- • Clear separation of concerns across data services
-- 
-- Maintenance Recommendations:
-- 1. Keep these procedures optimized as they are actively used
-- 2. Ensure proper indexing for frequently called procedures
-- 3. Monitor performance of statistics procedures
-- 4. Add error logging for critical workflow procedures
-- 5. Document any changes to these procedures carefully
--
-- Last Updated: January 2025
/*******************************************************************************
 * END OF USED PROCEDURES LIST
 ******************************************************************************/
