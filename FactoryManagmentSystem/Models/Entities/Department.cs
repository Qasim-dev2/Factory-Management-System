using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace FactoryManagmentSystem.Models.Entities;

public class Department
{
    [Key]
    public int DepartmentID { get; set; }
    
    [Required]
    [StringLength(100)]
    public string DepartmentName { get; set; } = string.Empty;
    
    [StringLength(500)]
    public string? Description { get; set; }
    
    public bool IsActive { get; set; } = true;
    
    public DateTime CreatedDate { get; set; } = DateTime.Now;
    
    public DateTime? LastModified { get; set; }
    
    // Navigation property
    public virtual ICollection<Employee> Employees { get; set; } = new List<Employee>();
}