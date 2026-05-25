using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Threading.Tasks;
using FactoryManagmentSystem.Models.Entities;

namespace FactoryManagmentSystem.Services
{
    public class DepartmentService
    {
        private readonly string _connectionString;

        public DepartmentService()
        {
            _connectionString = "Server=QASIM\\SQLEXPRESS;Database=GarmentsFactoryDB;Trusted_Connection=True;TrustServerCertificate=True;MultipleActiveResultSets=True;";
        }

        // Get all active departments
        public async Task<List<Department>> GetAllDepartmentsAsync()
        {
            var departments = new List<Department>();
            
            try
            {
                using (var connection = new SqlConnection(_connectionString))
                {
                    await connection.OpenAsync();
                    using (var command = new SqlCommand("sp_GetAllDepartments", connection))
                    {
                        command.CommandType = System.Data.CommandType.StoredProcedure;
                        
                        using (var reader = await command.ExecuteReaderAsync())
                        {
                            while (await reader.ReadAsync())
                            {
                                departments.Add(new Department
                                {
                                    DepartmentID = reader.GetInt32(0),
                                    DepartmentName = reader.GetString(1),
                                    Description = reader.IsDBNull(2) ? null : reader.GetString(2),
                                    IsActive = reader.GetBoolean(3),
                                    CreatedDate = reader.GetDateTime(4)
                                });
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception($"Error retrieving departments: {ex.Message}");
            }
            
            return departments;
        }

        // Get department by ID
        public async Task<Department?> GetDepartmentByIdAsync(int departmentId)
        {
            try
            {
                using (var connection = new SqlConnection(_connectionString))
                {
                    await connection.OpenAsync();
                    using (var command = new SqlCommand("sp_GetDepartmentById", connection))
                    {
                        command.CommandType = System.Data.CommandType.StoredProcedure;
                        command.Parameters.AddWithValue("@DepartmentID", departmentId);
                        
                        using (var reader = await command.ExecuteReaderAsync())
                        {
                            if (await reader.ReadAsync())
                            {
                                return new Department
                                {
                                    DepartmentID = reader.GetInt32(0),
                                    DepartmentName = reader.GetString(1),
                                    Description = reader.IsDBNull(2) ? null : reader.GetString(2),
                                    IsActive = reader.GetBoolean(3),
                                    CreatedDate = reader.GetDateTime(4)
                                };
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception($"Error retrieving department: {ex.Message}");
            }
            
            return null;
        }

        // Add new department
        public async Task<int> AddDepartmentAsync(string departmentName, string? description = null)
        {
            try
            {
                using (var connection = new SqlConnection(_connectionString))
                {
                    await connection.OpenAsync();
                    using (var command = new SqlCommand("sp_AddDepartment", connection))
                    {
                        command.CommandType = System.Data.CommandType.StoredProcedure;
                        command.Parameters.AddWithValue("@DepartmentName", departmentName);
                        command.Parameters.AddWithValue("@Description", description ?? (object)DBNull.Value);
                        
                        // Add OUTPUT parameter
                        var outputParam = new SqlParameter("@NewDepartmentID", System.Data.SqlDbType.Int)
                        {
                            Direction = System.Data.ParameterDirection.Output
                        };
                        command.Parameters.Add(outputParam);
                        
                        await command.ExecuteNonQueryAsync();
                        
                        return Convert.ToInt32(outputParam.Value);
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception($"Error adding department: {ex.Message}");
            }
        }

        // Update existing department
        public async Task<bool> UpdateDepartmentAsync(int departmentId, string departmentName, string? description = null)
        {
            try
            {
                using (var connection = new SqlConnection(_connectionString))
                {
                    await connection.OpenAsync();
                    using (var command = new SqlCommand("sp_UpdateDepartment", connection))
                    {
                        command.CommandType = System.Data.CommandType.StoredProcedure;
                        command.Parameters.AddWithValue("@DepartmentID", departmentId);
                        command.Parameters.AddWithValue("@DepartmentName", departmentName);
                        command.Parameters.AddWithValue("@Description", description ?? (object)DBNull.Value);
                        
                        var rowsAffected = await command.ExecuteNonQueryAsync();
                        return rowsAffected > 0;
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception($"Error updating department: {ex.Message}");
            }
        }

        // Delete department (soft delete - sets IsActive to false)
        public async Task<bool> DeleteDepartmentAsync(int departmentId)
        {
            try
            {
                using (var connection = new SqlConnection(_connectionString))
                {
                    await connection.OpenAsync();
                    using (var command = new SqlCommand("sp_DeleteDepartment", connection))
                    {
                        command.CommandType = System.Data.CommandType.StoredProcedure;
                        command.Parameters.AddWithValue("@DepartmentID", departmentId);
                        
                        var rowsAffected = await command.ExecuteNonQueryAsync();
                        return rowsAffected > 0;
                    }
                }
            }
            catch (SqlException ex) when (ex.Number == 50000) // Custom error from stored procedure
            {
                throw new InvalidOperationException("Cannot delete department. It has employees assigned to it.");
            }
            catch (Exception ex)
            {
                throw new Exception($"Error deleting department: {ex.Message}");
            }
        }

        // Get departments with employee count (using sub-query)
        public async Task<List<DepartmentWithEmployeeCount>> GetDepartmentsWithEmployeeCountAsync()
        {
            var departments = new List<DepartmentWithEmployeeCount>();
            
            try
            {
                using (var connection = new SqlConnection(_connectionString))
                {
                    await connection.OpenAsync();
                    using (var command = new SqlCommand("sp_GetDepartmentsWithEmployeeCount", connection))
                    {
                        command.CommandType = System.Data.CommandType.StoredProcedure;
                        
                        using (var reader = await command.ExecuteReaderAsync())
                        {
                            while (await reader.ReadAsync())
                            {
                                departments.Add(new DepartmentWithEmployeeCount
                                {
                                    DepartmentID = reader.GetInt32(0),
                                    DepartmentName = reader.GetString(1),
                                    Description = reader.IsDBNull(2) ? null : reader.GetString(2),
                                    IsActive = true, // All departments returned by sp are active (filtered by WHERE d.IsActive = 1)
                                    EmployeeCount = reader.GetInt32(3)
                                });
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception($"Error retrieving departments with employee count: {ex.Message}");
            }
            
            return departments;
        }

        // Get employees by department (using JOIN query)
        public async Task<List<EmployeeSummary>> GetEmployeesByDepartmentAsync(int departmentId)
        {
            var employees = new List<EmployeeSummary>();
            
            try
            {
                using (var connection = new SqlConnection(_connectionString))
                {
                    await connection.OpenAsync();
                    using (var command = new SqlCommand("sp_GetEmployeesByDepartment", connection))
                    {
                        command.CommandType = System.Data.CommandType.StoredProcedure;
                        command.Parameters.AddWithValue("@DepartmentID", departmentId);
                        
                        using (var reader = await command.ExecuteReaderAsync())
                        {
                            while (await reader.ReadAsync())
                            {
                                employees.Add(new EmployeeSummary
                                {
                                    EmployeeID = reader.GetInt32(0),
                                    FullName = reader.GetString(1),
                                    Email = reader.IsDBNull(2) ? null : reader.GetString(2),
                                    Phone = reader.IsDBNull(3) ? null : reader.GetString(3),
                                    JoinDate = reader.GetDateTime(4),
                                    RoleName = reader.GetString(5)
                                });
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception($"Error retrieving employees for department: {ex.Message}");
            }
            
            return employees;
        }

        // Search departments by name
        public async Task<List<Department>> SearchDepartmentsAsync(string searchTerm)
        {
            var departments = new List<Department>();
            
            try
            {
                using (var connection = new SqlConnection(_connectionString))
                {
                    await connection.OpenAsync();
                    using (var command = new SqlCommand("SELECT DepartmentID, DepartmentName, Description, IsActive, CreatedDate FROM Department WHERE IsActive = 1 AND DepartmentName LIKE @SearchTerm ORDER BY DepartmentName", connection))
                    {
                        command.Parameters.AddWithValue("@SearchTerm", $"%{searchTerm}%");
                        
                        using (var reader = await command.ExecuteReaderAsync())
                        {
                            while (await reader.ReadAsync())
                            {
                                departments.Add(new Department
                                {
                                    DepartmentID = reader.GetInt32(0),
                                    DepartmentName = reader.GetString(1),
                                    Description = reader.IsDBNull(2) ? null : reader.GetString(2),
                                    IsActive = reader.GetBoolean(3),
                                    CreatedDate = reader.GetDateTime(4)
                                });
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception($"Error searching departments: {ex.Message}");
            }
            
            return departments;
        }

        // =============================================
        // Department Analytics Methods
        // =============================================

        // Get Production Department Statistics
        public async Task<ProductionDepartmentStats> GetProductionDepartmentStatsAsync()
        {
            try
            {
                using (var connection = new SqlConnection(_connectionString))
                {
                    await connection.OpenAsync();
                    using (var command = new SqlCommand("sp_GetProductionDepartmentStats", connection))
                    {
                        command.CommandType = System.Data.CommandType.StoredProcedure;
                        
                        using (var reader = await command.ExecuteReaderAsync())
                        {
                            if (await reader.ReadAsync())
                            {
                                return new ProductionDepartmentStats
                                {
                                    TotalProduction = reader.GetInt32(0),
                                    ActiveTailors = reader.GetInt32(1),
                                    TotalTailors = reader.GetInt32(2),
                                    AvgPerTailor = reader.GetDecimal(3),
                                    QualityRate = reader.GetDecimal(4),
                                    ProductionChange = reader.GetDecimal(5),
                                    EfficiencyGain = reader.GetDecimal(6),
                                    QualityImprovement = reader.GetDecimal(7),
                                    ActiveManagers = reader.GetInt32(8)
                                };
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception($"Error retrieving production department stats: {ex.Message}");
            }
            
            return new ProductionDepartmentStats();
        }

        // Get Sales Department Statistics
        public async Task<SalesDepartmentStats> GetSalesDepartmentStatsAsync()
        {
            try
            {
                using (var connection = new SqlConnection(_connectionString))
                {
                    await connection.OpenAsync();
                    using (var command = new SqlCommand("sp_GetSalesDepartmentStats", connection))
                    {
                        command.CommandType = System.Data.CommandType.StoredProcedure;
                        
                        using (var reader = await command.ExecuteReaderAsync())
                        {
                            if (await reader.ReadAsync())
                            {
                                return new SalesDepartmentStats
                                {
                                    TotalSales = reader.GetDecimal(0),
                                    ActiveSalespeople = reader.GetInt32(1),
                                    TotalOrders = reader.GetInt32(2),
                                    AvgOrderValue = reader.GetDecimal(3),
                                    ConversionRate = reader.GetDecimal(4),
                                    SalesGrowth = reader.GetDecimal(5)
                                };
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception($"Error retrieving sales department stats: {ex.Message}");
            }
            
            return new SalesDepartmentStats();
        }

        // Get Tailor Production Performance
        public async Task<List<TailorProductionPerformance>> GetTailorProductionPerformanceAsync()
        {
            var tailors = new List<TailorProductionPerformance>();
            
            try
            {
                using (var connection = new SqlConnection(_connectionString))
                {
                    await connection.OpenAsync();
                    using (var command = new SqlCommand("sp_GetTailorProductionPerformance", connection))
                    {
                        command.CommandType = System.Data.CommandType.StoredProcedure;
                        
                        using (var reader = await command.ExecuteReaderAsync())
                        {
                            while (await reader.ReadAsync())
                            {
                                tailors.Add(new TailorProductionPerformance
                                {
                                    Rank = reader.GetInt64(0),
                                    Name = reader.GetString(1),
                                    EmployeeId = reader.GetString(2),
                                    UnitsToday = reader.GetInt32(3),
                                    UnitsWeek = reader.GetInt32(4),
                                    UnitsMonth = reader.GetInt32(5),
                                    Performance = reader.GetInt32(6)
                                });
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception($"Error retrieving tailor production performance: {ex.Message}");
            }
            
            return tailors;
        }

        // Get Salesperson Sales Performance
        public async Task<List<SalespersonSalesPerformance>> GetSalespersonSalesPerformanceAsync()
        {
            var salespeople = new List<SalespersonSalesPerformance>();
            
            try
            {
                using (var connection = new SqlConnection(_connectionString))
                {
                    await connection.OpenAsync();
                    using (var command = new SqlCommand("sp_GetSalespersonSalesPerformance", connection))
                    {
                        command.CommandType = System.Data.CommandType.StoredProcedure;
                        
                        using (var reader = await command.ExecuteReaderAsync())
                        {
                            while (await reader.ReadAsync())
                            {
                                salespeople.Add(new SalespersonSalesPerformance
                                {
                                    Rank = reader.GetInt64(0),
                                    Name = reader.GetString(1),
                                    EmployeeId = reader.GetString(2),
                                    SalesToday = reader.GetDecimal(3),
                                    SalesWeek = reader.GetDecimal(4),
                                    SalesMonth = reader.GetDecimal(5),
                                    OrderCount = reader.GetInt32(6),
                                    TargetPercent = reader.GetInt32(7)
                                });
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception($"Error retrieving salesperson sales performance: {ex.Message}");
            }
            
            return salespeople;
        }
    }

    // Helper classes for complex query results
    public class DepartmentWithEmployeeCount
    {
        public int DepartmentID { get; set; }
        public string DepartmentName { get; set; } = string.Empty;
        public string? Description { get; set; }
        public bool IsActive { get; set; }
        public int EmployeeCount { get; set; }
    }

    public class EmployeeSummary
    {
        public int EmployeeID { get; set; }
        public string FullName { get; set; } = string.Empty;
        public string? Email { get; set; }
        public string? Phone { get; set; }
        public DateTime JoinDate { get; set; }
        public string RoleName { get; set; } = string.Empty;
    }

    // Analytics Data Classes
    public class ProductionDepartmentStats
    {
        public int TotalProduction { get; set; }
        public int ActiveTailors { get; set; }
        public int TotalTailors { get; set; }
        public decimal AvgPerTailor { get; set; }
        public decimal QualityRate { get; set; }
        public decimal ProductionChange { get; set; }
        public decimal EfficiencyGain { get; set; }
        public decimal QualityImprovement { get; set; }
        public int ActiveManagers { get; set; }
    }

    public class SalesDepartmentStats
    {
        public decimal TotalSales { get; set; }
        public int ActiveSalespeople { get; set; }
        public int TotalOrders { get; set; }
        public decimal AvgOrderValue { get; set; }
        public decimal ConversionRate { get; set; }
        public decimal SalesGrowth { get; set; }
    }

    public class TailorProductionPerformance
    {
        public long Rank { get; set; }
        public string Name { get; set; } = string.Empty;
        public string EmployeeId { get; set; } = string.Empty;
        public int UnitsToday { get; set; }
        public int UnitsWeek { get; set; }
        public int UnitsMonth { get; set; }
        public int Performance { get; set; }
    }

    public class SalespersonSalesPerformance
    {
        public long Rank { get; set; }
        public string Name { get; set; } = string.Empty;
        public string EmployeeId { get; set; } = string.Empty;
        public decimal SalesToday { get; set; }
        public decimal SalesWeek { get; set; }
        public decimal SalesMonth { get; set; }
        public int OrderCount { get; set; }
        public int TargetPercent { get; set; }
    }
}