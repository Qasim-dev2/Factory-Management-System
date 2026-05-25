-- =============================================
-- MASTER SUMMARY: USED PROCEDURES
-- Complete reference of all procedures used in the project
-- With Frontend Button/Action Mapping
-- Generated: December 17, 2025
-- =============================================

/*
==============================================
DOCUMENTATION OVERVIEW
==============================================

This documentation package contains ONLY the stored procedures that are 
actively used in the Factory Management System frontend. Each procedure 
is documented with:

1. Service file that calls it
2. Frontend screen/dashboard
3. Exact button or action that triggers it
4. Purpose and business logic
5. Parameters and return values
6. Auto-actions and side effects

Total Used Procedures: 151
Unused Procedures: 7 (documented separately in PROCEDURES_NOT_USED_IN_PROJECT.sql)

==============================================
DOCUMENTATION FILES BREAKDOWN
==============================================

File Name                                  | Procedures | Category
-------------------------------------------|------------|---------------------------
USED_PROCEDURES_SALES_MODULE.sql          | 32         | Sales Orders, Deals, Retailers
USED_PROCEDURES_PRODUCTION_MODULE.sql     | 33         | Production, Tailors, Materials
USED_PROCEDURES_DELIVERY_MODULE.sql       | 24         | Delivery, Approvals, Stock
USED_PROCEDURES_EMPLOYEE_MODULE.sql       | 30         | Employees, Departments, Roles, Auth
USED_PROCEDURES_FINANCIAL_MODULE.sql      | 32         | Revenue, Salaries, Expenses, Reports
-------------------------------------------|------------|---------------------------
TOTAL                                      | 151        | 

==============================================
PROCEDURES BY MODULE
==============================================
*/

-- ============================================================================
-- SALES MODULE (32 Procedures)
-- ============================================================================
-- Sales Order Management:        13 procedures
--   - sp_GetAllSalesOrders
--   - sp_GetSalesOrderById
--   - sp_AddSalesOrder               → CreateOrderDialog → "Create Order" button
--   - sp_AddSalesOrderItem
--   - sp_UpdateSalesOrder
--   - sp_DeleteSalesOrder
--   - sp_GetRetailersForOrder        → Populates retailer dropdown
--   - sp_GetSalespersonsForOrder     → Populates salesperson dropdown
--   - sp_GetProductsForOrder         → Populates product dropdown
--   - sp_SearchSalesOrders
--   - sp_GetSalesOrderStatistics
--   - sp_UpdateSalesOrderStatus
--   - sp_GetSalesOrderItems
--
-- Deal Management:               12 procedures
--   - sp_GetAllDeals
--   - sp_GetDealById
--   - sp_AddDeal                     → DealsManagementView → "Add Deal" button
--   - sp_UpdateDeal
--   - sp_DeleteDeal
--   - sp_GetDealStatistics
--   - sp_GetDealsByStatus
--   - sp_GetDealsByEmployee
--   - sp_GetDealItems
--   - sp_AddDealItem
--   - sp_UpdateDealItem
--   - sp_DeleteDealItem
--
-- Retailer Management:           7 procedures
--   - sp_GetAllRetailers
--   - sp_GetRetailerById
--   - sp_AddRetailer                 → AddRetailerDialog → "Add Retailer" button
--   - sp_UpdateRetailer
--   - sp_DeleteRetailer
--   - sp_SearchRetailers
--   - sp_GetRetailerStatistics

