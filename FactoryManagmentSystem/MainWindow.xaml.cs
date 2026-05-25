using System.Text;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;
using System.Windows.Media.Animation;
using System.Data.SqlClient;

namespace FactoryManagmentSystem;

/// <summary>
/// Interaction logic for MainWindow.xaml (Login Page)
/// </summary>
public partial class MainWindow : Window
{
    private readonly string _connectionString = "Server=QASIM\\SQLEXPRESS;Database=GarmentsFactoryDB;Trusted_Connection=True;TrustServerCertificate=True;";
    
    public MainWindow()
    {
        InitializeComponent();
        this.KeyDown += MainWindow_KeyDown;
        Loaded += MainWindow_Loaded;
    }
    
    private void MainWindow_Loaded(object sender, RoutedEventArgs e)
    {
        // Trigger fade-in animation
        var storyboard = this.FindResource("FadeInAnimation") as Storyboard;
        storyboard?.Begin();
        
        // Focus on role dropdown
        RoleComboBox.Focus();
    }

    private void MainWindow_KeyDown(object sender, KeyEventArgs e)
    {
        // Allow Enter key to trigger login
        if (e.Key == Key.Enter)
        {
            LoginButton_Click(sender, e);
        }
        // Allow Escape key to close application
        else if (e.Key == Key.Escape)
        {
            CloseButton_Click(sender, e);
        }
    }



    private void RoleComboBox_SelectionChanged(object sender, System.Windows.Controls.SelectionChangedEventArgs e)
    {
        if (RoleComboBox.SelectedItem != null)
        {
            UsernameComboBox.Items.Clear();
            PinComboBox.Items.Clear();
            
            ComboBoxItem? selectedRoleItem = RoleComboBox.SelectedItem as ComboBoxItem;
            string roleText = selectedRoleItem?.Content?.ToString() ?? "";
            
            // Remove emoji from role (first part before space, then rest is role)
            string role = roleText.Length > 2 ? roleText.Substring(roleText.IndexOf(' ') + 1).Trim() : roleText;
            
            LoadUsernamesForRole(role);
        }
    }
    
    private void UsernameComboBox_SelectionChanged(object sender, System.Windows.Controls.SelectionChangedEventArgs e)
    {
        if (UsernameComboBox.SelectedItem != null)
        {
            PinComboBox.Items.Clear();
            
            ComboBoxItem? selectedUsername = UsernameComboBox.SelectedItem as ComboBoxItem;
            string username = selectedUsername?.Tag?.ToString() ?? "";
            
            LoadPinForUsername(username);
        }
    }
    
