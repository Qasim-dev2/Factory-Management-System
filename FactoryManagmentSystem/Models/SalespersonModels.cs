using System.ComponentModel.DataAnnotations;

namespace FactoryManagmentSystem.Models.Salesperson
{
    /// <summary>
    /// Data models for Salesperson Dashboard modules
    /// Designed for easy Entity Framework integration
    /// </summary>
    /// 
    #region Customer Management Models
    public class SalesCustomer
    {
        [Key]
        public int CustomerId { get; set; }
        
        [Required]
        [StringLength(200)]
        public string CompanyName { get; set; } = string.Empty;
        
        [StringLength(100)]
        public string ContactPerson { get; set; } = string.Empty;
        
        [StringLength(100)]
        public string Position { get; set; } = string.Empty;
        
        [EmailAddress]
        public string Email { get; set; } = string.Empty;
        
        [Phone]
        public string PhoneNumber { get; set; } = string.Empty;
        
        [StringLength(500)]
        public string Address { get; set; } = string.Empty;
        
        [StringLength(100)]
        public string City { get; set; } = string.Empty;
        
        [StringLength(50)]
        public string State { get; set; } = string.Empty;
        
        [StringLength(20)]
        public string PostalCode { get; set; } = string.Empty;
        
        [StringLength(50)]
        public string Country { get; set; } = "USA";
        
        public DateTime CreatedDate { get; set; } = DateTime.Now;
        public DateTime? LastContactDate { get; set; }
        
        [StringLength(20)]
        public string Status { get; set; } = "Active"; // Active, Inactive, Prospect, Lead
        
        [StringLength(20)]
        public string Priority { get; set; } = "Medium"; // High, Medium, Low
        
        public int AssignedSalespersonId { get; set; }
        
        [StringLength(1000)]
        public string Notes { get; set; } = string.Empty;
        
        // Navigation properties
        public List<SalesDeal> Deals { get; set; } = new List<SalesDeal>();
        public List<SalesOrderHeader> Orders { get; set; } = new List<SalesOrderHeader>();
    }
    #endregion

    #region Deal Management Models
    public class SalesDeal
    {
        [Key]
        public int DealId { get; set; }
        
        [Required]
        [StringLength(100)]
        public string DealTitle { get; set; } = string.Empty;
        
        [Required]
        [StringLength(50)]
        public string DealNumber { get; set; } = string.Empty;
        
        public int CustomerId { get; set; }
        public SalesCustomer Customer { get; set; } = null!;
        
        [Range(0, double.MaxValue)]
        public decimal EstimatedValue { get; set; }
        
        [Range(0, 100)]
        public int ProbabilityPercent { get; set; } = 50;
        
        [StringLength(20)]
        public string Stage { get; set; } = "Prospecting"; // Prospecting, Qualified, Proposal, Negotiation, Closing, Won, Lost
        
        [StringLength(20)]
        public string Priority { get; set; } = "Medium"; // High, Medium, Low
        
        public DateTime CreatedDate { get; set; } = DateTime.Now;
        public DateTime? ExpectedCloseDate { get; set; }
        public DateTime? ActualCloseDate { get; set; }
        
        public int SalespersonId { get; set; }
        
        [StringLength(1000)]
        public string Description { get; set; } = string.Empty;
        
        [StringLength(500)]
        public string CompetitorInfo { get; set; } = string.Empty;
        
        [StringLength(500)]
        public string NextSteps { get; set; } = string.Empty;
        
        public bool IsActive { get; set; } = true;
        
        // Navigation properties
        public List<DealActivity> Activities { get; set; } = new List<DealActivity>();
        public List<DealProduct> Products { get; set; } = new List<DealProduct>();
    }

    public class DealActivity
    {
        [Key]
        public int ActivityId { get; set; }
        
        public int DealId { get; set; }
        public SalesDeal Deal { get; set; } = null!;
        
        [Required]
        [StringLength(20)]
        public string ActivityType { get; set; } = string.Empty; // Call, Email, Meeting, Demo, Proposal
        
        [Required]
        [StringLength(200)]
        public string Subject { get; set; } = string.Empty;
        
