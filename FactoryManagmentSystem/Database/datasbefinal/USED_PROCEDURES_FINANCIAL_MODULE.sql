-- =============================================
-- USED PROCEDURES: FINANCIAL MODULE
-- Only procedures actively used in the project
-- With Frontend Button/Action Mapping
-- Generated: December 17, 2025
-- =============================================

/*
==============================================
REVENUE & FINANCIAL REPORTING (14 Procedures)
==============================================
*/

-- ============================================================================
-- sp_CalculateMonthlyRevenue
-- ============================================================================
-- SERVICE: RevenueService.cs → CalculateMonthlyRevenueAsync()
-- FRONTEND: OwnerDashboard
-- BUTTON/ACTION: Auto-triggered OR "Calculate Revenue" button
-- PURPOSE: Calculates complete P&L statement for a specific month
-- PARAMETERS: @Month INT, @Year INT
-- 
-- CALCULATION BREAKDOWN:
--   1. SalesIncome = SUM(SalesOrder.TotalAmount WHERE Status='Delivered' AND MONTH/YEAR match)
--   2. DealIncome = SUM(Deal.TotalAmount WHERE Status='Delivered' AND MONTH/YEAR match)
--   3. TotalIncome = SalesIncome + DealIncome
--   4. TotalSalaries = SUM(SalaryPayment.TotalAmount WHERE Month/Year match)
--   5. RawMaterialCost = SUM(RawMaterialPurchase.TotalAmount WHERE Month/Year match)
--   6. MiscExpense = SUM(MiscExpense.Amount WHERE Month/Year match)
--   7. TotalExpense = TotalSalaries + RawMaterialCost + MiscExpense
--   8. NetProfit = TotalIncome - TotalExpense
-- 
-- AUTO-ACTIONS:
--   - Inserts/Updates MonthlyRevenue record
--   - Sets CalculatedDate = NOW
-- 
-- TRIGGERS:
--   - Called when SalesOrder/Deal status changes to 'Delivered'
--   - Called when salary payment is recorded
--   - Called when material purchase is made
--   - Called manually from Owner Dashboard
-- ============================================================================

-- ============================================================================
-- sp_GetMonthlyRevenue
-- ============================================================================
-- SERVICE: RevenueService.cs → GetMonthlyRevenueAsync()
-- FRONTEND: OwnerDashboard → Revenue Reports
-- BUTTON/ACTION: Page Load (loads current month), Month selection dropdown
-- PURPOSE: Retrieves revenue data for a specific month
-- PARAMETERS: @Month INT, @Year INT
-- RETURNS: SalesIncome, DealIncome, TotalIncome, TotalSalaries, RawMaterialCost, 
--          MiscExpense, TotalExpense, NetProfit, SalariesPaid (BIT)
-- ============================================================================

-- ============================================================================
-- sp_GetYearlyRevenue
-- ============================================================================
-- SERVICE: RevenueService.cs → GetYearlyRevenueAsync()
-- FRONTEND: OwnerDashboard → Annual Financial Report
-- BUTTON/ACTION: "Yearly Report" button, Year selection dropdown
-- PURPOSE: Aggregates revenue data for entire year
-- PARAMETERS: @Year INT
-- RETURNS: Month-by-month breakdown + annual totals
-- USED FOR: Annual revenue chart, year-end reporting
-- ============================================================================

-- ============================================================================
-- sp_GetRevenueByDateRange
-- ============================================================================
-- SERVICE: RevenueService.cs → GetRevenueByDateRangeAsync()
-- FRONTEND: OwnerDashboard → Custom Date Range Report
-- BUTTON/ACTION: "Custom Date Range" → Date picker → "Generate Report" button
-- PURPOSE: Calculates revenue for any date range
-- PARAMETERS: @StartDate DATE, @EndDate DATE
-- RETURNS: TotalIncome, TotalExpense, NetProfit for the period
-- ============================================================================

-- ============================================================================
-- sp_GetTopRevenueProducts
-- ============================================================================
-- SERVICE: RevenueService.cs → GetTopRevenueProductsAsync()
-- FRONTEND: OwnerDashboard → Revenue Analysis
-- BUTTON/ACTION: "Top Products" widget
-- PURPOSE: Identifies products generating the most revenue
-- PARAMETERS: @TopN INT (default 10), @StartDate DATE, @EndDate DATE
-- RETURNS: ProductName, TotalQuantitySold, TotalRevenue, OrderCount
-- SORTED BY: TotalRevenue DESC
-- USED FOR: Product performance analysis
-- ============================================================================

