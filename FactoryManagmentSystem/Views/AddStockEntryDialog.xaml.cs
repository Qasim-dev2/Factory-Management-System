using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Input;
using FactoryManagmentSystem.Models;
using FactoryManagmentSystem.Services;

namespace FactoryManagmentSystem.Views
{
    public partial class AddStockEntryDialog : Window
    {
        private readonly StockService _stockService;
        private readonly ProductService _productService;
        private List<Product> _products = new();
        
        // Old sample data - kept for backwards compatibility
        private readonly (int Id, string Name, string Category)[] _productsOld = new[]
        {
            (101, "Premium Cotton T-Shirt", "T-Shirt"),
            (102, "Slim Fit Denim Jeans", "Jeans"),
            (103, "Formal Dress Shirt", "Shirt"),
            (104, "Winter Wool Jacket", "Jacket"),
            (105, "Casual Polo Shirt", "Shirt"),
            (106, "Sports Sweatshirt", "Sweatshirt"),
            (107, "Cargo Pants", "Pants"),
            (108, "V-Neck T-Shirt", "T-Shirt"),
            (109, "Leather Jacket", "Jacket"),
            (110, "Classic Blue Jeans", "Jeans"),
            (111, "Hooded Sweatshirt", "Sweatshirt"),
            (112, "Chino Pants", "Pants"),
            (113, "Graphic T-Shirt", "T-Shirt"),
            (114, "Business Formal Shirt", "Shirt"),
            (115, "Puffer Jacket", "Jacket"),
            (116, "Fleece Sweatshirt", "Sweatshirt"),
            (117, "Jogger Pants", "Pants"),
            (118, "Skinny Jeans", "Jeans")
        };

        public StockDisplayModel? NewStockEntry { get; private set; }
        public bool SaveAndAddAnother { get; private set; }
        private bool _isLoaded = false;

        public AddStockEntryDialog()
        {
            InitializeComponent();
            
            _stockService = new StockService();
            _productService = new ProductService();
            
            LoadProductsAsync();
            GenerateBatchNumber();

            // Handle status change for progress visibility
            StockStatusComboBox.SelectionChanged += StockStatusComboBox_SelectionChanged;
            
            // Set loaded flag after initialization
            this.Loaded += (s, e) => _isLoaded = true;
        }

