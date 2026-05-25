using System;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Media;
using FactoryManagmentSystem.Services;

namespace FactoryManagmentSystem.Views
{
    /// <summary>
    /// Simple Revenue View - Date Range Based Revenue Tracking
    /// </summary>
    public partial class SimpleRevenueView : UserControl
    {
        private readonly SimpleRevenueService _revenueService;
        private DateTime _startDate;
        private DateTime _endDate;
        private string _currentTab = "sales";

        public SimpleRevenueView()
        {
            InitializeComponent();
            _revenueService = new SimpleRevenueService();
            InitializeView();
        }

        private async void InitializeView()
        {
            // Default to current month
            var today = DateTime.Today;
            _startDate = new DateTime(today.Year, today.Month, 1);
            _endDate = today;
            
            dpStartDate.SelectedDate = _startDate;
            dpEndDate.SelectedDate = _endDate;

            // AUTO-PAY all past month salaries on view load
            await AutoPayPastSalariesAsync();

            // Load initial data
            LoadDataAsync();
        }

        /// <summary>
        /// Automatically pay all past month salaries (from Sep 2025)
        /// </summary>
        private async Task AutoPayPastSalariesAsync()
        {
            try
            {
                var (paymentsAdded, monthlySalary, empCount) = await _revenueService.AutoPayPastSalariesAsync();
                
                if (paymentsAdded > 0)
                {
                    System.Diagnostics.Debug.WriteLine($"Auto-paid {paymentsAdded} months of salaries");
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error auto-paying salaries: {ex.Message}");
            }
        }

        private async void LoadDataAsync()
        {
            try
            {
                // Get summary
                var summary = await _revenueService.GetRevenueSummaryAsync(_startDate, _endDate);
                UpdateSummaryCards(summary);

                // Get salary status for current month
                var salaryStatus = await _revenueService.GetSalaryStatusAsync(_endDate.Month, _endDate.Year);
                UpdateSalaryStatus(salaryStatus);

                // Load tab data
                await LoadTabDataAsync();
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error loading data: {ex.Message}", "Error", 
                    MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void UpdateSummaryCards(RevenueSummaryModel summary)
        {
            // Income
            txtTotalIncome.Text = $"Rs. {summary.TotalIncome:N0}";
            txtSalesCount.Text = $"Sales: Rs.{summary.SalesIncome:N0}";
            txtDealsCount.Text = $"Deals: Rs.{summary.DealIncome:N0}";

            // Expenses
            txtTotalExpense.Text = $"Rs. {summary.TotalExpense:N0}";
            txtExpenseBreakdown.Text = $"Raw: Rs.{summary.RawMaterialCost:N0} | Misc: Rs.{summary.MiscExpense:N0} | Sal: Rs.{summary.SalaryExpense:N0}";

            // Profit
            txtNetProfit.Text = $"Rs. {summary.NetProfit:N0}";
            txtProfitMargin.Text = $"Margin: {summary.ProfitMargin:F1}%";
            
            // Change profit color based on value
            if (summary.NetProfit >= 0)
            {
                txtNetProfit.Foreground = new SolidColorBrush(Color.FromRgb(76, 175, 80)); // Green
            }
            else
            {
                txtNetProfit.Foreground = new SolidColorBrush(Color.FromRgb(244, 67, 54)); // Red
            }
        }

        private void UpdateSalaryStatus(SalaryStatusModel status)
        {
            txtSalaryStatus.Text = status.IsPaid ? "✅ Paid" : "⏳ Pending";
            txtSalaryAmount.Text = $"Rs. {status.TotalSalary:N0} ({status.EmployeeCount} employees)";
            btnPaySalary.IsEnabled = !status.IsPaid;
            btnPaySalary.Content = status.IsPaid ? "✅ Paid" : "Pay Salary";
        }

        private async System.Threading.Tasks.Task LoadTabDataAsync()
        {
            try
            {
                // Hide all grids
                dgSalesOrders.Visibility = Visibility.Collapsed;
                dgDeals.Visibility = Visibility.Collapsed;
                dgPurchases.Visibility = Visibility.Collapsed;
                dgExpenses.Visibility = Visibility.Collapsed;
                txtNoData.Visibility = Visibility.Collapsed;

                switch (_currentTab)
                {
                    case "sales":
                        var sales = await _revenueService.GetSalesOrdersAsync(_startDate, _endDate);
                        dgSalesOrders.ItemsSource = sales;
                        dgSalesOrders.Visibility = Visibility.Visible;
                        txtGridTitle.Text = $"📦 Sales Orders ({sales.Count})";
                        if (sales.Count == 0) txtNoData.Visibility = Visibility.Visible;
                        break;

                    case "deals":
                        var deals = await _revenueService.GetDealsAsync(_startDate, _endDate);
                        dgDeals.ItemsSource = deals;
                        dgDeals.Visibility = Visibility.Visible;
                        txtGridTitle.Text = $"🤝 Deals ({deals.Count})";
                        if (deals.Count == 0) txtNoData.Visibility = Visibility.Visible;
                        break;

                    case "purchases":
                        var purchases = await _revenueService.GetPurchasesAsync(_startDate, _endDate);
                        dgPurchases.ItemsSource = purchases;
                        dgPurchases.Visibility = Visibility.Visible;
                        txtGridTitle.Text = $"🛒 Raw Material Purchases ({purchases.Count})";
                        if (purchases.Count == 0) txtNoData.Visibility = Visibility.Visible;
                        break;

                    case "expenses":
                        var expenses = await _revenueService.GetExpensesAsync(_startDate, _endDate);
                        dgExpenses.ItemsSource = expenses;
                        dgExpenses.Visibility = Visibility.Visible;
                        txtGridTitle.Text = $"💸 Misc Expenses ({expenses.Count})";
                        if (expenses.Count == 0) txtNoData.Visibility = Visibility.Visible;
                        break;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error loading tab data: {ex.Message}");
            }
        }

        #region Event Handlers

        private void Calculate_Click(object sender, RoutedEventArgs e)
        {
            if (dpStartDate.SelectedDate == null || dpEndDate.SelectedDate == null)
            {
                MessageBox.Show("Please select both start and end dates.", "Validation", 
                    MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }

            _startDate = dpStartDate.SelectedDate.Value;
            _endDate = dpEndDate.SelectedDate.Value;

            if (_startDate > _endDate)
            {
                MessageBox.Show("Start date cannot be after end date.", "Validation", 
                    MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }

            LoadDataAsync();
        }

        private void SetTabActive(string tab)
        {
            _currentTab = tab;
            
            // Reset all tab styles
            tabSales.BorderBrush = Brushes.Transparent;
            tabSales.Foreground = new SolidColorBrush(Color.FromRgb(102, 102, 102));
            tabDeals.BorderBrush = Brushes.Transparent;
            tabDeals.Foreground = new SolidColorBrush(Color.FromRgb(102, 102, 102));
            tabPurchases.BorderBrush = Brushes.Transparent;
            tabPurchases.Foreground = new SolidColorBrush(Color.FromRgb(102, 102, 102));
            tabExpenses.BorderBrush = Brushes.Transparent;
            tabExpenses.Foreground = new SolidColorBrush(Color.FromRgb(102, 102, 102));

            // Highlight active tab
            var activeColor = new SolidColorBrush(Color.FromRgb(33, 150, 243));
            switch (tab)
            {
                case "sales":
                    tabSales.BorderBrush = activeColor;
                    tabSales.Foreground = activeColor;
                    break;
                case "deals":
                    tabDeals.BorderBrush = activeColor;
                    tabDeals.Foreground = activeColor;
                    break;
                case "purchases":
                    tabPurchases.BorderBrush = activeColor;
                    tabPurchases.Foreground = activeColor;
                    break;
                case "expenses":
                    tabExpenses.BorderBrush = activeColor;
                    tabExpenses.Foreground = activeColor;
                    break;
            }
        }

        private async void TabSales_Click(object sender, RoutedEventArgs e)
        {
            SetTabActive("sales");
            await LoadTabDataAsync();
        }

        private async void TabDeals_Click(object sender, RoutedEventArgs e)
        {
            SetTabActive("deals");
            await LoadTabDataAsync();
        }

        private async void TabPurchases_Click(object sender, RoutedEventArgs e)
        {
            SetTabActive("purchases");
            await LoadTabDataAsync();
        }

        private async void TabExpenses_Click(object sender, RoutedEventArgs e)
        {
            SetTabActive("expenses");
            await LoadTabDataAsync();
        }

        private async void PaySalary_Click(object sender, RoutedEventArgs e)
        {
            var monthName = new DateTime(_endDate.Year, _endDate.Month, 1).ToString("MMMM yyyy");
            var result = MessageBox.Show(
                $"Pay all employee salaries for {monthName}?\n\nThis will record the salary payment.",
                "Confirm Salary Payment",
                MessageBoxButton.YesNo,
                MessageBoxImage.Question);

            if (result == MessageBoxResult.Yes)
            {
                try
                {
                    var (success, totalAmount, empCount) = await _revenueService.PayMonthlySalaryAsync(_endDate.Month, _endDate.Year);
                    
                    if (success)
                    {
                        MessageBox.Show($"✅ Salaries paid successfully!\n\nTotal: Rs. {totalAmount:N0}\nEmployees: {empCount}", 
                            "Success", MessageBoxButton.OK, MessageBoxImage.Information);
                        LoadDataAsync();
                    }
                    else
                    {
                        MessageBox.Show("Salaries were already paid for this month.", "Info", 
                            MessageBoxButton.OK, MessageBoxImage.Information);
                    }
                }
                catch (Exception ex)
                {
                    MessageBox.Show($"Error: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
                }
            }
        }

        private async void AddPurchase_Click(object sender, RoutedEventArgs e)
        {
            var dialog = new NewPurchaseDialog();
            if (dialog.ShowDialog() == true)
            {
                try
                {
                    await _revenueService.AddPurchaseAsync(
                        dialog.MaterialName,
                        dialog.PurchaseDate,
                        dialog.Quantity,
                        dialog.Unit,
                        dialog.UnitPrice,
                        dialog.SupplierName
                    );
                    
                    MessageBox.Show("✅ Purchase added successfully!", "Success", 
                        MessageBoxButton.OK, MessageBoxImage.Information);
                    LoadDataAsync();
                }
                catch (Exception ex)
                {
                    MessageBox.Show($"Error: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
                }
            }
        }

        private async void AddExpense_Click(object sender, RoutedEventArgs e)
        {
            var dialog = new NewExpenseDialog();
            if (dialog.ShowDialog() == true)
            {
                try
                {
                    await _revenueService.AddExpenseAsync(
                        dialog.ExpenseDate,
                        dialog.Amount,
                        dialog.Category,
                        dialog.Description,
                        dialog.PaidTo
                    );
                    
                    MessageBox.Show("✅ Expense added successfully!", "Success", 
                        MessageBoxButton.OK, MessageBoxImage.Information);
                    LoadDataAsync();
                }
                catch (Exception ex)
                {
                    MessageBox.Show($"Error: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
                }
            }
        }

        #endregion
    }
}
