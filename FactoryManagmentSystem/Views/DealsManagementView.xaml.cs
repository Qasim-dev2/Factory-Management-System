using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Globalization;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using FactoryManagmentSystem.Models;
using FactoryManagmentSystem.Services;

namespace FactoryManagmentSystem.Views
{
    /// <summary>
    /// Converter to determine if a deal can be edited/deleted based on its status
    /// Deals that are Approved, In Progress, Completed, or Delivered cannot be edited/deleted
    /// </summary>
    public class DealStatusToEditableConverter : IMultiValueConverter
    {
        public object Convert(object[] values, Type targetType, object parameter, CultureInfo culture)
        {
            if (values.Length > 0 && values[0] is string status)
            {
                // Allow edit/delete only for Pending and Cancelled deals
                return status == "Pending" || status == "Cancelled" || status == "Draft";
            }
            return true; // Default to enabled if status is unknown
        }

        public object[] ConvertBack(object value, Type[] targetTypes, object parameter, CultureInfo culture)
        {
            throw new NotImplementedException();
        }
    }

    public partial class DealsManagementView : UserControl
    {
        // Data service
        private readonly DealDataService _dealDataService;

        // Data collections
        private ObservableCollection<Deal> _deals = new();
        private List<Deal> _allDeals = new();
        
        // Deal Items for new deal
        private ObservableCollection<DealItem> _currentDealItems = new();
        
        // Deal Items for update deal
        private ObservableCollection<DealItem> _updateDealItems = new();

        // Pagination
        private int _currentPage = 1;
        private const int PageSize = 10;

        private bool _isLoaded = false;

        public DealsManagementView()
        {
            InitializeComponent();
            
            _dealDataService = new DealDataService();
            
            LoadDataAsync();
            LoadEmployees();
            LoadProducts();

            DealsGrid.ItemsSource = _deals;
            DealItemsGrid.ItemsSource = _currentDealItems;
            UpdateDealItemsGrid.ItemsSource = _updateDealItems;

            _isLoaded = true;
        }

