using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Collections.Generic;

namespace FactoryManagmentSystem.Models
{
    // Owner Employee Management Models
    public class OwnerEmployee
    {
        [Key]
        public int EmployeeId { get; set; }
        
        [Required]
        [StringLength(100)]
        public string FullName { get; set; } = string.Empty;
        
        [Required]
        [EmailAddress]
        [StringLength(150)]
        public string Email { get; set; } = string.Empty;
        
        [Required]
        [StringLength(20)]
        public string ContactNumber { get; set; } = string.Empty;
        
        [Required]
        [StringLength(20)]
        public string CNIC { get; set; } = string.Empty;
        
        [Required]
        [StringLength(300)]
        public string Address { get; set; } = string.Empty;
        
        [Required]
        [StringLength(50)]
        public string Role { get; set; } = "Employee"; // Employee, Manager, Salesperson
        
        [Required]
        [Column(TypeName = "decimal(18,2)")]
        public decimal Salary { get; set; }
        
        [Required]
        public DateTime HireDate { get; set; } = DateTime.Now;
        
        [StringLength(50)]
        public string Department { get; set; } = string.Empty;
        
        [StringLength(100)]
        public string Position { get; set; } = string.Empty;
        
        [StringLength(20)]
        public string Status { get; set; } = "Active"; // Active, Inactive, Terminated
        
        public DateTime? LastPromotionDate { get; set; }
        
        [StringLength(100)]
        public string EmergencyContact { get; set; } = string.Empty;
        
        [StringLength(50)]
        public string Username { get; set; } = string.Empty;
        
        [StringLength(4)]
        public string PIN { get; set; } = string.Empty;
        
        [StringLength(20)]
        public string EmergencyPhone { get; set; } = string.Empty;
        
        [Column(TypeName = "text")]
        public string Notes { get; set; } = string.Empty;
        
        public DateTime CreatedDate { get; set; } = DateTime.Now;
        
        public DateTime? UpdatedDate { get; set; }
        
        [StringLength(100)]
        public string CreatedBy { get; set; } = "Owner";
        
        [StringLength(100)]
        public string UpdatedBy { get; set; } = string.Empty;
        
        // Navigation properties
        public virtual ICollection<EmployeePromotion> Promotions { get; set; } = new List<EmployeePromotion>();
        public virtual ICollection<EmployeeSalaryHistory> SalaryHistory { get; set; } = new List<EmployeeSalaryHistory>();
        
        // UI Properties (not mapped to database)
        [NotMapped]
        public bool IsSelected { get; set; } = false;
        
        [NotMapped]
        public string Initials { get; set; } = string.Empty;
    }

    // Employee Promotion History
    public class EmployeePromotion
    {
        [Key]
        public int PromotionId { get; set; }
        
        [Required]
        public int EmployeeId { get; set; }
        
        [Required]
        [StringLength(50)]
        public string FromRole { get; set; } = string.Empty;
        
        [Required]
        [StringLength(50)]
        public string ToRole { get; set; } = string.Empty;
        
        [Required]
        public DateTime PromotionDate { get; set; } = DateTime.Now;
        
        [Column(TypeName = "decimal(18,2)")]
        public decimal? PreviousSalary { get; set; }
        
        [Column(TypeName = "decimal(18,2)")]
        public decimal? NewSalary { get; set; }
        
        [StringLength(500)]
        public string Reason { get; set; } = string.Empty;
        
        [Required]
        [StringLength(100)]
        public string ApprovedBy { get; set; } = "Owner";
        
        [Column(TypeName = "text")]
        public string Notes { get; set; } = string.Empty;
        
        // Navigation property
        [ForeignKey("EmployeeId")]
        public virtual OwnerEmployee Employee { get; set; } = null!;
    }

    // Employee Salary History
    public class EmployeeSalaryHistory
    {
        [Key]
        public int SalaryHistoryId { get; set; }
        
        [Required]
        public int EmployeeId { get; set; }
        
        [Required]
        [Column(TypeName = "decimal(18,2)")]
        public decimal PreviousSalary { get; set; }
        
        [Required]
        [Column(TypeName = "decimal(18,2)")]
        public decimal NewSalary { get; set; }
        
        [Required]
        public DateTime EffectiveDate { get; set; } = DateTime.Now;
        
        [StringLength(50)]
        public string ChangeType { get; set; } = "Salary Update"; // Salary Update, Promotion, Bonus, Deduction
        
