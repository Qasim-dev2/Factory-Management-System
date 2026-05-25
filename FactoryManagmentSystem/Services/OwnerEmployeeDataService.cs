using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Threading.Tasks;
using FactoryManagmentSystem.Models;

namespace FactoryManagmentSystem.Services
{
    // Owner Employee Data Service Interface
    public interface IOwnerEmployeeDataService
    {
        // Employee CRUD Operations - Simplified overloads
        Task<PaginatedResult<OwnerEmployee>> GetEmployeesAsync(int pageNumber = 1, int pageSize = 10, string searchTerm = "");
        Task<OwnerEmployee?> GetEmployeeByIdAsync(int employeeId);
        Task<OwnerEmployee> CreateEmployeeAsync(EmployeeFormData employeeData);
        Task<OwnerEmployee> UpdateEmployeeAsync(int employeeId, EmployeeFormData employeeData);
        Task<bool> DeleteEmployeeAsync(int employeeId);
        Task<bool> DeactivateEmployeeAsync(int employeeId);
        Task<bool> ReactivateEmployeeAsync(int employeeId);
        
        // Employee Role Management
        Task<bool> PromoteEmployeeAsync(int employeeId, string newRole, decimal? newSalary, string reason);
        Task<bool> DemoteEmployeeAsync(int employeeId, string newRole, decimal? newSalary, string reason);
        Task<List<EmployeePromotion>> GetEmployeePromotionHistoryAsync(int employeeId);
        
        // Salary Management
        Task<bool> UpdateEmployeeSalaryAsync(int employeeId, decimal newSalary, string reason);
        Task<List<EmployeeSalaryHistory>> GetEmployeeSalaryHistoryAsync(int employeeId);
        
        // Statistics and Reports
        Task<List<OwnerEmployee>> GetEmployeesByRoleAsync(string role);
        Task<List<OwnerEmployee>> GetEmployeesByDepartmentAsync(string department);
        Task<List<OwnerEmployee>> SearchEmployeesAsync(string searchTerm);
        
        // Validation and Utilities
        Task<bool> IsEmailUniqueAsync(string email, int? excludeEmployeeId = null);
        Task<bool> IsCNICUniqueAsync(string cnic, int? excludeEmployeeId = null);
        Task<List<string>> GetAvailableRolesAsync();
        Task<List<string>> GetAvailableDepartmentsAsync();
        
        // Additional methods for UI binding
        Task<List<string>> GetDepartmentsAsync();
        Task<List<string>> GetEmployeeRolesAsync();
    }

    // Owner Employee Data Service Implementation with REAL DATABASE
    public class OwnerEmployeeDataService : IOwnerEmployeeDataService
    {
        private static string connectionString = "Server=QASIM\\SQLEXPRESS;Database=GarmentsFactoryDB;Trusted_Connection=True;TrustServerCertificate=True;MultipleActiveResultSets=True;";

        // Get Employees with pagination and search
        public async Task<PaginatedResult<OwnerEmployee>> GetEmployeesAsync(int pageNumber = 1, int pageSize = 10, string searchTerm = "")
        {
            var employees = new List<OwnerEmployee>();
            int totalRecords = 0;

            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                using (SqlCommand cmd = new SqlCommand("sp_GetEmployees", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@PageNumber", pageNumber);
                    cmd.Parameters.AddWithValue("@PageSize", pageSize);
                    cmd.Parameters.AddWithValue("@SearchTerm", searchTerm ?? "");

                    await conn.OpenAsync();
                    using (SqlDataReader reader = await cmd.ExecuteReaderAsync())
                    {
                        while (await reader.ReadAsync())
                        {
                            var employee = MapToOwnerEmployee(reader);
                            employees.Add(employee);
                            totalRecords = reader["TotalCount"] != DBNull.Value ? Convert.ToInt32(reader["TotalCount"]) : employees.Count;
                        }
                    }
                }
            }

            return new PaginatedResult<OwnerEmployee>
            {
                Data = employees,
                TotalRecords = totalRecords,
                PageNumber = pageNumber,
                PageSize = pageSize
            };
        }

        // Get Employee by ID
        public async Task<OwnerEmployee?> GetEmployeeByIdAsync(int employeeId)
        {
            OwnerEmployee? employee = null;

            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                using (SqlCommand cmd = new SqlCommand("sp_GetEmployeeById", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@EmployeeID", employeeId);

                    await conn.OpenAsync();
                    using (SqlDataReader reader = await cmd.ExecuteReaderAsync())
                    {
                        if (await reader.ReadAsync())
                        {
                            employee = MapToOwnerEmployee(reader);
                        }
                    }
                }
            }

            return employee;
        }