-- ============================================================================
-- PRODUCTION MODULE (33 Procedures)
-- ============================================================================
-- Production Order Management:   12 procedures
--   - sp_GetAllProductionOrders
--   - sp_GetProductionOrderById
--   - sp_GetProductionOrdersBySalesOrder
--   - sp_GetPendingProductionOrders
--   - sp_UpdateProductionOrderStatus
--   - sp_GetProductionOrderStatistics
--   - sp_AssignTailorsToProductionOrder         → "Assign Tailor" button
--   - sp_GetProductionOrdersByStatus
--   - sp_CompleteProductionAndCreateDelivery    → "Mark Production Complete" button
--   - sp_GetProductionOrdersWithoutDelivery
--   - sp_CheckMaterialsForProductionOrder       → "Check Materials" button
--   - sp_RecordStockUsageForProduction
--
-- Tailor Assignment:             8 procedures
--   - sp_GetAllTailorAssignments
--   - sp_GetTailorAssignmentsByTailor
--   - sp_GetTailorAssignmentById
--   - sp_UpdateAssignmentStatus      → TailorDashboard → "Start Work", "Mark Complete" buttons
--   - sp_GetTailorWorkload
--   - sp_GetTailorStatistics
--   - sp_ReassignTailorAssignment    → ProductionManagerDashboard → "Reassign Tailor" button
--   - sp_GetCompletedAssignmentsForProduction
--
-- Product & Materials:           13 procedures
--   - sp_GetAllProducts
--   - sp_GetProductById
--   - sp_AddProduct                  → "Add Product" button
--   - sp_UpdateProduct
--   - sp_DeleteProduct
--   - sp_GetAllRawMaterials
--   - sp_GetRawMaterialById
--   - sp_AddRawMaterial
--   - sp_UpdateRawMaterial
--   - sp_DeleteRawMaterial
--   - sp_AddRawMaterialPurchaseWithRestock      → "Purchase Material", "Restock" buttons
--   - sp_GetLowStockMaterials        → Low Stock Alert widget
--   - sp_GetProductMaterialRequirements

-- ============================================================================
-- DELIVERY & LOGISTICS MODULE (24 Procedures)
-- ============================================================================
-- Delivery Management:           8 procedures
--   - sp_GetAllDeliveries
--   - sp_GetDeliveryById
--   - sp_GetDeliveriesByPerson
--   - sp_GetDeliveryBySalesOrderId
--   - sp_GetDeliveryByDealId
--   - sp_UpdateDeliveryStatus        → DeliveryPersonDashboard → "Start Delivery", "Mark Delivered"
--   - sp_GetDeliveryStatistics
--   - sp_GetPendingDeliveries
--
-- Order Approval Workflow:       6 procedures
--   - sp_GetPendingApprovals
--   - sp_GetApprovalById
--   - sp_ApproveOrderAndCreateProduction        → SalesManagerDashboard → "Approve Order" button
--   - sp_RejectOrder                 → SalesManagerDashboard → "Reject Order" button
--   - sp_GetApprovalHistory
--   - sp_GetApprovalStatistics
--
-- Stock & Inventory:             10 procedures
--   - sp_RecordStockUsage
--   - sp_GetStockUsageByProductionOrder
--   - sp_GetStockUsageByMaterial
--   - sp_GetStockUsageStatistics
--   - sp_GetRawMaterialPurchaseHistory
--   - sp_GetStockValuation           → OwnerDashboard → "Stock Valuation Report" button
--   - sp_GetMaterialConsumptionRate
--   - sp_CheckStockAvailability
--   - sp_GenerateRestockRecommendations         → "Restock Recommendations" widget
--   - sp_GetExpiringMaterials        → "Expiring Soon" alert widget

-- ============================================================================
-- EMPLOYEE & ADMIN MODULE (30 Procedures)
-- ============================================================================
-- Authentication:                3 procedures
--   - sp_AuthenticateUser            → MainWindow → "Login" button
--   - sp_UpdateLastLogin             → Auto-called after successful login
--   - sp_ChangeEmployeePassword      → All Dashboards → "Change Password" menu
--
-- Employee Management:           12 procedures
--   - sp_GetAllEmployees
--   - sp_GetEmployeeById
--   - sp_AddEmployee                 → "Add Employee" button
--   - sp_UpdateEmployee
--   - sp_DeleteEmployee
--   - sp_GetEmployeesByRole
--   - sp_GetEmployeesByDepartment
--   - sp_SearchEmployees
--   - sp_GetEmployeeStatistics
--   - sp_GetEmployeesForTailorAssignment        → "Assign Tailor" dropdown population
--   - sp_GetEmployeesForDeliveryAssignment
--   - sp_UpdateEmployeeStatus        → "Activate" / "Deactivate" toggle
--
-- Department Management:         10 procedures
--   - sp_GetAllDepartments
--   - sp_GetDepartmentById
--   - sp_AddDepartment               → "Add Department" button
--   - sp_UpdateDepartment
--   - sp_DeleteDepartment
--   - sp_GetDepartmentEmployees
--   - sp_GetDepartmentStatistics
--   - sp_TransferEmployee            → "Transfer Employee" button
--   - sp_GetDepartmentBudgetUtilization         → "Department Budget Report" button
--   - sp_GetManagersByDepartment
--
-- Role Management:               5 procedures
--   - sp_GetAllRoles
--   - sp_GetRoleById
--   - sp_GetEmployeeCountByRole
--   - sp_GetRolePermissions
--   - sp_UpdateEmployeeRole          → "Change Role" button

