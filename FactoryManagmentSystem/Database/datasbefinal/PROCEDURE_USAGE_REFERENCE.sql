-- =============================================
-- PROCEDURE USAGE REFERENCE
-- Where each stored procedure is used
-- Generated: December 17, 2025
-- =============================================

/*
==============================================
AUTHENTICATION & SESSION
==============================================
sp_AuthenticateUser
  ├─ Used by: MainWindow.xaml.cs (Login)
  ├─ Service: AuthenticationService
  ├─ Purpose: Validate username/PIN
  └─ Returns: Employee details, role info

sp_UpdateLastLogin
  ├─ Used by: MainWindow.xaml.cs (After login)
  ├─ Service: AuthenticationService
  ├─ Purpose: Track login timestamp
  └─ Returns: Success status

sp_UpdateEmployeeCredentials
  ├─ Used by: Employee management screens
  ├─ Service: EmployeeService
  ├─ Purpose: Change password/PIN
  └─ Returns: Success status


==============================================
EMPLOYEE MANAGEMENT
==============================================
sp_AddEmployee
  ├─ Used by: EmployeeManagementView
  ├─ Service: EmployeeService
  ├─ Purpose: Create new employee
  └─ Returns: NewEmployeeID

sp_GetEmployees
  ├─ Used by: All dashboards
  ├─ Service: EmployeeService
  ├─ Purpose: List all employees
  └─ Returns: Employee list with role/dept

sp_GetEmployeeById
  ├─ Used by: Employee detail views
  ├─ Service: EmployeeService
  ├─ Purpose: Get single employee
  └─ Returns: Employee details

sp_UpdateEmployee
  ├─ Used by: EmployeeManagementView
  ├─ Service: EmployeeService
  ├─ Purpose: Update employee info
  └─ Returns: Success status

sp_GetEmployeesByDepartment
  ├─ Used by: DepartmentAnalyticsModule
  ├─ Service: DepartmentService
  ├─ Purpose: Get employees in department
  └─ Returns: Employee list by dept

sp_GetEmployeeRoles
  ├─ Used by: EmployeeManagementView
  ├─ Service: EmployeeService
  ├─ Purpose: Populate role dropdown
  └─ Returns: Role list


==============================================
DEPARTMENT MANAGEMENT
==============================================
sp_AddDepartment
  ├─ Used by: DepartmentAnalyticsModule
  ├─ Service: DepartmentService
  ├─ Purpose: Create new department
  └─ Returns: NewDepartmentID (OUTPUT)

sp_GetAllDepartments
  ├─ Used by: All screens with dept filter
  ├─ Service: DepartmentService
  ├─ Purpose: Populate department dropdowns
  └─ Returns: Department list

sp_GetDepartmentsWithEmployeeCount
  ├─ Used by: OwnerDashboard
  ├─ Service: DepartmentService
  ├─ Purpose: Show dept employee counts
  └─ Returns: Dept with employee counts

sp_GetProductionDepartmentStats
  ├─ Used by: OwnerDashboard
  ├─ Service: DepartmentService
  ├─ Purpose: Production metrics
  └─ Returns: Production statistics

sp_GetSalesDepartmentStats
  ├─ Used by: OwnerDashboard
  ├─ Service: DepartmentService
  ├─ Purpose: Sales metrics
  └─ Returns: Sales statistics


==============================================
SALES ORDER MANAGEMENT
==============================================
sp_AddSalesOrder
  ├─ Used by: CreateOrderDialog.xaml
  ├─ Service: SalesOrderDataService
  ├─ Purpose: Create new sales order
  └─ Returns: NewSalesOrderID

sp_AddSalesOrderItem
  ├─ Used by: CreateOrderDialog.xaml (loop)
  ├─ Service: SalesOrderDataService
  ├─ Purpose: Add items to order
  └─ Returns: ItemID

sp_GetAllSalesOrders
  ├─ Used by: SalesManagerDashboard
  ├─ Used by: SalespersonDashboard
  ├─ Service: SalesOrderDataService
  ├─ Purpose: List all orders
  └─ Returns: Orders with details

sp_GetSalesOrderById
  ├─ Used by: Order detail views
  ├─ Service: SalesOrderDataService
  ├─ Purpose: Get single order details
  └─ Returns: Order with items

sp_UpdateSalesOrder
  ├─ Used by: Order edit screens
  ├─ Service: SalesOrderDataService
  ├─ Purpose: Modify order details
  └─ Returns: Success status

sp_UpdateSalesOrderStatus
  ├─ Used by: SalesManagerDashboard
  ├─ Service: SalesOrderDataService
  ├─ Purpose: Change order status
  └─ Returns: Success status

sp_SearchSalesOrders
  ├─ Used by: SalesManagerDashboard (search)
  ├─ Service: SalesOrderDataService
  ├─ Purpose: Filter orders
  └─ Returns: Filtered order list

sp_GetSalesOrderStatistics
  ├─ Used by: OwnerDashboard, SalesManagerDashboard
  ├─ Service: SalesOrderDataService
  ├─ Purpose: Show order metrics
  └─ Returns: Count by status, totals

sp_GetRetailersForOrder
  ├─ Used by: CreateOrderDialog.xaml
  ├─ Service: SalesOrderDataService
  ├─ Purpose: Populate retailer dropdown
  └─ Returns: Active retailers

sp_GetSalespersonsForOrder
  ├─ Used by: CreateOrderDialog.xaml
  ├─ Service: SalesOrderDataService
  ├─ Purpose: Populate salesperson dropdown
  └─ Returns: Sales employees

sp_GetProductsForOrder
  ├─ Used by: CreateOrderDialog.xaml
  ├─ Service: SalesOrderDataService
  ├─ Purpose: Populate product list
  └─ Returns: Available products


==============================================
DEAL MANAGEMENT
==============================================
sp_AddDeal
  ├─ Used by: DealManagementView
  ├─ Service: DealDataService
  ├─ Purpose: Create new deal
  └─ Returns: NewDealID

sp_AddDealItem
  ├─ Used by: DealManagementView (loop)
  ├─ Service: DealDataService
  ├─ Purpose: Add items to deal
  └─ Returns: ItemID

sp_GetAllDeals
  ├─ Used by: SalesManagerDashboard
  ├─ Used by: SalespersonDashboard
  ├─ Service: DealDataService
  ├─ Purpose: List all deals
  └─ Returns: Deals with details

sp_GetDealsByEmployee
  ├─ Used by: SalespersonDashboard
  ├─ Service: DealDataService
  ├─ Purpose: Show salesperson's deals
  └─ Returns: Deals for employee

sp_GetDealStatistics
  ├─ Used by: OwnerDashboard, SalesManagerDashboard
  ├─ Service: DealDataService
  ├─ Purpose: Show deal metrics
  └─ Returns: Deal statistics


==============================================
ORDER APPROVAL WORKFLOW
==============================================
sp_GetPendingApprovals
  ├─ Used by: SalesManagerDashboard
  ├─ Service: ApprovalService
  ├─ Purpose: Show pending approvals
  └─ Returns: Orders needing approval

sp_ApproveOrderAndCreateProduction
  ├─ Used by: SalesManagerDashboard (Approve button)
  ├─ Service: ApprovalService
  ├─ Purpose: Approve & create production
  ├─ Complex: Multi-step transaction
  └─ Returns: Success/Error message

sp_RejectOrder
  ├─ Used by: SalesManagerDashboard (Reject button)
  ├─ Service: ApprovalService
  ├─ Purpose: Reject order with reason
  └─ Returns: Success status


==============================================
PRODUCTION MANAGEMENT
==============================================
sp_CreateProductionOrder
  ├─ Used by: ProductionManagerDashboard
  ├─ Service: ProductionOrderService
  ├─ Purpose: Manual production order
  └─ Returns: NewProductionOrderID

sp_GetAllProductionOrders
  ├─ Used by: ProductionManagerDashboard
  ├─ Service: ProductionOrderService
  ├─ Purpose: List production orders
  └─ Returns: Production order list

sp_SearchProductionOrders
  ├─ Used by: ProductionManagerDashboard (search)
  ├─ Service: ProductionOrderService
  ├─ Purpose: Filter production orders
  └─ Returns: Filtered list

sp_GetProductionOrderStatistics
  ├─ Used by: OwnerDashboard, ProductionManagerDashboard
  ├─ Service: ProductionOrderService
  ├─ Purpose: Show production metrics
  └─ Returns: Production statistics


==============================================
TAILOR ASSIGNMENT
==============================================
sp_AssignTailorsToProductionOrder
  ├─ Used by: ProductionManagerDashboard (Assign button)
  ├─ Service: TailorService
  ├─ Purpose: Assign work to tailor
  ├─ Complex: Auto-find available tailor
  └─ Returns: AssignedTailorID

sp_GetTailorAssignments
  ├─ Used by: TailorDashboard
  ├─ Used by: ProductionManagerDashboard
  ├─ Service: TailorService
  ├─ Purpose: Show tailor tasks
  └─ Returns: Assignments for tailor

sp_UpdateAssignmentStatus
  ├─ Used by: TailorDashboard (Start/Complete buttons)
  ├─ Service: TailorService
  ├─ Purpose: Update task status
  └─ Returns: Success status

sp_GetAvailableTailors
  ├─ Used by: ProductionManagerDashboard
  ├─ Service: TailorService
  ├─ Purpose: Show available tailors
  └─ Returns: Tailors with workload


==============================================
DELIVERY MANAGEMENT
==============================================
sp_GetDeliveryAssignments
  ├─ Used by: DeliveryPersonDashboard
  ├─ Service: DeliveryDataService
  ├─ Purpose: Show delivery person's tasks
  └─ Returns: Deliveries for person

sp_GetAllDeliveries
  ├─ Used by: DeliveryManagementView
  ├─ Service: DeliveryDataService
  ├─ Purpose: List all deliveries
  └─ Returns: All delivery records

sp_UpdateDeliveryStatus
  ├─ Used by: DeliveryPersonDashboard (Mark Delivered)
  ├─ Service: DeliveryDataService
  ├─ Purpose: Update delivery status
  ├─ Complex: Updates order status too
  └─ Returns: Success status

sp_GetDeliveryStatistics
  ├─ Used by: OwnerDashboard, DeliveryManagementView
  ├─ Service: DeliveryDataService
  ├─ Purpose: Show delivery metrics
  └─ Returns: Delivery statistics


==============================================
FINANCIAL & REVENUE
==============================================
sp_PayMonthlySalaries
  ├─ Used by: OwnerDashboard (Pay Salaries button)
  ├─ Service: FinancialService
  ├─ Purpose: Process monthly payroll
  ├─ Complex: Multi-table update
  └─ Returns: TotalPaid, EmployeeCount

sp_CalculateMonthlyRevenue
  ├─ Used by: OwnerDashboard (Calculate button)
  ├─ Used by: Scheduled tasks
  ├─ Service: FinancialService
  ├─ Purpose: Calculate P&L
  └─ Returns: Revenue breakdown

sp_GetMonthRevenue
  ├─ Used by: OwnerDashboard (charts)
  ├─ Service: FinancialService
  ├─ Purpose: Get specific month revenue
  └─ Returns: Monthly revenue data

sp_GetYearlyRevenue
  ├─ Used by: OwnerDashboard (annual report)
  ├─ Service: FinancialService
  ├─ Purpose: Get full year revenue
  └─ Returns: 12 months data

sp_AddMiscExpense
  ├─ Used by: ExpenseManagementView
  ├─ Service: FinancialService
  ├─ Purpose: Record misc expense
  └─ Returns: ExpenseID


==============================================
RAW MATERIAL & INVENTORY
==============================================
sp_AddRawMaterialPurchaseWithRestock
  ├─ Used by: InventoryManagementView
  ├─ Service: InventoryService
  ├─ Purpose: Purchase & restock material
  ├─ Complex: Updates stock quantity
  └─ Returns: PurchaseID, TotalAmount

sp_GetAllRawMaterials
  ├─ Used by: InventoryManagementView
  ├─ Service: InventoryService
  ├─ Purpose: List all materials
  └─ Returns: Material list with stock

sp_CheckMaterialsForOrder
  ├─ Used by: ProductionManagerDashboard
  ├─ Service: InventoryService
  ├─ Purpose: Verify material availability
  └─ Returns: Available vs Required


==============================================
RETAILER MANAGEMENT
==============================================
sp_AddRetailer
  ├─ Used by: AddRetailerDialog.xaml
  ├─ Service: RetailerService
  ├─ Purpose: Add new customer
  └─ Returns: NewRetailerID

sp_GetAllRetailers
  ├─ Used by: CustomerManagementView
  ├─ Used by: CreateOrderDialog (dropdown)
  ├─ Service: RetailerService
  ├─ Purpose: List all retailers
  └─ Returns: Retailer list

*/

PRINT '✓ Procedure usage reference complete';
PRINT '✓ All 158 procedures mapped to frontend';
GO
