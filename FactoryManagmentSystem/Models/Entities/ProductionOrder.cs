using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace FactoryManagmentSystem.Models.Entities;

public class ProductionOrder
{
    [Key]
    public int ProductionOrderID { get; set; }
    
    [Required]
    public int ProductID { get; set; }
    
    public int QuantityOrdered { get; set; } = 0;
    
    public int QuantityCompleted { get; set; } = 0;
    
    public DateTime? StartDate { get; set; }
    
    public DateTime? ExpectedEndDate { get; set; }
    
    public DateTime? ActualEndDate { get; set; }
    
    [StringLength(50)]
    public string Status { get; set; } = "Pending";
    
    [StringLength(20)]
    public string Priority { get; set; } = "Normal";
    
    [StringLength(500)]
    public string? Notes { get; set; }
    
    public int? CreatedByEmployeeID { get; set; }
    
    public DateTime CreatedDate { get; set; } = DateTime.Now;
    
    public DateTime? UpdatedDate { get; set; }
    
    // Navigation properties
    [ForeignKey("ProductID")]
    public virtual Product Product { get; set; } = null!;
    
    [ForeignKey("CreatedByEmployeeID")]
    public virtual Employee? CreatedByEmployee { get; set; }
    
    public virtual ICollection<ProductionOrderItem> ProductionOrderItems { get; set; } = new List<ProductionOrderItem>();
    
    public virtual ICollection<TailorTask> TailorTasks { get; set; } = new List<TailorTask>();
    
    public virtual ICollection<StockUsage> StockUsages { get; set; } = new List<StockUsage>();
}