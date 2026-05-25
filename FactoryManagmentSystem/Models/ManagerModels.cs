using System.ComponentModel.DataAnnotations;

namespace FactoryManagmentSystem.Models.Manager
{

/// <summary>
/// Base model classes for Manager Dashboard modules
/// These models are designed for easy Entity Framework integration
/// </summary>
/// 
#region Employee Management Models
public class Employee
{
    [Key]
    public int EmployeeId { get; set; }
    
    [Required]
    [StringLength(100)]
    public string FirstName { get; set; } = string.Empty;
    
    [Required]
    [StringLength(100)]
    public string LastName { get; set; } = string.Empty;
    
    [Required]
    [StringLength(50)]
    public string EmployeeNumber { get; set; } = string.Empty;
    
    [Required]
    [StringLength(100)]
    public string Department { get; set; } = string.Empty;
    
    [StringLength(100)]
    public string Position { get; set; } = string.Empty;
    
    [EmailAddress]
    public string Email { get; set; } = string.Empty;
    
    [Phone]
    public string PhoneNumber { get; set; } = string.Empty;
    
    public DateTime HireDate { get; set; }
    
    public decimal Salary { get; set; }
    
    public bool IsActive { get; set; } = true;
    
    public int? ManagerId { get; set; }
    
    public string FullName => $"{FirstName} {LastName}";
}
#endregion

#region Product Management Models
public class Product
{
    [Key]
    public int ProductId { get; set; }
    
    [Required]
    [StringLength(100)]
    public string ProductName { get; set; } = string.Empty;
    
    [Required]
    [StringLength(50)]
    public string ProductCode { get; set; } = string.Empty;
    
    [StringLength(500)]
    public string Description { get; set; } = string.Empty;
    
    [Required]
    public string Category { get; set; } = string.Empty;
    
    [Range(0, double.MaxValue)]
    public decimal UnitPrice { get; set; }
    
    [Range(0, int.MaxValue)]
    public int StockQuantity { get; set; }
    
    [Range(0, int.MaxValue)]
    public int MinimumStock { get; set; }
    
    public bool IsActive { get; set; } = true;
    
    public DateTime CreatedDate { get; set; } = DateTime.Now;
    public DateTime? LastModified { get; set; }
}
#endregion

#region Raw Materials Models
public class RawMaterial
{
    [Key]
    public int MaterialId { get; set; }
    
    [Required]
    [StringLength(100)]
    public string MaterialName { get; set; } = string.Empty;
    
    [Required]
    [StringLength(50)]
    public string MaterialCode { get; set; } = string.Empty;
    
    [StringLength(50)]
    public string Unit { get; set; } = string.Empty; // kg, tons, liters, etc.
    
    [Range(0, double.MaxValue)]
    public decimal UnitCost { get; set; }
    
    [Range(0, double.MaxValue)]
    public double CurrentStock { get; set; }
    
    [Range(0, double.MaxValue)]  
    public double MinimumStock { get; set; }
    
    public int SupplierId { get; set; }
    
    public bool IsActive { get; set; } = true;
}

public class Supplier
{
    [Key]
    public int SupplierId { get; set; }
    
    [Required]
    [StringLength(200)]
    public string CompanyName { get; set; } = string.Empty;
    
    [StringLength(100)]
    public string ContactPerson { get; set; } = string.Empty;
    
    [EmailAddress]
    public string Email { get; set; } = string.Empty;
    
    [Phone]
    public string PhoneNumber { get; set; } = string.Empty;
    
    [StringLength(500)]
    public string Address { get; set; } = string.Empty;
    
    public bool IsActive { get; set; } = true;
}
#endregion

#region Stock Management Models
public class StockEntry
{
    [Key]
    public int StockEntryId { get; set; }
    
    public int ProductId { get; set; }
    public Product Product { get; set; } = null!;
    
    [Required]
    public string TransactionType { get; set; } = string.Empty; // IN, OUT, TRANSFER
    
    [Range(0, int.MaxValue)]
    public int Quantity { get; set; }
    
    [StringLength(200)]
    public string Reference { get; set; } = string.Empty;
    
    [StringLength(500)]
    public string Notes { get; set; } = string.Empty;
    
    public DateTime TransactionDate { get; set; } = DateTime.Now;
    
    public int CreatedBy { get; set; }
}
#endregion

#region Deals Management Models
public class Deal
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
    
    [Range(0, double.MaxValue)]
    public decimal DealValue { get; set; }
    
    [StringLength(20)]
    public string Status { get; set; } = "Pending"; // Pending, Approved, Rejected
    
    [StringLength(1000)]
    public string Description { get; set; } = string.Empty;
    
    public DateTime CreatedDate { get; set; } = DateTime.Now;
    public DateTime? ApprovedDate { get; set; }
    
    public int? ApprovedBy { get; set; }
    
    [StringLength(500)]
    public string ApprovalNotes { get; set; } = string.Empty;
}
#endregion

#region Sales Orders Models
public class SalesOrder
{
    [Key]
    public int OrderId { get; set; }
    
    [Required]
    [StringLength(50)]
    public string OrderNumber { get; set; } = string.Empty;
    
    public int CustomerId { get; set; }
    