        private async void LoadProductsAsync()
        {
            try
            {
                _products = await _productService.GetAllProductsAsync();
                
                foreach (var product in _products)
                {
                    ProductComboBox.Items.Add(new ComboBoxItem 
                    { 
                        Content = $"{product.Name} ({product.Category})",
                        Tag = product.ProductId
                    });
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error loading products: {ex.Message}", "Error",
                    MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void GenerateBatchNumber()
        {
            string batchNo = $"BTH-{DateTime.Now:yyyy}-{new Random().Next(100, 999)}";
            BatchNoTextBox.Text = batchNo;
        }

        private void GenerateBatchNo_Click(object sender, RoutedEventArgs e)
        {
            GenerateBatchNumber();
        }

        private void ProductComboBox_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            if (!_isLoaded) return;
            
            if (ProductIdTextBox == null || CategoryTextBox == null) return;
            
            if (ProductComboBox.SelectedIndex <= 0)
            {
                ProductIdTextBox.Text = "";
                CategoryTextBox.Text = "";
                return;
            }

            var selectedItem = ProductComboBox.SelectedItem as ComboBoxItem;
            if (selectedItem?.Tag != null)
            {
                int productId = (int)selectedItem.Tag;
                var product = _products.FirstOrDefault(p => p.ProductId == productId);
                
                if (product != null)
                {
                    ProductIdTextBox.Text = productId.ToString();
                    CategoryTextBox.Text = product.Category.ToString();
                }
            }
        }

        private void StockStatusComboBox_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            if (!_isLoaded) return;
            
            if (ProgressPanel == null || ProgressTextBox == null) return;

            var selectedItem = StockStatusComboBox.SelectedItem as ComboBoxItem;
            if (selectedItem?.Content?.ToString()?.Contains("In Process") == true)
            {
                ProgressPanel.Visibility = Visibility.Visible;
            }
            else
            {
                ProgressPanel.Visibility = Visibility.Collapsed;
                ProgressTextBox.Text = "0";
            }
        }

        private void NumericOnly_PreviewTextInput(object sender, TextCompositionEventArgs e)
        {
            Regex regex = new Regex("[^0-9]+");
            e.Handled = regex.IsMatch(e.Text);
        }

        private bool ValidateInput()
        {
            // Validate product selection
            if (ProductComboBox.SelectedIndex <= 0)
            {
                MessageBox.Show("Please select a product.", "Validation Error",
                    MessageBoxButton.OK, MessageBoxImage.Warning);
                ProductComboBox.Focus();
                return false;
            }

            // Validate batch number
            if (string.IsNullOrWhiteSpace(BatchNoTextBox.Text))
            {
                MessageBox.Show("Please enter or generate a batch number.", "Validation Error",
                    MessageBoxButton.OK, MessageBoxImage.Warning);
                BatchNoTextBox.Focus();
                return false;
            }

            // Validate quantity
            if (string.IsNullOrWhiteSpace(QuantityTextBox.Text) || !int.TryParse(QuantityTextBox.Text, out int qty) || qty <= 0)
            {
                MessageBox.Show("Please enter a valid quantity (greater than 0).", "Validation Error",
                    MessageBoxButton.OK, MessageBoxImage.Warning);
                QuantityTextBox.Focus();
                return false;
            }

            // Validate progress if In Process
            var statusItem = StockStatusComboBox.SelectedItem as ComboBoxItem;
            if (statusItem?.Content?.ToString()?.Contains("In Process") == true)
            {
                if (!int.TryParse(ProgressTextBox.Text, out int progress) || progress < 0 || progress > 100)
                {
                    MessageBox.Show("Progress must be between 0 and 100.", "Validation Error",
                        MessageBoxButton.OK, MessageBoxImage.Warning);
                    ProgressTextBox.Focus();
                    return false;
                }
            }

            return true;
        }

        private Stock CreateStockEntry()
        {
            var selectedItem = ProductComboBox.SelectedItem as ComboBoxItem;
            int productId = (int)(selectedItem?.Tag ?? 0);
            var product = _products.FirstOrDefault(p => p.ProductId == productId);

            int quantity = int.Parse(QuantityTextBox.Text);
            var statusItem = StockStatusComboBox.SelectedItem as ComboBoxItem;
            string statusText = statusItem?.Content?.ToString() ?? "Ready";
            
            string stockStatus = "Ready";
            if (statusText.Contains("In Process")) stockStatus = "InProcess";
            else if (statusText.Contains("Shipped")) stockStatus = "Shipped";
            else if (statusText.Contains("Delivered")) stockStatus = "Delivered";

            int progress = 100;
            if (stockStatus == "InProcess")
            {
                int.TryParse(ProgressTextBox.Text, out progress);
            }

            var stockEntry = new Stock
            {
                ProductId = productId,
                BatchNo = BatchNoTextBox.Text,
                EntryDate = EntryDatePicker.SelectedDate ?? DateTime.Now,
                Quantity = quantity,
                StockStatus = stockStatus,
                ProgressPercentage = progress,
                Location = (LocationComboBox.SelectedItem as ComboBoxItem)?.Content?.ToString(),
                Notes = string.IsNullOrWhiteSpace(NotesTextBox.Text) ? null : NotesTextBox.Text,
                ProductName = product?.Name ?? "",
                Category = product?.Category.ToString() ?? ""
            };

            return stockEntry;
        }

        private async void SaveButton_Click(object sender, RoutedEventArgs e)
        {
            if (!ValidateInput()) return;

            try
            {
                var stockEntry = CreateStockEntry();
                int newStockId = await _stockService.AddStockEntryAsync(stockEntry);
                stockEntry.StockId = newStockId;
                
                NewStockEntry = null; // Not using StockDisplayModel anymore
                SaveAndAddAnother = false;

                MessageBox.Show($"✅ Stock entry added successfully!\n\n" +
                    $"Stock ID: {newStockId}\n" +
                    $"Product: {stockEntry.ProductName}\n" +
                    $"Batch: {stockEntry.BatchNo}\n" +
                    $"Quantity: {stockEntry.Quantity}\n" +
                    $"Status: {stockEntry.StockStatus}",
                    "Success", MessageBoxButton.OK, MessageBoxImage.Information);

                DialogResult = true;
                Close();
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error saving stock entry: {ex.Message}", "Error",
                    MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private async void SaveAndAddButton_Click(object sender, RoutedEventArgs e)
        {
            if (!ValidateInput()) return;

            try
            {
                var stockEntry = CreateStockEntry();
                int newStockId = await _stockService.AddStockEntryAsync(stockEntry);
                
                SaveAndAddAnother = true;

                MessageBox.Show($"✅ Stock entry added!\n\n" +
                    $"Stock ID: {newStockId}\n" +
                    $"Product: {stockEntry.ProductName}\n" +
                    $"Batch: {stockEntry.BatchNo}\n" +
                    $"Quantity: {stockEntry.Quantity}\n" +
                    $"Status: {stockEntry.StockStatus}\n\n" +
                    "Ready to add another entry.",
                    "Entry Saved", MessageBoxButton.OK, MessageBoxImage.Information);

                // Reset form for next entry
                ResetForm();
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error saving stock entry: {ex.Message}", "Error",
                    MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void ResetForm()
        {
            ProductComboBox.SelectedIndex = 0;
            ProductIdTextBox.Text = "";
            CategoryTextBox.Text = "";
            GenerateBatchNumber();
            QuantityTextBox.Text = "";
            StockStatusComboBox.SelectedIndex = 0;
            ProgressTextBox.Text = "0";
            ProgressPanel.Visibility = Visibility.Collapsed;
            LocationComboBox.SelectedIndex = 0;
            NotesTextBox.Text = "";
            EntryDatePicker.SelectedDate = DateTime.Now;
        }

        private void CancelButton_Click(object sender, RoutedEventArgs e)
        {
            DialogResult = false;
            Close();
        }
    }
}
