using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Linq;
using System.Windows;
using System.Windows.Controls;
using FactoryManagmentSystem.Models;
using RawMaterial = FactoryManagmentSystem.Models.Entities.RawMaterial;
using FactoryManagmentSystem.Services;

namespace FactoryManagmentSystem.Views
{
    public partial class ProductManagementView : UserControl
    {
        private ObservableCollection<Product> _products;
        private ObservableCollection<Product> _filteredProducts;
        private Product? _selectedProduct;
        private int _currentPage = 1;
        private const int _pageSize = 10;
        private string _currentActiveTab = "ViewAll";
        private readonly ProductService _productService;
        private readonly ProductMaterialDataService _materialService;
        private readonly RawMaterialDataService _rawMaterialService;
        private ObservableCollection<ProductMaterialItem> _addProductMaterials;

        public ProductManagementView()
        {
            InitializeComponent();
            _products = new ObservableCollection<Product>();
            _filteredProducts = new ObservableCollection<Product>();
            _addProductMaterials = new ObservableCollection<ProductMaterialItem>();
            _productService = new ProductService();
            _materialService = new ProductMaterialDataService();
            _rawMaterialService = new RawMaterialDataService();
            
            InitializeData();
            SetupEventHandlers();
        }

        private async void InitializeData()
        {
            try
            {
                await LoadProducts();
                LoadFilterOptions();
                UpdateStatistics();
                UpdatePagination();
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error initializing product data: {ex.Message}", "Error", 
                               MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void SetupEventHandlers()
        {
            ProductsDataGrid.ItemsSource = _filteredProducts;
            DeleteProductsDataGrid.ItemsSource = _filteredProducts;
            AddProductMaterialsDataGrid.ItemsSource = _addProductMaterials;
        }

        private async System.Threading.Tasks.Task LoadProducts()
        {
            _products.Clear();
            
            try
            {
                var products = await _productService.GetAllProductsAsync();
                foreach (var product in products)
                {
                    _products.Add(product);
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error loading products: {ex.Message}", "Error", 
                               MessageBoxButton.OK, MessageBoxImage.Error);
            }

            ApplyFilters();
        }

        private void LoadProductsOLD()
        {
            _products.Clear();
            
            // Sample data for garments factory
            var products = new List<Product>
            {
                new TShirt
                {
                    ProductId = 1,
                    ProductCode = "TSH001",
                    Name = "Classic Cotton T-Shirt",
                    Description = "Premium quality cotton t-shirt with comfortable fit",
                    Category = ProductCategory.TShirts,
                    Brand = "Factory Premium",
                    Price = 1500,
                    Currency = "PKR",
                    AvailableSizes = new List<ProductSize> { ProductSize.S, ProductSize.M, ProductSize.L, ProductSize.XL },
                    AvailableColors = new List<string> { "White", "Black", "Navy", "Gray" },
                    Material = "100% Cotton",
                    CreatedDate = DateTime.Now.AddDays(-30),
                    LastUpdated = DateTime.Now.AddDays(-5),
                    IsActive = true,
                    ProductionStatus = ProductionStatus.Ready
                },
                new TShirt
                {
                    ProductId = 2,
                    ProductCode = "TSH002",
                    Name = "V-Neck Premium T-Shirt",
                    Description = "Stylish v-neck t-shirt with premium cotton blend",
                    Category = ProductCategory.TShirts,
                    Brand = "Fashion Forward",
                    Price = 1800,
                    Currency = "PKR",
                    AvailableSizes = new List<ProductSize> { ProductSize.S, ProductSize.M, ProductSize.L, ProductSize.XL, ProductSize.XXL },
                    AvailableColors = new List<string> { "White", "Blue", "Red", "Green" },
                    Material = "Cotton Blend",
                    CreatedDate = DateTime.Now.AddDays(-25),
                    LastUpdated = DateTime.Now.AddDays(-3),
                    IsActive = true,
                    ProductionStatus = ProductionStatus.InProduction
                },
                new Shirt
                {
                    ProductId = 3,
                    ProductCode = "SHT001",
                    Name = "Formal Business Shirt",
                    Description = "Professional formal shirt perfect for office wear",
                    Category = ProductCategory.Shirts,
                    Brand = "Executive Line",
                    Price = 3500,
                    Currency = "PKR",
                    AvailableSizes = new List<ProductSize> { ProductSize.S, ProductSize.M, ProductSize.L, ProductSize.XL },
                    AvailableColors = new List<string> { "White", "Light Blue", "Light Pink" },
                    Material = "Cotton Polyester",
                    CreatedDate = DateTime.Now.AddDays(-20),
                    LastUpdated = DateTime.Now.AddDays(-2),
                    IsActive = true,
                    ProductionStatus = ProductionStatus.Ready
                },
                new Jeans
                {
                    ProductId = 4,
                    ProductCode = "JNS001",
                    Name = "Slim Fit Dark Blue Jeans",
                    Description = "Modern slim fit jeans with premium denim fabric",
                    Category = ProductCategory.Jeans,
                    Brand = "Denim Works",
                    Price = 4500,
                    Currency = "PKR",
                    AvailableSizes = new List<ProductSize> { ProductSize.S, ProductSize.M, ProductSize.L, ProductSize.XL },
                    AvailableColors = new List<string> { "Dark Blue", "Medium Blue", "Black" },
                    Material = "Premium Denim",
                    CreatedDate = DateTime.Now.AddDays(-15),
                    LastUpdated = DateTime.Now.AddDays(-1),
                    IsActive = true,
                    ProductionStatus = ProductionStatus.QualityCheck
                },
                new Sweatshirt
                {
                    ProductId = 5,
                    ProductCode = "SWT001",
                    Name = "Hooded Sweatshirt",
                    Description = "Comfortable hooded sweatshirt perfect for casual wear",
                    Category = ProductCategory.Sweatshirts,
                    Brand = "Comfort Zone",
                    Price = 3200,
                    Currency = "PKR",
                    AvailableSizes = new List<ProductSize> { ProductSize.S, ProductSize.M, ProductSize.L, ProductSize.XL, ProductSize.XXL },
                    AvailableColors = new List<string> { "Gray", "Black", "Navy", "Maroon" },
                    Material = "Cotton Fleece",
                    CreatedDate = DateTime.Now.AddDays(-18),
                    LastUpdated = DateTime.Now.AddDays(-4),
                    IsActive = true,
                    ProductionStatus = ProductionStatus.Ready
                },
                new Jacket
                {
                    ProductId = 6,
                    ProductCode = "JKT001",
                    Name = "Denim Jacket Classic",
                    Description = "Classic denim jacket with vintage styling",
                    Category = ProductCategory.Jackets,
                    Brand = "Vintage Style",
                    Price = 5500,
                    Currency = "PKR",
                    AvailableSizes = new List<ProductSize> { ProductSize.S, ProductSize.M, ProductSize.L, ProductSize.XL },
                    AvailableColors = new List<string> { "Light Blue", "Dark Blue", "Black" },
                    Material = "Denim",
                    CreatedDate = DateTime.Now.AddDays(-12),
                    LastUpdated = DateTime.Now,
                    IsActive = true,
                    ProductionStatus = ProductionStatus.InProduction
                },
                new Pants
                {
                    ProductId = 7,
                    ProductCode = "PNT001",
                    Name = "Formal Trousers",
                    Description = "Professional formal trousers for business wear",
                    Category = ProductCategory.Pants,
                    Brand = "Business Elite",
                    Price = 3800,
                    Currency = "PKR",
                    AvailableSizes = new List<ProductSize> { ProductSize.S, ProductSize.M, ProductSize.L, ProductSize.XL },
                    AvailableColors = new List<string> { "Black", "Navy", "Gray", "Brown" },
                    Material = "Polyester Wool",
                    CreatedDate = DateTime.Now.AddDays(-22),
                    LastUpdated = DateTime.Now.AddDays(-6),
                    IsActive = true,
                    ProductionStatus = ProductionStatus.Ready
                },
                new TShirt
                {
                    ProductId = 8,
                    ProductCode = "TSH003",
                    Name = "Graphic Print T-Shirt",
                    Description = "Trendy graphic print t-shirt with unique design",
                    Category = ProductCategory.TShirts,
                    Brand = "Urban Style",
                    Price = 2200,
                    Currency = "PKR",
                    AvailableSizes = new List<ProductSize> { ProductSize.S, ProductSize.M, ProductSize.L, ProductSize.XL },
                    AvailableColors = new List<string> { "White", "Black", "Yellow", "Purple" },
                    Material = "Cotton",
                    CreatedDate = DateTime.Now.AddDays(-8),
                    LastUpdated = DateTime.Now.AddDays(-1),
                    IsActive = true,
                    ProductionStatus = ProductionStatus.Ready
                },
                new Shirt
                {
                    ProductId = 9,
                    ProductCode = "SHT002",
                    Name = "Casual Check Shirt",
                    Description = "Comfortable casual check shirt for everyday wear",
                    Category = ProductCategory.Shirts,
                    Brand = "Casual Comfort",
                    Price = 2800,
                    Currency = "PKR",
                    AvailableSizes = new List<ProductSize> { ProductSize.S, ProductSize.M, ProductSize.L, ProductSize.XL },
                    AvailableColors = new List<string> { "Blue Check", "Red Check", "Green Check" },
                    Material = "Cotton",
                    CreatedDate = DateTime.Now.AddDays(-10),
                    LastUpdated = DateTime.Now.AddDays(-2),
                    IsActive = true,
                    ProductionStatus = ProductionStatus.Ready
                },
                new Jeans
                {
                    ProductId = 10,
                    ProductCode = "JNS002",
                    Name = "Relaxed Fit Jeans",
                    Description = "Comfortable relaxed fit jeans for casual wear",
                    Category = ProductCategory.Jeans,
                    Brand = "Comfort Denim",
                    Price = 4200,
                    Currency = "PKR",
                    AvailableSizes = new List<ProductSize> { ProductSize.M, ProductSize.L, ProductSize.XL, ProductSize.XXL },
                    AvailableColors = new List<string> { "Medium Blue", "Light Blue" },
                    Material = "Stretch Denim",
                    CreatedDate = DateTime.Now.AddDays(-7),
                    LastUpdated = DateTime.Now,
                    IsActive = true,
                    ProductionStatus = ProductionStatus.Ready
                }
            };

            foreach (var product in products)
            {
                _products.Add(product);
            }

            ApplyFilters();
        }

        private void LoadFilterOptions()
        {
            // Category Filter
            var categories = new List<string> { "All Categories", "T-Shirts", "Shirts", "Jeans", "Pants", "Jackets", "Sweatshirts" };
            CategoryFilterComboBox.ItemsSource = categories;
            CategoryFilterComboBox.SelectedIndex = 0;

            // Status Filter
            var statuses = new List<string> { "All Status", "Ready", "In Production", "Quality Check", "Pending" };
            StatusFilterComboBox.ItemsSource = statuses;
            StatusFilterComboBox.SelectedIndex = 0;

            // Sort By
            var sortOptions = new List<string> { "Name", "Price (Low-High)", "Price (High-Low)", "Stock (Low-High)", "Stock (High-Low)", "Category" };
            SortByComboBox.ItemsSource = sortOptions;
            SortByComboBox.SelectedIndex = 0;

            // Add Product Form ComboBoxes
            var addCategories = new List<string> { "T-Shirts", "Shirts", "Jeans", "Pants", "Jackets", "Sweatshirts" };
            AddCategoryComboBox.ItemsSource = addCategories;
            AddCategoryComboBox.SelectedIndex = 0;

            var materials = new List<string> { "100% Cotton", "Cotton Blend", "Cotton Polyester", "Premium Denim", "Stretch Denim", "Cotton Fleece", "Polyester Wool", "Denim" };
            AddMaterialComboBox.ItemsSource = materials;
            AddMaterialComboBox.SelectedIndex = 0;

            // Update Form ComboBoxes
            UpdateCategoryComboBox.ItemsSource = addCategories;
            UpdateMaterialComboBox.ItemsSource = materials;
        }

        private void ApplyFilters()
        {
            var filtered = _products.AsEnumerable();

            // Search filter
            if (!string.IsNullOrWhiteSpace(SearchTextBox?.Text))
            {
                string searchTerm = SearchTextBox.Text.ToLower();
                filtered = filtered.Where(p => 
                    p.Name.ToLower().Contains(searchTerm) ||
                    p.ProductCode.ToLower().Contains(searchTerm) ||
                    p.Material.ToLower().Contains(searchTerm) ||
                    p.Description.ToLower().Contains(searchTerm));
            }

            // Category filter
            string? selectedCategory = CategoryFilterComboBox?.SelectedItem?.ToString();
            if (!string.IsNullOrEmpty(selectedCategory) && selectedCategory != "All Categories")
            {
                filtered = filtered.Where(p => p.Category.ToString() == selectedCategory.Replace("-", ""));
            }

            // Status filter
            string? selectedStatus = StatusFilterComboBox?.SelectedItem?.ToString();
            if (!string.IsNullOrEmpty(selectedStatus) && selectedStatus != "All Status")
            {
                filtered = filtered.Where(p => p.ProductionStatus.ToString() == selectedStatus.Replace(" ", ""));
            }

            // Apply sorting
            string? sortBy = SortByComboBox?.SelectedItem?.ToString();
            filtered = sortBy switch
            {
                "Price (Low-High)" => filtered.OrderBy(p => p.Price),
                "Price (High-Low)" => filtered.OrderByDescending(p => p.Price),
                "Category" => filtered.OrderBy(p => p.Category),
                _ => filtered.OrderBy(p => p.Name)
            };

            _filteredProducts.Clear();
            foreach (var product in filtered.Skip((_currentPage - 1) * _pageSize).Take(_pageSize))
            {
                _filteredProducts.Add(product);
            }

            UpdatePagination();
        }

        private void UpdateStatistics()
        {
            try
            {
                int totalProducts = _products.Count;
                int activeProducts = _products.Count(p => p.IsActive);

                TotalProductsCount.Text = totalProducts.ToString();
                ActiveProductsCount.Text = activeProducts.ToString();
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error updating statistics: {ex.Message}", "Error", 
                               MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void UpdatePagination()
        {
            int totalItems = _products.Count;
            int totalPages = (int)Math.Ceiling((double)totalItems / _pageSize);
            
            PageNumberText.Text = $"Page {_currentPage} of {Math.Max(1, totalPages)}";
            PaginationInfo.Text = $"Showing {_filteredProducts.Count} of {totalItems} products";
            
            PreviousPageButton.IsEnabled = _currentPage > 1;
            NextPageButton.IsEnabled = _currentPage < totalPages;
        }

        // Load next available product code
        private async void LoadNextProductCode()
        {
            try
            {
                string nextCode = await _productService.GetNextProductCodeAsync();
                AddProductCodeTextBox.Text = nextCode;
                AddProductCodeTextBox.IsReadOnly = true; // Make it read-only to prevent manual changes
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error loading product code: {ex.Message}", "Error", 
                               MessageBoxButton.OK, MessageBoxImage.Error);
                AddProductCodeTextBox.Text = "PC001"; // Default fallback
                AddProductCodeTextBox.IsReadOnly = true;
            }
        }

        // Tab Navigation
        private void TabButton_Click(object sender, RoutedEventArgs e)
        {
            if (sender is Button button && button.Tag is string tabName)
            {
                SwitchToTab(tabName);
            }
        }

        private void SwitchToTab(string tabName)
        {
            // Hide all content
            ViewAllContent.Visibility = Visibility.Collapsed;
            AddProductContent.Visibility = Visibility.Collapsed;
            UpdateProductContent.Visibility = Visibility.Collapsed;
            DeleteProductContent.Visibility = Visibility.Collapsed;

            // Reset all tab button styles
            ViewAllTab.Style = (Style)FindResource("TabButtonStyle");
            AddProductTab.Style = (Style)FindResource("TabButtonStyle");
            UpdateProductTab.Style = (Style)FindResource("TabButtonStyle");
            DeleteProductTab.Style = (Style)FindResource("TabButtonStyle");

            // Show selected content and set active tab style
            switch (tabName)
            {
                case "ViewAll":
                    ViewAllContent.Visibility = Visibility.Visible;
                    ViewAllTab.Style = (Style)FindResource("ActiveTabButtonStyle");
                    LoadProducts();
                    break;
                case "AddProduct":
                    AddProductContent.Visibility = Visibility.Visible;
                    AddProductTab.Style = (Style)FindResource("ActiveTabButtonStyle");
                    LoadNextProductCode();
                    LoadRawMaterialsForAddProduct();
                    break;
                case "UpdateProduct":
                    UpdateProductContent.Visibility = Visibility.Visible;
                    UpdateProductTab.Style = (Style)FindResource("ActiveTabButtonStyle");
                    break;
                case "DeleteProduct":
                    DeleteProductContent.Visibility = Visibility.Visible;
                    DeleteProductTab.Style = (Style)FindResource("ActiveTabButtonStyle");
                    LoadProducts();
                    break;
            }

            _currentActiveTab = tabName;
        }

        // Search and Filter Events
        private void SearchTextBox_TextChanged(object sender, TextChangedEventArgs e)
        {
            if (SearchPlaceholder != null)
            {
                SearchPlaceholder.Visibility = string.IsNullOrEmpty(SearchTextBox.Text) 
                    ? Visibility.Visible : Visibility.Collapsed;
            }
            _currentPage = 1;
            ApplyFilters();
            UpdateStatistics();
        }

        private void CategoryFilter_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            _currentPage = 1;
            ApplyFilters();
        }

        private void StatusFilter_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            _currentPage = 1;
            ApplyFilters();
        }

        private void SortBy_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            ApplyFilters();
        }

