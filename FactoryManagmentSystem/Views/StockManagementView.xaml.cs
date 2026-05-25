using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Windows;
using System.Windows.Controls;
using FactoryManagmentSystem.Services;
using FactoryManagmentSystem.Models;

namespace FactoryManagmentSystem.Views
{
    public partial class StockManagementView : UserControl
    {
        private readonly StockService _stockService;
        
        // Data collections
        private ObservableCollection<StockDisplayModel> _readyProducts = new();
        private ObservableCollection<StockDisplayModel> _inProcessProducts = new();
        private ObservableCollection<StockDisplayModel> _shippedProducts = new();

        // All data for filtering
        private List<StockDisplayModel> _allReadyProducts = new();
        private List<StockDisplayModel> _allInProcessProducts = new();
        private List<StockDisplayModel> _allShippedProducts = new();

        // Pagination
        private int _readyCurrentPage = 1;
        private int _inProcessCurrentPage = 1;
        private int _shippedCurrentPage = 1;
        private const int PageSize = 10;

        private string _currentTab = "Ready";
        private bool _isLoaded = false;

        public StockManagementView()
        {
            InitializeComponent();
            
            _stockService = new StockService();
            
            // Bind to grids after loading
            ReadyProductsGrid.ItemsSource = _readyProducts;
            InProcessGrid.ItemsSource = _inProcessProducts;
            ShippedGrid.ItemsSource = _shippedProducts;
            
            _isLoaded = true;
            
            // Load data from database (async)
            Loaded += async (s, e) => await LoadDataFromDatabaseAsync();
        }

