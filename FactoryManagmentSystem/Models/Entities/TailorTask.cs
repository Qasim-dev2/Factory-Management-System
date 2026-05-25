using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace FactoryManagmentSystem.Models.Entities;

public class TailorTask
{
    [Key]
    public int TailorTaskID { get; set; }
    
    [Required]
    public int EmployeeID { get; set; }
    
    [Required]
    public int ProductionOrderID { get; set; }
    
    public int QuantityAssigned { get; set; } = 0;
    
    public int QuantityCompleted { get; set; } = 0;
    
    public DateTime? StartDate { get; set; }
    
    public DateTime? EndDate { get; set; }
    
    [StringLength(50)]
    public string Status { get; set; } = "Assigned";
    
    [StringLength(500)]
    public string? Notes { get; set; }
    
    // Navigation properties
    [ForeignKey("EmployeeID")]
    public virtual Employee Employee { get; set; } = null!;
    
    [ForeignKey("ProductionOrderID")]
    public virtual ProductionOrder ProductionOrder { get; set; } = null!;
}