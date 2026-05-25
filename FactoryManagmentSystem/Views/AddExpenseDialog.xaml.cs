using System;
using System.Windows;
using System.Windows.Controls;

namespace FactoryManagmentSystem.Views
{
    public partial class NewExpenseDialog : Window
    {
        public DateTime ExpenseDate { get; private set; }
        public decimal Amount { get; private set; }
        public string? Category { get; private set; }
        public string? Description { get; private set; }
        public string? PaidTo { get; private set; }

        public NewExpenseDialog()
        {
            InitializeComponent();
            dpExpenseDate.SelectedDate = DateTime.Today;
        }

        private void Save_Click(object sender, RoutedEventArgs e)
        {
            // Validate
            if (dpExpenseDate.SelectedDate == null)
            {
                MessageBox.Show("Please select expense date.", "Validation", 
                    MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }

            if (!decimal.TryParse(txtAmount.Text, out decimal amount) || amount <= 0)
            {
                MessageBox.Show("Please enter valid amount.", "Validation", 
                    MessageBoxButton.OK, MessageBoxImage.Warning);
                txtAmount.Focus();
                return;
            }

            // Set properties
            ExpenseDate = dpExpenseDate.SelectedDate.Value;
            Amount = amount;
            Category = (cmbCategory.SelectedItem as ComboBoxItem)?.Content?.ToString();
            Description = string.IsNullOrWhiteSpace(txtDescription.Text) ? null : txtDescription.Text.Trim();
            PaidTo = string.IsNullOrWhiteSpace(txtPaidTo.Text) ? null : txtPaidTo.Text.Trim();

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
