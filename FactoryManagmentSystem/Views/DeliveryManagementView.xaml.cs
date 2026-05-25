using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using FactoryManagmentSystem.Services;

namespace FactoryManagmentSystem.Views
{
    public partial class DeliveryManagementView : UserControl
    {
        // Data collections
        private ObservableCollection<DeliveryModel> _deliveries = new();
        private List<DeliveryModel> _allDeliveries = new();
        private List<DeliveryPersonInfo> _deliveryPersons = new();

        // Pagination
        private int _currentPage = 1;
        private const int PageSize = 10;

        private bool _isLoaded = false;
        private readonly OrderApprovalDataService _orderApprovalService;
        private readonly DeliveryDataService _deliveryService;

        public DeliveryManagementView()
        {
            InitializeComponent();
            _orderApprovalService = new OrderApprovalDataService();
            _deliveryService = new DeliveryDataService();
            DeliveriesGrid.ItemsSource = _deliveries;
            Loaded += async (s, e) => await InitializeAsync();
        }

        private async Task InitializeAsync()
        {
            await LoadDeliveriesFromDatabaseAsync();
            await LoadComboBoxesAsync();
            ApplyFilters();
            await UpdateStatisticsAsync();
            _isLoaded = true;
        }

        private async Task LoadDeliveriesFromDatabaseAsync()
        {
            try
            {
                var deliveries = await _orderApprovalService.GetDeliveryAssignmentsAsync();
                _allDeliveries.Clear();

                foreach (var delivery in deliveries)
                {
                    // Determine proper display information
                    string sourceType;
                    string sourceDisplay;
                    
                    if (delivery.SalesOrderID.HasValue && delivery.SalesOrderID > 0)
                    {
                        sourceType = "Sales Order";
                        sourceDisplay = $"Order #{delivery.SalesOrderID}";
                    }
                    else if (delivery.DealID.HasValue && delivery.DealID > 0)
                    {
                        sourceType = "Deal";
                        sourceDisplay = $"Deal #{delivery.DealID}";
                    }
                    else
                    {
                        sourceType = "Direct";
                        sourceDisplay = $"Delivery #{delivery.DeliveryID}";
                    }

                    _allDeliveries.Add(new DeliveryModel
                    {
                        DeliveryId = delivery.DeliveryID,
                        SalesOrderId = delivery.SalesOrderID,
                        DealId = delivery.DealID,
                        SourceType = sourceType,
                        SourceDisplay = sourceDisplay,
                        RetailerName = delivery.CustomerName ?? "N/A",
                        DeliveryDate = delivery.DeliveryDate ?? DateTime.Now,
                        Status = delivery.Status,
                        DeliveredById = 0,
                        DeliveredByName = ""
                    });
                }

                LoadDeliverySelectComboBox();
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error loading deliveries: {ex.Message}", "Database Error", 
                    MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private async Task LoadComboBoxesAsync()
        {
            try
            {
                using var connection = new System.Data.SqlClient.SqlConnection(
                    "Server=QASIM\\SQLEXPRESS;Database=GarmentsFactoryDB;Trusted_Connection=True;TrustServerCertificate=True;MultipleActiveResultSets=True;");
                await connection.OpenAsync();

                using var command = new System.Data.SqlClient.SqlCommand(
                    "SELECT EmployeeID, FirstName + ' ' + LastName AS FullName FROM Employee WHERE Position LIKE '%Delivery%' AND IsActive = 1",
                    connection);

                using var reader = await command.ExecuteReaderAsync();
                _deliveryPersons.Clear();

                while (await reader.ReadAsync())
                {
                    _deliveryPersons.Add(new DeliveryPersonInfo
                    {
                        PersonId = reader.GetInt32(0),
                        Name = reader.GetString(1)
                    });
                }

                while (UpdateDeliveredBy.Items.Count > 1)
                    UpdateDeliveredBy.Items.RemoveAt(1);

                foreach (var person in _deliveryPersons)
                {
                    UpdateDeliveredBy.Items.Add(new ComboBoxItem
                    {
                        Content = person.Name,
                        Tag = person.PersonId
                    });
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error loading combo boxes: {ex.Message}", "Database Error",
                    MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }



        private void LoadDeliverySelectComboBox()
        {
            while (UpdateDeliverySelect.Items.Count > 1)
                UpdateDeliverySelect.Items.RemoveAt(1);

            // Only show pending deliveries for update
            var pendingDeliveries = _allDeliveries.Where(d => d.Status == "Pending").ToList();

            foreach (var delivery in pendingDeliveries)
            {
                // Build better display text
                string orderInfo;
                if (delivery.SalesOrderId.HasValue && delivery.SalesOrderId > 0)
                {
                    orderInfo = $"Sales Order #{delivery.SalesOrderId}";
                }
                else if (delivery.DealId.HasValue && delivery.DealId > 0)
                {
                    orderInfo = $"Deal #{delivery.DealId}";
                }
                else
                {
                    orderInfo = $"Delivery #{delivery.DeliveryId}";
                }

                var displayText = delivery.RetailerName != "N/A" && !string.IsNullOrEmpty(delivery.RetailerName)
                    ? $"[{delivery.DeliveryId}] {orderInfo} - {delivery.RetailerName}"
                    : $"[{delivery.DeliveryId}] {orderInfo}";

                UpdateDeliverySelect.Items.Add(new ComboBoxItem
                {
                    Content = displayText,
                    Tag = delivery.DeliveryId
                });
            }
        }

        private async Task UpdateStatisticsAsync()
        {
            try
            {
                var stats = await _deliveryService.GetDeliveryStatisticsAsync();
                TotalDeliveriesText.Text = stats.TotalDeliveries.ToString();
                PendingDeliveriesText.Text = stats.PendingDeliveries.ToString();
                DeliveredCountText.Text = stats.DeliveredCount.ToString();
                
                // Count unique delivery persons who have deliveries assigned
                var uniqueDeliveryPersons = _allDeliveries
                    .Where(d => d.DeliveredById > 0)
                    .Select(d => d.DeliveredById)
                    .Distinct()
                    .Count();
                DeliveryPersonsText.Text = uniqueDeliveryPersons.ToString();
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error updating statistics: {ex.Message}", "Database Error",
                    MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void ApplyFilters()
        {
            if (!_isLoaded) return;

            var filtered = _allDeliveries.AsEnumerable();

            // Search filter
            var searchText = SearchBox?.Text?.ToLower() ?? "";
            if (!string.IsNullOrWhiteSpace(searchText))
            {
                filtered = filtered.Where(d =>
                    d.RetailerName.ToLower().Contains(searchText) ||
                    d.SourceDisplay.ToLower().Contains(searchText) ||
                    d.DeliveredByName.ToLower().Contains(searchText) ||
                    d.DeliveryId.ToString().Contains(searchText));
            }

            // Status filter
            var selectedStatus = (StatusFilter?.SelectedItem as ComboBoxItem)?.Content?.ToString();
            if (!string.IsNullOrEmpty(selectedStatus) && selectedStatus != "All Status")
            {
                filtered = filtered.Where(d => d.Status == selectedStatus);
            }

            // Source filter
            var selectedSource = (SourceFilter?.SelectedItem as ComboBoxItem)?.Content?.ToString();
            if (!string.IsNullOrEmpty(selectedSource) && selectedSource != "All Sources")
            {
                filtered = filtered.Where(d => d.SourceType == selectedSource);
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

            _deliveries.Clear();
            foreach (var item in pagedItems)
                _deliveries.Add(item);

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
            PendingTab.Style = (Style)Resources["TabBtn"];
            UpdateDeliveryTab.Style = (Style)Resources["TabBtn"];

            // Set active tab style
            button.Style = (Style)Resources["ActiveTabBtn"];

            // Hide all content
            ViewAllContent.Visibility = Visibility.Collapsed;
            PendingContent.Visibility = Visibility.Collapsed;
            UpdateDeliveryContent.Visibility = Visibility.Collapsed;

            // Show selected content
            switch (tabName)
            {
                case "ViewAll":
                    ViewAllContent.Visibility = Visibility.Visible;
                    break;
                case "Pending":
                    PendingContent.Visibility = Visibility.Visible;
                    LoadPendingDeliveries();
                    break;
                case "Update":
                    UpdateDeliveryContent.Visibility = Visibility.Visible;
                    break;
            }
        }

        #endregion

        #region Pending Deliveries Tab

        private void LoadPendingDeliveries()
        {
            var pendingDeliveries = _allDeliveries.Where(d => d.Status == "Pending").ToList();
            PendingDeliveriesGrid.ItemsSource = pendingDeliveries;
        }

        private void QuickUpdate_Click(object sender, RoutedEventArgs e)
        {
            var deliveryId = (int)(sender as Button)?.Tag!;
            
            // Switch to Update tab and select this delivery
            UpdateDeliveryTab.RaiseEvent(new RoutedEventArgs(Button.ClickEvent));
            
            // Find and select the delivery in the dropdown
            for (int i = 1; i < UpdateDeliverySelect.Items.Count; i++)
            {
                var item = UpdateDeliverySelect.Items[i] as ComboBoxItem;
                if (item?.Tag != null && (int)item.Tag == deliveryId)
                {
                    UpdateDeliverySelect.SelectedIndex = i;
                    break;
                }
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

        private void SourceFilter_SelectionChanged(object sender, SelectionChangedEventArgs e)
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
            int totalPages = (int)Math.Ceiling((double)_allDeliveries.Count / PageSize);
            if (_currentPage < totalPages)
            {
                _currentPage++;
                ApplyFilters();
            }
        }

        private void ViewDelivery_Click(object sender, RoutedEventArgs e)
        {
            var deliveryId = (int)(sender as Button)?.Tag!;
            var delivery = _allDeliveries.FirstOrDefault(d => d.DeliveryId == deliveryId);

            if (delivery != null)
            {
                MessageBox.Show(
                    $"📦 DELIVERY DETAILS\n\n" +
                    $"Delivery ID: {delivery.DeliveryId}\n" +
                    $"Source: {delivery.SourceType}\n" +
                    $"Order/Deal: {delivery.SourceDisplay}\n" +
                    $"Retailer: {delivery.RetailerName}\n" +
                    $"Delivery Date: {delivery.DeliveryDate:dd/MM/yyyy}\n" +
                    $"Delivered By: {delivery.DeliveredByName}\n" +
                    $"Status: {delivery.Status}",
                    "Delivery Details", MessageBoxButton.OK, MessageBoxImage.Information);
            }
        }

        private async void MarkDelivered_Click(object sender, RoutedEventArgs e)
        {
            var deliveryId = (int)(sender as Button)?.Tag!;
            var delivery = _allDeliveries.FirstOrDefault(d => d.DeliveryId == deliveryId);

            if (delivery != null)
            {
                if (delivery.Status == "Delivered")
                {
                    MessageBox.Show("This delivery is already marked as Delivered.", "Info", MessageBoxButton.OK, MessageBoxImage.Information);
                    return;
                }

                var result = MessageBox.Show(
                    $"Mark this delivery as Delivered?\n\n" +
                    $"Delivery ID: {delivery.DeliveryId}\n" +
                    $"Retailer: {delivery.RetailerName}\n" +
                    $"Source: {delivery.SourceType} - {delivery.SourceDisplay}",
                    "Confirm Delivery", MessageBoxButton.YesNo, MessageBoxImage.Question);

                if (result == MessageBoxResult.Yes)
                {
                    try
                    {
                        await _deliveryService.UpdateDeliveryStatusAsync(delivery.DeliveryId, "Delivered", "", "Marked as delivered");
                        
                        // Reload all deliveries from database to get fresh data
                        await LoadDeliveriesFromDatabaseAsync();
                        ApplyFilters();
                        await UpdateStatisticsAsync();

                        MessageBox.Show("Delivery marked as Delivered!", "Success", MessageBoxButton.OK, MessageBoxImage.Information);
                    }
                    catch (Exception ex)
                    {
                        MessageBox.Show($"Error updating delivery: {ex.Message}", "Database Error",
                            MessageBoxButton.OK, MessageBoxImage.Error);
                    }
                }
            }
        }

        private async void DeleteDelivery_Click(object sender, RoutedEventArgs e)
        {
            var deliveryId = (int)(sender as Button)?.Tag!;
            var delivery = _allDeliveries.FirstOrDefault(d => d.DeliveryId == deliveryId);

            if (delivery != null)
            {
                var result = MessageBox.Show(
                    $"Are you sure you want to delete this delivery?\n\n" +
                    $"Delivery ID: {delivery.DeliveryId}\n" +
                    $"Retailer: {delivery.RetailerName}\n\n" +
                    "This action cannot be undone.",
                    "Confirm Delete", MessageBoxButton.YesNo, MessageBoxImage.Warning);

                if (result == MessageBoxResult.Yes)
                {
                    try
                    {
                        await _deliveryService.DeleteDeliveryAsync(delivery.DeliveryId);
                        _allDeliveries.Remove(delivery);
                        ApplyFilters();
                        await UpdateStatisticsAsync();
                        LoadDeliverySelectComboBox();

                        MessageBox.Show("Delivery deleted successfully!", "Deleted", MessageBoxButton.OK, MessageBoxImage.Information);
                    }
                    catch (Exception ex)
                    {
                        MessageBox.Show($"Error deleting delivery: {ex.Message}", "Database Error",
                            MessageBoxButton.OK, MessageBoxImage.Error);
                    }
                }
            }
        }

        #endregion

        #region Update Delivery Tab

        private void UpdateDeliverySelect_Changed(object sender, SelectionChangedEventArgs e)
        {
            if (!_isLoaded) return;
            if (UpdateDeliverySelect.SelectedIndex <= 0)
            {
                UpdateInfoPanel.Visibility = Visibility.Collapsed;
                UpdateDeliveryDate.SelectedDate = null;
                UpdateDeliveredBy.SelectedIndex = 0;
                UpdateStatus.SelectedIndex = -1;
                return;
            }

            var selectedItem = UpdateDeliverySelect.SelectedItem as ComboBoxItem;
            if (selectedItem?.Tag == null) return;

            var deliveryId = (int)selectedItem.Tag;
            var delivery = _allDeliveries.FirstOrDefault(d => d.DeliveryId == deliveryId);

            if (delivery != null)
            {
                // Show info panel
                UpdateInfoSource.Text = $"{delivery.SourceType}: {delivery.SourceDisplay}";
                UpdateInfoRetailer.Text = delivery.RetailerName;
                UpdateInfoStatus.Text = delivery.Status;
                UpdateInfoPanel.Visibility = Visibility.Visible;

                // Set form values
                UpdateDeliveryDate.SelectedDate = delivery.DeliveryDate;

                // Set Delivered By
                for (int i = 1; i < UpdateDeliveredBy.Items.Count; i++)
                {
                    var item = UpdateDeliveredBy.Items[i] as ComboBoxItem;
                    if (item?.Tag != null && (int)item.Tag == delivery.DeliveredById)
                    {
                        UpdateDeliveredBy.SelectedIndex = i;
                        break;
                    }
                }

                // Set Status
                for (int i = 0; i < UpdateStatus.Items.Count; i++)
                {
                    var item = UpdateStatus.Items[i] as ComboBoxItem;
                    if (item?.Content?.ToString() == delivery.Status)
                    {
                        UpdateStatus.SelectedIndex = i;
                        break;
                    }
                }
            }
        }

        private void ResetUpdateForm_Click(object sender, RoutedEventArgs e)
        {
            UpdateDeliverySelect.SelectedIndex = 0;
            UpdateInfoPanel.Visibility = Visibility.Collapsed;
            UpdateDeliveryDate.SelectedDate = null;
            UpdateDeliveredBy.SelectedIndex = 0;
            UpdateStatus.SelectedIndex = -1;
        }

        private async void UpdateDeliveryBtn_Click(object sender, RoutedEventArgs e)
        {
            if (UpdateDeliverySelect.SelectedIndex <= 0)
            {
                MessageBox.Show("Please select a delivery to update.", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }

            if (UpdateDeliveredBy.SelectedIndex <= 0)
            {
                MessageBox.Show("Please select a delivery person.", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }

            var selectedItem = UpdateDeliverySelect.SelectedItem as ComboBoxItem;
            var deliveryId = (int)(selectedItem?.Tag ?? 0);
            var delivery = _allDeliveries.FirstOrDefault(d => d.DeliveryId == deliveryId);

            if (delivery != null)
            {
                try
                {
                    var selectedPersonItem = UpdateDeliveredBy.SelectedItem as ComboBoxItem;
                    var personId = (int)(selectedPersonItem?.Tag ?? delivery.DeliveredById);
                    var person = _deliveryPersons.FirstOrDefault(p => p.PersonId == personId);

                    // Get delivery info from database
                    var dbDelivery = await _deliveryService.GetDeliveryByIdAsync(delivery.DeliveryId);
                    if (dbDelivery == null)
                    {
                        MessageBox.Show("Delivery not found in database.", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
                        return;
                    }

                    // Update all fields
                    dbDelivery.DeliveryDate = UpdateDeliveryDate.SelectedDate ?? dbDelivery.DeliveryDate;
                    dbDelivery.DeliveredBy = personId;
                    dbDelivery.DeliveryAddress = UpdateDeliveryAddress.Text;
                    dbDelivery.City = UpdateCity.Text;
                    dbDelivery.Province = UpdateProvince.Text;
                    dbDelivery.PostalCode = UpdatePostalCode.Text;
                    dbDelivery.ReceiverName = UpdateReceiverName.Text;
                    dbDelivery.ReceiverPhone = UpdateReceiverPhone.Text;
                    dbDelivery.Status = (UpdateStatus.SelectedItem as ComboBoxItem)?.Content?.ToString() ?? dbDelivery.Status;
                    dbDelivery.Notes = UpdateNotes.Text;

                    // Update in database
                    await _deliveryService.UpdateDeliveryAsync(dbDelivery);

                    // Reload all deliveries from database to get fresh data
                    await LoadDeliveriesFromDatabaseAsync();
                    ApplyFilters();
                    await UpdateStatisticsAsync();
                    LoadDeliverySelectComboBox();

                    MessageBox.Show(
                        $"✅ Delivery Updated Successfully!\n\n" +
                        $"Delivery ID: {delivery.DeliveryId}\n" +
                        $"Status: {delivery.Status}",
                        "Success", MessageBoxButton.OK, MessageBoxImage.Information);

                    ResetUpdateForm_Click(null!, null!);
                }
                catch (Exception ex)
                {
                    MessageBox.Show($"Error updating delivery: {ex.Message}", "Database Error",
                        MessageBoxButton.OK, MessageBoxImage.Error);
                }
            }
        }

        #endregion

        #region Common Actions

        private async void RefreshBtn_Click(object sender, RoutedEventArgs e)
        {
            await LoadDeliveriesFromDatabaseAsync();
            ApplyFilters();
            await UpdateStatisticsAsync();
            await LoadComboBoxesAsync();

            MessageBox.Show("Data refreshed successfully!", "Refresh", MessageBoxButton.OK, MessageBoxImage.Information);
        }

        #endregion

        #region Auto-Generate Deliveries (Called externally)

        /// <summary>
        /// Creates a delivery automatically when a Sales Order is created.
        /// This method should be called from SalesOrdersManagementView when a new order is saved.
        /// </summary>
        public static DeliveryModel CreateDeliveryForSalesOrder(int salesOrderId, string retailerName, int deliveredById, string deliveredByName)
        {
            return new DeliveryModel
            {
                SalesOrderId = salesOrderId,
                DealId = null,
                SourceType = "Sales Order",
                SourceDisplay = $"Order #{salesOrderId}",
                RetailerName = retailerName,
                DeliveryDate = DateTime.Now,
                Status = "Pending",
                DeliveredById = deliveredById,
                DeliveredByName = deliveredByName
            };
        }

        /// <summary>
        /// Creates a delivery automatically when a Deal is created.
        /// This method should be called from DealManagementView when a new deal is saved.
        /// </summary>
        public static DeliveryModel CreateDeliveryForDeal(int dealId, string dealName, string retailerName, int deliveredById, string deliveredByName)
        {
            return new DeliveryModel
            {
                SalesOrderId = null,
                DealId = dealId,
                SourceType = "Deal",
                SourceDisplay = dealName,
                RetailerName = retailerName,
                DeliveryDate = DateTime.Now,
                Status = "Pending",
                DeliveredById = deliveredById,
                DeliveredByName = deliveredByName
            };
        }

        #endregion
    }

    /// <summary>
    /// Delivery Model based on the entity diagram
    /// DeliveryID (INT, PK), SalesOrderID (FK), DeliveryDate, Status, DeliveredBy (FK)
    /// Status: Pending or Delivered
    /// Extended to support Deals as well
    /// </summary>
    public class DeliveryModel : INotifyPropertyChanged
    {
        private int _deliveryId;
        private int? _salesOrderId;
        private int? _dealId;
        private string _sourceType = string.Empty;
        private string _sourceDisplay = string.Empty;
        private string _retailerName = string.Empty;
        private DateTime _deliveryDate;
        private string _status = string.Empty;
        private int _deliveredById;
        private string _deliveredByName = string.Empty;

        public int DeliveryId
        {
            get => _deliveryId;
            set { _deliveryId = value; OnPropertyChanged(); }
        }

        public int? SalesOrderId
        {
            get => _salesOrderId;
            set { _salesOrderId = value; OnPropertyChanged(); }
        }

        public int? DealId
        {
            get => _dealId;
            set { _dealId = value; OnPropertyChanged(); }
        }

        public string SourceType
        {
            get => _sourceType;
            set { _sourceType = value; OnPropertyChanged(); }
        }

        public string SourceDisplay
        {
            get => _sourceDisplay;
            set { _sourceDisplay = value; OnPropertyChanged(); }
        }

        public string RetailerName
        {
            get => _retailerName;
            set { _retailerName = value; OnPropertyChanged(); }
        }

        public DateTime DeliveryDate
        {
            get => _deliveryDate;
            set { _deliveryDate = value; OnPropertyChanged(); }
        }

        public string Status
        {
            get => _status;
            set { _status = value; OnPropertyChanged(); }
        }

        public int DeliveredById
        {
            get => _deliveredById;
            set { _deliveredById = value; OnPropertyChanged(); }
        }

        public string DeliveredByName
        {
            get => _deliveredByName;
            set { _deliveredByName = value; OnPropertyChanged(); }
        }

        public event PropertyChangedEventHandler? PropertyChanged;

        protected virtual void OnPropertyChanged([CallerMemberName] string? propertyName = null)
        {
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
        }
    }

    public class DeliveryPersonInfo
    {
        public int PersonId { get; set; }
        public string Name { get; set; } = string.Empty;
    }
}
