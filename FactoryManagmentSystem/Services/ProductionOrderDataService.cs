using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Threading.Tasks;

namespace FactoryManagmentSystem.Services
{
    /// <summary>
    /// Data service for Production Order Management
    /// Handles all database operations for production orders and their items
    /// </summary>
    public class ProductionOrderDataService
    {
        private readonly string _connectionString = "Server=QASIM\\SQLEXPRESS;Database=GarmentsFactoryDB;Trusted_Connection=True;TrustServerCertificate=True;MultipleActiveResultSets=True;";

        #region Production Order Operations

        /// <summary>
        /// Get all production orders with product and employee details
        /// </summary>
        public async Task<List<ProductionOrderInfo>> GetAllProductionOrdersAsync()
        {
            var orders = new List<ProductionOrderInfo>();

            using (var connection = new SqlConnection(_connectionString))
            {
                await connection.OpenAsync();
                using (var command = new SqlCommand("sp_GetAllProductionOrders", connection))
                {
                    command.CommandType = System.Data.CommandType.StoredProcedure;

                    using (var reader = await command.ExecuteReaderAsync())
                    {
                        while (await reader.ReadAsync())
                        {
                            orders.Add(new ProductionOrderInfo
                            {
                                ProductionOrderID = reader.GetInt32(reader.GetOrdinal("ProductionOrderID")),
                                ProductID = reader.GetInt32(reader.GetOrdinal("ProductID")),
                                QuantityOrdered = reader.GetInt32(reader.GetOrdinal("QuantityOrdered")),
                                QuantityCompleted = reader.GetInt32(reader.GetOrdinal("QuantityCompleted")),
                                StartDate = reader.IsDBNull(reader.GetOrdinal("StartDate")) ? null : reader.GetDateTime(reader.GetOrdinal("StartDate")),
                                ExpectedEndDate = reader.IsDBNull(reader.GetOrdinal("ExpectedEndDate")) ? null : reader.GetDateTime(reader.GetOrdinal("ExpectedEndDate")),
                                ActualEndDate = reader.IsDBNull(reader.GetOrdinal("ActualEndDate")) ? null : reader.GetDateTime(reader.GetOrdinal("ActualEndDate")),
                                Status = reader.GetString(reader.GetOrdinal("Status")),
                                Priority = reader.GetString(reader.GetOrdinal("Priority")),
                                Notes = reader.IsDBNull(reader.GetOrdinal("Notes")) ? null : reader.GetString(reader.GetOrdinal("Notes")),
                                CreatedByEmployeeID = reader.IsDBNull(reader.GetOrdinal("CreatedByEmployeeID")) ? null : (int?)reader.GetInt32(reader.GetOrdinal("CreatedByEmployeeID")),
                                CreatedDate = reader.GetDateTime(reader.GetOrdinal("CreatedDate")),
                                UpdatedDate = reader.IsDBNull(reader.GetOrdinal("UpdatedDate")) ? null : reader.GetDateTime(reader.GetOrdinal("UpdatedDate")),
                                // Product Information
                                ProductName = reader.GetString(reader.GetOrdinal("ProductName")),
                                Category = reader.IsDBNull(reader.GetOrdinal("Category")) ? null : reader.GetString(reader.GetOrdinal("Category")),
                                SKU = reader.IsDBNull(reader.GetOrdinal("SKU")) ? null : reader.GetString(reader.GetOrdinal("SKU")),
                                SalePrice = reader.GetDecimal(reader.GetOrdinal("SalePrice")),
                                // Employee Information
                                CreatedByName = reader.IsDBNull(reader.GetOrdinal("CreatedByName")) ? null : reader.GetString(reader.GetOrdinal("CreatedByName")),
                                EmployeeRole = reader.IsDBNull(reader.GetOrdinal("EmployeeRole")) ? null : reader.GetString(reader.GetOrdinal("EmployeeRole")),
                                // Calculated Fields
                                RemainingQuantity = reader.GetInt32(reader.GetOrdinal("RemainingQuantity")),
                                CompletionPercentage = reader.GetDouble(reader.GetOrdinal("CompletionPercentage"))
                            });
                        }
                    }
                }
            }

            return orders;
        }

