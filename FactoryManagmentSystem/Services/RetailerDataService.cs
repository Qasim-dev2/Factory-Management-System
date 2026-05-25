using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Threading.Tasks;
using FactoryManagmentSystem.Models;

namespace FactoryManagmentSystem.Services
{
    public class RetailerDataService
    {
        private readonly string _connectionString;

        public RetailerDataService()
        {
            _connectionString = "Server=QASIM\\SQLEXPRESS;Database=GarmentsFactoryDB;Trusted_Connection=True;TrustServerCertificate=True;MultipleActiveResultSets=True;";
        }

        // ================================================================================
        // 1. GET ALL RETAILERS
        // ================================================================================
        public async Task<List<Retailer>> GetAllRetailersAsync()
        {
            var retailers = new List<Retailer>();

            using (var connection = new SqlConnection(_connectionString))
            {
                using (var command = new SqlCommand("sp_GetAllRetailers", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;

                    await connection.OpenAsync();
                    using (var reader = await command.ExecuteReaderAsync())
                    {
                        while (await reader.ReadAsync())
                        {
                            retailers.Add(MapRetailerFromReader(reader));
                        }
                    }
                }
            }

            return retailers;
        }

        // ================================================================================
        // 2. GET RETAILER BY ID
        // ================================================================================
        public async Task<Retailer> GetRetailerByIdAsync(int retailerId)
        {
            Retailer retailer = null;

            using (var connection = new SqlConnection(_connectionString))
            {
                using (var command = new SqlCommand("sp_GetRetailerById", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@RetailerID", retailerId);

                    await connection.OpenAsync();
                    using (var reader = await command.ExecuteReaderAsync())
                    {
                        if (await reader.ReadAsync())
                        {
                            retailer = MapRetailerFromReader(reader);
                        }
                    }
                }
            }

            return retailer;
        }

        // ================================================================================
        // 3. ADD NEW RETAILER
        // ================================================================================
        public async Task<int> AddRetailerAsync(Retailer retailer)
        {
            int newRetailerId = 0;

            using (var connection = new SqlConnection(_connectionString))
            {
                using (var command = new SqlCommand("sp_AddRetailer", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;

                    command.Parameters.AddWithValue("@CompanyName", retailer.CompanyName);
                    command.Parameters.AddWithValue("@ContactPerson", (object)retailer.ContactPerson ?? DBNull.Value);
                    command.Parameters.AddWithValue("@Phone", (object)retailer.Phone ?? DBNull.Value);
                    command.Parameters.AddWithValue("@Email", (object)retailer.Email ?? DBNull.Value);
                    command.Parameters.AddWithValue("@AlternativePhone", (object)retailer.AlternativePhone ?? DBNull.Value);
                    command.Parameters.AddWithValue("@Address", (object)retailer.Address ?? DBNull.Value);
                    command.Parameters.AddWithValue("@City", (object)retailer.City ?? DBNull.Value);
                    command.Parameters.AddWithValue("@Province", (object)retailer.Province ?? DBNull.Value);
                    command.Parameters.AddWithValue("@PostalCode", (object)retailer.PostalCode ?? DBNull.Value);

                    var outputParam = new SqlParameter("@NewRetailerID", SqlDbType.Int)
                    {
                        Direction = ParameterDirection.Output
                    };
                    command.Parameters.Add(outputParam);

                    await connection.OpenAsync();
                    await command.ExecuteNonQueryAsync();
                    newRetailerId = (int)outputParam.Value;
                }
            }

            return newRetailerId;
        }

        // ================================================================================
        // 4. UPDATE RETAILER
        // ================================================================================
        public async Task<bool> UpdateRetailerAsync(Retailer retailer)
        {
            using (var connection = new SqlConnection(_connectionString))
            {
                using (var command = new SqlCommand("sp_UpdateRetailer", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;

                    command.Parameters.AddWithValue("@RetailerID", retailer.RetailerID);
                    command.Parameters.AddWithValue("@CompanyName", retailer.CompanyName);
                    command.Parameters.AddWithValue("@ContactPerson", (object)retailer.ContactPerson ?? DBNull.Value);
                    command.Parameters.AddWithValue("@Phone", (object)retailer.Phone ?? DBNull.Value);
                    command.Parameters.AddWithValue("@Email", (object)retailer.Email ?? DBNull.Value);
                    command.Parameters.AddWithValue("@AlternativePhone", (object)retailer.AlternativePhone ?? DBNull.Value);
                    command.Parameters.AddWithValue("@Address", (object)retailer.Address ?? DBNull.Value);
                    command.Parameters.AddWithValue("@City", (object)retailer.City ?? DBNull.Value);
                    command.Parameters.AddWithValue("@Province", (object)retailer.Province ?? DBNull.Value);
                    command.Parameters.AddWithValue("@PostalCode", (object)retailer.PostalCode ?? DBNull.Value);
                    command.Parameters.AddWithValue("@Status", (object)retailer.Status ?? DBNull.Value);

                    await connection.OpenAsync();
                    await command.ExecuteNonQueryAsync();
                    return true;
                }
            }
        }

        // ================================================================================
        // 5. DELETE RETAILER
        // ================================================================================
        public async Task<bool> DeleteRetailerAsync(int retailerId)
        {
            using (var connection = new SqlConnection(_connectionString))
            {
                using (var command = new SqlCommand("sp_DeleteRetailer", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@RetailerID", retailerId);

                    await connection.OpenAsync();
                    await command.ExecuteNonQueryAsync();
                    return true;
                }
            }
        }

        // ================================================================================
        // 6. SEARCH RETAILERS
        // ================================================================================
        public async Task<List<Retailer>> SearchRetailersAsync(string searchTerm)
        {
            var retailers = new List<Retailer>();

            using (var connection = new SqlConnection(_connectionString))
            {
                using (var command = new SqlCommand("sp_SearchRetailers", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@SearchTerm", searchTerm);

                    await connection.OpenAsync();
                    using (var reader = await command.ExecuteReaderAsync())
                    {
                        while (await reader.ReadAsync())
                        {
                            retailers.Add(MapRetailerFromReader(reader));
                        }
                    }
                }
            }

            return retailers;
        }

        // ================================================================================
        // 7. GET RETAILER STATISTICS
        // ================================================================================
        public async Task<(int Total, int Active, int Inactive, int Cities)> GetRetailerStatisticsAsync()
        {
            using (var connection = new SqlConnection(_connectionString))
            {
                using (var command = new SqlCommand("sp_GetRetailerStatistics", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;

                    await connection.OpenAsync();
                    using (var reader = await command.ExecuteReaderAsync())
                    {
                        if (await reader.ReadAsync())
                        {
                            return (
                                reader.GetInt32(reader.GetOrdinal("TotalRetailers")),
                                reader.GetInt32(reader.GetOrdinal("ActiveRetailers")),
                                reader.GetInt32(reader.GetOrdinal("InactiveRetailers")),
                                reader.GetInt32(reader.GetOrdinal("CitiesCovered"))
                            );
                        }
                    }
                }
            }

            return (0, 0, 0, 0);
        }

        // ================================================================================
        // 8. GET SALES REPRESENTATIVES (for dropdowns)
        // ================================================================================
        public async Task<List<(int Id, string Name)>> GetSalesRepresentativesAsync()
        {
            var reps = new List<(int Id, string Name)>();

            using (var connection = new SqlConnection(_connectionString))
            {
                var query = @"SELECT e.EmployeeID, CONCAT(e.FirstName, ' ', e.LastName) AS Name 
                             FROM Employee e 
                             INNER JOIN EmployeeRole r ON e.RoleID = r.RoleID 
                             WHERE r.RoleName IN ('Salesperson', 'Sales Manager') AND e.IsActive = 1";
                using (var command = new SqlCommand(query, connection))
                {
                    await connection.OpenAsync();
                    using (var reader = await command.ExecuteReaderAsync())
                    {
                        while (await reader.ReadAsync())
                        {
                            reps.Add((reader.GetInt32(0), reader.GetString(1)));
                        }
                    }
                }
            }

            return reps;
        }

        // ================================================================================
        // HELPER: Map Retailer from DataReader
        // ================================================================================
        private Retailer MapRetailerFromReader(SqlDataReader reader)
        {
            return new Retailer
            {
                RetailerID = reader.GetInt32(reader.GetOrdinal("RetailerID")),
                CompanyName = reader.IsDBNull(reader.GetOrdinal("CompanyName")) ? null : reader.GetString(reader.GetOrdinal("CompanyName")),
                ContactPerson = reader.IsDBNull(reader.GetOrdinal("ContactPerson")) ? null : reader.GetString(reader.GetOrdinal("ContactPerson")),
                Phone = reader.IsDBNull(reader.GetOrdinal("Phone")) ? null : reader.GetString(reader.GetOrdinal("Phone")),
                Email = reader.IsDBNull(reader.GetOrdinal("Email")) ? null : reader.GetString(reader.GetOrdinal("Email")),
                AlternativePhone = reader.IsDBNull(reader.GetOrdinal("AlternativePhone")) ? null : reader.GetString(reader.GetOrdinal("AlternativePhone")),
                Address = reader.IsDBNull(reader.GetOrdinal("Address")) ? null : reader.GetString(reader.GetOrdinal("Address")),
                City = reader.IsDBNull(reader.GetOrdinal("City")) ? null : reader.GetString(reader.GetOrdinal("City")),
                Province = reader.IsDBNull(reader.GetOrdinal("Province")) ? null : reader.GetString(reader.GetOrdinal("Province")),
                PostalCode = reader.IsDBNull(reader.GetOrdinal("PostalCode")) ? null : reader.GetString(reader.GetOrdinal("PostalCode")),
                Status = reader.IsDBNull(reader.GetOrdinal("Status")) ? null : reader.GetString(reader.GetOrdinal("Status")),
                IsActive = reader.GetBoolean(reader.GetOrdinal("IsActive")),
                CreatedDate = reader.GetDateTime(reader.GetOrdinal("CreatedDate")),
                UpdatedDate = reader.IsDBNull(reader.GetOrdinal("UpdatedDate")) ? (DateTime?)null : reader.GetDateTime(reader.GetOrdinal("UpdatedDate"))
            };
        }
    }
}
