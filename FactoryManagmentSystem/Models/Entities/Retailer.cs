using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace FactoryManagmentSystem.Models.Entities;

public class Retailer
{
    [Key]
    public int RetailerID { get; set; }
    
    [Required]
    [StringLength(100)]
    public string CompanyName { get; set; } = string.Empty;
    
    [StringLength(50)]
    public string? BusinessType { get; set; }
    
    [StringLength(50)]
    public string? RegistrationNumber { get; set; }
    
    [StringLength(50)]
    public string? TaxId { get; set; }
    
    [StringLength(100)]
    public string? ContactPerson { get; set; }
    
    [StringLength(50)]
    public string? Designation { get; set; }
    
    [StringLength(20)]
    public string? Phone { get; set; }
    
    [StringLength(100)]
    public string? Email { get; set; }
    
    [StringLength(20)]
    public string? AlternativePhone { get; set; }
    
    [StringLength(500)]
    public string? Address { get; set; }
    
    [StringLength(50)]
    public string? City { get; set; }
    
    [StringLength(50)]
    public string? Province { get; set; }
    
    [StringLength(10)]
    public string? PostalCode { get; set; }
    
    [Column(TypeName = "decimal(18,2)")]
    public decimal CreditLimit { get; set; } = 0;
    
    [StringLength(30)]
    public string? PaymentTerms { get; set; }
    
    [Column(TypeName = "decimal(5,2)")]
    public decimal DiscountPercentage { get; set; } = 0;
    
    public int? SalesRepID { get; set; }
    
    [StringLength(20)]
    public string Priority { get; set; } = "Regular";
    
    [StringLength(100)]
    public string? BankName { get; set; }
    
    [StringLength(50)]
    public string? AccountNumber { get; set; }
    
    [StringLength(100)]
    public string? AccountTitle { get; set; }
    
    [StringLength(20)]
    public string? BranchCode { get; set; }
    
    [StringLength(20)]
    public string Status { get; set; } = "Active";
    
    [StringLength(200)]
    public string? Website { get; set; }
    
    [StringLength(1000)]
    public string? Notes { get; set; }
    
    [StringLength(200)]
    public string? Tags { get; set; }
    
    [Column(TypeName = "decimal(18,2)")]
    public decimal CurrentBalance { get; set; } = 0;
    
    public bool IsActive { get; set; } = true;
    
    public DateTime CreatedDate { get; set; } = DateTime.Now;
    
    public DateTime? UpdatedDate { get; set; }
    
    // Navigation properties
    [ForeignKey("SalesRepID")]
    public virtual Employee? SalesRep { get; set; }
    
    public virtual ICollection<SalesOrder> SalesOrders { get; set; } = new List<SalesOrder>();
}