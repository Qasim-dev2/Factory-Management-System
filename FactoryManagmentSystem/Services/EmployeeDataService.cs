using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using FactoryManagmentSystem.Models;

namespace FactoryManagmentSystem.Services
{
    // Employee Data Service Interface
    public interface IEmployeeDataService
    {
        // Employee Management
        Task<EmployeeUser> GetEmployeeAsync(int employeeId);
        Task<List<EmployeeUser>> GetAllEmployeesAsync();
        Task<EmployeeUser> CreateEmployeeAsync(EmployeeUser employee);
        Task<EmployeeUser> UpdateEmployeeAsync(EmployeeUser employee);
        Task<bool> DeleteEmployeeAsync(int employeeId);
        
        // Employee Statistics
        Task<EmployeeStats> GetEmployeeStatsAsync(int employeeId);
        
        // Task Management
        Task<List<EmployeeTask>> GetEmployeeTasksAsync(int employeeId);
        Task<List<EmployeeTask>> GetTasksByStatusAsync(int employeeId, string status);
        Task<EmployeeTask> CreateTaskAsync(EmployeeTask task);
        Task<EmployeeTask> UpdateTaskAsync(EmployeeTask task);
        Task<bool> CompleteTaskAsync(int taskId);
        Task<bool> DeleteTaskAsync(int taskId);
        Task<List<EmployeeTask>> SearchTasksAsync(int employeeId, string searchTerm);
        
        // Machinery Management
        Task<List<AssignedMachinery>> GetAssignedMachineryAsync(int employeeId);
        Task<AssignedMachinery> AssignMachineryAsync(AssignedMachinery assignment);
        Task<bool> UnassignMachineryAsync(int assignmentId);
        Task<AssignedMachinery> UpdateMachineryStatusAsync(int assignmentId, string status);
        
        // Activity Logging
        Task<List<EmployeeActivity>> GetRecentActivitiesAsync(int employeeId, int count = 10);
        Task<EmployeeActivity> LogActivityAsync(EmployeeActivity activity);
        Task<List<EmployeeActivity>> GetActivitiesByDateAsync(int employeeId, DateTime date);
        
        // Shift Management
        Task<List<EmployeeShift>> GetEmployeeShiftsAsync(int employeeId, DateTime? startDate = null, DateTime? endDate = null);
        Task<EmployeeShift> GetCurrentShiftAsync(int employeeId);
        Task<EmployeeShift> StartShiftAsync(int employeeId);
        Task<EmployeeShift> EndShiftAsync(int employeeId);
        
        // Performance Tracking
        Task<List<EmployeePerformance>> GetPerformanceHistoryAsync(int employeeId);
        Task<EmployeePerformance> GetLatestPerformanceAsync(int employeeId);
        
        // Training Management
        Task<List<EmployeeTraining>> GetEmployeeTrainingAsync(int employeeId);
        Task<List<EmployeeTraining>> GetPendingTrainingAsync(int employeeId);
        Task<EmployeeTraining> CompleteTrainingAsync(int trainingId, decimal score);
    }

    // Employee Data Service Implementation
    public class EmployeeDataService : IEmployeeDataService
    {
        // Demo data - in real application, this would connect to a database
        private static List<EmployeeUser> _employees;
        private static List<EmployeeTask> _tasks;
        private static List<AssignedMachinery> _machinery;
        private static List<EmployeeActivity> _activities;
        private static List<EmployeeShift> _shifts;
        private static List<EmployeePerformance> _performance;
        private static List<EmployeeTraining> _training;

        public EmployeeDataService()
        {
            InitializeDemoData();
        }

