-- =============================================
-- USED PROCEDURES: PRODUCTION MODULE
-- Only procedures actively used in the project
-- With Frontend Button/Action Mapping
-- Generated: December 17, 2025
-- =============================================

/*
==============================================
PRODUCTION ORDER MANAGEMENT (12 Procedures)
==============================================
*/

-- ============================================================================
-- sp_GetAllProductionOrders
-- ============================================================================
-- SERVICE: ProductionOrderDataService.cs → GetAllProductionOrdersAsync()
-- FRONTEND: ProductionManagerDashboard → Production Orders
-- BUTTON/ACTION: Page Load (Automatic)
-- PURPOSE: Retrieves all production orders with product and sales order details
-- RETURNS: ProductionOrderID, SalesOrderID, ProductName, Quantity, Status, StartDate, EndDate
-- ============================================================================

-- ============================================================================
-- sp_GetProductionOrderById
-- ============================================================================
-- SERVICE: ProductionOrderDataService.cs → GetProductionOrderByIdAsync()
-- FRONTEND: Production Orders Management View
-- BUTTON/ACTION: "View Details" button
-- PURPOSE: Fetches detailed information for a specific production order
-- PARAMETERS: @ProductionOrderID INT
-- ============================================================================

-- ============================================================================
-- sp_GetProductionOrdersBySalesOrder
-- ============================================================================
-- SERVICE: ProductionOrderDataService.cs → GetProductionOrdersBySalesOrderAsync()
-- FRONTEND: Sales Order Details View
-- BUTTON/ACTION: "View Production Orders" button in sales order details
-- PURPOSE: Retrieves all production orders linked to a specific sales order
-- PARAMETERS: @SalesOrderID INT
-- ============================================================================

-- ============================================================================
-- sp_GetPendingProductionOrders
-- ============================================================================
-- SERVICE: ProductionOrderDataService.cs → GetPendingProductionOrdersAsync()
-- FRONTEND: ProductionManagerDashboard
-- BUTTON/ACTION: "Pending Production" tab/filter
-- PURPOSE: Retrieves all production orders with Status='Pending'
-- USED FOR: Assigning tailors to pending work
-- ============================================================================

-- ============================================================================
-- sp_UpdateProductionOrderStatus
-- ============================================================================
-- SERVICE: ProductionOrderDataService.cs → UpdateProductionOrderStatusAsync()
-- FRONTEND: ProductionManagerDashboard
-- BUTTON/ACTION: Status change buttons, Tailor completion workflow
-- PURPOSE: Updates the status of a production order
-- PARAMETERS: @ProductionOrderID INT, @NewStatus NVARCHAR(50)
-- STATUSES: Pending, In Progress, Completed
-- ============================================================================

-- ============================================================================
-- sp_GetProductionOrderStatistics
-- ============================================================================
-- SERVICE: ProductionOrderDataService.cs → GetProductionOrderStatisticsAsync()
-- FRONTEND: ProductionManagerDashboard
-- BUTTON/ACTION: Page Load (Dashboard stats cards)
-- PURPOSE: Provides summary statistics for production
-- RETURNS: TotalOrders, PendingOrders, InProgressOrders, CompletedOrders
-- ============================================================================

-- ============================================================================
-- sp_AssignTailorsToProductionOrder
-- ============================================================================
-- SERVICE: ProductionOrderDataService.cs → AssignTailorsToProductionOrderAsync()
-- FRONTEND: ProductionManagerDashboard
-- BUTTON/ACTION: "Assign Tailor" button in Production Orders view
-- PURPOSE: Assigns a tailor to a production order (creates TailorAssignment)
-- PARAMETERS: @ProductionOrderID INT, @TailorID INT (NULL = auto-assign least busy)
-- AUTO-ACTIONS:
--   - Creates TailorAssignment record
--   - Updates ProductionOrder status to 'In Progress'
--   - If @TailorID is NULL, finds tailor with least assignments
-- ============================================================================

-- ============================================================================
-- sp_GetProductionOrdersByStatus
-- ============================================================================
-- SERVICE: ProductionOrderDataService.cs → GetProductionOrdersByStatusAsync()
-- FRONTEND: ProductionManagerDashboard
-- BUTTON/ACTION: Status filter dropdown
-- PURPOSE: Filters production orders by status
-- PARAMETERS: @Status NVARCHAR(50)
-- ============================================================================

