using System;
using System.Collections.Generic;
using System.Windows;
using System.Windows.Media;
using FactoryManagmentSystem.Models;

namespace FactoryManagmentSystem.Views
{
    public partial class MaterialCheckDialog : Window
    {
        public MaterialCheckDialog(
            List<MaterialCheckResult> materials,
            string overallStatus,
            string statusMessage,
            OrderApproval orderInfo)
        {
            InitializeComponent();
            
            // Set order information
            txtOrderInfo.Text = $"{orderInfo.OrderType} #{orderInfo.OrderID} - {orderInfo.CustomerName}";
            
            // Set overall status
            txtOverallStatus.Text = overallStatus;
            txtStatusMessage.Text = statusMessage;
            
            if (overallStatus == "Sufficient")
            {
                borderOverallStatus.Background = new SolidColorBrush((Color)ColorConverter.ConvertFromString("#D4EDDA"));
                borderOverallStatus.BorderBrush = new SolidColorBrush((Color)ColorConverter.ConvertFromString("#28A745"));
                borderOverallStatus.BorderThickness = new Thickness(2);
                txtStatusIcon.Text = "✔";
                txtStatusIcon.Foreground = new SolidColorBrush((Color)ColorConverter.ConvertFromString("#28A745"));
                txtOverallStatus.Foreground = new SolidColorBrush((Color)ColorConverter.ConvertFromString("#155724"));
                txtStatusMessage.Foreground = new SolidColorBrush((Color)ColorConverter.ConvertFromString("#155724"));
            }
            else
            {
                borderOverallStatus.Background = new SolidColorBrush((Color)ColorConverter.ConvertFromString("#F8D7DA"));
                borderOverallStatus.BorderBrush = new SolidColorBrush((Color)ColorConverter.ConvertFromString("#DC3545"));
                borderOverallStatus.BorderThickness = new Thickness(2);
                txtStatusIcon.Text = "✖";
                txtStatusIcon.Foreground = new SolidColorBrush((Color)ColorConverter.ConvertFromString("#DC3545"));
                txtOverallStatus.Foreground = new SolidColorBrush((Color)ColorConverter.ConvertFromString("#721C24"));
                txtStatusMessage.Foreground = new SolidColorBrush((Color)ColorConverter.ConvertFromString("#721C24"));
            }
            
            // Bind materials to DataGrid
            dgMaterials.ItemsSource = materials;
        }

        private void BtnClose_Click(object sender, RoutedEventArgs e)
        {
            this.Close();
        }
    }
}
