// ================================================================================
// FACTORY DATABASE CONTEXT - Ready for Entity Framework Integration
// ================================================================================
// 
// This file contains the complete DbContext configuration for your Factory
// Management System, matching your database tables exactly.
// 
// CONNECTION STRING: Server=QASIM\SQLEXPRESS;Database=GarmentsFactoryDB;
//                    Trusted_Connection=True;TrustServerCertificate=True;
// 
// IMPORTANT: The DbContext code is commented out until you install Entity Framework.
// 
// TO ENABLE DATABASE:
// 1. Run in Package Manager Console:
//    Install-Package Microsoft.EntityFrameworkCore.SqlServer
//    Install-Package Microsoft.EntityFrameworkCore.Tools
//
// 2. Uncomment the code below (remove /* and */)
// 
// NOTE: Since you created tables via SQL script, you don't need migrations.
//       Just uncomment the code and use it directly.
// ================================================================================

using Microsoft.EntityFrameworkCore;
using FactoryManagmentSystem.Models.Entities;

namespace FactoryManagmentSystem.Data;

public class FactoryDbContext : DbContext
{
    // Your SQL Server connection string
    private const string CONNECTION_STRING = 
        "Server=QASIM\\SQLEXPRESS;Database=GarmentsFactoryDB;Trusted_Connection=True;TrustServerCertificate=True;MultipleActiveResultSets=True;";

    public FactoryDbContext(DbContextOptions<FactoryDbContext> options) : base(options)
    {
    }

    public FactoryDbContext()
    {
    }

    #region DbSets - All Tables

    // Core Entities
    public DbSet<Department> Departments { get; set; } = null!;
    public DbSet<EmployeeRole> EmployeeRoles { get; set; } = null!;
    public DbSet<Employee> Employees { get; set; } = null!;

    // Product & Stock Entities
    public DbSet<Product> Products { get; set; } = null!;
    public DbSet<Stock> Stocks { get; set; } = null!;
    public DbSet<RawMaterial> RawMaterials { get; set; } = null!;
    public DbSet<StockUsage> StockUsages { get; set; } = null!;

    // Retailer & Sales Entities
    public DbSet<Retailer> Retailers { get; set; } = null!;
    public DbSet<SalesOrder> SalesOrders { get; set; } = null!;
    public DbSet<SalesOrderItem> SalesOrderItems { get; set; } = null!;

    // Deal Entities
    public DbSet<Deal> Deals { get; set; } = null!;
    public DbSet<DealItem> DealItems { get; set; } = null!;

    // Production Entities
    public DbSet<ProductionOrder> ProductionOrders { get; set; } = null!;
    public DbSet<ProductionOrderItem> ProductionOrderItems { get; set; } = null!;
    public DbSet<TailorTask> TailorTasks { get; set; } = null!;

    // Delivery Entity
    public DbSet<Delivery> Deliveries { get; set; } = null!;

    #endregion

    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
    {
        if (!optionsBuilder.IsConfigured)
        {
            optionsBuilder.UseSqlServer(CONNECTION_STRING);
        }
    }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // Basic model configuration - the database already exists
        // so we just need basic mapping
    }
}

