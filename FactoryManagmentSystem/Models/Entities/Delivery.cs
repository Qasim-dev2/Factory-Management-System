using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace FactoryManagmentSystem.Models.Entities;

public class Delivery
{
    [Key]
    public int DeliveryID { get; set; }
    
    [Required]
    public int SalesOrderID { get; set; }
    
    public int? DeliveredBy { get; set; }
    
    public DateTime? DeliveryDate { get; set; }
    
    [StringLength(500)]
    public string? DeliveryAddress { get; set; }
    
    [StringLength(50)]
    public string? City { get; set; }
    
    [StringLength(50)]
    public string? Province { get; set; }
    
    [StringLength(10)]
    public string? PostalCode { get; set; }
    
    [StringLength(100)]
    public string? TrackingNumber { get; set; }
    
    [StringLength(50)]
    public string? DeliveryMethod { get; set; }
    
    [Column(TypeName = "decimal(18,2)")]
    public decimal DeliveryCost { get; set; } = 0;
    
    [StringLength(50)]
    public string Status { get; set; } = "Pending";
    
    [StringLength(100)]
    public string? ReceiverName { get; set; }
    
    [StringLength(20)]
    public string? ReceiverPhone { get; set; }
    
    [StringLength(500)]
    public string? Notes { get; set; }
    
    public DateTime CreatedDate { get; set; } = DateTime.Now;
    
    public DateTime? UpdatedDate { get; set; }
    
    // Navigation properties
    [ForeignKey("SalesOrderID")]
    public virtual SalesOrder SalesOrder { get; set; } = null!;
    
    [ForeignKey("DeliveredBy")]
    public virtual Employee? DeliveredByEmployee { get; set; }
}