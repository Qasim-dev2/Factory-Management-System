# Complete Stored Procedure to Frontend Mapping
**Generated:** December 17, 2025  
**Factory Management System - Database & Frontend Integration Reference**

---

## 📋 Table of Contents
1. [Sales Order Management](#sales-order-management)
2. [Deal Management](#deal-management)
3. [Retailer Management](#retailer-management)
4. [Employee Management](#employee-management)
5. [Product Management](#product-management)
6. [Production Order Management](#production-order-management)
7. [Raw Material Management](#raw-material-management)
8. [Stock Management](#stock-management)
9. [Delivery Management](#delivery-management)
10. [Order Approval System](#order-approval-system)
11. [Tailor Assignment System](#tailor-assignment-system)
12. [Department Management](#department-management)
13. [Revenue Management](#revenue-management)
14. [Stock Usage Tracking](#stock-usage-tracking)

---

## Sales Order Management

### sp_GetAllSalesOrders
- **Service:** SalesOrderDataService.cs → `GetAllSalesOrdersAsync()`
- **Frontend:** 
  - OwnerDashboard → Sales Orders → SalesOrdersManagementView
  - SalesManagerDashboard → Sales Orders → SalesOrdersManagementView
  - SalespersonDashboard → Sales Orders → SalesOrdersManagementView
- **Button/Action:** Page Load (Automatic)
- **Purpose:** Retrieves all sales orders with retailer and salesperson details for display in the orders grid

### sp_GetSalesOrderById
- **Service:** SalesOrderDataService.cs → `GetSalesOrderByIdAsync()`
- **Frontend:** SalesOrdersManagementView
- **Button/Action:** View Details button, Update Order selection
- **Purpose:** Fetches detailed information for a specific sales order including all related data

### sp_AddSalesOrder
- **Service:** SalesOrderDataService.cs → `AddSalesOrderAsync()`
- **Frontend:** SalesOrdersManagementView
- **Button/Action:** "Create Order" button in Add tab
- **Purpose:** Creates a new sales order record and returns the new order ID

### sp_AddSalesOrderItem
- **Service:** SalesOrderDataService.cs → `AddSalesOrderAsync()` (called within loop)
- **Frontend:** SalesOrdersManagementView
- **Button/Action:** "Create Order" button (automatically adds items)
- **Purpose:** Adds product line items to a sales order

### sp_UpdateSalesOrder
- **Service:** SalesOrderDataService.cs → `UpdateSalesOrderAsync()`
- **Frontend:** SalesOrdersManagementView
- **Button/Action:** "Update Order" button in Update tab
- **Purpose:** Updates existing sales order information including status and amounts

### sp_DeleteSalesOrder
- **Service:** SalesOrderDataService.cs → `DeleteSalesOrderAsync()`
- **Frontend:** SalesOrdersManagementView
- **Button/Action:** "Delete Order" button in Delete tab
- **Purpose:** Removes a sales order from the system (soft delete or hard delete)

### sp_GetRetailersForOrder
- **Service:** SalesOrderDataService.cs → `GetRetailersForOrderAsync()`
- **Frontend:** SalesOrdersManagementView
- **Button/Action:** Page Load (populates retailer dropdown)
- **Purpose:** Loads all active retailers for sales order creation/editing

### sp_GetSalespersonsForOrder
- **Service:** SalesOrderDataService.cs → `GetSalespersonsForOrderAsync()`
- **Frontend:** SalesOrdersManagementView
- **Button/Action:** Page Load (populates salesperson dropdown)
- **Purpose:** Loads all active salespeople for sales order assignment

### sp_GetProductsForOrder
- **Service:** SalesOrderDataService.cs → `GetProductsForOrderAsync()`
- **Frontend:** SalesOrdersManagementView
- **Button/Action:** Page Load (populates product dropdown)
- **Purpose:** Loads all available products for adding to sales orders

### sp_SearchSalesOrders
- **Service:** SalesOrderDataService.cs → `SearchSalesOrdersAsync()`
- **Frontend:** SalesOrdersManagementView
- **Button/Action:** Search box text change
- **Purpose:** Filters sales orders based on search criteria

### sp_GetSalesOrderStatistics
- **Service:** SalesOrderDataService.cs → `GetSalesOrderStatisticsAsync()`
- **Frontend:** SalesOrdersManagementView
- **Button/Action:** Page Load (Dashboard stats)
- **Purpose:** Provides summary statistics for sales orders (total, pending, completed, etc.)

### sp_UpdateSalesOrderStatus
- **Service:** SalesOrderDataService.cs → `UpdateSalesOrderStatusAsync()`
- **Frontend:** SalesOrdersManagementView
- **Button/Action:** Quick status change buttons
- **Purpose:** Updates only the status of a sales order

---

## Deal Management

### sp_GetAllDeals
- **Service:** DealDataService.cs → `GetAllDealsAsync()`
- **Frontend:** 
  - OwnerDashboard → Deals → DealsManagementView
  - SalesManagerDashboard → Deals → DealsManagementView
  - SalespersonDashboard → Deals → DealsManagementView
- **Button/Action:** Page Load (Automatic)
- **Purpose:** Retrieves all deals with client and employee information

### sp_GetDealById
- **Service:** DealDataService.cs → `GetDealByIdAsync()`
- **Frontend:** DealsManagementView
- **Button/Action:** View Details button
- **Purpose:** Fetches detailed information for a specific deal

### sp_AddDeal
- **Service:** DealDataService.cs → `AddDealAsync()`
- **Frontend:** DealsManagementView
- **Button/Action:** "Add Deal" button in Add tab
- **Purpose:** Creates a new deal record

### sp_UpdateDeal
- **Service:** DealDataService.cs → `UpdateDealAsync()`
- **Frontend:** DealsManagementView
- **Button/Action:** "Update Deal" button in Update tab
- **Purpose:** Updates existing deal information

### sp_DeleteDeal
- **Service:** DealDataService.cs → `DeleteDealAsync()`
- **Frontend:** DealsManagementView
- **Button/Action:** "Delete Deal" button in Delete tab
- **Purpose:** Removes a deal from the system

### sp_GetDealStatistics
- **Service:** DealDataService.cs → `GetDealStatisticsAsync()`
- **Frontend:** DealsManagementView
- **Button/Action:** Page Load (Dashboard stats)
- **Purpose:** Provides summary statistics for deals

### sp_GetDealsByStatus
- **Service:** DealDataService.cs → `GetDealsByStatusAsync()`
- **Frontend:** DealsManagementView
- **Button/Action:** Status filter dropdown
- **Purpose:** Filters deals by their current status

### sp_GetDealsByEmployee
- **Service:** DealDataService.cs → `GetDealsByEmployeeAsync()`
- **Frontend:** DealsManagementView
- **Button/Action:** Employee filter
- **Purpose:** Filters deals by assigned employee

### sp_GetDealItems
- **Service:** DealDataService.cs → `GetDealItemsAsync()`
- **Frontend:** DealsManagementView
- **Button/Action:** View Deal Items, Update Deal (loads items)
- **Purpose:** Retrieves all product items associated with a deal

### sp_AddDealItem
- **Service:** DealDataService.cs → `AddDealItemAsync()`
- **Frontend:** DealsManagementView
- **Button/Action:** "Add Deal" button (automatically adds items)
- **Purpose:** Adds product line items to a deal

### sp_UpdateDealItem
- **Service:** DealDataService.cs → `UpdateDealItemAsync()`
- **Frontend:** DealsManagementView
- **Button/Action:** Update deal items during deal update
- **Purpose:** Updates existing deal items

### sp_DeleteDealItem
- **Service:** DealDataService.cs → `DeleteDealItemAsync()`
- **Frontend:** DealsManagementView
- **Button/Action:** Remove item from deal
- **Purpose:** Removes a product item from a deal

---

## Retailer Management

### sp_GetAllRetailers
- **Service:** RetailerDataService.cs → `GetAllRetailersAsync()`
- **Frontend:** 
  - OwnerDashboard → Retailers → RetailersManagementView
- **Button/Action:** Page Load (Automatic)
- **Purpose:** Retrieves all retailers for display in the retailers grid

### sp_GetRetailerById
- **Service:** RetailerDataService.cs → `GetRetailerByIdAsync()`
- **Frontend:** RetailersManagementView
- **Button/Action:** View Details button
- **Purpose:** Fetches detailed information for a specific retailer

### sp_AddRetailer
- **Service:** RetailerDataService.cs → `AddRetailerAsync()`
- **Frontend:** RetailersManagementView, AddRetailerDialog
- **Button/Action:** "Add Retailer" button in Add tab
- **Purpose:** Creates a new retailer record

### sp_UpdateRetailer
- **Service:** RetailerDataService.cs → `UpdateRetailerAsync()`
- **Frontend:** RetailersManagementView
- **Button/Action:** "Update Retailer" button in Update tab
- **Purpose:** Updates existing retailer information

### sp_DeleteRetailer
- **Service:** RetailerDataService.cs → `DeleteRetailerAsync()`
- **Frontend:** RetailersManagementView
- **Button/Action:** "Delete Retailer" button in Delete tab
- **Purpose:** Removes a retailer from the system

### sp_SearchRetailers
- **Service:** RetailerDataService.cs → `SearchRetailersAsync()`
- **Frontend:** RetailersManagementView
- **Button/Action:** Search box text change
- **Purpose:** Filters retailers based on search criteria

### sp_GetRetailerStatistics
- **Service:** RetailerDataService.cs → `GetRetailerStatisticsAsync()`
- **Frontend:** RetailersManagementView
- **Button/Action:** Page Load (Dashboard stats)
- **Purpose:** Provides summary statistics for retailers (total, active, inactive, cities covered)

---

## Employee Management

### sp_GetEmployees
- **Service:** OwnerEmployeeDataService.cs → `GetEmployeesAsync()`
- **Frontend:** OwnerDashboard → Employees → EmployeeManagementView
- **Button/Action:** Page Load, Browse tab
- **Purpose:** Retrieves paginated list of all employees

### sp_GetEmployeeById
- **Service:** OwnerEmployeeDataService.cs → `GetEmployeeByIdAsync()`
- **Frontend:** EmployeeManagementView
- **Button/Action:** View Details button, Update selection, Delete selection
- **Purpose:** Fetches detailed information for a specific employee

### sp_AddEmployee
- **Service:** OwnerEmployeeDataService.cs → `AddEmployeeAsync()`
- **Frontend:** EmployeeManagementView
- **Button/Action:** "Add Employee" button in Add tab
- **Purpose:** Creates a new employee record

### sp_UpdateEmployee
- **Service:** OwnerEmployeeDataService.cs → `UpdateEmployeeAsync()`
- **Frontend:** EmployeeManagementView
- **Button/Action:** "Update Employee" button in Update tab
- **Purpose:** Updates existing employee information

### sp_DeleteEmployee
- **Service:** OwnerEmployeeDataService.cs → `DeleteEmployeeAsync()`
- **Frontend:** EmployeeManagementView
- **Button/Action:** "Delete Employee" button in Delete tab
- **Purpose:** Soft deletes an employee (sets IsActive = 0)

### sp_GetEmployeeRoles
- **Service:** OwnerEmployeeDataService.cs → `GetEmployeeRolesAsync()`
- **Frontend:** EmployeeManagementView
- **Button/Action:** Page Load (populates role dropdown)
- **Purpose:** Loads all available employee roles for assignment

### sp_GetDepartments
- **Service:** OwnerEmployeeDataService.cs → `GetDepartmentsAsync()`
- **Frontend:** EmployeeManagementView
- **Button/Action:** Page Load (populates department dropdown)
- **Purpose:** Loads all departments for employee assignment

---

## Product Management

### sp_GetAllProducts
- **Service:** ProductService.cs → `GetAllProductsAsync()`
- **Frontend:** 
  - OwnerDashboard → Products → ProductManagementView
  - SalesManagerDashboard → Products → ProductManagementView
  - ProductionManagerDashboard → Products → ProductManagementView
- **Button/Action:** Page Load (Automatic)
- **Purpose:** Retrieves all products for display in the products grid

### sp_GetProductById
- **Service:** ProductService.cs → `GetProductByIdAsync()`
- **Frontend:** ProductManagementView
- **Button/Action:** View Details button
- **Purpose:** Fetches detailed information for a specific product

### sp_AddProduct
- **Service:** ProductService.cs → `AddProductAsync()`
- **Frontend:** ProductManagementView, AddProductDialog
- **Button/Action:** "Add Product" button
- **Purpose:** Creates a new product record

### sp_UpdateProduct
- **Service:** ProductService.cs → `UpdateProductAsync()`
- **Frontend:** ProductManagementView
- **Button/Action:** "Update Product" button
- **Purpose:** Updates existing product information

### sp_DeleteProduct
- **Service:** ProductService.cs → `DeleteProductAsync()`
- **Frontend:** ProductManagementView
- **Button/Action:** "Delete Product" button
- **Purpose:** Removes a product from the system

### sp_SearchProducts
- **Service:** ProductService.cs → `SearchProductsAsync()`
- **Frontend:** ProductManagementView
- **Button/Action:** Search box text change
- **Purpose:** Filters products based on search criteria

---

## Production Order Management

### sp_GetAllProductionOrders
- **Service:** ProductionOrderDataService.cs → `GetAllProductionOrdersAsync()`
- **Frontend:** 
  - OwnerDashboard → Production Orders → ProductionOrderManagementView
- **Button/Action:** Page Load (Automatic)
- **Purpose:** Retrieves all production orders with product and employee details

### sp_GetProductionOrderById
- **Service:** ProductionOrderDataService.cs → `GetProductionOrderByIdAsync()`
- **Frontend:** ProductionOrderManagementView
- **Button/Action:** View Details button
- **Purpose:** Fetches detailed information for a specific production order

### sp_CreateProductionOrder
- **Service:** ProductionOrderDataService.cs → `CreateProductionOrderAsync()`
- **Frontend:** ProductionOrderManagementView
- **Button/Action:** "Create Production Order" button
- **Purpose:** Creates a new production order record

### sp_UpdateProductionOrder
- **Service:** ProductionOrderDataService.cs → `UpdateProductionOrderAsync()`
- **Frontend:** ProductionOrderManagementView
- **Button/Action:** "Update Order" button
- **Purpose:** Updates existing production order information

### sp_DeleteProductionOrder
- **Service:** ProductionOrderDataService.cs → `DeleteProductionOrderAsync()`
- **Frontend:** ProductionOrderManagementView
- **Button/Action:** "Delete Order" button
- **Purpose:** Removes a production order from the system

### sp_SearchProductionOrders
- **Service:** ProductionOrderDataService.cs → `SearchProductionOrdersAsync()`
- **Frontend:** ProductionOrderManagementView
- **Button/Action:** Search/Filter controls
- **Purpose:** Filters production orders based on search criteria

### sp_GetProductionOrderStatistics
- **Service:** ProductionOrderDataService.cs → `GetProductionOrderStatisticsAsync()`
- **Frontend:** ProductionOrderManagementView
- **Button/Action:** Page Load (Dashboard stats)
- **Purpose:** Provides summary statistics for production orders

### sp_GetProductionOrderItems
- **Service:** ProductionOrderDataService.cs → `GetProductionOrderItemsAsync()`
- **Frontend:** ProductionOrderManagementView
- **Button/Action:** View Order Items
- **Purpose:** Retrieves all items associated with a production order

### sp_AddProductionOrderItem
- **Service:** ProductionOrderDataService.cs → `AddProductionOrderItemAsync()`
- **Frontend:** ProductionOrderManagementView
- **Button/Action:** Add item to production order
- **Purpose:** Adds an item to a production order

### sp_UpdateProductionOrderItem
- **Service:** ProductionOrderDataService.cs → `UpdateProductionOrderItemAsync()`
- **Frontend:** ProductionOrderManagementView
- **Button/Action:** Update production order item
- **Purpose:** Updates an existing production order item

### sp_DeleteProductionOrderItem
- **Service:** ProductionOrderDataService.cs → `DeleteProductionOrderItemAsync()`
- **Frontend:** ProductionOrderManagementView
- **Button/Action:** Remove item from production order
- **Purpose:** Removes an item from a production order

---

## Raw Material Management

### sp_GetAllRawMaterials
- **Service:** RawMaterialDataService.cs → `GetAllRawMaterialsAsync()`
- **Frontend:** 
  - OwnerDashboard → Raw Materials → RawMaterialManagementView
  - ProductionManagerDashboard → Raw Materials → RawMaterialManagementView
- **Button/Action:** Page Load (Automatic)
- **Purpose:** Retrieves all raw materials with stock levels

### sp_GetRawMaterialById
- **Service:** RawMaterialDataService.cs → `GetRawMaterialByIdAsync()`
- **Frontend:** RawMaterialManagementView
- **Button/Action:** View Details button
- **Purpose:** Fetches detailed information for a specific raw material

### sp_CreateRawMaterial
- **Service:** RawMaterialDataService.cs → `CreateRawMaterialAsync()`
- **Frontend:** RawMaterialManagementView
- **Button/Action:** "Add Material" button
- **Purpose:** Creates a new raw material record

### sp_UpdateRawMaterial
- **Service:** RawMaterialDataService.cs → `UpdateRawMaterialAsync()`
- **Frontend:** RawMaterialManagementView
- **Button/Action:** "Update Material" button
- **Purpose:** Updates existing raw material information

### sp_DeleteRawMaterial
- **Service:** RawMaterialDataService.cs → `DeleteRawMaterialAsync()`
- **Frontend:** RawMaterialManagementView
- **Button/Action:** "Delete Material" button
- **Purpose:** Removes a raw material from the system

### sp_SearchRawMaterials
- **Service:** RawMaterialDataService.cs → `SearchRawMaterialsAsync()`
- **Frontend:** RawMaterialManagementView
- **Button/Action:** Search box text change
- **Purpose:** Filters raw materials based on search criteria

### sp_GetRawMaterialStatistics
- **Service:** RawMaterialDataService.cs → `GetRawMaterialStatisticsAsync()`
- **Frontend:** RawMaterialManagementView
- **Button/Action:** Page Load (Dashboard stats)
- **Purpose:** Provides summary statistics for raw materials

### sp_RestockRawMaterial
- **Service:** RawMaterialDataService.cs → `RestockRawMaterialAsync()`
- **Frontend:** RawMaterialManagementView
- **Button/Action:** "Restock" button
- **Purpose:** Increases stock quantity for a raw material

### sp_DeductRawMaterialStock
- **Service:** RawMaterialDataService.cs → `DeductRawMaterialStockAsync()`
- **Frontend:** RawMaterialManagementView, ProductionOrderManagementView
- **Button/Action:** Automatic when production order created
- **Purpose:** Decreases stock quantity when materials are used in production

---

## Stock Management

### sp_GetAllStockEntries
- **Service:** StockService.cs → `GetAllStockEntriesAsync()`
- **Frontend:** OwnerDashboard → Stock → StockManagementView
- **Button/Action:** Page Load (Automatic)
- **Purpose:** Retrieves all stock entries

### sp_GetStockById
- **Service:** StockService.cs → `GetStockByIdAsync()`
- **Frontend:** StockManagementView
- **Button/Action:** View Details button
- **Purpose:** Fetches detailed information for a specific stock entry

### sp_AddStockEntry
- **Service:** StockService.cs → `AddStockEntryAsync()`
- **Frontend:** StockManagementView, AddStockEntryDialog
- **Button/Action:** "Add Stock Entry" button
- **Purpose:** Creates a new stock entry record

### sp_UpdateStockEntry
- **Service:** StockService.cs → `UpdateStockEntryAsync()`
- **Frontend:** StockManagementView
- **Button/Action:** "Update Entry" button
- **Purpose:** Updates existing stock entry information

### sp_DeleteStockEntry
- **Service:** StockService.cs → `DeleteStockEntryAsync()`
- **Frontend:** StockManagementView
- **Button/Action:** "Delete Entry" button
- **Purpose:** Removes a stock entry from the system

### sp_GetStockStatistics
- **Service:** StockService.cs → `GetStockStatisticsAsync()`
- **Frontend:** StockManagementView
- **Button/Action:** Page Load (Dashboard stats)
- **Purpose:** Provides summary statistics for stock

### sp_SearchStockEntries
- **Service:** StockService.cs → `SearchStockEntriesAsync()`
- **Frontend:** StockManagementView
- **Button/Action:** Search box text change
- **Purpose:** Filters stock entries based on search criteria

### sp_GetStockByProduct
- **Service:** StockService.cs → `GetStockByProductAsync()`
- **Frontend:** StockManagementView
- **Button/Action:** Filter by product
- **Purpose:** Gets stock entries for a specific product

### sp_UpdateStockStatus
- **Service:** StockService.cs → `UpdateStockStatusAsync()`
- **Frontend:** StockManagementView
- **Button/Action:** Status change button
- **Purpose:** Updates the status of a stock entry

### sp_GetProductsForStock
- **Service:** StockService.cs → `GetProductsForStockAsync()`
- **Frontend:** StockManagementView
- **Button/Action:** Page Load (populates product dropdown)
- **Purpose:** Loads all products for stock entry creation

### sp_GetStockManagement
- **Service:** StockService.cs → `GetStockManagementAsync()`
- **Frontend:** StockManagementView
- **Button/Action:** Page Load (Main view)
- **Purpose:** Retrieves comprehensive stock management data with status breakdown

### sp_GetReadyProducts
- **Service:** StockService.cs → `GetReadyProductsAsync()`
- **Frontend:** StockManagementView
- **Button/Action:** "Ready" tab click
- **Purpose:** Gets all products with Ready status

### sp_GetInProcessProducts
- **Service:** StockService.cs → `GetInProcessProductsAsync()`
- **Frontend:** StockManagementView
- **Button/Action:** "In Process" tab click
- **Purpose:** Gets all products currently in production

### sp_GetShippedProducts
- **Service:** StockService.cs → `GetShippedProductsAsync()`
- **Frontend:** StockManagementView
- **Button/Action:** "Shipped" tab click
- **Purpose:** Gets all products that have been shipped

---

## Delivery Management

### sp_GetAllDeliveries
- **Service:** DeliveryDataService.cs → `GetAllDeliveriesAsync()`
- **Frontend:** 
  - OwnerDashboard → Deliveries → DeliveryManagementView
  - DeliveryPersonDashboard → Deliveries → DeliveryManagementView
- **Button/Action:** Page Load (Automatic)
- **Purpose:** Retrieves all deliveries with order and customer information

### sp_GetDeliveryById
- **Service:** DeliveryDataService.cs → `GetDeliveryByIdAsync()`
- **Frontend:** DeliveryManagementView
- **Button/Action:** View Details button
- **Purpose:** Fetches detailed information for a specific delivery

### sp_GetDeliveryBySalesOrderId
- **Service:** DeliveryDataService.cs → `GetDeliveryBySalesOrderIdAsync()`
- **Frontend:** DeliveryManagementView
- **Button/Action:** View delivery for order
- **Purpose:** Gets delivery information for a specific sales order

### sp_UpdateDelivery
- **Service:** DeliveryDataService.cs → `UpdateDeliveryAsync()`
- **Frontend:** DeliveryManagementView
- **Button/Action:** "Update Delivery" button
- **Purpose:** Updates existing delivery information

### sp_UpdateDeliveryStatus
- **Service:** DeliveryDataService.cs → `UpdateDeliveryStatusAsync()`
- **Frontend:** DeliveryManagementView
- **Button/Action:** Quick status change buttons (Mark as Delivered, etc.)
- **Purpose:** Updates only the status of a delivery

### sp_DeleteDelivery
- **Service:** DeliveryDataService.cs → `DeleteDeliveryAsync()`
- **Frontend:** DeliveryManagementView
- **Button/Action:** "Delete Delivery" button
- **Purpose:** Removes a delivery from the system

### sp_SearchDeliveries
- **Service:** DeliveryDataService.cs → `SearchDeliveriesAsync()`
- **Frontend:** DeliveryManagementView
- **Button/Action:** Search/Filter controls
- **Purpose:** Filters deliveries based on search criteria

### sp_GetDeliveryStatistics
- **Service:** DeliveryDataService.cs → `GetDeliveryStatisticsAsync()`
- **Frontend:** DeliveryManagementView, DeliveryPersonDashboard
- **Button/Action:** Page Load (Dashboard stats)
- **Purpose:** Provides summary statistics for deliveries (total, pending, in-transit, delivered, failed)

---

## Order Approval System

### sp_GetPendingApprovals
- **Service:** OrderApprovalDataService.cs → `GetPendingApprovalsAsync()`
- **Frontend:** 
  - OwnerDashboard → Order Approval → OrderApprovalViewControl
  - ProductionManagerDashboard → Order Approval → OrderApprovalViewControl
- **Button/Action:** Page Load (Automatic)
- **Purpose:** Retrieves all orders pending approval from owner/manager

### sp_CheckMaterialsForOrder
- **Service:** OrderApprovalDataService.cs → `CheckMaterialsForOrderAsync()`
- **Frontend:** OrderApprovalViewControl
- **Button/Action:** "Check Materials" button on pending order
- **Purpose:** Validates if sufficient raw materials are available for order production

### sp_ApproveOrderAndCreateProduction
- **Service:** OrderApprovalDataService.cs → `ApproveOrderAsync()`
- **Frontend:** OrderApprovalViewControl
- **Button/Action:** "Approve" button after selecting tailors (TailorSelectionDialog)
- **Purpose:** Approves the order, creates production order, assigns tailors, and deducts materials

### sp_RejectOrder
- **Service:** OrderApprovalDataService.cs → `RejectOrderAsync()`
- **Frontend:** OrderApprovalViewControl
- **Button/Action:** "Reject" button (RejectReasonDialog)
- **Purpose:** Rejects the order with a reason

### sp_GetAvailableTailors
- **Service:** OrderApprovalDataService.cs → `GetAvailableTailorsAsync()`
- **Frontend:** TailorSelectionDialog
- **Button/Action:** Approval flow - Select Tailors step
- **Purpose:** Gets list of available tailors for production order assignment

### sp_GetApprovalHistory
- **Service:** OrderApprovalDataService.cs → `GetApprovalHistoryAsync()`
- **Frontend:** OrderApprovalViewControl
- **Button/Action:** "View History" tab
- **Purpose:** Shows historical record of all approval decisions

---

## Tailor Assignment System

### sp_GetTailorAssignments
- **Service:** OrderApprovalDataService.cs → `GetTailorAssignmentsAsync()`
- **Frontend:** 
  - TailorDashboard → My Tasks → TailorTasksViewControl
  - OwnerDashboard → Tailor Tasks → TailorTasksViewControl
- **Button/Action:** Page Load, Tailor selection dropdown
- **Purpose:** Gets all production orders assigned to a specific tailor

### sp_UpdateTailorCompletionStatus
- **Service:** OrderApprovalDataService.cs → `UpdateTailorStatusAsync()`
- **Frontend:** TailorTasksViewControl
- **Button/Action:** "Mark as Complete" button, "Mark as Incomplete" button
- **Purpose:** Updates tailor's completion status for assigned production order

### sp_GetDeliveryAssignments
- **Service:** OrderApprovalDataService.cs → `GetDeliveryAssignmentsAsync()`
- **Frontend:** DeliveryManagementView
- **Button/Action:** Page Load (Delivery view)
- **Purpose:** Gets all deliveries assigned to delivery persons

---

## Department Management

### sp_GetAllDepartments
- **Service:** DepartmentService.cs → `GetAllDepartmentsAsync()`
- **Frontend:** OwnerDashboard → Departments → DepartmentAnalyticsModule
- **Button/Action:** Page Load (Automatic)
- **Purpose:** Retrieves all departments for management and analytics

### sp_GetDepartmentById
- **Service:** DepartmentService.cs → `GetDepartmentByIdAsync()`
- **Frontend:** DepartmentAnalyticsModule
- **Button/Action:** View Department Details
- **Purpose:** Fetches detailed information for a specific department

### sp_AddDepartment
- **Service:** DepartmentService.cs → `AddDepartmentAsync()`
- **Frontend:** DepartmentAnalyticsModule
- **Button/Action:** "Add Department" button
- **Purpose:** Creates a new department record

### sp_UpdateDepartment
- **Service:** DepartmentService.cs → `UpdateDepartmentAsync()`
- **Frontend:** DepartmentAnalyticsModule
- **Button/Action:** "Update Department" button
- **Purpose:** Updates existing department information

### sp_DeleteDepartment
- **Service:** DepartmentService.cs → `DeleteDepartmentAsync()`
- **Frontend:** DepartmentAnalyticsModule
- **Button/Action:** "Delete Department" button
- **Purpose:** Removes a department from the system

### sp_GetDepartmentsWithEmployeeCount
- **Service:** DepartmentService.cs → `GetDepartmentsWithEmployeeCountAsync()`
- **Frontend:** DepartmentAnalyticsModule
- **Button/Action:** Page Load (Main view)
- **Purpose:** Gets departments with their employee counts

### sp_GetEmployeesByDepartment
- **Service:** DepartmentService.cs → `GetEmployeesByDepartmentAsync()`
- **Frontend:** DepartmentAnalyticsModule
- **Button/Action:** View employees in department
- **Purpose:** Lists all employees in a specific department

### sp_GetProductionDepartmentStats
- **Service:** DepartmentService.cs → `GetProductionDepartmentStatsAsync()`
- **Frontend:** DepartmentAnalyticsModule
- **Button/Action:** Production Analytics tab
- **Purpose:** Provides production department performance statistics

### sp_GetSalesDepartmentStats
- **Service:** DepartmentService.cs → `GetSalesDepartmentStatsAsync()`
- **Frontend:** DepartmentAnalyticsModule
- **Button/Action:** Sales Analytics tab
- **Purpose:** Provides sales department performance statistics

### sp_GetTailorProductionPerformance
- **Service:** DepartmentService.cs → `GetTailorProductionPerformanceAsync()`
- **Frontend:** DepartmentAnalyticsModule
- **Button/Action:** Tailor Performance view
- **Purpose:** Shows individual tailor production performance metrics

### sp_GetSalespersonSalesPerformance
- **Service:** DepartmentService.cs → `GetSalespersonSalesPerformanceAsync()`
- **Frontend:** DepartmentAnalyticsModule
- **Button/Action:** Salesperson Performance view
- **Purpose:** Shows individual salesperson sales performance metrics

---

## Revenue Management

### sp_GetRevenueByDateRange
- **Service:** SimpleRevenueService.cs → `GetRevenueSummaryAsync()`
- **Frontend:** OwnerDashboard → Revenue → SimpleRevenueView
- **Button/Action:** Date range selection, "Calculate" button
- **Purpose:** Calculates total revenue between specified dates

### sp_GetSalesOrdersByDateRange
- **Service:** SimpleRevenueService.cs → `GetSalesOrdersAsync()`
- **Frontend:** SimpleRevenueView
- **Button/Action:** "Sales Orders" tab, date range filter
- **Purpose:** Gets all sales orders within date range for revenue calculation

### sp_GetDealsByDateRange
- **Service:** SimpleRevenueService.cs → `GetDealsAsync()`
- **Frontend:** SimpleRevenueView
- **Button/Action:** "Deals" tab, date range filter
- **Purpose:** Gets all deals within date range for revenue calculation

### sp_GetPurchasesByDateRange
- **Service:** SimpleRevenueService.cs → `GetPurchasesAsync()`
- **Frontend:** SimpleRevenueView
- **Button/Action:** "Purchases" tab, date range filter
- **Purpose:** Gets all raw material purchases within date range for expense tracking

### sp_GetExpensesByDateRange
- **Service:** SimpleRevenueService.cs → `GetExpensesAsync()`
- **Frontend:** SimpleRevenueView
- **Button/Action:** "Expenses" tab, date range filter
- **Purpose:** Gets all miscellaneous expenses within date range

### sp_AddRawMaterialPurchase
- **Service:** SimpleRevenueService.cs → `AddPurchaseAsync()`
- **Frontend:** SimpleRevenueView
- **Button/Action:** "Add Purchase" button in Purchases tab
- **Purpose:** Records a new raw material purchase expense

### sp_AddMiscExpense
- **Service:** SimpleRevenueService.cs → `AddExpenseAsync()`
- **Frontend:** SimpleRevenueView, AddExpenseDialog
- **Button/Action:** "Add Expense" button in Expenses tab
- **Purpose:** Records a miscellaneous expense

### sp_GetMonthlySalaryStatus
- **Service:** SimpleRevenueService.cs → `GetSalaryStatusAsync()`
- **Frontend:** SimpleRevenueView
- **Button/Action:** Page Load (Salary section)
- **Purpose:** Checks if salaries have been paid for a specific month

### sp_PayMonthlySalary
- **Service:** SimpleRevenueService.cs → `PayMonthlySalaryAsync()`
- **Frontend:** SimpleRevenueView
- **Button/Action:** "Pay Salaries" button
- **Purpose:** Records monthly salary payment for all employees

### sp_AutoPayPastSalaries
- **Service:** SimpleRevenueService.cs → `AutoPayPastSalariesAsync()`
- **Frontend:** SimpleRevenueView
- **Button/Action:** "Auto Pay Past Salaries" button
- **Purpose:** Automatically pays all unpaid salaries for past months

### sp_GetUnpaidSalaryMonths
- **Service:** SimpleRevenueService.cs → `GetUnpaidSalaryMonthsAsync()`
- **Frontend:** SimpleRevenueView
- **Button/Action:** View unpaid months
- **Purpose:** Lists all months with unpaid salaries

### sp_GetMonthRevenue (Legacy)
- **Service:** RevenueService.cs → `GetMonthRevenueAsync()`
- **Frontend:** RevenueView (Old system)
- **Button/Action:** Month selection
- **Purpose:** Gets revenue for a specific month (older version)

### sp_GetYearlyRevenue (Legacy)
- **Service:** RevenueService.cs → `GetYearlyRevenueAsync()`
- **Frontend:** RevenueView (Old system)
- **Button/Action:** Year selection
- **Purpose:** Gets yearly revenue breakdown (older version)

### sp_CalculateMonthlyRevenue (Legacy)
- **Service:** RevenueService.cs → `CalculateMonthlyRevenueAsync()`
- **Frontend:** RevenueView (Old system)
- **Button/Action:** "Calculate Revenue" button
- **Purpose:** Calculates and stores monthly revenue (older version)

### sp_PayMonthlySalaries (Legacy - plural)
- **Service:** RevenueService.cs → `PayMonthlySalariesAsync()`
- **Frontend:** RevenueView (Old system)
- **Button/Action:** "Pay Salaries" button
- **Purpose:** Pays salaries for month (older version with 's')

### sp_ResetMiscExpense (Legacy)
- **Service:** RevenueService.cs → `ResetMiscExpenseAsync()`
- **Frontend:** RevenueView (Old system)
- **Button/Action:** "Reset Expenses" button
- **Purpose:** Resets miscellaneous expenses (older version)

---

## Stock Usage Tracking

### sp_GetAllStockUsage
- **Service:** StockUsageDataService.cs → `GetAllStockUsageAsync()`
- **Frontend:** Not directly linked to UI (backend tracking)
- **Button/Action:** N/A
- **Purpose:** Retrieves all stock usage records for auditing

### sp_GetStockUsageById
- **Service:** StockUsageDataService.cs → `GetStockUsageByIdAsync()`
- **Frontend:** Not directly linked to UI
- **Button/Action:** N/A
- **Purpose:** Gets specific stock usage record details

### sp_RecordStockUsage
- **Service:** StockUsageDataService.cs → `RecordStockUsageAsync()`
- **Frontend:** Automatic during production
- **Button/Action:** Production order creation (automatic)
- **Purpose:** Records material usage when production order is created

### sp_GetStockUsageByProductionOrder
- **Service:** StockUsageDataService.cs → `GetStockUsageByProductionOrderAsync()`
- **Frontend:** ProductionOrderManagementView
- **Button/Action:** View materials used for order
- **Purpose:** Shows all materials used in a specific production order

### sp_GetStockUsageByEmployee
- **Service:** StockUsageDataService.cs → `GetStockUsageByEmployeeAsync()`
- **Frontend:** Not directly linked to UI
- **Button/Action:** N/A
- **Purpose:** Tracks material usage by specific employee

### sp_GetStockUsageByMaterial
- **Service:** StockUsageDataService.cs → `GetStockUsageByMaterialAsync()`
- **Frontend:** RawMaterialManagementView
- **Button/Action:** View usage history for material
- **Purpose:** Shows usage history for a specific raw material

### sp_GetStockUsageStatistics
- **Service:** StockUsageDataService.cs → `GetStockUsageStatisticsAsync()`
- **Frontend:** Not directly linked to UI
- **Button/Action:** N/A
- **Purpose:** Provides statistics on material usage patterns

### sp_DeleteStockUsage
- **Service:** StockUsageDataService.cs → `DeleteStockUsageAsync()`
- **Frontend:** Not directly linked to UI
- **Button/Action:** N/A
- **Purpose:** Removes a stock usage record (admin function)

### sp_SearchStockUsage
- **Service:** StockUsageDataService.cs → `SearchStockUsageAsync()`
- **Frontend:** Not directly linked to UI
- **Button/Action:** N/A
- **Purpose:** Searches stock usage records

### sp_CheckMaterialAvailability
- **Service:** StockUsageDataService.cs → `CheckMaterialAvailabilityAsync()`
- **Frontend:** MaterialCheckDialog, OrderApprovalViewControl
- **Button/Action:** "Check Materials" button
- **Purpose:** Verifies if sufficient materials are available for production

---

## Product Material Requirements

### sp_AddProductMaterialRequirement
- **Service:** ProductMaterialDataService.cs → `AddProductMaterialRequirementAsync()`
- **Frontend:** ProductManagementView
- **Button/Action:** Add material requirement when creating product
- **Purpose:** Links raw materials to products with required quantities

### sp_UpdateProductMaterialRequirement
- **Service:** ProductMaterialDataService.cs → `UpdateProductMaterialRequirementAsync()`
- **Frontend:** ProductManagementView
- **Button/Action:** Update material requirements
- **Purpose:** Updates material quantity requirements for a product

### sp_DeleteProductMaterialRequirement
- **Service:** ProductMaterialDataService.cs → `DeleteProductMaterialRequirementAsync()`
- **Frontend:** ProductManagementView
- **Button/Action:** Remove material from product
- **Purpose:** Removes a material requirement from a product

### sp_GetProductMaterials
- **Service:** ProductMaterialDataService.cs → `GetProductMaterialsAsync()`
- **Frontend:** ProductManagementView
- **Button/Action:** View product materials
- **Purpose:** Lists all materials required for a specific product

### sp_CalculateProductionOrderMaterialRequirements
- **Service:** ProductMaterialDataService.cs → `CalculateProductionOrderMaterialRequirementsAsync()`
- **Frontend:** ProductionOrderManagementView
- **Button/Action:** Production order creation (automatic)
- **Purpose:** Calculates total material requirements for a production order

### sp_CheckMaterialsAvailability
- **Service:** ProductMaterialDataService.cs → `CheckMaterialsAvailabilityAsync()`
- **Frontend:** ProductionOrderManagementView, OrderApprovalViewControl
- **Button/Action:** Material check before order approval
- **Purpose:** Validates material availability for production

### sp_GetAllProductMaterialRequirements
- **Service:** ProductMaterialDataService.cs → `GetAllProductMaterialRequirementsAsync()`
- **Frontend:** Not directly linked to UI
- **Button/Action:** N/A
- **Purpose:** Gets all product-material relationships

---

## 📊 Summary Statistics

### Total Stored Procedures Mapped: **92+**
### Total Service Methods: **150+**
### Total Dashboard Views: **7**
- OwnerDashboard
- SalesManagerDashboard
- ProductionManagerDashboard
- SalespersonDashboard
- TailorDashboard
- DeliveryPersonDashboard
- MainWindow (Login)

### Total Management Views: **15+**
- EmployeeManagementView
- DepartmentAnalyticsModule
- ProductManagementView
- StockManagementView
- RawMaterialManagementView
- DealsManagementView
- RetailersManagementView
- SalesOrdersManagementView
- ProductionOrderManagementView
- DeliveryManagementView
- OrderApprovalViewControl
- TailorTasksViewControl
- SimpleRevenueView
- RevenueView
- MaterialCheckDialog
- TailorSelectionDialog
- AddProductDialog
- AddExpenseDialog
- AddPurchaseDialog
- AddStockEntryDialog
- RejectReasonDialog

---

## 🔄 Key Integration Patterns

### Pattern 1: CRUD Operations
Most modules follow this pattern:
- **Get All** → Page Load (automatic)
- **Get By ID** → View Details button
- **Add** → Create/Add button
- **Update** → Update button
- **Delete** → Delete button
- **Search** → Search box text change

### Pattern 2: Approval Workflow
Order/Deal → Pending Approvals → Check Materials → Select Tailors → Approve → Create Production Order → Assign Tailors → Deduct Materials

### Pattern 3: Statistical Dashboard
Module View → Page Load → Statistics Procedure → Display Cards/Charts

### Pattern 4: Master-Detail
Main Grid → Select Item → Load Details → Show Related Items (e.g., Order Items, Deal Items, Product Materials)

---

## 📝 Notes

1. **Legacy Procedures**: Some procedures have newer versions (e.g., sp_PayMonthlySalary vs sp_PayMonthlySalaries)
2. **Automatic Triggers**: Some procedures are called automatically during business processes (e.g., material deduction during production order approval)
3. **Authorization**: Access to procedures is controlled by user roles (Owner, Sales Manager, Production Manager, etc.)
4. **Transaction Safety**: Critical procedures like approval workflows use database transactions for data integrity

---

**Document Version:** 1.0  
**Last Updated:** December 17, 2025  
**Maintained By:** Development Team
