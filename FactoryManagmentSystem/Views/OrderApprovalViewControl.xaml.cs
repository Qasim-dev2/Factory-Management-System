using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Input;
using FactoryManagmentSystem.Models;
using FactoryManagmentSystem.Services;

namespace FactoryManagmentSystem.Views
{
    public partial class OrderApprovalViewControl : UserControl
    {
        private readonly OrderApprovalDataService _dataService;
        private readonly int _ownerID;
        private List<OrderApproval> _pendingApprovals;

        public OrderApprovalViewControl(int ownerID)
        {
            InitializeComponent();
            _ownerID = ownerID;
            _dataService = new OrderApprovalDataService();
            
            Loaded += OrderApprovalViewControl_Loaded;
        }

        private async void OrderApprovalViewControl_Loaded(object sender, RoutedEventArgs e)
        {
            await LoadPendingApprovals();
        }

        private async Task LoadPendingApprovals()
        {
            try
            {
                UpdateStatusMessage("Loading pending approvals...");
                
                _pendingApprovals = await _dataService.GetPendingApprovalsAsync();
                dgPendingApprovals.ItemsSource = _pendingApprovals;
                
                txtPendingCount.Text = _pendingApprovals.Count.ToString();
                txtLastUpdate.Text = $"Last updated: {DateTime.Now:HH:mm:ss}";

                if (_pendingApprovals.Count == 0)
                {
                    txtNoData.Visibility = Visibility.Visible;
                    dgPendingApprovals.Visibility = Visibility.Collapsed;
                    UpdateStatusMessage("No pending approval requests at this time");
                }
                else
                {
                    txtNoData.Visibility = Visibility.Collapsed;
                    dgPendingApprovals.Visibility = Visibility.Visible;
                    UpdateStatusMessage($"Loaded {_pendingApprovals.Count} pending approval(s) - Select an order to review");
                }
            }
            catch (Exception ex)
            {
                ShowError($"Error loading approvals: {ex.Message}");
            }
        }

        private void DgPendingApprovals_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            bool hasSelection = dgPendingApprovals.SelectedItem != null;
            
            btnCheckMaterials.IsEnabled = hasSelection;
            btnApprove.IsEnabled = hasSelection;
            btnReject.IsEnabled = hasSelection;

            if (hasSelection)
            {
                var selected = dgPendingApprovals.SelectedItem as OrderApproval;
                UpdateStatusMessage($"Selected Order #{selected.OrderID} ({selected.OrderType}) - Customer: {selected.CustomerName}");
            }
            else
            {
                UpdateStatusMessage("Select an order to check materials or approve/reject");
            }
        }

        private void DgPendingApprovals_MouseDoubleClick(object sender, MouseButtonEventArgs e)
        {
            if (dgPendingApprovals.SelectedItem != null)
            {
                BtnCheckMaterials_Click(sender, e);
            }
        }

        private async void BtnCheckMaterials_Click(object sender, RoutedEventArgs e)
        {
            var selectedApproval = dgPendingApprovals.SelectedItem as OrderApproval;
            if (selectedApproval == null)
            {
                ShowWarning("Please select an order to check materials");
                return;
            }

            try
            {
                UpdateStatusMessage($"Checking materials for Order #{selectedApproval.OrderID}...");

                var materialCheckResult = await _dataService.CheckMaterialsForOrderAsync(
                    selectedApproval.OrderType,
                    selectedApproval.OrderID
                );

                var dialog = new MaterialCheckDialog(
                    materialCheckResult.Materials,
                    materialCheckResult.OverallStatus,
                    materialCheckResult.Message,
                    selectedApproval)
                {
                    Owner = Window.GetWindow(this)
                };

                dialog.ShowDialog();

                UpdateStatusMessage($"Material check completed for Order #{selectedApproval.OrderID}");
            }
            catch (Exception ex)
            {
                ShowError($"Error checking materials: {ex.Message}");
            }
        }

