using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace FactoryManagmentSystem.Models.Entities;

public class SalesOrder
{
    [Key]
    public int SalesOrderID { get; set; }
    
    public DateTime OrderDate { get; set; } = DateTime.Now;
    
    public DateTime? ExpectedDeliveryDate { get; set; }
    
    [StringLength(20)]
    public string PriorityLevel { get; set; } = "Medium";
    
    [StringLength(30)]
    public string Status { get; set; } = "Pending";
    
    [Required]
    public int RetailerID { get; set; }
    
    [StringLength(500)]
    public string? ShippingAddress { get; set; }
    
    [StringLength(500)]
    public string? SpecialInstructions { get; set; }
    
    [StringLength(30)]
    public string? PaymentTerms { get; set; }
    
    [Column(TypeName = "decimal(5,2)")]
    public decimal AdvancePaymentPercent { get; set; } = 0;
    
    [Column(TypeName = "decimal(5,2)")]
    public decimal DiscountPercentage { get; set; } = 0;
    
    [StringLength(20)]
    public string PaymentStatus { get; set; } = "Pending";
    
    [Column(TypeName = "decimal(18,2)")]
    public decimal SubTotal { get; set; } = 0;
    
    [Column(TypeName = "decimal(18,2)")]
    public decimal DiscountAmount { get; set; } = 0;
    
    [Column(TypeName = "decimal(18,2)")]
    public decimal TaxAmount { get; set; } = 0;
    
    [Column(TypeName = "decimal(18,2)")]
    public decimal TotalAmount { get; set; } = 0;
    
    public int? SalesRepID { get; set; }
    
    [StringLength(30)]
    public string? OrderSource { get; set; }
    
    [StringLength(1000)]
    public string? InternalNotes { get; set; }
    
    [StringLength(200)]
    public string? Tags { get; set; }
    
    public DateTime CreatedDate { get; set; } = DateTime.Now;
    
    public DateTime? UpdatedDate { get; set; }
    
    // Navigation properties
    [ForeignKey("RetailerID")]
    public virtual Retailer Retailer { get; set; } = null!;
    
    [ForeignKey("SalesRepID")]
    public virtual Employee? SalesRep { get; set; }
    
    public virtual ICollection<SalesOrderItem> SalesOrderItems { get; set; } = new List<SalesOrderItem>();
    
    public virtual Delivery? Delivery { get; set; }
}