        [StringLength(1000)]
        public string Description { get; set; } = string.Empty;
        
        public DateTime ActivityDate { get; set; } = DateTime.Now;
        
        [StringLength(20)]
        public string Status { get; set; } = "Completed"; // Scheduled, Completed, Cancelled
        
        public int CreatedBy { get; set; }
    }

    public class DealProduct
    {
        [Key]
        public int DealProductId { get; set; }
        
        public int DealId { get; set; }
        public SalesDeal Deal { get; set; } = null!;
        
        [Required]
        [StringLength(100)]
        public string ProductName { get; set; } = string.Empty;
        
        [StringLength(50)]
        public string ProductCode { get; set; } = string.Empty;
        
        [Range(1, int.MaxValue)]
        public int Quantity { get; set; }
        
        [Range(0, double.MaxValue)]
        public decimal UnitPrice { get; set; }
        
        [Range(0, double.MaxValue)]
        public decimal TotalPrice { get; set; }
        
        [StringLength(500)]
        public string Notes { get; set; } = string.Empty;
    }
    #endregion

    #region Sales Order Models
    public class SalesOrderHeader
    {
        [Key]
        public int OrderId { get; set; }
        
        [Required]
        [StringLength(50)]
        public string OrderNumber { get; set; } = string.Empty;
        
        public int CustomerId { get; set; }
        public SalesCustomer Customer { get; set; } = null!;
        
        public DateTime OrderDate { get; set; } = DateTime.Now;
        
        public DateTime? RequestedDeliveryDate { get; set; }
        public DateTime? ConfirmedDeliveryDate { get; set; }
        
        [Range(0, double.MaxValue)]
        public decimal SubtotalAmount { get; set; }
        
        [Range(0, double.MaxValue)]
        public decimal TaxAmount { get; set; }
        
        [Range(0, double.MaxValue)]
        public decimal TotalAmount { get; set; }
        
        [StringLength(20)]
        public string Status { get; set; } = "Draft"; // Draft, Submitted, Approved, Processing, Shipped, Delivered, Cancelled
        
        [StringLength(20)]
        public string PaymentTerms { get; set; } = "Net 30";
        
        [StringLength(20)]
        public string ShippingMethod { get; set; } = "Standard";
        
        [StringLength(500)]
        public string ShippingAddress { get; set; } = string.Empty;
        
        [StringLength(500)]
        public string BillingAddress { get; set; } = string.Empty;
        
        public int SalespersonId { get; set; }
        
        [StringLength(1000)]
        public string Notes { get; set; } = string.Empty;
        
        // Navigation properties
        public List<SalesOrderLine> OrderLines { get; set; } = new List<SalesOrderLine>();
        public List<SalesDelivery> Deliveries { get; set; } = new List<SalesDelivery>();
    }

    public class SalesOrderLine
    {
        [Key]
        public int OrderLineId { get; set; }
        
        public int OrderId { get; set; }
        public SalesOrderHeader Order { get; set; } = null!;
        
        [Required]
        [StringLength(100)]
        public string ProductName { get; set; } = string.Empty;
        
        [StringLength(50)]
        public string ProductCode { get; set; } = string.Empty;
        
        [StringLength(500)]
        public string ProductDescription { get; set; } = string.Empty;
        
        [Range(1, int.MaxValue)]
        public int QuantityOrdered { get; set; }
        
        [Range(0, int.MaxValue)]
        public int QuantityShipped { get; set; } = 0;
        
        [Range(0, double.MaxValue)]
        public decimal UnitPrice { get; set; }
        
        [Range(0, 100)]
        public decimal DiscountPercent { get; set; } = 0;
        
        [Range(0, double.MaxValue)]
        public decimal LineTotal { get; set; }
        
        [StringLength(20)]
        public string Status { get; set; } = "Pending"; // Pending, Backordered, Shipped, Delivered
    }
    #endregion

    #region Delivery Models
    public class SalesDelivery
    {
        [Key]
        public int DeliveryId { get; set; }
        
        [Required]
        [StringLength(50)]
        public string DeliveryNumber { get; set; } = string.Empty;
        
        public int OrderId { get; set; }
        public SalesOrderHeader Order { get; set; } = null!;
        
