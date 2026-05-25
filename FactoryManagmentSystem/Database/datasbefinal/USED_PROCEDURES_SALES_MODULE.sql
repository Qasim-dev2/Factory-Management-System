-- =============================================
-- USED PROCEDURES: SALES MODULE
-- Only procedures actively used in the project
-- With Frontend Button/Action Mapping
-- Generated: December 17, 2025
-- =============================================

/*
==============================================
SALES ORDER MANAGEMENT (13 Procedures)
==============================================
*/

-- ============================================================================
-- sp_GetAllSalesOrders
-- ============================================================================
-- SERVICE: SalesOrderDataService.cs → GetAllSalesOrdersAsync()
-- FRONTEND: OwnerDashboard, SalesManagerDashboard, SalespersonDashboard
-- BUTTON/ACTION: Page Load (Automatic) - Sales Orders → SalesOrdersManagementView
-- PURPOSE: Retrieves all sales orders with retailer and salesperson details
-- RETURNS: Table with OrderID, RetailerName, SalespersonName, OrderDate, TotalAmount, Status
-- ============================================================================

-- ============================================================================
-- sp_GetSalesOrderById
-- ============================================================================
-- SERVICE: SalesOrderDataService.cs → GetSalesOrderByIdAsync()
-- FRONTEND: SalesOrdersManagementView
-- BUTTON/ACTION: "View Details" button, Update Order selection
-- PURPOSE: Fetches detailed information for a specific sales order
-- PARAMETERS: @SalesOrderID INT
-- RETURNS: Single sales order record with all details
-- ============================================================================

-- ============================================================================
-- sp_AddSalesOrder
-- ============================================================================
-- SERVICE: SalesOrderDataService.cs → AddSalesOrderAsync()
-- FRONTEND: SalesOrdersManagementView / CreateOrderDialog
-- BUTTON/ACTION: "Create Order" button in Add tab
-- PURPOSE: Creates a new sales order record and returns the new order ID
-- PARAMETERS: @RetailerID, @EmployeeID, @OrderDate, @Status, @TotalAmount, @NewOrderID OUTPUT
-- RETURNS: @NewOrderID (newly created order ID)
-- AUTO-CREATES: OrderApproval record with Status='Pending'
-- ============================================================================

-- ============================================================================
-- sp_AddSalesOrderItem
-- ============================================================================
-- SERVICE: SalesOrderDataService.cs → AddSalesOrderAsync() (called within loop)
-- FRONTEND: SalesOrdersManagementView / CreateOrderDialog
-- BUTTON/ACTION: "Create Order" button (automatically adds items)
-- PURPOSE: Adds product line items to a sales order
-- PARAMETERS: @SalesOrderID, @ProductID, @Quantity, @UnitPrice
-- CALLED AFTER: sp_AddSalesOrder
-- ============================================================================

-- ============================================================================
-- sp_UpdateSalesOrder
-- ============================================================================
-- SERVICE: SalesOrderDataService.cs → UpdateSalesOrderAsync()
-- FRONTEND: SalesOrdersManagementView
-- BUTTON/ACTION: "Update Order" button in Update tab
-- PURPOSE: Updates existing sales order information including status and amounts
-- PARAMETERS: @SalesOrderID, @RetailerID, @Status, @TotalAmount
-- ============================================================================

-- ============================================================================
-- sp_DeleteSalesOrder
-- ============================================================================
-- SERVICE: SalesOrderDataService.cs → DeleteSalesOrderAsync()
-- FRONTEND: SalesOrdersManagementView
-- BUTTON/ACTION: "Delete Order" button in Delete tab
-- PURPOSE: Removes a sales order from the system
-- PARAMETERS: @SalesOrderID INT
-- NOTE: May cascade delete related items depending on FK constraints
-- ============================================================================

-- ============================================================================
-- sp_GetRetailersForOrder
-- ============================================================================
-- SERVICE: SalesOrderDataService.cs → GetRetailersForOrderAsync()
-- FRONTEND: SalesOrdersManagementView, CreateOrderDialog
-- BUTTON/ACTION: Page Load (populates retailer dropdown)
-- PURPOSE: Loads all active retailers for sales order creation/editing
-- RETURNS: RetailerID, RetailerName, ContactPerson, PhoneNumber
-- FILTER: Active retailers only
-- ============================================================================

