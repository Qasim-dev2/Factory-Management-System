using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Collections.Generic;

namespace FactoryManagmentSystem.Models
{
    // Employee User Model
    public class EmployeeUser
    {
        [Key]
        public int EmployeeId { get; set; }
        
        [Required]
        [StringLength(50)]
        public string FirstName { get; set; }
        
        [Required]
        [StringLength(50)]
        public string LastName { get; set; }
        
        [Required]
        [EmailAddress]
        [StringLength(100)]
        public string Email { get; set; }
        
        [StringLength(100)]
        public string Department { get; set; }
        
        [StringLength(100)]
        public string Position { get; set; }
        
        public DateTime HiredDate { get; set; } = DateTime.Now;
        
        public bool IsActive { get; set; } = true;
        
        // Navigation properties
        public virtual ICollection<EmployeeTask> Tasks { get; set; } = new List<EmployeeTask>();
        public virtual ICollection<AssignedMachinery> AssignedMachinery { get; set; } = new List<AssignedMachinery>();
        public virtual ICollection<EmployeeActivity> Activities { get; set; } = new List<EmployeeActivity>();
    }

    // Employee Task Model
    public class EmployeeTask
    {
        [Key]
        public int TaskId { get; set; }
        
        [Required]
        [StringLength(200)]
        public string Title { get; set; }
        
        [StringLength(500)]
        public string Description { get; set; }
        
        [Required]
        public int EmployeeId { get; set; }
        
        [Required]
        [StringLength(50)]
        public string Status { get; set; } = "Pending"; // Pending, Active, Completed, Cancelled
        
        [Required]
        [StringLength(100)]
        public string Priority { get; set; } = "Medium"; // Low, Medium, High, Critical
        
        [Required]
        public DateTime AssignedDate { get; set; } = DateTime.Now;
        
        public DateTime? StartedDate { get; set; }
        
        public DateTime? CompletedDate { get; set; }
        
        [Required]
        public DateTime DueDate { get; set; }
        
        [StringLength(100)]
        public string AssignedBy { get; set; }
        
        [Column(TypeName = "text")]
        public string Notes { get; set; }
        
        public decimal EstimatedHours { get; set; }
        
        public decimal ActualHours { get; set; }
        
        // Navigation property
        [ForeignKey("EmployeeId")]
        public virtual EmployeeUser Employee { get; set; }
    }

    // Assigned Machinery Model
    public class AssignedMachinery
    {
        [Key]
        public int AssignmentId { get; set; }
        
        [Required]
        public int EmployeeId { get; set; }
        
        [Required]
        [StringLength(100)]
        public string MachineId { get; set; }
        
        [Required]
        [StringLength(200)]
        public string MachineName { get; set; }
        
        [Required]
        [StringLength(100)]
        public string MachineType { get; set; }
        
        [StringLength(200)]
        public string Location { get; set; }
        
        [Required]
        [StringLength(50)]
        public string Status { get; set; } = "Online"; // Online, Offline, Maintenance, Error
        
        [Required]
        public DateTime AssignedDate { get; set; } = DateTime.Now;
        
        public DateTime? UnassignedDate { get; set; }
        
        [StringLength(50)]
        public string AccessLevel { get; set; } = "Operator"; // Operator, Maintenance, Admin
        
        [StringLength(100)]
        public string AssignedBy { get; set; }
        
        [Column(TypeName = "text")]
        public string Notes { get; set; }
        
        // Machine performance metrics
        public decimal EfficiencyRating { get; set; } = 0m;
        
        public int TotalRunHours { get; set; } = 0;
        
        public DateTime LastMaintenanceDate { get; set; }
        
        public DateTime NextMaintenanceDate { get; set; }
        
        // Navigation property
        [ForeignKey("EmployeeId")]
        public virtual EmployeeUser Employee { get; set; }
    }

    // Employee Activity Log Model
    public class EmployeeActivity
    {
        [Key]
        public int ActivityId { get; set; }
        
        [Required]
        public int EmployeeId { get; set; }
        
        [Required]
        [StringLength(100)]
        public string ActivityType { get; set; }
        
        [Required]
        [StringLength(200)]
        public string Title { get; set; }
        
        [StringLength(500)]
        public string Description { get; set; }
        
        [Required]
        public DateTime Timestamp { get; set; } = DateTime.Now;
        
