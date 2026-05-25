using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace FactoryManagmentSystem.Models.Entities;

public class Employee
{
    [Key]
    public int EmployeeID { get; set; }
    
    [Required]
    [StringLength(100)]
    public string Name { get; set; } = string.Empty;
    
    [Required]
    [StringLength(100)]
    public string Email { get; set; } = string.Empty;
    
    [Required]
    [StringLength(20)]
    public string Phone { get; set; } = string.Empty;
    
    [StringLength(200)]
    public string? Address { get; set; }
    
    public DateTime DateOfBirth { get; set; }
    
    public DateTime HireDate { get; set; } = DateTime.Now;
    
    [Column(TypeName = "decimal(18,2)")]
    public decimal BaseSalary { get; set; } = 0;
    
    [StringLength(20)]
    public string Status { get; set; } = "Active";
    
    // Department relationship
    [Required]
    public int DepartmentID { get; set; }
    
    // Role relationship
    [Required]
    public int RoleID { get; set; }
    
    // Salesperson specific fields (nullable for non-salesperson employees)
    [Column(TypeName = "decimal(5,2)")]
    public decimal? CommissionRate { get; set; }
    
    [Column(TypeName = "decimal(18,2)")]
    public decimal? TotalSales { get; set; }
    
    public int? SalesTarget { get; set; }
    
    // Tailor specific fields (nullable for non-tailor employees)
    public int? ProductionTarget { get; set; }
    
    // Common fields
    public DateTime CreatedDate { get; set; } = DateTime.Now;
    
    public DateTime? LastModified { get; set; }
    
    // Navigation properties
    [ForeignKey("DepartmentID")]
    public virtual Department Department { get; set; } = null!;
    
    [ForeignKey("RoleID")]
    public virtual EmployeeRole EmployeeRole { get; set; } = null!;
    
    // Navigation properties for related entities
    public virtual ICollection<Stock> CreatedStocks { get; set; } = new List<Stock>();
    public virtual ICollection<SalesOrder> SalesOrders { get; set; } = new List<SalesOrder>();
    public virtual ICollection<ProductionOrder> ProductionOrders { get; set; } = new List<ProductionOrder>();
    public virtual ICollection<TailorTask> TailorTasks { get; set; } = new List<TailorTask>();
    public virtual ICollection<Delivery> Deliveries { get; set; } = new List<Delivery>();
}