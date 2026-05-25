using System;
using System.Collections.ObjectModel;
using System.Linq;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using FactoryManagmentSystem.Models;
using FactoryManagmentSystem.Services;

namespace FactoryManagmentSystem.Views
{
    public partial class EmployeeManagementView : UserControl
    {
        private readonly IOwnerEmployeeDataService _employeeDataService;
        private int? _selectedEmployeeId;
        private int? _selectedUpdateEmployeeId;
        private int? _selectedDeleteEmployeeId;
        private int? _selectedPromoteEmployeeId;
        
        // Browse Employees Properties
        private ObservableCollection<BrowseEmployeeItem> _allEmployees;
        private ObservableCollection<BrowseEmployeeItem> _filteredEmployees;
        private string _searchText = "";
        private int _currentPage = 1;
        private int _pageSize = 15;
        private int _totalEmployees = 0;
        private int _totalPages = 1;

        public EmployeeManagementView()
        {
            InitializeComponent();
            _employeeDataService = new OwnerEmployeeDataService();
            LoadInitialData();
        }

        private async void LoadInitialData()
        {
            try
            {
                await LoadDepartmentsAndRoles();
                await LoadEmployeesForComboBoxes();
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error loading initial data: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private async Task LoadDepartmentsAndRoles()
        {
            try
            {
                // Load departments
                var departments = await _employeeDataService.GetDepartmentsAsync();
                
                // Populate Add form dropdowns
                AddDepartmentComboBox.Items.Clear();
                foreach (var dept in departments)
                {
                    AddDepartmentComboBox.Items.Add(new ComboBoxItem { Content = dept });
                }

                // Populate Update form dropdowns
                UpdateDepartmentComboBox.Items.Clear();
                foreach (var dept in departments)
                {
                    UpdateDepartmentComboBox.Items.Add(new ComboBoxItem { Content = dept });
                }

                // Load roles
                var roles = await _employeeDataService.GetEmployeeRolesAsync();
                
                // Populate Add form position dropdown (exclude Owner)
                AddPositionComboBox.Items.Clear();
                foreach (var role in roles)
                {
                    if (role != "Owner")  // Exclude Owner - hardcoded credentials only
                    {
                        AddPositionComboBox.Items.Add(new ComboBoxItem { Content = role });
                    }
                }

                // Populate Update form position dropdown (exclude Owner)
                UpdatePositionComboBox.Items.Clear();
                foreach (var role in roles)
                {
                    if (role != "Owner")  // Exclude Owner - hardcoded credentials only
                    {
                        UpdatePositionComboBox.Items.Add(new ComboBoxItem { Content = role });
                    }
                }

                // Populate Promote form new role dropdown (exclude Owner)
                PromoteNewRoleComboBox.Items.Clear();
                foreach (var role in roles)
                {
                    if (role != "Owner")  // Exclude Owner - hardcoded credentials only
                    {
                        PromoteNewRoleComboBox.Items.Add(new ComboBoxItem { Content = role });
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error loading departments and roles: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private async Task LoadEmployeesForComboBoxes()
        {
            try
            {
                var result = await _employeeDataService.GetEmployeesAsync(1, 1000, "");
                var employees = result.Data;
                
                // Clear all employee combo boxes
                UpdateEmployeeComboBox.Items.Clear();
                DeleteEmployeeComboBox.Items.Clear();
                PromoteEmployeeComboBox.Items.Clear();
                
                foreach (var employee in employees)
                {
                    var employeeDisplay = $"{employee.FullName} ({employee.Position})";
                    
                    UpdateEmployeeComboBox.Items.Add(new ComboBoxItem 
                    { 
                        Content = employeeDisplay, 
                        Tag = employee.EmployeeId 
                    });
                    
                    DeleteEmployeeComboBox.Items.Add(new ComboBoxItem 
                    { 
                        Content = employeeDisplay, 
                        Tag = employee.EmployeeId 
                    });
                    
                    PromoteEmployeeComboBox.Items.Add(new ComboBoxItem 
                    { 
                        Content = employeeDisplay, 
                        Tag = employee.EmployeeId 
                    });
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error loading employees: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        // Navigation Methods
        private void ShowAddEmployee_Click(object sender, RoutedEventArgs e)
        {
            MainMenuGrid.Visibility = Visibility.Collapsed;
            AddEmployeeGrid.Visibility = Visibility.Visible;
            UpdateEmployeeGrid.Visibility = Visibility.Collapsed;
            DeleteEmployeeGrid.Visibility = Visibility.Collapsed;
            PromoteEmployeeGrid.Visibility = Visibility.Collapsed;
        }

        private void ShowUpdateEmployee_Click(object sender, RoutedEventArgs e)
        {
            MainMenuGrid.Visibility = Visibility.Collapsed;
            AddEmployeeGrid.Visibility = Visibility.Collapsed;
            UpdateEmployeeGrid.Visibility = Visibility.Visible;
            DeleteEmployeeGrid.Visibility = Visibility.Collapsed;
            PromoteEmployeeGrid.Visibility = Visibility.Collapsed;
        }

        private void ShowDeleteEmployee_Click(object sender, RoutedEventArgs e)
        {
            MainMenuGrid.Visibility = Visibility.Collapsed;
            AddEmployeeGrid.Visibility = Visibility.Collapsed;
            UpdateEmployeeGrid.Visibility = Visibility.Collapsed;
            DeleteEmployeeGrid.Visibility = Visibility.Visible;
            PromoteEmployeeGrid.Visibility = Visibility.Collapsed;
        }

        private void ShowPromoteEmployee_Click(object sender, RoutedEventArgs e)
        {
            MainMenuGrid.Visibility = Visibility.Collapsed;
            AddEmployeeGrid.Visibility = Visibility.Collapsed;
            UpdateEmployeeGrid.Visibility = Visibility.Collapsed;
            DeleteEmployeeGrid.Visibility = Visibility.Collapsed;
            PromoteEmployeeGrid.Visibility = Visibility.Visible;
        }

        private async void ShowBrowseEmployees_Click(object sender, RoutedEventArgs e)
        {
            MainMenuGrid.Visibility = Visibility.Collapsed;
            AddEmployeeGrid.Visibility = Visibility.Collapsed;
            UpdateEmployeeGrid.Visibility = Visibility.Collapsed;
            DeleteEmployeeGrid.Visibility = Visibility.Collapsed;
            PromoteEmployeeGrid.Visibility = Visibility.Collapsed;
            BrowseEmployeesGrid.Visibility = Visibility.Visible;
            
            await LoadBrowseEmployeesData();
        }

        private void BackToMain_Click(object sender, RoutedEventArgs e)
        {
            MainMenuGrid.Visibility = Visibility.Visible;
            AddEmployeeGrid.Visibility = Visibility.Collapsed;
            UpdateEmployeeGrid.Visibility = Visibility.Collapsed;
            DeleteEmployeeGrid.Visibility = Visibility.Collapsed;
            PromoteEmployeeGrid.Visibility = Visibility.Collapsed;
            BrowseEmployeesGrid.Visibility = Visibility.Collapsed;
            
            // Clear all forms
            ClearAddForm();
            ClearUpdateForm();
            ClearDeleteForm();
            ClearPromoteForm();
        }

        // Add Employee Methods
        private async void AddEmployee_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                if (!ValidateAddForm())
                    return;

                var employeeData = new EmployeeFormData
                {
                    FullName = $"{AddFirstNameTextBox.Text.Trim()} {AddLastNameTextBox.Text.Trim()}",
                    Email = AddEmailTextBox.Text.Trim(),
                    ContactNumber = AddPhoneTextBox.Text.Trim(),
                    Department = ((ComboBoxItem)AddDepartmentComboBox.SelectedItem)?.Content?.ToString() ?? "",
                    Position = ((ComboBoxItem)AddPositionComboBox.SelectedItem)?.Content?.ToString() ?? "",
                    Role = ((ComboBoxItem)AddPositionComboBox.SelectedItem)?.Content?.ToString() ?? "",
                    Salary = decimal.Parse(AddSalaryTextBox.Text.Trim()),
                    HireDate = AddHireDatePicker.SelectedDate ?? DateTime.Now,
                    Address = AddAddressTextBox.Text.Trim(),
                    CNIC = AddCNICTextBox.Text.Trim(),
                    EmergencyContact = AddEmergencyContactTextBox.Text.Trim(),
                    Username = AddUsernameTextBox.Text.Trim(),
                    PIN = AddPINTextBox.Text.Trim()
                };

                var createdEmployee = await _employeeDataService.CreateEmployeeAsync(employeeData);

                if (createdEmployee != null)
                {
                    MessageBox.Show($"✓ Employee added successfully!\n\nName: {createdEmployee.FullName}\nUsername: {employeeData.Username}\nPIN: {employeeData.PIN}", 
                                    "Success", MessageBoxButton.OK, MessageBoxImage.Information);
                    ClearAddForm();
                    await LoadEmployeesForComboBoxes(); // Refresh employee lists
                }
                else
                {
                    MessageBox.Show("Failed to add employee. Please try again.", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error adding employee: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private bool ValidateAddForm()
        {
            // Validate First Name
            if (string.IsNullOrWhiteSpace(AddFirstNameTextBox.Text))
            {
                MessageBox.Show("❌ Please enter first name.", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                AddFirstNameTextBox.Focus();
                return false;
            }

            // Validate Last Name
            if (string.IsNullOrWhiteSpace(AddLastNameTextBox.Text))
            {
                MessageBox.Show("❌ Please enter last name.", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                AddLastNameTextBox.Focus();
                return false;
            }

            // Validate CNIC
            if (string.IsNullOrWhiteSpace(AddCNICTextBox.Text))
            {
                MessageBox.Show("❌ Please enter CNIC number.", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                AddCNICTextBox.Focus();
                return false;
            }

            if (AddCNICTextBox.Text.Length < 13)
            {
                MessageBox.Show("❌ CNIC must be at least 13 digits.\nFormat: 12345-1234567-1", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                AddCNICTextBox.Focus();
                return false;
            }

            // Validate Email
            if (string.IsNullOrWhiteSpace(AddEmailTextBox.Text))
            {
                MessageBox.Show("❌ Please enter email address.", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                AddEmailTextBox.Focus();
                return false;
            }

            if (!AddEmailTextBox.Text.Contains("@") || !AddEmailTextBox.Text.Contains("."))
            {
                MessageBox.Show("❌ Please enter a valid email address.\nFormat: example@domain.com", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                AddEmailTextBox.Focus();
                return false;
            }

            // Validate Phone
            if (string.IsNullOrWhiteSpace(AddPhoneTextBox.Text))
            {
                MessageBox.Show("❌ Please enter phone number.", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                AddPhoneTextBox.Focus();
                return false;
            }

            if (AddPhoneTextBox.Text.Length < 10)
            {
                MessageBox.Show("❌ Phone number must be at least 10 digits.", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                AddPhoneTextBox.Focus();
                return false;
            }

            // Validate Address
            if (string.IsNullOrWhiteSpace(AddAddressTextBox.Text))
            {
                MessageBox.Show("❌ Please enter address.", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                AddAddressTextBox.Focus();
                return false;
            }

            // Validate Emergency Contact
            if (string.IsNullOrWhiteSpace(AddEmergencyContactTextBox.Text))
            {
                MessageBox.Show("❌ Please enter emergency contact number.", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                AddEmergencyContactTextBox.Focus();
                return false;
            }

            // Validate Department
            if (AddDepartmentComboBox.SelectedItem == null)
            {
                MessageBox.Show("❌ Please select a department.", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                AddDepartmentComboBox.Focus();
                return false;
            }

            // Validate Position
            if (AddPositionComboBox.SelectedItem == null)
            {
                MessageBox.Show("❌ Please select a position/role.", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                AddPositionComboBox.Focus();
                return false;
            }

            // Validate Salary
            if (string.IsNullOrWhiteSpace(AddSalaryTextBox.Text))
            {
                MessageBox.Show("❌ Please enter salary amount.", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                AddSalaryTextBox.Focus();
                return false;
            }

            if (!decimal.TryParse(AddSalaryTextBox.Text, out decimal salary))
            {
                MessageBox.Show("❌ Salary must be a valid number.\nExample: 30000", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                AddSalaryTextBox.Focus();
                return false;
            }

            if (salary < 25000)
            {
                MessageBox.Show("❌ Minimum salary must be Rs. 25,000 or above.\nCurrent value: Rs. " + salary.ToString("N0"), 
                                "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                AddSalaryTextBox.Focus();
                return false;
            }

            // Validate Hire Date
            if (AddHireDatePicker.SelectedDate == null)
            {
                MessageBox.Show("❌ Please select hire/join date.", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                AddHireDatePicker.Focus();
                return false;
            }

            if (AddHireDatePicker.SelectedDate > DateTime.Now)
            {
                MessageBox.Show("❌ Hire date cannot be in the future.", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                AddHireDatePicker.Focus();
                return false;
            }

            // Validate Username
            if (string.IsNullOrWhiteSpace(AddUsernameTextBox.Text))
            {
                MessageBox.Show("❌ Please enter username for login.", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                AddUsernameTextBox.Focus();
                return false;
            }

            if (AddUsernameTextBox.Text.Length < 3)
            {
                MessageBox.Show("❌ Username must be at least 3 characters long.", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                AddUsernameTextBox.Focus();
                return false;
            }

            // Validate PIN
            if (string.IsNullOrWhiteSpace(AddPINTextBox.Text))
            {
                MessageBox.Show("❌ Please enter 4-digit PIN.", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                AddPINTextBox.Focus();
                return false;
            }

            if (AddPINTextBox.Text.Length != 4)
            {
                MessageBox.Show("❌ PIN must be exactly 4 digits.\nExample: 1234", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                AddPINTextBox.Focus();
                return false;
            }

            if (!int.TryParse(AddPINTextBox.Text, out _))
            {
                MessageBox.Show("❌ PIN must contain only numbers (0-9).", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                AddPINTextBox.Focus();
                return false;
            }

            return true;
        }

        private void ClearAddForm()
        {
            AddFirstNameTextBox.Clear();
            AddLastNameTextBox.Clear();
            AddCNICTextBox.Clear();
            AddEmailTextBox.Clear();
            AddPhoneTextBox.Clear();
            AddAddressTextBox.Clear();
            AddEmergencyContactTextBox.Clear();
            AddDepartmentComboBox.SelectedItem = null;
            AddPositionComboBox.SelectedItem = null;
            AddSalaryTextBox.Clear();
            AddHireDatePicker.SelectedDate = null;
            AddUsernameTextBox.Clear();
            AddPINTextBox.Clear();
        }

        // Update Employee Methods
        private async void UpdateEmployeeComboBox_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            if (UpdateEmployeeComboBox.SelectedItem is ComboBoxItem selectedItem && selectedItem.Tag != null)
            {
                try
                {
                    _selectedUpdateEmployeeId = (int)selectedItem.Tag;
                    var employee = await _employeeDataService.GetEmployeeByIdAsync(_selectedUpdateEmployeeId.Value);

                    if (employee != null)
                    {
                        // Split full name into first and last name
                        var nameParts = employee.FullName.Split(' ', 2);
                        UpdateFirstNameTextBox.Text = nameParts[0];
                        UpdateLastNameTextBox.Text = nameParts.Length > 1 ? nameParts[1] : "";
                        
                        UpdateCNICTextBox.Text = employee.CNIC ?? "";
                        UpdateEmailTextBox.Text = employee.Email;
                        UpdatePhoneTextBox.Text = employee.ContactNumber ?? "";
                        UpdateAddressTextBox.Text = employee.Address ?? "";
                        UpdateEmergencyContactTextBox.Text = employee.EmergencyContact ?? "";
                        UpdateSalaryTextBox.Text = employee.Salary.ToString();
                        UpdateHireDatePicker.SelectedDate = employee.HireDate;
                        UpdateUsernameTextBox.Text = employee.Username ?? "";
                        UpdatePINTextBox.Text = employee.PIN ?? "";

                        // Set department
                        foreach (ComboBoxItem item in UpdateDepartmentComboBox.Items)
                        {
                            if (item.Content.ToString() == employee.Department)
                            {
                                UpdateDepartmentComboBox.SelectedItem = item;
                                break;
                            }
                        }

                        // Set position
                        foreach (ComboBoxItem item in UpdatePositionComboBox.Items)
                        {
                            if (item.Content.ToString() == employee.Position)
                            {
                                UpdatePositionComboBox.SelectedItem = item;
                                break;
                            }
                        }
                    }
                }
                catch (Exception ex)
                {
                    MessageBox.Show($"Error loading employee details: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
                }
            }
        }

        private async void UpdateEmployee_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                if (_selectedUpdateEmployeeId == null)
                {
                    MessageBox.Show("Please select an employee to update.", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                    return;
                }

                if (!ValidateUpdateForm())
                    return;

                var employeeData = new EmployeeFormData
                {
                    EmployeeId = _selectedUpdateEmployeeId.Value,
                    FullName = $"{UpdateFirstNameTextBox.Text.Trim()} {UpdateLastNameTextBox.Text.Trim()}",
                    Email = UpdateEmailTextBox.Text.Trim(),
                    ContactNumber = UpdatePhoneTextBox.Text.Trim(),
                    Department = ((ComboBoxItem)UpdateDepartmentComboBox.SelectedItem)?.Content?.ToString() ?? "",
                    Position = ((ComboBoxItem)UpdatePositionComboBox.SelectedItem)?.Content?.ToString() ?? "",
                    Role = ((ComboBoxItem)UpdatePositionComboBox.SelectedItem)?.Content?.ToString() ?? "",
                    Salary = decimal.Parse(UpdateSalaryTextBox.Text.Trim()),
                    HireDate = UpdateHireDatePicker.SelectedDate ?? DateTime.Now,
                    Address = UpdateAddressTextBox.Text.Trim(),
                    CNIC = UpdateCNICTextBox.Text.Trim(),
                    EmergencyContact = UpdateEmergencyContactTextBox.Text.Trim(),
                    Username = UpdateUsernameTextBox.Text.Trim(),
                    PIN = UpdatePINTextBox.Text.Trim()
                };

                var updatedEmployee = await _employeeDataService.UpdateEmployeeAsync(_selectedUpdateEmployeeId.Value, employeeData);

                if (updatedEmployee != null)
                {
                    MessageBox.Show("Employee updated successfully!", "Success", MessageBoxButton.OK, MessageBoxImage.Information);
                    ClearUpdateForm();
                    await LoadEmployeesForComboBoxes(); // Refresh employee lists
                }
                else
                {
                    MessageBox.Show("Failed to update employee. Please try again.", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error updating employee: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private bool ValidateUpdateForm()
        {
            if (string.IsNullOrWhiteSpace(UpdateFirstNameTextBox.Text))
            {
                MessageBox.Show("Please enter first name.", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                return false;
            }

            if (string.IsNullOrWhiteSpace(UpdateLastNameTextBox.Text))
            {
                MessageBox.Show("Please enter last name.", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                return false;
            }

            if (string.IsNullOrWhiteSpace(UpdateEmailTextBox.Text))
            {
                MessageBox.Show("Please enter email address.", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                return false;
            }

            if (UpdateDepartmentComboBox.SelectedItem == null)
            {
                MessageBox.Show("Please select a department.", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                return false;
            }

            if (UpdatePositionComboBox.SelectedItem == null)
            {
                MessageBox.Show("Please select a position.", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                return false;
            }

            if (string.IsNullOrWhiteSpace(UpdateSalaryTextBox.Text) || !decimal.TryParse(UpdateSalaryTextBox.Text, out _))
            {
                MessageBox.Show("Please enter a valid salary.", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                return false;
            }

            return true;
        }

        private void ClearUpdateForm()
        {
            UpdateEmployeeComboBox.SelectedItem = null;
            UpdateFirstNameTextBox.Clear();
            UpdateLastNameTextBox.Clear();
            UpdateCNICTextBox.Clear();
            UpdateEmailTextBox.Clear();
            UpdatePhoneTextBox.Clear();
            UpdateAddressTextBox.Clear();
            UpdateEmergencyContactTextBox.Clear();
            UpdateDepartmentComboBox.SelectedItem = null;
            UpdatePositionComboBox.SelectedItem = null;
            UpdateSalaryTextBox.Clear();
            UpdateHireDatePicker.SelectedDate = null;
            UpdateUsernameTextBox.Clear();
            UpdatePINTextBox.Clear();
            _selectedUpdateEmployeeId = null;
        }

        // Delete Employee Methods
        private async void DeleteEmployeeComboBox_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            if (DeleteEmployeeComboBox.SelectedItem is ComboBoxItem selectedItem && selectedItem.Tag != null)
            {
                try
                {
                    _selectedDeleteEmployeeId = (int)selectedItem.Tag;
                    var employee = await _employeeDataService.GetEmployeeByIdAsync(_selectedDeleteEmployeeId.Value);

                    if (employee != null)
                    {
                        DeleteEmployeeDetails.Text = $"Name: {employee.FullName}\n" +
                                                   $"Email: {employee.Email}\n" +
                                                   $"Department: {employee.Department}\n" +
                                                   $"Position: {employee.Position}\n" +
                                                   $"Salary: Rs. {employee.Salary:N0}\n" +
                                                   $"Hire Date: {employee.HireDate:yyyy-MM-dd}";

                        DeleteEmployeeDetailsPanel.Visibility = Visibility.Visible;
                        DeleteEmployeeButton.IsEnabled = true;
                    }
                }
                catch (Exception ex)
                {
                    MessageBox.Show($"Error loading employee details: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
                }
            }
            else
            {
                DeleteEmployeeDetailsPanel.Visibility = Visibility.Collapsed;
                DeleteEmployeeButton.IsEnabled = false;
            }
        }

        private async void DeleteEmployee_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                if (_selectedDeleteEmployeeId == null)
                {
                    MessageBox.Show("Please select an employee to delete.", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                    return;
                }

                var result = MessageBox.Show("Are you sure you want to delete this employee? This action cannot be undone.", 
                                           "Confirm Delete", MessageBoxButton.YesNo, MessageBoxImage.Warning);

                if (result == MessageBoxResult.Yes)
                {
                    var success = await _employeeDataService.DeleteEmployeeAsync(_selectedDeleteEmployeeId.Value);

                    if (success)
                    {
                        MessageBox.Show("Employee deleted successfully!", "Success", MessageBoxButton.OK, MessageBoxImage.Information);
                        ClearDeleteForm();
                        await LoadEmployeesForComboBoxes(); // Refresh employee lists
                    }
                    else
                    {
                        MessageBox.Show("Failed to delete employee. Please try again.", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error deleting employee: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void ClearDeleteForm()
        {
            DeleteEmployeeComboBox.SelectedItem = null;
            DeleteEmployeeDetailsPanel.Visibility = Visibility.Collapsed;
            DeleteEmployeeButton.IsEnabled = false;
            _selectedDeleteEmployeeId = null;
        }

        // Promote/Demote Employee Methods
        private async void PromoteEmployeeComboBox_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            if (PromoteEmployeeComboBox.SelectedItem is ComboBoxItem selectedItem && selectedItem.Tag != null)
            {
                try
                {
                    _selectedPromoteEmployeeId = (int)selectedItem.Tag;
                    var employee = await _employeeDataService.GetEmployeeByIdAsync(_selectedPromoteEmployeeId.Value);

                    if (employee != null)
                    {
                        PromoteCurrentRoleText.Text = employee.Position;
                        PromoteNewSalaryTextBox.Text = employee.Salary.ToString();

                        PromoteCurrentRolePanel.Visibility = Visibility.Visible;
                        PromoteNewRolePanel.Visibility = Visibility.Visible;
                        PromoteNewSalaryPanel.Visibility = Visibility.Visible;
                        PromoteReasonPanel.Visibility = Visibility.Visible;
                        PromoteButtonsPanel.Visibility = Visibility.Visible;
                    }
                }
                catch (Exception ex)
                {
                    MessageBox.Show($"Error loading employee details: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
                }
            }
            else
            {
                PromoteCurrentRolePanel.Visibility = Visibility.Collapsed;
                PromoteNewRolePanel.Visibility = Visibility.Collapsed;
                PromoteNewSalaryPanel.Visibility = Visibility.Collapsed;
                PromoteReasonPanel.Visibility = Visibility.Collapsed;
                PromoteButtonsPanel.Visibility = Visibility.Collapsed;
            }
        }

        private async void PromoteEmployee_Click(object sender, RoutedEventArgs e)
        {
            await PerformPromotionAction(true);
        }

        private async void DemoteEmployee_Click(object sender, RoutedEventArgs e)
        {
            await PerformPromotionAction(false);
        }

        private async Task PerformPromotionAction(bool isPromotion)
        {
            try
            {
                if (_selectedPromoteEmployeeId == null)
                {
                    MessageBox.Show("Please select an employee.", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                    return;
                }

                if (PromoteNewRoleComboBox.SelectedItem == null)
                {
                    MessageBox.Show("Please select a new role.", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                    return;
                }

                if (string.IsNullOrWhiteSpace(PromoteNewSalaryTextBox.Text) || !decimal.TryParse(PromoteNewSalaryTextBox.Text, out decimal newSalary))
                {
                    MessageBox.Show("Please enter a valid new salary.", "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                    return;
                }

                var newRole = ((ComboBoxItem)PromoteNewRoleComboBox.SelectedItem).Content.ToString() ?? "";
                var reason = PromoteReasonTextBox.Text.Trim();

                var actionText = isPromotion ? "promote" : "demote";
                var result = MessageBox.Show($"Are you sure you want to {actionText} this employee to {newRole}?", 
                                           $"Confirm {(isPromotion ? "Promotion" : "Demotion")}", 
                                           MessageBoxButton.YesNo, MessageBoxImage.Question);

                if (result == MessageBoxResult.Yes)
                {
                    bool success;
                    if (isPromotion)
                    {
                        success = await _employeeDataService.PromoteEmployeeAsync(_selectedPromoteEmployeeId.Value, newRole, newSalary, reason);
                    }
                    else
                    {
                        success = await _employeeDataService.DemoteEmployeeAsync(_selectedPromoteEmployeeId.Value, newRole, newSalary, reason);
                    }

                    if (success)
                    {
                        MessageBox.Show($"Employee {(isPromotion ? "promoted" : "demoted")} successfully!", "Success", MessageBoxButton.OK, MessageBoxImage.Information);
                        ClearPromoteForm();
                        await LoadEmployeesForComboBoxes(); // Refresh employee lists
                    }
                    else
                    {
                        MessageBox.Show($"Failed to {actionText} employee. Please try again.", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error performing action: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void ClearPromoteForm()
        {
            PromoteEmployeeComboBox.SelectedItem = null;
            PromoteNewRoleComboBox.SelectedItem = null;
            PromoteNewSalaryTextBox.Clear();
            PromoteReasonTextBox.Clear();
            PromoteCurrentRolePanel.Visibility = Visibility.Collapsed;
            PromoteNewRolePanel.Visibility = Visibility.Collapsed;
            PromoteNewSalaryPanel.Visibility = Visibility.Collapsed;
            PromoteReasonPanel.Visibility = Visibility.Collapsed;
            PromoteButtonsPanel.Visibility = Visibility.Collapsed;
            _selectedPromoteEmployeeId = null;
        }

        // Browse Employees Methods
        private async Task LoadBrowseEmployeesData()
        {
            try
            {
                _allEmployees = new ObservableCollection<BrowseEmployeeItem>();
                _filteredEmployees = new ObservableCollection<BrowseEmployeeItem>();
                
                // Load all employees
                var result = await _employeeDataService.GetEmployeesAsync(1, 1000, "");
                var employees = result.Data;
                
                foreach (var emp in employees)
                {
                    var browseItem = new BrowseEmployeeItem
                    {
                        EmployeeId = emp.EmployeeId.ToString(),
                        FullName = emp.FullName,
                        Email = emp.Email ?? "N/A",
                        Phone = emp.ContactNumber ?? "N/A",
                        Department = emp.Department,
                        Role = emp.Role,
                        JoinDate = emp.HireDate,
                        Initials = GetInitials(emp.FullName)
                    };
                    _allEmployees.Add(browseItem);
                }
                
                // Load filter options
                await LoadBrowseFilterOptions();
                
                // Initialize display
                RefreshBrowseDisplay();
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error loading employees: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }
        
        private async Task LoadBrowseFilterOptions()
        {
            try
            {
                // Load departments for filter
                var departments = await _employeeDataService.GetDepartmentsAsync();
                DepartmentFilterCombo.Items.Clear();
                DepartmentFilterCombo.Items.Add(new ComboBoxItem { Content = "All Departments" });
                foreach (var dept in departments)
                {
                    DepartmentFilterCombo.Items.Add(new ComboBoxItem { Content = dept });
                }
                DepartmentFilterCombo.SelectedIndex = 0;
                
                // Load roles for filter
                var roles = await _employeeDataService.GetEmployeeRolesAsync();
                PositionFilterCombo.Items.Clear();
                PositionFilterCombo.Items.Add(new ComboBoxItem { Content = "All Positions" });
                foreach (var role in roles)
                {
                    PositionFilterCombo.Items.Add(new ComboBoxItem { Content = role });
                }
                PositionFilterCombo.SelectedIndex = 0;
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error loading filter options: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }
        
        private string GetInitials(string fullName)
        {
            if (string.IsNullOrWhiteSpace(fullName))
                return "NA";
                
            var parts = fullName.Trim().Split(' ', StringSplitOptions.RemoveEmptyEntries);
            if (parts.Length == 0)
                return "NA";
            if (parts.Length == 1)
                return parts[0].Substring(0, Math.Min(2, parts[0].Length)).ToUpper();
            
            return (parts[0].Substring(0, 1) + parts[parts.Length - 1].Substring(0, 1)).ToUpper();
        }
        
        private void RefreshBrowseDisplay()
        {
            ApplyFiltersAndSort();
            UpdatePagination();
            DisplayCurrentPage();
            UpdateEmployeeCount();
        }
        
        private void ApplyFiltersAndSort()
        {
            var filtered = _allEmployees.AsEnumerable();
            
            // Apply search filter
            if (!string.IsNullOrEmpty(_searchText) && _searchText != "Search employees by name, ID, or department...")
            {
                filtered = filtered.Where(e =>
                    e.FullName.Contains(_searchText, StringComparison.OrdinalIgnoreCase) ||
                    e.EmployeeId.Contains(_searchText, StringComparison.OrdinalIgnoreCase) ||
                    e.Department.Contains(_searchText, StringComparison.OrdinalIgnoreCase) ||
                    e.Role.Contains(_searchText, StringComparison.OrdinalIgnoreCase) ||
                    e.Email.Contains(_searchText, StringComparison.OrdinalIgnoreCase));
            }
            
            // Apply department filter
            if (DepartmentFilterCombo.SelectedIndex > 0)
            {
                var selectedDept = ((ComboBoxItem)DepartmentFilterCombo.SelectedItem).Content.ToString();
                filtered = filtered.Where(e => e.Department == selectedDept);
            }
            
            // Apply position filter
            if (PositionFilterCombo.SelectedIndex > 0)
            {
                var selectedPos = ((ComboBoxItem)PositionFilterCombo.SelectedItem).Content.ToString();
                filtered = filtered.Where(e => e.Role == selectedPos);
            }
            
            // Apply sorting
            switch (SortByCombo.SelectedIndex)
            {
                case 1: // Name A-Z
                    filtered = filtered.OrderBy(e => e.FullName);
                    break;
                case 2: // Name Z-A
                    filtered = filtered.OrderByDescending(e => e.FullName);
                    break;
                case 3: // Join Date New
                    filtered = filtered.OrderByDescending(e => e.JoinDate);
                    break;
                case 4: // Join Date Old
                    filtered = filtered.OrderBy(e => e.JoinDate);
                    break;
                case 5: // Department
                    filtered = filtered.OrderBy(e => e.Department);
                    break;
                case 6: // Position
                    filtered = filtered.OrderBy(e => e.Role);
                    break;
                default: // Employee ID
                    filtered = filtered.OrderBy(e => e.EmployeeId);
                    break;
            }
            
            _filteredEmployees = new ObservableCollection<BrowseEmployeeItem>(filtered);
            _totalEmployees = _filteredEmployees.Count;
            _totalPages = Math.Max(1, (int)Math.Ceiling((double)_totalEmployees / _pageSize));
            
            // Ensure current page is valid
            if (_currentPage > _totalPages)
                _currentPage = _totalPages;
        }
        
        private void UpdatePagination()
        {
            // Update pagination controls
            FirstPageBtn.IsEnabled = _currentPage > 1;
            PrevPageBtn.IsEnabled = _currentPage > 1;
            NextPageBtn.IsEnabled = _currentPage < _totalPages;
            LastPageBtn.IsEnabled = _currentPage < _totalPages;
            
            CurrentPageLabel.Text = $"Page {_currentPage} of {_totalPages}";
            
            var startIndex = (_currentPage - 1) * _pageSize + 1;
            var endIndex = Math.Min(_currentPage * _pageSize, _totalEmployees);
            PageInfoLabel.Text = _totalEmployees > 0 ? 
                $"Showing {startIndex}-{endIndex} of {_totalEmployees} employees" : 
                "No employees found";
        }
        
        private void DisplayCurrentPage()
        {
            var startIndex = (_currentPage - 1) * _pageSize;
            var pageItems = _filteredEmployees.Skip(startIndex).Take(_pageSize).ToList();
            
            EmployeeItemsControl.ItemsSource = pageItems;
        }
        
        private void UpdateEmployeeCount()
        {
            TotalEmployeesLabel.Text = $"({_totalEmployees} employees found)";
        }
        
        // Event Handlers for Browse Employees
        private void SearchEmployeeBox_GotFocus(object sender, RoutedEventArgs e)
        {
            if (SearchEmployeeBox.Text == "Search employees by name, ID, or department...")
            {
                SearchEmployeeBox.Text = "";
            }
        }
        
        private void SearchEmployeeBox_LostFocus(object sender, RoutedEventArgs e)
        {
            if (string.IsNullOrWhiteSpace(SearchEmployeeBox.Text))
            {
                SearchEmployeeBox.Text = "Search employees by name, ID, or department...";
            }
        }
        
        private void SearchEmployeeBox_TextChanged(object sender, TextChangedEventArgs e)
        {
            if (SearchEmployeeBox.Text != "Search employees by name, ID, or department...")
            {
                _searchText = SearchEmployeeBox.Text;
                _currentPage = 1;
                RefreshBrowseDisplay();
            }
        }
        
        private async void RefreshListBtn_Click(object sender, RoutedEventArgs e)
        {
            await LoadBrowseEmployeesData();
        }
        
        private void FilterChanged(object sender, SelectionChangedEventArgs e)
        {
            if (_allEmployees != null)
            {
                _currentPage = 1;
                RefreshBrowseDisplay();
            }
        }
        
        private void SortChanged(object sender, SelectionChangedEventArgs e)
        {
            if (_allEmployees != null)
            {
                RefreshBrowseDisplay();
            }
        }
        
        // Pagination Event Handlers
        private void FirstPageBtn_Click(object sender, RoutedEventArgs e)
        {
            _currentPage = 1;
            RefreshBrowseDisplay();
        }
        
        private void PrevPageBtn_Click(object sender, RoutedEventArgs e)
        {
            if (_currentPage > 1)
            {
                _currentPage--;
                RefreshBrowseDisplay();
            }
        }
        
        private void NextPageBtn_Click(object sender, RoutedEventArgs e)
        {
            if (_currentPage < _totalPages)
            {
                _currentPage++;
                RefreshBrowseDisplay();
            }
        }
        
        private void LastPageBtn_Click(object sender, RoutedEventArgs e)
        {
            _currentPage = _totalPages;
            RefreshBrowseDisplay();
        }
        
        // Individual Employee Action Handlers
        private async void ViewEmployeeDetailsBtn_Click(object sender, RoutedEventArgs e)
        {
            if (sender is Button button && button.Tag is string employeeId)
            {
                try
                {
                    var employee = await _employeeDataService.GetEmployeeByIdAsync(int.Parse(employeeId));
                    if (employee != null)
                    {
                        MessageBox.Show($"Employee Details:\n\n" +
                                      $"Name: {employee.FullName}\n" +
                                      $"ID: {employee.EmployeeId}\n" +
                                      $"Email: {employee.Email}\n" +
                                      $"Phone: {employee.ContactNumber ?? "N/A"}\n" +
                                      $"Department: {employee.Department}\n" +
                                      $"Position: {employee.Role}\n" +
                                      $"Salary: Rs. {employee.Salary:N0}\n" +
                                      $"Hire Date: {employee.HireDate:dd/MM/yyyy}",
                                      "Employee Details", MessageBoxButton.OK, MessageBoxImage.Information);
                    }
                }
                catch (Exception ex)
                {
                    MessageBox.Show($"Error loading employee details: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
                }
            }
        }
        
        private void EditEmployeeBtn_Click(object sender, RoutedEventArgs e)
        {
            if (sender is Button button && button.Tag is string employeeId)
            {
                // Switch to update employee view and pre-select the employee
                ShowUpdateEmployee_Click(sender, e);
                
                // Find and select the employee in the combo box
                foreach (ComboBoxItem item in UpdateEmployeeComboBox.Items)
                {
                    if (item.Tag?.ToString() == employeeId)
                    {
                        UpdateEmployeeComboBox.SelectedItem = item;
                        break;
                    }
                }
            }
        }
        
        private async void DeleteSingleEmployeeBtn_Click(object sender, RoutedEventArgs e)
        {
            if (sender is Button button && button.Tag is string employeeId)
            {
                try
                {
                    var employee = await _employeeDataService.GetEmployeeByIdAsync(int.Parse(employeeId));
                    if (employee != null)
                    {
                        var result = MessageBox.Show(
                            $"Are you sure you want to delete this employee?\n\n" +
                            $"Employee: {employee.FullName}\n" +
                            $"ID: {employee.EmployeeId}\n" +
                            $"Position: {employee.Role}\n" +
                            $"Department: {employee.Department}\n\n" +
                            $"This action cannot be undone.",
                            "Confirm Employee Deletion",
                            MessageBoxButton.YesNo,
                            MessageBoxImage.Warning);
                        
                        if (result == MessageBoxResult.Yes)
                        {
                            var success = await _employeeDataService.DeleteEmployeeAsync(int.Parse(employeeId));
                            if (success)
                            {
                                MessageBox.Show($"Employee {employee.FullName} has been successfully deleted.", "Employee Deleted", MessageBoxButton.OK, MessageBoxImage.Information);
                                await LoadBrowseEmployeesData(); // Refresh the list
                                await LoadEmployeesForComboBoxes(); // Refresh combo boxes in other forms
                            }
                            else
                            {
                                MessageBox.Show("Failed to delete employee. Please try again.", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
                            }
                        }
                    }
                }
                catch (Exception ex)
                {
                    MessageBox.Show($"Error deleting employee: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
                }
            }
        }
    }
    
    // Helper class for Browse Employees display
    public class BrowseEmployeeItem
    {
        public string EmployeeId { get; set; } = "";
        public string FullName { get; set; } = "";
        public string Email { get; set; } = "";
        public string Phone { get; set; } = "";
        public string Department { get; set; } = "";
        public string Role { get; set; } = "";
        public DateTime JoinDate { get; set; }
        public string Initials { get; set; } = "";
    }
}