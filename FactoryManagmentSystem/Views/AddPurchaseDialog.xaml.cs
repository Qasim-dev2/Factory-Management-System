using System;
using System.Windows;
using System.Windows.Controls;

namespace FactoryManagmentSystem.Views
{
    public partial class NewPurchaseDialog : Window
    {
        public string MaterialName { get; private set; } = string.Empty;
        public DateTime PurchaseDate { get; private set; }
        public decimal Quantity { get; private set; }
        public string Unit { get; private set; } = string.Empty;
        public decimal UnitPrice { get; private set; }
        public string? SupplierName { get; private set; }

        public NewPurchaseDialog()
        {
            InitializeComponent();
            dpPurchaseDate.SelectedDate = DateTime.Today;
        }

        private void Save_Click(object sender, RoutedEventArgs e)
        {
            // Validate
            if (string.IsNullOrWhiteSpace(txtMaterialName.Text))
            {
                MessageBox.Show("Please enter material name.", "Validation", 
                    MessageBoxButton.OK, MessageBoxImage.Warning);
                txtMaterialName.Focus();
                return;
            }

            if (dpPurchaseDate.SelectedDate == null)
            {
                MessageBox.Show("Please select purchase date.", "Validation", 
                    MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }

            if (!decimal.TryParse(txtQuantity.Text, out decimal qty) || qty <= 0)
            {
                MessageBox.Show("Please enter valid quantity.", "Validation", 
                    MessageBoxButton.OK, MessageBoxImage.Warning);
                txtQuantity.Focus();
                return;
            }

            if (!decimal.TryParse(txtUnitPrice.Text, out decimal price) || price <= 0)
            {
                MessageBox.Show("Please enter valid unit price.", "Validation", 
                    MessageBoxButton.OK, MessageBoxImage.Warning);
                txtUnitPrice.Focus();
                return;
            }

            // Set properties
            MaterialName = txtMaterialName.Text.Trim();
            PurchaseDate = dpPurchaseDate.SelectedDate.Value;
            Quantity = qty;
            Unit = (cmbUnit.SelectedItem as ComboBoxItem)?.Content?.ToString() ?? "Pieces";
            UnitPrice = price;
            SupplierName = string.IsNullOrWhiteSpace(txtSupplierName.Text) ? null : txtSupplierName.Text.Trim();

            DialogResult = true;
            Close();
        }

        private void Cancel_Click(object sender, RoutedEventArgs e)
        {
            DialogResult = false;
            Close();
        }
    }
}