-- ============================================================================
-- sp_GetRevenueByRetailer
-- ============================================================================
-- SERVICE: RevenueService.cs → GetRevenueByRetailerAsync()
-- FRONTEND: OwnerDashboard → Customer Analysis
-- BUTTON/ACTION: "Revenue by Customer" report
-- PURPOSE: Shows revenue generated from each retailer
-- PARAMETERS: @StartDate DATE, @EndDate DATE
-- RETURNS: RetailerName, OrderCount, TotalRevenue, AvgOrderValue
-- SORTED BY: TotalRevenue DESC
-- USED FOR: Key customer identification
-- ============================================================================

-- ============================================================================
-- sp_GetRevenueBySalesperson
-- ============================================================================
-- SERVICE: RevenueService.cs → GetRevenueBySalespersonAsync()
-- FRONTEND: OwnerDashboard, SalesManagerDashboard → Sales Performance
-- BUTTON/ACTION: "Salesperson Performance" report
-- PURPOSE: Shows revenue generated by each salesperson
-- PARAMETERS: @StartDate DATE, @EndDate DATE
-- RETURNS: SalespersonName, OrderCount, DealCount, TotalRevenue, Commission
-- SORTED BY: TotalRevenue DESC
-- USED FOR: Sales team performance evaluation, commission calculation
-- ============================================================================

-- ============================================================================
-- sp_GetProfitMarginAnalysis
-- ============================================================================
-- SERVICE: RevenueService.cs → GetProfitMarginAnalysisAsync()
-- FRONTEND: OwnerDashboard → Financial Analysis
-- BUTTON/ACTION: "Profit Margin Analysis" button
-- PURPOSE: Calculates profit margins for products
-- PARAMETERS: @StartDate DATE, @EndDate DATE
-- RETURNS: ProductName, TotalRevenue, TotalCost (materials), ProfitMargin
-- CALCULATION: ProfitMargin = ((Revenue - Cost) / Revenue) * 100
-- USED FOR: Pricing strategy and cost optimization
-- ============================================================================

-- ============================================================================
-- sp_GetExpenseBreakdown
-- ============================================================================
-- SERVICE: RevenueService.cs → GetExpenseBreakdownAsync()
-- FRONTEND: OwnerDashboard → Expense Reports
-- BUTTON/ACTION: "Expense Breakdown" chart
-- PURPOSE: Shows expense distribution by category
-- PARAMETERS: @Month INT, @Year INT
-- RETURNS: CategoryName, Amount, Percentage
-- CATEGORIES: Salaries, Raw Materials, Utilities, Rent, Maintenance, Other
-- USED FOR: Expense pie chart
-- ============================================================================

-- ============================================================================
-- sp_GetCashFlowStatement
-- ============================================================================
-- SERVICE: RevenueService.cs → GetCashFlowStatementAsync()
-- FRONTEND: OwnerDashboard → Financial Reports
-- BUTTON/ACTION: "Cash Flow Statement" button
-- PURPOSE: Shows monthly cash inflows and outflows
-- PARAMETERS: @StartDate DATE, @EndDate DATE
-- RETURNS: Month, CashInflow (income), CashOutflow (expenses), NetCashFlow
-- USED FOR: Liquidity analysis
-- ============================================================================

-- ============================================================================
-- sp_GetFinancialSummary
-- ============================================================================
-- SERVICE: RevenueService.cs → GetFinancialSummaryAsync()
-- FRONTEND: OwnerDashboard
-- BUTTON/ACTION: Page Load (Dashboard summary cards)
-- PURPOSE: Provides high-level financial overview
-- RETURNS: CurrentMonthRevenue, CurrentMonthProfit, YTDRevenue, YTDProfit, 
--          GrowthRate, TopProduct, TopRetailer
-- ============================================================================

-- ============================================================================
-- sp_ComparePeriodRevenue
-- ============================================================================
-- SERVICE: RevenueService.cs → ComparePeriodRevenueAsync()
-- FRONTEND: OwnerDashboard → Comparative Analysis
-- BUTTON/ACTION: "Period Comparison" → Select two date ranges
-- PURPOSE: Compares revenue between two time periods
-- PARAMETERS: @Period1Start DATE, @Period1End DATE, @Period2Start DATE, @Period2End DATE
-- RETURNS: Metric, Period1Value, Period2Value, Change, ChangePercent
-- USED FOR: Month-over-month, year-over-year comparisons
-- ============================================================================