        private void SearchButton_Click(object sender, RoutedEventArgs e)
        {
            _currentPage = 1;
            ApplyFilters();
        }

        private void RefreshButton_Click(object sender, RoutedEventArgs e)
        {
            SearchTextBox.Text = "";
            CategoryFilterComboBox.SelectedIndex = 0;
            StatusFilterComboBox.SelectedIndex = 0;
            SortByComboBox.SelectedIndex = 0;
            _currentPage = 1;
            LoadProducts();
            UpdateStatistics();
        }

        // Pagination
        private void PreviousPage_Click(object sender, RoutedEventArgs e)
        {
            if (_currentPage > 1)
            {
                _currentPage--;
                ApplyFilters();
            }
        }

        private void NextPage_Click(object sender, RoutedEventArgs e)
        {
            int totalPages = (int)Math.Ceiling((double)_products.Count / _pageSize);
            if (_currentPage < totalPages)
            {
                _currentPage++;
                ApplyFilters();
            }
        }

        // DataGrid Action Handlers
        private void ViewProduct_Click(object sender, RoutedEventArgs e)
        {
            if (sender is Button button && button.Tag is int productId)
            {
                var product = _products.FirstOrDefault(p => p.ProductId == productId);
                if (product != null)
                {
                    ShowProductDetails(product);
                }
            }
        }

