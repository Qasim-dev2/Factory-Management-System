using System.ComponentModel.DataAnnotations;

namespace FactoryManagmentSystem.Models;

/// <summary>
/// Base user class for all system users
/// This class is designed for easy database integration
/// </summary>
public abstract class User
{
    [Key]
    public int Id { get; set; }
    
    [Required]
    [StringLength(50)]
    public string UserId { get; set; } = string.Empty;
    
    [Required]
    [StringLength(100)]
    public string Password { get; set; } = string.Empty; // This should be hashed in production
    
    [Required]
    [StringLength(100)]
    public string FirstName { get; set; } = string.Empty;
    
    [Required]
    [StringLength(100)]
    public string LastName { get; set; } = string.Empty;
    
    [Required]
    [EmailAddress]
    [StringLength(200)]
    public string Email { get; set; } = string.Empty;
    
    [StringLength(20)]
    public string? PhoneNumber { get; set; }
    
    [Required]
    public UserRole Role { get; set; }
    
    public DateTime CreatedDate { get; set; } = DateTime.Now;
    
    public DateTime? LastLoginDate { get; set; }
    
    public bool IsActive { get; set; } = true;
    
    public string FullName => $"{FirstName} {LastName}";
    
    /// <summary>
    /// Virtual method for role-specific authentication logic
    /// Override in derived classes for custom authentication
    /// </summary>
    public virtual bool Authenticate(string password)
    {
        // TODO: Implement proper password hashing (e.g., bcrypt)
        return Password == password;
    }
}

/// <summary>
/// Enum for user roles
/// </summary>
public enum UserRole
{
    Owner = 1,
    Manager = 2,
    Employee = 3,
    Salesperson = 4
}

/// <summary>
/// Owner class with additional properties
/// </summary>
public class Owner : User
{
    public Owner()
    {
        Role = UserRole.Owner;
    }
    
    [StringLength(100)]
    public string? CompanyPosition { get; set; }
    
    public decimal? OwnershipPercentage { get; set; }
    
    public override bool Authenticate(string password)
    {
        // Owner might have additional security requirements
        return base.Authenticate(password);
    }
}

/// <summary>
/// Manager class with department and team management properties
/// </summary>
public class ManagerUser : User
{
    public ManagerUser()
    {
        Role = UserRole.Manager;
    }
    
    [Required]
    [StringLength(100)]
    public string Department { get; set; } = string.Empty;
    
    [StringLength(100)]
    public string? ManagerLevel { get; set; } // Senior, Junior, etc.
    
    public int? TeamSize { get; set; }
    
    public decimal? Salary { get; set; }
    
    // Navigation property for employees under this manager
    public List<Employee> ManagedEmployees { get; set; } = new List<Employee>();
}

/// <summary>
/// Employee class with work-related properties
/// </summary>
public class Employee : User
{
    public Employee()
    {
        Role = UserRole.Employee;
    }
    
    [Required]
    [StringLength(50)]
    public string EmployeeNumber { get; set; } = string.Empty;
    
    [Required]
    [StringLength(100)]
    public string Department { get; set; } = string.Empty;
    
    [StringLength(100)]
    public string? Position { get; set; }
    
    public DateTime HireDate { get; set; }
    
    public decimal? HourlyRate { get; set; }
    
    public int? ManagerId { get; set; }
    
    // Navigation property
    public ManagerUser? ReportsTo { get; set; }
    
    public bool IsFullTime { get; set; } = true;
}

/// <summary>
/// Salesperson class with sales-related properties
/// </summary>
public class SalespersonUser : User
{
    public SalespersonUser()
    {
        Role = UserRole.Salesperson;
    }
    
    [Required]
    [StringLength(50)]
    public string SalesNumber { get; set; } = string.Empty;
    
    [StringLength(100)]
    public string? Territory { get; set; }
    
    public decimal? CommissionRate { get; set; }
    
    public decimal? SalesTarget { get; set; }
    
    public decimal? CurrentYearSales { get; set; }
    
    [StringLength(100)]
    public string? SpecializationArea { get; set; } // Paper types, regions, etc.
    
    public DateTime? LastSaleDate { get; set; }
}

/// <summary>
/// Authentication service for handling login logic
/// This class will interface with your database
/// </summary>
public static class AuthenticationService
{
    // TODO: Replace with actual database context
    private static readonly Dictionary<string, Dictionary<string, User>> DemoUsers = InitializeDemoUsers();
    
