using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Windows;
using System.Windows.Controls;
using FactoryManagmentSystem.Views;
using FactoryManagmentSystem.Services;
using FactoryManagmentSystem.Models;

namespace FactoryManagmentSystem
{
    public partial class CreateOrderDialog : Window, INotifyPropertyChanged
    {
        public bool DialogResult { get; private set; } = false;
        private readonly SalesOrderDataService _dataService;

        // Properties for order data
        public string OrderId { get; private set; } = "";
        public DateTime OrderDate { get; private set; }
        public DateTime DeliveryDate { get; private set; }
        public string Priority { get; private set; } = "";
        public string Status { get; private set; } = "";
        public int RetailerId { get; private set; } = 0;
        public string CustomerName { get; private set; } = "";
        public string CustomerEmail { get; private set; } = "";
        public string CustomerPhone { get; private set; } = "";
        public string ShippingAddress { get; private set; } = "";
        public string SpecialInstructions { get; private set; } = "";
        public string PaymentTerms { get; private set; } = "";
        public decimal AdvancePayment { get; private set; } = 0;
        public decimal DiscountPercentage { get; private set; } = 0;
        public string PaymentStatus { get; private set; } = "";
        public int SalesRepId { get; private set; } = 0;
        public string SalesRepresentative { get; private set; } = "";
        public string OrderSource { get; private set; } = "";
        public string InternalNotes { get; private set; } = "";
        public string Tags { get; private set; } = "";
        public ObservableCollection<OrderItem> OrderItems { get; set; }
        public decimal TotalAmount { get; private set; } = 0;

        private List<RetailerForOrder> _retailers;
        private Dictionary<string, CustomerInfo> _customerData;

        public event PropertyChangedEventHandler? PropertyChanged;