-- ============================================================================
-- FINANCIAL MODULE (32 Procedures)
-- ============================================================================
-- Revenue & Reporting:           14 procedures
--   - sp_CalculateMonthlyRevenue     → OwnerDashboard → "Calculate Revenue" button (or auto)
--   - sp_GetMonthlyRevenue
--   - sp_GetYearlyRevenue            → "Yearly Report" button
--   - sp_GetRevenueByDateRange       → "Custom Date Range" → "Generate Report" button
--   - sp_GetTopRevenueProducts       → "Top Products" widget
--   - sp_GetRevenueByRetailer        → "Revenue by Customer" report
--   - sp_GetRevenueBySalesperson     → "Salesperson Performance" report
--   - sp_GetProfitMarginAnalysis     → "Profit Margin Analysis" button
--   - sp_GetExpenseBreakdown         → "Expense Breakdown" chart
--   - sp_GetCashFlowStatement        → "Cash Flow Statement" button
--   - sp_GetFinancialSummary
--   - sp_ComparePeriodRevenue        → "Period Comparison" feature
--   - sp_GetRevenueGrowthTrend       → "Revenue Trend" line chart
--   - sp_GetOutstandingPayments      → "Outstanding Payments" widget
--
-- Salary Management:             5 procedures
--   - sp_PayMonthlySalaries          → OwnerDashboard → "Pay Salaries" button
--   - sp_GetSalaryPaymentHistory
--   - sp_GetUnpaidSalaryMonths       → Alert widget for unpaid months
--   - sp_GetEmployeeSalaryDetails
--   - sp_UpdateEmployeeSalary        → "Update Salary" button
--
-- Expense Management:            7 procedures
--   - sp_AddMiscExpense              → OwnerDashboard → "Add Expense" button
--   - sp_GetAllMiscExpenses
--   - sp_GetMiscExpensesByCategory
--   - sp_GetMiscExpensesByDateRange
--   - sp_UpdateMiscExpense
--   - sp_DeleteMiscExpense
--   - sp_GetExpenseStatistics
--
-- Dashboard Statistics:          6 procedures
--   - sp_GetOwnerDashboardStatistics             → OwnerDashboard page load
--   - sp_GetSalesManagerDashboardStatistics      → SalesManagerDashboard page load
--   - sp_GetProductionManagerDashboardStatistics → ProductionManagerDashboard page load
--   - sp_GetSalespersonDashboardStatistics       → SalespersonDashboard page load
--   - sp_GetTailorDashboardStatistics            → TailorDashboard page load
--   - sp_GetDeliveryPersonDashboardStatistics    → DeliveryPersonDashboard page load


