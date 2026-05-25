using System.Collections.Generic;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Media;
using System.Data.SqlClient;
using System;

namespace FactoryManagmentSystem;

public partial class DeliveryPersonDashboard : Window
{
    private Button? _activeButton;
    private readonly string _connectionString = "Server=QASIM\\SQLEXPRESS;Database=GarmentsFactoryDB;Trusted_Connection=True;TrustServerCertificate=True;";

    public DeliveryPersonDashboard()
    {
        InitializeComponent();
        WelcomeText.Text = $"Welcome, {UserSession.FullName}";
        _activeButton = DashboardBtn;
        
        // Load statistics
        LoadDashboardStatistics();
    }
    
    private async void LoadDashboardStatistics()
    {
        try
        {
            using (SqlConnection conn = new SqlConnection(_connectionString))
            {
                await conn.OpenAsync();
                
                // Get Total Deliveries count
                using (SqlCommand cmd = new SqlCommand(@"
                    SELECT COUNT(*) FROM Delivery", conn))
                {
                    var result = await cmd.ExecuteScalarAsync();
                    TotalDeliveriesCount.Text = result?.ToString() ?? "0";
                }
                
                // Get Completed Deliveries count (all completed)
                using (SqlCommand cmd = new SqlCommand(@"
                    SELECT COUNT(*) FROM Delivery 
                    WHERE Status = 'Delivered'", conn))
                {
                    var result = await cmd.ExecuteScalarAsync();
                    CompletedDeliveriesCount.Text = result?.ToString() ?? "0";
                }
                
                // Get Pending Deliveries count
                using (SqlCommand cmd = new SqlCommand(@"
                    SELECT COUNT(*) FROM Delivery 
                    WHERE Status = 'Pending'", conn))
                {
                    var result = await cmd.ExecuteScalarAsync();
                    PendingDeliveriesCount.Text = result?.ToString() ?? "0";
                }
                
                // Get My Completed Deliveries count (for this specific delivery person)
                using (SqlCommand cmd = new SqlCommand(@"
                    SELECT COUNT(*) FROM Delivery 
                    WHERE Status = 'Delivered' 
                    AND DeliveredBy = @EmployeeID", conn))
                {
                    cmd.Parameters.AddWithValue("@EmployeeID", UserSession.EmployeeID);
                    var result = await cmd.ExecuteScalarAsync();
                    MyCompletedDeliveriesCount.Text = result?.ToString() ?? "0";
                }
                
                // Update the label to show employee name
                MyDeliveriesLabel.Text = $"Deliveries by {UserSession.FullName}";
            }
        }
        catch (Exception ex)
        {
            MessageBox.Show($"Error loading statistics: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
        }
    }

    private void NavigationButton_Click(object sender, RoutedEventArgs e)
    {
        if (sender is Button clickedButton)
        {
            // Reset previous active button
            if (_activeButton != null)
            {
                _activeButton.Style = (Style)FindResource("SidebarButton");
            }
            
            // Set new active button
            clickedButton.Style = (Style)FindResource("ActiveSidebarButton");
            _activeButton = clickedButton;
            
            // Get the content type from button tag
            string contentType = clickedButton.Tag?.ToString() ?? "Dashboard";
            
            // Update page content
            UpdateMainContent(contentType);
        }
    }
    
    private void ClearAllContent()
    {
        // Hide all XAML-defined content areas
        DashboardContent.Visibility = Visibility.Collapsed;
        OtherContent.Visibility = Visibility.Collapsed;
        
        // Clear any dynamically added modules
        ClearDynamicModules();
    }
    
    private void ClearDynamicModules()
    {
        // Remove only dynamically added UserControls
        var elementsToRemove = new List<UIElement>();
        
        foreach (UIElement child in MainContentArea.Children)
        {
            if (child is UserControl && 
                child != DashboardContent && 
                child != OtherContent)
            {
                elementsToRemove.Add(child);
            }
        }
        
        foreach (var element in elementsToRemove)
        {
            MainContentArea.Children.Remove(element);
        }
    }
    
    private void UpdateMainContent(string contentType)
    {
        // Clear all content first
        ClearAllContent();
        
        // Update page title
        PageTitle.Text = contentType;
        
        switch (contentType)
        {
            case "Dashboard":
                PageTitle.Text = "Dashboard";
                PageSubtitle.Text = "Overview of your delivery activities";
                DashboardContent.Visibility = Visibility.Visible;
                break;
                
            case "Deliveries":
                PageTitle.Text = "Handle Deliveries";
                PageSubtitle.Text = "View and manage your assigned deliveries";
                ShowDeliveryManagement();
                break;
                
            default:
                ShowOtherContent("Under Development", "This module is currently under development.");
                break;
        }
    }
    
    private void ShowOtherContent(string title, string description)
    {
        OtherContent.Visibility = Visibility.Visible;
        ContentTitle.Text = title;
        ContentDescription.Text = description;
    }

    private void ShowDeliveryManagement()
    {
        // Show the Delivery Management View
        var deliveryView = new Views.DeliveryManagementView();
        MainContentArea.Children.Add(deliveryView);
    }

    private void QuickAction_ViewDeliveries(object sender, RoutedEventArgs e)
    {
        // Navigate to Deliveries module
        DeliveriesBtn.RaiseEvent(new RoutedEventArgs(Button.ClickEvent));
    }

    private void LogoutButton_Click(object sender, RoutedEventArgs e)
    {
        UserSession.Clear();
        var loginWindow = new MainWindow();
        loginWindow.Show();
        this.Close();
    }
}