    private static Dictionary<string, Dictionary<string, User>> InitializeDemoUsers()
    {
        return new Dictionary<string, Dictionary<string, User>>
        {
            ["Owner"] = new Dictionary<string, User>
            {
                ["OWNER001"] = new Owner
                {
                    Id = 1,
                    UserId = "OWNER001",
                    Password = "owner123",
                    FirstName = "John",
                    LastName = "Smith",
                    Email = "john.smith@paperfactory.com",
                    CompanyPosition = "CEO",
                    OwnershipPercentage = 100
                }
            },
            ["Manager"] = new Dictionary<string, User>
            {
                ["MGR001"] = new ManagerUser
                {
                    Id = 2,
                    UserId = "MGR001",
                    Password = "manager123",
                    FirstName = "Sarah",
                    LastName = "Johnson",
                    Email = "sarah.johnson@paperfactory.com",
                    Department = "Production",
                    ManagerLevel = "Senior",
                    TeamSize = 15,
                    Salary = 75000
                },
                ["MGR002"] = new ManagerUser
                {
                    Id = 3,
                    UserId = "MGR002",
                    Password = "manager456",
                    FirstName = "Mike",
                    LastName = "Davis",
                    Email = "mike.davis@paperfactory.com",
                    Department = "Quality Control",
                    ManagerLevel = "Junior",
                    TeamSize = 8,
                    Salary = 65000
                }
            },
            ["Employee"] = new Dictionary<string, User>
            {
                ["EMP001"] = new Employee
                {
                    Id = 4,
                    UserId = "EMP001",
                    Password = "emp123",
                    FirstName = "David",
                    LastName = "Wilson",
                    Email = "david.wilson@paperfactory.com",
                    EmployeeNumber = "E001",
                    Department = "Production",
                    Position = "Machine Operator",
                    HireDate = DateTime.Now.AddYears(-2),
                    HourlyRate = 18.50m
                },
                ["EMP002"] = new Employee
                {
                    Id = 5,
                    UserId = "EMP002",
                    Password = "emp456",
                    FirstName = "Lisa",
                    LastName = "Brown",
                    Email = "lisa.brown@paperfactory.com",
                    EmployeeNumber = "E002",
                    Department = "Quality Control",
                    Position = "Quality Inspector",
                    HireDate = DateTime.Now.AddYears(-1),
                    HourlyRate = 20.00m
                }
            },
            ["Salesperson"] = new Dictionary<string, User>
            {
                ["SALES001"] = new SalespersonUser
                {
                    Id = 6,
                    UserId = "SALES001",
                    Password = "sales123",
                    FirstName = "Robert",
                    LastName = "Miller",
                    Email = "robert.miller@paperfactory.com",
                    SalesNumber = "S001",
                    Territory = "North Region",
                    CommissionRate = 0.05m,
                    SalesTarget = 500000,
                    CurrentYearSales = 350000,
                    SpecializationArea = "Industrial Paper"
                },
                ["SALES002"] = new SalespersonUser
                {
                    Id = 7,
                    UserId = "SALES002",
                    Password = "sales456",
                    FirstName = "Jennifer",
                    LastName = "Garcia",
                    Email = "jennifer.garcia@paperfactory.com",
                    SalesNumber = "S002",
                    Territory = "South Region",
                    CommissionRate = 0.05m,
                    SalesTarget = 450000,
                    CurrentYearSales = 280000,
                    SpecializationArea = "Commercial Paper"
                }
            }
        };
    }
    
    /// <summary>
    /// Authenticate user with role, userId, and password
    /// </summary>
    public static User? AuthenticateUser(string role, string userId, string password)
    {
        try
        {
            if (DemoUsers.ContainsKey(role) && 
                DemoUsers[role].ContainsKey(userId.ToUpper()))
            {
                var user = DemoUsers[role][userId.ToUpper()];
                if (user.Authenticate(password))
                {
                    user.LastLoginDate = DateTime.Now;
                    return user;
                }
            }
            return null;
        }
        catch
        {
            return null;
        }
    }
    
    /// <summary>
    /// Get user by role and userId (for profile management)
    /// </summary>
    public static User? GetUser(string role, string userId)
    {
        try
        {
            if (DemoUsers.ContainsKey(role) && 
                DemoUsers[role].ContainsKey(userId.ToUpper()))
            {
                return DemoUsers[role][userId.ToUpper()];
            }
            return null;
        }
        catch
        {
            return null;
        }
    }
    
    /// <summary>
    /// TODO: Database integration methods
    /// These methods should be implemented when connecting to a real database
    /// </summary>
    
    // public static async Task<User?> AuthenticateUserAsync(string role, string userId, string password)
    // {
    //     using var context = new FactoryDbContext();
    //     var user = await context.Users
    //         .FirstOrDefaultAsync(u => u.UserId == userId && u.Role.ToString() == role);
    //     
    //     return user?.Authenticate(password) == true ? user : null;
    // }
    
    // public static async Task<bool> CreateUserAsync(User user)
    // {
    //     using var context = new FactoryDbContext();
    //     context.Users.Add(user);
    //     return await context.SaveChangesAsync() > 0;
    // }
    
    // public static async Task<bool> UpdateUserAsync(User user)
    // {
    //     using var context = new FactoryDbContext();
    //     context.Users.Update(user);
    //     return await context.SaveChangesAsync() > 0;
    // }
}