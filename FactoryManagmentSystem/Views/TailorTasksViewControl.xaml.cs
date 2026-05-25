using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using FactoryManagmentSystem.Models;
using FactoryManagmentSystem.Services;

namespace FactoryManagmentSystem.Views
{
    public partial class TailorTasksViewControl : UserControl
    {
        private readonly OrderApprovalDataService _dataService;
        private int _selectedTailorId = 0;

        public TailorTasksViewControl()
        {
            InitializeComponent();
            _dataService = new OrderApprovalDataService();
            Loaded += TailorTasksViewControl_Loaded;
        }

        private async void TailorTasksViewControl_Loaded(object sender, RoutedEventArgs e)
        {
            await LoadTailorsAsync();
        }

        private async Task LoadTailorsAsync()
        {
            try
            {
                var tailors = await _dataService.GetAvailableTailorsAsync();
                CmbTailors.ItemsSource = tailors;

                if (tailors.Any())
                {
                    CmbTailors.SelectedIndex = 0;
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error loading tailors: {ex.Message}", 
                    "Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private async void CmbTailors_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            if (CmbTailors.SelectedValue != null)
            {
                _selectedTailorId = (int)CmbTailors.SelectedValue;
                await LoadTailorTasksAsync(_selectedTailorId);
            }
        }

        private async Task LoadTailorTasksAsync(int tailorId)
        {
            try
            {
                var tasks = await _dataService.GetTailorAssignmentsAsync(tailorId);

                if (tasks.Any())
                {
                    // Add UI-specific properties for button visibility and colors
                    foreach (var task in tasks)
                    {
                        // Handle both "Assigned" (DB status) and "Incomplete" (legacy) - both show Start button
                        task.StartButtonVisibility = (task.CompletionStatus == "Assigned" || task.CompletionStatus == "Incomplete") ? 
                            Visibility.Visible : Visibility.Collapsed;
                        
                        task.CompleteButtonVisibility = task.CompletionStatus == "InProgress" ? 
                            Visibility.Visible : Visibility.Collapsed;
                        
                        task.CompletedTextVisibility = task.CompletionStatus == "Complete" ? 
                            Visibility.Visible : Visibility.Collapsed;

                        // Status colors
                        task.StatusColor = task.CompletionStatus switch
                        {
                            "Assigned" => "#FF9800",      // Orange - same as Incomplete
                            "Incomplete" => "#FF9800",    // Orange - legacy status
                            "InProgress" => "#2196F3",    // Blue
                            "Complete" => "#4CAF50",      // Green
                            _ => "#95A5A6"                // Gray - unknown status
                        };
                    }

                    DgTasks.ItemsSource = tasks;
                    DgTasks.Visibility = Visibility.Visible;
                    PnlNoData.Visibility = Visibility.Collapsed;

                    // Update counts - include "Assigned" and "Incomplete" as active
                    int activeCount = tasks.Count(t => t.CompletionStatus == "Assigned" ||
                                                       t.CompletionStatus == "Incomplete" || 
                                                       t.CompletionStatus == "InProgress");
                    int completedCount = tasks.Count(t => t.CompletionStatus == "Complete");
                    
                    TxtActiveCount.Text = activeCount.ToString();
                    TxtCompletedCount.Text = completedCount.ToString();
                }
                else
                {
                    DgTasks.ItemsSource = null;
                    DgTasks.Visibility = Visibility.Collapsed;
                    PnlNoData.Visibility = Visibility.Visible;
                    
                    TxtActiveCount.Text = "0";
                    TxtCompletedCount.Text = "0";
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error loading tailor tasks: {ex.Message}", 
                    "Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private async void BtnStartTask_Click(object sender, RoutedEventArgs e)
        {
            var button = sender as Button;
            if (button?.Tag == null) return;

            int taskId = (int)button.Tag;

            var result = MessageBox.Show(
                "Start working on this production task?",
                "Start Task",
                MessageBoxButton.YesNo,
                MessageBoxImage.Question);

            if (result == MessageBoxResult.Yes)
            {
                await UpdateTaskStatusAsync(taskId, "InProgress", "Task started by tailor");
            }
        }

        private async void BtnCompleteTask_Click(object sender, RoutedEventArgs e)
        {
            var button = sender as Button;
            if (button?.Tag == null) return;

            int taskId = (int)button.Tag;

            var result = MessageBox.Show(
                "Mark this production task as completed?\n\nThis will update the production order status if all tailors have completed their tasks.",
                "Complete Task",
                MessageBoxButton.YesNo,
                MessageBoxImage.Question);

            if (result == MessageBoxResult.Yes)
            {
                await UpdateTaskStatusAsync(taskId, "Complete", "Task completed by tailor");
            }
        }

        private async Task UpdateTaskStatusAsync(int taskId, string newStatus, string notes)
        {
            try
            {
                var (success, message, allCompleted) = await _dataService.UpdateTailorStatusAsync(
                    taskId, 
                    _selectedTailorId, 
                    newStatus, 
                    notes);

                if (success)
                {
                    MessageBox.Show(
                        $"Task status updated to {newStatus}!",
                        "Success",
                        MessageBoxButton.OK,
                        MessageBoxImage.Information);

                    // Reload tasks to reflect changes
                    await LoadTailorTasksAsync(_selectedTailorId);
                }
                else
                {
                    MessageBox.Show(message, "Error", MessageBoxButton.OK, MessageBoxImage.Error);
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(
                    $"Error updating task status: {ex.Message}",
                    "Error",
                    MessageBoxButton.OK,
                    MessageBoxImage.Error);
            }
        }

        private async void BtnRefresh_Click(object sender, RoutedEventArgs e)
        {
            if (_selectedTailorId > 0)
            {
                await LoadTailorTasksAsync(_selectedTailorId);
            }
        }
    }
}