-- ============================================================================
-- sp_GetSalespersonsForOrder
-- ============================================================================
-- SERVICE: SalesOrderDataService.cs → GetSalespersonsForOrderAsync()
-- FRONTEND: SalesOrdersManagementView
-- BUTTON/ACTION: Page Load (populates salesperson dropdown)
-- PURPOSE: Loads all active salespeople for sales order assignment
-- RETURNS: EmployeeID, FullName (FirstName + LastName)
-- FILTER: Role = 'Salesperson', IsActive = 1
-- ============================================================================

-- ============================================================================
-- sp_GetProductsForOrder
-- ============================================================================
-- SERVICE: SalesOrderDataService.cs → GetProductsForOrderAsync()
-- FRONTEND: SalesOrdersManagementView, CreateOrderDialog
-- BUTTON/ACTION: Page Load (populates product dropdown in items)
-- PURPOSE: Loads all available products for adding to sales orders
-- RETURNS: ProductID, ProductName, Price, Category
-- ============================================================================

-- ============================================================================
-- sp_SearchSalesOrders
-- ============================================================================
-- SERVICE: SalesOrderDataService.cs → SearchSalesOrdersAsync()
-- FRONTEND: SalesOrdersManagementView
-- BUTTON/ACTION: Search box text change (real-time search)
-- PURPOSE: Filters sales orders based on search criteria
-- PARAMETERS: @SearchTerm NVARCHAR(100)
-- SEARCHES: OrderID, RetailerName, SalespersonName, Status
-- ============================================================================

-- ============================================================================
-- sp_GetSalesOrderStatistics
-- ============================================================================
-- SERVICE: SalesOrderDataService.cs → GetSalesOrderStatisticsAsync()
-- FRONTEND: SalesOrdersManagementView, Dashboard statistics panel
-- BUTTON/ACTION: Page Load (Dashboard stats cards)
-- PURPOSE: Provides summary statistics for sales orders
-- RETURNS: TotalOrders, PendingOrders, CompletedOrders, TotalRevenue, AvgOrderValue
-- ============================================================================

-- ============================================================================
-- sp_UpdateSalesOrderStatus
-- ============================================================================
-- SERVICE: SalesOrderDataService.cs → UpdateSalesOrderStatusAsync()
-- FRONTEND: SalesOrdersManagementView
-- BUTTON/ACTION: Quick status change buttons (Mark as Completed, Mark as Delivered)
-- PURPOSE: Updates only the status of a sales order
-- PARAMETERS: @SalesOrderID INT, @NewStatus NVARCHAR(50)
-- USED FOR: Quick status updates without full order update
-- ============================================================================

-- ============================================================================
-- sp_GetSalesOrderItems
-- ============================================================================
-- SERVICE: SalesOrderDataService.cs → GetSalesOrderItemsAsync()
-- FRONTEND: SalesOrdersManagementView
-- BUTTON/ACTION: View Details button (loads items in details view)
-- PURPOSE: Retrieves all product items for a specific sales order
-- PARAMETERS: @SalesOrderID INT
-- RETURNS: ItemID, ProductName, Quantity, UnitPrice, TotalPrice
-- ============================================================================


/*
==============================================
DEAL MANAGEMENT (12 Procedures)
==============================================
*/

-- ============================================================================
-- sp_GetAllDeals
-- ============================================================================
-- SERVICE: DealDataService.cs → GetAllDealsAsync()
-- FRONTEND: OwnerDashboard, SalesManagerDashboard, SalespersonDashboard
-- BUTTON/ACTION: Page Load (Automatic) - Deals → DealsManagementView
-- PURPOSE: Retrieves all deals with client and employee information
-- RETURNS: DealID, ClientName, EmployeeName, DealDate, TotalAmount, Status
-- ============================================================================

