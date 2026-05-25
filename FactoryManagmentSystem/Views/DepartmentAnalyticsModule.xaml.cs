using System;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Media;
using System.Linq;
using FactoryManagmentSystem.Services;
using FactoryManagmentSystem.Models.Entities;
using System.Threading.Tasks;

namespace FactoryManagmentSystem.Views
{
    /// <summary>
    /// Department Analytics Module with Database Integration
    /// </summary>
    public partial class DepartmentAnalyticsModule : UserControl
    {
        public ObservableCollection<TailorProduction> TailorProductionData { get; set; }
        public ObservableCollection<SalespersonSales> SalespersonSalesData { get; set; }
        public ObservableCollection<DepartmentItem> DepartmentsData { get; set; }
        
        private readonly DepartmentService _departmentService;

        public DepartmentAnalyticsModule()
        {
            InitializeComponent();
            _departmentService = new DepartmentService();
            
            // Initialize collections
            TailorProductionData = new ObservableCollection<TailorProduction>();
            SalespersonSalesData = new ObservableCollection<SalespersonSales>();
            DepartmentsData = new ObservableCollection<DepartmentItem>();
            
            // Load real data from database
            _ = LoadAllDataAsync();
        }

        private async Task LoadAllDataAsync()
        {
            try
            {
                // Load departments first (this works)
                await LoadDepartmentsFromDatabaseAsync();
                
                // Load production and sales data - show real employees even if no orders yet
                await LoadProductionDataAsync();
                await LoadSalesDataAsync();
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error loading data: {ex.Message}\n\nShowing available data only.", "Loading Error", 
                    MessageBoxButton.OK, MessageBoxImage.Information);
            }
        }

        private async Task LoadProductionDataAsync()
        {
            try
            {
                // Get Production/Tailor employees from database
                var productionEmployees = await _departmentService.GetEmployeesByDepartmentAsync(2); // Production dept ID = 2
                
                Dispatcher.Invoke(() =>
                {
                    TailorProductionData.Clear();
                    
                    // Set stats to 0 since no production orders yet
                    TotalProductionValue.Text = "0";
                    ActiveTailorsCount.Text = productionEmployees.Count.ToString();
                    AvgProductionPerTailor.Text = "0";
                    QualityRateValue.Text = "0.0%";
                    
                    // Show real employees with zero production (they haven't started yet)
                    int rank = 1;
                    foreach (var emp in productionEmployees)
                    {
                        TailorProductionData.Add(new TailorProduction
                        {
                            Rank = rank++,
                            Name = emp.FullName,
                            EmployeeId = $"EMP-{emp.EmployeeID:D3}",
                            UnitsToday = 0,
                            UnitsWeek = 0,
                            UnitsMonth = 0,
                            Performance = 0
                        });
                    }
                    TailorProductionList.ItemsSource = TailorProductionData;
                });
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error loading production data: {ex.Message}");
                Dispatcher.Invoke(() =>
                {
                    TotalProductionValue.Text = "0";
                    ActiveTailorsCount.Text = "0";
                    AvgProductionPerTailor.Text = "0";
                    QualityRateValue.Text = "0.0%";
                });
            }
        }

        private async Task LoadSalesDataAsync()
        {
            try
            {
                // Get Sales employees from database
                var salesEmployees = await _departmentService.GetEmployeesByDepartmentAsync(1); // Sales dept ID = 1
                
                Dispatcher.Invoke(() =>
                {
                    SalespersonSalesData.Clear();
                    
                    // Set stats to 0 since no sales orders yet
                    TotalSalesValue.Text = "Rs. 0";
                    ActiveSalespersonsCount.Text = salesEmployees.Count.ToString();
                    TotalOrdersCount.Text = "0";
                    AvgSalesPerPerson.Text = "Rs. 0";
                    
                    // Show real employees with zero sales (they haven't made sales yet)
                    int rank = 1;
                    foreach (var emp in salesEmployees)
                    {
                        SalespersonSalesData.Add(new SalespersonSales
                        {
                            Rank = rank++,
                            Name = emp.FullName,
                            EmployeeId = $"EMP-{emp.EmployeeID:D3}",
                            SalesToday = "Rs. 0",
                            SalesWeek = "Rs. 0",
                            SalesMonth = "Rs. 0",
                            OrderCount = 0,
                            TargetPercent = 0
                        });
                    }
                    SalespersonSalesList.ItemsSource = SalespersonSalesData;
                });
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error loading sales data: {ex.Message}");
                Dispatcher.Invoke(() =>
                {
                    TotalSalesValue.Text = "Rs. 0";
                    ActiveSalespersonsCount.Text = "0";
                    TotalOrdersCount.Text = "0";
                    AvgSalesPerPerson.Text = "Rs. 0";
                });
            }
        }

