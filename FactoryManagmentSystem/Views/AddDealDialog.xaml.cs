using System;
using System.ComponentModel;
using System.Windows;

namespace FactoryManagmentSystem.Views
{
    public partial class AddDealDialog : Window, INotifyPropertyChanged
    {
        public event PropertyChangedEventHandler? PropertyChanged;

        // Properties for data binding
        public string DealTitle { get; set; } = "";
        public string DealType { get; set; } = "";
        public string ClientName { get; set; } = "";
        public string ContactPerson { get; set; } = "";
        public string Email { get; set; } = "";
        public string Phone { get; set; } = "";
        public string DealValue { get; set; } = "";
        public string Currency { get; set; } = "USD ($)";
        public string Priority { get; set; } = "Medium";
        public string Duration { get; set; } = "";
        public DateTime? StartDate { get; set; } = DateTime.Today;
        public DateTime? EndDate { get; set; }
        public string Description { get; set; } = "";
        public string Terms { get; set; } = "";
        public string PaymentTerms { get; set; } = "Net 30 Days";
        public string PaymentMethod { get; set; } = "Bank Transfer";
        public string Requirements { get; set; } = "";
        public string AssignedManager { get; set; } = "";
        public string Status { get; set; } = "Draft";

        public new bool DialogResult { get; private set; } = false;

        public AddDealDialog()
        {
            try
            {
                InitializeComponent();
                InitializeDefaultValues();
                DataContext = this;
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error initializing Add Deal Dialog: {ex.Message}", "Initialization Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void InitializeDefaultValues()
        {
            try
            {
                // Set default end date to 1 year from start date
                if (StartDate.HasValue)
                {
                    EndDate = StartDate.Value.AddYears(1);
                }
                else
                {
                    StartDate = DateTime.Today;
                    EndDate = DateTime.Today.AddYears(1);
                }
            }
            catch (Exception ex)
            {
                // Handle any date initialization errors silently
                StartDate = DateTime.Today;
                EndDate = DateTime.Today.AddYears(1);
            }
        }

        private void Save_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                // Validate required fields
                if (!ValidateForm())
                {
                    return;
                }

                // Collect form data
                CollectFormData();

                // Show success message
                MessageBox.Show(
                    $"Deal '{DealTitle}' has been successfully created!\n\n" +
                    $"Client: {ClientName}\n" +
                    $"Type: {DealType}\n" +
                    $"Value: {DealValue}\n" +
                    $"Status: {Status}",
                    "Deal Created Successfully",
                    MessageBoxButton.OK,
                    MessageBoxImage.Information
                );

                DialogResult = true;
                base.DialogResult = true;
                this.Close();
            }
            catch (Exception ex)
            {
                MessageBox.Show(
                    $"Error creating deal: {ex.Message}",
                    "Error",
                    MessageBoxButton.OK,
                    MessageBoxImage.Error
                );
            }
        }

        private void Cancel_Click(object sender, RoutedEventArgs e)
        {
            var result = MessageBox.Show(
                "Are you sure you want to cancel? All entered data will be lost.",
                "Confirm Cancel",
                MessageBoxButton.YesNo,
                MessageBoxImage.Question
            );

            if (result == MessageBoxResult.Yes)
            {
                DialogResult = false;
                this.Close();
            }
        }

        private bool ValidateForm()
        {
            // Check required fields
            if (string.IsNullOrWhiteSpace(DealTitleTextBox.Text))
            {
                MessageBox.Show("Please enter a deal title.", "Validation Error", 
                    MessageBoxButton.OK, MessageBoxImage.Warning);
                DealTitleTextBox.Focus();
                return false;
            }

            if (DealTypeComboBox.SelectedItem == null)
            {
                MessageBox.Show("Please select a deal type.", "Validation Error", 
                    MessageBoxButton.OK, MessageBoxImage.Warning);
                DealTypeComboBox.Focus();
                return false;
            }

            if (string.IsNullOrWhiteSpace(ClientNameTextBox.Text))
            {
                MessageBox.Show("Please enter a client/company name.", "Validation Error", 
                    MessageBoxButton.OK, MessageBoxImage.Warning);
                ClientNameTextBox.Focus();
                return false;
            }

            // Validate email format if provided
            if (!string.IsNullOrWhiteSpace(EmailTextBox.Text))
            {
                if (!IsValidEmail(EmailTextBox.Text))
                {
                    MessageBox.Show("Please enter a valid email address.", "Validation Error", 
                        MessageBoxButton.OK, MessageBoxImage.Warning);
                    EmailTextBox.Focus();
                    return false;
                }
            }

            // Validate deal value if provided
            if (!string.IsNullOrWhiteSpace(DealValueTextBox.Text))
            {
                if (!IsValidCurrency(DealValueTextBox.Text))
                {
                    MessageBox.Show("Please enter a valid deal value (e.g., $100,000 or 100000).", "Validation Error", 
                        MessageBoxButton.OK, MessageBoxImage.Warning);
                    DealValueTextBox.Focus();
                    return false;
                }
            }

            // Validate dates
            if (StartDatePicker.SelectedDate.HasValue && EndDatePicker.SelectedDate.HasValue)
            {
                if (EndDatePicker.SelectedDate.Value <= StartDatePicker.SelectedDate.Value)
                {
                    MessageBox.Show("End date must be after start date.", "Validation Error", 
                        MessageBoxButton.OK, MessageBoxImage.Warning);
                    EndDatePicker.Focus();
                    return false;
                }
            }

            return true;
        }