-- ============================================================================
-- sp_GetDealById
-- ============================================================================
-- SERVICE: DealDataService.cs → GetDealByIdAsync()
-- FRONTEND: DealsManagementView
-- BUTTON/ACTION: "View Details" button
-- PURPOSE: Fetches detailed information for a specific deal
-- PARAMETERS: @DealID INT
-- RETURNS: Complete deal record with all details
-- ============================================================================

-- ============================================================================
-- sp_AddDeal
-- ============================================================================
-- SERVICE: DealDataService.cs → AddDealAsync()
-- FRONTEND: DealsManagementView
-- BUTTON/ACTION: "Add Deal" button in Add tab
-- PURPOSE: Creates a new deal record
-- PARAMETERS: @ClientName, @EmployeeID, @DealDate, @TotalAmount, @Status, @NewDealID OUTPUT
-- RETURNS: @NewDealID (newly created deal ID)
-- AUTO-CREATES: OrderApproval record with Status='Pending'
-- ============================================================================

-- ============================================================================
-- sp_UpdateDeal
-- ============================================================================
-- SERVICE: DealDataService.cs → UpdateDealAsync()
-- FRONTEND: DealsManagementView
-- BUTTON/ACTION: "Update Deal" button in Update tab
-- PURPOSE: Updates existing deal information
-- PARAMETERS: @DealID, @ClientName, @TotalAmount, @Status
-- ============================================================================

-- ============================================================================
-- sp_DeleteDeal
-- ============================================================================
-- SERVICE: DealDataService.cs → DeleteDealAsync()
-- FRONTEND: DealsManagementView
-- BUTTON/ACTION: "Delete Deal" button in Delete tab
-- PURPOSE: Removes a deal from the system
-- PARAMETERS: @DealID INT
-- ============================================================================

-- ============================================================================
-- sp_GetDealStatistics
-- ============================================================================
-- SERVICE: DealDataService.cs → GetDealStatisticsAsync()
-- FRONTEND: DealsManagementView
-- BUTTON/ACTION: Page Load (Dashboard stats panel)
-- PURPOSE: Provides summary statistics for deals
-- RETURNS: TotalDeals, PendingDeals, CompletedDeals, TotalValue
-- ============================================================================

-- ============================================================================
-- sp_GetDealsByStatus
-- ============================================================================
-- SERVICE: DealDataService.cs → GetDealsByStatusAsync()
-- FRONTEND: DealsManagementView
-- BUTTON/ACTION: Status filter dropdown
-- PURPOSE: Filters deals by their current status
-- PARAMETERS: @Status NVARCHAR(50)
-- ============================================================================

-- ============================================================================
-- sp_GetDealsByEmployee
-- ============================================================================
-- SERVICE: DealDataService.cs → GetDealsByEmployeeAsync()
-- FRONTEND: DealsManagementView, SalespersonDashboard
-- BUTTON/ACTION: Employee filter dropdown, "My Deals" view
-- PURPOSE: Filters deals by assigned employee
-- PARAMETERS: @EmployeeID INT
-- ============================================================================

-- ============================================================================
-- sp_GetDealItems
-- ============================================================================
-- SERVICE: DealDataService.cs → GetDealItemsAsync()
-- FRONTEND: DealsManagementView
-- BUTTON/ACTION: View Deal Items, Update Deal (loads items)
-- PURPOSE: Retrieves all product items associated with a deal
-- PARAMETERS: @DealID INT
-- RETURNS: ItemID, ProductName, Quantity, UnitPrice, TotalPrice
-- ============================================================================

-- ============================================================================
-- sp_AddDealItem
-- ============================================================================
-- SERVICE: DealDataService.cs → AddDealItemAsync()
-- FRONTEND: DealsManagementView
-- BUTTON/ACTION: "Add Deal" button (automatically adds items)
-- PURPOSE: Adds product line items to a deal
-- PARAMETERS: @DealID, @ProductID, @Quantity, @UnitPrice
-- ============================================================================

-- ============================================================================
-- sp_UpdateDealItem
-- ============================================================================
-- SERVICE: DealDataService.cs → UpdateDealItemAsync()
-- FRONTEND: DealsManagementView
-- BUTTON/ACTION: Update deal items during deal update
-- PURPOSE: Updates existing deal items
-- PARAMETERS: @DealItemID, @Quantity, @UnitPrice
-- ============================================================================

