using System.Configuration;
using System.Data;
using System.Windows;

namespace FactoryManagmentSystem;

/// <summary>
/// Interaction logic for App.xaml
/// </summary>
public partial class App : Application
{
    protected override void OnStartup(StartupEventArgs e)
    {
        // Handle unhandled exceptions
        AppDomain.CurrentDomain.UnhandledException += (sender, args) =>
        {
            Exception ex = (Exception)args.ExceptionObject;
            MessageBox.Show($"Unhandled Exception:\n\n{ex.Message}\n\nStack Trace:\n{ex.StackTrace}", 
                "Application Error", MessageBoxButton.OK, MessageBoxImage.Error);
        };

        this.DispatcherUnhandledException += (sender, args) =>
        {
            MessageBox.Show($"UI Exception:\n\n{args.Exception.Message}\n\nStack Trace:\n{args.Exception.StackTrace}", 
                "UI Error", MessageBoxButton.OK, MessageBoxImage.Error);
            args.Handled = true;
        };

        try
        {
            base.OnStartup(e);
        }
        catch (Exception ex)
        {
            MessageBox.Show($"Startup Exception:\n\n{ex.Message}\n\nStack Trace:\n{ex.StackTrace}", 
                "Startup Error", MessageBoxButton.OK, MessageBoxImage.Error);
        }
    }
}