        public CreateOrderDialog()
        {
            try
            {
                InitializeComponent();
                _dataService = new SalesOrderDataService();
                _retailers = new List<RetailerForOrder>();
                OrderItems = new ObservableCollection<OrderItem>();
                OrderItemsDataGrid.ItemsSource = OrderItems;

                InitializeCustomerData();
                InitializeForm();

                OrderItems.CollectionChanged += (s, e) => UpdateOrderSummary();
                
                // Load retailers and salespersons from database async
                Loaded += async (s, e) =>
                {
                    await LoadRetailersAsync();
                    await LoadSalespersonsAsync();
                };
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error initializing Create Order Dialog: {ex.Message}", "Error", 
                    MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void InitializeCustomerData()
        {
            // Customer data will be loaded from database via LoadRetailersAsync
            _customerData = new Dictionary<string, CustomerInfo>();
        }
        
        private async System.Threading.Tasks.Task LoadRetailersAsync()
        {
            try
            {
                _retailers = await _dataService.GetRetailersForOrderAsync();
                
                // Populate customer combo box with retailers from database
                CustomerComboBox.Items.Clear();
                
                foreach (var retailer in _retailers)
                {
                    var item = new ComboBoxItem
                    {
                        Content = retailer.CompanyName,
                        Tag = retailer.RetailerID
                    };
                    CustomerComboBox.Items.Add(item);
                    
                    // Also populate customer data dictionary for auto-fill
                    _customerData[retailer.CompanyName] = new CustomerInfo
                    {
                        Name = retailer.CompanyName,
                        Email = retailer.Email,
                        Phone = retailer.Phone,
                        Address = retailer.ShippingAddress
                    };
                }
                
                // Add "Add New Customer..." option at the end
                CustomerComboBox.Items.Add(new ComboBoxItem { Content = "Add New Customer..." });
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error loading retailers: {ex.Message}", "Error",
                    MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private async System.Threading.Tasks.Task LoadSalespersonsAsync()
        {
            try
            {
                // Load salespersons from database
                var salespersons = await _dataService.GetSalespersonsForOrderAsync();
                
                // Populate Salesperson ComboBox
                SalesRepComboBox.Items.Clear();
                SalesRepComboBox.Items.Add(new ComboBoxItem { Content = "-- Select Salesperson --" });
                
                foreach (var salesperson in salespersons)
                {
                    SalesRepComboBox.Items.Add(new ComboBoxItem
                    {
                        Content = salesperson.FullName,
                        Tag = salesperson.EmployeeID
                    });
                }
                
                SalesRepComboBox.SelectedIndex = 0;
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error loading salespersons: {ex.Message}", "Error",
                    MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void InitializeForm()
        {
            // Generate order ID
            OrderIdTextBox.Text = $"SO-{DateTime.Now:yyyy}-{new Random().Next(1000, 9999)}";
            
            // Set default dates
            OrderDatePicker.SelectedDate = DateTime.Now;
            DeliveryDatePicker.SelectedDate = DateTime.Now.AddDays(30);
            
            // Set default values
            PriorityComboBox.SelectedIndex = 1; // Medium
            StatusComboBox.SelectedIndex = 0; // Pending
            PaymentTermsComboBox.SelectedIndex = 2; // 30 days
            PaymentStatusComboBox.SelectedIndex = 0; // Pending
            OrderSourceComboBox.SelectedIndex = 0; // Direct Call
            SalesRepComboBox.SelectedIndex = 0; // First sales rep
            
            // Focus on customer selection
            CustomerComboBox.Focus();
            
            UpdateOrderSummary();
        }

        private void CustomerComboBox_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            if (CustomerComboBox.SelectedItem is ComboBoxItem selectedItem)
            {
                string selectedCustomer = selectedItem.Content.ToString() ?? "";
                
                if (selectedCustomer == "Add New Customer...")
                {
                    MessageBox.Show("Add New Customer functionality will be implemented here", 
                        "Add Customer", MessageBoxButton.OK, MessageBoxImage.Information);
                    CustomerComboBox.SelectedIndex = -1;
                    return;
                }
                
                // Get RetailerID from Tag
                if (selectedItem.Tag != null && int.TryParse(selectedItem.Tag.ToString(), out int retailerId))
                {
                    RetailerId = retailerId;
                }
                
                if (_customerData.ContainsKey(selectedCustomer))
                {
                    var customer = _customerData[selectedCustomer];
                    CustomerEmailTextBox.Text = customer.Email;
                    CustomerPhoneTextBox.Text = customer.Phone;
                    ShippingAddressTextBox.Text = customer.Address;
                }
            }
        }

        private void AddItemButton_Click(object sender, RoutedEventArgs e)
        {
            var addItemDialog = new AddOrderItemDialog();
            addItemDialog.Owner = this;
            
            if (addItemDialog.ShowDialog() == true)
            {
                var newItem = addItemDialog.GetOrderItem();
                OrderItems.Add(newItem);
                UpdateOrderSummary();
            }
        }

        private void RemoveItem_Click(object sender, RoutedEventArgs e)
        {
            if (sender is Button button && button.Tag is OrderItem item)
            {
                OrderItems.Remove(item);
                UpdateOrderSummary();
            }
        }

        private void DiscountPercentageTextBox_TextChanged(object sender, System.Windows.Controls.TextChangedEventArgs e)
        {
            if (decimal.TryParse(DiscountPercentageTextBox.Text.Trim(), out decimal discount))
            {
                DiscountPercentage = discount;
                UpdateOrderSummary();
            }
            else if (string.IsNullOrWhiteSpace(DiscountPercentageTextBox.Text))
            {
                DiscountPercentage = 0;
                UpdateOrderSummary();
            }
        }

        private void UpdateOrderSummary()
        {
            var totalItems = OrderItems.Sum(item => item.Quantity);
            var subtotal = OrderItems.Sum(item => item.TotalPrice);
            var discountAmount = subtotal * (DiscountPercentage / 100);
            var taxableAmount = subtotal - discountAmount;
            var taxAmount = taxableAmount * 0.05m; // 5% tax
            var totalAmount = taxableAmount + taxAmount;

            TotalItemsText.Text = totalItems.ToString();
            SubtotalText.Text = $"₨{subtotal:N0}";
            DiscountText.Text = $"₨{discountAmount:N0}";
            TaxText.Text = $"₨{taxAmount:N0}";
            TotalAmountText.Text = $"₨{totalAmount:N0}";

            TotalAmount = totalAmount;
        }

        private async void SaveOrderButton_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                if (ValidateForm())
                {
                    CollectFormData();
                    
                    // Build SalesOrder object from form
                    var salesOrder = new SalesOrder
                    {
                        SalesOrderID = 0, // Auto-generated
                        OrderDate = this.OrderDate,
                        Status = this.Status,
                        RetailerID = this.RetailerId,
                        RetailerName = this.CustomerName,
                        ShippingAddress = this.ShippingAddress,
                        DiscountPercentage = this.DiscountPercentage,
                        SubTotal = OrderItems.Sum(item => item.TotalPrice),
                        DiscountAmount = OrderItems.Sum(item => item.TotalPrice) * (DiscountPercentage / 100),
                        TotalAmount = this.TotalAmount,
                        SalesRepID = 1, // Default - should be from login session
                        SalesRepName = this.SalesRepresentative,
                        Items = new List<SalesOrderItem>()
                    };
                    
                    // Build order items from OrderItems collection
                    foreach (var item in OrderItems)
                    {
                        salesOrder.Items.Add(new SalesOrderItem
                        {
                            SalesOrderItemID = 0,
                            SalesOrderID = 0,
                            ProductID = item.ProductID,
                            ProductName = item.ProductName,
                            Size = item.Size,
                            Color = item.Color,
                            Quantity = item.Quantity,
                            UnitPrice = item.UnitPrice,
                            Discount = 0, // Item-level discount
                            TotalPrice = item.TotalPrice
                        });
                    }
                    
                    // Save to database
                    int newOrderId = await _dataService.AddSalesOrderAsync(salesOrder);
                    
                    MessageBox.Show($"Order saved successfully! Order ID: {newOrderId}", "Success",
                        MessageBoxButton.OK, MessageBoxImage.Information);
                    
                    DialogResult = true;
                    Close();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error saving order: {ex.Message}", "Error", 
                    MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void SaveAndPrintButton_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                if (ValidateForm())
                {
                    CollectFormData();
                    DialogResult = true;
                    
                    MessageBox.Show("Order saved successfully!\nPrint functionality will be implemented here.", 
                        "Order Saved", MessageBoxButton.OK, MessageBoxImage.Information);
                    
                    Close();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error saving order: {ex.Message}", "Error", 
                    MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void CancelButton_Click(object sender, RoutedEventArgs e)
        {
            DialogResult = false;
            Close();
        }

        private bool ValidateForm()
        {
            if (CustomerComboBox.SelectedIndex == -1)
            {
                MessageBox.Show("Please select a customer.", "Validation Error", 
                    MessageBoxButton.OK, MessageBoxImage.Warning);
                CustomerComboBox.Focus();
                return false;
            }

            if (string.IsNullOrWhiteSpace(ShippingAddressTextBox.Text))
            {
                MessageBox.Show("Shipping Address is required.", "Validation Error", 
                    MessageBoxButton.OK, MessageBoxImage.Warning);
                ShippingAddressTextBox.Focus();
                return false;
            }

            if (OrderDatePicker.SelectedDate == null)
            {
                MessageBox.Show("Order Date is required.", "Validation Error", 
                    MessageBoxButton.OK, MessageBoxImage.Warning);
                OrderDatePicker.Focus();
                return false;
            }

            if (DeliveryDatePicker.SelectedDate == null)
            {
                MessageBox.Show("Delivery Date is required.", "Validation Error", 
                    MessageBoxButton.OK, MessageBoxImage.Warning);
                DeliveryDatePicker.Focus();
                return false;
            }

            if (DeliveryDatePicker.SelectedDate <= OrderDatePicker.SelectedDate)
            {
                MessageBox.Show("Delivery Date must be after Order Date.", "Validation Error", 
                    MessageBoxButton.OK, MessageBoxImage.Warning);
                DeliveryDatePicker.Focus();
                return false;
            }

            if (OrderItems.Count == 0)
            {
                MessageBox.Show("Please add at least one item to the order.", "Validation Error", 
                    MessageBoxButton.OK, MessageBoxImage.Warning);
                return false;
            }

            return true;
        }

        private void CollectFormData()
        {
            OrderId = OrderIdTextBox.Text.Trim();
            OrderDate = OrderDatePicker.SelectedDate ?? DateTime.Now;
            DeliveryDate = DeliveryDatePicker.SelectedDate ?? DateTime.Now.AddDays(30);
            Priority = (PriorityComboBox.SelectedItem as ComboBoxItem)?.Content.ToString() ?? "";
            Status = (StatusComboBox.SelectedItem as ComboBoxItem)?.Content.ToString() ?? "";
            
            var selectedCustomer = (CustomerComboBox.SelectedItem as ComboBoxItem)?.Content.ToString() ?? "";
            CustomerName = _customerData.ContainsKey(selectedCustomer) ? _customerData[selectedCustomer].Name : "";
            CustomerEmail = CustomerEmailTextBox.Text.Trim();
            CustomerPhone = CustomerPhoneTextBox.Text.Trim();
            
            ShippingAddress = ShippingAddressTextBox.Text.Trim();
            SpecialInstructions = SpecialInstructionsTextBox.Text.Trim();
            PaymentTerms = (PaymentTermsComboBox.SelectedItem as ComboBoxItem)?.Content.ToString() ?? "";
            PaymentStatus = (PaymentStatusComboBox.SelectedItem as ComboBoxItem)?.Content.ToString() ?? "";
            SalesRepresentative = (SalesRepComboBox.SelectedItem as ComboBoxItem)?.Content.ToString() ?? "";
            OrderSource = (OrderSourceComboBox.SelectedItem as ComboBoxItem)?.Content.ToString() ?? "";
            InternalNotes = InternalNotesTextBox.Text.Trim();
            Tags = TagsTextBox.Text.Trim();

            // Parse numeric values safely
            if (decimal.TryParse(AdvancePaymentTextBox.Text.Trim(), out decimal advance))
            {
                AdvancePayment = advance;
            }

            if (decimal.TryParse(DiscountPercentageTextBox.Text.Trim(), out decimal discount))
            {
                DiscountPercentage = discount;
                UpdateOrderSummary(); // Recalculate with new discount
            }
        }

        // Helper method to create SalesOrder object
        public Views.SalesOrderModel CreateSalesOrder()
        {
            var order = new Views.SalesOrderModel
            {
                SalesOrderId = 0, // Will be assigned by database
                RetailerId = 0,
                RetailerName = this.CustomerName,
                SalespersonId = 0,
                SalespersonName = "",
                OrderDate = this.OrderDate,
                TotalAmount = this.TotalAmount,
                Status = this.Status
            };

            return order;
        }

        protected virtual void OnPropertyChanged([CallerMemberName] string? propertyName = null)
        {
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
        }
    }

    // Helper classes
    public class CustomerInfo
    {
        public string Name { get; set; } = "";
        public string Email { get; set; } = "";
        public string Phone { get; set; } = "";
        public string Address { get; set; } = "";
    }

    public class OrderItem : INotifyPropertyChanged
    {
        private int _productID = 0;
        private string _productName = "";
        private string _size = "";
        private string _color = "";
        private int _quantity = 0;
        private decimal _unitPrice = 0;

        public int ProductID
        {
            get => _productID;
            set { _productID = value; OnPropertyChanged(); }
        }

        public string ProductName
        {
            get => _productName;
            set { _productName = value; OnPropertyChanged(); OnPropertyChanged(nameof(TotalPrice)); }
        }

        public string Size
        {
            get => _size;
            set { _size = value; OnPropertyChanged(); }
        }

        public string Color
        {
            get => _color;
            set { _color = value; OnPropertyChanged(); }
        }

        public int Quantity
        {
            get => _quantity;
            set { _quantity = value; OnPropertyChanged(); OnPropertyChanged(nameof(TotalPrice)); }
        }

        public decimal UnitPrice
        {
            get => _unitPrice;
            set { _unitPrice = value; OnPropertyChanged(); OnPropertyChanged(nameof(TotalPrice)); }
        }

        public decimal TotalPrice => Quantity * UnitPrice;

        public event PropertyChangedEventHandler? PropertyChanged;

        protected virtual void OnPropertyChanged([CallerMemberName] string? propertyName = null)
        {
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
        }
    }

    // Simple Add Item Dialog (placeholder)
    public class AddOrderItemDialog : Window
    {
        private readonly SalesOrderDataService _dataService;
        private List<ProductForOrder> _products;
        private ComboBox _productComboBox;
        private ComboBox _sizeComboBox;
        private ComboBox _colorComboBox;
        private TextBox _quantityTextBox;
        private TextBox _unitPriceTextBox;

        public AddOrderItemDialog()
        {
            Title = "Add Order Item";
            Width = 500;
            Height = 400;
            WindowStartupLocation = WindowStartupLocation.CenterOwner;
            
            _dataService = new SalesOrderDataService();
            _products = new List<ProductForOrder>();
            
            InitializeDialog();
            Loaded += async (s, e) => await LoadProductsAsync();
        }
        
        private async System.Threading.Tasks.Task LoadProductsAsync()
        {
            try
            {
                _products = await _dataService.GetProductsForOrderAsync();
                
                _productComboBox.Items.Clear();
                foreach (var product in _products)
                {
                    var item = new ComboBoxItem
                    {
                        Content = $"{product.ProductName} - ₨{product.SalePrice:N0}",
                        Tag = product.ProductID
                    };
                    _productComboBox.Items.Add(item);
                }
                
                if (_productComboBox.Items.Count > 0)
                {
                    _productComboBox.SelectedIndex = 0;
                    UpdateProductDetails();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error loading products: {ex.Message}", "Error",
                    MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }
        
        private void UpdateProductDetails()
        {
            if (_productComboBox.SelectedItem is ComboBoxItem selectedItem && 
                selectedItem.Tag != null && 
                int.TryParse(selectedItem.Tag.ToString(), out int productId))
            {
                var product = _products.FirstOrDefault(p => p.ProductID == productId);
                if (product != null)
                {
                    _unitPriceTextBox.Text = product.SalePrice.ToString("F2");
                    
                    // Update available sizes
                    _sizeComboBox.Items.Clear();
                    if (!string.IsNullOrEmpty(product.AvailableSizes))
                    {
                        foreach (var size in product.AvailableSizes.Split(','))
                        {
                            _sizeComboBox.Items.Add(size.Trim());
                        }
                        if (_sizeComboBox.Items.Count > 0)
                            _sizeComboBox.SelectedIndex = 0;
                    }
                    
                    // Update available colors
                    _colorComboBox.Items.Clear();
                    if (!string.IsNullOrEmpty(product.AvailableColors))
                    {
                        foreach (var color in product.AvailableColors.Split(','))
                        {
                            _colorComboBox.Items.Add(color.Trim());
                        }
                        if (_colorComboBox.Items.Count > 0)
                            _colorComboBox.SelectedIndex = 0;
                    }
                }
            }
        }

        private void InitializeDialog()
        {
            var stackPanel = new StackPanel { Margin = new Thickness(20) };

            // Product
            stackPanel.Children.Add(new TextBlock { Text = "Product:", FontWeight = FontWeights.Bold, Margin = new Thickness(0, 10, 0, 5) });
            _productComboBox = new ComboBox { Margin = new Thickness(0, 0, 0, 10) };
            _productComboBox.SelectionChanged += (s, e) => UpdateProductDetails();
            stackPanel.Children.Add(_productComboBox);

            // Size
            stackPanel.Children.Add(new TextBlock { Text = "Size:", FontWeight = FontWeights.Bold, Margin = new Thickness(0, 10, 0, 5) });
            _sizeComboBox = new ComboBox { Margin = new Thickness(0, 0, 0, 10) };
            _sizeComboBox.Items.Add("XS");
            _sizeComboBox.Items.Add("S");
            _sizeComboBox.Items.Add("M");
            _sizeComboBox.Items.Add("L");
            _sizeComboBox.Items.Add("XL");
            _sizeComboBox.Items.Add("XXL");
            _sizeComboBox.SelectedIndex = 2;
            stackPanel.Children.Add(_sizeComboBox);

            // Color
            stackPanel.Children.Add(new TextBlock { Text = "Color:", FontWeight = FontWeights.Bold, Margin = new Thickness(0, 10, 0, 5) });
            _colorComboBox = new ComboBox { Margin = new Thickness(0, 0, 0, 10) };
            _colorComboBox.Items.Add("White");
            _colorComboBox.Items.Add("Black");
            _colorComboBox.Items.Add("Blue");
            _colorComboBox.Items.Add("Red");
            _colorComboBox.Items.Add("Green");
            _colorComboBox.Items.Add("Gray");
            _colorComboBox.SelectedIndex = 0;
            stackPanel.Children.Add(_colorComboBox);

            // Quantity
            stackPanel.Children.Add(new TextBlock { Text = "Quantity:", FontWeight = FontWeights.Bold, Margin = new Thickness(0, 10, 0, 5) });
            _quantityTextBox = new TextBox { Text = "1", Margin = new Thickness(0, 0, 0, 10) };
            stackPanel.Children.Add(_quantityTextBox);

            // Unit Price
            stackPanel.Children.Add(new TextBlock { Text = "Unit Price (PKR):", FontWeight = FontWeights.Bold, Margin = new Thickness(0, 10, 0, 5) });
            _unitPriceTextBox = new TextBox { Text = "1500", Margin = new Thickness(0, 0, 0, 20) };
            stackPanel.Children.Add(_unitPriceTextBox);

            // Buttons
            var buttonPanel = new StackPanel { Orientation = Orientation.Horizontal, HorizontalAlignment = HorizontalAlignment.Right };
            
            var addButton = new Button { Content = "Add Item", Padding = new Thickness(15, 8, 15, 8), Margin = new Thickness(0, 0, 10, 0) };
            addButton.Click += (s, e) => { DialogResult = true; Close(); };
            buttonPanel.Children.Add(addButton);

            var cancelButton = new Button { Content = "Cancel", Padding = new Thickness(15, 8, 15, 8) };
            cancelButton.Click += (s, e) => { DialogResult = false; Close(); };
            buttonPanel.Children.Add(cancelButton);

            stackPanel.Children.Add(buttonPanel);
            Content = stackPanel;
        }

        public OrderItem GetOrderItem()
        {
            int productId = 0;
            string productName = "";
            
            if (_productComboBox.SelectedItem is ComboBoxItem selectedItem)
            {
                if (selectedItem.Tag != null && int.TryParse(selectedItem.Tag.ToString(), out int id))
                {
                    productId = id;
                    var product = _products.FirstOrDefault(p => p.ProductID == id);
                    productName = product?.ProductName ?? "";
                }
            }
            
            return new OrderItem
            {
                ProductID = productId,
                ProductName = productName,
                Size = _sizeComboBox.SelectedItem?.ToString() ?? "",
                Color = _colorComboBox.SelectedItem?.ToString() ?? "",
                Quantity = int.TryParse(_quantityTextBox.Text, out var qty) ? qty : 1,
                UnitPrice = decimal.TryParse(_unitPriceTextBox.Text, out var price) ? price : 0
            };
        }
    }
}