    public DateTime OrderDate { get; set; } = DateTime.Now;
    
    public DateTime? DeliveryDate { get; set; }
    
    [Range(0, double.MaxValue)]
    public decimal TotalAmount { get; set; }
    
    [StringLength(20)]
    public string Status { get; set; } = "Pending"; // Pending, Processing, Shipped, Delivered, Cancelled
    
    [StringLength(500)]
    public string Notes { get; set; } = string.Empty;
    
    public List<SalesOrderItem> OrderItems { get; set; } = new List<SalesOrderItem>();
}

public class SalesOrderItem
{
    [Key]
    public int OrderItemId { get; set; }
    
    public int OrderId { get; set; }
    public SalesOrder Order { get; set; } = null!;
    
    public int ProductId { get; set; }
    public Product Product { get; set; } = null!;
    
    [Range(1, int.MaxValue)]
    public int Quantity { get; set; }
    
    [Range(0, double.MaxValue)]
    public decimal UnitPrice { get; set; }
    
    [Range(0, double.MaxValue)]
    public decimal TotalPrice { get; set; }
}
#endregion

#region Machinery Models
public class Machine
{
    [Key]
    public int MachineId { get; set; }
    
    [Required]
    [StringLength(100)]
    public string MachineName { get; set; } = string.Empty;
    
    [Required]
    [StringLength(50)]
    public string MachineCode { get; set; } = string.Empty;
    
    [StringLength(100)]
    public string Manufacturer { get; set; } = string.Empty;
    
    [StringLength(50)]
    public string Model { get; set; } = string.Empty;
    
    public DateTime InstallationDate { get; set; }
    
    [StringLength(20)]
    public string Status { get; set; } = "Operational"; // Operational, Maintenance, Breakdown, Retired
    
    public DateTime? LastMaintenanceDate { get; set; }
    public DateTime? NextMaintenanceDate { get; set; }
    
    [StringLength(500)]
    public string Notes { get; set; } = string.Empty;
}

public class MaintenanceRecord
{
    [Key]
    public int MaintenanceId { get; set; }
    
    public int MachineId { get; set; }
    public Machine Machine { get; set; } = null!;
    
    [Required]
    [StringLength(20)]
    public string MaintenanceType { get; set; } = string.Empty; // Preventive, Corrective, Emergency
    
    [StringLength(500)]
    public string Description { get; set; } = string.Empty;
    
    public DateTime MaintenanceDate { get; set; }
    
    [Range(0, double.MaxValue)]
    public decimal Cost { get; set; }
    
    public int TechnicianId { get; set; }
    
    [StringLength(20)]
    public string Status { get; set; } = "Completed"; // Scheduled, InProgress, Completed
}
#endregion

#region Vehicle Models
public class Vehicle
{
    [Key]
    public int VehicleId { get; set; }
    
    [Required]
    [StringLength(20)]
    public string LicensePlate { get; set; } = string.Empty;
    
    [Required]
    [StringLength(50)]
    public string VehicleType { get; set; } = string.Empty; // Truck, Van, Car
    
    [StringLength(50)]
    public string Make { get; set; } = string.Empty;
    
    [StringLength(50)]
    public string Model { get; set; } = string.Empty;
    
    public int Year { get; set; }
    
    [StringLength(20)]
    public string Status { get; set; } = "Available"; // Available, InUse, Maintenance, Retired
    
    public int? AssignedDriverId { get; set; }
    
    public DateTime? LastServiceDate { get; set; }
    public DateTime? NextServiceDate { get; set; }
    
    [Range(0, double.MaxValue)]
    public double Mileage { get; set; }
}
#endregion

#region Delivery Models
public class Delivery
{
    [Key]
    public int DeliveryId { get; set; }
    
    [Required]
    [StringLength(50)]
    public string DeliveryNumber { get; set; } = string.Empty;
    
    public int OrderId { get; set; }
    public SalesOrder Order { get; set; } = null!;
    
    public int? VehicleId { get; set; }
    public Vehicle? Vehicle { get; set; }
    
    public int? DriverId { get; set; }
    
    public DateTime ScheduledDate { get; set; }
    public DateTime? ActualDeliveryDate { get; set; }
    
    [StringLength(500)]
    public string DeliveryAddress { get; set; } = string.Empty;
    
    [StringLength(20)]
    public string Status { get; set; } = "Scheduled"; // Scheduled, InTransit, Delivered, Failed
    
    [StringLength(500)]
    public string Notes { get; set; } = string.Empty;
}
#endregion

#region Customer Model
public class Customer
{
    [Key]
    public int CustomerId { get; set; }
    
    [Required]
    [StringLength(200)]
    public string CompanyName { get; set; } = string.Empty;
    
    [StringLength(100)]
    public string ContactPerson { get; set; } = string.Empty;
    
    [EmailAddress]
    public string Email { get; set; } = string.Empty;
    
    [Phone]
    public string PhoneNumber { get; set; } = string.Empty;
    
    [StringLength(500)]
    public string Address { get; set; } = string.Empty;
    
    public bool IsActive { get; set; } = true;
    
    public DateTime CreatedDate { get; set; } = DateTime.Now;
}
#endregion
}