        private async Task LoadDataFromDatabaseAsync()
        {
            try
            {
                // Load using new dynamic stored procedures
                var readyItems = await _stockService.GetReadyProductsAsync();
                var inProcessItems = await _stockService.GetInProcessProductsAsync();
                var shippedItems = await _stockService.GetShippedProductsAsync();
                
                // Map to display models - Ready Products
                _allReadyProducts = readyItems.Select(s => new StockDisplayModel
                {
                    StockId = s.StockID,
                    ProductId = s.ProductID,
                    BatchNo = s.BatchNo,
                    ProductName = s.Product,
                    ProductCategory = s.OrderType,
                    ReadyQty = s.Quantity,
                    InProcessQty = 0,
                    ShippedQty = 0,
                    DateAdded = s.DateAdded ?? DateTime.Now,
                    ProgressPercent = 100,
                    Destination = s.CustomerName ?? "N/A"
                }).ToList();

                // Map to display models - In Process Products
                _allInProcessProducts = inProcessItems.Select(s => new StockDisplayModel
                {
                    StockId = s.StockID,
                    ProductId = s.ProductID,
                    BatchNo = s.BatchNo,
                    ProductName = s.Product,
                    ProductCategory = s.OrderType,
                    ReadyQty = 0,
                    InProcessQty = s.RemainingQuantity,
                    ShippedQty = 0,
                    DateAdded = s.DateAdded ?? DateTime.Now,
                    ProcessStartDate = s.DateAdded ?? DateTime.Now,
                    ProgressPercent = s.ProgressPercentage,
                    Destination = s.CustomerName ?? "N/A"
                }).ToList();

                // Map to display models - Shipped Products
                _allShippedProducts = shippedItems.Select(s => new StockDisplayModel
                {
                    StockId = s.StockID,
                    ProductId = s.ProductID ?? 0,
                    BatchNo = s.BatchNo ?? "N/A",
                    ProductName = s.Product ?? "Unknown",
                    ProductCategory = s.OrderType,
                    ReadyQty = 0,
                    InProcessQty = 0,
                    ShippedQty = s.Quantity,
                    DateAdded = s.DateShipped ?? DateTime.Now,
                    ShippedDate = s.DateShipped ?? DateTime.Now,
                    DeliveryStatus = s.DeliveryStatus,
                    Destination = s.CustomerName ?? "N/A"
                }).ToList();
                    
                await UpdateStatisticsAsync();
                
                // Apply filters to populate grids
                ApplyReadyFilters();
                ApplyInProcessFilters();
                ApplyShippedFilters();
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error loading stock data: {ex.Message}", "Error",
                    MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private async Task UpdateStatisticsAsync()
        {
            try
            {
                var stats = await _stockService.GetStockStatisticsAsync();
                
                TotalStockText.Text = stats.TotalOrders.ToString();
                ReadyQtyText.Text = $"{stats.ReadyQuantity} ({stats.ReadyCount} items)";
                InProcessQtyText.Text = $"{stats.InProcessQuantity} ({stats.InProcessCount} items)";
                ShippedQtyText.Text = $"{stats.ShippedQuantity} ({stats.ShippedCount} items)";
            }
            catch (Exception ex)
            {
                // Fallback to counting from loaded data
                int totalStock = _allReadyProducts.Count + _allInProcessProducts.Count + _allShippedProducts.Count;
                int totalReady = _allReadyProducts.Sum(p => p.ReadyQty);
                int totalInProcess = _allInProcessProducts.Sum(p => p.InProcessQty);
                int totalShipped = _allShippedProducts.Sum(p => p.ShippedQty);

                TotalStockText.Text = totalStock.ToString();
                ReadyQtyText.Text = $"{totalReady} ({_allReadyProducts.Count} items)";
                InProcessQtyText.Text = $"{totalInProcess} ({_allInProcessProducts.Count} items)";
                ShippedQtyText.Text = $"{totalShipped} ({_allShippedProducts.Count} items)";
            }
        }

        #region Tab Navigation

        private void TabBtn_Click(object sender, RoutedEventArgs e)
        {
            var button = sender as Button;
            var tabName = button?.Tag?.ToString();

            if (string.IsNullOrEmpty(tabName)) return;

            // Reset all tab styles
            ReadyProductsTab.Style = (Style)Resources["TabBtn"];
            InProcessTab.Style = (Style)Resources["TabBtn"];
            ShippedTab.Style = (Style)Resources["TabBtn"];

            // Set active tab style
            button.Style = (Style)Resources["ActiveTabBtn"];

            // Hide all content
            ReadyProductsContent.Visibility = Visibility.Collapsed;
            InProcessContent.Visibility = Visibility.Collapsed;
            ShippedContent.Visibility = Visibility.Collapsed;

            // Show selected content
            _currentTab = tabName;
            switch (tabName)
            {
                case "Ready":
                    ReadyProductsContent.Visibility = Visibility.Visible;
                    break;
                case "InProcess":
                    InProcessContent.Visibility = Visibility.Visible;
                    break;
                case "Shipped":
                    ShippedContent.Visibility = Visibility.Visible;
                    break;
            }
        }

        #endregion

        #region Ready Products Tab

        private void ApplyReadyFilters()
        {
            var filtered = _allReadyProducts.AsEnumerable();

            // Search filter
            var searchText = ReadySearchBox?.Text?.ToLower() ?? "";
            if (!string.IsNullOrWhiteSpace(searchText))
            {
                filtered = filtered.Where(x =>
                    x.ProductName.ToLower().Contains(searchText) ||
                    x.BatchNo.ToLower().Contains(searchText) ||
                    x.StockId.ToString().Contains(searchText));
            }

            // Category filter
            var selectedCategory = (ReadyCategoryFilter?.SelectedItem as ComboBoxItem)?.Content?.ToString();
            if (!string.IsNullOrEmpty(selectedCategory) && selectedCategory != "All Products")
            {
                filtered = filtered.Where(x => x.ProductCategory == selectedCategory);
            }

            // Apply pagination
            var filteredList = filtered.ToList();
            int totalItems = filteredList.Count;
            int totalPages = (int)Math.Ceiling((double)totalItems / PageSize);

            if (_readyCurrentPage > totalPages && totalPages > 0)
                _readyCurrentPage = totalPages;

            var pagedItems = filteredList
                .Skip((_readyCurrentPage - 1) * PageSize)
                .Take(PageSize)
                .ToList();

            _readyProducts.Clear();
            foreach (var item in pagedItems)
                _readyProducts.Add(item);

            // Update pagination UI
            int startItem = totalItems > 0 ? ((_readyCurrentPage - 1) * PageSize) + 1 : 0;
            int endItem = Math.Min(_readyCurrentPage * PageSize, totalItems);
            ReadyShowingText.Text = $"Showing {startItem}-{endItem} of {totalItems} entries";
            ReadyPageText.Text = $"Page {_readyCurrentPage} of {Math.Max(1, totalPages)}";
            ReadyPrevBtn.IsEnabled = _readyCurrentPage > 1;
            ReadyNextBtn.IsEnabled = _readyCurrentPage < totalPages;
        }

        private void ReadySearchBox_TextChanged(object sender, TextChangedEventArgs e)
        {
            if (!_isLoaded) return;
            _readyCurrentPage = 1;
            ApplyReadyFilters();
        }

        private void ReadyCategoryFilter_Changed(object sender, SelectionChangedEventArgs e)
        {
            if (!_isLoaded) return;
            _readyCurrentPage = 1;
            ApplyReadyFilters();
        }

        private void ReadyPrevPage_Click(object sender, RoutedEventArgs e)
        {
            if (_readyCurrentPage > 1)
            {
                _readyCurrentPage--;
                ApplyReadyFilters();
            }
        }

        private void ReadyNextPage_Click(object sender, RoutedEventArgs e)
        {
            int totalPages = (int)Math.Ceiling((double)_allReadyProducts.Count / PageSize);
            if (_readyCurrentPage < totalPages)
            {
                _readyCurrentPage++;
                ApplyReadyFilters();
            }
        }

        private async void MoveToShipped_Click(object sender, RoutedEventArgs e)
        {
            var selectedItems = _readyProducts.Where(x => x.IsSelected).ToList();
            if (!selectedItems.Any())
            {
                MessageBox.Show("Please select at least one item to move to shipped.", "No Selection",
                    MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }

            var result = MessageBox.Show($"Are you sure you want to move {selectedItems.Count} item(s) to shipped?",
                "Confirm Move", MessageBoxButton.YesNo, MessageBoxImage.Question);

            if (result == MessageBoxResult.Yes)
            {
                foreach (var item in selectedItems)
                {
                    item.ShippedQty = item.ReadyQty;
                    item.ReadyQty = 0;
                    item.ShippedDate = DateTime.Now;
                    item.DeliveryStatus = "Pending";
                    item.Destination = "Pending Assignment";
                    item.IsSelected = false;

                    _allReadyProducts.Remove(item);
                    _allShippedProducts.Add(item);
                }

                ApplyReadyFilters();
                ApplyShippedFilters();
                await UpdateStatisticsAsync();

                MessageBox.Show($"Successfully moved {selectedItems.Count} item(s) to shipped.", "Success",
                    MessageBoxButton.OK, MessageBoxImage.Information);
            }
        }

        #endregion

        #region In Process Tab

        private void ApplyInProcessFilters()
        {
            var filtered = _allInProcessProducts.AsEnumerable();

            // Search filter
            var searchText = InProcessSearchBox?.Text?.ToLower() ?? "";
            if (!string.IsNullOrWhiteSpace(searchText))
            {
                filtered = filtered.Where(x =>
                    x.ProductName.ToLower().Contains(searchText) ||
                    x.BatchNo.ToLower().Contains(searchText) ||
                    x.StockId.ToString().Contains(searchText));
            }

            // Category filter
            var selectedCategory = (InProcessCategoryFilter?.SelectedItem as ComboBoxItem)?.Content?.ToString();
            if (!string.IsNullOrEmpty(selectedCategory) && selectedCategory != "All Products")
            {
                filtered = filtered.Where(x => x.ProductCategory == selectedCategory);
            }

            // Apply pagination
            var filteredList = filtered.ToList();
            int totalItems = filteredList.Count;
            int totalPages = (int)Math.Ceiling((double)totalItems / PageSize);

            if (_inProcessCurrentPage > totalPages && totalPages > 0)
                _inProcessCurrentPage = totalPages;

            var pagedItems = filteredList
                .Skip((_inProcessCurrentPage - 1) * PageSize)
                .Take(PageSize)
                .ToList();

            _inProcessProducts.Clear();
            foreach (var item in pagedItems)
                _inProcessProducts.Add(item);

            // Update pagination UI
            int startItem = totalItems > 0 ? ((_inProcessCurrentPage - 1) * PageSize) + 1 : 0;
            int endItem = Math.Min(_inProcessCurrentPage * PageSize, totalItems);
            InProcessShowingText.Text = $"Showing {startItem}-{endItem} of {totalItems} entries";
            InProcessPageText.Text = $"Page {_inProcessCurrentPage} of {Math.Max(1, totalPages)}";
            InProcessPrevBtn.IsEnabled = _inProcessCurrentPage > 1;
            InProcessNextBtn.IsEnabled = _inProcessCurrentPage < totalPages;
        }

        private void InProcessSearchBox_TextChanged(object sender, TextChangedEventArgs e)
        {
            if (!_isLoaded) return;
            _inProcessCurrentPage = 1;
            ApplyInProcessFilters();
        }

        private void InProcessCategoryFilter_Changed(object sender, SelectionChangedEventArgs e)
        {
            if (!_isLoaded) return;
            _inProcessCurrentPage = 1;
            ApplyInProcessFilters();
        }

        private void InProcessPrevPage_Click(object sender, RoutedEventArgs e)
        {
            if (_inProcessCurrentPage > 1)
            {
                _inProcessCurrentPage--;
                ApplyInProcessFilters();
            }
        }

        private void InProcessNextPage_Click(object sender, RoutedEventArgs e)
        {
            int totalPages = (int)Math.Ceiling((double)_allInProcessProducts.Count / PageSize);
            if (_inProcessCurrentPage < totalPages)
            {
                _inProcessCurrentPage++;
                ApplyInProcessFilters();
            }
        }

        private async void MoveToReady_Click(object sender, RoutedEventArgs e)
        {
            var selectedItems = _inProcessProducts.Where(x => x.IsSelected).ToList();
            if (!selectedItems.Any())
            {
                MessageBox.Show("Please select at least one item to move to ready.", "No Selection",
                    MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }

            var result = MessageBox.Show($"Are you sure you want to move {selectedItems.Count} item(s) to ready products?",
                "Confirm Move", MessageBoxButton.YesNo, MessageBoxImage.Question);

            if (result == MessageBoxResult.Yes)
            {
                foreach (var item in selectedItems)
                {
                    item.ReadyQty = item.InProcessQty;
                    item.InProcessQty = 0;
                    item.DateAdded = DateTime.Now;
                    item.ProgressPercent = 100;
                    item.IsSelected = false;

                    _allInProcessProducts.Remove(item);
                    _allReadyProducts.Add(item);
                }

                ApplyInProcessFilters();
                ApplyReadyFilters();
                await UpdateStatisticsAsync();

                MessageBox.Show($"Successfully moved {selectedItems.Count} item(s) to ready products.", "Success",
                    MessageBoxButton.OK, MessageBoxImage.Information);
            }
        }

        private async void CompleteProcess_Click(object sender, RoutedEventArgs e)
        {
            var button = sender as Button;
            var stockId = Convert.ToInt32(button?.Tag);

            var item = _allInProcessProducts.FirstOrDefault(x => x.StockId == stockId);
            if (item != null)
            {
                var result = MessageBox.Show($"Mark '{item.ProductName}' as complete and move to ready products?",
                    "Complete Process", MessageBoxButton.YesNo, MessageBoxImage.Question);

                if (result == MessageBoxResult.Yes)
                {
                    item.ReadyQty = item.InProcessQty;
                    item.InProcessQty = 0;
                    item.DateAdded = DateTime.Now;
                    item.ProgressPercent = 100;

                    _allInProcessProducts.Remove(item);
                    _allReadyProducts.Add(item);

                    ApplyInProcessFilters();
                    ApplyReadyFilters();
                    await UpdateStatisticsAsync();

                    MessageBox.Show("Item moved to ready products successfully.", "Success",
                        MessageBoxButton.OK, MessageBoxImage.Information);
                }
            }
        }

        private void UpdateProgress_Click(object sender, RoutedEventArgs e)
        {
            var button = sender as Button;
            var stockId = Convert.ToInt32(button?.Tag);

            var item = _allInProcessProducts.FirstOrDefault(x => x.StockId == stockId);
            if (item != null)
            {
                // Simulate progress update - in real app would open a dialog
                int newProgress = Math.Min(100, item.ProgressPercent + 10);
                item.ProgressPercent = newProgress;

                ApplyInProcessFilters();

                MessageBox.Show($"Progress updated to {newProgress}%", "Progress Updated",
                    MessageBoxButton.OK, MessageBoxImage.Information);
            }
        }

        #endregion

        #region Shipped Tab

        private void ApplyShippedFilters()
        {
            var filtered = _allShippedProducts.AsEnumerable();

            // Search filter
            var searchText = ShippedSearchBox?.Text?.ToLower() ?? "";
            if (!string.IsNullOrWhiteSpace(searchText))
            {
                filtered = filtered.Where(x =>
                    x.ProductName.ToLower().Contains(searchText) ||
                    x.BatchNo.ToLower().Contains(searchText) ||
                    x.Destination?.ToLower().Contains(searchText) == true ||
                    x.StockId.ToString().Contains(searchText));
            }

            // Category filter
            var selectedCategory = (ShippedCategoryFilter?.SelectedItem as ComboBoxItem)?.Content?.ToString();
            if (!string.IsNullOrEmpty(selectedCategory) && selectedCategory != "All Products")
            {
                filtered = filtered.Where(x => x.ProductCategory == selectedCategory);
            }

            // Apply pagination
            var filteredList = filtered.ToList();
            int totalItems = filteredList.Count;
            int totalPages = (int)Math.Ceiling((double)totalItems / PageSize);

            if (_shippedCurrentPage > totalPages && totalPages > 0)
                _shippedCurrentPage = totalPages;

            var pagedItems = filteredList
                .Skip((_shippedCurrentPage - 1) * PageSize)
                .Take(PageSize)
                .ToList();

            _shippedProducts.Clear();
            foreach (var item in pagedItems)
                _shippedProducts.Add(item);

            // Update pagination UI
            int startItem = totalItems > 0 ? ((_shippedCurrentPage - 1) * PageSize) + 1 : 0;
            int endItem = Math.Min(_shippedCurrentPage * PageSize, totalItems);
            ShippedShowingText.Text = $"Showing {startItem}-{endItem} of {totalItems} entries";
            ShippedPageText.Text = $"Page {_shippedCurrentPage} of {Math.Max(1, totalPages)}";
            ShippedPrevBtn.IsEnabled = _shippedCurrentPage > 1;
            ShippedNextBtn.IsEnabled = _shippedCurrentPage < totalPages;
        }

        private void ShippedSearchBox_TextChanged(object sender, TextChangedEventArgs e)
        {
            if (!_isLoaded) return;
            _shippedCurrentPage = 1;
            ApplyShippedFilters();
        }

        private void ShippedCategoryFilter_Changed(object sender, SelectionChangedEventArgs e)
        {
            if (!_isLoaded) return;
            _shippedCurrentPage = 1;
            ApplyShippedFilters();
        }

        private void ShippedPrevPage_Click(object sender, RoutedEventArgs e)
        {
            if (_shippedCurrentPage > 1)
            {
                _shippedCurrentPage--;
                ApplyShippedFilters();
            }
        }

        private void ShippedNextPage_Click(object sender, RoutedEventArgs e)
        {
            int totalPages = (int)Math.Ceiling((double)_allShippedProducts.Count / PageSize);
            if (_shippedCurrentPage < totalPages)
            {
                _shippedCurrentPage++;
                ApplyShippedFilters();
            }
        }

        private void ExportShipped_Click(object sender, RoutedEventArgs e)
        {
            MessageBox.Show("📊 EXPORT SHIPPED REPORT\n\n" +
                "Report Type: Shipped Products Summary\n" +
                "Format: Excel/PDF\n\n" +
                "Data Includes:\n" +
                "• All shipped products\n" +
                "• Quantities and dates\n" +
                "• Delivery statuses\n" +
                "• Destination details\n\n" +
                "⚡ Report will be generated when database is connected.",
                "Export Report", MessageBoxButton.OK, MessageBoxImage.Information);
        }

        private void ViewShipmentDetails_Click(object sender, RoutedEventArgs e)
        {
            var button = sender as Button;
            var stockId = Convert.ToInt32(button?.Tag);

            var item = _allShippedProducts.FirstOrDefault(x => x.StockId == stockId);
            if (item != null)
            {
                MessageBox.Show($"📦 SHIPMENT DETAILS\n\n" +
                    $"Stock ID: {item.StockId}\n" +
                    $"Batch No: {item.BatchNo}\n" +
                    $"Product: {item.ProductName}\n" +
                    $"Category: {item.ProductCategory}\n" +
                    $"Quantity Shipped: {item.ShippedQty}\n" +
                    $"Ship Date: {item.ShippedDate:MMM dd, yyyy}\n" +
                    $"Destination: {item.Destination}\n" +
                    $"Status: {item.DeliveryStatus}\n\n" +
                    "📍 Tracking information will be available when connected to shipping service.",
                    "Shipment Details", MessageBoxButton.OK, MessageBoxImage.Information);
            }
        }

        #endregion

        #region Common Actions

        private async void RefreshBtn_Click(object sender, RoutedEventArgs e)
        {
            await LoadDataFromDatabaseAsync();

            MessageBox.Show("Stock data refreshed successfully!", "Refresh Complete",
                MessageBoxButton.OK, MessageBoxImage.Information);
        }

        private async void AddStockBtn_Click(object sender, RoutedEventArgs e)
        {
            var dialog = new AddStockEntryDialog();
            dialog.Owner = Window.GetWindow(this);
            
            if (dialog.ShowDialog() == true)
            {
                // Reload data from database to show new entry
                await LoadDataFromDatabaseAsync();
            }
        }

        private void EditStock_Click(object sender, RoutedEventArgs e)
        {
            var button = sender as Button;
            var stockId = Convert.ToInt32(button?.Tag);

            MessageBox.Show($"✏️ EDIT STOCK ENTRY\n\n" +
                $"Stock ID: {stockId}\n\n" +
                "This will open the edit dialog for this stock entry.\n\n" +
                "⚡ Feature ready for database integration.",
                "Edit Stock", MessageBoxButton.OK, MessageBoxImage.Information);
        }

        private async void DeleteStock_Click(object sender, RoutedEventArgs e)
        {
            var button = sender as Button;
            var stockId = Convert.ToInt32(button?.Tag);

            var item = _allReadyProducts.FirstOrDefault(x => x.StockId == stockId);
            if (item != null)
            {
                var result = MessageBox.Show($"Are you sure you want to delete stock entry for '{item.ProductName}'?\n\nThis action cannot be undone.",
                    "Confirm Delete", MessageBoxButton.YesNo, MessageBoxImage.Warning);

                if (result == MessageBoxResult.Yes)
                {
                    _allReadyProducts.Remove(item);
                    ApplyReadyFilters();
                    await UpdateStatisticsAsync();

                    MessageBox.Show("Stock entry deleted successfully.", "Deleted",
                        MessageBoxButton.OK, MessageBoxImage.Information);
                }
            }
        }

        private void SearchBox_GotFocus(object sender, RoutedEventArgs e)
        {
            var textBox = sender as TextBox;
            if (textBox?.Text == "Search...")
            {
                textBox.Text = "";
            }
        }

        private void SearchBox_LostFocus(object sender, RoutedEventArgs e)
        {
            var textBox = sender as TextBox;
            if (string.IsNullOrWhiteSpace(textBox?.Text))
            {
                textBox.Text = "";
            }
        }

        #endregion
    }

    /// <summary>
    /// Model class for displaying stock data based on Stock entity
    /// </summary>
    public class StockDisplayModel : INotifyPropertyChanged
    {
        private bool _isSelected;

        // Stock Entity Fields (matching your diagram)
        public int StockId { get; set; }
        public int ProductId { get; set; }
        public string BatchNo { get; set; } = string.Empty;
        public int ReadyQty { get; set; }
        public int InProcessQty { get; set; }
        public int ShippedQty { get; set; }

        // Additional display properties
        public string ProductName { get; set; } = string.Empty;
        public string ProductCategory { get; set; } = string.Empty;
        public DateTime DateAdded { get; set; } = DateTime.Now;
        public DateTime ProcessStartDate { get; set; } = DateTime.Now;
        public DateTime ShippedDate { get; set; } = DateTime.Now;
        public int ProgressPercent { get; set; }
        public string Destination { get; set; } = string.Empty;
        public string DeliveryStatus { get; set; } = string.Empty;

        public bool IsSelected
        {
            get => _isSelected;
            set
            {
                _isSelected = value;
                OnPropertyChanged();
            }
        }

        public event PropertyChangedEventHandler? PropertyChanged;

        protected virtual void OnPropertyChanged([CallerMemberName] string? propertyName = null)
        {
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
        }
    }
}