        private void LoadSampleData()
        {
            // Load Production Department Data
            TailorProductionData = new ObservableCollection<TailorProduction>
            {
                new TailorProduction { Rank = 1, Name = "Ahmed Khan", EmployeeId = "EMP-001", UnitsToday = 45, UnitsWeek = 312, UnitsMonth = 1248, Performance = 98 },
                new TailorProduction { Rank = 2, Name = "Muhammad Ali", EmployeeId = "EMP-003", UnitsToday = 42, UnitsWeek = 295, UnitsMonth = 1180, Performance = 95 },
                new TailorProduction { Rank = 3, Name = "Hassan Raza", EmployeeId = "EMP-007", UnitsToday = 40, UnitsWeek = 280, UnitsMonth = 1120, Performance = 92 },
                new TailorProduction { Rank = 4, Name = "Imran Shah", EmployeeId = "EMP-009", UnitsToday = 38, UnitsWeek = 266, UnitsMonth = 1064, Performance = 88 },
                new TailorProduction { Rank = 5, Name = "Bilal Ahmed", EmployeeId = "EMP-012", UnitsToday = 36, UnitsWeek = 252, UnitsMonth = 1008, Performance = 85 },
                new TailorProduction { Rank = 6, Name = "Usman Tariq", EmployeeId = "EMP-015", UnitsToday = 35, UnitsWeek = 245, UnitsMonth = 980, Performance = 82 },
                new TailorProduction { Rank = 7, Name = "Farhan Malik", EmployeeId = "EMP-018", UnitsToday = 33, UnitsWeek = 231, UnitsMonth = 924, Performance = 78 },
                new TailorProduction { Rank = 8, Name = "Asad Hussain", EmployeeId = "EMP-021", UnitsToday = 31, UnitsWeek = 217, UnitsMonth = 868, Performance = 75 },
                new TailorProduction { Rank = 9, Name = "Zain Abbas", EmployeeId = "EMP-024", UnitsToday = 28, UnitsWeek = 196, UnitsMonth = 784, Performance = 70 },
                new TailorProduction { Rank = 10, Name = "Kamran Iqbal", EmployeeId = "EMP-027", UnitsToday = 25, UnitsWeek = 175, UnitsMonth = 700, Performance = 65 }
            };

            // Load Sales Department Data
            SalespersonSalesData = new ObservableCollection<SalespersonSales>
            {
                new SalespersonSales { Rank = 1, Name = "Sara Ahmed", EmployeeId = "EMP-102", SalesToday = "Rs. 4,520", SalesWeek = "Rs. 31,640", SalesMonth = "Rs. 126,560", OrderCount = 156, TargetPercent = 115 },
                new SalespersonSales { Rank = 2, Name = "Fatima Khan", EmployeeId = "EMP-105", SalesToday = "Rs. 3,890", SalesWeek = "Rs. 27,230", SalesMonth = "Rs. 108,920", OrderCount = 134, TargetPercent = 105 },
                new SalespersonSales { Rank = 3, Name = "Ali Hassan", EmployeeId = "EMP-108", SalesToday = "Rs. 3,450", SalesWeek = "Rs. 24,150", SalesMonth = "Rs. 96,600", OrderCount = 118, TargetPercent = 98 },
                new SalespersonSales { Rank = 4, Name = "Ayesha Malik", EmployeeId = "EMP-111", SalesToday = "Rs. 3,120", SalesWeek = "Rs. 21,840", SalesMonth = "Rs. 87,360", OrderCount = 102, TargetPercent = 92 },
                new SalespersonSales { Rank = 5, Name = "Umar Farooq", EmployeeId = "EMP-114", SalesToday = "Rs. 2,890", SalesWeek = "Rs. 20,230", SalesMonth = "Rs. 80,920", OrderCount = 95, TargetPercent = 88 },
                new SalespersonSales { Rank = 6, Name = "Hira Zafar", EmployeeId = "EMP-117", SalesToday = "Rs. 2,650", SalesWeek = "Rs. 18,550", SalesMonth = "Rs. 74,200", OrderCount = 87, TargetPercent = 82 },
                new SalespersonSales { Rank = 7, Name = "Tariq Mehmood", EmployeeId = "EMP-120", SalesToday = "Rs. 2,380", SalesWeek = "Rs. 16,660", SalesMonth = "Rs. 66,640", OrderCount = 78, TargetPercent = 75 },
                new SalespersonSales { Rank = 8, Name = "Nadia Rashid", EmployeeId = "EMP-123", SalesToday = "Rs. 2,100", SalesWeek = "Rs. 14,700", SalesMonth = "Rs. 58,800", OrderCount = 68, TargetPercent = 68 }
            };

            TailorProductionList.ItemsSource = TailorProductionData;
            SalespersonSalesList.ItemsSource = SalespersonSalesData;
        }