/*
 * ================================================================================
 * UNCOMMENT THIS SECTION AFTER INSTALLING ENTITY FRAMEWORK PACKAGES
 * ================================================================================

using Microsoft.EntityFrameworkCore;
using FactoryManagmentSystem.Models.Entities;

namespace FactoryManagmentSystem.Data;

public class FactoryDbContext : DbContext
{
    // Your SQL Server connection string
    private const string CONNECTION_STRING = 
        "Server=QASIM\\SQLEXPRESS;Database=GarmentsFactoryDB;Trusted_Connection=True;TrustServerCertificate=True;MultipleActiveResultSets=True;";

    public FactoryDbContext(DbContextOptions<FactoryDbContext> options) : base(options)
    {
    }

    public FactoryDbContext()
    {
    }

    #region DbSets - All 16 Tables

    // Core Entities
    public DbSet<Department> Departments { get; set; } = null!;
    public DbSet<EmployeeRole> EmployeeRoles { get; set; } = null!;
    public DbSet<Employee> Employees { get; set; } = null!;  // Includes Salesperson & Tailor fields

    // Product & Stock Entities
    public DbSet<Product> Products { get; set; } = null!;
    public DbSet<Stock> Stocks { get; set; } = null!;
    public DbSet<RawMaterial> RawMaterials { get; set; } = null!;
    public DbSet<StockUsage> StockUsages { get; set; } = null!;

    // Retailer & Sales Entities
    public DbSet<Retailer> Retailers { get; set; } = null!;
    public DbSet<SalesOrder> SalesOrders { get; set; } = null!;
    public DbSet<SalesOrderItem> SalesOrderItems { get; set; } = null!;

    // Deal Entities
    public DbSet<Deal> Deals { get; set; } = null!;
    public DbSet<DealItem> DealItems { get; set; } = null!;

    // Production Entities
    public DbSet<ProductionOrder> ProductionOrders { get; set; } = null!;
    public DbSet<ProductionOrderItem> ProductionOrderItems { get; set; } = null!;
    public DbSet<TailorTask> TailorTasks { get; set; } = null!;

    // Delivery Entity
    public DbSet<Delivery> Deliveries { get; set; } = null!;

    #endregion

    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
    {
        if (!optionsBuilder.IsConfigured)
        {
            optionsBuilder.UseSqlServer(CONNECTION_STRING);
        }
    }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // ================================================================================
        // Department Configuration
        // ================================================================================
        modelBuilder.Entity<Department>(entity =>
        {
            entity.ToTable("Department");
            entity.HasKey(e => e.DepartmentID);
            entity.Property(e => e.DepartmentName).IsRequired().HasMaxLength(100);
            entity.Property(e => e.Description).HasMaxLength(500);
        });

        // ================================================================================
        // EmployeeRole Configuration
        // ================================================================================
        modelBuilder.Entity<EmployeeRole>(entity =>
        {
            entity.ToTable("EmployeeRole");
            entity.HasKey(e => e.RoleID);
            entity.Property(e => e.RoleName).IsRequired().HasMaxLength(50);
            entity.Property(e => e.Description).HasMaxLength(500);
        });

        // ================================================================================
        // Employee Configuration (includes Salesperson & Tailor fields)
        // ================================================================================
        modelBuilder.Entity<Employee>(entity =>
        {
            entity.ToTable("Employee");
            entity.HasKey(e => e.EmployeeID);
            
            // Personal Info
            entity.Property(e => e.FirstName).IsRequired().HasMaxLength(50);
            entity.Property(e => e.LastName).IsRequired().HasMaxLength(50);
            entity.Property(e => e.Email).HasMaxLength(100);
            entity.Property(e => e.Phone).HasMaxLength(20);
            entity.Property(e => e.CNIC).HasMaxLength(15);
            entity.Property(e => e.Address).HasMaxLength(500);
            entity.Property(e => e.EmergencyContact).HasMaxLength(100);
            entity.Property(e => e.Notes).HasMaxLength(1000);
            
            // Work Info
            entity.Property(e => e.Salary).HasColumnType("decimal(18,2)");
            
            // Salesperson Fields (nullable)
            entity.Property(e => e.CommissionRate).HasColumnType("decimal(5,2)");
            entity.Property(e => e.SalesTarget).HasColumnType("decimal(18,2)");
            entity.Property(e => e.TotalSales).HasColumnType("decimal(18,2)");
            entity.Property(e => e.SalesRegion).HasMaxLength(100);

            // Relationships
            entity.HasOne(e => e.Department)
                .WithMany(d => d.Employees)
                .HasForeignKey(e => e.DepartmentID)
                .OnDelete(DeleteBehavior.Restrict);

            entity.HasOne(e => e.Role)
                .WithMany(r => r.Employees)
                .HasForeignKey(e => e.RoleID)
                .OnDelete(DeleteBehavior.Restrict);
        });

        // ================================================================================
        // Product Configuration
        // ================================================================================
        modelBuilder.Entity<Product>(entity =>
        {
            entity.ToTable("Product");
            entity.HasKey(e => e.ProductID);
            entity.Property(e => e.ProductName).IsRequired().HasMaxLength(100);
            entity.Property(e => e.Description).HasMaxLength(1000);
            entity.Property(e => e.Category).HasMaxLength(50);
            entity.Property(e => e.Brand).HasMaxLength(100);
            entity.Property(e => e.SalePrice).HasColumnType("decimal(18,2)");
            entity.Property(e => e.CostPrice).HasColumnType("decimal(18,2)");
            entity.Property(e => e.Material).HasMaxLength(50);
            entity.Property(e => e.AvailableSizes).HasMaxLength(100);
            entity.Property(e => e.AvailableColors).HasMaxLength(200);
            entity.Property(e => e.Supplier).HasMaxLength(100);
            entity.Property(e => e.ImageUrl).HasMaxLength(500);
            entity.Property(e => e.ProductionStatus).HasMaxLength(30);
            entity.Property(e => e.SKU).HasMaxLength(50);
            entity.HasIndex(e => e.SKU).IsUnique();
        });

        // ================================================================================
        // Stock Configuration
        // ================================================================================
        modelBuilder.Entity<Stock>(entity =>
        {
            entity.ToTable("Stock");
            entity.HasKey(e => e.StockID);
            entity.Property(e => e.BatchNo).IsRequired().HasMaxLength(50);
            entity.Property(e => e.StockStatus).HasMaxLength(30);
            entity.Property(e => e.Location).HasMaxLength(100);
            entity.Property(e => e.Notes).HasMaxLength(500);

            entity.HasOne(s => s.Product)
                .WithMany(p => p.Stocks)
                .HasForeignKey(s => s.ProductID)
                .OnDelete(DeleteBehavior.Restrict);

            entity.HasOne(s => s.CreatedByEmployee)
                .WithMany()
                .HasForeignKey(s => s.CreatedBy)
                .OnDelete(DeleteBehavior.Restrict);
        });

        // ================================================================================
        // RawMaterial Configuration
        // ================================================================================
        modelBuilder.Entity<RawMaterial>(entity =>
        {
            entity.ToTable("RawMaterial");
            entity.HasKey(e => e.RawMaterialID);
            entity.Property(e => e.MaterialName).IsRequired().HasMaxLength(100);
            entity.Property(e => e.Category).HasMaxLength(50);
            entity.Property(e => e.Unit).HasMaxLength(20);
            entity.Property(e => e.Quantity).HasColumnType("decimal(18,2)");
            entity.Property(e => e.MinimumStock).HasColumnType("decimal(18,2)");
            entity.Property(e => e.UnitPrice).HasColumnType("decimal(18,2)");
            entity.Property(e => e.Supplier).HasMaxLength(100);
            entity.Property(e => e.SupplierContact).HasMaxLength(100);
            entity.Property(e => e.Description).HasMaxLength(500);
            entity.Property(e => e.StockStatus).HasMaxLength(20);
        });

        // ================================================================================
        // Retailer Configuration
        // ================================================================================
        modelBuilder.Entity<Retailer>(entity =>
        {
            entity.ToTable("Retailer");
            entity.HasKey(e => e.RetailerID);
            entity.Property(e => e.CompanyName).IsRequired().HasMaxLength(100);
            entity.Property(e => e.BusinessType).HasMaxLength(50);
            entity.Property(e => e.RegistrationNumber).HasMaxLength(50);
            entity.Property(e => e.TaxId).HasMaxLength(50);
            entity.Property(e => e.ContactPerson).HasMaxLength(100);
            entity.Property(e => e.Designation).HasMaxLength(50);
            entity.Property(e => e.Phone).HasMaxLength(20);
            entity.Property(e => e.Email).HasMaxLength(100);
            entity.Property(e => e.AlternativePhone).HasMaxLength(20);
            entity.Property(e => e.Address).HasMaxLength(500);
            entity.Property(e => e.City).HasMaxLength(50);
            entity.Property(e => e.Province).HasMaxLength(50);
            entity.Property(e => e.PostalCode).HasMaxLength(10);
            entity.Property(e => e.CreditLimit).HasColumnType("decimal(18,2)");
            entity.Property(e => e.PaymentTerms).HasMaxLength(30);
            entity.Property(e => e.DiscountPercentage).HasColumnType("decimal(5,2)");
            entity.Property(e => e.Priority).HasMaxLength(20);
            entity.Property(e => e.BankName).HasMaxLength(100);
            entity.Property(e => e.AccountNumber).HasMaxLength(50);
            entity.Property(e => e.AccountTitle).HasMaxLength(100);
            entity.Property(e => e.BranchCode).HasMaxLength(20);
            entity.Property(e => e.Status).HasMaxLength(20);
            entity.Property(e => e.Website).HasMaxLength(200);
            entity.Property(e => e.Notes).HasMaxLength(1000);
            entity.Property(e => e.Tags).HasMaxLength(200);
            entity.Property(e => e.CurrentBalance).HasColumnType("decimal(18,2)");

            entity.HasOne(r => r.SalesRep)
                .WithMany()
                .HasForeignKey(r => r.SalesRepID)
                .OnDelete(DeleteBehavior.Restrict);
        });

        // ================================================================================
        // SalesOrder Configuration
        // ================================================================================
        modelBuilder.Entity<SalesOrder>(entity =>
        {
            entity.ToTable("SalesOrder");
            entity.HasKey(e => e.SalesOrderID);
            entity.Property(e => e.PriorityLevel).HasMaxLength(20);
            entity.Property(e => e.Status).HasMaxLength(30);
            entity.Property(e => e.ShippingAddress).HasMaxLength(500);
            entity.Property(e => e.SpecialInstructions).HasMaxLength(500);
            entity.Property(e => e.PaymentTerms).HasMaxLength(30);
            entity.Property(e => e.AdvancePaymentPercent).HasColumnType("decimal(5,2)");
            entity.Property(e => e.DiscountPercentage).HasColumnType("decimal(5,2)");
            entity.Property(e => e.PaymentStatus).HasMaxLength(20);
            entity.Property(e => e.SubTotal).HasColumnType("decimal(18,2)");
            entity.Property(e => e.DiscountAmount).HasColumnType("decimal(18,2)");
            entity.Property(e => e.TaxAmount).HasColumnType("decimal(18,2)");
            entity.Property(e => e.TotalAmount).HasColumnType("decimal(18,2)");
            entity.Property(e => e.OrderSource).HasMaxLength(30);
            entity.Property(e => e.InternalNotes).HasMaxLength(1000);
            entity.Property(e => e.Tags).HasMaxLength(200);

            entity.HasOne(so => so.Retailer)
                .WithMany(r => r.SalesOrders)
                .HasForeignKey(so => so.RetailerID)
                .OnDelete(DeleteBehavior.Restrict);

            entity.HasOne(so => so.SalesRep)
                .WithMany()
                .HasForeignKey(so => so.SalesRepID)
                .OnDelete(DeleteBehavior.Restrict);
        });

        // ================================================================================
        // SalesOrderItem Configuration
        // ================================================================================
        modelBuilder.Entity<SalesOrderItem>(entity =>
        {
            entity.ToTable("SalesOrderItem");
            entity.HasKey(e => e.SalesOrderItemID);
            entity.Property(e => e.Size).HasMaxLength(20);
            entity.Property(e => e.Color).HasMaxLength(50);
            entity.Property(e => e.UnitPrice).HasColumnType("decimal(18,2)");
            entity.Property(e => e.Discount).HasColumnType("decimal(18,2)");
            entity.Property(e => e.TotalPrice).HasColumnType("decimal(18,2)")
                .HasComputedColumnSql("[Quantity] * [UnitPrice] - [Discount]");

            entity.HasOne(soi => soi.SalesOrder)
                .WithMany(so => so.SalesOrderItems)
                .HasForeignKey(soi => soi.SalesOrderID)
                .OnDelete(DeleteBehavior.Cascade);

            entity.HasOne(soi => soi.Product)
                .WithMany()
                .HasForeignKey(soi => soi.ProductID)
                .OnDelete(DeleteBehavior.Restrict);
        });

        // ================================================================================
        // Deal Configuration
        // ================================================================================
        modelBuilder.Entity<Deal>(entity =>
        {
            entity.ToTable("Deal");
            entity.HasKey(e => e.DealID);
            entity.Property(e => e.DealTitle).IsRequired().HasMaxLength(100);
            entity.Property(e => e.DealType).HasMaxLength(50);
            entity.Property(e => e.ClientName).HasMaxLength(100);
            entity.Property(e => e.ContactPerson).HasMaxLength(100);
            entity.Property(e => e.Email).HasMaxLength(100);
            entity.Property(e => e.Phone).HasMaxLength(20);
            entity.Property(e => e.EstimatedValue).HasColumnType("decimal(18,2)");
            entity.Property(e => e.Currency).HasMaxLength(10);
            entity.Property(e => e.Priority).HasMaxLength(20);
            entity.Property(e => e.ExpectedDuration).HasMaxLength(50);
            entity.Property(e => e.Description).HasMaxLength(1000);
            entity.Property(e => e.KeyTerms).HasMaxLength(1000);
            entity.Property(e => e.PaymentTerms).HasMaxLength(50);
            entity.Property(e => e.PaymentMethod).HasMaxLength(50);
            entity.Property(e => e.SpecialRequirements).HasMaxLength(1000);
            entity.Property(e => e.Status).HasMaxLength(30);

            entity.HasOne(d => d.AssignedManager)
                .WithMany()
                .HasForeignKey(d => d.AssignedManagerID)
                .OnDelete(DeleteBehavior.Restrict);

            entity.HasOne(d => d.CreatedByEmployee)
                .WithMany()
                .HasForeignKey(d => d.CreatedBy)
                .OnDelete(DeleteBehavior.Restrict);
        });

        // ================================================================================
        // DealItem Configuration
        // ================================================================================
        modelBuilder.Entity<DealItem>(entity =>
        {
            entity.ToTable("DealItem");
            entity.HasKey(e => e.DealItemID);
            entity.Property(e => e.UnitPrice).HasColumnType("decimal(18,2)");

            entity.HasOne(di => di.Deal)
                .WithMany(d => d.DealItems)
                .HasForeignKey(di => di.DealID)
                .OnDelete(DeleteBehavior.Cascade);

            entity.HasOne(di => di.Product)
                .WithMany()
                .HasForeignKey(di => di.ProductID)
                .OnDelete(DeleteBehavior.Restrict);
        });

        // ================================================================================
        // ProductionOrder Configuration
        // ================================================================================
        modelBuilder.Entity<ProductionOrder>(entity =>
        {
            entity.ToTable("ProductionOrder");
            entity.HasKey(e => e.ProductionOrderID);
            entity.Property(e => e.Status).HasMaxLength(50);
            entity.Property(e => e.Priority).HasMaxLength(20);
            entity.Property(e => e.Notes).HasMaxLength(500);

            entity.HasOne(po => po.Product)
                .WithMany(p => p.ProductionOrders)
                .HasForeignKey(po => po.ProductID)
                .OnDelete(DeleteBehavior.Restrict);

            entity.HasOne(po => po.CreatedByEmployee)
                .WithMany()
                .HasForeignKey(po => po.CreatedByEmployeeID)
                .OnDelete(DeleteBehavior.Restrict);
        });

        // ================================================================================
        // ProductionOrderItem Configuration
        // ================================================================================
        modelBuilder.Entity<ProductionOrderItem>(entity =>
        {
            entity.ToTable("ProductionOrderItem");
            entity.HasKey(e => e.ProductionOrderItemID);
            entity.Property(e => e.QuantityRequired).HasColumnType("decimal(18,2)");
            entity.Property(e => e.QuantityUsed).HasColumnType("decimal(18,2)");

            entity.HasOne(poi => poi.ProductionOrder)
                .WithMany(po => po.ProductionOrderItems)
                .HasForeignKey(poi => poi.ProductionOrderID)
                .OnDelete(DeleteBehavior.Cascade);

            entity.HasOne(poi => poi.RawMaterial)
                .WithMany()
                .HasForeignKey(poi => poi.RawMaterialID)
                .OnDelete(DeleteBehavior.Restrict);
        });

        // ================================================================================
        // TailorTask Configuration
        // ================================================================================
        modelBuilder.Entity<TailorTask>(entity =>
        {
            entity.ToTable("TailorTask");
            entity.HasKey(e => e.TailorTaskID);
            entity.Property(e => e.Status).HasMaxLength(50);
            entity.Property(e => e.Notes).HasMaxLength(500);

            entity.HasOne(tt => tt.Employee)
                .WithMany()
                .HasForeignKey(tt => tt.EmployeeID)
                .OnDelete(DeleteBehavior.Restrict);

            entity.HasOne(tt => tt.ProductionOrder)
                .WithMany(po => po.TailorTasks)
                .HasForeignKey(tt => tt.ProductionOrderID)
                .OnDelete(DeleteBehavior.Restrict);
        });

        // ================================================================================
        // StockUsage Configuration
        // ================================================================================
        modelBuilder.Entity<StockUsage>(entity =>
        {
            entity.ToTable("StockUsage");
            entity.HasKey(e => e.StockUsageID);
            entity.Property(e => e.QuantityUsed).HasColumnType("decimal(18,2)");
            entity.Property(e => e.Notes).HasMaxLength(500);

            entity.HasOne(su => su.Employee)
                .WithMany()
                .HasForeignKey(su => su.EmployeeID)
                .OnDelete(DeleteBehavior.Restrict);

            entity.HasOne(su => su.ProductionOrder)
                .WithMany(po => po.StockUsages)
                .HasForeignKey(su => su.ProductionOrderID)
                .OnDelete(DeleteBehavior.Restrict);

            entity.HasOne(su => su.RawMaterial)
                .WithMany(rm => rm.StockUsages)
                .HasForeignKey(su => su.RawMaterialID)
                .OnDelete(DeleteBehavior.Restrict);
        });

        // ================================================================================
        // Delivery Configuration
        // ================================================================================
        modelBuilder.Entity<Delivery>(entity =>
        {
            entity.ToTable("Delivery");
            entity.HasKey(e => e.DeliveryID);
            entity.Property(e => e.DeliveryAddress).HasMaxLength(500);
            entity.Property(e => e.City).HasMaxLength(50);
            entity.Property(e => e.Province).HasMaxLength(50);
            entity.Property(e => e.PostalCode).HasMaxLength(10);
            entity.Property(e => e.TrackingNumber).HasMaxLength(100);
            entity.Property(e => e.DeliveryMethod).HasMaxLength(50);
            entity.Property(e => e.DeliveryCost).HasColumnType("decimal(18,2)");
            entity.Property(e => e.Status).HasMaxLength(50);
            entity.Property(e => e.ReceiverName).HasMaxLength(100);
            entity.Property(e => e.ReceiverPhone).HasMaxLength(20);
            entity.Property(e => e.Notes).HasMaxLength(500);

            entity.HasOne(d => d.SalesOrder)
                .WithOne(so => so.Delivery)
                .HasForeignKey<Delivery>(d => d.SalesOrderID)
                .OnDelete(DeleteBehavior.Restrict);

            entity.HasOne(d => d.DeliveredByEmployee)
                .WithMany()
                .HasForeignKey(d => d.DeliveredBy)
                .OnDelete(DeleteBehavior.Restrict);
        });
    }
}

 * ================================================================================
 * END OF ENTITY FRAMEWORK CODE
 * ================================================================================
 */