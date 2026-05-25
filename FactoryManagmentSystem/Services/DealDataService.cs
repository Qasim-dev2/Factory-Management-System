using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Threading.Tasks;
using FactoryManagmentSystem.Models;

namespace FactoryManagmentSystem.Services
{
    /// <summary>
    /// Data service for Deal Management module
    /// Handles all database operations for Deals and DealItems
    /// </summary>
    public class DealDataService
    {
        private readonly string _connectionString;

        public DealDataService()
        {
            _connectionString = "Server=QASIM\\SQLEXPRESS;Database=GarmentsFactoryDB;Trusted_Connection=True;TrustServerCertificate=True;MultipleActiveResultSets=True;";
        }

        #region Deal CRUD Operations

        /// <summary>
        /// Get all deals with optional search and status filter
        /// </summary>
        public async Task<List<Deal>> GetAllDealsAsync(string searchTerm = "", string statusFilter = "All")
        {
            var deals = new List<Deal>();

            try
            {
                using (var connection = new SqlConnection(_connectionString))
                {
                    await connection.OpenAsync();
                    using (var command = new SqlCommand("sp_GetAllDeals", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        // sp_GetAllDeals has no parameters - filtering done in C# if needed

                        using (var reader = await command.ExecuteReaderAsync())
                        {
                            while (await reader.ReadAsync())
                            {
                                var deal = MapDealFromReader(reader);
                                
                                // Apply client-side filtering if needed
                                bool matchesSearch = string.IsNullOrEmpty(searchTerm) || 
                                    (deal.ClientName != null && deal.ClientName.Contains(searchTerm, StringComparison.OrdinalIgnoreCase)) ||
                                    (deal.DealTitle != null && deal.DealTitle.Contains(searchTerm, StringComparison.OrdinalIgnoreCase));
                                
                                bool matchesStatus = statusFilter == "All" || deal.Status == statusFilter;
                                
                                if (matchesSearch && matchesStatus)
                                {
                                    deals.Add(deal);
                                }
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception($"Error retrieving deals: {ex.Message}", ex);
            }

            return deals;
        }

        /// <summary>
        /// Get a single deal by ID
        /// </summary>
        public async Task<Deal?> GetDealByIdAsync(int dealId)
        {
            Deal? deal = null;

            try
            {
                using (var connection = new SqlConnection(_connectionString))
                {
                    await connection.OpenAsync();
                    using (var command = new SqlCommand("sp_GetDealById", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.AddWithValue("@DealID", dealId);

                        using (var reader = await command.ExecuteReaderAsync())
                        {
                            if (await reader.ReadAsync())
                            {
                                deal = MapDealFromReader(reader);
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception($"Error retrieving deal: {ex.Message}", ex);
            }

            return deal;
        }

        /// <summary>
        /// Add a new deal
        /// </summary>
        public async Task<int> AddDealAsync(Deal deal)
        {
            int newDealId = 0;

            try
            {
                using (var connection = new SqlConnection(_connectionString))
                {
                    await connection.OpenAsync();
                    
                    // Set QUOTED_IDENTIFIER ON for compatibility with indexes
                    using (var setCmd = new SqlCommand("SET QUOTED_IDENTIFIER ON", connection))
                    {
                        await setCmd.ExecuteNonQueryAsync();
                    }
                    
                    using (var command = new SqlCommand("sp_AddDeal", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;

                        // Add all parameters
                        command.Parameters.AddWithValue("@DealTitle", deal.DealTitle);
                        command.Parameters.AddWithValue("@DealType", (object?)deal.DealType ?? DBNull.Value);
                        command.Parameters.AddWithValue("@ClientName", (object?)deal.ClientName ?? DBNull.Value);
                        command.Parameters.AddWithValue("@ContactPerson", (object?)deal.ContactPerson ?? DBNull.Value);
                        command.Parameters.AddWithValue("@Email", (object?)deal.Email ?? DBNull.Value);
                        command.Parameters.AddWithValue("@Phone", (object?)deal.Phone ?? DBNull.Value);
                        command.Parameters.AddWithValue("@ExpectedDuration", (object?)deal.ExpectedDuration ?? DBNull.Value);
                        command.Parameters.AddWithValue("@StartDate", (object?)deal.StartDate ?? DBNull.Value);
                        command.Parameters.AddWithValue("@EndDate", (object?)deal.EndDate ?? DBNull.Value);
                        command.Parameters.AddWithValue("@Description", (object?)deal.Description ?? DBNull.Value);
                        command.Parameters.AddWithValue("@Status", deal.Status);
                        command.Parameters.AddWithValue("@CreatedBy", (object?)deal.CreatedBy ?? DBNull.Value);

                        // Output parameter
                        var outputParam = new SqlParameter("@NewDealID", SqlDbType.Int)
                        {
                            Direction = ParameterDirection.Output
                        };
                        command.Parameters.Add(outputParam);

                        await command.ExecuteNonQueryAsync();

                        newDealId = (int)outputParam.Value;
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception($"Error adding deal: {ex.Message}", ex);
            }

            return newDealId;
        }

        /// <summary>
        /// Update an existing deal
        /// </summary>
        public async Task<bool> UpdateDealAsync(Deal deal)
        {
            try
            {
                using (var connection = new SqlConnection(_connectionString))
                {
                    await connection.OpenAsync();
                    using (var command = new SqlCommand("sp_UpdateDeal", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;

                        // Add all parameters
                        command.Parameters.AddWithValue("@DealID", deal.DealId);
                        command.Parameters.AddWithValue("@DealTitle", deal.DealTitle);
                        command.Parameters.AddWithValue("@DealType", (object?)deal.DealType ?? DBNull.Value);
                        command.Parameters.AddWithValue("@ClientName", (object?)deal.ClientName ?? DBNull.Value);
                        command.Parameters.AddWithValue("@ContactPerson", (object?)deal.ContactPerson ?? DBNull.Value);
                        command.Parameters.AddWithValue("@Email", (object?)deal.Email ?? DBNull.Value);
                        command.Parameters.AddWithValue("@Phone", (object?)deal.Phone ?? DBNull.Value);
                        command.Parameters.AddWithValue("@ExpectedDuration", (object?)deal.ExpectedDuration ?? DBNull.Value);
                        command.Parameters.AddWithValue("@StartDate", (object?)deal.StartDate ?? DBNull.Value);
                        command.Parameters.AddWithValue("@EndDate", (object?)deal.EndDate ?? DBNull.Value);
                        command.Parameters.AddWithValue("@Description", (object?)deal.Description ?? DBNull.Value);
                        command.Parameters.AddWithValue("@Status", deal.Status);

                        await command.ExecuteNonQueryAsync();
                        return true;
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception($"Error updating deal: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Delete a deal (cascades to deal items)
        /// </summary>
        public async Task<bool> DeleteDealAsync(int dealId)
        {
            try
            {
                using (var connection = new SqlConnection(_connectionString))
                {
                    await connection.OpenAsync();
                    
                    // Set QUOTED_IDENTIFIER ON for compatibility with indexes
                    using (var setCmd = new SqlCommand("SET QUOTED_IDENTIFIER ON", connection))
                    {
                        await setCmd.ExecuteNonQueryAsync();
                    }
                    
                    using (var command = new SqlCommand("sp_DeleteDeal", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.AddWithValue("@DealID", dealId);

                        await command.ExecuteNonQueryAsync();
                        return true;
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception($"Error deleting deal: {ex.Message}", ex);
            }
        }

        #endregion

        #region Deal Statistics

        /// <summary>
        /// Get deal statistics for dashboard
        /// </summary>
        public async Task<DealStatistics> GetDealStatisticsAsync()
        {
            var stats = new DealStatistics();

            try
            {
                using (var connection = new SqlConnection(_connectionString))
                {
                    await connection.OpenAsync();
                    using (var command = new SqlCommand("sp_GetDealStatistics", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;

                        using (var reader = await command.ExecuteReaderAsync())
                        {
                            if (await reader.ReadAsync())
                            {
                                stats.TotalDeals = reader.IsDBNull(reader.GetOrdinal("TotalDeals")) ? 0 : reader.GetInt32(reader.GetOrdinal("TotalDeals"));
                                stats.PendingDeals = reader.IsDBNull(reader.GetOrdinal("PendingDeals")) ? 0 : reader.GetInt32(reader.GetOrdinal("PendingDeals"));
                                stats.DraftDeals = reader.IsDBNull(reader.GetOrdinal("DraftDeals")) ? 0 : reader.GetInt32(reader.GetOrdinal("DraftDeals"));
                                stats.UnderReviewDeals = reader.IsDBNull(reader.GetOrdinal("UnderReviewDeals")) ? 0 : reader.GetInt32(reader.GetOrdinal("UnderReviewDeals"));
                                stats.PendingApprovalDeals = reader.IsDBNull(reader.GetOrdinal("PendingApprovalDeals")) ? 0 : reader.GetInt32(reader.GetOrdinal("PendingApprovalDeals"));
                                stats.ApprovedDeals = reader.IsDBNull(reader.GetOrdinal("ApprovedDeals")) ? 0 : reader.GetInt32(reader.GetOrdinal("ApprovedDeals"));
                                stats.ActiveDeals = reader.IsDBNull(reader.GetOrdinal("ActiveDeals")) ? 0 : reader.GetInt32(reader.GetOrdinal("ActiveDeals"));
                                stats.InProgressDeals = reader.IsDBNull(reader.GetOrdinal("InProgressDeals")) ? 0 : reader.GetInt32(reader.GetOrdinal("InProgressDeals"));
                                stats.CompletedDeals = reader.IsDBNull(reader.GetOrdinal("CompletedDeals")) ? 0 : reader.GetInt32(reader.GetOrdinal("CompletedDeals"));
                                stats.CancelledDeals = reader.IsDBNull(reader.GetOrdinal("CancelledDeals")) ? 0 : reader.GetInt32(reader.GetOrdinal("CancelledDeals"));
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception($"Error retrieving deal statistics: {ex.Message}", ex);
            }

            return stats;
        }

        /// <summary>
        /// Get deals by status
        /// </summary>
        public async Task<List<Deal>> GetDealsByStatusAsync(string status)
        {
            var deals = new List<Deal>();

            try
            {
                using (var connection = new SqlConnection(_connectionString))
                {
                    await connection.OpenAsync();
                    using (var command = new SqlCommand("sp_GetDealsByStatus", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.AddWithValue("@Status", status);

                        using (var reader = await command.ExecuteReaderAsync())
                        {
                            while (await reader.ReadAsync())
                            {
                                deals.Add(MapDealFromReader(reader));
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception($"Error retrieving deals by status: {ex.Message}", ex);
            }

            return deals;
        }

        /// <summary>
        /// Get deals by employee (created by or assigned to)
        /// </summary>
        public async Task<List<Deal>> GetDealsByEmployeeAsync(int employeeId)
        {
            var deals = new List<Deal>();

            try
            {
                using (var connection = new SqlConnection(_connectionString))
                {
                    await connection.OpenAsync();
                    using (var command = new SqlCommand("sp_GetDealsByEmployee", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.AddWithValue("@EmployeeID", employeeId);

                        using (var reader = await command.ExecuteReaderAsync())
                        {
                            while (await reader.ReadAsync())
                            {
                                deals.Add(MapDealFromReader(reader));
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception($"Error retrieving deals by employee: {ex.Message}", ex);
            }

            return deals;
        }

        #endregion

        #region Deal Items Operations

        /// <summary>
        /// Get all items (products) for a specific deal
        /// </summary>
        public async Task<List<DealItem>> GetDealItemsAsync(int dealId)
        {
            var items = new List<DealItem>();

            try
            {
                using (var connection = new SqlConnection(_connectionString))
                {
                    await connection.OpenAsync();
                    using (var command = new SqlCommand("sp_GetDealItems", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.AddWithValue("@DealID", dealId);

                        using (var reader = await command.ExecuteReaderAsync())
                        {
                            while (await reader.ReadAsync())
                            {
                                items.Add(MapDealItemFromReader(reader));
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception($"Error retrieving deal items: {ex.Message}", ex);
            }

            return items;
        }

        /// <summary>
        /// Add a product to a deal
        /// </summary>
        public async Task<int> AddDealItemAsync(DealItem item)
        {
            int newItemId = 0;

            try
            {
                using (var connection = new SqlConnection(_connectionString))
                {
                    await connection.OpenAsync();
                    using (var command = new SqlCommand("sp_AddDealItem", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;

                        command.Parameters.AddWithValue("@DealID", item.DealId);
                        command.Parameters.AddWithValue("@ProductID", item.ProductId);
                        command.Parameters.AddWithValue("@Quantity", item.Quantity);
                        command.Parameters.AddWithValue("@UnitPrice", item.UnitPrice);

                        var outputParam = new SqlParameter("@DealItemID", SqlDbType.Int)
                        {
                            Direction = ParameterDirection.Output
                        };
                        command.Parameters.Add(outputParam);

                        await command.ExecuteNonQueryAsync();

                        newItemId = (int)outputParam.Value;
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception($"Error adding deal item: {ex.Message}", ex);
            }

            return newItemId;
        }

        /// <summary>
        /// Update a deal item
        /// </summary>
        public async Task<bool> UpdateDealItemAsync(DealItem item)
        {
            try
            {
                using (var connection = new SqlConnection(_connectionString))
                {
                    await connection.OpenAsync();
                    using (var command = new SqlCommand("sp_UpdateDealItem", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;

                        command.Parameters.AddWithValue("@DealItemID", item.DealItemId);
                        command.Parameters.AddWithValue("@ProductID", item.ProductId);
                        command.Parameters.AddWithValue("@Quantity", item.Quantity);
                        command.Parameters.AddWithValue("@UnitPrice", item.UnitPrice);

                        await command.ExecuteNonQueryAsync();
                        return true;
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception($"Error updating deal item: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Delete a deal item
        /// </summary>
        public async Task<bool> DeleteDealItemAsync(int dealItemId)
        {
            try
            {
                using (var connection = new SqlConnection(_connectionString))
                {
                    await connection.OpenAsync();
                    using (var command = new SqlCommand("sp_DeleteDealItem", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.AddWithValue("@DealItemID", dealItemId);

                        await command.ExecuteNonQueryAsync();
                        return true;
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception($"Error deleting deal item: {ex.Message}", ex);
            }
        }

        #endregion

        #region Helper Methods - Get Employees and Products

        /// <summary>
        /// Get all salespersons for deal creation
        /// </summary>
        public async Task<List<(int EmployeeID, string FullName)>> GetSalespersonsAsync()
        {
            var salespeople = new List<(int, string)>();

            try
            {
                using (var connection = new SqlConnection(_connectionString))
                {
                    await connection.OpenAsync();
                    
                    string query = @"
                        SELECT e.EmployeeID, e.FirstName + ' ' + e.LastName AS FullName
                        FROM Employee e
                        INNER JOIN EmployeeRole r ON e.RoleID = r.RoleID
                        WHERE r.RoleName LIKE '%Sales%' OR r.RoleName LIKE '%Manager%'
                        AND e.IsActive = 1
                        ORDER BY e.FirstName, e.LastName";
                    
                    using (var command = new SqlCommand(query, connection))
                    {
                        using (var reader = await command.ExecuteReaderAsync())
                        {
                            while (await reader.ReadAsync())
                            {
                                salespeople.Add((
                                    reader.GetInt32(0),
                                    reader.GetString(1)
                                ));
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception($"Error retrieving salespeople: {ex.Message}", ex);
            }

            return salespeople;
        }

        /// <summary>
        /// Get all active products for deal items
        /// </summary>
        public async Task<List<(int ProductID, string ProductName, string SKU, decimal SalePrice)>> GetActiveProductsAsync()
        {
            var products = new List<(int, string, string, decimal)>();

            try
            {
                using (var connection = new SqlConnection(_connectionString))
                {
                    await connection.OpenAsync();
                    
                    string query = @"
                        SELECT ProductID, ProductName, ISNULL(SKU, '') AS SKU, SalePrice
                        FROM Product
                        WHERE IsActive = 1
                        ORDER BY ProductName";
                    
                    using (var command = new SqlCommand(query, connection))
                    {
                        using (var reader = await command.ExecuteReaderAsync())
                        {
                            while (await reader.ReadAsync())
                            {
                                products.Add((
                                    reader.GetInt32(0),
                                    reader.GetString(1),
                                    reader.GetString(2),
                                    reader.GetDecimal(3)
                                ));
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception($"Error retrieving products: {ex.Message}", ex);
            }

            return products;
        }

        #endregion

        #region Helper Methods

        /// <summary>
        /// Map SqlDataReader to Deal object
        /// </summary>
        private Deal MapDealFromReader(SqlDataReader reader)
        {
            return new Deal
            {
                DealId = reader.GetInt32(reader.GetOrdinal("DealID")),
                DealTitle = reader.GetString(reader.GetOrdinal("DealTitle")),
                DealType = reader.IsDBNull(reader.GetOrdinal("DealType")) ? null : reader.GetString(reader.GetOrdinal("DealType")),
                ClientName = reader.IsDBNull(reader.GetOrdinal("ClientName")) ? null : reader.GetString(reader.GetOrdinal("ClientName")),
                ContactPerson = reader.IsDBNull(reader.GetOrdinal("ContactPerson")) ? null : reader.GetString(reader.GetOrdinal("ContactPerson")),
                Email = reader.IsDBNull(reader.GetOrdinal("Email")) ? null : reader.GetString(reader.GetOrdinal("Email")),
                Phone = reader.IsDBNull(reader.GetOrdinal("Phone")) ? null : reader.GetString(reader.GetOrdinal("Phone")),
                // ExpectedDuration not in sp_GetAllDeals - skip it
                StartDate = reader.IsDBNull(reader.GetOrdinal("StartDate")) ? null : reader.GetDateTime(reader.GetOrdinal("StartDate")),
                EndDate = reader.IsDBNull(reader.GetOrdinal("EndDate")) ? null : reader.GetDateTime(reader.GetOrdinal("EndDate")),
                // Description, DeliveryAddress, City, Province not in sp_GetAllDeals
                Status = reader.GetString(reader.GetOrdinal("Status")),
                TotalAmount = reader.GetDecimal(reader.GetOrdinal("TotalAmount")),
                // CreatedBy column returns string name, not ID
                CreatedByName = reader.IsDBNull(reader.GetOrdinal("CreatedBy")) ? null : reader.GetString(reader.GetOrdinal("CreatedBy")),
                CreatedDate = reader.GetDateTime(reader.GetOrdinal("CreatedDate")),
                UpdatedDate = reader.IsDBNull(reader.GetOrdinal("UpdatedDate")) ? null : reader.GetDateTime(reader.GetOrdinal("UpdatedDate"))
            };
        }

        /// <summary>
        /// Map SqlDataReader to DealItem object
        /// </summary>
        private DealItem MapDealItemFromReader(SqlDataReader reader)
        {
            return new DealItem
            {
                DealItemId = reader.GetInt32(reader.GetOrdinal("DealItemID")),
                // DealID not returned by sp_GetDealItems (we already know it from the parameter)
                ProductId = reader.GetInt32(reader.GetOrdinal("ProductID")),
                ProductName = reader.IsDBNull(reader.GetOrdinal("ProductName")) ? null : reader.GetString(reader.GetOrdinal("ProductName")),
                // Category and SKU not returned by sp_GetDealItems
                Quantity = reader.GetInt32(reader.GetOrdinal("Quantity")),
                UnitPrice = reader.GetDecimal(reader.GetOrdinal("UnitPrice")),
                TotalPrice = reader.GetDecimal(reader.GetOrdinal("TotalPrice"))
            };
        }

        #endregion
    }
}