        private async void BtnApprove_Click(object sender, RoutedEventArgs e)
        {
            var selectedApproval = dgPendingApprovals.SelectedItem as OrderApproval;
            if (selectedApproval == null)
            {
                ShowWarning("Please select an order to approve");
                return;
            }

            try
            {
                // First check if materials are available
                UpdateStatusMessage($"Verifying materials for Order #{selectedApproval.OrderID}...");
                
                var materialCheckResult = await _dataService.CheckMaterialsForOrderAsync(
                    selectedApproval.OrderType,
                    selectedApproval.OrderID
                );

                // Check the overall status from the tuple result
                if (materialCheckResult.OverallStatus == "Insufficient")
                {
                    // Build detailed material shortage message
                    var insufficientMaterials = materialCheckResult.Materials
                        .Where(m => m.Status == "Insufficient")
                        .ToList();

                    var shortageDetails = new System.Text.StringBuilder();
                    shortageDetails.AppendLine("⚠️ MATERIAL SHORTAGE DETECTED\n");
                    shortageDetails.AppendLine("The following materials are insufficient:\n");

                    foreach (var material in insufficientMaterials)
                    {
                        decimal shortage = material.RequiredQuantity - material.AvailableQuantity;
                        shortageDetails.AppendLine($"• {material.MaterialName}");
                        shortageDetails.AppendLine($"  Required: {material.RequiredQuantity:N2} {material.Unit}");
                        shortageDetails.AppendLine($"  Available: {material.AvailableQuantity:N2} {material.Unit}");
                        shortageDetails.AppendLine($"  ⚠️ SHORTAGE: {shortage:N2} {material.Unit} needed\n");
                    }

                    shortageDetails.AppendLine($"\nTotal insufficient materials: {insufficientMaterials.Count}");
                    shortageDetails.AppendLine("\nTo approve this order, you need to:");
                    shortageDetails.AppendLine("1. Add the missing quantities listed above, OR");
                    shortageDetails.AppendLine("2. Proceed with partial approval (risk of production delays)");
                    shortageDetails.AppendLine("\nDo you still want to approve this order?");

                    var result = MessageBox.Show(
                        shortageDetails.ToString(),
                        "Material Shortage Warning",
                        MessageBoxButton.YesNo,
                        MessageBoxImage.Warning);

                    if (result != MessageBoxResult.Yes)
                    {
                        UpdateStatusMessage("Approval cancelled - insufficient materials");
                        return;
                    }
                }

                // Show tailor selection dialog
                var tailorDialog = new TailorSelectionDialog(selectedApproval)
                {
                    Owner = Window.GetWindow(this)
                };

                if (tailorDialog.ShowDialog() != true || string.IsNullOrEmpty(tailorDialog.SelectedTailorIDs))
                {
                    UpdateStatusMessage("Approval cancelled - no tailors selected");
                    return;
                }

                // Parse the tailor IDs from comma-separated string
                var tailorIDs = tailorDialog.SelectedTailorIDs
                    .Split(',')
                    .Select(id => int.Parse(id.Trim()))
                    .ToList();

                // Get special instructions if any
                string specialInstructions = "";  // TailorSelectionDialog doesn't expose this yet

                // Approve order and create production order
                UpdateStatusMessage($"Approving Order #{selectedApproval.OrderID}...");
                
                var approvalResult = await _dataService.ApproveOrderAsync(
                    selectedApproval.ApprovalID,
                    _ownerID,
                    tailorDialog.SelectedTailorIDs
                );

                if (approvalResult.Success)
                {
                    string successMessage = $"Order #{selectedApproval.OrderID} approved successfully!\n\n";
                    if (approvalResult.ProductionOrderID.HasValue)
                    {
                        successMessage += $"Production Order #{approvalResult.ProductionOrderID.Value} created and assigned to {tailorIDs.Count} tailor(s).";
                    }
                    else
                    {
                        successMessage += $"Assigned to {tailorIDs.Count} tailor(s).";
                    }
                    ShowSuccess(successMessage);
                }
                else
                {
                    ShowError($"Failed to approve order:\n{approvalResult.Message}");
                    return;
                }

                // Refresh the list
                await LoadPendingApprovals();
            }
            catch (Exception ex)
            {
                ShowError($"Error approving order: {ex.Message}");
            }
        }

        private async void BtnReject_Click(object sender, RoutedEventArgs e)
        {
            var selectedApproval = dgPendingApprovals.SelectedItem as OrderApproval;
            if (selectedApproval == null)
            {
                ShowWarning("Please select an order to reject");
                return;
            }

            try
            {
                // Show reject reason dialog
                var rejectDialog = new RejectReasonDialog(selectedApproval)
                {
                    Owner = Window.GetWindow(this)
                };

                if (rejectDialog.ShowDialog() != true || string.IsNullOrWhiteSpace(rejectDialog.RejectionReason))
                {
                    UpdateStatusMessage("Rejection cancelled");
                    return;
                }

                // Reject the order
                UpdateStatusMessage($"Rejecting Order #{selectedApproval.OrderID}...");

                await _dataService.RejectOrderAsync(
                    selectedApproval.ApprovalID,
                    _ownerID,
                    rejectDialog.RejectionReason
                );

                ShowSuccess($"Order #{selectedApproval.OrderID} has been rejected.\n\nReason: {rejectDialog.RejectionReason}");

                // Refresh the list
                await LoadPendingApprovals();
            }
            catch (Exception ex)
            {
                ShowError($"Error rejecting order: {ex.Message}");
            }
        }

        private async void BtnRefresh_Click(object sender, RoutedEventArgs e)
        {
            await LoadPendingApprovals();
        }

        private void UpdateStatusMessage(string message)
        {
            txtStatusMessage.Text = message;
        }

        private void ShowSuccess(string message)
        {
            MessageBox.Show(message, "Success", MessageBoxButton.OK, MessageBoxImage.Information);
            UpdateStatusMessage("Operation completed successfully");
        }

        private void ShowWarning(string message)
        {
            MessageBox.Show(message, "Warning", MessageBoxButton.OK, MessageBoxImage.Warning);
        }

        private void ShowError(string message)
        {
            MessageBox.Show(message, "Error", MessageBoxButton.OK, MessageBoxImage.Error);
            UpdateStatusMessage("Error occurred - check details");
        }
    }
}