        private void InitializeDemoData()
        {
            if (_employees == null)
            {
                _employees = new List<EmployeeUser>
                {
                    new EmployeeUser
                    {
                        EmployeeId = 1,
                        FirstName = "Ahmed",
                        LastName = "Khan",
                        Email = "a.khan@garmentsFactory.com",
                        Department = "Cutting",
                        Position = "Master Cutter",
                        HiredDate = DateTime.Now.AddYears(-3)
                    },
                    new EmployeeUser
                    {
                        EmployeeId = 2,
                        FirstName = "Fatima",
                        LastName = "Ali",
                        Email = "f.ali@garmentsFactory.com",
                        Department = "Stitching",
                        Position = "Senior Tailor",
                        HiredDate = DateTime.Now.AddYears(-2)
                    },
                    new EmployeeUser
                    {
                        EmployeeId = 3,
                        FirstName = "Muhammad",
                        LastName = "Hassan",
                        Email = "m.hassan@garmentsFactory.com",
                        Department = "Quality Control",
                        Position = "Quality Controller",
                        HiredDate = DateTime.Now.AddYears(-1)
                    },
                    new EmployeeUser
                    {
                        EmployeeId = 4,
                        FirstName = "Ayesha",
                        LastName = "Malik",
                        Email = "a.malik@garmentsFactory.com",
                        Department = "Finishing",
                        Position = "Finisher",
                        HiredDate = DateTime.Now.AddMonths(-8)
                    }
                };

                _tasks = new List<EmployeeTask>
                {
                    new EmployeeTask
                    {
                        TaskId = 1,
                        EmployeeId = 1,
                        Title = "Pattern Cutting - Summer Collection",
                        Description = "Cut fabric patterns for 500 polo shirts - Summer collection order",
                        Status = "Active",
                        Priority = "High",
                        AssignedDate = DateTime.Now.AddDays(-1),
                        DueDate = DateTime.Now.AddHours(6),
                        EstimatedHours = 4.0m,
                        AssignedBy = "Production Manager"
                    },
                    new EmployeeTask
                    {
                        TaskId = 2,
                        EmployeeId = 2,
                        Title = "Stitching - Corporate Shirts",
                        Description = "Complete stitching for 300 formal shirts order - Client: ABC Corp",
                        Status = "Active",
                        Priority = "Medium",
                        AssignedDate = DateTime.Now.AddDays(-2),
                        DueDate = DateTime.Now.AddDays(1),
                        EstimatedHours = 8.0m,
                        AssignedBy = "Line Supervisor"
                    },
                    new EmployeeTask
                    {
                        TaskId = 2,
                        EmployeeId = 1,
                        Title = "Quality Check - Batch 2401",
                        Description = "Perform quality inspection on paper batch 2401",
                        Status = "Pending",
                        Priority = "Medium",
                        AssignedDate = DateTime.Now.AddHours(-2),
                        DueDate = DateTime.Now.AddHours(6),
                        EstimatedHours = 1.5m,
                        AssignedBy = "QC Supervisor"
                    },
                    new EmployeeTask
                    {
                        TaskId = 3,
                        EmployeeId = 1,
                        Title = "Equipment Maintenance Check",
                        Description = "Daily maintenance check on assigned machinery",
                        Status = "Completed",
                        Priority = "Medium",
                        AssignedDate = DateTime.Now.AddDays(-1),
                        StartedDate = DateTime.Now.AddHours(-8),
                        CompletedDate = DateTime.Now.AddHours(-6),
                        DueDate = DateTime.Now.AddHours(-4),
                        EstimatedHours = 2m,
                        ActualHours = 1.5m,
                        AssignedBy = "Maintenance Supervisor"
                    },
                    new EmployeeTask
                    {
                        TaskId = 4,
                        EmployeeId = 1,
                        Title = "Safety Training Completion",
                        Description = "Complete monthly safety training module",
                        Status = "Active",
                        Priority = "High",
                        AssignedDate = DateTime.Now.AddDays(-3),
                        DueDate = DateTime.Now.AddDays(2),
                        EstimatedHours = 1m,
                        AssignedBy = "Safety Officer"
                    },
                    new EmployeeTask
                    {
                        TaskId = 5,
                        EmployeeId = 1,
                        Title = "Production Report Review",
                        Description = "Review and verify yesterday's production reports",
                        Status = "Completed",
                        Priority = "Low",
                        AssignedDate = DateTime.Now.AddHours(-10),
                        StartedDate = DateTime.Now.AddHours(-9),
                        CompletedDate = DateTime.Now.AddHours(-7),
                        DueDate = DateTime.Now.AddHours(-2),
                        EstimatedHours = 0.5m,
                        ActualHours = 0.75m,
                        AssignedBy = "Production Supervisor"
                    }
                };

                _machinery = new List<AssignedMachinery>
                {
                    new AssignedMachinery
                    {
                        AssignmentId = 1,
                        EmployeeId = 1,
                        MachineId = "PM-001",
                        MachineName = "Paper Mill Machine #1",
                        MachineType = "Paper Manufacturing",
                        Location = "Production Floor A - Section 1",
                        Status = "Online",
                        AssignedDate = DateTime.Now.AddMonths(-6),
                        AccessLevel = "Operator",
                        AssignedBy = "Production Manager",
                        EfficiencyRating = 92.5m,
                        TotalRunHours = 2840,
                        LastMaintenanceDate = DateTime.Now.AddDays(-15),
                        NextMaintenanceDate = DateTime.Now.AddDays(15)
                    },
                    new AssignedMachinery
                    {
                        AssignmentId = 2,
                        EmployeeId = 1,
                        MachineId = "CT-002",
                        MachineName = "Cutting Machine #2",
                        MachineType = "Paper Cutting",
                        Location = "Production Floor A - Section 3",
                        Status = "Online",
                        AssignedDate = DateTime.Now.AddMonths(-3),
                        AccessLevel = "Operator",
                        AssignedBy = "Production Manager",
                        EfficiencyRating = 88.2m,
                        TotalRunHours = 1560,
                        LastMaintenanceDate = DateTime.Now.AddDays(-8),
                        NextMaintenanceDate = DateTime.Now.AddDays(22)
                    }
                };

                _activities = new List<EmployeeActivity>
                {
                    new EmployeeActivity
                    {
                        ActivityId = 1,
                        EmployeeId = 1,
                        ActivityType = "task_completed",
                        Title = "Completed Equipment Maintenance Check",
                        Description = "Successfully completed daily maintenance check",
                        Timestamp = DateTime.Now.AddHours(-6),
                        Status = "Success",
                        Module = "Tasks"
                    },
                    new EmployeeActivity
                    {
                        ActivityId = 2,
                        EmployeeId = 1,
                        ActivityType = "task_started",
                        Title = "Started Machine Setup - Line A",
                        Description = "Began setup process for production line A",
                        Timestamp = DateTime.Now.AddHours(-3),
                        Status = "In Progress",
                        Module = "Tasks"
                    },
                    new EmployeeActivity
                    {
                        ActivityId = 3,
                        EmployeeId = 1,
                        ActivityType = "shift_started",
                        Title = "Day shift started",
                        Description = "Clocked in for day shift",
                        Timestamp = DateTime.Now.AddHours(-8),
                        Status = "Active",
                        Module = "Attendance"
                    },
                    new EmployeeActivity
                    {
                        ActivityId = 4,
                        EmployeeId = 1,
                        ActivityType = "machine_assigned",
                        Title = "Assigned to Paper Mill Machine #1",
                        Description = "Successfully assigned to operate PM-001",
                        Timestamp = DateTime.Now.AddHours(-4),
                        Status = "Active",
                        Module = "Machinery"
                    },
                    new EmployeeActivity
                    {
                        ActivityId = 5,
                        EmployeeId = 1,
                        ActivityType = "task_completed",
                        Title = "Completed Production Report Review",
                        Description = "Reviewed and verified production reports",
                        Timestamp = DateTime.Now.AddHours(-7),
                        Status = "Success",
                        Module = "Tasks"
                    }
                };

                _shifts = new List<EmployeeShift>();
                _performance = new List<EmployeePerformance>();
                _training = new List<EmployeeTraining>();
            }
        }