-- ============================================================================
-- sp_GetRevenueGrowthTrend
-- ============================================================================
-- SERVICE: RevenueService.cs → GetRevenueGrowthTrendAsync()
-- FRONTEND: OwnerDashboard → Growth Analysis
-- BUTTON/ACTION: "Revenue Trend" line chart
-- PURPOSE: Shows revenue growth trend over time
-- PARAMETERS: @Months INT (number of months to analyze)
-- RETURNS: Month, Revenue, Growth (vs previous month), TrendDirection
-- USED FOR: Revenue trend line chart
-- ============================================================================

-- ============================================================================
-- sp_GetOutstandingPayments
-- ============================================================================
-- SERVICE: RevenueService.cs → GetOutstandingPaymentsAsync()
-- FRONTEND: OwnerDashboard → Accounts Receivable
-- BUTTON/ACTION: "Outstanding Payments" widget
-- PURPOSE: Shows orders delivered but not paid yet
-- RETURNS: OrderID, CustomerName, TotalAmount, DeliveredDate, DaysOutstanding
-- FILTER: Status='Delivered' but PaymentReceived=0
-- ALERT: Highlights overdue payments (> 30 days) in red
-- ============================================================================


/*
==============================================
SALARY MANAGEMENT (5 Procedures)
==============================================
*/

-- ============================================================================
-- sp_PayMonthlySalaries
-- ============================================================================
-- SERVICE: RevenueService.cs → PayMonthlySalariesAsync()
-- FRONTEND: OwnerDashboard → Payroll
-- BUTTON/ACTION: "Pay Salaries" button
-- PURPOSE: Processes monthly salary payment for all active employees
-- PARAMETERS: @PaymentMonth INT, @PaymentYear INT
-- 
-- AUTO-ACTIONS (Transaction-based):
--   1. Calculate TotalSalary = SUM(Salary) for all IsActive=1 employees
--   2. Count EmployeesPaid = COUNT(*) of active employees
--   3. Insert SalaryPayment record
--   4. Update MonthlyRevenue.TotalSalaries
--   5. Set MonthlyRevenue.SalariesPaid = 1
-- 
-- VALIDATION:
--   - Prevents duplicate payment for same month/year
--   - Requires confirmation before execution
-- 
-- COMPLEX: Multi-step transaction with rollback on error
-- ============================================================================

-- ============================================================================
-- sp_GetSalaryPaymentHistory
-- ============================================================================
-- SERVICE: RevenueService.cs → GetSalaryPaymentHistoryAsync()
-- FRONTEND: OwnerDashboard → Payroll History
-- BUTTON/ACTION: "Salary Payment History" tab
-- PURPOSE: Shows all past salary payments
-- RETURNS: PaymentID, PaymentMonth, PaymentYear, TotalAmount, EmployeesPaid, 
--          PaymentDate
-- SORTED BY: PaymentDate DESC
-- ============================================================================

-- ============================================================================
-- sp_GetUnpaidSalaryMonths
-- ============================================================================
-- SERVICE: RevenueService.cs → GetUnpaidSalaryMonthsAsync()
-- FRONTEND: OwnerDashboard
-- BUTTON/ACTION: Page Load (alert widget for unpaid months)
-- PURPOSE: Identifies months where salaries haven't been paid
-- RETURNS: Month, Year, ExpectedAmount, Status='Unpaid'
-- ALERT: Shows red badge if any months are unpaid
-- CALCULATION: Checks MonthlyRevenue.SalariesPaid = 0 for past months
-- ============================================================================

-- ============================================================================
-- sp_GetEmployeeSalaryDetails
-- ============================================================================
-- SERVICE: EmployeeDataService.cs → GetEmployeeSalaryDetailsAsync()
-- FRONTEND: Employee Details View
-- BUTTON/ACTION: "View Salary Details" button
-- PURPOSE: Shows salary information for a specific employee
-- PARAMETERS: @EmployeeID INT
-- RETURNS: BaseSalary, Allowances, Deductions, NetSalary, PaymentHistory
-- ============================================================================

