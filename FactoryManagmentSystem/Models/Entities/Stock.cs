using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace FactoryManagmentSystem.Models.Entities;

public class Stock
{
    [Key]
    public int StockID { get; set; }
    
    [Required]
    public int ProductID { get; set; }
    
    [Required]
    [StringLength(50)]
    public string BatchNo { get; set; } = string.Empty;
    
    public DateTime EntryDate { get; set; } = DateTime.Now;
    
    public int Quantity { get; set; } = 0;
    
    [StringLength(30)]
    public string StockStatus { get; set; } = "Ready";
    
    public int ProgressPercentage { get; set; } = 100;
    
    [StringLength(100)]
    public string? Location { get; set; }
    
    [StringLength(500)]
    public string? Notes { get; set; }
    
    public int? CreatedBy { get; set; }
    
    public DateTime LastUpdated { get; set; } = DateTime.Now;
    
    public DateTime CreatedDate { get; set; } = DateTime.Now;
    
    // Navigation properties
    [ForeignKey("ProductID")]
    public virtual Product Product { get; set; } = null!;
    
    [ForeignKey("CreatedBy")]
    public virtual Employee? CreatedByEmployee { get; set; }
}