        [StringLength(500)]
        public string Reason { get; set; } = string.Empty;
        
        [Required]
        [StringLength(100)]
        public string ApprovedBy { get; set; } = "Owner";
        
        [Column(TypeName = "text")]
        public string Notes { get; set; } = string.Empty;
        
        // Navigation property
        [ForeignKey("EmployeeId")]
        public virtual OwnerEmployee Employee { get; set; } = null!;
    }

    // Employee Search/Filter DTO
    public class EmployeeSearchFilter
    {
        public string? SearchTerm { get; set; }
        public string? Role { get; set; }
        public string? Department { get; set; }
        public string? Status { get; set; }
        public decimal? MinSalary { get; set; }
        public decimal? MaxSalary { get; set; }
        public DateTime? HireDateFrom { get; set; }
        public DateTime? HireDateTo { get; set; }
        public int PageNumber { get; set; } = 1;
        public int PageSize { get; set; } = 10;
        public string SortBy { get; set; } = "FullName";
        public string SortDirection { get; set; } = "ASC";
    }

    // Employee Statistics DTO
    public class EmployeeStatistics
    {
        public int TotalEmployees { get; set; }
        public int ActiveEmployees { get; set; }
        public int InactiveEmployees { get; set; }
        public int TerminatedEmployees { get; set; }
        public int TotalManagers { get; set; }
        public int TotalSalespersons { get; set; }
        public int TotalRegularEmployees { get; set; }
        public decimal AverageSalary { get; set; }
        public decimal TotalPayroll { get; set; }
        public int NewHiresThisMonth { get; set; }
        public int PromotionsThisYear { get; set; }
        public List<DepartmentEmployeeCount> DepartmentBreakdown { get; set; } = new List<DepartmentEmployeeCount>();
        public List<RoleEmployeeCount> RoleBreakdown { get; set; } = new List<RoleEmployeeCount>();
    }

    // Department Employee Count
    public class DepartmentEmployeeCount
    {
        public string Department { get; set; } = string.Empty;
        public int Count { get; set; }
    }

    // Role Employee Count
    public class RoleEmployeeCount
    {
        public string Role { get; set; } = string.Empty;
        public int Count { get; set; }
    }

    // Paginated Result
    public class PaginatedResult<T>
    {
        public List<T> Data { get; set; } = new List<T>();
        public int TotalRecords { get; set; }
        public int PageNumber { get; set; }
        public int PageSize { get; set; }
        public int TotalPages => (int)Math.Ceiling((double)TotalRecords / PageSize);
        public bool HasPreviousPage => PageNumber > 1;
        public bool HasNextPage => PageNumber < TotalPages;
    }

    // Employee Form Validation
    public class EmployeeFormData
    {
        public int? EmployeeId { get; set; }
        public string FullName { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string ContactNumber { get; set; } = string.Empty;
        public string CNIC { get; set; } = string.Empty;
        public string Address { get; set; } = string.Empty;
        public string Role { get; set; } = "Employee";
        public decimal Salary { get; set; }
        public string Department { get; set; } = string.Empty;
        public string Position { get; set; } = string.Empty;
        public string EmergencyContact { get; set; } = string.Empty;
        public DateTime HireDate { get; set; } = DateTime.Now;
        public string Username { get; set; } = string.Empty;
        public string PIN { get; set; } = string.Empty;
        
        // Validation method
        public List<string> Validate()
        {
            var errors = new List<string>();
            
            if (string.IsNullOrWhiteSpace(FullName))
                errors.Add("Full Name is required");
            
            if (string.IsNullOrWhiteSpace(Email) || !IsValidEmail(Email))
                errors.Add("Valid Email is required");
            
            if (string.IsNullOrWhiteSpace(ContactNumber))
                errors.Add("Contact Number is required");
            
            if (string.IsNullOrWhiteSpace(CNIC))
                errors.Add("CNIC is required");
            
            if (string.IsNullOrWhiteSpace(Address))
                errors.Add("Address is required");
            
            if (Salary <= 0)
                errors.Add("Salary must be greater than 0");
            
            return errors;
        }
        
        private bool IsValidEmail(string email)
        {
            try
            {
                var addr = new System.Net.Mail.MailAddress(email);
                return addr.Address == email;
            }
            catch
            {
                return false;
            }
        }
    }
}