        #region Department Management Methods

        // Load departments from database using stored procedures
        private async Task LoadDepartmentsFromDatabaseAsync()
        {
            try
            {
                var departmentsWithCount = await _departmentService.GetDepartmentsWithEmployeeCountAsync();
                
                DepartmentsData = new ObservableCollection<DepartmentItem>();
                
                foreach (var dept in departmentsWithCount)
                {
                    DepartmentsData.Add(new DepartmentItem
                    {
                        DepartmentId = dept.DepartmentID,
                        DepartmentName = dept.DepartmentName,
                        Description = dept.Description ?? "No description available",
                        EmployeeCount = dept.EmployeeCount,
                        CreatedDate = DateTime.Now, // You can add CreatedDate to the stored procedure if needed
                        Status = dept.IsActive ? "Active" : "Inactive"
                    });
                }

                // Update UI on main thread
                Dispatcher.Invoke(() =>
                {
                    DepartmentsList.ItemsSource = DepartmentsData;
                    UpdateDepartmentCounts();
                });
            }
            catch (Exception ex)
            {
                Dispatcher.Invoke(() =>
                {
                    MessageBox.Show($"Error loading departments: {ex.Message}", "Database Error", 
                        MessageBoxButton.OK, MessageBoxImage.Error);
                });
            }
        }
        
        // Update department counts in the header cards
        private void UpdateDepartmentCounts()
        {
            var productionDept = DepartmentsData?.FirstOrDefault(d => 
                d.DepartmentName.Contains("Production", StringComparison.OrdinalIgnoreCase));
            var salesDept = DepartmentsData?.FirstOrDefault(d => 
                d.DepartmentName.Contains("Sales", StringComparison.OrdinalIgnoreCase));
            
            if (productionDept != null)
            {
                ProductionEmployeeCount.Text = productionDept.EmployeeCount.ToString();
            }
            else
            {
                ProductionEmployeeCount.Text = "0";
            }
            
            if (salesDept != null)
            {
                SalesEmployeeCount.Text = salesDept.EmployeeCount.ToString();
            }
            else
            {
                SalesEmployeeCount.Text = "0";
            }
        }