        // Employee Management Implementation
        public async Task<EmployeeUser> GetEmployeeAsync(int employeeId)
        {
            await Task.Delay(100); // Simulate async database call
            return _employees.FirstOrDefault(e => e.EmployeeId == employeeId);
        }

        public async Task<List<EmployeeUser>> GetAllEmployeesAsync()
        {
            await Task.Delay(100);
            return _employees.ToList();
        }

        public async Task<EmployeeUser> CreateEmployeeAsync(EmployeeUser employee)
        {
            await Task.Delay(100);
            employee.EmployeeId = _employees.Max(e => e.EmployeeId) + 1;
            _employees.Add(employee);
            return employee;
        }

        public async Task<EmployeeUser> UpdateEmployeeAsync(EmployeeUser employee)
        {
            await Task.Delay(100);
            var existing = _employees.FirstOrDefault(e => e.EmployeeId == employee.EmployeeId);
            if (existing != null)
            {
                var index = _employees.IndexOf(existing);
                _employees[index] = employee;
                return employee;
            }
            return null;
        }

        public async Task<bool> DeleteEmployeeAsync(int employeeId)
        {
            await Task.Delay(100);
            var employee = _employees.FirstOrDefault(e => e.EmployeeId == employeeId);
            if (employee != null)
            {
                _employees.Remove(employee);
                return true;
            }
            return false;
        }