        private void EditProduct_Click(object sender, RoutedEventArgs e)
        {
            if (sender is Button button && button.Tag is int productId)
            {
                var product = _products.FirstOrDefault(p => p.ProductId == productId);
                if (product != null)
                {
                    _selectedProduct = product;
                    SwitchToTab("UpdateProduct");
                    PopulateUpdateForm(product);
                }
            }
        }

        private void DeleteProduct_Click(object sender, RoutedEventArgs e)
        {
            if (sender is Button button && button.Tag is int productId)
            {
                var product = _products.FirstOrDefault(p => p.ProductId == productId);
                if (product != null)
                {
                    ConfirmAndDeleteProduct(product);
                }
            }
        }

        // Add Product Form
        private void ClearAddForm_Click(object sender, RoutedEventArgs e)
        {
            AddProductNameTextBox.Text = "";
            LoadNextProductCode(); // Reload next product code
            AddBrandTextBox.Text = "";
            AddPriceTextBox.Text = "";
            AddColorsTextBox.Text = "White, Black, Navy, Gray";
            AddDescriptionTextBox.Text = "";
            AddCategoryComboBox.SelectedIndex = 0;
            AddMaterialComboBox.SelectedIndex = 0;
            AddIsActiveCheckBox.IsChecked = true;
            
            // Reset size checkboxes
            SizeXS.IsChecked = false;
            SizeS.IsChecked = true;
            SizeM.IsChecked = true;
            SizeL.IsChecked = true;
            SizeXL.IsChecked = true;
            SizeXXL.IsChecked = false;
            SizeXXXL.IsChecked = false;
            
            // Clear material requirements list
            _addProductMaterials.Clear();
            AddProductMaterialComboBox.SelectedIndex = -1;
            AddProductMaterialQuantityTextBox.Text = "";
            AddProductMaterialUnitTextBox.Text = "";
            AddProductTotalMaterialCostText.Text = "Rs. 0.00";
        }