-- ============================================================================
-- sp_UpdateEmployeeSalary
-- ============================================================================
-- SERVICE: EmployeeDataService.cs → UpdateEmployeeSalaryAsync()
-- FRONTEND: Employee Management View
-- BUTTON/ACTION: "Update Salary" button
-- PURPOSE: Changes an employee's salary amount
-- PARAMETERS: @EmployeeID INT, @NewSalary DECIMAL
-- AUTO-ACTIONS: Records salary change history with date and reason
-- IMPACT: Affects future salary payments and department budget calculations
-- ============================================================================


/*
==============================================
EXPENSE MANAGEMENT (7 Procedures)
==============================================
*/

-- ============================================================================
-- sp_AddMiscExpense
-- ============================================================================
-- SERVICE: RevenueService.cs → AddMiscExpenseAsync()
-- FRONTEND: OwnerDashboard → Expenses → Add Expense
-- BUTTON/ACTION: "Add Expense" button
-- PURPOSE: Records a miscellaneous expense
-- PARAMETERS: @ExpenseCategory NVARCHAR(50), @Amount DECIMAL, @Description NVARCHAR(500), 
--             @ExpenseDate DATE
-- CATEGORIES: Utilities, Rent, Maintenance, Transportation, Marketing, Other
-- AUTO-ACTIONS: 
--   - Inserts MiscExpense record
--   - Updates MonthlyRevenue.MiscExpense for the month
-- ============================================================================

-- ============================================================================
-- sp_GetAllMiscExpenses
-- ============================================================================
-- SERVICE: RevenueService.cs → GetAllMiscExpensesAsync()
-- FRONTEND: OwnerDashboard → Expenses
-- BUTTON/ACTION: Page Load (Automatic)
-- PURPOSE: Retrieves all miscellaneous expenses
-- RETURNS: ExpenseID, Category, Amount, Description, ExpenseDate
-- SORTED BY: ExpenseDate DESC
-- ============================================================================

-- ============================================================================
-- sp_GetMiscExpensesByCategory
-- ============================================================================
-- SERVICE: RevenueService.cs → GetMiscExpensesByCategoryAsync()
-- FRONTEND: OwnerDashboard → Expense Analysis
-- BUTTON/ACTION: Category filter dropdown
-- PURPOSE: Filters expenses by category
-- PARAMETERS: @Category NVARCHAR(50)
-- RETURNS: Expenses matching the selected category
-- ============================================================================

-- ============================================================================
-- sp_GetMiscExpensesByDateRange
-- ============================================================================
-- SERVICE: RevenueService.cs → GetMiscExpensesByDateRangeAsync()
-- FRONTEND: OwnerDashboard → Expense Reports
-- BUTTON/ACTION: Date range picker → "Filter" button
-- PURPOSE: Shows expenses for a specific date range
-- PARAMETERS: @StartDate DATE, @EndDate DATE
-- RETURNS: ExpenseID, Category, Amount, Description, ExpenseDate, TotalAmount (SUM)
-- ============================================================================

-- ============================================================================
-- sp_UpdateMiscExpense
-- ============================================================================
-- SERVICE: RevenueService.cs → UpdateMiscExpenseAsync()
-- FRONTEND: Expense Management View
-- BUTTON/ACTION: "Update Expense" button
-- PURPOSE: Modifies an existing expense record
-- PARAMETERS: @ExpenseID INT, @Category, @Amount, @Description, @ExpenseDate
-- AUTO-ACTIONS: Recalculates MonthlyRevenue if month/amount changed
-- ============================================================================

-- ============================================================================
-- sp_DeleteMiscExpense
-- ============================================================================
-- SERVICE: RevenueService.cs → DeleteMiscExpenseAsync()
-- FRONTEND: Expense Management View
-- BUTTON/ACTION: "Delete Expense" button
-- PURPOSE: Removes an expense record
-- PARAMETERS: @ExpenseID INT
-- AUTO-ACTIONS: Updates MonthlyRevenue.MiscExpense (deduct deleted amount)
-- ============================================================================

-- ============================================================================
-- sp_GetExpenseStatistics
-- ============================================================================
-- SERVICE: RevenueService.cs → GetExpenseStatisticsAsync()
-- FRONTEND: OwnerDashboard → Expense Stats Panel
-- BUTTON/ACTION: Page Load (Dashboard stats)
-- PURPOSE: Provides summary statistics for expenses
-- PARAMETERS: @StartDate DATE, @EndDate DATE
-- RETURNS: TotalExpenses, ExpenseByCategory, AvgMonthlyExpense, HighestCategory
-- USED FOR: Expense dashboard cards and charts
-- ============================================================================


