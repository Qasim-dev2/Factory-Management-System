using System.Collections.Generic;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Media;

namespace FactoryManagmentSystem;

public partial class SalespersonDashboard : Window
{
    private Button? _activeButton;

    public SalespersonDashboard()
    {
        InitializeComponent();
        WelcomeText.Text = $"Welcome, {UserSession.FullName}";
        _activeButton = DashboardBtn;
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
                PageSubtitle.Text = "Overview of your sales activities";
                DashboardContent.Visibility = Visibility.Visible;
                break;
                
            case "SalesOrders":
                PageTitle.Text = "Sales Orders";
                PageSubtitle.Text = "Manage your sales orders";
                ShowSalesOrdersManagement();
                break;
                
            case "Deals":
                PageTitle.Text = "Deals";
                PageSubtitle.Text = "Manage your deals with retailers";
                ShowDealsManagement();
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

    private void ShowSalesOrdersManagement()
    {
        // Show the Sales Orders Management View
        var salesOrdersView = new Views.SalesOrdersManagementView();
        MainContentArea.Children.Add(salesOrdersView);
    }

    private void ShowDealsManagement()
    {
        // Show the Deals Management View
        var dealsView = new Views.DealsManagementView();
        MainContentArea.Children.Add(dealsView);
    }

    private void QuickAction_CreateSalesOrder(object sender, RoutedEventArgs e)
    {
        // Navigate to Sales Orders module
        SalesOrdersBtn.RaiseEvent(new RoutedEventArgs(Button.ClickEvent));
    }

    private void QuickAction_CreateDeal(object sender, RoutedEventArgs e)
    {
        // Navigate to Deals module
        DealsBtn.RaiseEvent(new RoutedEventArgs(Button.ClickEvent));
    }

    private void LogoutButton_Click(object sender, RoutedEventArgs e)
    {
        UserSession.Clear();
        var loginWindow = new MainWindow();
        loginWindow.Show();
        this.Close();
    }
}
