-- =============================================
-- USED PROCEDURES: DELIVERY & LOGISTICS MODULE
-- Only procedures actively used in the project
-- With Frontend Button/Action Mapping
-- Generated: December 17, 2025
-- =============================================

/*
==============================================
DELIVERY MANAGEMENT (8 Procedures)
==============================================
*/

-- ============================================================================
-- sp_GetAllDeliveries
-- ============================================================================
-- SERVICE: DeliveryDataService.cs → GetAllDeliveriesAsync()
-- FRONTEND: DeliveryPersonDashboard, OwnerDashboard
-- BUTTON/ACTION: Page Load (Automatic) - Deliveries view
-- PURPOSE: Retrieves all deliveries with order and customer details
-- RETURNS: DeliveryID, OrderType (Sales/Deal), CustomerName, DeliveryPersonName, 
--          Status, DeliveryDate, Address
-- ============================================================================

-- ============================================================================
-- sp_GetDeliveryById
-- ============================================================================
-- SERVICE: DeliveryDataService.cs → GetDeliveryByIdAsync()
-- FRONTEND: Delivery Management View
-- BUTTON/ACTION: "View Details" button
-- PURPOSE: Fetches detailed information for a specific delivery
-- PARAMETERS: @DeliveryID INT
-- RETURNS: Complete delivery record with address, dates, status
-- ============================================================================

