using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Windows;
using System.Windows.Controls;
using FactoryManagmentSystem.Models;
using FactoryManagmentSystem.Services;

namespace FactoryManagmentSystem.Views
{
    public partial class RawMaterialManagementView : UserControl
    {
        // Data collections
        private ObservableCollection<RawMaterialModel> _materials = new();
        private List<RawMaterialModel> _allMaterials = new();
        private ObservableCollection<ProductionCheckItem> _productionCheckItems = new();

        // Services
        private readonly RawMaterialDataService _rawMaterialService;

        // Pagination
        private int _currentPage = 1;
        private const int PageSize = 10;

        private bool _isLoaded = false;

        public RawMaterialManagementView()
        {
            InitializeComponent();
            
            _rawMaterialService = new RawMaterialDataService();

            MaterialsGrid.ItemsSource = _materials;
            ProductionCheckGrid.ItemsSource = _productionCheckItems;

            // Load data asynchronously
            Loaded += async (s, e) =>
            {
                await LoadAllDataAsync();
                _isLoaded = true;
                ApplyFilters();
                LoadComboBoxes();
            };
        }

        // ================================================================================
        // DATA LOADING METHODS
        // ================================================================================

        private async System.Threading.Tasks.Task LoadAllDataAsync()
        {
            try
            {
                // Load all raw materials from database
                var materialsFromDb = await _rawMaterialService.GetAllRawMaterialsAsync();
                
                _allMaterials = materialsFromDb.Select(m => new RawMaterialModel
                {
                    MaterialId = m.RawMaterialID,
                    Name = m.MaterialName,
                    Category = m.Category ?? string.Empty,
                    Unit = m.Unit ?? string.Empty,
                    Quantity = m.Quantity,
                    MinimumStock = m.MinimumStock,
                    UnitPrice = m.UnitPrice,
                    Supplier = m.Supplier ?? string.Empty,
                    Description = m.Description ?? string.Empty
                }).ToList();

                await UpdateStatisticsAsync();
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error loading raw materials: {ex.Message}", "Database Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private async System.Threading.Tasks.Task UpdateStatisticsAsync()
        {
            try
            {
                var stats = await _rawMaterialService.GetRawMaterialStatisticsAsync();

                TotalMaterialsText.Text = stats.TotalMaterials.ToString();
                InStockText.Text = stats.InStockCount.ToString();
                LowStockText.Text = stats.LowStockCount.ToString();
                OutOfStockText.Text = stats.OutOfStockCount.ToString();
                TotalValueText.Text = stats.FormattedTotalStockValue;
            }
            catch (Exception ex)
            {
                // Use fallback local calculation if database fails
                TotalMaterialsText.Text = _allMaterials.Count.ToString();
                InStockText.Text = _allMaterials.Count(m => m.StockStatus == "In Stock").ToString();
                LowStockText.Text = _allMaterials.Count(m => m.StockStatus == "Low Stock").ToString();
                OutOfStockText.Text = _allMaterials.Count(m => m.StockStatus == "Out of Stock").ToString();

                var totalValue = _allMaterials.Sum(m => m.Quantity * m.UnitPrice);
                TotalValueText.Text = $"Rs. {totalValue:N0}";
            }
        }

        private void LoadComboBoxes()
        {
            // Load materials for Update dropdown
            while (UpdateMaterialSelect.Items.Count > 1)
                UpdateMaterialSelect.Items.RemoveAt(1);

            while (DeleteMaterialSelect.Items.Count > 1)
                DeleteMaterialSelect.Items.RemoveAt(1);

            while (ProductionMaterialSelect.Items.Count > 1)
                ProductionMaterialSelect.Items.RemoveAt(1);

            foreach (var material in _allMaterials.OrderBy(m => m.Name))
            {
                var displayText = $"[{material.MaterialId}] {material.Name} ({material.Category})";

                UpdateMaterialSelect.Items.Add(new ComboBoxItem
                {
                    Content = displayText,
                    Tag = material.MaterialId
                });

                DeleteMaterialSelect.Items.Add(new ComboBoxItem
                {
                    Content = displayText,
                    Tag = material.MaterialId
                });

                var productionDisplay = $"{material.Name} - Available: {material.Quantity} {material.Unit}";
                ProductionMaterialSelect.Items.Add(new ComboBoxItem
                {
                    Content = productionDisplay,
                    Tag = material.MaterialId
                });
            }
        }

        private void UpdateStatistics()
        {
            TotalMaterialsText.Text = _allMaterials.Count.ToString();
            InStockText.Text = _allMaterials.Count(m => m.StockStatus == "In Stock").ToString();
            LowStockText.Text = _allMaterials.Count(m => m.StockStatus == "Low Stock").ToString();
            OutOfStockText.Text = _allMaterials.Count(m => m.StockStatus == "Out of Stock").ToString();

            var totalValue = _allMaterials.Sum(m => m.Quantity * m.UnitPrice);
            TotalValueText.Text = $"Rs. {totalValue:N0}";
        }

        private void ApplyFilters()
        {
            if (!_isLoaded) return;

            var filtered = _allMaterials.AsEnumerable();

            // Search filter
            var searchText = SearchBox?.Text?.ToLower() ?? "";
            if (!string.IsNullOrWhiteSpace(searchText))
            {
                filtered = filtered.Where(m =>
                    m.Name.ToLower().Contains(searchText) ||
                    m.Category.ToLower().Contains(searchText) ||
                    m.Supplier.ToLower().Contains(searchText) ||
                    m.MaterialId.ToString().Contains(searchText));
            }

            // Category filter
            var selectedCategory = (CategoryFilter?.SelectedItem as ComboBoxItem)?.Content?.ToString();
            if (!string.IsNullOrEmpty(selectedCategory) && selectedCategory != "All Categories")
            {
                filtered = filtered.Where(m => m.Category == selectedCategory);
            }

            // Stock Status filter
            var selectedStatus = (StockStatusFilter?.SelectedItem as ComboBoxItem)?.Content?.ToString();
            if (!string.IsNullOrEmpty(selectedStatus) && selectedStatus != "All Status")
            {
                filtered = filtered.Where(m => m.StockStatus == selectedStatus);
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

            _materials.Clear();
            foreach (var item in pagedItems)
                _materials.Add(item);

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
            AddMaterialTab.Style = (Style)Resources["TabBtn"];
            UpdateMaterialTab.Style = (Style)Resources["TabBtn"];
            DeleteMaterialTab.Style = (Style)Resources["TabBtn"];
            ProductionCheckTab.Style = (Style)Resources["TabBtn"];

            // Set active tab style
            button.Style = (Style)Resources["ActiveTabBtn"];

            // Hide all content
            ViewAllContent.Visibility = Visibility.Collapsed;
            AddMaterialContent.Visibility = Visibility.Collapsed;
            UpdateMaterialContent.Visibility = Visibility.Collapsed;
            DeleteMaterialContent.Visibility = Visibility.Collapsed;
            ProductionCheckContent.Visibility = Visibility.Collapsed;

            // Show selected content
            switch (tabName)
            {
                case "ViewAll":
                    ViewAllContent.Visibility = Visibility.Visible;
                    break;
                case "Add":
                    AddMaterialContent.Visibility = Visibility.Visible;
                    break;
                case "Update":
                    UpdateMaterialContent.Visibility = Visibility.Visible;
                    break;
                case "Delete":
                    DeleteMaterialContent.Visibility = Visibility.Visible;
                    break;
                case "Production":
                    ProductionCheckContent.Visibility = Visibility.Visible;
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

        private void CategoryFilter_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            if (!_isLoaded) return;
            _currentPage = 1;
            ApplyFilters();
        }

        private void StockStatusFilter_SelectionChanged(object sender, SelectionChangedEventArgs e)
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
            int totalPages = (int)Math.Ceiling((double)_allMaterials.Count / PageSize);
            if (_currentPage < totalPages)
            {
                _currentPage++;
                ApplyFilters();
            }
        }

        private void ViewMaterial_Click(object sender, RoutedEventArgs e)
        {
            var materialId = (int)(sender as Button)?.Tag!;
            var material = _allMaterials.FirstOrDefault(m => m.MaterialId == materialId);

            if (material != null)
            {
                var stockValue = material.Quantity * material.UnitPrice;
                MessageBox.Show(
                    $"🧵 RAW MATERIAL DETAILS\n\n" +
                    $"Material ID: {material.MaterialId}\n" +
                    $"Name: {material.Name}\n" +
                    $"Category: {material.Category}\n" +
                    $"Unit: {material.Unit}\n" +
                    $"───────────────────\n" +
                    $"Current Quantity: {material.Quantity}\n" +
                    $"Minimum Stock: {material.MinimumStock}\n" +
                    $"Unit Price: Rs. {material.UnitPrice:N2}\n" +
                    $"Stock Value: Rs. {stockValue:N2}\n" +
                    $"Status: {material.StockStatus}\n" +
                    $"───────────────────\n" +
                    $"Supplier: {material.Supplier}\n" +
                    $"Description: {material.Description}",
                    "Material Details", MessageBoxButton.OK, MessageBoxImage.Information);
            }
        }

        private async void AddStock_Click(object sender, RoutedEventArgs e)
        {
            var materialId = (int)(sender as Button)?.Tag!;
            var material = _allMaterials.FirstOrDefault(m => m.MaterialId == materialId);

            if (material != null)
            {
                var result = MessageBox.Show(
                    $"Add stock to: {material.Name}\n\n" +
                    $"Current Stock: {material.Quantity} {material.Unit}\n\n" +
                    "Would you like to add 100 units?",
                    "Add Stock", MessageBoxButton.YesNo, MessageBoxImage.Question);

                if (result == MessageBoxResult.Yes)
                {
                    try
                    {
                        await _rawMaterialService.RestockRawMaterialAsync(materialId, 100);

                        MessageBox.Show(
                            $"✅ Stock Added Successfully!\n\n" +
                            $"Material: {material.Name}\n" +
                            $"Added: 100 {material.Unit}\n" +
                            $"New Stock: {material.Quantity + 100} {material.Unit}",
                            "Success", MessageBoxButton.OK, MessageBoxImage.Information);

                        // Reload data
                        await LoadAllDataAsync();
                        ApplyFilters();
                        LoadComboBoxes();
                    }
                    catch (Exception ex)
                    {
                        MessageBox.Show($"Error adding stock: {ex.Message}", "Database Error", MessageBoxButton.OK, MessageBoxImage.Error);
                    }
                }
            }
        }

        private async void QuickDelete_Click(object sender, RoutedEventArgs e)
        {
            var materialId = (int)(sender as Button)?.Tag!;
            var material = _allMaterials.FirstOrDefault(m => m.MaterialId == materialId);

            if (material != null)
            {
                var result = MessageBox.Show(
                    $"Are you sure you want to delete this material?\n\n" +
                    $"Material: {material.Name}\n" +
                    $"Category: {material.Category}\n" +
                    $"Current Stock: {material.Quantity} {material.Unit}\n\n" +
                    "This will soft delete (deactivate) the material.",
                    "Confirm Delete", MessageBoxButton.YesNo, MessageBoxImage.Warning);

                if (result == MessageBoxResult.Yes)
                {
                    try
                    {
                        await _rawMaterialService.DeleteRawMaterialAsync(materialId);

                        MessageBox.Show("Material deleted successfully!", "Deleted", MessageBoxButton.OK, MessageBoxImage.Information);

                        // Reload data
                        await LoadAllDataAsync();
                        ApplyFilters();
                        LoadComboBoxes();
                    }
                    catch (Exception ex)
                    {
                        MessageBox.Show($"Error deleting material: {ex.Message}", "Database Error", MessageBoxButton.OK, MessageBoxImage.Error);
                    }
                }
            }
        }

        #endregion

        #region Add Material Tab

        private void ClearAddForm_Click(object sender, RoutedEventArgs e)
        {
            AddMaterialName.Text = "";
            AddCategory.SelectedIndex = 0;
            AddUnit.SelectedIndex = 0;
            AddQuantity.Text = "";
            AddMinStock.Text = "";
            AddUnitPrice.Text = "";
            AddSupplier.Text = "";
            AddDescription.Text = "";
        }

        private async void SaveMaterial_Click(object sender, RoutedEventArgs e)
        {
            // Validation
            if (string.IsNullOrWhiteSpace(AddMaterialName.Text))
            {
                MessageBox.Show("Please enter material name.", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }

            if (AddCategory.SelectedIndex <= 0)
            {
                MessageBox.Show("Please select a category.", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }

            if (AddUnit.SelectedIndex <= 0)
            {
                MessageBox.Show("Please select a unit.", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }

            if (!decimal.TryParse(AddQuantity.Text, out decimal quantity) || quantity < 0)
            {
                MessageBox.Show("Please enter a valid quantity.", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }

            if (!decimal.TryParse(AddMinStock.Text, out decimal minStock) || minStock < 0)
            {
                MessageBox.Show("Please enter a valid minimum stock level.", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }

            if (!decimal.TryParse(AddUnitPrice.Text, out decimal unitPrice) || unitPrice < 0)
            {
                MessageBox.Show("Please enter a valid unit price.", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }

            try
            {
                var newMaterial = new RawMaterialInfo
                {
                    MaterialName = AddMaterialName.Text.Trim(),
                    Category = (AddCategory.SelectedItem as ComboBoxItem)?.Content?.ToString() ?? "",
                    Unit = (AddUnit.SelectedItem as ComboBoxItem)?.Content?.ToString() ?? "",
                    Quantity = quantity,
                    MinimumStock = minStock,
                    UnitPrice = unitPrice,
                    Supplier = AddSupplier.Text.Trim(),
                    Description = AddDescription.Text.Trim()
                };

                int newId = await _rawMaterialService.CreateRawMaterialAsync(newMaterial);

                MessageBox.Show(
                    $"✅ Material Added Successfully!\n\n" +
                    $"Material ID: {newId}\n" +
                    $"Name: {newMaterial.MaterialName}\n" +
                    $"Category: {newMaterial.Category}\n" +
                    $"Quantity: {newMaterial.Quantity} {newMaterial.Unit}",
                    "Success", MessageBoxButton.OK, MessageBoxImage.Information);

                ClearAddForm_Click(null!, null!);

                // Reload data
                await LoadAllDataAsync();
                ApplyFilters();
                LoadComboBoxes();

                // Switch to View All tab
                ViewAllTab.Style = (Style)Resources["ActiveTabBtn"];
                AddMaterialTab.Style = (Style)Resources["TabBtn"];
                AddMaterialContent.Visibility = Visibility.Collapsed;
                ViewAllContent.Visibility = Visibility.Visible;
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error adding material: {ex.Message}", "Database Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        #endregion

        #region Update Material Tab

        private void UpdateMaterialSelect_Changed(object sender, SelectionChangedEventArgs e)
        {
            if (!_isLoaded) return;
            if (UpdateMaterialSelect.SelectedIndex <= 0)
            {
                UpdateInfoPanel.Visibility = Visibility.Collapsed;
                ClearUpdateForm();
                return;
            }

            var selectedItem = UpdateMaterialSelect.SelectedItem as ComboBoxItem;
            if (selectedItem?.Tag == null) return;

            var materialId = (int)selectedItem.Tag;
            var material = _allMaterials.FirstOrDefault(m => m.MaterialId == materialId);

            if (material != null)
            {
                // Show info panel
                UpdateInfoStock.Text = $"{material.Quantity} {material.Unit}";
                UpdateInfoCategory.Text = material.Category;
                UpdateInfoStatus.Text = material.StockStatus;
                UpdateInfoPanel.Visibility = Visibility.Visible;

                // Fill form
                UpdateMaterialName.Text = material.Name;
                UpdateQuantity.Text = material.Quantity.ToString();
                UpdateMinStock.Text = material.MinimumStock.ToString();
                UpdateUnitPrice.Text = material.UnitPrice.ToString();
                UpdateSupplier.Text = material.Supplier;

                // Set Category
                for (int i = 0; i < UpdateCategory.Items.Count; i++)
                {
                    var item = UpdateCategory.Items[i] as ComboBoxItem;
                    if (item?.Content?.ToString() == material.Category)
                    {
                        UpdateCategory.SelectedIndex = i;
                        break;
                    }
                }

                // Set Unit
                for (int i = 0; i < UpdateUnit.Items.Count; i++)
                {
                    var item = UpdateUnit.Items[i] as ComboBoxItem;
                    if (item?.Content?.ToString() == material.Unit)
                    {
                        UpdateUnit.SelectedIndex = i;
                        break;
                    }
                }
            }
        }

        private void ClearUpdateForm()
        {
            UpdateMaterialName.Text = "";
            UpdateCategory.SelectedIndex = -1;
            UpdateUnit.SelectedIndex = -1;
            UpdateQuantity.Text = "";
            UpdateMinStock.Text = "";
            UpdateUnitPrice.Text = "";
            UpdateSupplier.Text = "";
        }

        private void ResetUpdateForm_Click(object sender, RoutedEventArgs e)
        {
            UpdateMaterialSelect.SelectedIndex = 0;
            UpdateInfoPanel.Visibility = Visibility.Collapsed;
            ClearUpdateForm();
        }

        private async void UpdateMaterialBtn_Click(object sender, RoutedEventArgs e)
        {
            if (UpdateMaterialSelect.SelectedIndex <= 0)
            {
                MessageBox.Show("Please select a material to update.", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }

            var selectedItem = UpdateMaterialSelect.SelectedItem as ComboBoxItem;
            var materialId = (int)(selectedItem?.Tag ?? 0);

            if (!decimal.TryParse(UpdateQuantity.Text, out decimal quantity) || quantity < 0)
            {
                MessageBox.Show("Please enter a valid quantity.", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }

            if (!decimal.TryParse(UpdateMinStock.Text, out decimal minStock) || minStock < 0)
            {
                MessageBox.Show("Please enter a valid minimum stock.", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }

            if (!decimal.TryParse(UpdateUnitPrice.Text, out decimal unitPrice) || unitPrice < 0)
            {
                MessageBox.Show("Please enter a valid unit price.", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }

            try
            {
                var updatedMaterial = new RawMaterialInfo
                {
                    RawMaterialID = materialId,
                    MaterialName = UpdateMaterialName.Text.Trim(),
                    Category = (UpdateCategory.SelectedItem as ComboBoxItem)?.Content?.ToString() ?? "",
                    Unit = (UpdateUnit.SelectedItem as ComboBoxItem)?.Content?.ToString() ?? "",
                    Quantity = quantity,
                    MinimumStock = minStock,
                    UnitPrice = unitPrice,
                    Supplier = UpdateSupplier.Text.Trim(),
                    Description = string.Empty
                };

                await _rawMaterialService.UpdateRawMaterialAsync(updatedMaterial);

                MessageBox.Show(
                    $"✅ Material Updated Successfully!\n\n" +
                    $"Material: {updatedMaterial.MaterialName}\n" +
                    $"New Stock: {updatedMaterial.Quantity} {updatedMaterial.Unit}",
                    "Success", MessageBoxButton.OK, MessageBoxImage.Information);

                // Reload data
                await LoadAllDataAsync();
                ApplyFilters();
                LoadComboBoxes();

                ResetUpdateForm_Click(null!, null!);
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error updating material: {ex.Message}", "Database Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        #endregion

        #region Delete Material Tab

        private void DeleteMaterialSelect_Changed(object sender, SelectionChangedEventArgs e)
        {
            if (!_isLoaded) return;
            if (DeleteMaterialSelect.SelectedIndex <= 0)
            {
                DeleteInfoPanel.Visibility = Visibility.Collapsed;
                return;
            }

            var selectedItem = DeleteMaterialSelect.SelectedItem as ComboBoxItem;
            if (selectedItem?.Tag == null) return;

            var materialId = (int)selectedItem.Tag;
            var material = _allMaterials.FirstOrDefault(m => m.MaterialId == materialId);

            if (material != null)
            {
                DeleteInfoName.Text = material.Name;
                DeleteInfoCategory.Text = material.Category;
                DeleteInfoStock.Text = $"{material.Quantity} {material.Unit}";
                DeleteInfoValue.Text = $"Rs. {(material.Quantity * material.UnitPrice):N2}";
                DeleteInfoPanel.Visibility = Visibility.Visible;
            }
        }

        private async void DeleteMaterialBtn_Click(object sender, RoutedEventArgs e)
        {
            if (DeleteMaterialSelect.SelectedIndex <= 0)
            {
                MessageBox.Show("Please select a material to delete.", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }

            var selectedItem = DeleteMaterialSelect.SelectedItem as ComboBoxItem;
            var materialId = (int)(selectedItem?.Tag ?? 0);
            var material = _allMaterials.FirstOrDefault(m => m.MaterialId == materialId);

            if (material != null)
            {
                var result = MessageBox.Show(
                    $"⚠️ CONFIRM DELETE\n\n" +
                    $"Are you sure you want to delete this material?\n\n" +
                    $"Material: {material.Name}\n" +
                    $"Category: {material.Category}\n" +
                    $"Current Stock: {material.Quantity} {material.Unit}\n" +
                    $"Stock Value: Rs. {(material.Quantity * material.UnitPrice):N2}\n\n" +
                    "⚠️ This will soft delete (deactivate) the material!",
                    "Confirm Delete", MessageBoxButton.YesNo, MessageBoxImage.Warning);

                if (result == MessageBoxResult.Yes)
                {
                    try
                    {
                        await _rawMaterialService.DeleteRawMaterialAsync(materialId);

                        MessageBox.Show("Material deleted successfully!", "Deleted", MessageBoxButton.OK, MessageBoxImage.Information);

                        // Reload data
                        await LoadAllDataAsync();
                        ApplyFilters();
                        LoadComboBoxes();

                        DeleteMaterialSelect.SelectedIndex = 0;
                        DeleteInfoPanel.Visibility = Visibility.Collapsed;
                    }
                    catch (Exception ex)
                    {
                        MessageBox.Show($"Error deleting material: {ex.Message}", "Database Error", MessageBoxButton.OK, MessageBoxImage.Error);
                    }
                }
            }
        }

        #endregion

        #region Production Check Tab

        private void AddToProductionCheck_Click(object sender, RoutedEventArgs e)
        {
            if (ProductionMaterialSelect.SelectedIndex <= 0)
            {
                MessageBox.Show("Please select a material.", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }

            if (!decimal.TryParse(ProductionQuantityRequired.Text, out decimal requiredQty) || requiredQty <= 0)
            {
                MessageBox.Show("Please enter a valid quantity.", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }

            var selectedItem = ProductionMaterialSelect.SelectedItem as ComboBoxItem;
            var materialId = (int)(selectedItem?.Tag ?? 0);
            var material = _allMaterials.FirstOrDefault(m => m.MaterialId == materialId);

            if (material != null)
            {
                // Check if already added
                if (_productionCheckItems.Any(p => p.MaterialId == materialId))
                {
                    MessageBox.Show("This material is already in the check list.", "Info", MessageBoxButton.OK, MessageBoxImage.Information);
                    return;
                }

                var checkItem = new ProductionCheckItem
                {
                    MaterialId = materialId,
                    MaterialName = material.Name,
                    RequiredQuantity = requiredQty,
                    AvailableQuantity = material.Quantity,
                    Unit = material.Unit,
                    IsAvailable = material.Quantity >= requiredQty
                };

                _productionCheckItems.Add(checkItem);
                ProductionMaterialSelect.SelectedIndex = 0;
                ProductionQuantityRequired.Text = "";

                // Hide result panel when adding new items
                ProductionResultPanel.Visibility = Visibility.Collapsed;
            }
        }

        private void RemoveFromProductionCheck_Click(object sender, RoutedEventArgs e)
        {
            var materialId = (int)(sender as Button)?.Tag!;
            var item = _productionCheckItems.FirstOrDefault(p => p.MaterialId == materialId);
            if (item != null)
            {
                _productionCheckItems.Remove(item);
            }
        }

        private void ClearProductionCheck_Click(object sender, RoutedEventArgs e)
        {
            _productionCheckItems.Clear();
            ProductionResultPanel.Visibility = Visibility.Collapsed;
        }

        private void CheckProductionAvailability_Click(object sender, RoutedEventArgs e)
        {
            if (_productionCheckItems.Count == 0)
            {
                MessageBox.Show("Please add at least one material to check.", "Info", MessageBoxButton.OK, MessageBoxImage.Information);
                return;
            }

            // Re-check availability with current stock
            foreach (var item in _productionCheckItems)
            {
                var material = _allMaterials.FirstOrDefault(m => m.MaterialId == item.MaterialId);
                if (material != null)
                {
                    item.AvailableQuantity = material.Quantity;
                    item.IsAvailable = material.Quantity >= item.RequiredQuantity;
                }
            }

            // Refresh the grid
            ProductionCheckGrid.Items.Refresh();

            // Show result
            bool allAvailable = _productionCheckItems.All(p => p.IsAvailable);
            var insufficientItems = _productionCheckItems.Where(p => !p.IsAvailable).ToList();

            ProductionResultPanel.Visibility = Visibility.Visible;

            if (allAvailable)
            {
                ProductionResultPanel.Background = new System.Windows.Media.SolidColorBrush(
                    (System.Windows.Media.Color)System.Windows.Media.ColorConverter.ConvertFromString("#D1FAE5"));
                ProductionResultTitle.Text = "✅ All Materials Available!";
                ProductionResultTitle.Foreground = new System.Windows.Media.SolidColorBrush(
                    (System.Windows.Media.Color)System.Windows.Media.ColorConverter.ConvertFromString("#059669"));
                ProductionResultMessage.Text = "All required raw materials are in stock. You can proceed to create the production order.";
                ProductionResultMessage.Foreground = new System.Windows.Media.SolidColorBrush(
                    (System.Windows.Media.Color)System.Windows.Media.ColorConverter.ConvertFromString("#065F46"));
                CreateProductionOrderBtn.Visibility = Visibility.Visible;
            }
            else
            {
                ProductionResultPanel.Background = new System.Windows.Media.SolidColorBrush(
                    (System.Windows.Media.Color)System.Windows.Media.ColorConverter.ConvertFromString("#FEE2E2"));
                ProductionResultTitle.Text = "❌ Insufficient Stock";
                ProductionResultTitle.Foreground = new System.Windows.Media.SolidColorBrush(
                    (System.Windows.Media.Color)System.Windows.Media.ColorConverter.ConvertFromString("#DC2626"));

                var insufficientList = string.Join("\n", insufficientItems.Select(i =>
                    $"• {i.MaterialName}: Need {i.RequiredQuantity}, Available {i.AvailableQuantity} {i.Unit} (Short by {i.RequiredQuantity - i.AvailableQuantity})"));

                ProductionResultMessage.Text = $"The following materials have insufficient stock:\n\n{insufficientList}\n\nPlease restock these materials before creating a production order.";
                ProductionResultMessage.Foreground = new System.Windows.Media.SolidColorBrush(
                    (System.Windows.Media.Color)System.Windows.Media.ColorConverter.ConvertFromString("#991B1B"));
                CreateProductionOrderBtn.Visibility = Visibility.Collapsed;
            }
        }

        private void CreateProductionOrder_Click(object sender, RoutedEventArgs e)
        {
            // Deduct stock for production
            var result = MessageBox.Show(
                "Are you sure you want to create a production order?\n\n" +
                "This will deduct the required quantities from raw material stock.",
                "Confirm Production Order", MessageBoxButton.YesNo, MessageBoxImage.Question);

            if (result == MessageBoxResult.Yes)
            {
                foreach (var item in _productionCheckItems)
                {
                    var material = _allMaterials.FirstOrDefault(m => m.MaterialId == item.MaterialId);
                    if (material != null)
                    {
                        material.Quantity -= item.RequiredQuantity;
                    }
                }

                ApplyFilters();
                UpdateStatistics();
                LoadComboBoxes();

                MessageBox.Show(
                    "🏭 Production Order Created Successfully!\n\n" +
                    "Raw material stock has been updated.\n" +
                    "The production order has been queued for processing.",
                    "Success", MessageBoxButton.OK, MessageBoxImage.Information);

                // Clear the production check
                _productionCheckItems.Clear();
                ProductionResultPanel.Visibility = Visibility.Collapsed;
            }
        }

        #endregion

        #region Common Actions

        private async void RefreshBtn_Click(object sender, RoutedEventArgs e)
        {
            await LoadAllDataAsync();
            ApplyFilters();
            LoadComboBoxes();

            MessageBox.Show("Data refreshed successfully!", "Refresh", MessageBoxButton.OK, MessageBoxImage.Information);
        }

        private void LowStockAlertBtn_Click(object sender, RoutedEventArgs e)
        {
            var lowStockItems = _allMaterials.Where(m => m.StockStatus == "Low Stock" || m.StockStatus == "Out of Stock").ToList();

            if (lowStockItems.Count == 0)
            {
                MessageBox.Show("✅ All materials are well-stocked!", "Stock Status", MessageBoxButton.OK, MessageBoxImage.Information);
                return;
            }

            var alertMessage = string.Join("\n", lowStockItems.Select(m =>
                $"• {m.Name} ({m.Category}): {m.Quantity}/{m.MinimumStock} {m.Unit} - {m.StockStatus}"));

            MessageBox.Show(
                $"⚠️ LOW STOCK ALERTS\n\n{lowStockItems.Count} materials need attention:\n\n{alertMessage}",
                "Low Stock Alerts", MessageBoxButton.OK, MessageBoxImage.Warning);
        }

        #endregion

        #region Static Methods for External Use

        /// <summary>
        /// Check if a specific material has sufficient stock for production
        /// </summary>
        public static bool CheckMaterialAvailability(int materialId, decimal requiredQuantity, List<RawMaterialModel> materials)
        {
            var material = materials.FirstOrDefault(m => m.MaterialId == materialId);
            return material != null && material.Quantity >= requiredQuantity;
        }

        /// <summary>
        /// Deduct stock when production order is confirmed
        /// </summary>
        public static bool DeductStock(int materialId, decimal quantity, List<RawMaterialModel> materials)
        {
            var material = materials.FirstOrDefault(m => m.MaterialId == materialId);
            if (material != null && material.Quantity >= quantity)
            {
                material.Quantity -= quantity;
                return true;
            }
            return false;
        }

        #endregion
    }

    /// <summary>
    /// Raw Material Model
    /// Fields: MaterialID, Name, Category, Unit, Quantity, MinimumStock, UnitPrice, Supplier, Description
    /// Status: In Stock, Low Stock, Out of Stock (calculated based on Quantity vs MinimumStock)
    /// </summary>
    public class RawMaterialModel : INotifyPropertyChanged
    {
        private int _materialId;
        private string _name = string.Empty;
        private string _category = string.Empty;
        private string _unit = string.Empty;
        private decimal _quantity;
        private decimal _minimumStock;
        private decimal _unitPrice;
        private string _supplier = string.Empty;
        private string _description = string.Empty;

        public int MaterialId
        {
            get => _materialId;
            set { _materialId = value; OnPropertyChanged(); }
        }

        public string Name
        {
            get => _name;
            set { _name = value; OnPropertyChanged(); }
        }

        public string Category
        {
            get => _category;
            set { _category = value; OnPropertyChanged(); }
        }

        public string Unit
        {
            get => _unit;
            set { _unit = value; OnPropertyChanged(); }
        }

        public decimal Quantity
        {
            get => _quantity;
            set { _quantity = value; OnPropertyChanged(); OnPropertyChanged(nameof(StockStatus)); }
        }

        public decimal MinimumStock
        {
            get => _minimumStock;
            set { _minimumStock = value; OnPropertyChanged(); OnPropertyChanged(nameof(StockStatus)); }
        }

        public decimal UnitPrice
        {
            get => _unitPrice;
            set { _unitPrice = value; OnPropertyChanged(); }
        }

        public string Supplier
        {
            get => _supplier;
            set { _supplier = value; OnPropertyChanged(); }
        }

        public string Description
        {
            get => _description;
            set { _description = value; OnPropertyChanged(); }
        }

        /// <summary>
        /// Calculated Stock Status based on Quantity vs MinimumStock
        /// </summary>
        public string StockStatus
        {
            get
            {
                if (_quantity <= 0) return "Out of Stock";
                if (_quantity < _minimumStock) return "Low Stock";
                return "In Stock";
            }
        }

        public event PropertyChangedEventHandler? PropertyChanged;

        protected virtual void OnPropertyChanged([CallerMemberName] string? propertyName = null)
        {
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
        }
    }

    /// <summary>
    /// Production Check Item - Used to verify material availability before production
    /// </summary>
    public class ProductionCheckItem : INotifyPropertyChanged
    {
        private int _materialId;
        private string _materialName = string.Empty;
        private decimal _requiredQuantity;
        private decimal _availableQuantity;
        private string _unit = string.Empty;
        private bool _isAvailable;

        public int MaterialId
        {
            get => _materialId;
            set { _materialId = value; OnPropertyChanged(); }
        }

        public string MaterialName
        {
            get => _materialName;
            set { _materialName = value; OnPropertyChanged(); }
        }

        public decimal RequiredQuantity
        {
            get => _requiredQuantity;
            set { _requiredQuantity = value; OnPropertyChanged(); }
        }

        public decimal AvailableQuantity
        {
            get => _availableQuantity;
            set { _availableQuantity = value; OnPropertyChanged(); }
        }

        public string Unit
        {
            get => _unit;
            set { _unit = value; OnPropertyChanged(); }
        }

        public bool IsAvailable
        {
            get => _isAvailable;
            set { _isAvailable = value; OnPropertyChanged(); }
        }

        public event PropertyChangedEventHandler? PropertyChanged;

        protected virtual void OnPropertyChanged([CallerMemberName] string? propertyName = null)
        {
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
        }
    }
}
