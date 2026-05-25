using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace FactoryManagmentSystem.Models.Entities;

public class DealItem
{
    [Key]
    public int DealItemID { get; set; }
    
    [Required]
    public int DealID { get; set; }
    
    [Required]
    public int ProductID { get; set; }
    
    public int Quantity { get; set; } = 1;
    
    [Column(TypeName = "decimal(18,2)")]
    public decimal UnitPrice { get; set; } = 0;
    
    // Navigation properties
    [ForeignKey("DealID")]
    public virtual Deal Deal { get; set; } = null!;
    
    [ForeignKey("ProductID")]
    public virtual Product Product { get; set; } = null!;
}