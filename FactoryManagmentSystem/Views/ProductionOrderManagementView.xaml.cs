using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Linq;
using System.Windows;
using System.Windows.Controls;
using FactoryManagmentSystem.Services;
using FactoryManagmentSystem.Models;

namespace FactoryManagmentSystem.Views
{
    public partial class ProductionOrderManagementView : UserControl
    {
        private readonly ProductionOrderDataService _productionOrderService;
        private readonly ProductMaterialDataService _materialService;
        private readonly RawMaterialDataService _rawMaterialService;
        private ObservableCollection<ProductionOrderInfo> _allOrders;
        private ObservableCollection<ProductionOrderInfo> _filteredOrders;
        private List<Product> _allProducts;
        private List<EmployeeDatabaseService.EmployeeInfo> _allTailors;
        private ObservableCollection<ProductionMaterialRequirement> _currentMaterialRequirements;

        // Pagination
        private int _currentPage = 1;
        private int _itemsPerPage = 10;
        private int _totalPages = 1;

        public ProductionOrderManagementView()
        {
            InitializeComponent();
            _productionOrderService = new ProductionOrderDataService();
            _materialService = new ProductMaterialDataService();
            _rawMaterialService = new RawMaterialDataService();
            _allOrders = new ObservableCollection<ProductionOrderInfo>();
            _filteredOrders = new ObservableCollection<ProductionOrderInfo>();
            _currentMaterialRequirements = new ObservableCollection<ProductionMaterialRequirement>();

            Loaded += ProductionOrderManagementView_Loaded;
        }

        private async void ProductionOrderManagementView_Loaded(object sender, RoutedEventArgs e)
        {
            // Set default date for Add form
            AddStartDate.SelectedDate = DateTime.Now;
            
            await LoadAllData();
        }

        #region Data Loading

