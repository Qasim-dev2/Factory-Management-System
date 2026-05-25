using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Windows;
using FactoryManagmentSystem.Models;
using FactoryManagmentSystem.Services;

namespace FactoryManagmentSystem.Views
{
    public partial class TailorSelectionDialog : Window
    {
        private readonly OrderApprovalDataService _dataService;
        private List<AvailableTailor> _availableTailors = new List<AvailableTailor>();

        public string SelectedTailorIDs { get; private set; } = string.Empty;

        public TailorSelectionDialog(OrderApproval orderInfo)
        {
            InitializeComponent();
            _dataService = new OrderApprovalDataService();
            
            // Set order information
            txtOrderInfo.Text = $"{orderInfo.OrderType} #{orderInfo.OrderID} - {orderInfo.CustomerName}";
            
            LoadAvailableTailors();
        }

        private async void LoadAvailableTailors()
        {
            try
            {
                _availableTailors = await _dataService.GetAvailableTailorsAsync();
                
                // Subscribe to PropertyChanged for each tailor
                foreach (var tailor in _availableTailors)
                {
                    tailor.PropertyChanged += Tailor_PropertyChanged;
                }
                
                dgTailors.ItemsSource = _availableTailors;
                UpdateSelectedCount();
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error loading available tailors:\n{ex.Message}", 
                    "Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void Tailor_PropertyChanged(object? sender, PropertyChangedEventArgs e)
        {
            if (e.PropertyName == "IsSelected")
            {
                UpdateSelectedCount();
            }
        }

        private void UpdateSelectedCount()
        {
            if (_availableTailors == null) return;
            
            int selectedCount = _availableTailors.Count(t => t.IsSelected);
            txtSelectedCount.Text = $"Selected Tailors: {selectedCount}";
            btnAssign.IsEnabled = selectedCount > 0;
        }

        private void BtnSelectAll_Click(object sender, RoutedEventArgs e)
        {
            foreach (var tailor in _availableTailors)
            {
                tailor.IsSelected = true;
            }
            UpdateSelectedCount();
        }

        private void BtnClearAll_Click(object sender, RoutedEventArgs e)
        {
            foreach (var tailor in _availableTailors)
            {
                tailor.IsSelected = false;
            }
            UpdateSelectedCount();
        }

        private void BtnAssign_Click(object sender, RoutedEventArgs e)
        {
            var selectedTailors = _availableTailors.Where(t => t.IsSelected).ToList();
            
            if (selectedTailors.Count == 0)
            {
                MessageBox.Show("Please select at least one tailor.", 
                    "No Selection", MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }

            // Create comma-separated list of tailor IDs
            SelectedTailorIDs = string.Join(",", selectedTailors.Select(t => t.EmployeeID));
            
            // Show confirmation
            var tailorNames = string.Join("\n  • ", selectedTailors.Select(t => t.TailorName));
            var result = MessageBox.Show(
                $"Assign the following {selectedTailors.Count} tailor(s)?\n\n  • {tailorNames}",
                "Confirm Assignment",
                MessageBoxButton.YesNo,
                MessageBoxImage.Question);
            
            if (result == MessageBoxResult.Yes)
            {
                this.DialogResult = true;
                this.Close();
            }
        }

        private void BtnCancel_Click(object sender, RoutedEventArgs e)
        {
            this.DialogResult = false;
            this.Close();
        }
    }
}