        // Employee Statistics Implementation
        public async Task<EmployeeStats> GetEmployeeStatsAsync(int employeeId)
        {
            await Task.Delay(100);
            
            var employeeTasks = _tasks.Where(t => t.EmployeeId == employeeId).ToList();
            var employeeMachinery = _machinery.Where(m => m.EmployeeId == employeeId).ToList();
            
            return new EmployeeStats
            {
                ActiveTasks = employeeTasks.Count(t => t.Status == "Active"),
                CompletedTasksToday = employeeTasks.Count(t => t.Status == "Completed" && 
                    t.CompletedDate?.Date == DateTime.Today),
                CompletedTasksThisWeek = employeeTasks.Count(t => t.Status == "Completed" && 
                    t.CompletedDate >= DateTime.Today.AddDays(-7)),
                CompletedTasksThisMonth = employeeTasks.Count(t => t.Status == "Completed" && 
                    t.CompletedDate >= DateTime.Today.AddDays(-30)),
                AssignedMachines = employeeMachinery.Count,
                OnlineMachines = employeeMachinery.Count(m => m.Status == "Online"),
                HoursWorkedToday = 6.5m, // Demo value
                HoursWorkedThisWeek = 32.5m, // Demo value
                HoursWorkedThisMonth = 128m, // Demo value
                AverageTaskCompletionTime = employeeTasks.Where(t => t.ActualHours > 0).Any() ? 
                    employeeTasks.Where(t => t.ActualHours > 0).Average(t => t.ActualHours) : 0,
                OverallEfficiencyRating = employeeMachinery.Any() ? 
                    employeeMachinery.Average(m => m.EfficiencyRating) : 0,
                PendingTasks = employeeTasks.Count(t => t.Status == "Pending"),
                OverdueTasks = employeeTasks.Count(t => t.Status != "Completed" && t.DueDate < DateTime.Now),
                LastActivityTime = _activities.Where(a => a.EmployeeId == employeeId).Any() ?
                    _activities.Where(a => a.EmployeeId == employeeId).Max(a => a.Timestamp) : DateTime.Now,
                CurrentShift = "Day Shift",
                ShiftStartTime = new TimeSpan(8, 0, 0),
                ShiftEndTime = new TimeSpan(16, 30, 0)
            };
        }

        // Task Management Implementation
        public async Task<List<EmployeeTask>> GetEmployeeTasksAsync(int employeeId)
        {
            await Task.Delay(100);
            return _tasks.Where(t => t.EmployeeId == employeeId)
                         .OrderByDescending(t => t.AssignedDate)
                         .ToList();
        }

