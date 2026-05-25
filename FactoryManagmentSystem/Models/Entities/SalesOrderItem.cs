using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace FactoryManagmentSystem.Models.Entities;

public class SalesOrderItem
{
    [Key]
    public int SalesOrderItemID { get; set; }
    
    [Required]
    public int SalesOrderID { get; set; }
    
    [Required]
    public int ProductID { get; set; }
    
    [StringLength(20)]
    public string? Size { get; set; }
    
    [StringLength(50)]
    public string? Color { get; set; }
    
    public int Quantity { get; set; } = 1;
    
    [Column(TypeName = "decimal(18,2)")]
    public decimal UnitPrice { get; set; } = 0;
    
    [Column(TypeName = "decimal(18,2)")]
    public decimal Discount { get; set; } = 0;
    
    [Column(TypeName = "decimal(18,2)")]
    public decimal TotalPrice { get; set; } = 0;
    
    // Navigation properties
    [ForeignKey("SalesOrderID")]
    public virtual SalesOrder SalesOrder { get; set; } = null!;
    
    [ForeignKey("ProductID")]
    public virtual Product Product { get; set; } = null!;
}