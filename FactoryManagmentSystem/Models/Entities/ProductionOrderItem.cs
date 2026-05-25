using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace FactoryManagmentSystem.Models.Entities;

public class ProductionOrderItem
{
    [Key]
    public int ProductionOrderItemID { get; set; }
    
    [Required]
    public int ProductionOrderID { get; set; }
    
    [Required]
    public int RawMaterialID { get; set; }
    
    [Column(TypeName = "decimal(18,2)")]
    public decimal QuantityRequired { get; set; } = 0;
    
    [Column(TypeName = "decimal(18,2)")]
    public decimal QuantityUsed { get; set; } = 0;
    
    // Navigation properties
    [ForeignKey("ProductionOrderID")]
    public virtual ProductionOrder ProductionOrder { get; set; } = null!;
    
    [ForeignKey("RawMaterialID")]
    public virtual RawMaterial RawMaterial { get; set; } = null!;
}