        public async Task<List<EmployeeTask>> GetTasksByStatusAsync(int employeeId, string status)
        {
            await Task.Delay(100);
            return _tasks.Where(t => t.EmployeeId == employeeId && t.Status == status)
                         .OrderByDescending(t => t.AssignedDate)
                         .ToList();
        }

        public async Task<EmployeeTask> CreateTaskAsync(EmployeeTask task)
        {
            await Task.Delay(100);
            task.TaskId = _tasks.Max(t => t.TaskId) + 1;
            _tasks.Add(task);
            return task;
        }

        public async Task<EmployeeTask> UpdateTaskAsync(EmployeeTask task)
        {
            await Task.Delay(100);
            var existing = _tasks.FirstOrDefault(t => t.TaskId == task.TaskId);
            if (existing != null)
            {
                var index = _tasks.IndexOf(existing);
                _tasks[index] = task;
                return task;
            }
            return null;
        }

        public async Task<bool> CompleteTaskAsync(int taskId)
        {
            await Task.Delay(100);
            var task = _tasks.FirstOrDefault(t => t.TaskId == taskId);
            if (task != null)
            {
                task.Status = "Completed";
                task.CompletedDate = DateTime.Now;
                return true;
            }
            return false;
        }

        public async Task<bool> DeleteTaskAsync(int taskId)
        {
            await Task.Delay(100);
            var task = _tasks.FirstOrDefault(t => t.TaskId == taskId);
            if (task != null)
            {
                _tasks.Remove(task);
                return true;
            }
            return false;
        }

        public async Task<List<EmployeeTask>> SearchTasksAsync(int employeeId, string searchTerm)
        {
            await Task.Delay(100);
            return _tasks.Where(t => t.EmployeeId == employeeId && 
                               (t.Title.Contains(searchTerm) || t.Description.Contains(searchTerm)))
                         .OrderByDescending(t => t.AssignedDate)
                         .ToList();
        }

        // Machinery Management Implementation
        public async Task<List<AssignedMachinery>> GetAssignedMachineryAsync(int employeeId)
        {
            await Task.Delay(100);
            return _machinery.Where(m => m.EmployeeId == employeeId)
                            .OrderBy(m => m.MachineName)
                            .ToList();
        }

        public async Task<AssignedMachinery> AssignMachineryAsync(AssignedMachinery assignment)
        {
            await Task.Delay(100);
            assignment.AssignmentId = _machinery.Max(m => m.AssignmentId) + 1;
            _machinery.Add(assignment);
            return assignment;
        }

        public async Task<bool> UnassignMachineryAsync(int assignmentId)
        {
            await Task.Delay(100);
            var assignment = _machinery.FirstOrDefault(m => m.AssignmentId == assignmentId);
            if (assignment != null)
            {
                assignment.UnassignedDate = DateTime.Now;
                return true;
            }
            return false;
        }

        public async Task<AssignedMachinery> UpdateMachineryStatusAsync(int assignmentId, string status)
        {
            await Task.Delay(100);
            var assignment = _machinery.FirstOrDefault(m => m.AssignmentId == assignmentId);
            if (assignment != null)
            {
                assignment.Status = status;
                return assignment;
            }
            return null;
        }

        // Activity Logging Implementation
        public async Task<List<EmployeeActivity>> GetRecentActivitiesAsync(int employeeId, int count = 10)
        {
            await Task.Delay(100);
            return _activities.Where(a => a.EmployeeId == employeeId)
                             .OrderByDescending(a => a.Timestamp)
                             .Take(count)
                             .ToList();
        }

        public async Task<EmployeeActivity> LogActivityAsync(EmployeeActivity activity)
        {
            await Task.Delay(100);
            activity.ActivityId = _activities.Max(a => a.ActivityId) + 1;
            _activities.Add(activity);
            return activity;
        }