/*
==============================================
DASHBOARD STATISTICS (6 Procedures)
==============================================
*/

-- ============================================================================
-- sp_GetOwnerDashboardStatistics
-- ============================================================================
-- SERVICE: OwnerDashboardService.cs → GetDashboardStatisticsAsync()
-- FRONTEND: OwnerDashboard
-- BUTTON/ACTION: Page Load (Automatic)
-- PURPOSE: Aggregates all key metrics for Owner Dashboard
-- RETURNS: 
--   - TotalEmployees, ActiveEmployees
--   - TotalSalesOrders, PendingSalesOrders
--   - TotalDeals, PendingDeals
--   - TotalRevenue (current month)
--   - NetProfit (current month)
--   - PendingApprovals
--   - PendingDeliveries
--   - LowStockItems
-- COMPLEX: Aggregates data from multiple tables
-- ============================================================================

-- ============================================================================
-- sp_GetSalesManagerDashboardStatistics
-- ============================================================================
-- SERVICE: SalesManagerDashboardService.cs → GetDashboardStatisticsAsync()
-- FRONTEND: SalesManagerDashboard
-- BUTTON/ACTION: Page Load (Automatic)
-- PURPOSE: Sales-focused metrics for Sales Manager
-- RETURNS:
--   - PendingApprovals (count)
--   - TotalSalesOrders, CompletedSalesOrders
--   - TotalDeals, CompletedDeals
--   - RevenueThisMonth
--   - TopSalesperson
--   - ConversionRate
-- ============================================================================

-- ============================================================================
-- sp_GetProductionManagerDashboardStatistics
-- ============================================================================
-- SERVICE: ProductionManagerDashboardService.cs → GetDashboardStatisticsAsync()
-- FRONTEND: ProductionManagerDashboard
-- BUTTON/ACTION: Page Load (Automatic)
-- PURPOSE: Production-focused metrics
-- RETURNS:
--   - PendingProductionOrders
--   - InProgressProductions
--   - CompletedProductions
--   - UnassignedOrders
--   - TailorUtilization
--   - LowStockMaterials
-- ============================================================================

-- ============================================================================
-- sp_GetSalespersonDashboardStatistics
-- ============================================================================
-- SERVICE: SalespersonDashboardService.cs → GetDashboardStatisticsAsync()
-- FRONTEND: SalespersonDashboard
-- BUTTON/ACTION: Page Load (Automatic)
-- PURPOSE: Individual salesperson performance metrics
-- PARAMETERS: @SalespersonID INT (logged-in user)
-- RETURNS:
--   - MyOrders (count)
--   - MyDeals (count)
--   - MyRevenue (this month)
--   - MyCommission
--   - PendingApprovals (my orders)
--   - CompletionRate
-- ============================================================================

-- ============================================================================
-- sp_GetTailorDashboardStatistics
-- ============================================================================
-- SERVICE: TailorDashboardService.cs → GetDashboardStatisticsAsync()
-- FRONTEND: TailorDashboard
-- BUTTON/ACTION: Page Load (Automatic)
-- PURPOSE: Tailor workload and performance metrics
-- PARAMETERS: @TailorID INT (logged-in user)
-- RETURNS:
--   - MyAssignedTasks
--   - MyInProgressTasks
--   - MyCompletedTasks
--   - TasksCompletedThisWeek
--   - TasksCompletedThisMonth
--   - CompletionRate
-- ============================================================================

-- ============================================================================
-- sp_GetDeliveryPersonDashboardStatistics
-- ============================================================================
-- SERVICE: DeliveryPersonDashboardService.cs → GetDashboardStatisticsAsync()
-- FRONTEND: DeliveryPersonDashboard
-- BUTTON/ACTION: Page Load (Automatic)
-- PURPOSE: Delivery person performance metrics
-- PARAMETERS: @DeliveryPersonID INT (logged-in user)
-- RETURNS:
--   - MyPendingDeliveries
--   - MyInTransitDeliveries
--   - MyCompletedDeliveries (this month)
--   - OnTimeDeliveryRate
--   - TotalDeliveriesAllTime
-- ============================================================================


PRINT '✓ Financial Module procedures documented';
PRINT '✓ 14 Revenue & Reporting procedures';
PRINT '✓ 5 Salary Management procedures';
PRINT '✓ 7 Expense Management procedures';
PRINT '✓ 6 Dashboard Statistics procedures';
PRINT '✓ Total: 32 procedures with frontend button mappings';
GO
