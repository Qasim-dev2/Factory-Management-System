using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace FactoryManagmentSystem.Models.Entities;

public class Product
{
    [Key]
    public int ProductID { get; set; }
    
    [Required]
    [StringLength(100)]
    public string ProductName { get; set; } = string.Empty;
    
    [StringLength(1000)]
    public string? Description { get; set; }
    
    [StringLength(50)]
    public string? Category { get; set; }
    
    [StringLength(100)]
    public string? Brand { get; set; }
    
    [Column(TypeName = "decimal(18,2)")]
    public decimal SalePrice { get; set; } = 0;
    
    [Column(TypeName = "decimal(18,2)")]
    public decimal CostPrice { get; set; } = 0;
    
    [StringLength(50)]
    public string? Material { get; set; }
    
    [StringLength(100)]
    public string? AvailableSizes { get; set; }
    
    [StringLength(200)]
    public string? AvailableColors { get; set; }
    
    public int StockQuantity { get; set; } = 0;
    
    public int MinimumStock { get; set; } = 10;
    
    [StringLength(100)]
    public string? Supplier { get; set; }
    
    [StringLength(500)]
    public string? ImageUrl { get; set; }
    
    [StringLength(30)]
    public string ProductionStatus { get; set; } = "Active";
    
    [StringLength(50)]
    public string? SKU { get; set; }
    
    public bool IsActive { get; set; } = true;
    
    public DateTime CreatedDate { get; set; } = DateTime.Now;
    
    public DateTime? UpdatedDate { get; set; }
    
    // Navigation properties
    public virtual ICollection<Stock> Stocks { get; set; } = new List<Stock>();
    public virtual ICollection<ProductionOrder> ProductionOrders { get; set; } = new List<ProductionOrder>();
}