        [StringLength(50)]
        public string Status { get; set; }
        
        [StringLength(100)]
        public string Module { get; set; }
        
        [Column(TypeName = "json")]
        public string MetaData { get; set; }
        
        // Navigation property
        [ForeignKey("EmployeeId")]
        public virtual EmployeeUser Employee { get; set; }
    }

    // Employee Statistics DTO
    public class EmployeeStats
    {
        public int ActiveTasks { get; set; }
        public int CompletedTasksToday { get; set; }
        public int CompletedTasksThisWeek { get; set; }
        public int CompletedTasksThisMonth { get; set; }
        public int AssignedMachines { get; set; }
        public int OnlineMachines { get; set; }
        public decimal HoursWorkedToday { get; set; }
        public decimal HoursWorkedThisWeek { get; set; }
        public decimal HoursWorkedThisMonth { get; set; }
        public decimal AverageTaskCompletionTime { get; set; }
        public decimal OverallEfficiencyRating { get; set; }
        public int PendingTasks { get; set; }
        public int OverdueTasks { get; set; }
        public DateTime LastActivityTime { get; set; }
        public string CurrentShift { get; set; }
        public TimeSpan ShiftStartTime { get; set; }
        public TimeSpan ShiftEndTime { get; set; }
    }

    // Employee Shift Schedule Model
    public class EmployeeShift
    {
        [Key]
        public int ShiftId { get; set; }
        
        [Required]
        public int EmployeeId { get; set; }
        
        [Required]
        [StringLength(50)]
        public string ShiftType { get; set; } // Day, Night, Evening
        
        [Required]
        public DateTime ShiftDate { get; set; }
        
        [Required]
        public TimeSpan StartTime { get; set; }
        
        [Required]
        public TimeSpan EndTime { get; set; }
        
        public DateTime? ActualStartTime { get; set; }
        
        public DateTime? ActualEndTime { get; set; }
        
        [StringLength(50)]
        public string Status { get; set; } = "Scheduled"; // Scheduled, InProgress, Completed, Missed
        
        [Column(TypeName = "text")]
        public string Notes { get; set; }
        
        // Navigation property
        [ForeignKey("EmployeeId")]
        public virtual EmployeeUser Employee { get; set; }
    }

    // Employee Performance Model
    public class EmployeePerformance
    {
        [Key]
        public int PerformanceId { get; set; }
        
        [Required]
        public int EmployeeId { get; set; }
        
        [Required]
        public DateTime EvaluationDate { get; set; }
        
        [Required]
        public DateTime PeriodStart { get; set; }
        
        [Required]
        public DateTime PeriodEnd { get; set; }
        
        public decimal ProductivityScore { get; set; }
        
        public decimal QualityScore { get; set; }
        
        public decimal SafetyScore { get; set; }
        
        public int TasksCompleted { get; set; }
        
        public int TasksOnTime { get; set; }
        
        public decimal AverageTaskRating { get; set; }
        
        public int AttendanceScore { get; set; }
        
        [Column(TypeName = "text")]
        public string Comments { get; set; }
        
        [StringLength(100)]
        public string EvaluatedBy { get; set; }
        
        // Navigation property
        [ForeignKey("EmployeeId")]
        public virtual EmployeeUser Employee { get; set; }
    }

    // Employee Training Record Model
    public class EmployeeTraining
    {
        [Key]
        public int TrainingId { get; set; }
        
        [Required]
        public int EmployeeId { get; set; }
        
        [Required]
        [StringLength(200)]
        public string TrainingName { get; set; }
        
        [StringLength(100)]
        public string TrainingCategory { get; set; }
        
        [StringLength(500)]
        public string Description { get; set; }
        
        [Required]
        public DateTime StartDate { get; set; }
        
        public DateTime? CompletionDate { get; set; }
        
        [Required]
        [StringLength(50)]
        public string Status { get; set; } = "Assigned"; // Assigned, InProgress, Completed, Failed
        
        public decimal? Score { get; set; }
        
        public decimal PassingScore { get; set; } = 70m;
        
        [StringLength(100)]
        public string Instructor { get; set; }
        
        [Column(TypeName = "text")]
        public string Notes { get; set; }
        
        public DateTime? CertificationExpiry { get; set; }
        
        // Navigation property
        [ForeignKey("EmployeeId")]
        public virtual EmployeeUser Employee { get; set; }
    }
}