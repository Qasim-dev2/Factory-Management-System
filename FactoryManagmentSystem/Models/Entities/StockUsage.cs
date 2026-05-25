using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace FactoryManagmentSystem.Models.Entities;

public class StockUsage
{
    [Key]
    public int StockUsageID { get; set; }
    
    [Required]
    public int EmployeeID { get; set; }
    
    [Required]
    public int ProductionOrderID { get; set; }
    
    [Required]
    public int RawMaterialID { get; set; }
    
    [Column(TypeName = "decimal(18,2)")]
    public decimal QuantityUsed { get; set; } = 0;
    
    public DateTime UsageDate { get; set; } = DateTime.Now;
    
    [StringLength(500)]
    public string? Notes { get; set; }
    
    // Navigation properties
    [ForeignKey("EmployeeID")]
    public virtual Employee Employee { get; set; } = null!;
    
    [ForeignKey("ProductionOrderID")]
    public virtual ProductionOrder ProductionOrder { get; set; } = null!;
    
    [ForeignKey("RawMaterialID")]
    public virtual RawMaterial RawMaterial { get; set; } = null!;
}