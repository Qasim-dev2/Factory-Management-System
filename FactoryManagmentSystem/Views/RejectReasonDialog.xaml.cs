using System;
using System.Windows;
using System.Windows.Controls;
using FactoryManagmentSystem.Models;

namespace FactoryManagmentSystem.Views
{
    public partial class RejectReasonDialog : Window
    {
        private const int MaxCharacters = 500;

        public string RejectionReason { get; private set; }

        public RejectReasonDialog(OrderApproval orderInfo)
        {
            InitializeComponent();
            
            // Set order information
            txtOrderInfo.Text = $"{orderInfo.OrderType} #{orderInfo.OrderID} - {orderInfo.CustomerName}";
            
            // Set focus to text box
            txtRejectionReason.Focus();
        }

        private void TxtRejectionReason_TextChanged(object sender, TextChangedEventArgs e)
        {
            string text = txtRejectionReason.Text;
            
            // Enforce character limit
            if (text.Length > MaxCharacters)
            {
                txtRejectionReason.Text = text.Substring(0, MaxCharacters);
                txtRejectionReason.CaretIndex = MaxCharacters;
                return;
            }
            
            // Update character count
            txtCharCount.Text = text.Length.ToString();
            
            // Enable/disable reject button
            btnReject.IsEnabled = !string.IsNullOrWhiteSpace(text) && text.Length >= 10;
        }

        private void QuickReason_Click(object sender, RoutedEventArgs e)
        {
            Button btn = sender as Button;
            if (btn != null)
            {
                string quickReason = btn.Content.ToString();
                
                // Add to existing text or replace if empty
                if (string.IsNullOrWhiteSpace(txtRejectionReason.Text))
                {
                    txtRejectionReason.Text = quickReason + ": ";
                }
                else
                {
                    txtRejectionReason.Text += (txtRejectionReason.Text.EndsWith(" ") ? "" : " ") + quickReason + " ";
                }
                
                // Set focus and caret to end
                txtRejectionReason.Focus();
                txtRejectionReason.CaretIndex = txtRejectionReason.Text.Length;
            }
        }

        private void BtnReject_Click(object sender, RoutedEventArgs e)
        {
            string reason = txtRejectionReason.Text.Trim();
            
            if (string.IsNullOrWhiteSpace(reason))
            {
                MessageBox.Show("Please provide a rejection reason.", 
                    "Reason Required", MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }
            
            if (reason.Length < 10)
            {
                MessageBox.Show("Rejection reason must be at least 10 characters.", 
                    "Reason Too Short", MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }
            
            RejectionReason = reason;
            this.DialogResult = true;
            this.Close();
        }

        private void BtnCancel_Click(object sender, RoutedEventArgs e)
        {
            this.DialogResult = false;
            this.Close();
        }
    }
}
