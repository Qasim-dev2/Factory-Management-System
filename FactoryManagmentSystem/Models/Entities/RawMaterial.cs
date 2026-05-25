using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace FactoryManagmentSystem.Models.Entities;

public class RawMaterial
{
    [Key]
    public int RawMaterialID { get; set; }
    
    [Required]
    [StringLength(100)]
    public string MaterialName { get; set; } = string.Empty;
    
    [StringLength(50)]
    public string? Category { get; set; }
    
    [StringLength(20)]
    public string? Unit { get; set; }
    
    [Column(TypeName = "decimal(18,2)")]
    public decimal Quantity { get; set; } = 0;
    
    [Column(TypeName = "decimal(18,2)")]
    public decimal MinimumStock { get; set; } = 0;
    
    [Column(TypeName = "decimal(18,2)")]
    public decimal UnitPrice { get; set; } = 0;
    
    [StringLength(100)]
    public string? Supplier { get; set; }
    
    [StringLength(100)]
    public string? SupplierContact { get; set; }
    
    [StringLength(500)]
    public string? Description { get; set; }
    
    [StringLength(20)]
    public string StockStatus { get; set; } = "In Stock";
    
    public DateTime? LastRestockDate { get; set; }
    
    public bool IsActive { get; set; } = true;
    
    public DateTime CreatedDate { get; set; } = DateTime.Now;
    
    public DateTime? UpdatedDate { get; set; }
    
    // Navigation properties
    public virtual ICollection<StockUsage> StockUsages { get; set; } = new List<StockUsage>();
}