/*
==============================================
CRITICAL WORKFLOW PROCEDURES
==============================================

These procedures are the backbone of the system and handle
complex multi-step business operations:

1. sp_ApproveOrderAndCreateProduction
   - Approves order
   - Creates production orders for each item
   - Updates order approval status
   - Transaction-based with rollback
   FRONTEND: SalesManagerDashboard → "Approve Order" button

2. sp_AssignTailorsToProductionOrder
   - Assigns tailor to production
   - Creates TailorAssignment record
   - Updates production status
   - Auto-finds least busy tailor if not specified
   FRONTEND: ProductionManagerDashboard → "Assign Tailor" button

3. sp_CompleteProductionAndCreateDelivery
   - Completes production order
   - Auto-creates delivery record
   - Assigns delivery person
   - Links to sales order or deal
   FRONTEND: ProductionManagerDashboard → "Mark Production Complete" button

4. sp_UpdateDeliveryStatus
   - Updates delivery status
   - When status = 'Delivered':
     * Updates linked order/deal status
     * Triggers revenue calculation
   FRONTEND: DeliveryPersonDashboard → "Start Delivery", "Mark Delivered" buttons

5. sp_CalculateMonthlyRevenue
   - Calculates complete P&L statement
   - Aggregates sales income
   - Aggregates all expenses
   - Calculates net profit
   - Auto-triggered on order completion, salary payment, etc.
   FRONTEND: OwnerDashboard → "Calculate Revenue" button (or auto)

6. sp_PayMonthlySalaries
   - Processes monthly payroll
   - Updates revenue records
   - Prevents duplicate payments
   FRONTEND: OwnerDashboard → "Pay Salaries" button

7. sp_AddRawMaterialPurchaseWithRestock
   - Records material purchase
   - Updates stock quantity
   - Calculates total amount
   FRONTEND: Inventory Management → "Purchase Material", "Restock" buttons

8. sp_AuthenticateUser
   - Validates credentials
   - Returns role and permissions
   - Routes to appropriate dashboard
   FRONTEND: MainWindow → "Login" button

==============================================
DASHBOARD → PROCEDURE MAPPING
==============================================

OWNER DASHBOARD
├─ Page Load
│  ├─ sp_GetOwnerDashboardStatistics
│  ├─ sp_GetFinancialSummary
│  ├─ sp_GetUnpaidSalaryMonths
│  └─ sp_GetLowStockMaterials
├─ Sales Orders → sp_GetAllSalesOrders
├─ Deals → sp_GetAllDeals
├─ Employees → sp_GetAllEmployees
├─ Departments → sp_GetAllDepartments
├─ Products → sp_GetAllProducts
├─ Raw Materials → sp_GetAllRawMaterials
├─ Retailers → sp_GetAllRetailers
├─ Revenue Reports
│  ├─ sp_GetMonthlyRevenue
│  ├─ sp_GetYearlyRevenue
│  ├─ sp_CalculateMonthlyRevenue
│  └─ sp_GetRevenueGrowthTrend
├─ Expenses
│  ├─ sp_GetAllMiscExpenses
│  ├─ sp_AddMiscExpense
│  └─ sp_GetExpenseStatistics
└─ Payroll
   ├─ sp_PayMonthlySalaries
   └─ sp_GetSalaryPaymentHistory

SALES MANAGER DASHBOARD
├─ Page Load
│  └─ sp_GetSalesManagerDashboardStatistics
├─ Pending Approvals
│  ├─ sp_GetPendingApprovals
│  ├─ sp_ApproveOrderAndCreateProduction  [APPROVE BUTTON]
│  └─ sp_RejectOrder                      [REJECT BUTTON]
├─ Sales Orders → sp_GetAllSalesOrders
├─ Deals → sp_GetAllDeals
└─ Approval History → sp_GetApprovalHistory

SALESPERSON DASHBOARD
├─ Page Load
│  └─ sp_GetSalespersonDashboardStatistics
├─ My Sales Orders → sp_GetAllSalesOrders (filtered)
├─ My Deals → sp_GetDealsByEmployee
└─ Create Order → sp_AddSalesOrder        [CREATE ORDER BUTTON]

PRODUCTION MANAGER DASHBOARD
├─ Page Load
│  └─ sp_GetProductionManagerDashboardStatistics
├─ Production Orders → sp_GetAllProductionOrders
├─ Pending Production → sp_GetPendingProductionOrders
├─ Assign Tailor
│  └─ sp_AssignTailorsToProductionOrder   [ASSIGN TAILOR BUTTON]
├─ Tailor Assignments → sp_GetAllTailorAssignments
├─ Tailor Workload → sp_GetTailorWorkload
└─ Complete Production
   └─ sp_CompleteProductionAndCreateDelivery [MARK COMPLETE BUTTON]

TAILOR DASHBOARD
├─ Page Load
│  └─ sp_GetTailorDashboardStatistics
├─ My Tasks → sp_GetTailorAssignmentsByTailor
├─ Start Work
│  └─ sp_UpdateAssignmentStatus           [START WORK BUTTON]
└─ Mark Complete
   └─ sp_UpdateAssignmentStatus           [MARK COMPLETE BUTTON]

DELIVERY PERSON DASHBOARD
├─ Page Load
│  └─ sp_GetDeliveryPersonDashboardStatistics
├─ My Deliveries → sp_GetDeliveriesByPerson
├─ Pending Deliveries → sp_GetPendingDeliveries
├─ Start Delivery
│  └─ sp_UpdateDeliveryStatus             [START DELIVERY BUTTON]
└─ Mark Delivered
   └─ sp_UpdateDeliveryStatus             [MARK DELIVERED BUTTON]

MAIN WINDOW (Login Screen)
└─ Login
   └─ sp_AuthenticateUser                 [LOGIN BUTTON]

==============================================
QUICK REFERENCE BY BUTTON
==============================================

BUTTON NAME                    | PROCEDURE CALLED                          | DASHBOARD/VIEW
-------------------------------|-------------------------------------------|--------------------------------
Login                          | sp_AuthenticateUser                       | MainWindow
Create Order                   | sp_AddSalesOrder + sp_AddSalesOrderItem   | SalesOrdersManagementView
Add Deal                       | sp_AddDeal + sp_AddDealItem               | DealsManagementView
Add Retailer                   | sp_AddRetailer                            | AddRetailerDialog
Approve Order                  | sp_ApproveOrderAndCreateProduction        | SalesManagerDashboard
Reject Order                   | sp_RejectOrder                            | SalesManagerDashboard
Assign Tailor                  | sp_AssignTailorsToProductionOrder         | ProductionManagerDashboard
Reassign Tailor                | sp_ReassignTailorAssignment               | ProductionManagerDashboard
Start Work                     | sp_UpdateAssignmentStatus                 | TailorDashboard
Mark Complete                  | sp_UpdateAssignmentStatus                 | TailorDashboard
Mark Production Complete       | sp_CompleteProductionAndCreateDelivery    | ProductionManagerDashboard
Start Delivery                 | sp_UpdateDeliveryStatus                   | DeliveryPersonDashboard
Mark Delivered                 | sp_UpdateDeliveryStatus                   | DeliveryPersonDashboard
Calculate Revenue              | sp_CalculateMonthlyRevenue                | OwnerDashboard
Pay Salaries                   | sp_PayMonthlySalaries                     | OwnerDashboard
Add Expense                    | sp_AddMiscExpense                         | OwnerDashboard - Expenses
Purchase Material / Restock    | sp_AddRawMaterialPurchaseWithRestock      | Inventory Management
Add Employee                   | sp_AddEmployee                            | Employee Management
Add Department                 | sp_AddDepartment                          | Department Management
Add Product                    | sp_AddProduct                             | Product Management
Check Materials                | sp_CheckMaterialsForProductionOrder       | ProductionManagerDashboard
Change Password                | sp_ChangeEmployeePassword                 | All Dashboards - Settings

==============================================
FILE LOCATIONS
==============================================

All documentation files are located in:
c:\Users\qasim\OneDrive\Desktop\Factory - Copy\FactoryManagmentSystem\Database\datasbefinal\

Files:
1. USED_PROCEDURES_SALES_MODULE.sql          (32 procedures)
2. USED_PROCEDURES_PRODUCTION_MODULE.sql     (33 procedures)
3. USED_PROCEDURES_DELIVERY_MODULE.sql       (24 procedures)
4. USED_PROCEDURES_EMPLOYEE_MODULE.sql       (30 procedures)
5. USED_PROCEDURES_FINANCIAL_MODULE.sql      (32 procedures)
6. MASTER_SUMMARY_USED_PROCEDURES.sql        (this file - overview)
7. COMPLETE_STORED_PROCEDURE_MAPPING.md      (detailed markdown documentation)

Total: 151 documented procedures with frontend button mappings

==============================================
*/

PRINT '===============================================';
PRINT 'MASTER SUMMARY: USED PROCEDURES';
PRINT '===============================================';
PRINT 'Total Used Procedures: 151';
PRINT 'Sales Module: 32';
PRINT 'Production Module: 33';
PRINT 'Delivery & Logistics: 24';
PRINT 'Employee & Admin: 30';
PRINT 'Financial Module: 32';
PRINT '===============================================';
PRINT 'All procedures mapped to frontend buttons/actions';
PRINT 'Documentation complete ✓';
GO
