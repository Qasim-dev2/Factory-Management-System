using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace FactoryManagmentSystem.Models.Entities;

public class Deal
{
    [Key]
    public int DealID { get; set; }
    
    [Required]
    [StringLength(100)]
    public string DealTitle { get; set; } = string.Empty;
    
    [StringLength(50)]
    public string? DealType { get; set; }
    
    [StringLength(100)]
    public string? ClientName { get; set; }
    
    [StringLength(100)]
    public string? ContactPerson { get; set; }
    
    [StringLength(100)]
    public string? Email { get; set; }
    
    [StringLength(20)]
    public string? Phone { get; set; }
    
    [Column(TypeName = "decimal(18,2)")]
    public decimal? EstimatedValue { get; set; }
    
    [StringLength(10)]
    public string Currency { get; set; } = "PKR";
    
    [StringLength(20)]
    public string Priority { get; set; } = "Medium";
    
    [StringLength(50)]
    public string? ExpectedDuration { get; set; }
    
    public DateTime? StartDate { get; set; }
    
    public DateTime? EndDate { get; set; }
    
    [StringLength(1000)]
    public string? Description { get; set; }
    
    [StringLength(1000)]
    public string? KeyTerms { get; set; }
    
    [StringLength(50)]
    public string? PaymentTerms { get; set; }
    
    [StringLength(50)]
    public string? PaymentMethod { get; set; }
    
    [StringLength(1000)]
    public string? SpecialRequirements { get; set; }
    
    public int? AssignedManagerID { get; set; }
    
    [StringLength(30)]
    public string Status { get; set; } = "Draft";
    
    public int? CreatedBy { get; set; }
    
    public DateTime CreatedDate { get; set; } = DateTime.Now;
    
    public DateTime? UpdatedDate { get; set; }
    
    // Navigation properties
    [ForeignKey("AssignedManagerID")]
    public virtual Employee? AssignedManager { get; set; }
    
    [ForeignKey("CreatedBy")]
    public virtual Employee? CreatedByEmployee { get; set; }
    
    public virtual ICollection<DealItem> DealItems { get; set; } = new List<DealItem>();
}