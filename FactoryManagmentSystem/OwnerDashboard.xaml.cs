using System.Collections.Generic;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Media;

namespace FactoryManagmentSystem;

public partial class OwnerDashboard : Window
{
    private Button? _activeButton;

    public OwnerDashboard()
    {
        InitializeComponent();
        WelcomeText.Text = $"Owner: {UserSession.FullName}";
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
        if (EmployeeManagementContent != null)
            EmployeeManagementContent.Visibility = Visibility.Collapsed;
        if (StockContent != null)
            StockContent.Visibility = Visibility.Collapsed;
        OtherContent.Visibility = Visibility.Collapsed;
        
        // Clear any dynamically added modules
        ClearDynamicModules();
    }
    
    private void ClearDynamicModules()
    {
        // Remove only dynamically added UserControls, preserve XAML-defined elements
        var elementsToRemove = new List<UIElement>();
        
        foreach (UIElement child in MainContentArea.Children)
        {
            // Only remove UserControls that were added dynamically
            if (child is UserControl && 
                child != DashboardContent && 
                child != EmployeeManagementContent && 
                child != StockContent && 
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
        
        // Update page title and description
        PageTitle.Text = contentType;
        
        switch (contentType)
        {
            case "Dashboard":
                PageTitle.Text = "Dashboard";
                DashboardContent.Visibility = Visibility.Visible;
                break;
                
            case "Employees":
                PageTitle.Text = "Employee Management";
                ShowEmployeeManagement();
                break;
                
            case "Departments":
                PageTitle.Text = "Department Management";
                ShowDepartmentManagement();
                break;
                
            case "Products":
                PageTitle.Text = "Product Management";
                ShowProductManagement();
                break;
                
            case "Stock":
                PageTitle.Text = "Stock Management";
                ShowStockManagement();
                break;
                
            case "RawMaterial":
                PageTitle.Text = "Raw Material Management";
                ShowRawMaterialManagement();
                break;
                
            case "Deals":
                PageTitle.Text = "Deals & Contracts";
                ShowDealsManagement();
                break;
                
            case "OrderApproval":
                PageTitle.Text = "Order Approval System";
                ShowOrderApprovalManagement();
                break;
                
            case "TailorTasks":
                PageTitle.Text = "Tailor Tasks Management";
                ShowTailorTasksManagement();
                break;
                
            case "Retailers":
                PageTitle.Text = "Retailers Management";
                ShowRetailersManagement();
                break;
                
            case "SalesOrders":
                PageTitle.Text = "Sales Orders";
                ShowSalesOrdersManagement();
                break;
                
            case "Deliveries":
                PageTitle.Text = "Delivery Management";
                ShowDeliveryManagement();
                break;
                
            case "ProductionOrders":
                PageTitle.Text = "Production Order Management";
                ShowProductionOrderManagement();
                break;
                
            case "Revenue":
                PageTitle.Text = "Revenue Management";
                ShowRevenueManagement();
                break;
                
            case "Settings":
                PageTitle.Text = "System Settings";
                ShowOtherContent("System Settings", "Configure system preferences, user permissions, and application settings.");
                break;
                
            default:
                ShowOtherContent("Under Development", "This module is currently under development and will be available soon.");
                break;
        }
    }
    
    private void ShowOtherContent(string title, string description)
    {
        // Content is already cleared by UpdateMainContent
        OtherContent.Visibility = Visibility.Visible;
        ContentTitle.Text = title;
        ContentDescription.Text = description;
    }

    private void ShowEmployeeManagement()
    {
        // Content is already cleared by UpdateMainContent
        
        // Show the Database-Connected Employee Management View
        var employeeView = new Views.EmployeeManagementView();
        MainContentArea.Children.Add(employeeView);
        
        // This view is connected to the database via OwnerEmployeeDataService
    }

    private void ShowDepartmentManagement()
    {
        // Content is already cleared by UpdateMainContent
        
        // Show the Department Analytics Module (Production & Sales Analytics)
        var analyticsModule = new Views.DepartmentAnalyticsModule();
        MainContentArea.Children.Add(analyticsModule);
    }

    private void ShowProductManagement()
    {
        // Content is already cleared by UpdateMainContent
        
        // Show the Product Management View
        var productView = new Views.ProductManagementView();
        MainContentArea.Children.Add(productView);
    }

    private void ShowStockManagement()
    {
        // Content is already cleared by UpdateMainContent
        
        // Show the new Stock Management View
        var stockView = new Views.StockManagementView();
        MainContentArea.Children.Add(stockView);
    }

    private void ShowRawMaterialManagement()
    {
        // Content is already cleared by UpdateMainContent
        
        // Show the Raw Material Management View
        var rawMaterialView = new Views.RawMaterialManagementView();
        MainContentArea.Children.Add(rawMaterialView);
    }

    private void ShowDealsManagement()
    {
        // Content is already cleared by UpdateMainContent
        
        // Show the Deals Management View (redesigned)
        var dealsView = new Views.DealsManagementView();
        MainContentArea.Children.Add(dealsView);
    }

    private void ShowOrderApprovalManagement()
    {
        // Content is already cleared by UpdateMainContent
        
        // Owner has EmployeeID = 1 in database
        int approverID = UserSession.EmployeeID > 0 ? UserSession.EmployeeID : 1;
        
        // Show the Order Approval View inline (not as a window)
        var orderApprovalView = new Views.OrderApprovalViewControl(approverID);
        MainContentArea.Children.Add(orderApprovalView);
    }

    private void ShowTailorTasksManagement()
    {
        // Content is already cleared by UpdateMainContent
        
        // Show the Tailor Tasks Management View
        var tailorTasksView = new Views.TailorTasksViewControl();
        MainContentArea.Children.Add(tailorTasksView);
    }

    private void ShowRetailersManagement()
    {
        // Content is already cleared by UpdateMainContent
        
        // Show the Retailers Management View (redesigned)
        var retailersView = new Views.RetailersManagementView();
        MainContentArea.Children.Add(retailersView);
    }

    private void ShowSalesOrdersManagement()
    {
        // Show the Sales Orders Management View
        var salesOrdersView = new Views.SalesOrdersManagementView();
        MainContentArea.Children.Add(salesOrdersView);
    }

    private void ShowDeliveryManagement()
    {
        // Show the Delivery Management View
        var deliveryView = new Views.DeliveryManagementView();
        MainContentArea.Children.Add(deliveryView);
    }

    private void ShowProductionOrderManagement()
    {
        // Show the Production Order Management View
        var productionOrderView = new Views.ProductionOrderManagementView();
        MainContentArea.Children.Add(productionOrderView);
    }

    private void ShowRevenueManagement()
    {
        // Show the Simple Revenue View (date-range based)
        var revenueView = new Views.SimpleRevenueView();
        MainContentArea.Children.Add(revenueView);
    }

    private void LogoutButton_Click(object sender, RoutedEventArgs e)
    {
        UserSession.Clear();
        var loginWindow = new MainWindow();
        loginWindow.Show();
        this.Close();
    }
}