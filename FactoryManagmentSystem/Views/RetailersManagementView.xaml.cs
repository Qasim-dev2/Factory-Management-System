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
    public partial class RetailersManagementView : UserControl
    {
        // Data collections
        private ObservableCollection<RetailerModel> _retailers = new();
        private List<RetailerModel> _allRetailers = new();

        // Pagination
        private int _currentPage = 1;
        private const int PageSize = 10;

        private bool _isLoaded = false;

        // Database service
        private readonly RetailerDataService _dataService;
        private List<(int Id, string Name)> _salesReps = new();

        public RetailersManagementView()
        {
            InitializeComponent();
            _dataService = new RetailerDataService();
            
            RetailersGrid.ItemsSource = _retailers;

            _ = LoadDataAsync();
        }

        private async System.Threading.Tasks.Task LoadDataAsync()
        {
            try
            {
                await LoadRetailersAsync();
                await LoadSalesRepsAsync();
                await UpdateStatisticsAsync();
                LoadRetailerComboBoxes();
                
                _isLoaded = true;
                ApplyFilters();
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error loading data: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private async System.Threading.Tasks.Task LoadRetailersAsync()
        {
            try
            {
                var retailers = await _dataService.GetAllRetailersAsync();
                _allRetailers = retailers.Select(r => new RetailerModel
                {
                    RetailerId = r.RetailerID,
                    Name = r.CompanyName ?? "",
                    ContactName = r.ContactPerson ?? "",
                    Phone = r.Phone ?? "",
                    Email = r.Email ?? "",
                    City = r.City ?? "",
                    Address = r.Address ?? "",
                    Status = r.Status ?? "Active"
                }).ToList();
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error loading retailers: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private async System.Threading.Tasks.Task LoadSalesRepsAsync()
        {
            try
            {
                _salesReps = await _dataService.GetSalesRepresentativesAsync();
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error loading sales representatives: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void LoadRetailerComboBoxes()
        {
            // Clear existing items except the first placeholder
            while (UpdateRetailerSelect.Items.Count > 1)
                UpdateRetailerSelect.Items.RemoveAt(1);
            while (DeleteRetailerSelect.Items.Count > 1)
                DeleteRetailerSelect.Items.RemoveAt(1);

            foreach (var retailer in _allRetailers)
            {
                UpdateRetailerSelect.Items.Add(new ComboBoxItem
                {
                    Content = $"[{retailer.RetailerId}] {retailer.Name}",
                    Tag = retailer.RetailerId
                });
                DeleteRetailerSelect.Items.Add(new ComboBoxItem
                {
                    Content = $"[{retailer.RetailerId}] {retailer.Name}",
                    Tag = retailer.RetailerId
                });
            }
        }

        private async System.Threading.Tasks.Task UpdateStatisticsAsync()
        {
            try
            {
                var stats = await _dataService.GetRetailerStatisticsAsync();
                TotalRetailersText.Text = stats.Total.ToString();
                ActiveRetailersText.Text = stats.Active.ToString();
                InactiveRetailersText.Text = stats.Inactive.ToString();
                CitiesCoveredText.Text = stats.Cities.ToString();
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error updating statistics: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void ApplyFilters()
        {
            if (!_isLoaded) return;

            var filtered = _allRetailers.AsEnumerable();

            // Search filter
            var searchText = SearchBox?.Text?.ToLower() ?? "";
            if (!string.IsNullOrWhiteSpace(searchText))
            {
                filtered = filtered.Where(r =>
                    r.Name.ToLower().Contains(searchText) ||
                    r.ContactName.ToLower().Contains(searchText) ||
                    r.Phone.ToLower().Contains(searchText) ||
                    r.Email.ToLower().Contains(searchText) ||
                    r.City.ToLower().Contains(searchText) ||
                    r.RetailerId.ToString().Contains(searchText));
            }

            // City filter
            var selectedCity = (CityFilter?.SelectedItem as ComboBoxItem)?.Content?.ToString();
            if (!string.IsNullOrEmpty(selectedCity) && selectedCity != "All Cities")
            {
                filtered = filtered.Where(r => r.City == selectedCity);
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

            _retailers.Clear();
            foreach (var item in pagedItems)
                _retailers.Add(item);

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
            AddRetailerTab.Style = (Style)Resources["TabBtn"];
            UpdateRetailerTab.Style = (Style)Resources["TabBtn"];
            DeleteRetailerTab.Style = (Style)Resources["TabBtn"];

            // Set active tab style
            button.Style = (Style)Resources["ActiveTabBtn"];

            // Hide all content
            ViewAllContent.Visibility = Visibility.Collapsed;
            AddRetailerContent.Visibility = Visibility.Collapsed;
            UpdateRetailerContent.Visibility = Visibility.Collapsed;
            DeleteRetailerContent.Visibility = Visibility.Collapsed;

            // Show selected content
            switch (tabName)
            {
                case "ViewAll":
                    ViewAllContent.Visibility = Visibility.Visible;
                    break;
                case "Add":
                    AddRetailerContent.Visibility = Visibility.Visible;
                    break;
                case "Update":
                    UpdateRetailerContent.Visibility = Visibility.Visible;
                    break;
                case "Delete":
                    DeleteRetailerContent.Visibility = Visibility.Visible;
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

        private void CityFilter_SelectionChanged(object sender, SelectionChangedEventArgs e)
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
            int totalPages = (int)Math.Ceiling((double)_allRetailers.Count / PageSize);
            if (_currentPage < totalPages)
            {
                _currentPage++;
                ApplyFilters();
            }
        }

        private void ViewRetailer_Click(object sender, RoutedEventArgs e)
        {
            var retailerId = (int)(sender as Button)?.Tag!;
            var retailer = _allRetailers.FirstOrDefault(r => r.RetailerId == retailerId);

            if (retailer != null)
            {
                MessageBox.Show(
                    $"🏪 RETAILER DETAILS\n\n" +
                    $"ID: {retailer.RetailerId}\n" +
                    $"Name: {retailer.Name}\n" +
                    $"Contact: {retailer.ContactName}\n" +
                    $"Phone: {retailer.Phone}\n" +
                    $"Email: {retailer.Email}\n" +
                    $"City: {retailer.City}\n" +
                    $"Address: {retailer.Address}\n" +
                    $"Status: {retailer.Status}",
                    "Retailer Details", MessageBoxButton.OK, MessageBoxImage.Information);
            }
        }

        private void EditRetailer_Click(object sender, RoutedEventArgs e)
        {
            var retailerId = (int)(sender as Button)?.Tag!;

            // Switch to Update tab and select the retailer
            UpdateRetailerTab.Style = (Style)Resources["ActiveTabBtn"];
            ViewAllTab.Style = (Style)Resources["TabBtn"];

            ViewAllContent.Visibility = Visibility.Collapsed;
            UpdateRetailerContent.Visibility = Visibility.Visible;

            // Find and select the retailer in combo box
            for (int i = 1; i < UpdateRetailerSelect.Items.Count; i++)
            {
                var item = UpdateRetailerSelect.Items[i] as ComboBoxItem;
                if (item?.Tag != null && (int)item.Tag == retailerId)
                {
                    UpdateRetailerSelect.SelectedIndex = i;
                    break;
                }
            }
        }

        private void DeleteRetailer_Click(object sender, RoutedEventArgs e)
        {
            var retailerId = (int)(sender as Button)?.Tag!;
            var retailer = _allRetailers.FirstOrDefault(r => r.RetailerId == retailerId);

            if (retailer != null)
            {
                var result = MessageBox.Show(
                    $"Are you sure you want to delete this retailer?\n\n" +
                    $"Name: {retailer.Name}\n" +
                    $"City: {retailer.City}\n\n" +
                    "This action cannot be undone.",
                    "Confirm Delete", MessageBoxButton.YesNo, MessageBoxImage.Warning);

                if (result == MessageBoxResult.Yes)
                {
                    _ = DeleteRetailerAsync(retailerId);
                }
            }
        }

        private async System.Threading.Tasks.Task DeleteRetailerAsync(int retailerId)
        {
            try
            {
                await _dataService.DeleteRetailerAsync(retailerId);
                await LoadRetailersAsync();
                ApplyFilters();
                await UpdateStatisticsAsync();
                LoadRetailerComboBoxes();

                MessageBox.Show("Retailer deleted successfully!", "Deleted", MessageBoxButton.OK, MessageBoxImage.Information);
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error deleting retailer: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        #endregion

        #region Add Retailer Tab

        private void ClearAddForm_Click(object sender, RoutedEventArgs e)
        {
            AddName.Text = "";
            AddContactName.Text = "";
            AddPhone.Text = "";
            AddEmail.Text = "";
            AddCity.SelectedIndex = 0;
            AddAddress.Text = "";
            // Clear new fields
            if (FindName("AddAltPhone") is TextBox altPhone) altPhone.Text = "";
            if (FindName("AddProvince") is ComboBox province) province.SelectedIndex = 0;
            if (FindName("AddPostalCode") is TextBox postalCode) postalCode.Text = "";
            // Hide error message
            if (FindName("AddErrorBorder") is Border errorBorder) errorBorder.Visibility = Visibility.Collapsed;
        }

        private void ShowAddError(string message)
        {
            if (FindName("AddErrorBorder") is Border errorBorder && FindName("AddErrorMessage") is TextBlock errorText)
            {
                errorText.Text = message;
                errorBorder.Visibility = Visibility.Visible;
            }
            else
            {
                MessageBox.Show(message, "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
            }
        }

        private void HideAddError()
        {
            if (FindName("AddErrorBorder") is Border errorBorder)
            {
                errorBorder.Visibility = Visibility.Collapsed;
            }
        }

        private void SaveRetailer_Click(object sender, RoutedEventArgs e)
        {
            HideAddError();
            
            // Validation
            if (string.IsNullOrWhiteSpace(AddName.Text))
            {
                ShowAddError("Please enter a retailer/company name.");
                AddName.Focus();
                return;
            }

            if (string.IsNullOrWhiteSpace(AddContactName.Text))
            {
                ShowAddError("Please enter a contact name.");
                AddContactName.Focus();
                return;
            }

            if (string.IsNullOrWhiteSpace(AddPhone.Text))
            {
                ShowAddError("Please enter a phone number.");
                AddPhone.Focus();
                return;
            }

            // Validate phone format (basic)
            if (AddPhone.Text.Length < 10)
            {
                ShowAddError("Phone number should be at least 10 digits.");
                AddPhone.Focus();
                return;
            }

            if (AddCity.SelectedIndex <= 0)
            {
                ShowAddError("Please select a city.");
                return;
            }

            var addProvince = FindName("AddProvince") as ComboBox;
            if (addProvince != null && addProvince.SelectedIndex <= 0)
            {
                ShowAddError("Please select a province.");
                return;
            }

            if (string.IsNullOrWhiteSpace(AddAddress.Text))
            {
                ShowAddError("Please enter an address.");
                AddAddress.Focus();
                return;
            }

            _ = SaveRetailerAsync();
        }

        private async System.Threading.Tasks.Task SaveRetailerAsync()
        {
            try
            {
                var selectedCity = (AddCity.SelectedItem as ComboBoxItem)?.Content?.ToString() ?? "";
                var selectedProvince = (FindName("AddProvince") as ComboBox)?.SelectedItem is ComboBoxItem prov ? prov.Content?.ToString() : "";
                var altPhone = (FindName("AddAltPhone") as TextBox)?.Text?.Trim() ?? "";
                var postalCode = (FindName("AddPostalCode") as TextBox)?.Text?.Trim() ?? "";

                var newRetailer = new Retailer
                {
                    CompanyName = AddName.Text.Trim(),
                    ContactPerson = AddContactName.Text.Trim(),
                    Phone = AddPhone.Text.Trim(),
                    Email = AddEmail.Text.Trim(),
                    AlternativePhone = altPhone,
                    City = selectedCity,
                    Province = selectedProvince,
                    PostalCode = postalCode,
                    Address = AddAddress.Text.Trim(),
                    Status = "Active"
                };

                int newId = await _dataService.AddRetailerAsync(newRetailer);
                
                await LoadRetailersAsync();
                ApplyFilters();
                await UpdateStatisticsAsync();
                LoadRetailerComboBoxes();

                MessageBox.Show(
                    $"✅ Retailer Added Successfully!\n\n" +
                    $"ID: {newId}\n" +
                    $"Name: {newRetailer.CompanyName}\n" +
                    $"City: {newRetailer.City}",
                    "Success", MessageBoxButton.OK, MessageBoxImage.Information);

                ClearAddForm_Click(null!, null!);

                // Switch to View All tab
                ViewAllTab.Style = (Style)Resources["ActiveTabBtn"];
                AddRetailerTab.Style = (Style)Resources["TabBtn"];
                AddRetailerContent.Visibility = Visibility.Collapsed;
                ViewAllContent.Visibility = Visibility.Visible;
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error saving retailer: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        #endregion

        #region Update Retailer Tab

        private void UpdateRetailerSelect_Changed(object sender, SelectionChangedEventArgs e)
        {
            if (!_isLoaded) return;
            if (UpdateRetailerSelect.SelectedIndex <= 0)
            {
                UpdateName.Text = "";
                UpdateContactName.Text = "";
                UpdatePhone.Text = "";
                UpdateEmail.Text = "";
                UpdateCity.SelectedIndex = -1;
                UpdateStatus.SelectedIndex = -1;
                UpdateAddress.Text = "";
                return;
            }

            var selectedItem = UpdateRetailerSelect.SelectedItem as ComboBoxItem;
            if (selectedItem?.Tag == null) return;

            var retailerId = (int)selectedItem.Tag;
            var retailer = _allRetailers.FirstOrDefault(r => r.RetailerId == retailerId);

            if (retailer != null)
            {
                UpdateName.Text = retailer.Name;
                UpdateContactName.Text = retailer.ContactName;
                UpdatePhone.Text = retailer.Phone;
                UpdateEmail.Text = retailer.Email;
                UpdateAddress.Text = retailer.Address;

                // Set city
                for (int i = 0; i < UpdateCity.Items.Count; i++)
                {
                    var item = UpdateCity.Items[i] as ComboBoxItem;
                    if (item?.Content?.ToString() == retailer.City)
                    {
                        UpdateCity.SelectedIndex = i;
                        break;
                    }
                }

                // Set status
                for (int i = 0; i < UpdateStatus.Items.Count; i++)
                {
                    var item = UpdateStatus.Items[i] as ComboBoxItem;
                    if (item?.Content?.ToString() == retailer.Status)
                    {
                        UpdateStatus.SelectedIndex = i;
                        break;
                    }
                }
            }
        }

        private void ResetUpdateForm_Click(object sender, RoutedEventArgs e)
        {
            UpdateRetailerSelect.SelectedIndex = 0;
            UpdateName.Text = "";
            UpdateContactName.Text = "";
            UpdatePhone.Text = "";
            UpdateEmail.Text = "";
            UpdateCity.SelectedIndex = -1;
            UpdateStatus.SelectedIndex = -1;
            UpdateAddress.Text = "";
        }

        private void UpdateRetailerBtn_Click(object sender, RoutedEventArgs e)
        {
            if (UpdateRetailerSelect.SelectedIndex <= 0)
            {
                MessageBox.Show("Please select a retailer to update.", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }

            if (string.IsNullOrWhiteSpace(UpdateName.Text))
            {
                MessageBox.Show("Please enter a retailer name.", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }

            if (string.IsNullOrWhiteSpace(UpdateContactName.Text))
            {
                MessageBox.Show("Please enter a contact name.", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }

            _ = UpdateRetailerAsync();
        }

        private async System.Threading.Tasks.Task UpdateRetailerAsync()
        {
            try
            {
                var selectedItem = UpdateRetailerSelect.SelectedItem as ComboBoxItem;
                var retailerId = (int)(selectedItem?.Tag ?? 0);

                var updatedRetailer = new Retailer
                {
                    RetailerID = retailerId,
                    CompanyName = UpdateName.Text.Trim(),
                    ContactPerson = UpdateContactName.Text.Trim(),
                    Phone = UpdatePhone.Text.Trim(),
                    Email = UpdateEmail.Text.Trim(),
                    City = (UpdateCity.SelectedItem as ComboBoxItem)?.Content?.ToString() ?? "",
                    Status = (UpdateStatus.SelectedItem as ComboBoxItem)?.Content?.ToString() ?? "Active",
                    Address = UpdateAddress.Text.Trim()
                };

                await _dataService.UpdateRetailerAsync(updatedRetailer);
                
                await LoadRetailersAsync();
                ApplyFilters();
                await UpdateStatisticsAsync();
                LoadRetailerComboBoxes();

                MessageBox.Show(
                    $"✅ Retailer Updated Successfully!\n\n" +
                    $"ID: {retailerId}\n" +
                    $"Name: {updatedRetailer.CompanyName}",
                    "Success", MessageBoxButton.OK, MessageBoxImage.Information);

                ResetUpdateForm_Click(null!, null!);
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error updating retailer: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        #endregion

        #region Delete Retailer Tab

        private void DeleteRetailerSelect_Changed(object sender, SelectionChangedEventArgs e)
        {
            if (!_isLoaded) return;
            if (DeleteRetailerSelect.SelectedIndex <= 0)
            {
                DeletePreviewPanel.Visibility = Visibility.Collapsed;
                return;
            }

            var selectedItem = DeleteRetailerSelect.SelectedItem as ComboBoxItem;
            if (selectedItem?.Tag == null) return;

            var retailerId = (int)selectedItem.Tag;
            var retailer = _allRetailers.FirstOrDefault(r => r.RetailerId == retailerId);

            if (retailer != null)
            {
                DeletePreviewName.Text = retailer.Name;
                DeletePreviewContact.Text = retailer.ContactName;
                DeletePreviewPhone.Text = retailer.Phone;
                DeletePreviewEmail.Text = retailer.Email;
                DeletePreviewCity.Text = retailer.City;
                DeletePreviewStatus.Text = retailer.Status;
                DeletePreviewPanel.Visibility = Visibility.Visible;
            }
        }

        private void ConfirmDeleteRetailer_Click(object sender, RoutedEventArgs e)
        {
            if (DeleteRetailerSelect.SelectedIndex <= 0)
            {
                MessageBox.Show("Please select a retailer to delete.", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }

            var selectedItem = DeleteRetailerSelect.SelectedItem as ComboBoxItem;
            var retailerId = (int)(selectedItem?.Tag ?? 0);
            var retailer = _allRetailers.FirstOrDefault(r => r.RetailerId == retailerId);

            if (retailer != null)
            {
                var result = MessageBox.Show(
                    $"⚠️ ARE YOU SURE?\n\n" +
                    $"You are about to permanently delete:\n\n" +
                    $"Name: {retailer.Name}\n" +
                    $"City: {retailer.City}\n\n" +
                    "This action CANNOT be undone!",
                    "Confirm Deletion", MessageBoxButton.YesNo, MessageBoxImage.Warning);

                if (result == MessageBoxResult.Yes)
                {
                    _ = ConfirmDeleteRetailerAsync(retailerId);
                }
            }
        }

        private async System.Threading.Tasks.Task ConfirmDeleteRetailerAsync(int retailerId)
        {
            try
            {
                await _dataService.DeleteRetailerAsync(retailerId);
                await LoadRetailersAsync();
                ApplyFilters();
                await UpdateStatisticsAsync();
                LoadRetailerComboBoxes();

                DeleteRetailerSelect.SelectedIndex = 0;
                DeletePreviewPanel.Visibility = Visibility.Collapsed;

                MessageBox.Show("Retailer deleted successfully!", "Deleted", MessageBoxButton.OK, MessageBoxImage.Information);
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error deleting retailer: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        #endregion

        #region Common Actions

        private void RefreshBtn_Click(object sender, RoutedEventArgs e)
        {
            _ = RefreshDataAsync();
        }

        private async System.Threading.Tasks.Task RefreshDataAsync()
        {
            try
            {
                await LoadRetailersAsync();
                ApplyFilters();
                await UpdateStatisticsAsync();
                LoadRetailerComboBoxes();

                MessageBox.Show("Data refreshed successfully!", "Refresh", MessageBoxButton.OK, MessageBoxImage.Information);
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error refreshing data: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void AddRetailerBtn_Click(object sender, RoutedEventArgs e)
        {
            // Switch to Add Retailer tab
            AddRetailerTab.Style = (Style)Resources["ActiveTabBtn"];
            ViewAllTab.Style = (Style)Resources["TabBtn"];
            UpdateRetailerTab.Style = (Style)Resources["TabBtn"];
            DeleteRetailerTab.Style = (Style)Resources["TabBtn"];

            ViewAllContent.Visibility = Visibility.Collapsed;
            AddRetailerContent.Visibility = Visibility.Visible;
            UpdateRetailerContent.Visibility = Visibility.Collapsed;
            DeleteRetailerContent.Visibility = Visibility.Collapsed;
        }

        #endregion
    }

    /// <summary>
    /// Retailer Model based on the entity diagram
    /// RetailerID (INT, PK), Name, ContactName, Phone, Email, City, Address
    /// </summary>
    public class RetailerModel : INotifyPropertyChanged
    {
        private int _retailerId;
        private string _name = string.Empty;
        private string _contactName = string.Empty;
        private string _phone = string.Empty;
        private string _email = string.Empty;
        private string _city = string.Empty;
        private string _address = string.Empty;
        private string _status = string.Empty;

        public int RetailerId
        {
            get => _retailerId;
            set { _retailerId = value; OnPropertyChanged(); }
        }

        public string Name
        {
            get => _name;
            set { _name = value; OnPropertyChanged(); }
        }

        public string ContactName
        {
            get => _contactName;
            set { _contactName = value; OnPropertyChanged(); }
        }

        public string Phone
        {
            get => _phone;
            set { _phone = value; OnPropertyChanged(); }
        }

        public string Email
        {
            get => _email;
            set { _email = value; OnPropertyChanged(); }
        }

        public string City
        {
            get => _city;
            set { _city = value; OnPropertyChanged(); }
        }

        public string Address
        {
            get => _address;
            set { _address = value; OnPropertyChanged(); }
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
}