        /// <summary>
        /// Get a single production order by ID
        /// </summary>
        public async Task<ProductionOrderInfo?> GetProductionOrderByIdAsync(int productionOrderID)
        {
            ProductionOrderInfo? order = null;

            using (var connection = new SqlConnection(_connectionString))
            {
                await connection.OpenAsync();
                using (var command = new SqlCommand("sp_GetProductionOrderById", connection))
                {
                    command.CommandType = System.Data.CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@ProductionOrderID", productionOrderID);

                    using (var reader = await command.ExecuteReaderAsync())
                    {
                        if (await reader.ReadAsync())
                        {
                            order = new ProductionOrderInfo
                            {
                                ProductionOrderID = reader.GetInt32(reader.GetOrdinal("ProductionOrderID")),
                                ProductID = reader.GetInt32(reader.GetOrdinal("ProductID")),
                                QuantityOrdered = reader.GetInt32(reader.GetOrdinal("QuantityOrdered")),
                                QuantityCompleted = reader.GetInt32(reader.GetOrdinal("QuantityCompleted")),
                                StartDate = reader.IsDBNull(reader.GetOrdinal("StartDate")) ? null : reader.GetDateTime(reader.GetOrdinal("StartDate")),
                                ExpectedEndDate = reader.IsDBNull(reader.GetOrdinal("ExpectedEndDate")) ? null : reader.GetDateTime(reader.GetOrdinal("ExpectedEndDate")),
                                ActualEndDate = reader.IsDBNull(reader.GetOrdinal("ActualEndDate")) ? null : reader.GetDateTime(reader.GetOrdinal("ActualEndDate")),
                                Status = reader.GetString(reader.GetOrdinal("Status")),
                                Priority = reader.GetString(reader.GetOrdinal("Priority")),
                                Notes = reader.IsDBNull(reader.GetOrdinal("Notes")) ? null : reader.GetString(reader.GetOrdinal("Notes")),
                                CreatedByEmployeeID = reader.IsDBNull(reader.GetOrdinal("CreatedByEmployeeID")) ? null : (int?)reader.GetInt32(reader.GetOrdinal("CreatedByEmployeeID")),
                                CreatedDate = reader.GetDateTime(reader.GetOrdinal("CreatedDate")),
                                UpdatedDate = reader.IsDBNull(reader.GetOrdinal("UpdatedDate")) ? null : reader.GetDateTime(reader.GetOrdinal("UpdatedDate")),
                                // Product Information
                                ProductName = reader.GetString(reader.GetOrdinal("ProductName")),
                                Category = reader.IsDBNull(reader.GetOrdinal("Category")) ? null : reader.GetString(reader.GetOrdinal("Category")),
                                Brand = reader.IsDBNull(reader.GetOrdinal("Brand")) ? null : reader.GetString(reader.GetOrdinal("Brand")),
                                SKU = reader.IsDBNull(reader.GetOrdinal("SKU")) ? null : reader.GetString(reader.GetOrdinal("SKU")),
                                SalePrice = reader.GetDecimal(reader.GetOrdinal("SalePrice")),
                                Material = reader.IsDBNull(reader.GetOrdinal("Material")) ? null : reader.GetString(reader.GetOrdinal("Material")),
                                // Employee Information
                                CreatedByName = reader.IsDBNull(reader.GetOrdinal("CreatedByName")) ? null : reader.GetString(reader.GetOrdinal("CreatedByName")),
                                CreatedByPhone = reader.IsDBNull(reader.GetOrdinal("CreatedByPhone")) ? null : reader.GetString(reader.GetOrdinal("CreatedByPhone")),
                                CreatedByEmail = reader.IsDBNull(reader.GetOrdinal("CreatedByEmail")) ? null : reader.GetString(reader.GetOrdinal("CreatedByEmail")),
                                EmployeeRole = reader.IsDBNull(reader.GetOrdinal("EmployeeRole")) ? null : reader.GetString(reader.GetOrdinal("EmployeeRole")),
                                DepartmentName = reader.IsDBNull(reader.GetOrdinal("DepartmentName")) ? null : reader.GetString(reader.GetOrdinal("DepartmentName")),
                                // Calculated Fields
                                RemainingQuantity = reader.GetInt32(reader.GetOrdinal("RemainingQuantity")),
                                CompletionPercentage = reader.GetDouble(reader.GetOrdinal("CompletionPercentage"))
                            };
                        }
                    }
                }
            }

            return order;
        }