        private void CollectFormData()
        {
            DealTitle = DealTitleTextBox.Text.Trim();
            DealType = ((System.Windows.Controls.ComboBoxItem)DealTypeComboBox.SelectedItem)?.Content?.ToString() ?? "";
            ClientName = ClientNameTextBox.Text.Trim();
            ContactPerson = ContactPersonTextBox.Text.Trim();
            Email = EmailTextBox.Text.Trim();
            Phone = PhoneTextBox.Text.Trim();
            DealValue = DealValueTextBox.Text.Trim();
            Currency = ((System.Windows.Controls.ComboBoxItem)CurrencyComboBox.SelectedItem)?.Content?.ToString() ?? "USD ($)";
            Priority = ((System.Windows.Controls.ComboBoxItem)PriorityComboBox.SelectedItem)?.Content?.ToString() ?? "Medium";
            Duration = DurationTextBox.Text.Trim();
            StartDate = StartDatePicker.SelectedDate;
            EndDate = EndDatePicker.SelectedDate;
            Description = DescriptionTextBox.Text.Trim();
            Terms = TermsTextBox.Text.Trim();
            PaymentTerms = ((System.Windows.Controls.ComboBoxItem)PaymentTermsComboBox.SelectedItem)?.Content?.ToString() ?? "Net 30 Days";
            PaymentMethod = ((System.Windows.Controls.ComboBoxItem)PaymentMethodComboBox.SelectedItem)?.Content?.ToString() ?? "Bank Transfer";
            Requirements = RequirementsTextBox.Text.Trim();
            AssignedManager = ((System.Windows.Controls.ComboBoxItem)ManagerComboBox.SelectedItem)?.Content?.ToString() ?? "";
            Status = ((System.Windows.Controls.ComboBoxItem)StatusComboBox.SelectedItem)?.Content?.ToString() ?? "Draft";
        }

        private bool IsValidEmail(string email)
        {
            try
            {
                var addr = new System.Net.Mail.MailAddress(email);
                return addr.Address == email;
            }
            catch
            {
                return false;
            }
        }

        private bool IsValidCurrency(string value)
        {
            // Remove common currency symbols and formatting
            string cleanValue = value.Replace("$", "").Replace(",", "").Replace(" ", "");
            
            // Try to parse as decimal
            return decimal.TryParse(cleanValue, out _);
        }

        protected virtual void OnPropertyChanged(string propertyName)
        {
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
        }

        // Event handlers for form interactions
        private void StartDatePicker_SelectedDateChanged(object sender, System.Windows.Controls.SelectionChangedEventArgs e)
        {
            // Auto-set end date to 1 year from start date if end date is not set
            if (StartDatePicker.SelectedDate.HasValue && !EndDatePicker.SelectedDate.HasValue)
            {
                EndDatePicker.SelectedDate = StartDatePicker.SelectedDate.Value.AddYears(1);
            }
        }

        private void DealValueTextBox_LostFocus(object sender, RoutedEventArgs e)
        {
            // Format currency value when user finishes editing
            if (!string.IsNullOrWhiteSpace(DealValueTextBox.Text))
            {
                string cleanValue = DealValueTextBox.Text.Replace("$", "").Replace(",", "");
                if (decimal.TryParse(cleanValue, out decimal value))
                {
                    DealValueTextBox.Text = $"${value:N0}";
                }
            }
        }

        private void Window_Loaded(object sender, RoutedEventArgs e)
        {
            // Focus on the first input field when dialog loads
            DealTitleTextBox.Focus();
            DealTitleTextBox.SelectAll();
        }
    }
}