        private async void LoadDataAsync()
        {
            try
            {
                // Load deals from database
                _allDeals = await _dealDataService.GetAllDealsAsync();
                
                // Update statistics
                await UpdateStatisticsAsync();
                
                // Apply filters and load UI
                ApplyFilters();
                LoadDealComboBoxes();
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error loading deals: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private async void LoadEmployees()
        {
            try
            {
                var salespeople = await _dealDataService.GetSalespersonsAsync();
                
                // Remove all items except the first two (placeholder and "Created by Owner")
                while (AddCreatedBy.Items.Count > 2)
                {
                    AddCreatedBy.Items.RemoveAt(2);
                }

                foreach (var emp in salespeople)
                {
                    AddCreatedBy.Items.Add(new ComboBoxItem { Content = emp.FullName, Tag = emp.EmployeeID });
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error loading employees: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private async void LoadProducts()
        {
            try
            {
                var products = await _dealDataService.GetActiveProductsAsync();
                
                AddDealItemProduct.Items.Clear();
                UpdateDealItemProduct.Items.Clear();

                foreach (var product in products)
                {
                    var item = new ComboBoxItem 
                    { 
                        Content = product.ProductName,
                        Tag = new { product.ProductID, product.ProductName, product.SKU, product.SalePrice }
                    };
                    
                    AddDealItemProduct.Items.Add(item);
                    UpdateDealItemProduct.Items.Add(new ComboBoxItem 
                    { 
                        Content = product.ProductName,
                        Tag = new { product.ProductID, product.ProductName, product.SKU, product.SalePrice }
                    });
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error loading products: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void LoadDealComboBoxes()
        {
            // Clear existing items except the first placeholder
            while (UpdateDealSelect.Items.Count > 1)
                UpdateDealSelect.Items.RemoveAt(1);
            while (DeleteDealSelect.Items.Count > 1)
                DeleteDealSelect.Items.RemoveAt(1);

            foreach (var deal in _allDeals)
            {
                UpdateDealSelect.Items.Add(new ComboBoxItem
                {
                    Content = $"[{deal.DealId}] {deal.DealTitle}",
                    Tag = deal.DealId
                });
                DeleteDealSelect.Items.Add(new ComboBoxItem
                {
                    Content = $"[{deal.DealId}] {deal.DealTitle}",
                    Tag = deal.DealId
                });
            }
        }

        private async System.Threading.Tasks.Task UpdateStatisticsAsync()
        {
            try
            {
                var stats = await _dealDataService.GetDealStatisticsAsync();
                TotalDealsText.Text = stats.TotalDeals.ToString();
                PendingDealsText.Text = stats.PendingDeals.ToString();
                InProgressDealsText.Text = stats.InProgressDeals.ToString();
                CompletedDealsText.Text = stats.CompletedDeals.ToString();
                CancelledDealsText.Text = stats.CancelledDeals.ToString();
                
                // Add Delivered count
                var deliveredCount = _allDeals.Count(d => d.Status == "Delivered");
                DeliveredDealsText.Text = deliveredCount.ToString();
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error loading statistics: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void ApplyFilters()
        {
            if (!_isLoaded) return;

            var filtered = _allDeals.AsEnumerable();

            // Search filter
            var searchText = SearchBox?.Text?.ToLower() ?? "";
            if (!string.IsNullOrWhiteSpace(searchText))
            {
                filtered = filtered.Where(d =>
                    (d.DealTitle?.ToLower().Contains(searchText) ?? false) ||
                    (d.ClientName?.ToLower().Contains(searchText) ?? false) ||
                    d.DealId.ToString().Contains(searchText));
            }

            // Status filter
            var selectedStatus = (StatusFilter?.SelectedItem as ComboBoxItem)?.Content?.ToString();
            if (!string.IsNullOrEmpty(selectedStatus) && selectedStatus != "All Status")
            {
                filtered = filtered.Where(d => d.Status == selectedStatus);
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

            _deals.Clear();
            foreach (var item in pagedItems)
                _deals.Add(item);

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
            AddDealTab.Style = (Style)Resources["TabBtn"];
            UpdateDealTab.Style = (Style)Resources["TabBtn"];
            DeleteDealTab.Style = (Style)Resources["TabBtn"];

            // Set active tab style
            button.Style = (Style)Resources["ActiveTabBtn"];

            // Hide all content
            ViewAllContent.Visibility = Visibility.Collapsed;
            AddDealContent.Visibility = Visibility.Collapsed;
            UpdateDealContent.Visibility = Visibility.Collapsed;
            DeleteDealContent.Visibility = Visibility.Collapsed;

            // Show selected content
            switch (tabName)
            {
                case "ViewAll":
                    ViewAllContent.Visibility = Visibility.Visible;
                    break;
                case "Add":
                    AddDealContent.Visibility = Visibility.Visible;
                    break;
                case "Update":
                    UpdateDealContent.Visibility = Visibility.Visible;
                    break;
                case "Delete":
                    DeleteDealContent.Visibility = Visibility.Visible;
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

        private void SearchBox_GotFocus(object sender, RoutedEventArgs e)
        {
            if (SearchPlaceholder != null)
                SearchPlaceholder.Visibility = Visibility.Collapsed;
        }

        private void SearchBox_LostFocus(object sender, RoutedEventArgs e)
        {
            if (SearchPlaceholder != null && string.IsNullOrWhiteSpace(SearchBox.Text))
                SearchPlaceholder.Visibility = Visibility.Visible;
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
            int totalPages = (int)Math.Ceiling((double)_allDeals.Count / PageSize);
            if (_currentPage < totalPages)
            {
                _currentPage++;
                ApplyFilters();
            }
        }

        private void ViewDeal_Click(object sender, RoutedEventArgs e)
        {
            var dealId = (int)(sender as Button)?.Tag!;
            var deal = _allDeals.FirstOrDefault(d => d.DealId == dealId);

            if (deal != null)
            {
                MessageBox.Show(
                    $"📋 DEAL DETAILS\n\n" +
                    $"Deal ID: {deal.DealId}\n" +
                    $"Deal Title: {deal.DealTitle}\n" +
                    $"Client: {deal.ClientName}\n" +
                    $"Created By: {deal.CreatedByName ?? "Owner"}\n" +
                    $"Start Date: {deal.StartDate?.ToString("dd MMM yyyy") ?? "N/A"}\n" +
                    $"End Date: {deal.EndDate?.ToString("dd MMM yyyy") ?? "N/A"}\n" +
                    $"Status: {deal.Status}\n\n" +
                    $"Description:\n{deal.Description}",
                    "Deal Details", MessageBoxButton.OK, MessageBoxImage.Information);
            }
        }

        private void EditDeal_Click(object sender, RoutedEventArgs e)
        {
            var dealId = (int)(sender as Button)?.Tag!;

            // Switch to Update tab and select the deal
            UpdateDealTab.Style = (Style)Resources["ActiveTabBtn"];
            ViewAllTab.Style = (Style)Resources["TabBtn"];

            ViewAllContent.Visibility = Visibility.Collapsed;
            UpdateDealContent.Visibility = Visibility.Visible;

            // Find and select the deal in combo box
            for (int i = 1; i < UpdateDealSelect.Items.Count; i++)
            {
                var item = UpdateDealSelect.Items[i] as ComboBoxItem;
                if (item?.Tag != null && (int)item.Tag == dealId)
                {
                    UpdateDealSelect.SelectedIndex = i;
                    break;
                }
            }
        }

        private async void DeleteDeal_Click(object sender, RoutedEventArgs e)
        {
            var dealId = (int)(sender as Button)?.Tag!;
            var deal = _allDeals.FirstOrDefault(d => d.DealId == dealId);

            if (deal != null)
            {
                var result = MessageBox.Show(
                    $"Are you sure you want to delete this deal?\n\n" +
                    $"Deal: {deal.DealTitle}\n" +
                    $"Client: {deal.ClientName}\n\n" +
                    "This action cannot be undone.",
                    "Confirm Delete", MessageBoxButton.YesNo, MessageBoxImage.Warning);

                if (result == MessageBoxResult.Yes)
                {
                    try
                    {
                        await _dealDataService.DeleteDealAsync(dealId);
                        _allDeals.Remove(deal);
                        ApplyFilters();
                        await UpdateStatisticsAsync();
                        LoadDealComboBoxes();

                        MessageBox.Show("Deal deleted successfully!", "Deleted", MessageBoxButton.OK, MessageBoxImage.Information);
                    }
                    catch (Exception ex)
                    {
                        MessageBox.Show($"Error deleting deal: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
                    }
                }
            }
        }

        #endregion

        #region Add Deal Tab

        private void ClearAddForm_Click(object sender, RoutedEventArgs e)
        {
            AddDealName.Text = "";
            AddRequestedBy.Text = "";
            AddDealType.SelectedIndex = 0;
            AddContactPerson.Text = "";
            AddEmail.Text = "";
            AddPhone.Text = "";
            AddDeliveryAddress.Text = "";
            AddCity.Text = "";
            AddProvince.SelectedIndex = 0;
            AddCreatedBy.SelectedIndex = 0;
            AddDeadline.SelectedDate = null;
            AddDescription.Text = "";
            
            // Clear deal items
            _currentDealItems.Clear();
            AddDealItemProduct.SelectedIndex = -1;
            AddDealItemQuantity.Text = "";
            AddDealItemPrice.Text = "";
        }

        private async void SaveDeal_Click(object sender, RoutedEventArgs e)
        {
            // Validation
            if (string.IsNullOrWhiteSpace(AddDealName.Text))
            {
                MessageBox.Show("Please enter a deal name.", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                AddDealName.Focus();
                return;
            }

            if (string.IsNullOrWhiteSpace(AddRequestedBy.Text))
            {
                MessageBox.Show("Please enter who requested this deal.", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                AddRequestedBy.Focus();
                return;
            }

            // Check if a valid employee or "Created by Owner" is selected (not the placeholder at index 0)
            if (AddCreatedBy.SelectedIndex <= 0 || AddCreatedBy.SelectedItem == null)
            {
                MessageBox.Show("Please select the employee who created this deal.", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }
            
            var selectedEmployee = AddCreatedBy.SelectedItem as ComboBoxItem;
            if (selectedEmployee?.Content?.ToString() == "-- Select Employee --")
            {
                MessageBox.Show("Please select the employee who created this deal.", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }

            if (AddDeadline.SelectedDate == null)
            {
                MessageBox.Show("Please select a deadline.", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }

            try
            {
                // selectedEmployee already declared above in validation
                // Status is always Pending for new deals (workflow-managed)

                var dealTypeItem = AddDealType.SelectedItem as ComboBoxItem;
                var provinceItem = AddProvince.SelectedItem as ComboBoxItem;

                var newDeal = new Deal
                {
                    DealTitle = AddDealName.Text.Trim(),
                    ClientName = AddRequestedBy.Text.Trim(),
                    DealType = dealTypeItem?.Content?.ToString() == "-- Select Type --" ? null : dealTypeItem?.Content?.ToString(),
                    ContactPerson = string.IsNullOrWhiteSpace(AddContactPerson.Text) ? null : AddContactPerson.Text.Trim(),
                    Email = string.IsNullOrWhiteSpace(AddEmail.Text) ? null : AddEmail.Text.Trim(),
                    Phone = string.IsNullOrWhiteSpace(AddPhone.Text) ? null : AddPhone.Text.Trim(),
                    DeliveryAddress = string.IsNullOrWhiteSpace(AddDeliveryAddress.Text) ? null : AddDeliveryAddress.Text.Trim(),
                    City = string.IsNullOrWhiteSpace(AddCity.Text) ? null : AddCity.Text.Trim(),
                    Province = provinceItem?.Content?.ToString() == "-- Select Province --" ? null : provinceItem?.Content?.ToString(),
                    CreatedBy = selectedEmployee?.Content?.ToString() == "Created by Owner" ? null : (int?)(selectedEmployee?.Tag ?? 0),
                    EndDate = AddDeadline.SelectedDate.Value,
                    Status = "Pending",
                    Description = AddDescription.Text.Trim(),
                    StartDate = DateTime.Now
                };

                int newDealId = await _dealDataService.AddDealAsync(newDeal);
                newDeal.DealId = newDealId;
                newDeal.CreatedByName = selectedEmployee?.Content?.ToString();

                // Save deal items if any were added
                foreach (var item in _currentDealItems)
                {
                    item.DealId = newDealId;
                    await _dealDataService.AddDealItemAsync(item);
                }

                _allDeals.Add(newDeal);
                ApplyFilters();
                await UpdateStatisticsAsync();
                LoadDealComboBoxes();

                MessageBox.Show(
                    $"✅ Deal Added Successfully!\n\n" +
                    $"Deal ID: {newDeal.DealId}\n" +
                    $"Deal Name: {newDeal.DealTitle}\n" +
                    $"Items Added: {_currentDealItems.Count}\n" +
                    $"Deadline: {newDeal.EndDate?.ToString("dd MMM yyyy")}",
                    "Success", MessageBoxButton.OK, MessageBoxImage.Information);

                ClearAddForm_Click(null!, null!);

                // Switch to View All tab
                ViewAllTab.Style = (Style)Resources["ActiveTabBtn"];
                AddDealTab.Style = (Style)Resources["TabBtn"];
                AddDealContent.Visibility = Visibility.Collapsed;
                ViewAllContent.Visibility = Visibility.Visible;
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error adding deal: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        #endregion

        #region Update Deal Tab

        private async void UpdateDealSelect_Changed(object sender, SelectionChangedEventArgs e)
        {
            if (!_isLoaded) return;
            if (UpdateDealSelect.SelectedIndex <= 0)
            {
                UpdateDealName.Text = "";
                UpdateRequestedBy.Text = "";
                UpdateDealType.SelectedIndex = 0;
                UpdateContactPerson.Text = "";
                UpdateEmail.Text = "";
                UpdatePhone.Text = "";
                UpdateDeliveryAddress.Text = "";
                UpdateCity.Text = "";
                UpdateProvince.SelectedIndex = 0;
                UpdateDeadline.SelectedDate = null;
                UpdateStatus.SelectedIndex = -1;
                _updateDealItems.Clear();
                return;
            }

            var selectedItem = UpdateDealSelect.SelectedItem as ComboBoxItem;
            if (selectedItem?.Tag == null) return;

            var dealId = (int)selectedItem.Tag;
            var deal = _allDeals.FirstOrDefault(d => d.DealId == dealId);

            if (deal != null)
            {
                UpdateDealName.Text = deal.DealTitle;
                UpdateRequestedBy.Text = deal.ClientName;
                
                // Set DealType
                for (int i = 0; i < UpdateDealType.Items.Count; i++)
                {
                    var item = UpdateDealType.Items[i] as ComboBoxItem;
                    if (item?.Content?.ToString() == deal.DealType)
                    {
                        UpdateDealType.SelectedIndex = i;
                        break;
                    }
                }
                
                UpdateContactPerson.Text = deal.ContactPerson ?? "";
                UpdateEmail.Text = deal.Email ?? "";
                UpdatePhone.Text = deal.Phone ?? "";
                UpdateDeliveryAddress.Text = deal.DeliveryAddress ?? "";
                UpdateCity.Text = deal.City ?? "";
                
                // Set Province
                for (int i = 0; i < UpdateProvince.Items.Count; i++)
                {
                    var item = UpdateProvince.Items[i] as ComboBoxItem;
                    if (item?.Content?.ToString() == deal.Province)
                    {
                        UpdateProvince.SelectedIndex = i;
                        break;
                    }
                }
                
                UpdateDeadline.SelectedDate = deal.EndDate;

                // Set status
                for (int i = 0; i < UpdateStatus.Items.Count; i++)
                {
                    var item = UpdateStatus.Items[i] as ComboBoxItem;
                    if (item?.Content?.ToString() == deal.Status)
                    {
                        UpdateStatus.SelectedIndex = i;
                        break;
                    }
                }

                // Load deal items
                try
                {
                    var items = await _dealDataService.GetDealItemsAsync(dealId);
                    _updateDealItems.Clear();
                    foreach (var item in items)
                    {
                        _updateDealItems.Add(item);
                    }
                }
                catch (Exception ex)
                {
                    MessageBox.Show($"Error loading deal items: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
                }
            }
        }

        private void ResetUpdateForm_Click(object sender, RoutedEventArgs e)
        {
            UpdateDealSelect.SelectedIndex = 0;
            UpdateDealName.Text = "";
            UpdateRequestedBy.Text = "";
            UpdateDealType.SelectedIndex = 0;
            UpdateContactPerson.Text = "";
            UpdateEmail.Text = "";
            UpdatePhone.Text = "";
            UpdateDeliveryAddress.Text = "";
            UpdateCity.Text = "";
            UpdateProvince.SelectedIndex = 0;
            UpdateDeadline.SelectedDate = null;
            UpdateStatus.SelectedIndex = -1;
            _updateDealItems.Clear();
            UpdateDealItemProduct.SelectedIndex = -1;
            UpdateDealItemQuantity.Text = "";
            UpdateDealItemPrice.Text = "";
        }

        private async void UpdateDealBtn_Click(object sender, RoutedEventArgs e)
        {
            if (UpdateDealSelect.SelectedIndex <= 0)
            {
                MessageBox.Show("Please select a deal to update.", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }

            if (string.IsNullOrWhiteSpace(UpdateDealName.Text))
            {
                MessageBox.Show("Please enter a deal name.", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }

            if (UpdateDeadline.SelectedDate == null)
            {
                MessageBox.Show("Please select a deadline.", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }

            try
            {
                var selectedItem = UpdateDealSelect.SelectedItem as ComboBoxItem;
                var dealId = (int)(selectedItem?.Tag ?? 0);
                var deal = _allDeals.FirstOrDefault(d => d.DealId == dealId);

                if (deal != null)
                {
                    deal.DealTitle = UpdateDealName.Text.Trim();
                    deal.ClientName = UpdateRequestedBy.Text.Trim();
                    deal.DealType = (UpdateDealType.SelectedItem as ComboBoxItem)?.Content?.ToString() ?? "";
                    deal.ContactPerson = UpdateContactPerson.Text.Trim();
                    deal.Email = UpdateEmail.Text.Trim();
                    deal.Phone = UpdatePhone.Text.Trim();
                    deal.DeliveryAddress = UpdateDeliveryAddress.Text.Trim();
                    deal.City = UpdateCity.Text.Trim();
                    deal.Province = (UpdateProvince.SelectedItem as ComboBoxItem)?.Content?.ToString() ?? "";
                    deal.EndDate = UpdateDeadline.SelectedDate.Value;
                    deal.Status = (UpdateStatus.SelectedItem as ComboBoxItem)?.Content?.ToString() ?? deal.Status;

                    await _dealDataService.UpdateDealAsync(deal);

                    // Get existing items and delete them
                    var existingItems = await _dealDataService.GetDealItemsAsync(dealId);
                    foreach (var existingItem in existingItems)
                    {
                        await _dealDataService.DeleteDealItemAsync(existingItem.DealItemId);
                    }

                    // Add new items
                    foreach (var item in _updateDealItems)
                    {
                        item.DealId = dealId;
                        await _dealDataService.AddDealItemAsync(item);
                    }

                    // Reload all deals from database to get fresh data
                    _allDeals = await _dealDataService.GetAllDealsAsync();
                    ApplyFilters();
                    await UpdateStatisticsAsync();
                    LoadDealComboBoxes();

                    MessageBox.Show(
                        $"✅ Deal Updated Successfully!\n\n" +
                        $"Deal ID: {deal.DealId}\n" +
                        $"Deal Name: {deal.DealTitle}\n" +
                        $"Items: {_updateDealItems.Count}",
                        "Success", MessageBoxButton.OK, MessageBoxImage.Information);

                    ResetUpdateForm_Click(null!, null!);
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error updating deal: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        #endregion

        #region Delete Deal Tab

        private void DeleteDealSelect_Changed(object sender, SelectionChangedEventArgs e)
        {
            if (!_isLoaded) return;
            if (DeleteDealSelect.SelectedIndex <= 0)
            {
                DeletePreviewPanel.Visibility = Visibility.Collapsed;
                return;
            }

            var selectedItem = DeleteDealSelect.SelectedItem as ComboBoxItem;
            if (selectedItem?.Tag == null) return;

            var dealId = (int)selectedItem.Tag;
            var deal = _allDeals.FirstOrDefault(d => d.DealId == dealId);

            if (deal != null)
            {
                DeletePreviewName.Text = deal.DealTitle;
                DeletePreviewRequested.Text = deal.ClientName ?? "N/A";
                DeletePreviewDeadline.Text = deal.EndDate?.ToString("dd MMM yyyy") ?? "N/A";
                DeletePreviewStatus.Text = deal.Status;
                DeletePreviewPanel.Visibility = Visibility.Visible;
            }
        }

        private async void ConfirmDeleteDeal_Click(object sender, RoutedEventArgs e)
        {
            if (DeleteDealSelect.SelectedIndex <= 0)
            {
                MessageBox.Show("Please select a deal to delete.", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }

            var selectedItem = DeleteDealSelect.SelectedItem as ComboBoxItem;
            var dealId = (int)(selectedItem?.Tag ?? 0);
            var deal = _allDeals.FirstOrDefault(d => d.DealId == dealId);

            if (deal != null)
            {
                var result = MessageBox.Show(
                    $"⚠️ ARE YOU SURE?\n\n" +
                    $"You are about to permanently delete:\n\n" +
                    $"Deal: {deal.DealTitle}\n" +
                    $"Client: {deal.ClientName}\n\n" +
                    "This action CANNOT be undone!",
                    "Confirm Deletion", MessageBoxButton.YesNo, MessageBoxImage.Warning);

                if (result == MessageBoxResult.Yes)
                {
                    try
                    {
                        await _dealDataService.DeleteDealAsync(dealId);
                        _allDeals.Remove(deal);
                        ApplyFilters();
                        await UpdateStatisticsAsync();
                        LoadDealComboBoxes();

                        DeleteDealSelect.SelectedIndex = 0;
                        DeletePreviewPanel.Visibility = Visibility.Collapsed;

                        MessageBox.Show("Deal deleted successfully!", "Deleted", MessageBoxButton.OK, MessageBoxImage.Information);
                    }
                    catch (Exception ex)
                    {
                        MessageBox.Show($"Error deleting deal: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
                    }
                }
            }
        }

        #endregion

        #region Common Actions

        private void AddDealItemBtn_Click(object sender, RoutedEventArgs e)
        {
            // Validation
            if (AddDealItemProduct.SelectedIndex < 0)
            {
                MessageBox.Show("Please select a product.", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }

            if (!int.TryParse(AddDealItemQuantity.Text, out int quantity) || quantity <= 0)
            {
                MessageBox.Show("Please enter a valid quantity (positive number).", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                AddDealItemQuantity.Focus();
                return;
            }

            if (!decimal.TryParse(AddDealItemPrice.Text, out decimal unitPrice) || unitPrice <= 0)
            {
                MessageBox.Show("Please enter a valid unit price (positive number).", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                AddDealItemPrice.Focus();
                return;
            }

            try
            {
                var selectedProduct = AddDealItemProduct.SelectedItem as ComboBoxItem;
                dynamic productData = selectedProduct!.Tag;

                var dealItem = new DealItem
                {
                    ProductId = productData.ProductID,
                    ProductName = productData.ProductName,
                    SKU = productData.SKU,
                    Quantity = quantity,
                    UnitPrice = unitPrice,
                    TotalPrice = quantity * unitPrice
                };

                _currentDealItems.Add(dealItem);

                // Clear inputs
                AddDealItemProduct.SelectedIndex = -1;
                AddDealItemQuantity.Text = "";
                AddDealItemPrice.Text = "";

                MessageBox.Show($"Product '{dealItem.ProductName}' added to deal items.", "Item Added", MessageBoxButton.OK, MessageBoxImage.Information);
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error adding deal item: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void RemoveDealItem_Click(object sender, RoutedEventArgs e)
        {
            var button = sender as Button;
            var item = button?.Tag as DealItem;

            if (item != null)
            {
                var result = MessageBox.Show(
                    $"Remove '{item.ProductName}' from deal items?",
                    "Confirm Remove", MessageBoxButton.YesNo, MessageBoxImage.Question);

                if (result == MessageBoxResult.Yes)
                {
                    _currentDealItems.Remove(item);
                }
            }
        }

        private void AddDealItemProduct_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            // Auto-fill price when product is selected
            if (AddDealItemProduct.SelectedIndex >= 0)
            {
                var selectedProduct = AddDealItemProduct.SelectedItem as ComboBoxItem;
                if (selectedProduct?.Tag != null)
                {
                    dynamic productData = selectedProduct.Tag;
                    AddDealItemPrice.Text = productData.SalePrice.ToString("F2");
                }
            }
        }

        private void UpdateDealItemProduct_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            // Auto-fill price when product is selected in update tab
            if (UpdateDealItemProduct.SelectedIndex >= 0)
            {
                var selectedProduct = UpdateDealItemProduct.SelectedItem as ComboBoxItem;
                if (selectedProduct?.Tag != null)
                {
                    dynamic productData = selectedProduct.Tag;
                    UpdateDealItemPrice.Text = productData.SalePrice.ToString("F2");
                }
            }
        }

        private void UpdateAddDealItemBtn_Click(object sender, RoutedEventArgs e)
        {
            // Validation
            if (UpdateDealItemProduct.SelectedIndex < 0)
            {
                MessageBox.Show("Please select a product.", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }

            if (!int.TryParse(UpdateDealItemQuantity.Text, out int quantity) || quantity <= 0)
            {
                MessageBox.Show("Please enter a valid quantity (positive number).", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                UpdateDealItemQuantity.Focus();
                return;
            }

            if (!decimal.TryParse(UpdateDealItemPrice.Text, out decimal unitPrice) || unitPrice <= 0)
            {
                MessageBox.Show("Please enter a valid unit price (positive number).", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                UpdateDealItemPrice.Focus();
                return;
            }

            try
            {
                var selectedProduct = UpdateDealItemProduct.SelectedItem as ComboBoxItem;
                dynamic productData = selectedProduct!.Tag;

                var dealItem = new DealItem
                {
                    ProductId = productData.ProductID,
                    ProductName = productData.ProductName,
                    SKU = productData.SKU,
                    Quantity = quantity,
                    UnitPrice = unitPrice,
                    TotalPrice = quantity * unitPrice
                };

                _updateDealItems.Add(dealItem);

                // Clear inputs
                UpdateDealItemProduct.SelectedIndex = -1;
                UpdateDealItemQuantity.Text = "";
                UpdateDealItemPrice.Text = "";

                MessageBox.Show($"Product '{dealItem.ProductName}' added to deal items.", "Item Added", MessageBoxButton.OK, MessageBoxImage.Information);
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error adding deal item: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void UpdateRemoveDealItem_Click(object sender, RoutedEventArgs e)
        {
            var button = sender as Button;
            var item = button?.Tag as DealItem;

            if (item != null)
            {
                var result = MessageBox.Show(
                    $"Remove '{item.ProductName}' from deal items?",
                    "Confirm Remove", MessageBoxButton.YesNo, MessageBoxImage.Question);

                if (result == MessageBoxResult.Yes)
                {
                    _updateDealItems.Remove(item);
                }
            }
        }

        private async void RefreshBtn_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                _allDeals = await _dealDataService.GetAllDealsAsync();
                ApplyFilters();
                await UpdateStatisticsAsync();
                LoadDealComboBoxes();

                MessageBox.Show("Data refreshed successfully!", "Refresh", MessageBoxButton.OK, MessageBoxImage.Information);
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error refreshing data: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void AddDealBtn_Click(object sender, RoutedEventArgs e)
        {
            // Switch to Add Deal tab
            AddDealTab.Style = (Style)Resources["ActiveTabBtn"];
            ViewAllTab.Style = (Style)Resources["TabBtn"];
            UpdateDealTab.Style = (Style)Resources["TabBtn"];
            DeleteDealTab.Style = (Style)Resources["TabBtn"];

            ViewAllContent.Visibility = Visibility.Collapsed;
            AddDealContent.Visibility = Visibility.Visible;
            UpdateDealContent.Visibility = Visibility.Collapsed;
            DeleteDealContent.Visibility = Visibility.Collapsed;
        }

        #endregion
    }
}