        private async void SaveProduct_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                // Validate required fields
                if (string.IsNullOrWhiteSpace(AddProductNameTextBox.Text))
                {
                    MessageBox.Show("Product Name is required.", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                    return;
                }

                // Auto-generate product code right before saving to ensure uniqueness
                string productCode = await _productService.GetNextProductCodeAsync();
                AddProductCodeTextBox.Text = productCode;

                if (!decimal.TryParse(AddPriceTextBox.Text, out decimal price) || price <= 0)
                {
                    MessageBox.Show("Please enter a valid selling price.", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                    return;
                }

                // MANDATORY: Validate material requirements - at least one material must be added
                if (_addProductMaterials == null || _addProductMaterials.Count == 0)
                {
                    MessageBox.Show("❌ Material Requirements are mandatory!\n\nPlease add at least one raw material for this product before saving.\n\nGo to the 'Material Requirements' section and click '➕ Add' to add materials.", 
                                   "Material Requirements Required", 
                                   MessageBoxButton.OK, 
                                   MessageBoxImage.Warning);
                    return;
                }

                // Get selected sizes
                var sizes = new List<ProductSize>();
                if (SizeXS.IsChecked == true) sizes.Add(ProductSize.XS);
                if (SizeS.IsChecked == true) sizes.Add(ProductSize.S);
                if (SizeM.IsChecked == true) sizes.Add(ProductSize.M);
                if (SizeL.IsChecked == true) sizes.Add(ProductSize.L);
                if (SizeXL.IsChecked == true) sizes.Add(ProductSize.XL);
                if (SizeXXL.IsChecked == true) sizes.Add(ProductSize.XXL);
                if (SizeXXXL.IsChecked == true) sizes.Add(ProductSize.XXXL);

                // Parse colors
                var colors = AddColorsTextBox.Text.Split(',').Select(c => c.Trim()).Where(c => !string.IsNullOrEmpty(c)).ToList();

                // Create new product with auto-generated SKU
                var newProduct = new Product
                {
                    SKU = AddProductCodeTextBox.Text.Trim(), // Use SKU field instead of ProductCode
                    Name = AddProductNameTextBox.Text.Trim(),
                    Description = AddDescriptionTextBox.Text.Trim(),
                    Category = ParseCategory(AddCategoryComboBox.SelectedItem?.ToString() ?? "T-Shirts"),
                    Brand = AddBrandTextBox.Text.Trim(),
                    Price = price,
                    AvailableSizes = sizes,
                    AvailableColors = colors,
                    Material = AddMaterialComboBox.SelectedItem?.ToString() ?? "100% Cotton",
                    CreatedDate = DateTime.Now,
                    LastUpdated = DateTime.Now,
                    IsActive = AddIsActiveCheckBox.IsChecked ?? true,
                    ProductionStatus = ProductionStatus.Ready
                };

                // Save to database
                int newProductId = await _productService.AddProductAsync(newProduct);
                newProduct.ProductId = newProductId;
                
                // Save material requirements if any were added
                int materialsSavedCount = 0;
                if (newProductId > 0 && _addProductMaterials.Any())
                {
                    foreach (var material in _addProductMaterials)
                    {
                        int requirementId = await _materialService.AddProductMaterialRequirementAsync(
                            newProductId, 
                            material.RawMaterialID, 
                            material.QuantityRequired, 
                            material.Unit, 
                            "");
                        
                        if (requirementId > 0)
                            materialsSavedCount++;
                    }
                }
                
                _products.Add(newProduct);
                ApplyFilters();
                UpdateStatistics();
                
                string successMessage = $"Product '{newProduct.Name}' has been added successfully!";
                if (materialsSavedCount > 0)
                {
                    successMessage += $"\n{materialsSavedCount} material requirement(s) saved.";
                }
                
                MessageBox.Show(successMessage, "Success", MessageBoxButton.OK, MessageBoxImage.Information);

                ClearAddForm_Click(sender, e);
                SwitchToTab("ViewAll");
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error saving product: {ex.Message}", "Error", 
                               MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        // Update Product Form
        private void UpdateSearch_TextChanged(object sender, TextChangedEventArgs e)
        {
            // Search products as user types
        }

        private void FindProduct_Click(object sender, RoutedEventArgs e)
        {
            string searchTerm = UpdateSearchTextBox.Text.Trim().ToLower();
            if (string.IsNullOrEmpty(searchTerm))
            {
                MessageBox.Show("Please enter a product name or code to search.", "Search Required", 
                               MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }

            var product = _products.FirstOrDefault(p => 
                p.Name.ToLower().Contains(searchTerm) || 
                p.ProductCode.ToLower().Contains(searchTerm));

            if (product != null)
            {
                _selectedProduct = product;
                PopulateUpdateForm(product);
                UpdateFormGrid.Visibility = Visibility.Visible;
                UpdateActionsPanel.Visibility = Visibility.Visible;
            }
            else
            {
                MessageBox.Show("No product found matching your search.", "Not Found", 
                               MessageBoxButton.OK, MessageBoxImage.Information);
            }
        }

        private void PopulateUpdateForm(Product product)
        {
            UpdateProductNameTextBox.Text = product.Name;
            UpdatePriceTextBox.Text = product.Price.ToString();
            UpdateDescriptionTextBox.Text = product.Description;
            UpdateIsActiveCheckBox.IsChecked = product.IsActive;

            // Set category
            for (int i = 0; i < UpdateCategoryComboBox.Items.Count; i++)
            {
                if (UpdateCategoryComboBox.Items[i]?.ToString() == product.Category.ToString())
                {
                    UpdateCategoryComboBox.SelectedIndex = i;
                    break;
                }
            }

            // Set material
            for (int i = 0; i < UpdateMaterialComboBox.Items.Count; i++)
            {
                if (UpdateMaterialComboBox.Items[i]?.ToString() == product.Material)
                {
                    UpdateMaterialComboBox.SelectedIndex = i;
                    break;
                }
            }

            UpdateFormGrid.Visibility = Visibility.Visible;
            UpdateActionsPanel.Visibility = Visibility.Visible;
        }

        private void CancelUpdate_Click(object sender, RoutedEventArgs e)
        {
            _selectedProduct = null;
            UpdateSearchTextBox.Text = "";
            UpdateFormGrid.Visibility = Visibility.Collapsed;
            UpdateActionsPanel.Visibility = Visibility.Collapsed;
        }

        private async void UpdateProduct_Click(object sender, RoutedEventArgs e)
        {
            if (_selectedProduct == null)
            {
                MessageBox.Show("No product selected for update.", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
                return;
            }

            try
            {
                // Validate
                if (!decimal.TryParse(UpdatePriceTextBox.Text, out decimal price) || price <= 0)
                {
                    MessageBox.Show("Please enter a valid selling price.", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                    return;
                }

                // Update product properties
                _selectedProduct.Name = UpdateProductNameTextBox.Text.Trim();
                _selectedProduct.Price = price;
                _selectedProduct.Material = UpdateMaterialComboBox.SelectedItem?.ToString() ?? _selectedProduct.Material;
                _selectedProduct.Description = UpdateDescriptionTextBox.Text.Trim();
                _selectedProduct.IsActive = UpdateIsActiveCheckBox.IsChecked ?? true;
                _selectedProduct.LastUpdated = DateTime.Now;

                // Update in database
                await _productService.UpdateProductAsync(_selectedProduct);
                
                ApplyFilters();
                UpdateStatistics();

                MessageBox.Show($"Product '{_selectedProduct.Name}' has been updated successfully!", 
                    "Success", MessageBoxButton.OK, MessageBoxImage.Information);

                CancelUpdate_Click(sender, e);
                SwitchToTab("ViewAll");
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error updating product: {ex.Message}", "Error", 
                               MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        // Stock Management
        // Delete Product
        private void ConfirmDeleteProduct_Click(object sender, RoutedEventArgs e)
        {
            if (sender is Button button && button.Tag is int productId)
            {
                var product = _products.FirstOrDefault(p => p.ProductId == productId);
                if (product != null)
                {
                    ConfirmAndDeleteProduct(product);
                }
            }
        }

        private async void ConfirmAndDeleteProduct(Product product)
        {
            var result = MessageBox.Show(
                $"Are you sure you want to delete '{product.Name}'?\n\n" +
                $"Product Code: {product.ProductCode}\n\n" +
                $"This action cannot be undone.",
                "Confirm Delete",
                MessageBoxButton.YesNo,
                MessageBoxImage.Warning);

            if (result == MessageBoxResult.Yes)
            {
                try
                {
                    // Delete from database
                    await _productService.DeleteProductAsync(product.ProductId);
                    
                    _products.Remove(product);
                    ApplyFilters();
                    UpdateStatistics();
                    
                    MessageBox.Show($"Product '{product.Name}' has been deleted successfully.", 
                        "Deleted", MessageBoxButton.OK, MessageBoxImage.Information);
                }
                catch (Exception ex)
                {
                    MessageBox.Show($"Error deleting product: {ex.Message}", "Error", 
                                   MessageBoxButton.OK, MessageBoxImage.Error);
                }
            }
        }

        // Helper Methods
        private void ShowProductDetails(Product product)
        {
            var sizesText = string.Join(", ", product.AvailableSizes);
            var colorsText = string.Join(", ", product.AvailableColors);
            
            var details = $"📦 PRODUCT DETAILS\n\n" +
                         $"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n" +
                         $"Name: {product.Name}\n" +
                         $"Code: {product.ProductCode}\n" +
                         $"Category: {product.Category}\n" +
                         $"Brand: {product.Brand}\n" +
                         $"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n" +
                         $"💰 PRICING\n" +
                         $"Selling Price: Rs. {product.Price:N0}\n\n" +
                         $"📏 VARIANTS\n" +
                         $"Sizes: {sizesText}\n" +
                         $"Colors: {colorsText}\n" +
                         $"Material: {product.Material}\n\n" +
                         $"📊 STATUS\n" +
                         $"Status: {product.ProductionStatus}\n\n" +
                         $"📅 DATES\n" +
                         $"Created: {product.CreatedDate:dd/MM/yyyy}\n" +
                         $"Last Updated: {product.LastUpdated:dd/MM/yyyy}";

            MessageBox.Show(details, $"Product Details - {product.Name}", 
                MessageBoxButton.OK, MessageBoxImage.Information);
        }

        // Add Product Material Requirements (Inline)
        private async void LoadRawMaterialsForAddProduct()
        {
            try
            {
                var rawMaterials = await _rawMaterialService.GetAllRawMaterialsAsync();
                AddProductMaterialComboBox.ItemsSource = rawMaterials;
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error loading raw materials: {ex.Message}", "Error", 
                               MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void AddProductMaterial_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            if (AddProductMaterialComboBox.SelectedItem is RawMaterialInfo material)
            {
                AddProductMaterialUnitTextBox.Text = material.Unit;
            }
        }

        private void AddProductMaterialToList_Click(object sender, RoutedEventArgs e)
        {
            if (AddProductMaterialComboBox.SelectedItem is not RawMaterialInfo selectedMaterial)
            {
                MessageBox.Show("Please select a raw material.", "No Material Selected", 
                               MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }

            if (!decimal.TryParse(AddProductMaterialQuantityTextBox.Text, out decimal quantity) || quantity <= 0)
            {
                MessageBox.Show("Please enter a valid quantity.", "Invalid Quantity", 
                               MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }

            // Check if material already added
            if (_addProductMaterials.Any(m => m.RawMaterialID == selectedMaterial.RawMaterialID))
            {
                MessageBox.Show("This material is already added. Remove it first to add again.", "Duplicate Material", 
                               MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }

            // Add to list
            var materialItem = new ProductMaterialItem
            {
                RawMaterialID = selectedMaterial.RawMaterialID,
                MaterialName = selectedMaterial.MaterialName,
                QuantityRequired = quantity,
                Unit = selectedMaterial.Unit,
                UnitPrice = selectedMaterial.UnitPrice,
                TotalCost = quantity * selectedMaterial.UnitPrice
            };

            _addProductMaterials.Add(materialItem);

            // Update total cost
            UpdateAddProductMaterialTotalCost();

            // Clear form
            AddProductMaterialComboBox.SelectedIndex = -1;
            AddProductMaterialQuantityTextBox.Text = "";
            AddProductMaterialUnitTextBox.Text = "";
        }

        private void RemoveProductMaterial_Click(object sender, RoutedEventArgs e)
        {
            if (sender is Button button && button.Tag is int materialId)
            {
                var material = _addProductMaterials.FirstOrDefault(m => m.RawMaterialID == materialId);
                if (material != null)
                {
                    _addProductMaterials.Remove(material);
                    UpdateAddProductMaterialTotalCost();
                }
            }
        }

        private void UpdateAddProductMaterialTotalCost()
        {
            decimal totalCost = _addProductMaterials.Sum(m => m.TotalCost);
            AddProductTotalMaterialCostText.Text = $"Rs. {totalCost:N2}";
        }

        private ProductCategory ParseCategory(string category)
        {
            return category?.Replace("-", "") switch
            {
                "TShirts" => ProductCategory.TShirts,
                "Shirts" => ProductCategory.Shirts,
                "Jeans" => ProductCategory.Jeans,
                "Pants" => ProductCategory.Pants,
                "Jackets" => ProductCategory.Jackets,
                "Sweatshirts" => ProductCategory.Sweatshirts,
                _ => ProductCategory.TShirts
            };
        }

        private ProductionStatus ParseProductionStatus(string status)
        {
            return status?.Replace(" ", "") switch
            {
                "Ready" => ProductionStatus.Ready,
                "InProduction" => ProductionStatus.InProduction,
                "QualityCheck" => ProductionStatus.QualityCheck,
                "Planning" => ProductionStatus.Planning,
                "Shipped" => ProductionStatus.Shipped,
                "Discontinued" => ProductionStatus.Discontinued,
                _ => ProductionStatus.Ready
            };
        }
    }

    // Helper class for material items during product creation
    public class ProductMaterialItem
    {
        public int RawMaterialID { get; set; }
        public string MaterialName { get; set; } = "";
        public decimal QuantityRequired { get; set; }
        public string Unit { get; set; } = "";
        public decimal UnitPrice { get; set; }
        public decimal TotalCost { get; set; }
    }
}
