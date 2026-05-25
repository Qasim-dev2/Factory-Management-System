using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Threading.Tasks;

namespace FactoryManagmentSystem.Services
{
    public class EmployeeDatabaseService
    {
        private readonly string _connectionString = "Server=QASIM\\SQLEXPRESS;Database=GarmentsFactoryDB;Integrated Security=True;";

        public class EmployeeInfo
        {
            public int EmployeeID { get; set; }
            public string FirstName { get; set; }
            public string LastName { get; set; }
            public string Email { get; set; }
            public string Phone { get; set; }
            public string RoleName { get; set; }
            public string DepartmentName { get; set; }
        }

        public async Task<List<EmployeeInfo>> GetAllEmployeesAsync()
        {
            var employees = new List<EmployeeInfo>();

            using (SqlConnection connection = new SqlConnection(_connectionString))
            {
                await connection.OpenAsync();

                string query = @"
                    SELECT 
                        e.EmployeeID,
                        e.FirstName,
                        e.LastName,
                        e.Email,
                        e.Phone,
                        r.RoleName,
                        d.DepartmentName
                    FROM Employee e
                    LEFT JOIN EmployeeRole r ON e.RoleID = r.RoleID
                    LEFT JOIN Department d ON e.DepartmentID = d.DepartmentID
                    WHERE e.IsActive = 1
                    ORDER BY e.FirstName, e.LastName";

                using (SqlCommand command = new SqlCommand(query, connection))
                using (SqlDataReader reader = await command.ExecuteReaderAsync())
                {
                    while (await reader.ReadAsync())
                    {
                        var employee = new EmployeeInfo
                        {
                            EmployeeID = reader.GetInt32(reader.GetOrdinal("EmployeeID")),
                            FirstName = reader.GetString(reader.GetOrdinal("FirstName")),
                            LastName = reader.GetString(reader.GetOrdinal("LastName")),
                            Email = reader.IsDBNull(reader.GetOrdinal("Email")) ? string.Empty : reader.GetString(reader.GetOrdinal("Email")),
                            Phone = reader.IsDBNull(reader.GetOrdinal("Phone")) ? string.Empty : reader.GetString(reader.GetOrdinal("Phone")),
                            RoleName = reader.IsDBNull(reader.GetOrdinal("RoleName")) ? string.Empty : reader.GetString(reader.GetOrdinal("RoleName")),
                            DepartmentName = reader.IsDBNull(reader.GetOrdinal("DepartmentName")) ? string.Empty : reader.GetString(reader.GetOrdinal("DepartmentName"))
                        };

                        employees.Add(employee);
                    }
                }
            }

            return employees;
        }

        public async Task<List<EmployeeInfo>> GetTailorsAsync()
        {
            var tailors = new List<EmployeeInfo>();

            using (SqlConnection connection = new SqlConnection(_connectionString))
            {
                await connection.OpenAsync();

                string query = @"
                    SELECT 
                        e.EmployeeID,
                        e.FirstName,
                        e.LastName,
                        e.Email,
                        e.Phone,
                        r.RoleName,
                        d.DepartmentName
                    FROM Employee e
                    INNER JOIN EmployeeRole r ON e.RoleID = r.RoleID
                    LEFT JOIN Department d ON e.DepartmentID = d.DepartmentID
                    WHERE e.IsActive = 1 
                      AND r.RoleName = 'Tailor'
                    ORDER BY e.FirstName, e.LastName";

                using (SqlCommand command = new SqlCommand(query, connection))
                using (SqlDataReader reader = await command.ExecuteReaderAsync())
                {
                    while (await reader.ReadAsync())
                    {
                        var tailor = new EmployeeInfo
                        {
                            EmployeeID = reader.GetInt32(reader.GetOrdinal("EmployeeID")),
                            FirstName = reader.GetString(reader.GetOrdinal("FirstName")),
                            LastName = reader.GetString(reader.GetOrdinal("LastName")),
                            Email = reader.IsDBNull(reader.GetOrdinal("Email")) ? string.Empty : reader.GetString(reader.GetOrdinal("Email")),
                            Phone = reader.IsDBNull(reader.GetOrdinal("Phone")) ? string.Empty : reader.GetString(reader.GetOrdinal("Phone")),
                            RoleName = reader.IsDBNull(reader.GetOrdinal("RoleName")) ? string.Empty : reader.GetString(reader.GetOrdinal("RoleName")),
                            DepartmentName = reader.IsDBNull(reader.GetOrdinal("DepartmentName")) ? string.Empty : reader.GetString(reader.GetOrdinal("DepartmentName"))
                        };

                        tailors.Add(tailor);
                    }
                }
            }

            return tailors;
        }
    }
}
