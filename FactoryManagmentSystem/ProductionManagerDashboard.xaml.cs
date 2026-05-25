using System.Collections.Generic;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Media;

namespace FactoryManagmentSystem;

public partial class ProductionManagerDashboard : Window
{
    private Button? _activeButton;

    public ProductionManagerDashboard()
    {
        InitializeComponent();
        WelcomeText.Text = $"Production Manager: {UserSession.FullName}";
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
                PageSubtitle.Text = "Overview of production operations";
                DashboardContent.Visibility = Visibility.Visible;
                break;
                
            case "RawMaterial":
                PageTitle.Text = "Raw Material Management";
                PageSubtitle.Text = "Manage raw materials and inventory";
                ShowRawMaterialManagement();
                break;
                
            case "OrderApproval":
                PageTitle.Text = "Order Approvals";
                PageSubtitle.Text = "Review and approve production orders";
                ShowOrderApprovalManagement();
                break;
                
            case "Products":
                PageTitle.Text = "Add Product";
                PageSubtitle.Text = "Add new products to the catalog";
                ShowProductManagement();
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

    private void ShowRawMaterialManagement()
    {
        // Show the Raw Material Management View
        var rawMaterialView = new Views.RawMaterialManagementView();
        MainContentArea.Children.Add(rawMaterialView);
    }

    private void ShowOrderApprovalManagement()
    {
        // Get production manager ID from session
        // Use Employee ID 15 (Hassan Ahmed - Production Manager) as fallback
        int managerID = UserSession.EmployeeID > 0 ? UserSession.EmployeeID : 15;
        
        // Show the Order Approval View Control
        var orderApprovalView = new Views.OrderApprovalViewControl(managerID);
        MainContentArea.Children.Add(orderApprovalView);
    }

    private void ShowProductManagement()
    {
        // Show the Product Management View
        var productView = new Views.ProductManagementView();
        MainContentArea.Children.Add(productView);
    }

    private void QuickAction_RawMaterial(object sender, RoutedEventArgs e)
    {
        // Navigate to Raw Material module
        RawMaterialBtn.RaiseEvent(new RoutedEventArgs(Button.ClickEvent));
    }

    private void QuickAction_OrderApproval(object sender, RoutedEventArgs e)
    {
        // Navigate to Order Approval module
        OrderApprovalBtn.RaiseEvent(new RoutedEventArgs(Button.ClickEvent));
    }

    private void QuickAction_AddProduct(object sender, RoutedEventArgs e)
    {
        // Navigate to Products module
        ProductsBtn.RaiseEvent(new RoutedEventArgs(Button.ClickEvent));
    }

    private void LogoutButton_Click(object sender, RoutedEventArgs e)
    {
        UserSession.Clear();
        var loginWindow = new MainWindow();
        loginWindow.Show();
        this.Close();
    }
}