        /// <summary>
        /// Create a new production order
        /// </summary>
        public async Task<int> CreateProductionOrderAsync(ProductionOrderInfo order)
        {
            int productionOrderID = 0;

            using (var connection = new SqlConnection(_connectionString))
            {
                await connection.OpenAsync();
                using (var command = new SqlCommand("sp_CreateProductionOrder", connection))
                {
                    command.CommandType = System.Data.CommandType.StoredProcedure;
                    
                    command.Parameters.AddWithValue("@ProductID", order.ProductID);
                    command.Parameters.AddWithValue("@QuantityOrdered", order.QuantityOrdered);
                    command.Parameters.AddWithValue("@StartDate", order.StartDate ?? (object)DBNull.Value);
                    command.Parameters.AddWithValue("@ExpectedEndDate", order.ExpectedEndDate ?? (object)DBNull.Value);
                    command.Parameters.AddWithValue("@Priority", order.Priority ?? "Normal");
                    command.Parameters.AddWithValue("@Notes", order.Notes ?? (object)DBNull.Value);
                    command.Parameters.AddWithValue("@CreatedByEmployeeID", order.CreatedByEmployeeID ?? (object)DBNull.Value);
                    
                    var outputParam = new SqlParameter("@ProductionOrderID", System.Data.SqlDbType.Int)
                    {
                        Direction = System.Data.ParameterDirection.Output
                    };
                    command.Parameters.Add(outputParam);

                    await command.ExecuteNonQueryAsync();
                    productionOrderID = (int)outputParam.Value;
                }
            }

            return productionOrderID;
        }

        /// <summary>
        /// Update an existing production order
        /// </summary>
        public async Task UpdateProductionOrderAsync(ProductionOrderInfo order)
        {
            using (var connection = new SqlConnection(_connectionString))
            {
                await connection.OpenAsync();
                using (var command = new SqlCommand("sp_UpdateProductionOrder", connection))
                {
                    command.CommandType = System.Data.CommandType.StoredProcedure;
                    
                    command.Parameters.AddWithValue("@ProductionOrderID", order.ProductionOrderID);
                    command.Parameters.AddWithValue("@ProductID", order.ProductID);
                    command.Parameters.AddWithValue("@QuantityOrdered", order.QuantityOrdered);
                    command.Parameters.AddWithValue("@QuantityCompleted", order.QuantityCompleted);
                    command.Parameters.AddWithValue("@StartDate", order.StartDate ?? (object)DBNull.Value);
                    command.Parameters.AddWithValue("@ExpectedEndDate", order.ExpectedEndDate ?? (object)DBNull.Value);
                    command.Parameters.AddWithValue("@ActualEndDate", order.ActualEndDate ?? (object)DBNull.Value);
                    command.Parameters.AddWithValue("@Status", order.Status);
                    command.Parameters.AddWithValue("@Priority", order.Priority);
                    command.Parameters.AddWithValue("@Notes", order.Notes ?? (object)DBNull.Value);
                    command.Parameters.AddWithValue("@CreatedByEmployeeID", order.CreatedByEmployeeID ?? (object)DBNull.Value);

                    await command.ExecuteNonQueryAsync();
                }
            }
        }

        /// <summary>
        /// Delete a production order
        /// </summary>
        public async Task DeleteProductionOrderAsync(int productionOrderID)
        {
            using (var connection = new SqlConnection(_connectionString))
            {
                await connection.OpenAsync();
                using (var command = new SqlCommand("sp_DeleteProductionOrder", connection))
                {
                    command.CommandType = System.Data.CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@ProductionOrderID", productionOrderID);

                    await command.ExecuteNonQueryAsync();
                }
            }
        }

