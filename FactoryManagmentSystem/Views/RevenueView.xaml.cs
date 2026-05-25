using System;
using System.Collections.Generic;
using System.Linq;
using System.Windows;
using System.Windows.Controls;
using FactoryManagmentSystem.Services;

namespace FactoryManagmentSystem.Views
{
    /// <summary>
    /// Interaction logic for RevenueView.xaml
    /// </summary>
    public partial class RevenueView : UserControl
    {
        private readonly RevenueService _revenueService;
        private List<MonthlyRevenueModel> _yearlyData = new();
        private int _selectedYear;
        private int _selectedMonth;

        public RevenueView()
        {
            InitializeComponent();
            _revenueService = new RevenueService();
            InitializeAsync();
        }

        private async void InitializeAsync()
        {
            try
            {
                // Set default selections
                _selectedYear = DateTime.Now.Year;
                _selectedMonth = DateTime.Now.Month;

                // Load available years
                var years = await _revenueService.GetAvailableYearsAsync();
                cmbYear.ItemsSource = years;
                cmbYear.SelectedItem = _selectedYear;

                // Set current month in combo
                cmbMonth.SelectedIndex = _selectedMonth - 1;

                // Update current month display
                txtCurrentMonth.Text = $"Current: {DateTime.Now:MMMM}";

                // Load data
                await LoadYearlyDataAsync();
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error initializing: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private async System.Threading.Tasks.Task LoadYearlyDataAsync()
        {
            try
            {
                // Get yearly revenue data
                _yearlyData = await _revenueService.GetYearlyRevenueAsync(_selectedYear);

                // Update DataGrid
                dgMonthlyRevenue.ItemsSource = _yearlyData;

                // Update summary cards
                await UpdateSummaryCardsAsync();

                // Update selected month details
                UpdateSelectedMonthDetails();
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error loading data: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private async System.Threading.Tasks.Task UpdateSummaryCardsAsync()
        {
            try
            {
                var summary = await _revenueService.GetYearlySummaryAsync(_selectedYear);

                // Total Income
                txtTotalIncome.Text = $"Rs. {summary.TotalIncome:N0}";
                txtIncomeBreakdown.Text = $"Sales: Rs.{summary.TotalSalesIncome:N0} | Deals: Rs.{summary.TotalDealIncome:N0}";

                // Total Expenses
                txtTotalExpense.Text = $"Rs. {summary.TotalExpense:N0}";
                txtExpenseBreakdown.Text = $"Sal: Rs.{summary.TotalSalaries:N0} | Raw: Rs.{summary.TotalRawMaterial:N0} | Misc: Rs.{summary.TotalMisc:N0}";

                // Net Profit
                txtNetProfit.Text = $"Rs. {summary.NetProfit:N0}";
                double margin = summary.TotalIncome > 0 ? (double)(summary.NetProfit / summary.TotalIncome) * 100 : 0;
                txtProfitPercent.Text = $"Margin: {margin:F1}%";
                txtNetProfit.Foreground = summary.NetProfit >= 0 
                    ? new System.Windows.Media.SolidColorBrush(System.Windows.Media.Color.FromRgb(76, 175, 80))
                    : new System.Windows.Media.SolidColorBrush(System.Windows.Media.Color.FromRgb(244, 67, 54));

                // Months count
                txtMonthsCount.Text = $"{summary.MonthsWithData} / 12";
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error updating summary: {ex.Message}");
            }
        }

        private void UpdateSelectedMonthDetails()
        {
            var monthData = _yearlyData.FirstOrDefault(m => m.Month == _selectedMonth);

            if (monthData != null)
            {
                // Income
                txtMonthSales.Text = $"Rs. {monthData.SalesIncome:N0}";
                txtMonthDeals.Text = $"Rs. {monthData.DealIncome:N0}";
                txtMonthTotalIncome.Text = $"Rs. {monthData.TotalIncome:N0}";

                // Expenses
                txtMonthSalaries.Text = $"Rs. {monthData.TotalSalaries:N0}";
                txtMonthRawMaterial.Text = $"Rs. {monthData.RawMaterialCost:N0}";
                txtMonthMisc.Text = $"Rs. {monthData.MiscExpense:N0}";
                txtMonthTotalExpense.Text = $"Rs. {monthData.TotalExpense:N0}";

                // Summary
                txtSalaryStatus.Text = monthData.SalaryStatus;
                txtSelectedMonth.Text = $"{monthData.MonthName} {_selectedYear}";
                txtMonthProfit.Text = $"Rs. {monthData.NetProfit:N0}";
                txtMonthProfit.Foreground = monthData.NetProfit >= 0
                    ? new System.Windows.Media.SolidColorBrush(System.Windows.Media.Color.FromRgb(76, 175, 80))
                    : new System.Windows.Media.SolidColorBrush(System.Windows.Media.Color.FromRgb(244, 67, 54));
                txtMonthNotes.Text = !string.IsNullOrEmpty(monthData.Notes) ? $"Notes: {monthData.Notes}" : "";

                // Update pay salaries button
                btnPaySalaries.IsEnabled = !monthData.SalariesPaid;
                btnPaySalaries.Content = monthData.SalariesPaid ? "✅ Salaries Paid" : "💳 Pay Salaries";
            }
            else
            {
                // No data for this month
                txtMonthSales.Text = "Rs. 0";
                txtMonthDeals.Text = "Rs. 0";
                txtMonthTotalIncome.Text = "Rs. 0";
                txtMonthSalaries.Text = "Rs. 0";
                txtMonthRawMaterial.Text = "Rs. 0";
                txtMonthMisc.Text = "Rs. 0";
                txtMonthTotalExpense.Text = "Rs. 0";
                txtSalaryStatus.Text = "⏳ Pending";
                txtSelectedMonth.Text = $"{System.Globalization.CultureInfo.CurrentCulture.DateTimeFormat.GetMonthName(_selectedMonth)} {_selectedYear}";
                txtMonthProfit.Text = "Rs. 0";
                txtMonthNotes.Text = "No data for this month. Click 'Calculate Month' to generate.";
                btnPaySalaries.IsEnabled = true;
                btnPaySalaries.Content = "💳 Pay Salaries";
            }
        }

        #region Event Handlers

        private async void cmbYear_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            if (cmbYear.SelectedItem != null)
            {
                _selectedYear = (int)cmbYear.SelectedItem;
                await LoadYearlyDataAsync();
            }
        }

        private void cmbMonth_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            if (cmbMonth.SelectedItem is ComboBoxItem item && item.Tag != null)
            {
                _selectedMonth = int.Parse(item.Tag.ToString()!);
                UpdateSelectedMonthDetails();
            }
        }

        private void dgMonthlyRevenue_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            if (dgMonthlyRevenue.SelectedItem is MonthlyRevenueModel selected)
            {
                _selectedMonth = selected.Month;
                cmbMonth.SelectedIndex = _selectedMonth - 1;
                UpdateSelectedMonthDetails();
            }
        }

        private async void RefreshButton_Click(object sender, RoutedEventArgs e)
        {
            await LoadYearlyDataAsync();
            MessageBox.Show("Data refreshed!", "Success", MessageBoxButton.OK, MessageBoxImage.Information);
        }

        private async void PaySalaries_Click(object sender, RoutedEventArgs e)
        {
            var result = MessageBox.Show(
                $"Are you sure you want to mark salaries as PAID for {System.Globalization.CultureInfo.CurrentCulture.DateTimeFormat.GetMonthName(_selectedMonth)} {_selectedYear}?\n\nThis will calculate total salaries from all active employees.",
                "Confirm Pay Salaries",
                MessageBoxButton.YesNo,
                MessageBoxImage.Question);

            if (result == MessageBoxResult.Yes)
            {
                try
                {
                    var updated = await _revenueService.PaySalariesAsync(_selectedYear, _selectedMonth);
                    if (updated != null)
                    {
                        MessageBox.Show(
                            $"Salaries marked as paid!\n\nTotal: Rs. {updated.TotalSalaries:N0}",
                            "Success",
                            MessageBoxButton.OK,
                            MessageBoxImage.Information);

                        await LoadYearlyDataAsync();
                    }
                }
                catch (Exception ex)
                {
                    MessageBox.Show($"Error paying salaries: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
                }
            }
        }

        private async void AddExpense_Click(object sender, RoutedEventArgs e)
        {
            // Simple input dialog
            var dialog = new AddExpenseDialog(_selectedYear, _selectedMonth);
            if (dialog.ShowDialog() == true)
            {
                try
                {
                    var updated = await _revenueService.AddMiscExpenseAsync(
                        _selectedYear, _selectedMonth, dialog.Amount, dialog.Description);

                    if (updated != null)
                    {
                        MessageBox.Show(
                            $"Expense added!\n\nTotal Misc Expenses: Rs. {updated.MiscExpense:N0}",
                            "Success",
                            MessageBoxButton.OK,
                            MessageBoxImage.Information);

                        await LoadYearlyDataAsync();
                    }
                }
                catch (Exception ex)
                {
                    MessageBox.Show($"Error adding expense: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
                }
            }
        }

        private async void CalculateMonth_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                var updated = await _revenueService.CalculateMonthlyRevenueAsync(_selectedYear, _selectedMonth);

                if (updated != null)
                {
                    MessageBox.Show(
                        $"Month calculated!\n\nSales: Rs. {updated.SalesIncome:N0}\nDeals: Rs. {updated.DealIncome:N0}",
                        "Success",
                        MessageBoxButton.OK,
                        MessageBoxImage.Information);

                    await LoadYearlyDataAsync();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error calculating month: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        #endregion
    }

    /// <summary>
    /// Simple dialog for adding expenses
    /// </summary>
    public class AddExpenseDialog : Window
    {
        private TextBox txtAmount;
        private TextBox txtDescription;

        public decimal Amount { get; private set; }
        public string Description { get; private set; } = string.Empty;

        public AddExpenseDialog(int year, int month)
        {
            Title = $"Add Expense - {System.Globalization.CultureInfo.CurrentCulture.DateTimeFormat.GetMonthName(month)} {year}";
            Width = 400;
            Height = 220;
            WindowStartupLocation = WindowStartupLocation.CenterOwner;
            ResizeMode = ResizeMode.NoResize;

            var grid = new Grid { Margin = new Thickness(20) };
            grid.RowDefinitions.Add(new RowDefinition { Height = GridLength.Auto });
            grid.RowDefinitions.Add(new RowDefinition { Height = GridLength.Auto });
            grid.RowDefinitions.Add(new RowDefinition { Height = GridLength.Auto });
            grid.RowDefinitions.Add(new RowDefinition { Height = GridLength.Auto });
            grid.RowDefinitions.Add(new RowDefinition { Height = GridLength.Auto });

            // Amount label
            var lblAmount = new TextBlock { Text = "Amount (Rs.):", FontWeight = FontWeights.SemiBold, Margin = new Thickness(0, 0, 0, 5) };
            Grid.SetRow(lblAmount, 0);
            grid.Children.Add(lblAmount);

            // Amount input
            txtAmount = new TextBox { FontSize = 14, Padding = new Thickness(8), Margin = new Thickness(0, 0, 0, 15) };
            Grid.SetRow(txtAmount, 1);
            grid.Children.Add(txtAmount);

            // Description label
            var lblDesc = new TextBlock { Text = "Description (optional):", FontWeight = FontWeights.SemiBold, Margin = new Thickness(0, 0, 0, 5) };
            Grid.SetRow(lblDesc, 2);
            grid.Children.Add(lblDesc);

            // Description input
            txtDescription = new TextBox { FontSize = 14, Padding = new Thickness(8), Margin = new Thickness(0, 0, 0, 15) };
            Grid.SetRow(txtDescription, 3);
            grid.Children.Add(txtDescription);

            // Buttons
            var buttonPanel = new StackPanel { Orientation = Orientation.Horizontal, HorizontalAlignment = HorizontalAlignment.Right };
            
            var btnCancel = new Button { Content = "Cancel", Padding = new Thickness(20, 8, 20, 8), Margin = new Thickness(0, 0, 10, 0) };
            btnCancel.Click += (s, e) => { DialogResult = false; Close(); };
            buttonPanel.Children.Add(btnCancel);

            var btnAdd = new Button 
            { 
                Content = "Add Expense", 
                Padding = new Thickness(20, 8, 20, 8), 
                Background = new System.Windows.Media.SolidColorBrush(System.Windows.Media.Color.FromRgb(255, 152, 0)),
                Foreground = System.Windows.Media.Brushes.White
            };
            btnAdd.Click += BtnAdd_Click;
            buttonPanel.Children.Add(btnAdd);

            Grid.SetRow(buttonPanel, 4);
            grid.Children.Add(buttonPanel);

            Content = grid;
        }

        private void BtnAdd_Click(object sender, RoutedEventArgs e)
        {
            if (decimal.TryParse(txtAmount.Text, out decimal amount) && amount > 0)
            {
                Amount = amount;
                Description = txtDescription.Text;
                DialogResult = true;
                Close();
            }
            else
            {
                MessageBox.Show("Please enter a valid positive amount.", "Invalid Amount", MessageBoxButton.OK, MessageBoxImage.Warning);
            }
        }
    }
}