-- ============================================================================
-- sp_CompleteProductionAndCreateDelivery
-- ============================================================================
-- SERVICE: ProductionOrderDataService.cs → CompleteProductionAndCreateDeliveryAsync()
-- FRONTEND: ProductionManagerDashboard, TailorDashboard
-- BUTTON/ACTION: "Mark Production Complete" button (when all tailors done)
-- PURPOSE: Completes production and auto-creates delivery
-- PARAMETERS: @ProductionOrderID INT
-- AUTO-ACTIONS:
--   1. Updates ProductionOrder status to 'Completed'
--   2. Updates all TailorAssignments to 'Complete'
--   3. Creates Delivery record (Status='Pending', auto-assigns DeliveryPerson)
--   4. Links Delivery to SalesOrder or Deal
-- COMPLEX: Multi-step transaction with rollback on error
-- ============================================================================

-- ============================================================================
-- sp_GetProductionOrdersWithoutDelivery
-- ============================================================================
-- SERVICE: ProductionOrderDataService.cs → GetProductionOrdersWithoutDeliveryAsync()
-- FRONTEND: ProductionManagerDashboard
-- BUTTON/ACTION: "Ready for Delivery" filter
-- PURPOSE: Finds completed production orders that don't have delivery yet
-- USED FOR: Manual delivery creation if auto-creation failed
-- ============================================================================

-- ============================================================================
-- sp_CheckMaterialsForProductionOrder
-- ============================================================================
-- SERVICE: ProductionOrderDataService.cs → CheckMaterialsForProductionOrderAsync()
-- FRONTEND: ProductionManagerDashboard
-- BUTTON/ACTION: "Check Materials" button before starting production
-- PURPOSE: Verifies sufficient raw materials exist for production
-- PARAMETERS: @ProductionOrderID INT
-- RETURNS: MaterialName, Required, Available, Sufficient (Yes/No)
-- PREVENTS: Starting production without materials
-- ============================================================================

-- ============================================================================
-- sp_RecordStockUsageForProduction
-- ============================================================================
-- SERVICE: ProductionOrderDataService.cs → RecordStockUsageForProductionAsync()
-- FRONTEND: ProductionManagerDashboard
-- BUTTON/ACTION: Auto-called when production starts or completes
-- PURPOSE: Deducts raw material stock used in production
-- PARAMETERS: @ProductionOrderID INT, @RawMaterialID INT, @QuantityUsed DECIMAL
-- AUTO-ACTIONS:
--   - Inserts StockUsage record
--   - Updates RawMaterial.StockQuantity (deduct)
-- ============================================================================


/*
==============================================
TAILOR ASSIGNMENT MANAGEMENT (8 Procedures)
==============================================
*/

-- ============================================================================
-- sp_GetAllTailorAssignments
-- ============================================================================
-- SERVICE: TailorService.cs → GetAllTailorAssignmentsAsync()
-- FRONTEND: ProductionManagerDashboard, TailorDashboard
-- BUTTON/ACTION: Page Load - "Tailor Assignments" view
-- PURPOSE: Retrieves all tailor assignments with production order details
-- RETURNS: AssignmentID, TailorName, ProductName, Quantity, Status, AssignedDate
-- ============================================================================

