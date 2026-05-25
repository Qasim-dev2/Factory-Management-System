using System;
using System.Windows;
using System.Windows.Controls;

namespace FactoryManagmentSystem
{
    public partial class AddRetailerDialog : Window
    {
        public bool DialogResult { get; private set; } = false;

        // Properties to hold the retailer data
        public string CompanyName { get; private set; } = "";
        public string BusinessType { get; private set; } = "";
        public string RegistrationNumber { get; private set; } = "";
        public string TaxId { get; private set; } = "";
        public string ContactPerson { get; private set; } = "";
        public string Designation { get; private set; } = "";
        public string Phone { get; private set; } = "";
        public string Email { get; private set; } = "";
        public string AlternativePhone { get; private set; } = "";
        public string Address { get; private set; } = "";
        public string City { get; private set; } = "";
        public string Province { get; private set; } = "";
        public string PostalCode { get; private set; } = "";
        public decimal CreditLimit { get; private set; } = 0;
        public string PaymentTerms { get; private set; } = "";
        public decimal DiscountPercentage { get; private set; } = 0;
        public string SalesRepresentative { get; private set; } = "";
        public string Priority { get; private set; } = "";
        public string BankName { get; private set; } = "";
        public string AccountNumber { get; private set; } = "";
        public string AccountTitle { get; private set; } = "";
        public string BranchCode { get; private set; } = "";
        public string Status { get; private set; } = "";
        public string Website { get; private set; } = "";
        public string Notes { get; private set; } = "";
        public string Tags { get; private set; } = "";

        public AddRetailerDialog()
        {
            try
            {
                InitializeComponent();
                
                // Set default values
                BusinessTypeComboBox.SelectedIndex = 0;
                CityComboBox.SelectedIndex = 0;
                ProvinceComboBox.SelectedIndex = 0;
                PaymentTermsComboBox.SelectedIndex = 0;
                PriorityComboBox.SelectedIndex = 1; // Medium
                StatusComboBox.SelectedIndex = 1; // Pending
                BankNameComboBox.SelectedIndex = 0;
                SalesRepComboBox.SelectedIndex = 0;
                
                // Set focus to first input
                CompanyNameTextBox.Focus();
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error initializing Add Retailer Dialog: {ex.Message}", "Error", 
                    MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void SaveButton_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                // Validate required fields
                if (string.IsNullOrWhiteSpace(CompanyNameTextBox.Text))
                {
                    MessageBox.Show("Company Name is required.", "Validation Error", 
                        MessageBoxButton.OK, MessageBoxImage.Warning);
                    CompanyNameTextBox.Focus();
                    return;
                }

                if (string.IsNullOrWhiteSpace(ContactPersonTextBox.Text))
                {
                    MessageBox.Show("Contact Person is required.", "Validation Error", 
                        MessageBoxButton.OK, MessageBoxImage.Warning);
                    ContactPersonTextBox.Focus();
                    return;
                }

                if (string.IsNullOrWhiteSpace(PhoneTextBox.Text))
                {
                    MessageBox.Show("Phone Number is required.", "Validation Error", 
                        MessageBoxButton.OK, MessageBoxImage.Warning);
                    PhoneTextBox.Focus();
                    return;
                }

                if (string.IsNullOrWhiteSpace(EmailTextBox.Text))
                {
                    MessageBox.Show("Email Address is required.", "Validation Error", 
                        MessageBoxButton.OK, MessageBoxImage.Warning);
                    EmailTextBox.Focus();
                    return;
                }

                if (string.IsNullOrWhiteSpace(AddressTextBox.Text))
                {
                    MessageBox.Show("Address is required.", "Validation Error", 
                        MessageBoxButton.OK, MessageBoxImage.Warning);
                    AddressTextBox.Focus();
                    return;
                }

                if (CityComboBox.SelectedItem == null)
                {
                    MessageBox.Show("City is required.", "Validation Error", 
                        MessageBoxButton.OK, MessageBoxImage.Warning);
                    CityComboBox.Focus();
                    return;
                }

                // Validate email format
                if (!IsValidEmail(EmailTextBox.Text))
                {
                    MessageBox.Show("Please enter a valid email address.", "Validation Error", 
                        MessageBoxButton.OK, MessageBoxImage.Warning);
                    EmailTextBox.Focus();
                    return;
                }

                // Collect data from form
                CollectFormData();

                DialogResult = true;
                Close();
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error saving retailer: {ex.Message}", "Error", 
                    MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void CancelButton_Click(object sender, RoutedEventArgs e)
        {
            DialogResult = false;
            Close();
        }

        private void CollectFormData()
        {
            CompanyName = CompanyNameTextBox.Text.Trim();
            BusinessType = (BusinessTypeComboBox.SelectedItem as ComboBoxItem)?.Content.ToString() ?? "";
            RegistrationNumber = RegistrationNumberTextBox.Text.Trim();
            TaxId = TaxIdTextBox.Text.Trim();
            ContactPerson = ContactPersonTextBox.Text.Trim();
            Designation = DesignationTextBox.Text.Trim();
            Phone = PhoneTextBox.Text.Trim();
            Email = EmailTextBox.Text.Trim();
            AlternativePhone = AlternativePhoneTextBox.Text.Trim();
            Address = AddressTextBox.Text.Trim();
            City = (CityComboBox.SelectedItem as ComboBoxItem)?.Content.ToString() ?? "";
            Province = (ProvinceComboBox.SelectedItem as ComboBoxItem)?.Content.ToString() ?? "";
            PostalCode = PostalCodeTextBox.Text.Trim();
            PaymentTerms = (PaymentTermsComboBox.SelectedItem as ComboBoxItem)?.Content.ToString() ?? "";
            Priority = (PriorityComboBox.SelectedItem as ComboBoxItem)?.Content.ToString() ?? "";
            BankName = (BankNameComboBox.SelectedItem as ComboBoxItem)?.Content.ToString() ?? "";
            AccountNumber = AccountNumberTextBox.Text.Trim();
            AccountTitle = AccountTitleTextBox.Text.Trim();
            BranchCode = BranchCodeTextBox.Text.Trim();
            Status = (StatusComboBox.SelectedItem as ComboBoxItem)?.Content.ToString() ?? "";
            Website = WebsiteTextBox.Text.Trim();
            Notes = NotesTextBox.Text.Trim();
            Tags = TagsTextBox.Text.Trim();
            SalesRepresentative = (SalesRepComboBox.SelectedItem as ComboBoxItem)?.Content.ToString() ?? "";

            // Parse numeric values safely
            if (decimal.TryParse(CreditLimitTextBox.Text.Trim(), out decimal creditLimit))
            {
                CreditLimit = creditLimit;
            }

            if (decimal.TryParse(DiscountPercentageTextBox.Text.Trim(), out decimal discount))
            {
                DiscountPercentage = discount;
            }
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

        // Helper method to create retailer object (for integration with the module)
        public Views.RetailerModel CreateRetailer()
        {
            return new Views.RetailerModel
            {
                RetailerId = new Random().Next(1000, 9999), // Temporary ID generation
                Name = CompanyName,
                ContactName = ContactPerson,
                Email = Email,
                Phone = Phone,
                Address = Address,
                City = City,
                Status = Status
            };
        }
    }
}