-- ============================================================================
-- sp_GetDeliveriesByPerson
-- ============================================================================
-- SERVICE: DeliveryDataService.cs → GetDeliveriesByPersonAsync()
-- FRONTEND: DeliveryPersonDashboard
-- BUTTON/ACTION: Page Load (shows logged-in delivery person's deliveries)
-- PURPOSE: Retrieves all deliveries assigned to a specific delivery person
-- PARAMETERS: @DeliveryPersonID INT
-- FILTER: Can filter by status (Pending, In Transit, Delivered)
-- ============================================================================

-- ============================================================================
-- sp_GetDeliveryBySalesOrderId
-- ============================================================================
-- SERVICE: DeliveryDataService.cs → GetDeliveryBySalesOrderIdAsync()
-- FRONTEND: Sales Order Details View
-- BUTTON/ACTION: "View Delivery" button in order details
-- PURPOSE: Gets delivery information for a specific sales order
-- PARAMETERS: @SalesOrderID INT
-- ============================================================================

-- ============================================================================
-- sp_GetDeliveryByDealId
-- ============================================================================
-- SERVICE: DeliveryDataService.cs → GetDeliveryByDealIdAsync()
-- FRONTEND: Deal Details View
-- BUTTON/ACTION: "View Delivery" button in deal details
-- PURPOSE: Gets delivery information for a specific deal
-- PARAMETERS: @DealID INT
-- ============================================================================

-- ============================================================================
-- sp_UpdateDeliveryStatus
-- ============================================================================
-- SERVICE: DeliveryDataService.cs → UpdateDeliveryStatusAsync()
-- FRONTEND: DeliveryPersonDashboard
-- BUTTON/ACTION: "Start Delivery" button, "Mark Delivered" button
-- PURPOSE: Updates the status of a delivery
-- PARAMETERS: @DeliveryID INT, @NewStatus NVARCHAR(50), @DeliveredDate DATETIME
-- STATUSES: Pending, In Transit, Delivered
-- AUTO-ACTIONS when status='Delivered':
--   1. Sets DeliveredDate
--   2. Updates linked SalesOrder/Deal status to 'Delivered'
--   3. Triggers revenue calculation (sp_CalculateMonthlyRevenue)
-- COMPLEX: Multi-step transaction with cascade updates
-- ============================================================================

-- ============================================================================
-- sp_GetDeliveryStatistics
-- ============================================================================
-- SERVICE: DeliveryDataService.cs → GetDeliveryStatisticsAsync()
-- FRONTEND: DeliveryPersonDashboard, OwnerDashboard
-- BUTTON/ACTION: Page Load (Dashboard stats cards)
-- PURPOSE: Provides summary statistics for deliveries
-- PARAMETERS: @DeliveryPersonID INT (NULL = all deliveries)
-- RETURNS: TotalDeliveries, PendingDeliveries, InTransitDeliveries, 
--          CompletedDeliveries, OnTimeRate
-- ============================================================================

-- ============================================================================
-- sp_GetPendingDeliveries
-- ============================================================================
-- SERVICE: DeliveryDataService.cs → GetPendingDeliveriesAsync()
-- FRONTEND: DeliveryPersonDashboard
-- BUTTON/ACTION: "Pending Deliveries" tab/filter
-- PURPOSE: Retrieves all deliveries with Status='Pending'
-- USED FOR: Assigning or viewing unstarted deliveries
-- FILTER: Can optionally filter by DeliveryPersonID
-- ============================================================================


/*
==============================================
ORDER APPROVAL WORKFLOW (6 Procedures)
==============================================
*/

-- ============================================================================
-- sp_GetPendingApprovals
-- ============================================================================
-- SERVICE: OrderApprovalDataService.cs → GetPendingApprovalsAsync()
-- FRONTEND: SalesManagerDashboard
-- BUTTON/ACTION: Page Load - "Pending Approvals" section
-- PURPOSE: Retrieves all orders awaiting approval
-- RETURNS: ApprovalID, OrderType (SalesOrder/Deal), OrderID, RequestedBy, 
--          RequestDate, Status='Pending'
-- FILTER: Only shows Status='Pending'
-- ============================================================================

-- ============================================================================
-- sp_GetApprovalById
-- ============================================================================
-- SERVICE: OrderApprovalDataService.cs → GetApprovalByIdAsync()
-- FRONTEND: Sales Manager Dashboard - Approval Details
-- BUTTON/ACTION: "View Approval Details" button
-- PURPOSE: Fetches detailed information for a specific approval request
-- PARAMETERS: @ApprovalID INT
-- RETURNS: Complete approval record with order details
-- ============================================================================

-- ============================================================================
-- sp_ApproveOrderAndCreateProduction
-- ============================================================================
-- SERVICE: OrderApprovalDataService.cs → ApproveOrderAsync()
-- FRONTEND: SalesManagerDashboard
-- BUTTON/ACTION: "Approve Order" button in Pending Approvals section
-- PURPOSE: Approves order and auto-creates production orders
-- PARAMETERS: @ApprovalID INT, @ApprovedByEmployeeID INT
-- 
-- AUTO-ACTIONS (Multi-step transaction):
--   1. Update OrderApproval: Status='Approved', ApprovedDate=NOW, ApprovedBy=EmployeeID
--   2. Update SalesOrder/Deal: Status='Approved'
--   3. Get all items from order (SalesOrderItems or DealItems)
--   4. FOR EACH item:
--      - Create ProductionOrder (Status='Pending', links to SalesOrder/Deal)
--   5. COMMIT transaction
-- 
-- COMPLEX: This is a CRITICAL workflow procedure
-- ROLLBACK: If any step fails, entire approval is reversed
-- ============================================================================

-- ============================================================================
-- sp_RejectOrder
-- ============================================================================
-- SERVICE: OrderApprovalDataService.cs → RejectOrderAsync()
-- FRONTEND: SalesManagerDashboard
-- BUTTON/ACTION: "Reject Order" button in Pending Approvals section
-- PURPOSE: Rejects an order with rejection reason
-- PARAMETERS: @ApprovalID INT, @RejectedByEmployeeID INT, @RejectionReason NVARCHAR(500)
-- AUTO-ACTIONS:
--   1. Update OrderApproval: Status='Rejected', RejectedDate=NOW, RejectionReason
--   2. Update SalesOrder/Deal: Status='Rejected'
-- ============================================================================

-- ============================================================================
-- sp_GetApprovalHistory
-- ============================================================================
-- SERVICE: OrderApprovalDataService.cs → GetApprovalHistoryAsync()
-- FRONTEND: SalesManagerDashboard, OwnerDashboard
-- BUTTON/ACTION: "Approval History" tab
-- PURPOSE: Shows all past approvals (Approved/Rejected)
-- RETURNS: ApprovalID, OrderType, OrderID, Status, ApprovedBy, ApprovedDate, 
--          RejectedBy, RejectedDate, RejectionReason
-- FILTER: Status IN ('Approved', 'Rejected')
-- ============================================================================

-- ============================================================================
-- sp_GetApprovalStatistics
-- ============================================================================
-- SERVICE: OrderApprovalDataService.cs → GetApprovalStatisticsAsync()
-- FRONTEND: SalesManagerDashboard
-- BUTTON/ACTION: Page Load (Dashboard stats)
-- PURPOSE: Provides summary statistics for approvals
-- RETURNS: TotalApprovals, PendingApprovals, ApprovedCount, RejectedCount, 
--          ApprovalRate, AvgApprovalTime
-- ============================================================================


/*
==============================================
STOCK & INVENTORY TRACKING (10 Procedures)
==============================================
*/

-- ============================================================================
-- sp_RecordStockUsage
-- ============================================================================
-- SERVICE: StockUsageDataService.cs → RecordStockUsageAsync()
-- FRONTEND: Production Order Processing (auto-called)
-- BUTTON/ACTION: Auto-triggered when production starts or completes
-- PURPOSE: Records which materials were used for which order
-- PARAMETERS: @ProductionOrderID INT, @RawMaterialID INT, @QuantityUsed DECIMAL
-- AUTO-ACTIONS:
--   1. Insert StockUsage record (links ProductionOrder → RawMaterial)
--   2. Update RawMaterial.StockQuantity (deduct used amount)
--   3. Check if reorder needed (StockQuantity <= ReorderLevel)
-- ============================================================================

-- ============================================================================
-- sp_GetStockUsageByProductionOrder
-- ============================================================================
-- SERVICE: StockUsageDataService.cs → GetStockUsageByProductionOrderAsync()
-- FRONTEND: Production Order Details View
-- BUTTON/ACTION: "View Material Usage" button
-- PURPOSE: Shows which materials were used for a specific production order
-- PARAMETERS: @ProductionOrderID INT
-- RETURNS: MaterialName, QuantityUsed, UsageDate, UnitPrice, TotalCost
-- ============================================================================

-- ============================================================================
-- sp_GetStockUsageByMaterial
-- ============================================================================
-- SERVICE: StockUsageDataService.cs → GetStockUsageByMaterialAsync()
-- FRONTEND: Raw Material Details View
-- BUTTON/ACTION: "View Usage History" button
-- PURPOSE: Shows usage history for a specific raw material
-- PARAMETERS: @RawMaterialID INT
-- RETURNS: ProductionOrderID, ProductName, QuantityUsed, UsageDate
-- ============================================================================

-- ============================================================================
-- sp_GetStockUsageStatistics
-- ============================================================================
-- SERVICE: StockUsageDataService.cs → GetStockUsageStatisticsAsync()
-- FRONTEND: Inventory Dashboard
-- BUTTON/ACTION: Page Load (Dashboard stats)
-- PURPOSE: Provides summary statistics for material usage
-- RETURNS: TotalMaterialsUsed, TotalCost, MostUsedMaterial, UsageByMonth
-- ============================================================================

-- ============================================================================
-- sp_GetRawMaterialPurchaseHistory
-- ============================================================================
-- SERVICE: RawMaterialDataService.cs → GetRawMaterialPurchaseHistoryAsync()
-- FRONTEND: Raw Material Management View
-- BUTTON/ACTION: "View Purchase History" button
-- PURPOSE: Shows all purchase transactions for raw materials
-- PARAMETERS: @RawMaterialID INT (NULL = all materials)
-- RETURNS: PurchaseID, MaterialName, Quantity, UnitPrice, SupplierName, 
--          PurchaseDate, TotalAmount
-- ============================================================================

-- ============================================================================
-- sp_GetStockValuation
-- ============================================================================
-- SERVICE: StockService.cs → GetStockValuationAsync()
-- FRONTEND: OwnerDashboard - Financial Reports
-- BUTTON/ACTION: "Stock Valuation Report" button
-- PURPOSE: Calculates total value of current stock
-- RETURNS: MaterialName, StockQuantity, UnitPrice, TotalValue
-- CALCULATION: TotalValue = StockQuantity * UnitPrice (per material)
-- SUMMARY: SUM of all material values = Total Stock Asset Value
-- ============================================================================

-- ============================================================================
-- sp_GetMaterialConsumptionRate
-- ============================================================================
-- SERVICE: StockService.cs → GetMaterialConsumptionRateAsync()
-- FRONTEND: Inventory Dashboard
-- BUTTON/ACTION: "Consumption Analysis" report
-- PURPOSE: Calculates average material consumption per month
-- PARAMETERS: @StartDate DATE, @EndDate DATE
-- RETURNS: MaterialName, TotalUsed, AvgMonthlyUsage, TrendDirection
-- USED FOR: Reorder planning and inventory optimization
-- ============================================================================

-- ============================================================================
-- sp_CheckStockAvailability
-- ============================================================================
-- SERVICE: StockService.cs → CheckStockAvailabilityAsync()
-- FRONTEND: Production Planning, Order Creation
-- BUTTON/ACTION: Auto-called before creating production order
-- PURPOSE: Verifies if sufficient stock exists for production
-- PARAMETERS: @ProductID INT, @Quantity INT
-- RETURNS: MaterialName, Required, Available, Sufficient (Yes/No)
-- PREVENTS: Creating orders without materials
-- ============================================================================

-- ============================================================================
-- sp_GenerateRestockRecommendations
-- ============================================================================
-- SERVICE: StockService.cs → GenerateRestockRecommendationsAsync()
-- FRONTEND: Inventory Dashboard
-- BUTTON/ACTION: "Restock Recommendations" widget
-- PURPOSE: Suggests reorder quantities based on usage patterns
-- RETURNS: MaterialName, CurrentStock, ReorderLevel, RecommendedOrderQty, 
--          Reason (Low Stock / High Usage / Upcoming Orders)
-- ALGORITHM: Analyzes consumption rate + pending orders + lead time
-- ============================================================================

-- ============================================================================
-- sp_GetExpiringMaterials
-- ============================================================================
-- SERVICE: StockService.cs → GetExpiringMaterialsAsync()
-- FRONTEND: Inventory Dashboard
-- BUTTON/ACTION: "Expiring Soon" alert widget
-- PURPOSE: Identifies materials approaching expiry date (if tracked)
-- PARAMETERS: @DaysThreshold INT (default 30 days)
-- RETURNS: MaterialName, ExpiryDate, DaysRemaining, StockQuantity
-- ALERT: Highlights urgent items in red
-- ============================================================================


PRINT '✓ Delivery & Logistics Module procedures documented';
PRINT '✓ 8 Delivery procedures';
PRINT '✓ 6 Order Approval procedures';
PRINT '✓ 10 Stock & Inventory procedures';
PRINT '✓ Total: 24 procedures with frontend button mappings';
GO