        // Create new employee
        public async Task<OwnerEmployee> CreateEmployeeAsync(EmployeeFormData employeeData)
        {
            int newEmployeeId = 0;

            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    using (SqlCommand cmd = new SqlCommand("sp_AddEmployee", conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;

                        // Parse fullname into first and last
                        var nameParts = employeeData.FullName.Split(' ', 2);
                        string firstName = nameParts.Length > 0 ? nameParts[0] : employeeData.FullName;
                        string lastName = nameParts.Length > 1 ? nameParts[1] : "";

                        cmd.Parameters.AddWithValue("@FirstName", firstName);
                        cmd.Parameters.AddWithValue("@LastName", lastName);
                        cmd.Parameters.AddWithValue("@Email", employeeData.Email);
                        cmd.Parameters.AddWithValue("@Phone", employeeData.ContactNumber);
                        cmd.Parameters.AddWithValue("@CNIC", employeeData.CNIC);
                        cmd.Parameters.AddWithValue("@Address", employeeData.Address);
                        cmd.Parameters.AddWithValue("@EmergencyContact", employeeData.EmergencyContact);
                        
                        // Get Department and Role IDs
                        int deptId = await GetDepartmentIdByName(employeeData.Department);
                        int roleId = await GetRoleIdByName(employeeData.Role);
                        
                        cmd.Parameters.AddWithValue("@DepartmentID", deptId);
                        cmd.Parameters.AddWithValue("@RoleID", roleId);
                        cmd.Parameters.AddWithValue("@Salary", employeeData.Salary);
                        cmd.Parameters.AddWithValue("@JoinDate", employeeData.HireDate);
                        cmd.Parameters.AddWithValue("@Username", employeeData.Username);
                        cmd.Parameters.AddWithValue("@PIN", employeeData.PIN);
                        cmd.Parameters.AddWithValue("@Position", employeeData.Position);

                        SqlParameter outputParam = new SqlParameter("@NewEmployeeID", SqlDbType.Int);
                        outputParam.Direction = ParameterDirection.Output;
                        cmd.Parameters.Add(outputParam);

                        await conn.OpenAsync();
                        
                        await cmd.ExecuteNonQueryAsync();
                        
                        // Get the output parameter value
                        if (outputParam.Value != DBNull.Value)
                        {
                            newEmployeeId = Convert.ToInt32(outputParam.Value);
                        }
                    }
                }

                // Return the created employee
                return await GetEmployeeByIdAsync(newEmployeeId) ?? new OwnerEmployee();
            }
            catch (Exception ex)
            {
                throw;
            }
        }

        // Update employee
        public async Task<OwnerEmployee> UpdateEmployeeAsync(int employeeId, EmployeeFormData employeeData)
        {
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                using (SqlCommand cmd = new SqlCommand("sp_UpdateEmployee", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    // Parse fullname
                    var nameParts = employeeData.FullName.Split(' ', 2);
                    string firstName = nameParts.Length > 0 ? nameParts[0] : employeeData.FullName;
                    string lastName = nameParts.Length > 1 ? nameParts[1] : "";

                    cmd.Parameters.AddWithValue("@EmployeeID", employeeId);
                    cmd.Parameters.AddWithValue("@FirstName", firstName);
                    cmd.Parameters.AddWithValue("@LastName", lastName);
                    cmd.Parameters.AddWithValue("@Email", employeeData.Email);
                    cmd.Parameters.AddWithValue("@Phone", employeeData.ContactNumber);
                    cmd.Parameters.AddWithValue("@CNIC", employeeData.CNIC);
                    cmd.Parameters.AddWithValue("@Address", employeeData.Address);
                    cmd.Parameters.AddWithValue("@EmergencyContact", employeeData.EmergencyContact);
                    
                    int deptId = await GetDepartmentIdByName(employeeData.Department);
                    int roleId = await GetRoleIdByName(employeeData.Role);
                    
                    cmd.Parameters.AddWithValue("@DepartmentID", deptId);
                    cmd.Parameters.AddWithValue("@RoleID", roleId);
                    cmd.Parameters.AddWithValue("@Salary", employeeData.Salary);
                    cmd.Parameters.AddWithValue("@JoinDate", employeeData.HireDate);
                    cmd.Parameters.AddWithValue("@Username", employeeData.Username);
                    cmd.Parameters.AddWithValue("@PIN", employeeData.PIN);

                    await conn.OpenAsync();
                    await cmd.ExecuteNonQueryAsync();
                }
            }

            return await GetEmployeeByIdAsync(employeeId) ?? new OwnerEmployee();
        }