        /// <summary>
        /// Search production orders with filters
        /// </summary>
        public async Task<List<ProductionOrderInfo>> SearchProductionOrdersAsync(
            string? searchTerm = null,
            string? status = null,
            string? priority = null,
            DateTime? startDate = null,
            DateTime? endDate = null,
            int? createdByEmployeeID = null)
        {
            var orders = new List<ProductionOrderInfo>();

            using (var connection = new SqlConnection(_connectionString))
            {
                await connection.OpenAsync();
                using (var command = new SqlCommand("sp_SearchProductionOrders", connection))
                {
                    command.CommandType = System.Data.CommandType.StoredProcedure;
                    
                    command.Parameters.AddWithValue("@SearchTerm", searchTerm ?? (object)DBNull.Value);
                    command.Parameters.AddWithValue("@Status", status ?? (object)DBNull.Value);
                    command.Parameters.AddWithValue("@Priority", priority ?? (object)DBNull.Value);
                    command.Parameters.AddWithValue("@StartDate", startDate ?? (object)DBNull.Value);
                    command.Parameters.AddWithValue("@EndDate", endDate ?? (object)DBNull.Value);
                    command.Parameters.AddWithValue("@CreatedByEmployeeID", createdByEmployeeID ?? (object)DBNull.Value);

                    using (var reader = await command.ExecuteReaderAsync())
                    {
                        while (await reader.ReadAsync())
                        {
                            orders.Add(new ProductionOrderInfo
                            {
                                ProductionOrderID = reader.GetInt32(reader.GetOrdinal("ProductionOrderID")),
                                ProductID = reader.GetInt32(reader.GetOrdinal("ProductID")),
                                QuantityOrdered = reader.GetInt32(reader.GetOrdinal("QuantityOrdered")),
                                QuantityCompleted = reader.GetInt32(reader.GetOrdinal("QuantityCompleted")),
                                StartDate = reader.IsDBNull(reader.GetOrdinal("StartDate")) ? null : reader.GetDateTime(reader.GetOrdinal("StartDate")),
                                ExpectedEndDate = reader.IsDBNull(reader.GetOrdinal("ExpectedEndDate")) ? null : reader.GetDateTime(reader.GetOrdinal("ExpectedEndDate")),
                                Status = reader.GetString(reader.GetOrdinal("Status")),
                                Priority = reader.GetString(reader.GetOrdinal("Priority")),
                                ProductName = reader.GetString(reader.GetOrdinal("ProductName")),
                                Category = reader.IsDBNull(reader.GetOrdinal("Category")) ? null : reader.GetString(reader.GetOrdinal("Category")),
                                CreatedByName = reader.IsDBNull(reader.GetOrdinal("CreatedByName")) ? null : reader.GetString(reader.GetOrdinal("CreatedByName")),
                                RemainingQuantity = reader.GetInt32(reader.GetOrdinal("RemainingQuantity"))
                            });
                        }
                    }
                }
            }

            return orders;
        }

        /// <summary>
        /// Get production order statistics for dashboard
        /// </summary>
        public async Task<ProductionOrderStatistics> GetProductionOrderStatisticsAsync()
        {
            var stats = new ProductionOrderStatistics();

            using (var connection = new SqlConnection(_connectionString))
            {
                await connection.OpenAsync();
                using (var command = new SqlCommand("sp_GetProductionOrderStatistics", connection))
                {
                    command.CommandType = System.Data.CommandType.StoredProcedure;

                    using (var reader = await command.ExecuteReaderAsync())
                    {
                        if (await reader.ReadAsync())
                        {
                            stats.TotalOrders = reader.GetInt32(reader.GetOrdinal("TotalOrders"));
                            stats.PendingOrders = reader.GetInt32(reader.GetOrdinal("PendingOrders"));
                            stats.InProgressOrders = reader.GetInt32(reader.GetOrdinal("InProgressOrders"));
                            stats.CompletedOrders = reader.GetInt32(reader.GetOrdinal("CompletedOrders"));
                            stats.CancelledOrders = reader.GetInt32(reader.GetOrdinal("CancelledOrders"));
                            stats.TotalQuantityOrdered = reader.IsDBNull(reader.GetOrdinal("TotalQuantityOrdered")) ? 0 : reader.GetInt32(reader.GetOrdinal("TotalQuantityOrdered"));
                            stats.TotalQuantityCompleted = reader.IsDBNull(reader.GetOrdinal("TotalQuantityCompleted")) ? 0 : reader.GetInt32(reader.GetOrdinal("TotalQuantityCompleted"));
                            stats.TotalRemainingQuantity = reader.IsDBNull(reader.GetOrdinal("TotalRemainingQuantity")) ? 0 : reader.GetInt32(reader.GetOrdinal("TotalRemainingQuantity"));
                            stats.AverageCompletionPercentage = reader.IsDBNull(reader.GetOrdinal("AverageCompletionPercentage")) ? 0 : reader.GetDouble(reader.GetOrdinal("AverageCompletionPercentage"));
                            stats.TodayOrders = reader.GetInt32(reader.GetOrdinal("TodayOrders"));
                            stats.UrgentOrders = reader.GetInt32(reader.GetOrdinal("UrgentOrders"));
                        }
                    }
                }
            }

            return stats;
        }