-- ============================================================================
-- sp_GetTailorAssignmentsByTailor
-- ============================================================================
-- SERVICE: TailorService.cs → GetTailorAssignmentsByTailorAsync()
-- FRONTEND: TailorDashboard
-- BUTTON/ACTION: Page Load (shows logged-in tailor's tasks)
-- PURPOSE: Retrieves all assignments for a specific tailor
-- PARAMETERS: @TailorID INT
-- FILTER: Shows Assigned, In Progress, Complete statuses
-- ============================================================================

-- ============================================================================
-- sp_GetTailorAssignmentById
-- ============================================================================
-- SERVICE: TailorService.cs → GetTailorAssignmentByIdAsync()
-- FRONTEND: TailorDashboard
-- BUTTON/ACTION: "View Details" button
-- PURPOSE: Fetches detailed information for a specific assignment
-- PARAMETERS: @AssignmentID INT
-- ============================================================================

-- ============================================================================
-- sp_UpdateAssignmentStatus
-- ============================================================================
-- SERVICE: TailorService.cs → UpdateAssignmentStatusAsync()
-- FRONTEND: TailorDashboard
-- BUTTON/ACTION: "Start Work" button, "Mark Complete" button
-- PURPOSE: Updates the status of a tailor assignment
-- PARAMETERS: @AssignmentID INT, @NewStatus NVARCHAR(50)
-- STATUSES: Assigned, In Progress, Complete
-- AUTO-ACTIONS: Sets CompletedDate when status='Complete'
-- ============================================================================

-- ============================================================================
-- sp_GetTailorWorkload
-- ============================================================================
-- SERVICE: TailorService.cs → GetTailorWorkloadAsync()
-- FRONTEND: ProductionManagerDashboard
-- BUTTON/ACTION: "View Tailor Workload" button (for balanced assignment)
-- PURPOSE: Shows workload statistics for all tailors
-- RETURNS: TailorID, TailorName, ActiveAssignments, CompletedAssignments, InProgressCount
-- USED FOR: Finding least busy tailor for auto-assignment
-- ============================================================================

-- ============================================================================
-- sp_GetTailorStatistics
-- ============================================================================
-- SERVICE: TailorService.cs → GetTailorStatisticsAsync()
-- FRONTEND: TailorDashboard, ProductionManagerDashboard
-- BUTTON/ACTION: Page Load (Dashboard stats panel)
-- PURPOSE: Provides summary statistics for tailor performance
-- PARAMETERS: @TailorID INT (NULL = all tailors)
-- RETURNS: TotalAssignments, CompletedTasks, InProgressTasks, CompletionRate
-- ============================================================================

-- ============================================================================
-- sp_ReassignTailorAssignment
-- ============================================================================
-- SERVICE: TailorService.cs → ReassignTailorAssignmentAsync()
-- FRONTEND: ProductionManagerDashboard
-- BUTTON/ACTION: "Reassign Tailor" button
-- PURPOSE: Transfers an assignment from one tailor to another
-- PARAMETERS: @AssignmentID INT, @NewTailorID INT
-- USED FOR: Workload balancing or tailor unavailability
-- ============================================================================

-- ============================================================================
-- sp_GetCompletedAssignmentsForProduction
-- ============================================================================
-- SERVICE: TailorService.cs → GetCompletedAssignmentsForProductionAsync()
-- FRONTEND: ProductionManagerDashboard
-- BUTTON/ACTION: Auto-called to check if production is ready for delivery
-- PURPOSE: Checks if all tailor assignments for a production order are complete
-- PARAMETERS: @ProductionOrderID INT
-- RETURNS: TotalAssignments, CompletedAssignments, AllComplete (Yes/No)
-- ============================================================================


/*
==============================================
PRODUCT & MATERIAL MANAGEMENT (13 Procedures)
==============================================
*/

-- ============================================================================
-- sp_GetAllProducts
-- ============================================================================
-- SERVICE: ProductDataService.cs → GetAllProductsAsync()
-- FRONTEND: OwnerDashboard → Products, Sales/Deal dialogs
-- BUTTON/ACTION: Page Load (Automatic), Product dropdown population
-- PURPOSE: Retrieves all products with category and pricing
-- RETURNS: ProductID, ProductName, Category, Price, Description
-- ============================================================================

-- ============================================================================
-- sp_GetProductById
-- ============================================================================
-- SERVICE: ProductDataService.cs → GetProductByIdAsync()
-- FRONTEND: Product Management View
-- BUTTON/ACTION: "View Details" button
-- PURPOSE: Fetches detailed information for a specific product
-- PARAMETERS: @ProductID INT
-- ============================================================================

-- ============================================================================
-- sp_AddProduct
-- ============================================================================
-- SERVICE: ProductDataService.cs → AddProductAsync()
-- FRONTEND: Product Management View
-- BUTTON/ACTION: "Add Product" button
-- PURPOSE: Creates a new product record
-- PARAMETERS: @ProductName, @Category, @Price, @Description
-- ============================================================================

-- ============================================================================
-- sp_UpdateProduct
-- ============================================================================
-- SERVICE: ProductDataService.cs → UpdateProductAsync()
-- FRONTEND: Product Management View
-- BUTTON/ACTION: "Update Product" button
-- PURPOSE: Updates existing product information
-- PARAMETERS: @ProductID, @ProductName, @Category, @Price, @Description
-- ============================================================================

-- ============================================================================
-- sp_DeleteProduct
-- ============================================================================
-- SERVICE: ProductDataService.cs → DeleteProductAsync()
-- FRONTEND: Product Management View
-- BUTTON/ACTION: "Delete Product" button
-- PURPOSE: Removes a product from the system
-- PARAMETERS: @ProductID INT
-- ============================================================================

-- ============================================================================
-- sp_GetAllRawMaterials
-- ============================================================================
-- SERVICE: RawMaterialDataService.cs → GetAllRawMaterialsAsync()
-- FRONTEND: OwnerDashboard → Raw Materials, Inventory Management
-- BUTTON/ACTION: Page Load (Automatic)
-- PURPOSE: Retrieves all raw materials with stock information
-- RETURNS: RawMaterialID, MaterialName, StockQuantity, UnitPrice, ReorderLevel
-- ============================================================================

-- ============================================================================
-- sp_GetRawMaterialById
-- ============================================================================
-- SERVICE: RawMaterialDataService.cs → GetRawMaterialByIdAsync()
-- FRONTEND: Raw Material Management View
-- BUTTON/ACTION: "View Details" button
-- PURPOSE: Fetches detailed information for a specific raw material
-- PARAMETERS: @RawMaterialID INT
-- ============================================================================

-- ============================================================================
-- sp_AddRawMaterial
-- ============================================================================
-- SERVICE: RawMaterialDataService.cs → AddRawMaterialAsync()
-- FRONTEND: Raw Material Management View
-- BUTTON/ACTION: "Add Raw Material" button
-- PURPOSE: Creates a new raw material record
-- PARAMETERS: @MaterialName, @StockQuantity, @UnitPrice, @ReorderLevel
-- ============================================================================

-- ============================================================================
-- sp_UpdateRawMaterial
-- ============================================================================
-- SERVICE: RawMaterialDataService.cs → UpdateRawMaterialAsync()
-- FRONTEND: Raw Material Management View
-- BUTTON/ACTION: "Update Raw Material" button
-- PURPOSE: Updates existing raw material information
-- PARAMETERS: @RawMaterialID, @MaterialName, @StockQuantity, @UnitPrice, @ReorderLevel
-- ============================================================================

-- ============================================================================
-- sp_DeleteRawMaterial
-- ============================================================================
-- SERVICE: RawMaterialDataService.cs → DeleteRawMaterialAsync()
-- FRONTEND: Raw Material Management View
-- BUTTON/ACTION: "Delete Raw Material" button
-- PURPOSE: Removes a raw material from the system
-- PARAMETERS: @RawMaterialID INT
-- ============================================================================

-- ============================================================================
-- sp_AddRawMaterialPurchaseWithRestock
-- ============================================================================
-- SERVICE: RawMaterialDataService.cs → AddRawMaterialPurchaseAsync()
-- FRONTEND: Raw Material Management View, Inventory Management
-- BUTTON/ACTION: "Purchase Material" button, "Restock" button
-- PURPOSE: Records material purchase AND updates stock quantity
-- PARAMETERS: @RawMaterialID, @Quantity, @UnitPrice, @SupplierName, @PurchaseDate
-- AUTO-ACTIONS:
--   1. Inserts RawMaterialPurchase record
--   2. Updates RawMaterial.StockQuantity (adds quantity)
--   3. Calculates TotalAmount = Quantity * UnitPrice
-- COMPLEX: Transaction-based with rollback
-- ============================================================================

-- ============================================================================
-- sp_GetLowStockMaterials
-- ============================================================================
-- SERVICE: RawMaterialDataService.cs → GetLowStockMaterialsAsync()
-- FRONTEND: OwnerDashboard, Inventory Dashboard
-- BUTTON/ACTION: "Low Stock Alert" widget, Page Load
-- PURPOSE: Finds materials where StockQuantity <= ReorderLevel
-- RETURNS: MaterialName, StockQuantity, ReorderLevel, Status='Low Stock'
-- ALERT: Triggers reorder notifications
-- ============================================================================

-- ============================================================================
-- sp_GetProductMaterialRequirements
-- ============================================================================
-- SERVICE: ProductMaterialDataService.cs → GetProductMaterialRequirementsAsync()
-- FRONTEND: Product Management View, Production Planning
-- BUTTON/ACTION: "View Material Requirements" button
-- PURPOSE: Shows which raw materials are needed for a product
-- PARAMETERS: @ProductID INT
-- RETURNS: MaterialName, QuantityRequired, Unit
-- ============================================================================


PRINT '✓ Production Module procedures documented';
PRINT '✓ 12 Production Order procedures';
PRINT '✓ 8 Tailor Assignment procedures';
PRINT '✓ 13 Product & Material procedures';
PRINT '✓ Total: 33 procedures with frontend button mappings';
GO