        public DateTime ScheduledDate { get; set; }
        public DateTime? ActualDeliveryDate { get; set; }
        
        [StringLength(500)]
        public string DeliveryAddress { get; set; } = string.Empty;
        
        [StringLength(100)]
        public string DeliveryContact { get; set; } = string.Empty;
        
        [Phone]
        public string ContactPhone { get; set; } = string.Empty;
        
        [StringLength(20)]
        public string Status { get; set; } = "Scheduled"; // Scheduled, InTransit, Delivered, Failed, Cancelled
        
        [StringLength(50)]
        public string TrackingNumber { get; set; } = string.Empty;
        
        [StringLength(100)]
        public string CarrierName { get; set; } = string.Empty;
        
        [StringLength(100)]
        public string DriverName { get; set; } = string.Empty;
        
        [Phone]
        public string DriverPhone { get; set; } = string.Empty;
        
        [StringLength(1000)]
        public string DeliveryNotes { get; set; } = string.Empty;
        
        [StringLength(500)]
        public string SpecialInstructions { get; set; } = string.Empty;
        
        public int SalespersonId { get; set; }
        
        // Navigation properties
        public List<DeliveryItem> Items { get; set; } = new List<DeliveryItem>();
    }

    public class DeliveryItem
    {
        [Key]
        public int DeliveryItemId { get; set; }
        
        public int DeliveryId { get; set; }
        public SalesDelivery Delivery { get; set; } = null!;
        
        public int OrderLineId { get; set; }
        public SalesOrderLine OrderLine { get; set; } = null!;
        
        [Range(1, int.MaxValue)]
        public int QuantityDelivered { get; set; }
        
        [StringLength(500)]
        public string ItemNotes { get; set; } = string.Empty;
    }
    #endregion

    #region Stock View Models (Read-Only)
    public class SalespersonStockItem
    {
        [Key]
        public int StockItemId { get; set; }
        
        [Required]
        [StringLength(100)]
        public string ProductName { get; set; } = string.Empty;
        
        [Required]
        [StringLength(50)]
        public string ProductCode { get; set; } = string.Empty;
        
        [StringLength(500)]
        public string Description { get; set; } = string.Empty;
        
        [StringLength(50)]
        public string Category { get; set; } = string.Empty;
        
        [Range(0, int.MaxValue)]
        public int CurrentStock { get; set; }
        
        [Range(0, int.MaxValue)]
        public int ReservedStock { get; set; }
        
        [Range(0, int.MaxValue)]
        public int AvailableStock { get; set; }
        
        [Range(0, int.MaxValue)]
        public int MinimumStock { get; set; }
        
        [Range(0, double.MaxValue)]
        public decimal UnitPrice { get; set; }
        
        [StringLength(20)]
        public string Unit { get; set; } = "Each";
        
        public DateTime LastUpdated { get; set; } = DateTime.Now;
        
        public bool IsActive { get; set; } = true;
        
        // Read-only computed property
        public string StockStatus => CurrentStock <= MinimumStock ? "Low Stock" : 
                                    CurrentStock == 0 ? "Out of Stock" : "In Stock";
    }
    #endregion

    #region Sales Analytics Models
    public class SalesPerformance
    {
        [Key]
        public int PerformanceId { get; set; }
        
        public int SalespersonId { get; set; }
        
        public DateTime PeriodStart { get; set; }
        public DateTime PeriodEnd { get; set; }
        
        [Range(0, double.MaxValue)]
        public decimal TotalSales { get; set; }
        
        [Range(0, double.MaxValue)]
        public decimal Target { get; set; }
        
        [Range(0, int.MaxValue)]
        public int DealsWon { get; set; }
        
        [Range(0, int.MaxValue)]
        public int DealsLost { get; set; }
        
        [Range(0, int.MaxValue)]
        public int NewCustomers { get; set; }
        
        [Range(0, 100)]
        public decimal WinRate { get; set; }
        
        [Range(0, double.MaxValue)]
        public decimal AverageDealSize { get; set; }
        
        public DateTime CreatedDate { get; set; } = DateTime.Now;
    }
    #endregion
}