    private async void LoadUsernamesForRole(string role)
    {
        UsernameComboBox.Items.Clear();
        
        if (role == "Owner")
        {
            var item = new ComboBoxItem 
            { 
                Content = "owner", 
                Tag = "owner",
                Foreground = new SolidColorBrush(Color.FromRgb(45, 52, 54)),
                FontSize = 15,
                FontWeight = FontWeights.Medium,
                Padding = new Thickness(12)
            };
            UsernameComboBox.Items.Add(item);
        }
        else
        {
            // Load all usernames from database for this role
            try
            {
                using (SqlConnection conn = new SqlConnection(_connectionString))
                using (SqlCommand cmd = new SqlCommand(@"
                    SELECT e.Username, e.FirstName + ' ' + e.LastName AS FullName
                    FROM Employee e
                    JOIN EmployeeRole r ON e.RoleID = r.RoleID
                    WHERE r.RoleName = @Role AND e.IsActive = 1 AND e.Username IS NOT NULL
                    ORDER BY e.FirstName", conn))
                {
                    cmd.Parameters.AddWithValue("@Role", role);
                    
                    await conn.OpenAsync();
                    
                    using (var reader = await cmd.ExecuteReaderAsync())
                    {
                        while (await reader.ReadAsync())
                        {
                            string username = reader.GetString(0);
                            string fullName = reader.GetString(1);
                            
                            var item = new ComboBoxItem 
                            { 
                                Content = $"{username} ({fullName})",
                                Tag = username,
                                Foreground = new SolidColorBrush(Color.FromRgb(45, 52, 54)),
                                FontSize = 15,
                                FontWeight = FontWeights.Medium,
                                Padding = new Thickness(12)
                            };
                            UsernameComboBox.Items.Add(item);
                        }
                    }
                }
                
                if (UsernameComboBox.Items.Count == 0)
                {
                    ShowStatusMessage($"No active users found for {role} role.", true);
                }
            }
            catch (Exception ex)
            {
                ShowStatusMessage($"Error loading usernames: {ex.Message}", true);
            }
        }
    }
    
    private async void LoadPinForUsername(string username)
    {
        PinComboBox.Items.Clear();
        
        if (username == "owner")
        {
            var item = new ComboBoxItem 
            { 
                Content = "0000",
                Tag = "0000",
                Foreground = new SolidColorBrush(Color.FromRgb(45, 52, 54)),
                FontSize = 15,
                FontWeight = FontWeights.Medium,
                Padding = new Thickness(12)
            };
            PinComboBox.Items.Add(item);
            PinComboBox.SelectedItem = item;
        }
        else
        {
            // Load PIN from database for this username
            try
            {
                using (SqlConnection conn = new SqlConnection(_connectionString))
                using (SqlCommand cmd = new SqlCommand(@"
                    SELECT PIN FROM Employee 
                    WHERE Username = @Username AND IsActive = 1", conn))
                {
                    cmd.Parameters.AddWithValue("@Username", username);
                    
                    await conn.OpenAsync();
                    
                    var pin = await cmd.ExecuteScalarAsync();
                    
                    if (pin != null && pin != DBNull.Value)
                    {
                        string pinValue = pin.ToString();
                        var item = new ComboBoxItem 
                        { 
                            Content = pinValue,
                            Tag = pinValue,
                            Foreground = new SolidColorBrush(Color.FromRgb(45, 52, 54)),
                            FontSize = 15,
                            FontWeight = FontWeights.Medium,
                            Padding = new Thickness(12)
                        };
                        PinComboBox.Items.Add(item);
                        PinComboBox.SelectedItem = item;
                    }
                }
            }
            catch (Exception ex)
            {
                ShowStatusMessage($"Error loading PIN: {ex.Message}", true);
            }
        }
    }
    
    private async void LoginButton_Click(object sender, RoutedEventArgs e)
    {
        // Clear previous status messages
        StatusMessage.Visibility = Visibility.Collapsed;

        // Validate inputs
        if (RoleComboBox.SelectedItem == null)
        {
            ShowStatusMessage("⚠️ Please select a role.", true);
            return;
        }

        if (UsernameComboBox.SelectedItem == null)
        {
            ShowStatusMessage("⚠️ Please select a username.", true);
            return;
        }

        if (PinComboBox.SelectedItem == null)
        {
            ShowStatusMessage("⚠️ Please select a PIN.", true);
            return;
        }

        // Get selected values
        ComboBoxItem? selectedRoleItem = RoleComboBox.SelectedItem as ComboBoxItem;
        string roleText = selectedRoleItem?.Content?.ToString() ?? "";
        // Remove emoji from role (first part before space, then rest is role)
        string selectedRole = roleText.Length > 2 ? roleText.Substring(roleText.IndexOf(' ') + 1).Trim() : roleText;
        
        ComboBoxItem? selectedUsernameItem = UsernameComboBox.SelectedItem as ComboBoxItem;
        string username = selectedUsernameItem?.Tag?.ToString() ?? "";
        
        ComboBoxItem? selectedPinItem = PinComboBox.SelectedItem as ComboBoxItem;
        string pin = selectedPinItem?.Tag?.ToString() ?? "";

        // Show loading message
        ShowStatusMessage("🔄 Authenticating...", false);
        LoginButton.IsEnabled = false;

        try
        {
            // Check for hardcoded owner login
            if (selectedRole == "Owner")
            {
                if (username == "owner" && pin == "0000")
                {
                    // Owner login successful (hardcoded)
                    UserSession.EmployeeID = 1; // Owner's database EmployeeID
                    UserSession.FullName = "System Owner";
                    UserSession.Role = "Owner";
                    UserSession.Username = "owner";
                    
                    ShowStatusMessage("✅ Login successful! Opening Owner Dashboard...", false);
                    await Task.Delay(500);
                    OpenDashboard("Owner");
                }
                else
                {
                    ShowStatusMessage("❌ Invalid owner credentials.", true);
                    PinComboBox.SelectedItem = null;
                }
            }
            else
            {
                // Database authentication for employees
                bool authenticated = await AuthenticateEmployeeAsync(username, pin, selectedRole);
                
                if (authenticated)
                {
                    ShowStatusMessage($"✅ Login successful! Opening {selectedRole} Dashboard...", false);
                    await Task.Delay(500);
                    OpenDashboard(UserSession.Role);
                }
                else
                {
                    ShowStatusMessage("❌ Invalid username or PIN.", true);
                    PinComboBox.SelectedItem = null;
                }
            }
        }
        catch (Exception ex)
        {
            ShowStatusMessage($"Login error: {ex.Message}", true);
        }
        finally
        {
            LoginButton.IsEnabled = true;
        }
    }

    private async Task<bool> AuthenticateEmployeeAsync(string username, string pin, string selectedRole)
    {
        try
        {
            using (SqlConnection conn = new SqlConnection(_connectionString))
            using (SqlCommand cmd = new SqlCommand("sp_AuthenticateUser", conn))
            {
                cmd.CommandType = System.Data.CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@Username", username);
                cmd.Parameters.AddWithValue("@PIN", pin);

                await conn.OpenAsync();
                
                using (var reader = await cmd.ExecuteReaderAsync())
                {
                    if (await reader.ReadAsync())
                    {
                        // Check if EmployeeID is NULL (failed login)
                        if (reader.IsDBNull(reader.GetOrdinal("EmployeeID")))
                        {
                            return false;
                        }

                        // Get role from database
                        string dbRole = reader.IsDBNull(reader.GetOrdinal("Role")) ? "" : reader.GetString(reader.GetOrdinal("Role"));
                        
                        // Verify role matches selection (normalize both)
                        string normalizedDbRole = dbRole.Replace(" ", "");
                        string normalizedSelectedRole = selectedRole.Replace(" ", "");
                        
                        if (!normalizedDbRole.Equals(normalizedSelectedRole, StringComparison.OrdinalIgnoreCase))
                        {
                            ShowStatusMessage($"⚠️ This user is a {dbRole}, not a {selectedRole}.", true);
                            return false;
                        }
                        
                        // Store user session
                        UserSession.EmployeeID = reader.GetInt32(reader.GetOrdinal("EmployeeID"));
                        UserSession.FirstName = reader.GetString(reader.GetOrdinal("FirstName"));
                        UserSession.LastName = reader.GetString(reader.GetOrdinal("LastName"));
                        UserSession.FullName = reader.GetString(reader.GetOrdinal("FullName"));
                        UserSession.Role = dbRole;
                        UserSession.Username = reader.GetString(reader.GetOrdinal("Username"));
                        UserSession.Email = reader.IsDBNull(reader.GetOrdinal("Email")) ? "" : reader.GetString(reader.GetOrdinal("Email"));
                        UserSession.Phone = reader.IsDBNull(reader.GetOrdinal("Phone")) ? "" : reader.GetString(reader.GetOrdinal("Phone"));
                        UserSession.LastLogin = reader.IsDBNull(reader.GetOrdinal("LastLogin")) ? null : (DateTime?)reader.GetDateTime(reader.GetOrdinal("LastLogin"));

                        return true;
                    }
                }
            }
        }
        catch (Exception ex)
        {
            MessageBox.Show($"Authentication error: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
        }

        return false;
    }

    private void ShowStatusMessage(string message, bool isError)
    {
        StatusMessage.Text = message;
        StatusMessageBorder.Background = new SolidColorBrush(isError ? Color.FromRgb(255, 243, 243) : Color.FromRgb(240, 255, 244));
        StatusMessageBorder.BorderBrush = new SolidColorBrush(isError ? Color.FromRgb(255, 107, 107) : Color.FromRgb(102, 126, 234));
        StatusMessage.Foreground = new SolidColorBrush(isError ? Color.FromRgb(255, 107, 107) : Color.FromRgb(76, 175, 80));
        StatusMessageBorder.Visibility = Visibility.Visible;

        // Fade in animation
        var fadeIn = new DoubleAnimation(0, 1, TimeSpan.FromMilliseconds(300));
        StatusMessageBorder.BeginAnimation(OpacityProperty, fadeIn);
    }

    private void OpenDashboard(string role)
    {
        try
        {
            Window? dashboard = role switch
            {
                "Owner" => new OwnerDashboard(),
                "Sales Person" => new SalespersonDashboard(),
                "Tailor" => new TailorDashboard(), // Renamed from EmployeeDashboard
                "Sales Manager" => new SalesManagerDashboard(), // Renamed from ManagerDashboard
                "Production Manager" => new ProductionManagerDashboard(), // New
                "Delivery Person" => new DeliveryPersonDashboard(), // New
                _ => null
            };

            if (dashboard != null)
            {
                dashboard.Show();
                this.Close();
            }
            else
            {
                ShowStatusMessage($"Dashboard for {role} is not available yet.", true);
            }
        }
        catch (Exception ex)
        {
            ShowStatusMessage($"Error opening dashboard: {ex.Message}", true);
            MessageBox.Show($"Dashboard Error:\n\n{ex.Message}\n\nStack Trace:\n{ex.StackTrace}", 
                "Error", MessageBoxButton.OK, MessageBoxImage.Error);
        }
    }

    private void CloseButton_Click(object sender, RoutedEventArgs e)
    {
        // Animate close
        var fadeOut = new DoubleAnimation(1, 0, TimeSpan.FromMilliseconds(300));
        fadeOut.Completed += (s, args) => Application.Current.Shutdown();
        this.BeginAnimation(OpacityProperty, fadeOut);
    }
}