        // Delete employee (soft delete)
        public async Task<bool> DeleteEmployeeAsync(int employeeId)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    using (SqlCommand cmd = new SqlCommand("sp_DeleteEmployee", conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.AddWithValue("@EmployeeID", employeeId);

                        await conn.OpenAsync();
                        using (SqlDataReader reader = await cmd.ExecuteReaderAsync())
                        {
                            if (await reader.ReadAsync())
                            {
                                int rowsAffected = reader.GetInt32(0); // RowsAffected column
                                return rowsAffected > 0;
                            }
                        }
                    }
                }
            }
            catch (Exception)
            {
                return false;
            }
            return false;
        }

        public async Task<bool> DeactivateEmployeeAsync(int employeeId)
        {
            return await DeleteEmployeeAsync(employeeId);
        }

        public async Task<bool> ReactivateEmployeeAsync(int employeeId)
        {
            // Simple reactivation by updating IsActive
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                string query = "UPDATE Employee SET IsActive = 1 WHERE EmployeeID = @EmployeeID";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@EmployeeID", employeeId);
                    await conn.OpenAsync();
                    int rows = await cmd.ExecuteNonQueryAsync();
                    return rows > 0;
                }
            }
        }

        // Helper method to map SqlDataReader to OwnerEmployee
        private OwnerEmployee MapToOwnerEmployee(SqlDataReader reader)
        {
            string firstName = reader["FirstName"]?.ToString() ?? "";
            string lastName = reader["LastName"]?.ToString() ?? "";
            
            return new OwnerEmployee
            {
                EmployeeId = Convert.ToInt32(reader["EmployeeID"]),
                FullName = $"{firstName} {lastName}".Trim(),
                Email = reader["Email"]?.ToString(),
                ContactNumber = reader["Phone"]?.ToString(),
                CNIC = reader["CNIC"]?.ToString(),
                Address = reader["Address"]?.ToString(),
                Role = reader["Position"]?.ToString(),  // Using Position as Role
                Salary = reader["Salary"] != DBNull.Value ? Convert.ToDecimal(reader["Salary"]) : 0,
                Department = reader["DepartmentName"]?.ToString(),
                Position = reader["Position"]?.ToString(),
                Status = reader["IsActive"] != DBNull.Value && Convert.ToBoolean(reader["IsActive"]) ? "Active" : "Inactive",
                HireDate = reader["JoinDate"] != DBNull.Value ? Convert.ToDateTime(reader["JoinDate"]) : DateTime.Now,
                EmergencyContact = reader["EmergencyContact"]?.ToString(),
                EmergencyPhone = reader["EmergencyContact"]?.ToString(),
                Notes = "",  // Default value since column removed
                CreatedDate = reader["CreatedDate"] != DBNull.Value ? Convert.ToDateTime(reader["CreatedDate"]) : DateTime.Now
            };
        }

        // Helper methods to get IDs
        private async Task<int> GetDepartmentIdByName(string departmentName)
        {
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                string query = "SELECT DepartmentID FROM Department WHERE DepartmentName = @Name AND IsActive = 1";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@Name", departmentName);
                    await conn.OpenAsync();
                    object result = await cmd.ExecuteScalarAsync();
                    return result != null ? Convert.ToInt32(result) : 1;
                }
            }
        }

        private async Task<int> GetRoleIdByName(string roleName)
        {
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                string query = "SELECT RoleID FROM EmployeeRole WHERE RoleName = @Name AND IsActive = 1";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@Name", roleName);
                    await conn.OpenAsync();
                    object result = await cmd.ExecuteScalarAsync();
                    return result != null ? Convert.ToInt32(result) : 1;
                }
            }
        }

        // ========================= REMAINING STUB METHODS =========================
        // These are simplified implementations - can be enhanced later
        // All data now comes from database only - no hardcoded data

        // Employee Role Management - Updates role and salary in database
        public async Task<bool> PromoteEmployeeAsync(int employeeId, string newRole, decimal? newSalary, string reason)
        {
            try
            {
                var employee = await GetEmployeeByIdAsync(employeeId);
                if (employee == null)
                    return false;

                int newRoleId = await GetRoleIdByName(newRole);

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    string query = @"UPDATE Employee 
                                     SET RoleID = @RoleID, 
                                         Position = @Position,
                                         Salary = ISNULL(@Salary, Salary)
                                     WHERE EmployeeID = @EmployeeID";
                    
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@EmployeeID", employeeId);
                        cmd.Parameters.AddWithValue("@RoleID", newRoleId);
                        cmd.Parameters.AddWithValue("@Position", newRole);
                        cmd.Parameters.AddWithValue("@Salary", newSalary.HasValue ? (object)newSalary.Value : DBNull.Value);

                        await conn.OpenAsync();
                        int rowsAffected = await cmd.ExecuteNonQueryAsync();
                        return rowsAffected > 0;
                    }
                }
            }
            catch
            {
                return false;
            }
        }

        public async Task<bool> DemoteEmployeeAsync(int employeeId, string newRole, decimal? newSalary, string reason)
        {
            // Demotion uses the same logic as promotion - just updating role and salary
            return await PromoteEmployeeAsync(employeeId, newRole, newSalary, reason);
        }

        public async Task<List<EmployeePromotion>> GetEmployeePromotionHistoryAsync(int employeeId)
        {
            await Task.Delay(10);
            // Stub - would need a PromotionHistory table
            return new List<EmployeePromotion>();
        }

        // Salary Management - Simplified stubs
        public async Task<bool> UpdateEmployeeSalaryAsync(int employeeId, decimal newSalary, string reason)
        {
            await Task.Delay(10);
            // Stub - would update via stored procedure
            return true;
        }

        public async Task<List<EmployeeSalaryHistory>> GetEmployeeSalaryHistoryAsync(int employeeId)
        {
            await Task.Delay(10);
            // Stub - would need a SalaryHistory table
            return new List<EmployeeSalaryHistory>();
        }

        // Statistics and Reports
        public async Task<List<OwnerEmployee>> GetEmployeesByRoleAsync(string role)
        {
            var result = await GetEmployeesAsync(1, 1000, "");
            return result.Data.Where(e => e.Role == role).ToList();
        }

        public async Task<List<OwnerEmployee>> GetEmployeesByDepartmentAsync(string department)
        {
            var result = await GetEmployeesAsync(1, 1000, "");
            return result.Data.Where(e => e.Department == department).ToList();
        }

        public async Task<List<OwnerEmployee>> SearchEmployeesAsync(string searchTerm)
        {
            var result = await GetEmployeesAsync(1, 1000, searchTerm);
            return result.Data;
        }

        // Validation and Utilities
        public async Task<bool> IsEmailUniqueAsync(string email, int? excludeEmployeeId = null)
        {
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                string query = "SELECT COUNT(*) FROM Employee WHERE Email = @Email" +
                              (excludeEmployeeId.HasValue ? " AND EmployeeID != @ExcludeID" : "");
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@Email", email);
                    if (excludeEmployeeId.HasValue)
                        cmd.Parameters.AddWithValue("@ExcludeID", excludeEmployeeId.Value);
                    
                    await conn.OpenAsync();
                    int count = (int)await cmd.ExecuteScalarAsync();
                    return count == 0;
                }
            }
        }

        public async Task<bool> IsCNICUniqueAsync(string cnic, int? excludeEmployeeId = null)
        {
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                string query = "SELECT COUNT(*) FROM Employee WHERE CNIC = @CNIC" +
                              (excludeEmployeeId.HasValue ? " AND EmployeeID != @ExcludeID" : "");
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@CNIC", cnic);
                    if (excludeEmployeeId.HasValue)
                        cmd.Parameters.AddWithValue("@ExcludeID", excludeEmployeeId.Value);
                    
                    await conn.OpenAsync();
                    int count = (int)await cmd.ExecuteScalarAsync();
                    return count == 0;
                }
            }
        }

        public async Task<List<string>> GetAvailableRolesAsync()
        {
            var roles = new List<string>();
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                using (SqlCommand cmd = new SqlCommand("sp_GetEmployeeRoles", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    await conn.OpenAsync();
                    using (SqlDataReader reader = await cmd.ExecuteReaderAsync())
                    {
                        while (await reader.ReadAsync())
                        {
                            roles.Add(reader["RoleName"].ToString());
                        }
                    }
                }
            }
            return roles;
        }

        public async Task<List<string>> GetAvailableDepartmentsAsync()
        {
            var departments = new List<string>();
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                using (SqlCommand cmd = new SqlCommand("sp_GetDepartments", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    await conn.OpenAsync();
                    using (SqlDataReader reader = await cmd.ExecuteReaderAsync())
                    {
                        while (await reader.ReadAsync())
                        {
                            departments.Add(reader["DepartmentName"].ToString());
                        }
                    }
                }
            }
            return departments;
        }

        // Additional methods for UI binding (aliases for existing methods)
        public async Task<List<string>> GetDepartmentsAsync()
        {
            return await GetAvailableDepartmentsAsync();
        }

        public async Task<List<string>> GetEmployeeRolesAsync()
        {
            return await GetAvailableRolesAsync();
        }
    }
}