        public async Task<List<EmployeeActivity>> GetActivitiesByDateAsync(int employeeId, DateTime date)
        {
            await Task.Delay(100);
            return _activities.Where(a => a.EmployeeId == employeeId && a.Timestamp.Date == date.Date)
                             .OrderByDescending(a => a.Timestamp)
                             .ToList();
        }

        // Shift Management Implementation
        public async Task<List<EmployeeShift>> GetEmployeeShiftsAsync(int employeeId, DateTime? startDate = null, DateTime? endDate = null)
        {
            await Task.Delay(100);
            var query = _shifts.Where(s => s.EmployeeId == employeeId);
            
            if (startDate.HasValue)
                query = query.Where(s => s.ShiftDate >= startDate.Value);
                
            if (endDate.HasValue)
                query = query.Where(s => s.ShiftDate <= endDate.Value);
                
            return query.OrderByDescending(s => s.ShiftDate).ToList();
        }

        public async Task<EmployeeShift> GetCurrentShiftAsync(int employeeId)
        {
            await Task.Delay(100);
            return _shifts.FirstOrDefault(s => s.EmployeeId == employeeId && 
                                         s.ShiftDate.Date == DateTime.Today && 
                                         s.Status == "InProgress");
        }

        public async Task<EmployeeShift> StartShiftAsync(int employeeId)
        {
            await Task.Delay(100);
            var shift = new EmployeeShift
            {
                ShiftId = _shifts.Any() ? _shifts.Max(s => s.ShiftId) + 1 : 1,
                EmployeeId = employeeId,
                ShiftType = "Day",
                ShiftDate = DateTime.Today,
                StartTime = new TimeSpan(8, 0, 0),
                EndTime = new TimeSpan(16, 30, 0),
                ActualStartTime = DateTime.Now,
                Status = "InProgress"
            };
            
            _shifts.Add(shift);
            return shift;
        }

        public async Task<EmployeeShift> EndShiftAsync(int employeeId)
        {
            await Task.Delay(100);
            var shift = await GetCurrentShiftAsync(employeeId);
            if (shift != null)
            {
                shift.ActualEndTime = DateTime.Now;
                shift.Status = "Completed";
                return shift;
            }
            return null;
        }

        // Performance Tracking Implementation
        public async Task<List<EmployeePerformance>> GetPerformanceHistoryAsync(int employeeId)
        {
            await Task.Delay(100);
            return _performance.Where(p => p.EmployeeId == employeeId)
                              .OrderByDescending(p => p.EvaluationDate)
                              .ToList();
        }

        public async Task<EmployeePerformance> GetLatestPerformanceAsync(int employeeId)
        {
            await Task.Delay(100);
            return _performance.Where(p => p.EmployeeId == employeeId)
                              .OrderByDescending(p => p.EvaluationDate)
                              .FirstOrDefault();
        }

        // Training Management Implementation
        public async Task<List<EmployeeTraining>> GetEmployeeTrainingAsync(int employeeId)
        {
            await Task.Delay(100);
            return _training.Where(t => t.EmployeeId == employeeId)
                           .OrderByDescending(t => t.StartDate)
                           .ToList();
        }

        public async Task<List<EmployeeTraining>> GetPendingTrainingAsync(int employeeId)
        {
            await Task.Delay(100);
            return _training.Where(t => t.EmployeeId == employeeId && 
                                  (t.Status == "Assigned" || t.Status == "InProgress"))
                           .OrderBy(t => t.StartDate)
                           .ToList();
        }

        public async Task<EmployeeTraining> CompleteTrainingAsync(int trainingId, decimal score)
        {
            await Task.Delay(100);
            var training = _training.FirstOrDefault(t => t.TrainingId == trainingId);
            if (training != null)
            {
                training.CompletionDate = DateTime.Now;
                training.Score = score;
                training.Status = score >= training.PassingScore ? "Completed" : "Failed";
                return training;
            }
            return null;
        }
    }
}