        private bool AddDepartment(string name, string description)
        {
            try
            {
                // Check if department name already exists
                var existingDepartment = DepartmentsData.FirstOrDefault(d => 
                    d.DepartmentName.Equals(name, StringComparison.OrdinalIgnoreCase));
                
                if (existingDepartment != null)
                {
                    MessageBox.Show("A department with this name already exists.", "Duplicate Name", 
                        MessageBoxButton.OK, MessageBoxImage.Warning);
                    return false;
                }

                // Add new department to the list
                var newDepartment = new DepartmentItem
                {
                    DepartmentId = DepartmentsData.Count > 0 ? DepartmentsData.Max(d => d.DepartmentId) + 1 : 1,
                    DepartmentName = name,
                    Description = description ?? string.Empty,
                    EmployeeCount = 0,
                    CreatedDate = DateTime.Now,
                    Status = "Active"
                };

                DepartmentsData.Add(newDepartment);
                
                // Refresh the display immediately
                DepartmentsList.ItemsSource = null;
                DepartmentsList.ItemsSource = DepartmentsData;
                

                
                return true;
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error adding department: {ex.Message}", "Error", 
                    MessageBoxButton.OK, MessageBoxImage.Error);
                return false;
            }
        }

        #endregion

        #region Tab Navigation

        private void AddDepartmentTabBtn_Click(object sender, RoutedEventArgs e)
        {
            // Update tab styles
            AddDepartmentTabBtn.Style = (Style)FindResource("TabButtonActive");
            ViewDepartmentsTabBtn.Style = (Style)FindResource("TabButton");
            ProductionTabBtn.Style = (Style)FindResource("TabButton");
            SalesTabBtn.Style = (Style)FindResource("TabButton");

            // Show/Hide content
            AddDepartmentContent.Visibility = Visibility.Visible;
            ViewDepartmentsContent.Visibility = Visibility.Collapsed;
            ProductionContent.Visibility = Visibility.Collapsed;
            SalesContent.Visibility = Visibility.Collapsed;
        }

        private async void ViewDepartmentsTabBtn_Click(object sender, RoutedEventArgs e)
        {
            // Update tab styles
            ViewDepartmentsTabBtn.Style = (Style)FindResource("TabButtonActive");
            AddDepartmentTabBtn.Style = (Style)FindResource("TabButton");
            ProductionTabBtn.Style = (Style)FindResource("TabButton");
            SalesTabBtn.Style = (Style)FindResource("TabButton");

            // Show/Hide content
            ViewDepartmentsContent.Visibility = Visibility.Visible;
            AddDepartmentContent.Visibility = Visibility.Collapsed;
            ProductionContent.Visibility = Visibility.Collapsed;
            SalesContent.Visibility = Visibility.Collapsed;
            
            // Refresh the departments list from database when switching to this tab
            await LoadDepartmentsFromDatabaseAsync();
        }

        #endregion

        #region Event Handlers

        private async void AddDepartmentBtn_Click(object sender, RoutedEventArgs e)
        {
            var name = AddDepartmentNameBox.Text.Trim();
            var description = AddDepartmentDescBox.Text.Trim();

            if (string.IsNullOrEmpty(name))
            {
                MessageBox.Show("Please enter a department name.", "Validation Error", 
                    MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }

            // Disable button to prevent multiple clicks
            AddDepartmentBtn.IsEnabled = false;
            AddDepartmentBtn.Content = "Adding...";

            try
            {
                var departmentId = await _departmentService.AddDepartmentAsync(name, description);
                if (departmentId > 0)
                {
                    MessageBox.Show("Department added successfully!", "Success", 
                        MessageBoxButton.OK, MessageBoxImage.Information);
                    
                    // Clear form
                    AddDepartmentNameBox.Clear();
                    AddDepartmentDescBox.Clear();
                }
                else
                {
                    MessageBox.Show("Failed to add department. Please try again.", "Error", 
                        MessageBoxButton.OK, MessageBoxImage.Error);
                }
            }
            finally
            {
                // Re-enable button
                AddDepartmentBtn.IsEnabled = true;
                AddDepartmentBtn.Content = "➕ Add Department";
            }
        }

        private void ClearAddFormBtn_Click(object sender, RoutedEventArgs e)
        {
            AddDepartmentNameBox.Clear();
            AddDepartmentDescBox.Clear();
        }

        private async void SearchDepartmentBtn_Click(object sender, RoutedEventArgs e)
        {
            var searchTerm = SearchDepartmentBox.Text.Trim();
            
            SearchDepartmentBtn.IsEnabled = false;
            SearchDepartmentBtn.Content = "Searching...";
            
            try
            {
                if (string.IsNullOrEmpty(searchTerm))
                {
                    // Show all departments if search is empty
                    await LoadDepartmentsFromDatabaseAsync();
                    return;
                }
                
                // Search departments using database query
                var searchResults = await _departmentService.SearchDepartmentsAsync(searchTerm);
                
                var searchResultItems = new ObservableCollection<DepartmentItem>();
                foreach (var dept in searchResults)
                {
                    searchResultItems.Add(new DepartmentItem
                    {
                        DepartmentId = dept.DepartmentID,
                        DepartmentName = dept.DepartmentName,
                        Description = dept.Description ?? "No description available",
                        EmployeeCount = 0, // Search doesn't include employee count - you can modify stored procedure if needed
                        CreatedDate = dept.CreatedDate,
                        Status = dept.IsActive ? "Active" : "Inactive"
                    });
                }
                
                DepartmentsList.ItemsSource = searchResultItems;
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error searching departments: {ex.Message}", "Database Error", 
                    MessageBoxButton.OK, MessageBoxImage.Error);
            }
            finally
            {
                SearchDepartmentBtn.IsEnabled = true;
                SearchDepartmentBtn.Content = "🔍 Search";
            }
        }

        private async void RefreshDepartmentBtn_Click(object sender, RoutedEventArgs e)
        {
            RefreshDepartmentBtn.IsEnabled = false;
            RefreshDepartmentBtn.Content = "Refreshing...";
            
            try
            {
                // Reload data from database
                await LoadDepartmentsFromDatabaseAsync();
                
                // Clear search box
                SearchDepartmentBox.Clear();
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error refreshing departments: {ex.Message}", "Database Error", 
                    MessageBoxButton.OK, MessageBoxImage.Error);
            }
            finally
            {
                RefreshDepartmentBtn.IsEnabled = true;
                RefreshDepartmentBtn.Content = "🔄 Refresh";
            }
        }

        private async void DeleteDepartmentBtn_Click(object sender, RoutedEventArgs e)
        {
            if (sender is Button btn && btn.Tag is int departmentId)
            {
                var department = DepartmentsData.FirstOrDefault(d => d.DepartmentId == departmentId);
                if (department == null) return;

                // Check if department has employees
                if (department.EmployeeCount > 0)
                {
                    MessageBox.Show($"Cannot delete '{department.DepartmentName}' department.\n\nIt has {department.EmployeeCount} active employee(s). Please reassign them first.", 
                        "Cannot Delete", MessageBoxButton.OK, MessageBoxImage.Warning);
                    return;
                }

                var result = MessageBox.Show($"Are you sure you want to delete '{department.DepartmentName}' department?", 
                    "Confirm Delete", MessageBoxButton.YesNo, MessageBoxImage.Question);

                if (result == MessageBoxResult.Yes)
                {
                    try
                    {
                        var success = await _departmentService.DeleteDepartmentAsync(departmentId);
                        if (success)
                        {
                            MessageBox.Show("Department deleted successfully!", "Success", 
                                MessageBoxButton.OK, MessageBoxImage.Information);
                            await LoadDepartmentsFromDatabaseAsync();
                        }
                        else
                        {
                            MessageBox.Show("Failed to delete department.", "Error", 
                                MessageBoxButton.OK, MessageBoxImage.Error);
                        }
                    }
                    catch (Exception ex)
                    {
                        MessageBox.Show($"Error deleting department: {ex.Message}", "Error", 
                            MessageBoxButton.OK, MessageBoxImage.Error);
                    }
                }
            }
        }

        #endregion

        private async void ProductionTabBtn_Click(object sender, RoutedEventArgs e)
        {
            // Update tab styles
            ProductionTabBtn.Style = (Style)FindResource("TabButtonActive");
            AddDepartmentTabBtn.Style = (Style)FindResource("TabButton");
            ViewDepartmentsTabBtn.Style = (Style)FindResource("TabButton");
            SalesTabBtn.Style = (Style)FindResource("TabButton");

            // Show/Hide content
            ProductionContent.Visibility = Visibility.Visible;
            AddDepartmentContent.Visibility = Visibility.Collapsed;
            ViewDepartmentsContent.Visibility = Visibility.Collapsed;
            SalesContent.Visibility = Visibility.Collapsed;
            
            // Reload production data when switching to this tab
            try
            {
                await LoadProductionDataAsync();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error refreshing production data: {ex.Message}");
            }
        }

        private async void SalesTabBtn_Click(object sender, RoutedEventArgs e)
        {
            // Update tab styles
            SalesTabBtn.Style = (Style)FindResource("TabButtonActive");
            AddDepartmentTabBtn.Style = (Style)FindResource("TabButton");
            ViewDepartmentsTabBtn.Style = (Style)FindResource("TabButton");
            ProductionTabBtn.Style = (Style)FindResource("TabButton");

            // Show/Hide content
            SalesContent.Visibility = Visibility.Visible;
            AddDepartmentContent.Visibility = Visibility.Collapsed;
            ViewDepartmentsContent.Visibility = Visibility.Collapsed;
            ProductionContent.Visibility = Visibility.Collapsed;
            
            // Reload sales data when switching to this tab
            try
            {
                await LoadSalesDataAsync();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error refreshing sales data: {ex.Message}");
            }
        }
    }

    /// <summary>
    /// Model for Tailor Production data
    /// </summary>
    public class TailorProduction : INotifyPropertyChanged
    {
        public int Rank { get; set; }
        public string Name { get; set; }
        public string EmployeeId { get; set; }
        public int UnitsToday { get; set; }
        public int UnitsWeek { get; set; }
        public int UnitsMonth { get; set; }
        public int Performance { get; set; }

        public string Initials => GetInitials(Name);

        public double PerformanceWidth => Performance * 1.2; // Max width ~120px

        public SolidColorBrush PerformanceColor
        {
            get
            {
                if (Performance >= 90) return new SolidColorBrush((Color)ColorConverter.ConvertFromString("#10B981"));
                if (Performance >= 75) return new SolidColorBrush((Color)ColorConverter.ConvertFromString("#3B82F6"));
                if (Performance >= 60) return new SolidColorBrush((Color)ColorConverter.ConvertFromString("#F59E0B"));
                return new SolidColorBrush((Color)ColorConverter.ConvertFromString("#EF4444"));
            }
        }

        private string GetInitials(string name)
        {
            if (string.IsNullOrEmpty(name)) return "?";
            var parts = name.Split(' ');
            if (parts.Length >= 2)
                return $"{parts[0][0]}{parts[1][0]}".ToUpper();
            return name.Substring(0, Math.Min(2, name.Length)).ToUpper();
        }

        public event PropertyChangedEventHandler PropertyChanged;
        protected void OnPropertyChanged(string propertyName)
        {
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
        }
    }

    /// <summary>
    /// Model for Salesperson Sales data
    /// </summary>
    public class SalespersonSales : INotifyPropertyChanged
    {
        public int Rank { get; set; }
        public string Name { get; set; }
        public string EmployeeId { get; set; }
        public string SalesToday { get; set; }
        public string SalesWeek { get; set; }
        public string SalesMonth { get; set; }
        public int OrderCount { get; set; }
        public int TargetPercent { get; set; }

        public string Initials => GetInitials(Name);

        public double TargetWidth => Math.Min(TargetPercent, 100) * 1.0; // Max width ~100px

        public SolidColorBrush TargetColor
        {
            get
            {
                if (TargetPercent >= 100) return new SolidColorBrush((Color)ColorConverter.ConvertFromString("#10B981"));
                if (TargetPercent >= 85) return new SolidColorBrush((Color)ColorConverter.ConvertFromString("#3B82F6"));
                if (TargetPercent >= 70) return new SolidColorBrush((Color)ColorConverter.ConvertFromString("#F59E0B"));
                return new SolidColorBrush((Color)ColorConverter.ConvertFromString("#EF4444"));
            }
        }

        private string GetInitials(string name)
        {
            if (string.IsNullOrEmpty(name)) return "?";
            var parts = name.Split(' ');
            if (parts.Length >= 2)
                return $"{parts[0][0]}{parts[1][0]}".ToUpper();
            return name.Substring(0, Math.Min(2, name.Length)).ToUpper();
        }

        public event PropertyChangedEventHandler PropertyChanged;
        protected void OnPropertyChanged(string propertyName)
        {
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
        }
    }

    /// <summary>
    /// Model for Department data
    /// </summary>
    public class DepartmentItem : INotifyPropertyChanged
    {
        public int DepartmentId { get; set; }
        public string DepartmentName { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public int EmployeeCount { get; set; }
        public DateTime CreatedDate { get; set; }
        public string Status { get; set; } = string.Empty;

        public SolidColorBrush StatusColor
        {
            get
            {
                return Status == "Active" 
                    ? new SolidColorBrush((Color)ColorConverter.ConvertFromString("#10B981"))
                    : new SolidColorBrush((Color)ColorConverter.ConvertFromString("#EF4444"));
            }
        }

        public event PropertyChangedEventHandler PropertyChanged;
        protected void OnPropertyChanged(string propertyName)
        {
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
        }
    }
}
