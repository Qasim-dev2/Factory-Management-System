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
    public partial class SalesOrdersManagementView : UserControl
    {
        private readonly SalesOrderDataService _dataService;
        
        // Data collections
        private ObservableCollection<SalesOrderModel> _orders = new();
        private List<SalesOrderModel> _allOrders = new();
        private List<RetailerInfo> _retailers = new();
        private List<SalespersonInfo> _salespersons = new();
        private ObservableCollection<OrderItemModel> _orderItems = new();
        private ObservableCollection<OrderItemModel> _updateOrderItems = new();
        private List<ProductForOrder> _products = new();

        // Pagination
        private int _currentPage = 1;
        private const int PageSize = 10;

        private bool _isLoaded = false;

        public SalesOrdersManagementView()
        {
            InitializeComponent();
            _dataService = new SalesOrderDataService();
            
            OrdersGrid.ItemsSource = _orders;
            CreateOrderItemsGrid.ItemsSource = _orderItems;
            UpdateOrderItemsGrid.ItemsSource = _updateOrderItems;

            _isLoaded = true;
            
            Loaded += async (s, e) => await LoadDataAsync();
        }
        
        private async System.Threading.Tasks.Task LoadDataAsync()
        {
            try
            {
                await LoadOrdersAsync();
                await LoadComboBoxesAsync();
                UpdateStatistics();
                ApplyFilters();
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error loading data: {ex.Message}", "Error",
                    MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }
        
        private async System.Threading.Tasks.Task LoadOrdersAsync()
        {
            try
            {
                var orders = await _dataService.GetAllSalesOrdersAsync();
                
                _allOrders = orders.Select(o => new SalesOrderModel
                {
                    SalesOrderId = o.SalesOrderID,
                    RetailerId = o.RetailerID,
                    RetailerName = o.RetailerName ?? "",
                    SalespersonId = o.SalesRepID.GetValueOrDefault(0),
                    SalespersonName = o.SalesRepName ?? "",
                    OrderDate = o.OrderDate,
                    TotalAmount = o.TotalAmount,
                    Status = o.Status ?? ""
                }).ToList();
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error loading orders: {ex.Message}", "Error",
                    MessageBoxButton.OK, MessageBoxImage.Error);
                _allOrders = new List<SalesOrderModel>();
            }
        }

        private async System.Threading.Tasks.Task LoadComboBoxesAsync()
        {
            try
            {
                // Load retailers from database
                var retailers = await _dataService.GetRetailersForOrderAsync();
                _retailers = retailers.Select(r => new RetailerInfo
                {
                    RetailerId = r.RetailerID,
                    Name = r.CompanyName
                }).ToList();
                
                // Load salespersons from database
                var salespersons = await _dataService.GetSalespersonsForOrderAsync();
                _salespersons = salespersons.Select(s => new SalespersonInfo
                {
                    SalespersonId = s.EmployeeID,
                    Name = s.FullName
                }).ToList();
                
                // Load products from database
                await LoadProductsAsync();
                
                // Load Retailers for Create/Update forms
                LoadRetailerComboBox(CreateRetailer);
                LoadRetailerComboBox(UpdateRetailer);

                // Load Salespersons for Create/Update forms
                LoadSalespersonComboBox(CreateSalesperson);
                LoadSalespersonComboBox(UpdateSalesperson);

                // Load Order select for Update/Delete
                LoadOrderSelectComboBox();
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error loading dropdown data: {ex.Message}", "Error",
                    MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void LoadRetailerComboBox(ComboBox comboBox)
        {
            while (comboBox.Items.Count > 1)
                comboBox.Items.RemoveAt(1);

            foreach (var retailer in _retailers)
            {
                comboBox.Items.Add(new ComboBoxItem
                {
                    Content = retailer.Name,
                    Tag = retailer.RetailerId
                });
            }
        }

        private void LoadSalespersonComboBox(ComboBox comboBox)
        {
            while (comboBox.Items.Count > 1)
                comboBox.Items.RemoveAt(1);

            foreach (var salesperson in _salespersons)
            {
                comboBox.Items.Add(new ComboBoxItem
                {
                    Content = salesperson.Name,
                    Tag = salesperson.SalespersonId
                });
            }
        }

        private void LoadOrderSelectComboBox()
        {
            while (UpdateOrderSelect.Items.Count > 1)
                UpdateOrderSelect.Items.RemoveAt(1);
            while (DeleteOrderSelect.Items.Count > 1)
                DeleteOrderSelect.Items.RemoveAt(1);

            foreach (var order in _allOrders)
            {
                var displayText = $"[{order.SalesOrderId}] {order.RetailerName} - ₨{order.TotalAmount:N0}";

                UpdateOrderSelect.Items.Add(new ComboBoxItem
                {
                    Content = displayText,
                    Tag = order.SalesOrderId
                });
                DeleteOrderSelect.Items.Add(new ComboBoxItem
                {
                    Content = displayText,
                    Tag = order.SalesOrderId
                });
            }
        }

        private void UpdateStatistics()
        {
            TotalOrdersText.Text = _allOrders.Count.ToString();
            NotDeliveredText.Text = _allOrders.Count(o => o.Status == "Not Delivered").ToString();
            DeliveredText.Text = _allOrders.Count(o => o.Status == "Delivered").ToString();
            TotalRevenueText.Text = $"₨{_allOrders.Sum(o => o.TotalAmount):N0}";
        }

        private void ApplyFilters()
        {
            if (!_isLoaded) return;

            var filtered = _allOrders.AsEnumerable();

            // Search filter
            var searchText = SearchBox?.Text?.ToLower() ?? "";
            if (!string.IsNullOrWhiteSpace(searchText))
            {
                filtered = filtered.Where(o =>
                    o.RetailerName.ToLower().Contains(searchText) ||
                    o.SalespersonName.ToLower().Contains(searchText) ||
                    o.SalesOrderId.ToString().Contains(searchText) ||
                    o.TotalAmount.ToString().Contains(searchText));
            }

            // Status filter
            var selectedStatus = (StatusFilter?.SelectedItem as ComboBoxItem)?.Content?.ToString();
            if (!string.IsNullOrEmpty(selectedStatus) && selectedStatus != "All Status")
            {
                filtered = filtered.Where(o => o.Status == selectedStatus);
            }

            // Apply pagination
            var filteredList = filtered.ToList();
            int totalItems = filteredList.Count;
            int totalPages = (int)Math.Ceiling((double)totalItems / PageSize);

            if (_currentPage > totalPages && totalPages > 0)
                _currentPage = totalPages;

            var pagedItems = filteredList
                .Skip((_currentPage - 1) * PageSize)
                .Take(PageSize)
                .ToList();

            _orders.Clear();
            foreach (var item in pagedItems)
                _orders.Add(item);

            // Update pagination UI
            int startItem = totalItems > 0 ? ((_currentPage - 1) * PageSize) + 1 : 0;
            int endItem = Math.Min(_currentPage * PageSize, totalItems);
            ShowingText.Text = $"Showing {startItem}-{endItem} of {totalItems} entries";
            PageText.Text = $"Page {_currentPage} of {Math.Max(1, totalPages)}";
            PrevBtn.IsEnabled = _currentPage > 1;
            NextBtn.IsEnabled = _currentPage < totalPages;
        }

        #region Tab Navigation

        private void TabBtn_Click(object sender, RoutedEventArgs e)
        {
            var button = sender as Button;
            var tabName = button?.Tag?.ToString();

            if (string.IsNullOrEmpty(tabName)) return;

            // Reset all tab styles
            ViewAllTab.Style = (Style)Resources["TabBtn"];
            CreateOrderTab.Style = (Style)Resources["TabBtn"];
            UpdateOrderTab.Style = (Style)Resources["TabBtn"];
            DeleteOrderTab.Style = (Style)Resources["TabBtn"];

            // Set active tab style
            button.Style = (Style)Resources["ActiveTabBtn"];

            // Hide all content
            ViewAllContent.Visibility = Visibility.Collapsed;
            CreateOrderContent.Visibility = Visibility.Collapsed;
            UpdateOrderContent.Visibility = Visibility.Collapsed;
            DeleteOrderContent.Visibility = Visibility.Collapsed;

            // Show selected content
            switch (tabName)
            {
                case "ViewAll":
                    ViewAllContent.Visibility = Visibility.Visible;
                    break;
                case "Create":
                    CreateOrderContent.Visibility = Visibility.Visible;
                    CreateOrderDate.SelectedDate = DateTime.Now;
                    break;
                case "Update":
                    UpdateOrderContent.Visibility = Visibility.Visible;
                    break;
                case "Delete":
                    DeleteOrderContent.Visibility = Visibility.Visible;
                    break;
            }
        }

        #endregion

        #region View All Tab

        private void SearchBox_TextChanged(object sender, TextChangedEventArgs e)
        {
            if (!_isLoaded) return;
            _currentPage = 1;
            ApplyFilters();
        }

        private void StatusFilter_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            if (!_isLoaded) return;
            _currentPage = 1;
            ApplyFilters();
        }

        private void SearchBtn_Click(object sender, RoutedEventArgs e)
        {
            _currentPage = 1;
            ApplyFilters();
        }

        private void PrevPage_Click(object sender, RoutedEventArgs e)
        {
            if (_currentPage > 1)
            {
                _currentPage--;
                ApplyFilters();
            }
        }

        private void NextPage_Click(object sender, RoutedEventArgs e)
        {
            int totalPages = (int)Math.Ceiling((double)_allOrders.Count / PageSize);
            if (_currentPage < totalPages)
            {
                _currentPage++;
                ApplyFilters();
            }
        }

        private void ViewOrder_Click(object sender, RoutedEventArgs e)
        {
            var orderId = (int)(sender as Button)?.Tag!;
            var order = _allOrders.FirstOrDefault(o => o.SalesOrderId == orderId);

            if (order != null)
            {
                MessageBox.Show(
                    $"🛒 SALES ORDER DETAILS\n\n" +
                    $"Order ID: {order.SalesOrderId}\n" +
                    $"Retailer: {order.RetailerName}\n" +
                    $"Salesperson: {order.SalespersonName}\n" +
                    $"Order Date: {order.OrderDate:dd/MM/yyyy}\n" +
                    $"Total Amount: ₨{order.TotalAmount:N0}\n" +
                    $"Status: {order.Status}",
                    "Order Details", MessageBoxButton.OK, MessageBoxImage.Information);
            }
        }

        private void EditOrder_Click(object sender, RoutedEventArgs e)
        {
            var orderId = (int)(sender as Button)?.Tag!;

            // Switch to Update tab and select the order
            UpdateOrderTab.Style = (Style)Resources["ActiveTabBtn"];
            ViewAllTab.Style = (Style)Resources["TabBtn"];

            ViewAllContent.Visibility = Visibility.Collapsed;
            UpdateOrderContent.Visibility = Visibility.Visible;

            // Find and select the order in combo box
            for (int i = 1; i < UpdateOrderSelect.Items.Count; i++)
            {
                var item = UpdateOrderSelect.Items[i] as ComboBoxItem;
                if (item?.Tag != null && (int)item.Tag == orderId)
                {
                    UpdateOrderSelect.SelectedIndex = i;
                    break;
                }
            }
        }

        private void MarkDelivered_Click(object sender, RoutedEventArgs e)
        {
            var orderId = (int)(sender as Button)?.Tag!;
            var order = _allOrders.FirstOrDefault(o => o.SalesOrderId == orderId);

            if (order != null)
            {
                if (order.Status == "Delivered")
                {
                    MessageBox.Show("This order is already marked as Delivered.", "Info", MessageBoxButton.OK, MessageBoxImage.Information);
                    return;
                }

                var result = MessageBox.Show(
                    $"Mark this order as Delivered?\n\n" +
                    $"Order ID: {order.SalesOrderId}\n" +
                    $"Retailer: {order.RetailerName}\n" +
                    $"Amount: ₨{order.TotalAmount:N0}",
                    "Confirm Delivery", MessageBoxButton.YesNo, MessageBoxImage.Question);

                if (result == MessageBoxResult.Yes)
                {
                    order.Status = "Delivered";
                    ApplyFilters();
                    UpdateStatistics();

                    MessageBox.Show("Order marked as Delivered!", "Success", MessageBoxButton.OK, MessageBoxImage.Information);
                }
            }
        }

        private void DeleteOrder_Click(object sender, RoutedEventArgs e)
        {
            var orderId = (int)(sender as Button)?.Tag!;
            var order = _allOrders.FirstOrDefault(o => o.SalesOrderId == orderId);

            if (order != null)
            {
                var result = MessageBox.Show(
                    $"Are you sure you want to delete this order?\n\n" +
                    $"Order ID: {order.SalesOrderId}\n" +
                    $"Retailer: {order.RetailerName}\n\n" +
                    "This action cannot be undone.",
                    "Confirm Delete", MessageBoxButton.YesNo, MessageBoxImage.Warning);

                if (result == MessageBoxResult.Yes)
                {
                    _allOrders.Remove(order);
                    ApplyFilters();
                    UpdateStatistics();
                    LoadOrderSelectComboBox();

                    MessageBox.Show("Order deleted successfully!", "Deleted", MessageBoxButton.OK, MessageBoxImage.Information);
                }
            }
        }

        #endregion

        #region Create Order Tab

        private async System.Threading.Tasks.Task LoadProductsAsync()
        {
            try
            {
                var products = await _dataService.GetProductsForOrderAsync();
                _products = products;
                
                // Load products into CREATE combo box
                CreateProductCombo.Items.Clear();
                CreateProductCombo.Items.Add(new ComboBoxItem { Content = "-- Select Product --" });
                
                // Load products into UPDATE combo box
                UpdateProductCombo.Items.Clear();
                UpdateProductCombo.Items.Add(new ComboBoxItem { Content = "-- Select Product --" });
                
                if (products == null || products.Count == 0)
                {
                    MessageBox.Show("No active products found in the database. Please add products first.", 
                        "No Products", MessageBoxButton.OK, MessageBoxImage.Information);
                    return;
                }
                
                foreach (var product in _products)
                {
                    // Add to Create tab
                    CreateProductCombo.Items.Add(new ComboBoxItem
                    {
                        Content = $"{product.ProductName} - ₨{product.SalePrice:N0}",
                        Tag = new { product.ProductID, product.ProductName, SKU = $"PRD-{product.ProductID}", product.SalePrice }
                    });
                    
                    // Add to Update tab
                    UpdateProductCombo.Items.Add(new ComboBoxItem
                    {
                        Content = $"{product.ProductName} - ₨{product.SalePrice:N0}",
                        Tag = new { product.ProductID, product.ProductName, SKU = $"PRD-{product.ProductID}", product.SalePrice }
                    });
                }
                
                if (CreateProductCombo.Items.Count > 0)
                    CreateProductCombo.SelectedIndex = 0;
                if (UpdateProductCombo.Items.Count > 0)
                    UpdateProductCombo.SelectedIndex = 0;
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error loading products: {ex.Message}\n\nStack Trace: {ex.StackTrace}", "Error",
                    MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void AddProductToOrder_Click(object sender, RoutedEventArgs e)
        {
            if (CreateProductCombo.SelectedIndex <= 0)
            {
                MessageBox.Show("Please select a product.", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }

            if (!int.TryParse(CreateQuantity.Text, out int quantity) || quantity <= 0)
            {
                MessageBox.Show("Please enter a valid quantity (positive number).", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                CreateQuantity.Focus();
                return;
            }

            if (!decimal.TryParse(CreateUnitPrice.Text, out decimal unitPrice) || unitPrice <= 0)
            {
                MessageBox.Show("Please enter a valid unit price (positive number).", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                CreateUnitPrice.Focus();
                return;
            }

            try
            {
                var selectedItem = CreateProductCombo.SelectedItem as ComboBoxItem;
                dynamic productData = selectedItem!.Tag;

                // Check if product already exists in the list
                var existingItem = _orderItems.FirstOrDefault(i => i.ProductId == productData.ProductID);
                if (existingItem != null)
                {
                    MessageBox.Show($"Product '{productData.ProductName}' is already in the order. Please update the quantity of existing item or remove it first.", 
                        "Duplicate Product", MessageBoxButton.OK, MessageBoxImage.Warning);
                    return;
                }

                var orderItem = new OrderItemModel
                {
                    ProductId = productData.ProductID,
                    ProductName = productData.ProductName,
                    SKU = productData.SKU,
                    Quantity = quantity,
                    UnitPrice = unitPrice,
                    Total = quantity * unitPrice
                };

                _orderItems.Add(orderItem);
                
                // Recalculate totals with discount
                CalculateCreateOrderTotals();
                
                // Reset form
                CreateProductCombo.SelectedIndex = 0;
                CreateQuantity.Text = "1";
                CreateUnitPrice.Text = "0";
                
                MessageBox.Show($"Product '{productData.ProductName}' added to order.", "Item Added", MessageBoxButton.OK, MessageBoxImage.Information);
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error adding product to order: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void RemoveProductFromOrder_Click(object sender, RoutedEventArgs e)
        {
            var button = sender as Button;
            if (button?.Tag != null && int.TryParse(button.Tag.ToString(), out int productId))
            {
                var item = _orderItems.FirstOrDefault(i => i.ProductId == productId);
                if (item != null)
                {
                    var result = MessageBox.Show(
                        $"Remove '{item.ProductName}' from order items?\n\nQuantity: {item.Quantity}\nUnit Price: ₨{item.UnitPrice:N2}\nTotal: ₨{item.Total:N2}",
                        "Confirm Remove", MessageBoxButton.YesNo, MessageBoxImage.Question);

                    if (result == MessageBoxResult.Yes)
                    {
                        _orderItems.Remove(item);
                        
                        // Recalculate totals with discount
                        CalculateCreateOrderTotals();
                    }
                }
            }
        }

        private void ClearCreateForm_Click(object sender, RoutedEventArgs e)
        {
            CreateRetailer.SelectedIndex = 0;
            CreateSalesperson.SelectedIndex = 0;
            CreateOrderDate.SelectedDate = DateTime.Now;
            CreateTotalAmount.Text = "";
            CreateStatus.SelectedIndex = 0;
            _orderItems.Clear();
            CreateProductCombo.SelectedIndex = 0;
            CreateQuantity.Text = "1";
            CreateUnitPrice.Text = "0";
        }

        private async void SaveOrder_Click(object sender, RoutedEventArgs e)
        {
            // Validation
            if (CreateRetailer.SelectedIndex <= 0)
            {
                MessageBox.Show("Please select a retailer.", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }

            if (CreateSalesperson.SelectedIndex <= 0)
            {
                MessageBox.Show("Please select a salesperson.", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }

            if (!CreateOrderDate.SelectedDate.HasValue)
            {
                MessageBox.Show("Please select an order date.", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }

            if (string.IsNullOrWhiteSpace(CreateTotalAmount.Text) || !decimal.TryParse(CreateTotalAmount.Text, out decimal totalAmount))
            {
                MessageBox.Show("Please enter a valid total amount.", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                CreateTotalAmount.Focus();
                return;
            }

            if (_orderItems.Count == 0)
            {
                MessageBox.Show("Please add at least one product to the order.", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }

            var selectedRetailer = CreateRetailer.SelectedItem as ComboBoxItem;
            var selectedSalesperson = CreateSalesperson.SelectedItem as ComboBoxItem;
            var selectedStatus = (CreateStatus.SelectedItem as ComboBoxItem)?.Content?.ToString() ?? "Not Delivered";

            var retailerId = (int)(selectedRetailer?.Tag ?? 0);
            var salespersonId = (int)(selectedSalesperson?.Tag ?? 0);

            // Get discount values
            decimal.TryParse(CreateDiscountPercentage.Text, out decimal discountPercentage);
            decimal.TryParse(CreateDiscountAmount.Text, out decimal discountAmount);

            try
            {
                // Create SalesOrder object for database
                var order = new SalesOrder
                {
                    OrderDate = CreateOrderDate.SelectedDate.Value,
                    RetailerID = retailerId,
                    SalesRepID = salespersonId,
                    Status = selectedStatus,
                    ShippingAddress = CreateShippingAddress.Text.Trim(),
                    DiscountPercentage = discountPercentage,
                    SubTotal = totalAmount,
                    DiscountAmount = discountAmount,
                    TotalAmount = decimal.Parse(CreateTotalAmount.Text),
                    Items = _orderItems.Select(item => new SalesOrderItem
                    {
                        ProductID = item.ProductId,
                        Quantity = item.Quantity,
                        UnitPrice = item.UnitPrice,
                        Discount = 0
                    }).ToList()
                };

                // Save to database
                int newOrderId = await _dataService.AddSalesOrderAsync(order);

                // Reload orders from database
                await LoadOrdersAsync();
                LoadOrderSelectComboBox();

                MessageBox.Show(
                    $"✅ Sales Order Created Successfully!\n\n" +
                    $"Order ID: {newOrderId}\n" +
                    $"Total Products: {_orderItems.Count}\n" +
                    $"Amount: ₨{totalAmount:N0}",
                    "Success", MessageBoxButton.OK, MessageBoxImage.Information);

                ClearCreateForm_Click(null!, null!);

                // Switch to View All tab
                ViewAllTab.Style = (Style)Resources["ActiveTabBtn"];
                CreateOrderTab.Style = (Style)Resources["TabBtn"];
                CreateOrderContent.Visibility = Visibility.Collapsed;
                ViewAllContent.Visibility = Visibility.Visible;
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error saving order: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        #endregion

        #region Update Order Tab

        private void UpdateOrderSelect_Changed(object sender, SelectionChangedEventArgs e)
        {
            if (!_isLoaded) return;
            if (UpdateOrderSelect.SelectedIndex <= 0)
            {
                UpdateRetailer.SelectedIndex = 0;
                UpdateSalesperson.SelectedIndex = 0;
                UpdateOrderDate.SelectedDate = null;
                UpdateTotalAmount.Text = "";
                UpdateStatus.SelectedIndex = -1;
                _updateOrderItems.Clear();
                return;
            }

            var selectedItem = UpdateOrderSelect.SelectedItem as ComboBoxItem;
            if (selectedItem?.Tag == null) return;

            var orderId = (int)selectedItem.Tag;
            var order = _allOrders.FirstOrDefault(o => o.SalesOrderId == orderId);

            if (order != null)
            {
                // Set Retailer
                for (int i = 1; i < UpdateRetailer.Items.Count; i++)
                {
                    var item = UpdateRetailer.Items[i] as ComboBoxItem;
                    if (item?.Tag != null && (int)item.Tag == order.RetailerId)
                    {
                        UpdateRetailer.SelectedIndex = i;
                        break;
                    }
                }

                // Set Salesperson
                for (int i = 1; i < UpdateSalesperson.Items.Count; i++)
                {
                    var item = UpdateSalesperson.Items[i] as ComboBoxItem;
                    if (item?.Tag != null && (int)item.Tag == order.SalespersonId)
                    {
                        UpdateSalesperson.SelectedIndex = i;
                        break;
                    }
                }

                UpdateOrderDate.SelectedDate = order.OrderDate;
                UpdateTotalAmount.Text = order.TotalAmount.ToString();

                // Set Status
                for (int i = 0; i < UpdateStatus.Items.Count; i++)
                {
                    var item = UpdateStatus.Items[i] as ComboBoxItem;
                    if (item?.Content?.ToString() == order.Status)
                    {
                        UpdateStatus.SelectedIndex = i;
                        break;
                    }
                }

                // Load order items from database
                LoadOrderItemsForUpdate(orderId);
            }
        }

        private async void LoadOrderItemsForUpdate(int orderId)
        {
            try
            {
                _updateOrderItems.Clear();
                var orderItems = await _dataService.GetSalesOrderItemsAsync(orderId);
                
                foreach (var item in orderItems)
                {
                    var product = _products.FirstOrDefault(p => p.ProductID == item.ProductID);
                    _updateOrderItems.Add(new OrderItemModel
                    {
                        ProductId = item.ProductID,
                        ProductName = product?.ProductName ?? "Unknown Product",
                        SKU = $"PRD-{item.ProductID}",
                        Quantity = item.Quantity,
                        UnitPrice = item.UnitPrice,
                        Total = item.Quantity * item.UnitPrice
                    });
                }

                // Update total amount display
                UpdateTotalAmount.Text = _updateOrderItems.Sum(i => i.Total).ToString("F2");
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error loading order items: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void AddProductToUpdateOrder_Click(object sender, RoutedEventArgs e)
        {
            if (UpdateProductCombo.SelectedIndex <= 0)
            {
                MessageBox.Show("Please select a product.", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }

            if (!int.TryParse(UpdateQuantity.Text, out int quantity) || quantity <= 0)
            {
                MessageBox.Show("Please enter a valid quantity (positive number).", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                UpdateQuantity.Focus();
                return;
            }

            if (!decimal.TryParse(UpdateUnitPrice.Text, out decimal unitPrice) || unitPrice <= 0)
            {
                MessageBox.Show("Please enter a valid unit price (positive number).", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                UpdateUnitPrice.Focus();
                return;
            }

            try
            {
                var selectedItem = UpdateProductCombo.SelectedItem as ComboBoxItem;
                dynamic productData = selectedItem!.Tag;

                // Check if product already exists in the list
                var existingItem = _updateOrderItems.FirstOrDefault(i => i.ProductId == productData.ProductID);
                if (existingItem != null)
                {
                    MessageBox.Show($"Product '{productData.ProductName}' is already in the order. Please update the quantity of existing item or remove it first.", 
                        "Duplicate Product", MessageBoxButton.OK, MessageBoxImage.Warning);
                    return;
                }

                var orderItem = new OrderItemModel
                {
                    ProductId = productData.ProductID,
                    ProductName = productData.ProductName,
                    SKU = productData.SKU,
                    Quantity = quantity,
                    UnitPrice = unitPrice,
                    Total = quantity * unitPrice
                };

                _updateOrderItems.Add(orderItem);
                
                // Recalculate totals with discount
                CalculateUpdateOrderTotals();
                
                // Reset form
                UpdateProductCombo.SelectedIndex = 0;
                UpdateQuantity.Text = "1";
                UpdateUnitPrice.Text = "0";
                
                MessageBox.Show($"Product '{productData.ProductName}' added to order.", "Item Added", MessageBoxButton.OK, MessageBoxImage.Information);
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error adding product to order: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void RemoveProductFromUpdateOrder_Click(object sender, RoutedEventArgs e)
        {
            var button = sender as Button;
            if (button?.Tag != null && int.TryParse(button.Tag.ToString(), out int productId))
            {
                var item = _updateOrderItems.FirstOrDefault(i => i.ProductId == productId);
                if (item != null)
                {
                    var result = MessageBox.Show(
                        $"Remove '{item.ProductName}' from order items?\n\nQuantity: {item.Quantity}\nUnit Price: ₨{item.UnitPrice:N2}\nTotal: ₨{item.Total:N2}",
                        "Confirm Remove", MessageBoxButton.YesNo, MessageBoxImage.Question);

                    if (result == MessageBoxResult.Yes)
                    {
                        _updateOrderItems.Remove(item);
                        
                        // Recalculate totals with discount
                        CalculateUpdateOrderTotals();
                    }
                }
            }
        }

        private void ResetUpdateForm_Click(object sender, RoutedEventArgs e)
        {
            UpdateOrderSelect.SelectedIndex = 0;
            UpdateRetailer.SelectedIndex = 0;
            UpdateSalesperson.SelectedIndex = 0;
            UpdateOrderDate.SelectedDate = null;
            UpdateTotalAmount.Text = "";
            UpdateStatus.SelectedIndex = -1;
            _updateOrderItems.Clear();
            UpdateProductCombo.SelectedIndex = 0;
            UpdateQuantity.Text = "1";
            UpdateUnitPrice.Text = "0";
        }

        private async void UpdateOrderBtn_Click(object sender, RoutedEventArgs e)
        {
            if (UpdateOrderSelect.SelectedIndex <= 0)
            {
                MessageBox.Show("Please select an order to update.", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }

            if (UpdateRetailer.SelectedIndex <= 0)
            {
                MessageBox.Show("Please select a retailer.", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }

            if (UpdateSalesperson.SelectedIndex <= 0)
            {
                MessageBox.Show("Please select a salesperson.", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }

            if (!decimal.TryParse(UpdateTotalAmount.Text, out decimal totalAmount))
            {
                MessageBox.Show("Please enter a valid total amount.", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }

            if (_updateOrderItems.Count == 0)
            {
                MessageBox.Show("Please add at least one product to the order.", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }

            var selectedItem = UpdateOrderSelect.SelectedItem as ComboBoxItem;
            var orderId = (int)(selectedItem?.Tag ?? 0);

            try
            {
                var selectedRetailer = UpdateRetailer.SelectedItem as ComboBoxItem;
                var selectedSalesperson = UpdateSalesperson.SelectedItem as ComboBoxItem;
                var selectedStatus = (UpdateStatus.SelectedItem as ComboBoxItem)?.Content?.ToString() ?? "Not Delivered";

                // Get discount values
                decimal.TryParse(UpdateDiscountPercentage.Text, out decimal discountPercentage);
                decimal.TryParse(UpdateDiscountAmount.Text, out decimal discountAmount);

                // Create SalesOrder object for database update
                var order = new SalesOrder
                {
                    SalesOrderID = orderId,
                    OrderDate = UpdateOrderDate.SelectedDate ?? DateTime.Now,
                    RetailerID = (int)(selectedRetailer?.Tag ?? 0),
                    SalesRepID = (int)(selectedSalesperson?.Tag ?? 0),
                    Status = selectedStatus,
                    ShippingAddress = UpdateShippingAddress.Text.Trim(),
                    DiscountPercentage = discountPercentage,
                    SubTotal = totalAmount,
                    DiscountAmount = discountAmount,
                    TotalAmount = decimal.Parse(UpdateTotalAmount.Text),
                    Items = _updateOrderItems.Select(item => new SalesOrderItem
                    {
                        ProductID = item.ProductId,
                        Quantity = item.Quantity,
                        UnitPrice = item.UnitPrice,
                        Discount = 0
                    }).ToList()
                };

                // Update in database
                await _dataService.UpdateSalesOrderAsync(order);

                // Reload orders from database
                await LoadOrdersAsync();
                LoadOrderSelectComboBox();

                MessageBox.Show(
                    $"✅ Order Updated Successfully!\n\n" +
                    $"Order ID: {orderId}\n" +
                    $"Total Products: {_updateOrderItems.Count}\n" +
                    $"Amount: ₨{totalAmount:N0}",
                    "Success", MessageBoxButton.OK, MessageBoxImage.Information);

                ResetUpdateForm_Click(null!, null!);
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error updating order: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        #endregion

        #region Delete Order Tab

        private void DeleteOrderSelect_Changed(object sender, SelectionChangedEventArgs e)
        {
            if (!_isLoaded) return;
            if (DeleteOrderSelect.SelectedIndex <= 0)
            {
                DeletePreviewPanel.Visibility = Visibility.Collapsed;
                return;
            }

            var selectedItem = DeleteOrderSelect.SelectedItem as ComboBoxItem;
            if (selectedItem?.Tag == null) return;

            var orderId = (int)selectedItem.Tag;
            var order = _allOrders.FirstOrDefault(o => o.SalesOrderId == orderId);

            if (order != null)
            {
                DeletePreviewOrderId.Text = order.SalesOrderId.ToString();
                DeletePreviewRetailer.Text = order.RetailerName;
                DeletePreviewDate.Text = order.OrderDate.ToString("dd/MM/yyyy");
                DeletePreviewAmount.Text = $"₨{order.TotalAmount:N0}";
                DeletePreviewStatus.Text = order.Status;
                DeletePreviewPanel.Visibility = Visibility.Visible;
            }
        }

        private async void ConfirmDeleteOrder_Click(object sender, RoutedEventArgs e)
        {
            if (DeleteOrderSelect.SelectedIndex <= 0)
            {
                MessageBox.Show("Please select an order to delete.", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }

            var selectedItem = DeleteOrderSelect.SelectedItem as ComboBoxItem;
            var orderId = (int)(selectedItem?.Tag ?? 0);
            var order = _allOrders.FirstOrDefault(o => o.SalesOrderId == orderId);

            if (order != null)
            {
                var result = MessageBox.Show(
                    $"⚠️ ARE YOU SURE?\n\n" +
                    $"You are about to permanently delete:\n\n" +
                    $"Order ID: {order.SalesOrderId}\n" +
                    $"Retailer: {order.RetailerName}\n" +
                    $"Amount: ₨{order.TotalAmount:N0}\n\n" +
                    "This action CANNOT be undone!",
                    "Confirm Deletion", MessageBoxButton.YesNo, MessageBoxImage.Warning);

                if (result == MessageBoxResult.Yes)
                {
                    try
                    {
                        await _dataService.DeleteSalesOrderAsync(orderId);
                        
                        await LoadOrdersAsync();
                        ApplyFilters();
                        UpdateStatistics();
                        LoadOrderSelectComboBox();

                        DeleteOrderSelect.SelectedIndex = 0;
                        DeletePreviewPanel.Visibility = Visibility.Collapsed;

                        MessageBox.Show("Order deleted successfully!", "Deleted", MessageBoxButton.OK, MessageBoxImage.Information);
                    }
                    catch (Exception ex)
                    {
                        MessageBox.Show($"Error deleting order: {ex.Message}", "Error",
                            MessageBoxButton.OK, MessageBoxImage.Error);
                    }
                }
            }
        }

        #endregion

        #region Product Selection Handlers

        private void UpdateProductCombo_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            // Auto-fill price when product is selected in update tab
            if (UpdateProductCombo.SelectedIndex > 0)
            {
                var selectedProduct = UpdateProductCombo.SelectedItem as ComboBoxItem;
                if (selectedProduct?.Tag != null)
                {
                    dynamic productData = selectedProduct.Tag;
                    UpdateUnitPrice.Text = productData.SalePrice.ToString("F2");
                }
            }
        }

        private void CreateProductCombo_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            // Auto-fill price when product is selected in create tab
            if (CreateProductCombo.SelectedIndex > 0)
            {
                var selectedProduct = CreateProductCombo.SelectedItem as ComboBoxItem;
                if (selectedProduct?.Tag != null)
                {
                    dynamic productData = selectedProduct.Tag;
                    CreateUnitPrice.Text = productData.SalePrice.ToString("F2");
                }
            }
        }

        private void CreateDiscountPercentage_TextChanged(object sender, TextChangedEventArgs e)
        {
            if (!_isLoaded) return;
            CalculateCreateOrderTotals();
        }

        private void UpdateDiscountPercentage_TextChanged(object sender, TextChangedEventArgs e)
        {
            if (!_isLoaded) return;
            CalculateUpdateOrderTotals();
        }

        private void CalculateCreateOrderTotals()
        {
            if (CreateDiscountAmount == null || CreateTotalAmount == null) return;
            
            if (_orderItems == null || _orderItems.Count == 0)
            {
                CreateDiscountAmount.Text = "0";
                CreateTotalAmount.Text = "0";
                return;
            }

            decimal subtotal = _orderItems.Sum(item => item.Total);
            
            if (!decimal.TryParse(CreateDiscountPercentage?.Text, out decimal discountPercentage))
            {
                discountPercentage = 0;
            }
            
            decimal discountAmount = subtotal * (discountPercentage / 100);
            decimal totalAmount = subtotal - discountAmount;

            CreateDiscountAmount.Text = discountAmount.ToString("F2");
            CreateTotalAmount.Text = totalAmount.ToString("F2");
        }

        private void CalculateUpdateOrderTotals()
        {
            if (UpdateDiscountAmount == null || UpdateTotalAmount == null) return;
            
            if (_updateOrderItems == null || _updateOrderItems.Count == 0)
            {
                UpdateDiscountAmount.Text = "0";
                UpdateTotalAmount.Text = "0";
                return;
            }

            decimal subtotal = _updateOrderItems.Sum(item => item.Total);
            
            if (!decimal.TryParse(UpdateDiscountPercentage?.Text, out decimal discountPercentage))
            {
                discountPercentage = 0;
            }
            
            decimal discountAmount = subtotal * (discountPercentage / 100);
            decimal totalAmount = subtotal - discountAmount;

            UpdateDiscountAmount.Text = discountAmount.ToString("F2");
            UpdateTotalAmount.Text = totalAmount.ToString("F2");
        }

        #endregion

        #region Common Actions

        private async void RefreshBtn_Click(object sender, RoutedEventArgs e)
        {
            await LoadDataAsync();
            MessageBox.Show("Data refreshed successfully!", "Refresh", MessageBoxButton.OK, MessageBoxImage.Information);
        }

        private void NewOrderBtn_Click(object sender, RoutedEventArgs e)
        {
            // Open CreateOrderDialog
            var dialog = new CreateOrderDialog();
            dialog.Owner = Window.GetWindow(this);
            if (dialog.ShowDialog() == true)
            {
                // Refresh data after order created
                _ = LoadDataAsync();
                MessageBox.Show("Order created successfully!", "Success", MessageBoxButton.OK, MessageBoxImage.Information);
            }
        }

        #endregion
    }

    /// <summary>
    /// Sales Order Model based on the entity diagram
    /// SalesOrderID (INT, PK), RetailerID (FK), SalespersonID (FK), OrderDate, TotalAmount, Status
    /// Status: Delivered or Not Delivered
    /// </summary>
    public class SalesOrderModel : INotifyPropertyChanged
    {
        private int _salesOrderId;
        private int _retailerId;
        private string _retailerName = string.Empty;
        private int _salespersonId;
        private string _salespersonName = string.Empty;
        private DateTime _orderDate;
        private decimal _totalAmount;
        private string _status = string.Empty;

        public int SalesOrderId
        {
            get => _salesOrderId;
            set { _salesOrderId = value; OnPropertyChanged(); }
        }

        public int RetailerId
        {
            get => _retailerId;
            set { _retailerId = value; OnPropertyChanged(); }
        }

        public string RetailerName
        {
            get => _retailerName;
            set { _retailerName = value; OnPropertyChanged(); }
        }

        public int SalespersonId
        {
            get => _salespersonId;
            set { _salespersonId = value; OnPropertyChanged(); }
        }

        public string SalespersonName
        {
            get => _salespersonName;
            set { _salespersonName = value; OnPropertyChanged(); }
        }

        public DateTime OrderDate
        {
            get => _orderDate;
            set { _orderDate = value; OnPropertyChanged(); }
        }

        public decimal TotalAmount
        {
            get => _totalAmount;
            set { _totalAmount = value; OnPropertyChanged(); }
        }

        public string Status
        {
            get => _status;
            set { _status = value; OnPropertyChanged(); }
        }

        public event PropertyChangedEventHandler? PropertyChanged;

        protected virtual void OnPropertyChanged([CallerMemberName] string? propertyName = null)
        {
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
        }
    }

    public class RetailerInfo
    {
        public int RetailerId { get; set; }
        public string Name { get; set; } = string.Empty;
    }

    public class SalespersonInfo
    {
        public int SalespersonId { get; set; }
        public string Name { get; set; } = string.Empty;
    }

    public class OrderItemModel : INotifyPropertyChanged
    {
        private int _productId;
        private string _productName = string.Empty;
        private string _sku = string.Empty;
        private int _quantity;
        private decimal _unitPrice;
        private decimal _total;

        public int ProductId
        {
            get => _productId;
            set { _productId = value; OnPropertyChanged(); }
        }

        public string ProductName
        {
            get => _productName;
            set { _productName = value; OnPropertyChanged(); }
        }

        public string SKU
        {
            get => _sku;
            set { _sku = value; OnPropertyChanged(); }
        }

        public int Quantity
        {
            get => _quantity;
            set { _quantity = value; OnPropertyChanged(); OnPropertyChanged(nameof(Total)); }
        }

        public decimal UnitPrice
        {
            get => _unitPrice;
            set { _unitPrice = value; OnPropertyChanged(); OnPropertyChanged(nameof(Total)); }
        }

        public decimal Total
        {
            get => _total;
            set { _total = value; OnPropertyChanged(); }
        }

        public event PropertyChangedEventHandler? PropertyChanged;

        protected virtual void OnPropertyChanged([CallerMemberName] string? propertyName = null)
        {
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
        }
    }
}