        #endregion

        #region Production Order Item Operations

        /// <summary>
        /// Get all items (raw materials) for a production order
        /// </summary>
        public async Task<List<ProductionOrderItemInfo>> GetProductionOrderItemsAsync(int productionOrderID)
        {
            var items = new List<ProductionOrderItemInfo>();

            using (var connection = new SqlConnection(_connectionString))
            {
                await connection.OpenAsync();
                using (var command = new SqlCommand("sp_GetProductionOrderItems", connection))
                {
                    command.CommandType = System.Data.CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@ProductionOrderID", productionOrderID);

                    using (var reader = await command.ExecuteReaderAsync())
                    {
                        while (await reader.ReadAsync())
                        {
                            items.Add(new ProductionOrderItemInfo
                            {
                                ProductionOrderItemID = reader.GetInt32(reader.GetOrdinal("ProductionOrderItemID")),
                                ProductionOrderID = reader.GetInt32(reader.GetOrdinal("ProductionOrderID")),
                                RawMaterialID = reader.GetInt32(reader.GetOrdinal("RawMaterialID")),
                                QuantityRequired = reader.GetDecimal(reader.GetOrdinal("QuantityRequired")),
                                QuantityUsed = reader.GetDecimal(reader.GetOrdinal("QuantityUsed")),
                                // Raw Material Information
                                MaterialName = reader.GetString(reader.GetOrdinal("MaterialName")),
                                Category = reader.IsDBNull(reader.GetOrdinal("Category")) ? null : reader.GetString(reader.GetOrdinal("Category")),
                                Unit = reader.IsDBNull(reader.GetOrdinal("Unit")) ? null : reader.GetString(reader.GetOrdinal("Unit")),
                                AvailableStock = reader.GetDecimal(reader.GetOrdinal("AvailableStock")),
                                UnitPrice = reader.GetDecimal(reader.GetOrdinal("UnitPrice")),
                                // Calculated Fields
                                RemainingQuantity = reader.GetDecimal(reader.GetOrdinal("RemainingQuantity")),
                                TotalCost = reader.GetDecimal(reader.GetOrdinal("TotalCost"))
                            });
                        }
                    }
                }
            }

            return items;
        }

        /// <summary>
        /// Add a raw material item to a production order
        /// </summary>
        public async Task<int> AddProductionOrderItemAsync(ProductionOrderItemInfo item)
        {
            int productionOrderItemID = 0;

            using (var connection = new SqlConnection(_connectionString))
            {
                await connection.OpenAsync();
                using (var command = new SqlCommand("sp_AddProductionOrderItem", connection))
                {
                    command.CommandType = System.Data.CommandType.StoredProcedure;
                    
                    command.Parameters.AddWithValue("@ProductionOrderID", item.ProductionOrderID);
                    command.Parameters.AddWithValue("@RawMaterialID", item.RawMaterialID);
                    command.Parameters.AddWithValue("@QuantityRequired", item.QuantityRequired);
                    
                    var outputParam = new SqlParameter("@ProductionOrderItemID", System.Data.SqlDbType.Int)
                    {
                        Direction = System.Data.ParameterDirection.Output
                    };
                    command.Parameters.Add(outputParam);

                    await command.ExecuteNonQueryAsync();
                    productionOrderItemID = (int)outputParam.Value;
                }
            }

            return productionOrderItemID;
        }