        private async System.Threading.Tasks.Task LoadAllData()
        {
            try
            {
                // Load statistics
                await LoadStatistics();

                // Load production orders
                await LoadProductionOrders();

                // Load products and tailors for dropdowns
                await LoadProducts();
                await LoadTailors();

                // Populate dropdowns
                PopulateProductDropdowns();
                PopulateTailorDropdowns();
                PopulateOrderDropdowns();
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error loading data: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private async System.Threading.Tasks.Task LoadStatistics()
        {
            try
            {
                var stats = await _productionOrderService.GetProductionOrderStatisticsAsync();
                if (stats != null)
                {
                    TotalOrdersText.Text = stats.TotalOrders.ToString();
                    PendingOrdersText.Text = stats.PendingOrders.ToString();
                    InProgressOrdersText.Text = stats.InProgressOrders.ToString();
                    CompletedOrdersText.Text = stats.CompletedOrders.ToString();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error loading statistics: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private async System.Threading.Tasks.Task LoadProductionOrders()
        {
            try
            {
                var orders = await _productionOrderService.GetAllProductionOrdersAsync();
                _allOrders.Clear();
                _filteredOrders.Clear();

                foreach (var order in orders)
                {
                    _allOrders.Add(order);
                    _filteredOrders.Add(order);
                }

                UpdatePagination();
                DisplayCurrentPage();
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error loading production orders: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private async System.Threading.Tasks.Task LoadProducts()
        {
            try
            {
                var productService = new ProductDataService();
                _allProducts = await productService.GetAllProductsAsync();
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error loading products: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
                _allProducts = new List<Product>();
            }
        }

        private async System.Threading.Tasks.Task LoadTailors()
        {
            try
            {
                var employeeService = new EmployeeDatabaseService();
                _allTailors = await employeeService.GetTailorsAsync();

                // If no specific tailors found, get all employees as fallback
                if (_allTailors.Count == 0)
                {
                    _allTailors = await employeeService.GetAllEmployeesAsync();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error loading tailors: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
                _allTailors = new List<EmployeeDatabaseService.EmployeeInfo>();
            }
        }

        #endregion

        #region Dropdown Population

        private void PopulateProductDropdowns()
        {
            // Add New Order dropdown
            AddProductCombo.Items.Clear();
            AddProductCombo.Items.Add(new ComboBoxItem { Content = "Select Product", Tag = null });
            foreach (var product in _allProducts)
            {
                AddProductCombo.Items.Add(new ComboBoxItem
                {
                    Content = $"{product.Name} - {product.Category} ({product.SKU})",
                    Tag = product.ProductId
                });
            }
            AddProductCombo.SelectedIndex = 0;
        }

        private void PopulateTailorDropdowns()
        {
            // Add New Order dropdown
            AddCreatedByCombo.Items.Clear();
            AddCreatedByCombo.Items.Add(new ComboBoxItem { Content = "Select Tailor", Tag = null });
            foreach (var tailor in _allTailors)
            {
                AddCreatedByCombo.Items.Add(new ComboBoxItem
                {
                    Content = $"{tailor.FirstName} {tailor.LastName}",
                    Tag = tailor.EmployeeID
                });
            }
            AddCreatedByCombo.SelectedIndex = 0;

            // Update Order dropdown
            UpdateCreatedByCombo.Items.Clear();
            UpdateCreatedByCombo.Items.Add(new ComboBoxItem { Content = "Select Tailor", Tag = null });
            foreach (var tailor in _allTailors)
            {
                UpdateCreatedByCombo.Items.Add(new ComboBoxItem
                {
                    Content = $"{tailor.FirstName} {tailor.LastName}",
                    Tag = tailor.EmployeeID
                });
            }
            UpdateCreatedByCombo.SelectedIndex = 0;
        }

        private void PopulateOrderDropdowns()
        {
            // Update Order dropdown
            UpdateOrderCombo.Items.Clear();
            UpdateOrderCombo.Items.Add(new ComboBoxItem { Content = "Select Production Order", Tag = null });
            foreach (var order in _allOrders)
            {
                UpdateOrderCombo.Items.Add(new ComboBoxItem
                {
                    Content = $"Order #{order.ProductionOrderID} - {order.ProductName} ({order.Status})",
                    Tag = order.ProductionOrderID
                });
            }
            UpdateOrderCombo.SelectedIndex = 0;

            // Delete Order dropdown
            DeleteOrderCombo.Items.Clear();
            DeleteOrderCombo.Items.Add(new ComboBoxItem { Content = "Select Production Order", Tag = null });
            foreach (var order in _allOrders)
            {
                DeleteOrderCombo.Items.Add(new ComboBoxItem
                {
                    Content = $"Order #{order.ProductionOrderID} - {order.ProductName} ({order.Status})",
                    Tag = order.ProductionOrderID
                });
            }
            DeleteOrderCombo.SelectedIndex = 0;
        }

        #endregion

        #region Tab Navigation

        private void TabBtn_Click(object sender, RoutedEventArgs e)
        {
            if (sender is Button button)
            {
                // Reset all tabs
                BrowseTab.Style = (Style)FindResource("TabBtn");
                AddTab.Style = (Style)FindResource("TabBtn");
                UpdateTab.Style = (Style)FindResource("TabBtn");
                DeleteTab.Style = (Style)FindResource("TabBtn");

                BrowseContent.Visibility = Visibility.Collapsed;
                AddContent.Visibility = Visibility.Collapsed;
                UpdateContent.Visibility = Visibility.Collapsed;
                DeleteContent.Visibility = Visibility.Collapsed;

                // Activate selected tab
                button.Style = (Style)FindResource("ActiveTabBtn");

                string tag = button.Tag?.ToString() ?? "";
                switch (tag)
                {
                    case "Browse":
                        BrowseContent.Visibility = Visibility.Visible;
                        break;
                    case "Add":
                        AddContent.Visibility = Visibility.Visible;
                        break;
                    case "Update":
                        UpdateContent.Visibility = Visibility.Visible;
                        break;
                    case "Delete":
                        DeleteContent.Visibility = Visibility.Visible;
                        break;
                }
            }
        }

        #endregion

        #region Browse Tab - Filtering and Pagination

        private void SearchBox_TextChanged(object sender, TextChangedEventArgs e)
        {
            ApplyFilters();
        }

        private void SearchBtn_Click(object sender, RoutedEventArgs e)
        {
            ApplyFilters();
        }

        private void StatusFilter_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            ApplyFilters();
        }

        private void PriorityFilter_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            ApplyFilters();
        }

        private void DateFilter_Changed(object sender, SelectionChangedEventArgs e)
        {
            ApplyFilters();
        }

        private void ApplyFilters()
        {
            if (_allOrders == null) return;

            _filteredOrders.Clear();

            string searchTerm = SearchBox?.Text?.ToLower() ?? "";
            string selectedStatus = (StatusFilter?.SelectedItem as ComboBoxItem)?.Content?.ToString() ?? "All Status";
            string selectedPriority = (PriorityFilter?.SelectedItem as ComboBoxItem)?.Content?.ToString() ?? "All Priorities";
            DateTime? startDate = StartDateFilter?.SelectedDate;
            DateTime? endDate = EndDateFilter?.SelectedDate;

            foreach (var order in _allOrders)
            {
                bool matchesSearch = string.IsNullOrEmpty(searchTerm) ||
                                   order.ProductionOrderID.ToString().Contains(searchTerm) ||
                                   (order.ProductName?.ToLower().Contains(searchTerm) ?? false) ||
                                   (order.Category?.ToLower().Contains(searchTerm) ?? false);

                bool matchesStatus = selectedStatus == "All Status" || order.Status == selectedStatus;
                bool matchesPriority = selectedPriority == "All Priorities" || order.Priority == selectedPriority;

                bool matchesDate = true;
                if (startDate.HasValue && order.StartDate < startDate.Value)
                    matchesDate = false;
                if (endDate.HasValue && order.StartDate > endDate.Value)
                    matchesDate = false;

                if (matchesSearch && matchesStatus && matchesPriority && matchesDate)
                {
                    _filteredOrders.Add(order);
                }
            }

            _currentPage = 1;
            UpdatePagination();
            DisplayCurrentPage();
        }

        private void UpdatePagination()
        {
            if (_filteredOrders == null || _filteredOrders.Count == 0)
            {
                _totalPages = 1;
                ShowingText.Text = "No entries found";
                PageText.Text = "Page 0 of 0";
                PrevBtn.IsEnabled = false;
                NextBtn.IsEnabled = false;
                return;
            }

            _totalPages = (int)Math.Ceiling((double)_filteredOrders.Count / _itemsPerPage);
            if (_currentPage > _totalPages) _currentPage = _totalPages;

            int startIndex = (_currentPage - 1) * _itemsPerPage + 1;
            int endIndex = Math.Min(_currentPage * _itemsPerPage, _filteredOrders.Count);

            ShowingText.Text = $"Showing {startIndex}-{endIndex} of {_filteredOrders.Count} entries";
            PageText.Text = $"Page {_currentPage} of {_totalPages}";

            PrevBtn.IsEnabled = _currentPage > 1;
            NextBtn.IsEnabled = _currentPage < _totalPages;
        }

        private void DisplayCurrentPage()
        {
            if (_filteredOrders == null || _filteredOrders.Count == 0)
            {
                OrdersGrid.ItemsSource = null;
                return;
            }

            int startIndex = (_currentPage - 1) * _itemsPerPage;
            var pageItems = _filteredOrders.Skip(startIndex).Take(_itemsPerPage).ToList();
            OrdersGrid.ItemsSource = pageItems;
        }

        private void PrevPage_Click(object sender, RoutedEventArgs e)
        {
            if (_currentPage > 1)
            {
                _currentPage--;
                UpdatePagination();
                DisplayCurrentPage();
            }
        }

        private void NextPage_Click(object sender, RoutedEventArgs e)
        {
            if (_currentPage < _totalPages)
            {
                _currentPage++;
                UpdatePagination();
                DisplayCurrentPage();
            }
        }

        private async void RefreshBtn_Click(object sender, RoutedEventArgs e)
        {
            await LoadAllData();
            MessageBox.Show("Data refreshed successfully!", "Success", MessageBoxButton.OK, MessageBoxImage.Information);
        }

        #endregion

        #region Browse Tab - Actions

        private async void ViewOrder_Click(object sender, RoutedEventArgs e)
        {
            if (sender is Button button && button.Tag != null)
            {
                int orderId = Convert.ToInt32(button.Tag);
                var order = await _productionOrderService.GetProductionOrderByIdAsync(orderId);

                if (order != null)
                {
                    string details = $"Production Order Details:\n\n" +
                                   $"Order ID: {order.ProductionOrderID}\n" +
                                   $"Product: {order.ProductName}\n" +
                                   $"Category: {order.Category}\n" +
                                   $"SKU: {order.SKU}\n" +
                                   $"Quantity Ordered: {order.QuantityOrdered}\n" +
                                   $"Quantity Completed: {order.QuantityCompleted}\n" +
                                   $"Remaining: {order.RemainingQuantity}\n" +
                                   $"Completion: {order.CompletionPercentage:F1}%\n" +
                                   $"Start Date: {order.StartDate:dd/MM/yyyy}\n" +
                                   $"Expected End: {(order.ExpectedEndDate.HasValue ? order.ExpectedEndDate.Value.ToString("dd/MM/yyyy") : "N/A")}\n" +
                                   $"Actual End: {(order.ActualEndDate.HasValue ? order.ActualEndDate.Value.ToString("dd/MM/yyyy") : "N/A")}\n" +
                                   $"Status: {order.Status}\n" +
                                   $"Priority: {order.Priority}\n" +
                                   $"Created By: {order.CreatedByName}\n" +
                                   $"Created Date: {order.CreatedDate:dd/MM/yyyy HH:mm}\n" +
                                   $"Notes: {order.Notes}";

                    MessageBox.Show(details, "Order Details", MessageBoxButton.OK, MessageBoxImage.Information);
                }
            }
        }

        private void EditOrder_Click(object sender, RoutedEventArgs e)
        {
            if (sender is Button button && button.Tag != null)
            {
                int orderId = Convert.ToInt32(button.Tag);

                // Switch to Update tab
                UpdateTab.Style = (Style)FindResource("ActiveTabBtn");
                BrowseTab.Style = (Style)FindResource("TabBtn");
                BrowseContent.Visibility = Visibility.Collapsed;
                UpdateContent.Visibility = Visibility.Visible;

                // Select the order in the dropdown
                foreach (ComboBoxItem item in UpdateOrderCombo.Items)
                {
                    if (item.Tag != null && Convert.ToInt32(item.Tag) == orderId)
                    {
                        UpdateOrderCombo.SelectedItem = item;
                        break;
                    }
                }
            }
        }

        private async void DeleteOrderQuick_Click(object sender, RoutedEventArgs e)
        {
            if (sender is Button button && button.Tag != null)
            {
                int orderId = Convert.ToInt32(button.Tag);
                var order = await _productionOrderService.GetProductionOrderByIdAsync(orderId);

                if (order != null)
                {
                    var result = MessageBox.Show(
                        $"Are you sure you want to delete this production order?\n\n" +
                        $"Order ID: {order.ProductionOrderID}\n" +
                        $"Product: {order.ProductName}\n" +
                        $"Quantity: {order.QuantityOrdered}\n" +
                        $"Status: {order.Status}\n\n" +
                        $"This action cannot be undone!",
                        "Confirm Delete",
                        MessageBoxButton.YesNo,
                        MessageBoxImage.Warning);

                    if (result == MessageBoxResult.Yes)
                    {
                        try
                        {
                            await _productionOrderService.DeleteProductionOrderAsync(orderId);
                            MessageBox.Show("Production order deleted successfully!", "Success", MessageBoxButton.OK, MessageBoxImage.Information);
                            await LoadAllData();
                        }
                        catch (Exception ex)
                        {
                            MessageBox.Show($"Error deleting order: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
                        }
                    }
                }
            }
        }

        #endregion

        #region Add New Order Tab

        private async void AddProductCombo_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            // Show material requirements inline (no popup)
            await LoadMaterialRequirementsInline();
        }

        private async void AddQuantityText_LostFocus(object sender, RoutedEventArgs e)
        {
            // Refresh material requirements when quantity changes
            await LoadMaterialRequirementsInline();
        }

        private async System.Threading.Tasks.Task LoadMaterialRequirementsInline()
        {
            try
            {
                // NULL CHECKS FOR UI ELEMENTS
                if (MaterialRequirementsPanel == null || AddProductCombo == null || AddQuantityText == null)
                    return;

                // Hide panel if no product selected
                if (AddProductCombo.SelectedIndex <= 0)
                {
                    MaterialRequirementsPanel.Visibility = Visibility.Collapsed;
                    return;
                }

                int productId = Convert.ToInt32(((ComboBoxItem)AddProductCombo.SelectedItem).Tag);
                string productName = ((ComboBoxItem)AddProductCombo.SelectedItem).Content.ToString();
                
                // Get quantity
                if (!int.TryParse(AddQuantityText.Text, out int quantity) || quantity <= 0)
                {
                    quantity = 1;
                    AddQuantityText.Text = "1";
                }

                // Fetch material requirements with real-time stock calculation
                var materials = await _materialService.CalculateProductionOrderMaterialsAsync(productId, quantity);

                if (materials == null || materials.Count == 0)
                {
                    MaterialRequirementsPanel.Visibility = Visibility.Collapsed;
                    MessageBox.Show($"⚠️ No Material Requirements Defined\n\n" +
                                   $"Product: {productName}\n\n" +
                                   $"This product has no Bill of Materials (BOM).\n" +
                                   $"Please add material requirements before creating production orders.", 
                                   "Missing BOM", 
                                   MessageBoxButton.OK, 
                                   MessageBoxImage.Warning);
                    return;
                }

                // Show the materials panel
                MaterialRequirementsPanel.Visibility = Visibility.Visible;
                MaterialRequirementsTitle.Text = $"For: {productName} × {quantity} units";

                // Bind to DataGrid
                _currentMaterialRequirements.Clear();
                decimal totalCost = 0;

                foreach (var material in materials)
                {
                    _currentMaterialRequirements.Add(material);
                    totalCost += material.TotalMaterialCost;
                }

                MaterialRequirementsGrid.ItemsSource = _currentMaterialRequirements;
                TotalMaterialCostText.Text = $"Rs. {totalCost:N2}";
            }
            catch (Exception ex)
            {
                MaterialRequirementsPanel.Visibility = Visibility.Collapsed;
                MessageBox.Show($"Error loading material requirements: {ex.Message}", 
                               "Error", 
                               MessageBoxButton.OK, 
                               MessageBoxImage.Error);
            }
        }

        private void ResetAddForm_Click(object sender, RoutedEventArgs e)
        {
            AddProductCombo.SelectedIndex = 0;
            AddQuantityText.Text = "1";
            AddStartDate.SelectedDate = DateTime.Now;
            AddExpectedEndDate.SelectedDate = null;
            AddPriorityCombo.SelectedIndex = 1; // Normal
            AddCreatedByCombo.SelectedIndex = 0;
            AddNotesText.Text = "";
        }

        private async void CreateOrder_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                // Validation
                if (AddProductCombo.SelectedIndex <= 0)
                {
                    MessageBox.Show("Please select a product.", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                    return;
                }

                if (!int.TryParse(AddQuantityText.Text, out int quantity) || quantity <= 0)
                {
                    MessageBox.Show("Please enter a valid quantity (greater than 0).", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                    return;
                }

                if (!AddStartDate.SelectedDate.HasValue)
                {
                    MessageBox.Show("Please select a start date.", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                    return;
                }

                // Get values
                int productId = Convert.ToInt32(((ComboBoxItem)AddProductCombo.SelectedItem).Tag);
                DateTime startDate = AddStartDate.SelectedDate.Value;
                DateTime? expectedEndDate = AddExpectedEndDate.SelectedDate;
                string priority = ((ComboBoxItem)AddPriorityCombo.SelectedItem).Content.ToString();
                int? createdByEmployeeId = AddCreatedByCombo.SelectedIndex > 0 ? 
                    Convert.ToInt32(((ComboBoxItem)AddCreatedByCombo.SelectedItem).Tag) : (int?)null;
                string notes = AddNotesText.Text;

                // CRITICAL: Check material availability BEFORE creating production order
                var materialRequirements = await _materialService.CalculateProductionOrderMaterialsAsync(productId, quantity);
                
                if (materialRequirements == null || materialRequirements.Count == 0)
                {
                    MessageBox.Show("❌ Cannot create production order!\n\n" +
                                   "This product has no Bill of Materials (BOM) defined.\n\n" +
                                   "Please add material requirements to this product first.", 
                                   "No Materials Defined", 
                                   MessageBoxButton.OK, 
                                   MessageBoxImage.Error);
                    return;
                }

                // Check if ANY material is insufficient - STRICT CHECK
                var insufficientMaterials = materialRequirements.Where(m => 
                    m.StockStatus.Contains("Insufficient") || 
                    m.AvailableStock < m.TotalQuantityRequired).ToList();
                
                if (insufficientMaterials.Any())
                {
                    // Build detailed error message
                    string errorMessage = "❌ INSUFFICIENT RAW MATERIALS!\n\n" +
                                         $"Cannot create production order for {quantity} units.\n\n" +
                                         $"The following materials are SHORT:\n\n";
                    
                    foreach (var material in insufficientMaterials)
                    {
                        decimal shortage = material.TotalQuantityRequired - material.AvailableStock;
                        errorMessage += $"❌ {material.MaterialName}\n" +
                                       $"   Required: {material.TotalQuantityRequired:N2} {material.Unit}\n" +
                                       $"   Available: {material.AvailableStock:N2} {material.Unit}\n" +
                                       $"   SHORT BY: {shortage:N2} {material.Unit}\n\n";
                    }
                    
                    errorMessage += "🛑 PRODUCTION ORDER BLOCKED!\n" +
                                   "Please restock materials before creating this order.";
                    
                    MessageBox.Show(errorMessage, 
                                   "INSUFFICIENT MATERIALS - ORDER BLOCKED", 
                                   MessageBoxButton.OK, 
                                   MessageBoxImage.Error);
                    return;
                }

                // Create order
                var orderInfo = new ProductionOrderInfo
                {
                    ProductID = productId,
                    QuantityOrdered = quantity,
                    StartDate = startDate,
                    ExpectedEndDate = expectedEndDate,
                    Priority = priority,
                    CreatedByEmployeeID = createdByEmployeeId,
                    Notes = notes
                };

                int newOrderId = await _productionOrderService.CreateProductionOrderAsync(orderInfo);

                // AUTO-DEDUCT MATERIALS FROM STOCK
                int materialsDeducted = 0;
                foreach (var material in materialRequirements)
                {
                    try
                    {
                        // Deduct the material from RawMaterial stock
                        await _rawMaterialService.UpdateRawMaterialStockAsync(
                            material.RawMaterialID, 
                            -material.TotalQuantityRequired);  // Negative to deduct
                        materialsDeducted++;
                    }
                    catch (Exception ex)
                    {
                        // Log error but continue (order already created)
                        System.Diagnostics.Debug.WriteLine($"Error deducting material {material.MaterialName}: {ex.Message}");
                    }
                }

                MessageBox.Show($"✅ Production Order Created Successfully!\n\n" +
                               $"Order ID: {newOrderId}\n" +
                               $"Product: {((ComboBoxItem)AddProductCombo.SelectedItem).Content}\n" +
                               $"Quantity: {quantity} units\n\n" +
                               $"📦 Materials automatically deducted from stock:\n" +
                               $"   {materialsDeducted} material(s) updated", 
                    "Success", MessageBoxButton.OK, MessageBoxImage.Information);

                // Reset form and refresh data
                ResetAddForm_Click(null, null);
                await LoadAllData();

                // Switch to browse tab
                BrowseTab.Style = (Style)FindResource("ActiveTabBtn");
                AddTab.Style = (Style)FindResource("TabBtn");
                AddContent.Visibility = Visibility.Collapsed;
                BrowseContent.Visibility = Visibility.Visible;
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error creating production order: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        #endregion

        #region Update Order Tab

        private async void UpdateOrderCombo_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            // Check if UI controls are initialized
            if (UpdateFormPanel == null)
                return;
                
            if (UpdateOrderCombo.SelectedIndex <= 0)
            {
                UpdateFormPanel.Visibility = Visibility.Collapsed;
                return;
            }

            try
            {
                int orderId = Convert.ToInt32(((ComboBoxItem)UpdateOrderCombo.SelectedItem).Tag);
                var order = await _productionOrderService.GetProductionOrderByIdAsync(orderId);

                if (order != null)
                {
                    UpdateFormPanel.Visibility = Visibility.Visible;

                    // Populate form
                    UpdateProductText.Text = $"{order.ProductName} - {order.Category}";
                    UpdateQuantityOrderedText.Text = order.QuantityOrdered.ToString();
                    UpdateQuantityCompletedText.Text = order.QuantityCompleted.ToString();
                    UpdateStartDate.SelectedDate = order.StartDate;
                    UpdateExpectedEndDate.SelectedDate = order.ExpectedEndDate;
                    UpdateActualEndDate.SelectedDate = order.ActualEndDate;
                    UpdateNotesText.Text = order.Notes;

                    // Set status
                    foreach (ComboBoxItem item in UpdateStatusCombo.Items)
                    {
                        if (item.Content.ToString() == order.Status)
                        {
                            UpdateStatusCombo.SelectedItem = item;
                            break;
                        }
                    }

                    // Set priority
                    foreach (ComboBoxItem item in UpdatePriorityCombo.Items)
                    {
                        if (item.Content.ToString() == order.Priority)
                        {
                            UpdatePriorityCombo.SelectedItem = item;
                            break;
                        }
                    }

                    // Set created by
                    if (order.CreatedByEmployeeID.HasValue)
                    {
                        foreach (ComboBoxItem item in UpdateCreatedByCombo.Items)
                        {
                            if (item.Tag != null && Convert.ToInt32(item.Tag) == order.CreatedByEmployeeID.Value)
                            {
                                UpdateCreatedByCombo.SelectedItem = item;
                                break;
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error loading order details: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void ResetUpdateForm_Click(object sender, RoutedEventArgs e)
        {
            UpdateOrderCombo.SelectedIndex = 0;
            UpdateFormPanel.Visibility = Visibility.Collapsed;
        }

        private async void UpdateOrder_Click(object sender, RoutedEventArgs e)
        {
            if (UpdateOrderCombo.SelectedIndex <= 0)
            {
                MessageBox.Show("Please select an order to update.", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }

            try
            {
                // Validation
                if (!int.TryParse(UpdateQuantityOrderedText.Text, out int quantityOrdered) || quantityOrdered <= 0)
                {
                    MessageBox.Show("Please enter a valid quantity ordered (greater than 0).", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                    return;
                }

                if (!int.TryParse(UpdateQuantityCompletedText.Text, out int quantityCompleted) || quantityCompleted < 0)
                {
                    MessageBox.Show("Please enter a valid quantity completed (0 or greater).", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                    return;
                }

                if (quantityCompleted > quantityOrdered)
                {
                    MessageBox.Show("Quantity completed cannot exceed quantity ordered.", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                    return;
                }

                // Get values
                int orderId = Convert.ToInt32(((ComboBoxItem)UpdateOrderCombo.SelectedItem).Tag);
                var currentOrder = await _productionOrderService.GetProductionOrderByIdAsync(orderId);

                var orderInfo = new ProductionOrderInfo
                {
                    ProductionOrderID = orderId,
                    ProductID = currentOrder.ProductID,
                    QuantityOrdered = quantityOrdered,
                    QuantityCompleted = quantityCompleted,
                    StartDate = UpdateStartDate.SelectedDate ?? currentOrder.StartDate,
                    ExpectedEndDate = UpdateExpectedEndDate.SelectedDate,
                    ActualEndDate = UpdateActualEndDate.SelectedDate,
                    Status = ((ComboBoxItem)UpdateStatusCombo.SelectedItem).Content.ToString(),
                    Priority = ((ComboBoxItem)UpdatePriorityCombo.SelectedItem).Content.ToString(),
                    CreatedByEmployeeID = UpdateCreatedByCombo.SelectedIndex > 0 ? 
                        Convert.ToInt32(((ComboBoxItem)UpdateCreatedByCombo.SelectedItem).Tag) : currentOrder.CreatedByEmployeeID,
                    Notes = UpdateNotesText.Text
                };

                await _productionOrderService.UpdateProductionOrderAsync(orderInfo);

                MessageBox.Show("Production order updated successfully!", "Success", MessageBoxButton.OK, MessageBoxImage.Information);

                // Reset form and refresh data
                ResetUpdateForm_Click(null, null);
                await LoadAllData();

                // Switch to browse tab
                BrowseTab.Style = (Style)FindResource("ActiveTabBtn");
                UpdateTab.Style = (Style)FindResource("TabBtn");
                UpdateContent.Visibility = Visibility.Collapsed;
                BrowseContent.Visibility = Visibility.Visible;
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error updating production order: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        #endregion

        #region Delete Order Tab

        private async void DeleteOrderCombo_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            // Check if UI controls are initialized
            if (DeleteOrderDetails == null || ConfirmDeleteBtn == null)
                return;
                
            if (DeleteOrderCombo.SelectedIndex <= 0 || DeleteOrderCombo.SelectedItem == null)
            {
                DeleteOrderDetails.Visibility = Visibility.Collapsed;
                ConfirmDeleteBtn.IsEnabled = false;
                return;
            }

            try
            {
                var selectedItem = DeleteOrderCombo.SelectedItem as ComboBoxItem;
                if (selectedItem == null || selectedItem.Tag == null)
                {
                    DeleteOrderDetails.Visibility = Visibility.Collapsed;
                    ConfirmDeleteBtn.IsEnabled = false;
                    return;
                }
                
                int orderId = Convert.ToInt32(selectedItem.Tag);
                var order = await _productionOrderService.GetProductionOrderByIdAsync(orderId);

                if (order != null)
                {
                    DeleteOrderDetails.Visibility = Visibility.Visible;
                    ConfirmDeleteBtn.IsEnabled = true;

                    DeleteOrderIdText.Text = $"Order ID: {order.ProductionOrderID}";
                    DeleteProductText.Text = $"Product: {order.ProductName} - {order.Category}";
                    DeleteQuantityText.Text = $"Quantity: {order.QuantityOrdered} (Completed: {order.QuantityCompleted})";
                    DeleteStatusText.Text = $"Status: {order.Status}";
                    DeleteCreatedByText.Text = $"Created By: {order.CreatedByName}";
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error loading order details: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void ResetDeleteForm_Click(object sender, RoutedEventArgs e)
        {
            DeleteOrderCombo.SelectedIndex = 0;
            DeleteOrderDetails.Visibility = Visibility.Collapsed;
            ConfirmDeleteBtn.IsEnabled = false;
        }

        private async void ConfirmDelete_Click(object sender, RoutedEventArgs e)
        {
            if (DeleteOrderCombo.SelectedIndex <= 0)
            {
                return;
            }

            try
            {
                int orderId = Convert.ToInt32(((ComboBoxItem)DeleteOrderCombo.SelectedItem).Tag);

                var result = MessageBox.Show(
                    "Are you sure you want to delete this production order?\n\n" +
                    "This will also delete:\n" +
                    "- All production order items (raw materials)\n" +
                    "- All related tailor tasks\n" +
                    "- All related stock usage records\n\n" +
                    "This action cannot be undone!",
                    "Confirm Delete",
                    MessageBoxButton.YesNo,
                    MessageBoxImage.Warning);

                if (result == MessageBoxResult.Yes)
                {
                    await _productionOrderService.DeleteProductionOrderAsync(orderId);

                    MessageBox.Show("Production order deleted successfully!", "Success", MessageBoxButton.OK, MessageBoxImage.Information);

                    // Reset form and refresh data
                    ResetDeleteForm_Click(null, null);
                    await LoadAllData();

                    // Switch to browse tab
                    BrowseTab.Style = (Style)FindResource("ActiveTabBtn");
                    DeleteTab.Style = (Style)FindResource("TabBtn");
                    DeleteContent.Visibility = Visibility.Collapsed;
                    BrowseContent.Visibility = Visibility.Visible;
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error deleting production order: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        #endregion
    }
}
