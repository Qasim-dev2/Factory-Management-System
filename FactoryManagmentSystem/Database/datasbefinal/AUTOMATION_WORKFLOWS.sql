-- =============================================
-- AUTOMATION WORKFLOW DOCUMENTATION
-- Complete automation flows in the system
-- Generated: December 17, 2025
-- =============================================

/*
==============================================
WORKFLOW 1: ORDER TO DELIVERY PROCESS
==============================================

STEP 1: Salesperson Creates Order
┌──────────────────────────────────────┐
│ Frontend: CreateOrderDialog.xaml    │
│ Service: SalesOrderDataService      │
│ Procedures:                          │
│   1. sp_GetRetailersForOrder()       │
│   2. sp_GetProductsForOrder()        │
│   3. sp_AddSalesOrder(...)           │
│   4. sp_AddSalesOrderItem(...)       │
└──────────────────────────────────────┘
         ↓
   Order created with Status = 'Pending'
         ↓

STEP 2: Auto-Create Approval Request
┌──────────────────────────────────────┐
│ Procedure: sp_AddSalesOrder          │
│ Auto-inserts into OrderApproval:     │
│   - OrderType = 'SalesOrder'         │
│   - Status = 'Pending'               │
│   - RequestedByEmployeeID = SalesRep │
└──────────────────────────────────────┘
         ↓
   Approval request visible to Sales Manager
         ↓

STEP 3: Sales Manager Approves
┌──────────────────────────────────────┐
│ Frontend: SalesManagerDashboard.xaml │
│ Service: SalesOrderDataService       │
│ Procedure:                            │
│   sp_ApproveOrderAndCreateProduction │
│   (@ApprovalID, @ApprovedBy)         │
│                                       │
│ AUTOMATED ACTIONS:                   │
│   1. Update OrderApproval status     │
│   2. Update SalesOrder status        │
│   3. Create ProductionOrder records  │
│   4. One record per SalesOrderItem   │
└──────────────────────────────────────┘
         ↓
   Production orders created automatically
         ↓

STEP 4: Production Manager Assigns Tailors
┌──────────────────────────────────────┐
│ Frontend: ProductionManagerDashboard │
│ Service: ProductionOrderService      │
│ Procedure:                            │
│   sp_AssignTailorsToProductionOrder  │
│   (@ProductionOrderID, @TailorID)    │
│                                       │
│ AUTOMATED ACTIONS:                   │
│   1. Find least busy tailor (if NULL)│
│   2. Create TailorAssignment         │
│   3. Update ProductionOrder status   │
└──────────────────────────────────────┘
         ↓
   Work assigned to tailors
         ↓

STEP 5: Tailor Completes Work
┌──────────────────────────────────────┐
│ Frontend: TailorDashboard.xaml       │
│ Service: TailorService               │
│ Procedure:                            │
│   sp_UpdateAssignmentStatus          │
│   (@AssignmentID, 'Complete')        │
│                                       │
│ MANUAL ACTION by Tailor:             │
│   - Marks task as complete           │
│   - Sets CompletedDate               │
└──────────────────────────────────────┘
         ↓
   Optional: Auto-create delivery
         ↓

STEP 6: Delivery Created (Auto or Manual)
┌──────────────────────────────────────┐
│ Option A: Automatic                  │
│   sp_CompleteProductionAndCreateDel..│
│   - Triggered when all tasks done    │
│                                       │
│ Option B: Manual                     │
│   sp_CreateDeliveryFromProduction    │
│   - Manager creates explicitly       │
└──────────────────────────────────────┘
         ↓
   Delivery assigned to delivery person
         ↓

STEP 7: Delivery Person Completes
┌──────────────────────────────────────┐
│ Frontend: DeliveryPersonDashboard    │
│ Service: DeliveryDataService         │
│ Procedure:                            │
│   sp_UpdateDeliveryStatus            │
│   (@DeliveryID, 'Delivered')         │
│                                       │
│ AUTOMATED ACTIONS:                   │
│   1. Update Delivery status          │
│   2. Update SalesOrder status        │
│   3. Update Deal status              │
│   4. Trigger revenue calculation     │
└──────────────────────────────────────┘
         ↓
   Order marked as delivered
         ↓
   Revenue recorded


==============================================
WORKFLOW 2: MONTHLY SALARY PAYMENT
==============================================

STEP 1: Auto-Check Unpaid Months
┌──────────────────────────────────────┐
│ Procedure: sp_GetUnpaidSalaryMonths  │
│ Returns: Months without payment      │
│ Used by: Owner Dashboard             │
└──────────────────────────────────────┘
         ↓

STEP 2: Process Payment
┌──────────────────────────────────────┐
│ Frontend: Owner Dashboard            │
│ Procedure: sp_PayMonthlySalaries     │
│   (@PaymentMonth, @PaymentYear)      │
│                                       │
│ AUTOMATED ACTIONS:                   │
│   1. Calculate total salary          │
│   2. Count active employees          │
│   3. Insert SalaryPayment record     │
│   4. Update MonthlyRevenue           │
│   5. Set SalariesPaid = 1            │
│                                       │
│ VALIDATION:                           │
│   - Prevents duplicate payments      │
│   - Only counts active employees     │
└──────────────────────────────────────┘


==============================================
WORKFLOW 3: RAW MATERIAL PURCHASE & RESTOCK
==============================================

STEP 1: Purchase Material
┌──────────────────────────────────────┐
│ Frontend: Inventory Module           │
│ Procedure:                            │
│   sp_AddRawMaterialPurchaseWithRestock│
│   (@RawMaterialID, @Quantity,...)    │
│                                       │
│ AUTOMATED ACTIONS:                   │
│   1. Insert RawMaterialPurchase      │
│   2. Update RawMaterial.StockQuantity│
│   3. Calculate TotalAmount           │
│   4. Record supplier info            │
└──────────────────────────────────────┘
         ↓

STEP 2: Check Material for Production
┌──────────────────────────────────────┐
│ Procedure: sp_CheckMaterialsForOrder │
│ Returns: Available vs Required       │
│ Prevents: Production without stock   │
└──────────────────────────────────────┘
         ↓

STEP 3: Deduct Material on Production
┌──────────────────────────────────────┐
│ Procedure: sp_RecordStockUsage       │
│ Updates: RawMaterial.StockQuantity   │
│ Tracks: Which order used materials   │
└──────────────────────────────────────┘


==============================================
WORKFLOW 4: MONTHLY REVENUE CALCULATION
==============================================

AUTOMATED CALCULATION TRIGGERS:
1. When order status changes to 'Delivered'
2. When salary payment is recorded
3. When material purchase is made
4. When misc expense is added

PROCEDURE: sp_CalculateMonthlyRevenue
┌──────────────────────────────────────┐
│ Calculates:                           │
│   - SalesIncome (delivered orders)   │
│   - DealIncome (delivered deals)     │
│   - TotalSalaries (from payments)    │
│   - RawMaterialCost (purchases)      │
│   - MiscExpense (all categories)     │
│                                       │
│ Auto-computed:                        │
│   - TotalIncome = Sales + Deals      │
│   - TotalExpense = Sal + Mat + Misc  │
│   - NetProfit = Income - Expense     │
└──────────────────────────────────────┘

DISPLAY: Owner Dashboard Revenue Charts


==============================================
WORKFLOW 5: EMPLOYEE AUTHENTICATION
==============================================

LOGIN FLOW:
┌──────────────────────────────────────┐
│ Frontend: MainWindow.xaml            │
│ Service: AuthenticationService       │
│ Procedure: sp_AuthenticateUser       │
│   (@Username, @PIN)                  │
│                                       │
│ RETURNS:                              │
│   - EmployeeID                       │
│   - RoleID, RoleName                 │
│   - DepartmentID                     │
│   - IsActive                         │
│                                       │
│ AUTOMATED ACTIONS:                   │
│   - sp_UpdateLastLogin()             │
│   - Set UserSession                  │
│   - Route to role dashboard          │
└──────────────────────────────────────┘

DASHBOARD ROUTING:
- RoleID 1 (Owner)      → OwnerDashboard
- RoleID 2 (Sales Mgr)  → SalesManagerDashboard
- RoleID 3 (Salesperson)→ SalespersonDashboard
- RoleID 4 (Prod Mgr)   → ProductionManagerDashboard
- RoleID 5 (Tailor)     → TailorDashboard
- RoleID 6 (Delivery)   → DeliveryPersonDashboard


==============================================
KEY AUTOMATION FEATURES
==============================================

1. AUTO-APPROVAL WORKFLOW
   - Order submission → Approval request
   - Approval → Production creation
   - Production → Tailor assignment

2. AUTO-DELIVERY CREATION
   - Production complete → Delivery created
   - All tailors done → Delivery pending

3. AUTO-REVENUE TRACKING
   - Delivered order → Revenue updated
   - Monthly calculation → P&L report

4. AUTO-STOCK MANAGEMENT
   - Purchase → Stock increase
   - Production → Stock decrease
   - Low stock → Reorder alert

5. AUTO-SALARY PROCESSING
   - Monthly trigger → Calculate total
   - Payment record → Update revenue
   - Prevent duplicates → Validation

6. AUTO-STATISTICS UPDATES
   - Real-time counts on dashboards
   - Performance metrics calculation
   - KPI auto-refresh

*/

PRINT '✓ Automation workflow documentation complete';
PRINT '✓ 5 major automated workflows documented';
GO