-- ============================================================================
-- sp_DeleteDealItem
-- ============================================================================
-- SERVICE: DealDataService.cs → DeleteDealItemAsync()
-- FRONTEND: DealsManagementView
-- BUTTON/ACTION: Remove item button in deal items list
-- PURPOSE: Removes a product item from a deal
-- PARAMETERS: @DealItemID INT
-- ============================================================================


/*
==============================================
RETAILER MANAGEMENT (7 Procedures)
==============================================
*/

-- ============================================================================
-- sp_GetAllRetailers
-- ============================================================================
-- SERVICE: RetailerDataService.cs → GetAllRetailersAsync()
-- FRONTEND: OwnerDashboard → Retailers → RetailersManagementView
-- BUTTON/ACTION: Page Load (Automatic)
-- PURPOSE: Retrieves all retailers for display in the retailers grid
-- RETURNS: RetailerID, RetailerName, ContactPerson, PhoneNumber, Email, Address
-- ============================================================================

-- ============================================================================
-- sp_GetRetailerById
-- ============================================================================
-- SERVICE: RetailerDataService.cs → GetRetailerByIdAsync()
-- FRONTEND: RetailersManagementView
-- BUTTON/ACTION: "View Details" button
-- PURPOSE: Fetches detailed information for a specific retailer
-- PARAMETERS: @RetailerID INT
-- ============================================================================

-- ============================================================================
-- sp_AddRetailer
-- ============================================================================
-- SERVICE: RetailerDataService.cs → AddRetailerAsync()
-- FRONTEND: RetailersManagementView, AddRetailerDialog
-- BUTTON/ACTION: "Add Retailer" button
-- PURPOSE: Creates a new retailer record
-- PARAMETERS: @RetailerName, @ContactPerson, @PhoneNumber, @Email, @Address
-- ============================================================================

-- ============================================================================
-- sp_UpdateRetailer
-- ============================================================================
-- SERVICE: RetailerDataService.cs → UpdateRetailerAsync()
-- FRONTEND: RetailersManagementView
-- BUTTON/ACTION: "Update Retailer" button in Update tab
-- PURPOSE: Updates existing retailer information
-- PARAMETERS: @RetailerID, @RetailerName, @ContactPerson, @PhoneNumber, @Email, @Address
-- ============================================================================

-- ============================================================================
-- sp_DeleteRetailer
-- ============================================================================
-- SERVICE: RetailerDataService.cs → DeleteRetailerAsync()
-- FRONTEND: RetailersManagementView
-- BUTTON/ACTION: "Delete Retailer" button in Delete tab
-- PURPOSE: Removes a retailer from the system
-- PARAMETERS: @RetailerID INT
-- ============================================================================

-- ============================================================================
-- sp_SearchRetailers
-- ============================================================================
-- SERVICE: RetailerDataService.cs → SearchRetailersAsync()
-- FRONTEND: RetailersManagementView
-- BUTTON/ACTION: Search box text change
-- PURPOSE: Filters retailers based on search criteria
-- PARAMETERS: @SearchTerm NVARCHAR(100)
-- SEARCHES: RetailerName, ContactPerson, PhoneNumber
-- ============================================================================

-- ============================================================================
-- sp_GetRetailerStatistics
-- ============================================================================
-- SERVICE: RetailerDataService.cs → GetRetailerStatisticsAsync()
-- FRONTEND: RetailersManagementView
-- BUTTON/ACTION: Page Load (Dashboard stats)
-- PURPOSE: Provides summary statistics for retailers
-- RETURNS: TotalRetailers, ActiveRetailers, TotalOrdersPlaced
-- ============================================================================


PRINT '✓ Sales Module procedures documented';
PRINT '✓ 13 Sales Order procedures';
PRINT '✓ 12 Deal procedures';
PRINT '✓ 7 Retailer procedures';
PRINT '✓ Total: 32 procedures with frontend button mappings';
GO