        /// <summary>
        /// Update a production order item
        /// </summary>
        public async Task UpdateProductionOrderItemAsync(ProductionOrderItemInfo item)
        {
            using (var connection = new SqlConnection(_connectionString))
            {
                await connection.OpenAsync();
                using (var command = new SqlCommand("sp_UpdateProductionOrderItem", connection))
                {
                    command.CommandType = System.Data.CommandType.StoredProcedure;
                    
                    command.Parameters.AddWithValue("@ProductionOrderItemID", item.ProductionOrderItemID);
                    command.Parameters.AddWithValue("@RawMaterialID", item.RawMaterialID);
                    command.Parameters.AddWithValue("@QuantityRequired", item.QuantityRequired);
                    command.Parameters.AddWithValue("@QuantityUsed", item.QuantityUsed);

                    await command.ExecuteNonQueryAsync();
                }
            }
        }

        /// <summary>
        /// Delete a production order item
        /// </summary>
        public async Task DeleteProductionOrderItemAsync(int productionOrderItemID)
        {
            using (var connection = new SqlConnection(_connectionString))
            {
                await connection.OpenAsync();
                using (var command = new SqlCommand("sp_DeleteProductionOrderItem", connection))
                {
                    command.CommandType = System.Data.CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@ProductionOrderItemID", productionOrderItemID);

                    await command.ExecuteNonQueryAsync();
                }
            }
        }

        #endregion
    }

    #region Data Models

    /// <summary>
    /// Production Order information with related data
    /// </summary>
    public class ProductionOrderInfo
    {
        // Production Order Fields
        public int ProductionOrderID { get; set; }
        public int ProductID { get; set; }
        public int QuantityOrdered { get; set; }
        public int QuantityCompleted { get; set; }
        public DateTime? StartDate { get; set; }
        public DateTime? ExpectedEndDate { get; set; }
        public DateTime? ActualEndDate { get; set; }
        public string Status { get; set; } = "Pending";
        public string Priority { get; set; } = "Normal";
        public string? Notes { get; set; }
        public int? CreatedByEmployeeID { get; set; }
        public DateTime CreatedDate { get; set; }
        public DateTime? UpdatedDate { get; set; }

        // Product Information
        public string ProductName { get; set; } = string.Empty;
        public string? Category { get; set; }
        public string? Brand { get; set; }
        public string? SKU { get; set; }
        public decimal SalePrice { get; set; }
        public string? Material { get; set; }

        // Employee Information (Tailor)
        public string? CreatedByName { get; set; }
        public string? CreatedByPhone { get; set; }
        public string? CreatedByEmail { get; set; }
        public string? EmployeeRole { get; set; }
        public string? DepartmentName { get; set; }

        // Calculated Fields
        public int RemainingQuantity { get; set; }
        public double CompletionPercentage { get; set; }
    }

    /// <summary>
    /// Production Order Item (Raw Material) information
    /// </summary>
    public class ProductionOrderItemInfo
    {
        public int ProductionOrderItemID { get; set; }
        public int ProductionOrderID { get; set; }
        public int RawMaterialID { get; set; }
        public decimal QuantityRequired { get; set; }
        public decimal QuantityUsed { get; set; }

        // Raw Material Information
        public string MaterialName { get; set; } = string.Empty;
        public string? Category { get; set; }
        public string? Unit { get; set; }
        public decimal AvailableStock { get; set; }
        public decimal UnitPrice { get; set; }

        // Calculated Fields
        public decimal RemainingQuantity { get; set; }
        public decimal TotalCost { get; set; }
    }

    /// <summary>
    /// Production Order statistics for dashboard
    /// </summary>
    public class ProductionOrderStatistics
    {
        public int TotalOrders { get; set; }
        public int PendingOrders { get; set; }
        public int InProgressOrders { get; set; }
        public int CompletedOrders { get; set; }
        public int CancelledOrders { get; set; }
        public int TotalQuantityOrdered { get; set; }
        public int TotalQuantityCompleted { get; set; }
        public int TotalRemainingQuantity { get; set; }
        public double AverageCompletionPercentage { get; set; }
        public int TodayOrders { get; set; }
        public int UrgentOrders { get; set; }
    }

    #endregion
}
