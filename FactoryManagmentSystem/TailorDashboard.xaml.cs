using System.Collections.Generic;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Media;

namespace FactoryManagmentSystem;

public partial class TailorDashboard : Window
{
    private Button? _activeButton;

    public TailorDashboard()
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
                PageSubtitle.Text = "Overview of your tailor activities";
                DashboardContent.Visibility = Visibility.Visible;
                break;
                
            case "TailorTasks":
                PageTitle.Text = "My Tasks";
                PageSubtitle.Text = "View and manage your assigned tasks";
                ShowTailorTasksManagement();
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

    private void ShowTailorTasksManagement()
    {
        // Show the Tailor Tasks View Control
        var tailorTasksView = new Views.TailorTasksViewControl();
        MainContentArea.Children.Add(tailorTasksView);
    }

    private void QuickAction_ViewTasks(object sender, RoutedEventArgs e)
    {
        // Navigate to Tailor Tasks module
        TailorTasksBtn.RaiseEvent(new RoutedEventArgs(Button.ClickEvent));
    }

    private void LogoutButton_Click(object sender, RoutedEventArgs e)
    {
        UserSession.Clear();
        var loginWindow = new MainWindow();
        loginWindow.Show();
        this.Close();
    }
}
