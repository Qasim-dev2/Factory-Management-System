-- =============================================
-- FRONTEND TO BACKEND MAPPING
-- Maps UI screens to stored procedures
-- Generated: December 17, 2025
-- =============================================

/*
==============================================
OWNER DASHBOARD (OwnerDashboard.xaml)
==============================================
Service: DepartmentService, SalesOrderDataService, DealDataService

DISPLAYED DATA:
1. Department Analytics
   - sp_GetDepartmentsWithEmployeeCount
   - sp_GetProductionDepartmentStats
   - sp_GetSalesDepartmentStats

2. Revenue Charts
   - sp_GetMonthRevenue (for current month)
   - sp_GetYearlyRevenue
   - sp_CalculateMonthlyRevenue

3. Performance Metrics
   - sp_GetSalesOrderStatistics
   - sp_GetDealStatistics
   - sp_GetProductionOrderStatistics

ACTIONS:
- View department performance: sp_GetEmployeesByDepartment
- View financial reports: sp_GetRevenueByDateRange
- Approve high-value orders: sp_ApproveOrderAndCreateProduction

==============================================
SALES MANAGER DASHBOARD (SalesManagerDashboard.xaml)
==============================================
Service: SalesOrderDataService, DealDataService

DISPLAYED DATA:
1. Pending Approvals
   - sp_GetPendingApprovals
   - sp_GetAllSalesOrders (WHERE Status = 'Pending Approval')
   - sp_GetAllDeals (WHERE Status = 'Pending Approval')

2. Sales Statistics
   - sp_GetSalesOrderStatistics
   - sp_GetDealStatistics
   - sp_GetSalesRepresentatives (performance)

ACTIONS:
- Approve Order: sp_ApproveOrderAndCreateProduction
- Reject Order: sp_RejectOrder
- View Order Details: sp_GetSalesOrderById, sp_GetDealById
- Search Orders: sp_SearchSalesOrders
- Update Status: sp_UpdateSalesOrderStatus

==============================================
SALESPERSON DASHBOARD (SalespersonDashboard.xaml)
==============================================
Service: SalesOrderDataService, DealDataService, RetailerService

DISPLAYED DATA:
1. My Sales Orders
   - sp_GetAllSalesOrders (filtered by SalesRepID)
   - sp_GetSalesOrdersByDateRange

2. My Deals
   - sp_GetDealsByEmployee
   - sp_GetDealsByStatus

3. Customers
   - sp_GetAllRetailers
   - sp_GetRetailersForOrder

ACTIONS:
- Create Sales Order: sp_AddSalesOrder + sp_AddSalesOrderItem
- Create Deal: sp_AddDeal + sp_AddDealItem
- Add Retailer: sp_AddRetailer
- Update Order: sp_UpdateSalesOrder
- View Statistics: sp_GetSalesOrderStatistics

==============================================
PRODUCTION MANAGER DASHBOARD (ProductionManagerDashboard.xaml)
==============================================
Service: ProductionOrderService, TailorService

DISPLAYED DATA:
1. Production Orders
   - sp_GetAllProductionOrders
   - sp_SearchProductionOrders
   - sp_GetProductionOrderStatistics

2. Tailor Assignments
   - sp_GetTailorAssignments
   - sp_GetAvailableTailors

3. Raw Materials
   - sp_GetAllRawMaterials
   - sp_GetRawMaterialStatistics
   - sp_CheckMaterialsAvailability

ACTIONS:
- Create Production Order: sp_CreateProductionOrder
- Assign Tailors: sp_AssignTailorsToProductionOrder
- Update Production: sp_UpdateProductionOrder
- Check Materials: sp_CheckMaterialsForOrder
- Record Material Usage: sp_RecordStockUsage

==============================================
TAILOR DASHBOARD (TailorDashboard.xaml)
==============================================
Service: TailorService

DISPLAYED DATA:
1. My Assignments
   - sp_GetTailorAssignments (WHERE TailorID = current user)
   - Filtered by Status: 'Assigned', 'InProgress'

2. Task Statistics
   - Count of pending tasks
   - Count of in-progress tasks
   - Count of completed tasks

ACTIONS:
- Start Work: sp_UpdateAssignmentStatus (@Status = 'InProgress')
- Complete Work: sp_UpdateAssignmentStatus (@Status = 'Complete')
   OR sp_UpdateTailorCompletionStatus
- View Task Details: sp_GetProductionOrderById

==============================================
DELIVERY PERSON DASHBOARD (DeliveryPersonDashboard.xaml)
==============================================
Service: DeliveryDataService

DISPLAYED DATA:
1. My Deliveries
   - sp_GetDeliveryAssignments (WHERE DeliveredBy = current user)
   - sp_GetAllDeliveries (filtered by delivery person)

2. Pending Deliveries
   - WHERE Status = 'Pending'

3. Delivery Statistics
   - sp_GetDeliveryStatistics

ACTIONS:
- Update Status: sp_UpdateDeliveryStatus
- Mark Delivered: sp_UpdateDeliveryStatus (@Status = 'Delivered')
- View Details: sp_GetDeliveryById
- Update Info: sp_UpdateDelivery

==============================================
COMMON OPERATIONS (All Dashboards)
==============================================

LOGIN/AUTHENTICATION:
- sp_AuthenticateUser (@Username, @PIN)
- sp_UpdateLastLogin

DEPARTMENT ANALYTICS:
- sp_GetDepartmentsWithEmployeeCount
- sp_GetEmployeesByDepartment

PRODUCT MANAGEMENT:
- sp_GetAllProducts
- sp_GetProductsForOrder
- sp_SearchProducts

EMPLOYEE MANAGEMENT:
- sp_GetEmployees
- sp_GetEmployeesByDepartment
- sp_GetEmployeeRoles

==============================================
DIALOGS & POPUP WINDOWS
==============================================

CreateOrderDialog.xaml:
- sp_GetRetailersForOrder
- sp_GetSalespersonsForOrder
- sp_GetProductsForOrder
- sp_AddSalesOrder + sp_AddSalesOrderItem

AddRetailerDialog.xaml:
- sp_AddRetailer
- sp_UpdateRetailer

*/

PRINT '✓ Frontend to Backend mapping documented';
GO
