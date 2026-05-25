using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Threading.Tasks;
using FactoryManagmentSystem.Models;

namespace FactoryManagmentSystem.Services
{
    public class StockService
    {
        private readonly string _connectionString;

        public StockService()
        {
            _connectionString = "Server=QASIM\\SQLEXPRESS;Database=GarmentsFactoryDB;Trusted_Connection=True;TrustServerCertificate=True;MultipleActiveResultSets=True;";
        }

        // Get all stock entries
        public async Task<List<Stock>> GetAllStockEntriesAsync()
        {
            var stockEntries = new List<Stock>();
            
            try
            {
                using (var connection = new SqlConnection(_connectionString))
                {
                    await connection.OpenAsync();
                    using (var command = new SqlCommand("sp_GetAllStockEntries", connection))
                    {
                        command.CommandType = System.Data.CommandType.StoredProcedure;
                        
                        using (var reader = await command.ExecuteReaderAsync())
                        {
                            while (await reader.ReadAsync())
                            {
                                var stock = MapStock(reader);
                                stockEntries.Add(stock);
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception($"Error retrieving stock entries: {ex.Message}");
            }
            
            return stockEntries;
        }

        // Get stock entry by ID
        public async Task<Stock?> GetStockByIdAsync(int stockId)
        {
            Stock? stock = null;
            
            try
            {
                using (var connection = new SqlConnection(_connectionString))
                {
                    await connection.OpenAsync();
                    using (var command = new SqlCommand("sp_GetStockById", connection))
                    {
                        command.CommandType = System.Data.CommandType.StoredProcedure;
                        command.Parameters.AddWithValue("@StockID", stockId);
                        
                        using (var reader = await command.ExecuteReaderAsync())
                        {
                            if (await reader.ReadAsync())
                            {
                                stock = MapStock(reader);
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception($"Error retrieving stock entry: {ex.Message}");
            }
            
            return stock;
        }

        // Add new stock entry
        public async Task<int> AddStockEntryAsync(Stock stock)
        {
            int newStockId = 0;
            
            try
            {
                using (var connection = new SqlConnection(_connectionString))
                {
                    await connection.OpenAsync();
                    using (var command = new SqlCommand("sp_AddStockEntry", connection))
                    {
                        command.CommandType = System.Data.CommandType.StoredProcedure;
                        
                        command.Parameters.AddWithValue("@ProductID", stock.ProductId);
                        command.Parameters.AddWithValue("@BatchNo", stock.BatchNo);
                        command.Parameters.AddWithValue("@EntryDate", stock.EntryDate);
                        command.Parameters.AddWithValue("@Quantity", stock.Quantity);
                        command.Parameters.AddWithValue("@StockStatus", stock.StockStatus);
                        command.Parameters.AddWithValue("@ProgressPercentage", stock.ProgressPercentage);
                        command.Parameters.AddWithValue("@Location", (object?)stock.Location ?? DBNull.Value);
                        command.Parameters.AddWithValue("@Notes", (object?)stock.Notes ?? DBNull.Value);
                        command.Parameters.AddWithValue("@CreatedBy", (object?)stock.CreatedBy ?? DBNull.Value);
                        
                        var result = await command.ExecuteScalarAsync();
                        newStockId = Convert.ToInt32(result);
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception($"Error adding stock entry: {ex.Message}");
            }
            
            return newStockId;
        }

        // Update stock entry
        public async Task UpdateStockEntryAsync(Stock stock)
        {
            try
            {
                using (var connection = new SqlConnection(_connectionString))
                {
                    await connection.OpenAsync();
                    using (var command = new SqlCommand("sp_UpdateStockEntry", connection))
                    {
                        command.CommandType = System.Data.CommandType.StoredProcedure;
                        
                        command.Parameters.AddWithValue("@StockID", stock.StockId);
                        command.Parameters.AddWithValue("@ProductID", stock.ProductId);
                        command.Parameters.AddWithValue("@BatchNo", stock.BatchNo);
                        command.Parameters.AddWithValue("@EntryDate", stock.EntryDate);
                        command.Parameters.AddWithValue("@Quantity", stock.Quantity);
                        command.Parameters.AddWithValue("@StockStatus", stock.StockStatus);
                        command.Parameters.AddWithValue("@ProgressPercentage", stock.ProgressPercentage);
                        command.Parameters.AddWithValue("@Location", (object?)stock.Location ?? DBNull.Value);
                        command.Parameters.AddWithValue("@Notes", (object?)stock.Notes ?? DBNull.Value);
                        
                        await command.ExecuteNonQueryAsync();
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception($"Error updating stock entry: {ex.Message}");
            }
        }

        // Delete stock entry
        public async Task DeleteStockEntryAsync(int stockId)
        {
            try
            {
                using (var connection = new SqlConnection(_connectionString))
                {
                    await connection.OpenAsync();
                    using (var command = new SqlCommand("sp_DeleteStockEntry", connection))
                    {
                        command.CommandType = System.Data.CommandType.StoredProcedure;
                        command.Parameters.AddWithValue("@StockID", stockId);
                        
                        await command.ExecuteNonQueryAsync();
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception($"Error deleting stock entry: {ex.Message}");
            }
        }

        // Get stock statistics (OLD - kept for compatibility)
        public async Task<(int TotalEntries, int Ready, int InProcess, int Shipped, int Delivered)> GetStockStatisticsOldAsync()
        {
            int totalEntries = 0;
            int ready = 0;
            int inProcess = 0;
            int shipped = 0;
            int delivered = 0;
            
            try
            {
                using (var connection = new SqlConnection(_connectionString))
                {
                    await connection.OpenAsync();
                    using (var command = new SqlCommand("sp_GetStockStatistics", connection))
                    {
                        command.CommandType = System.Data.CommandType.StoredProcedure;
                        
                        using (var reader = await command.ExecuteReaderAsync())
                        {
                            if (await reader.ReadAsync())
                            {
                                totalEntries = reader.GetInt32(reader.GetOrdinal("TotalStockEntries"));
                                ready = reader.GetInt32(reader.GetOrdinal("ReadyProducts"));
                                inProcess = reader.GetInt32(reader.GetOrdinal("InProcess"));
                                shipped = reader.GetInt32(reader.GetOrdinal("Shipped"));
                                delivered = reader.GetInt32(reader.GetOrdinal("Delivered"));
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception($"Error retrieving stock statistics: {ex.Message}");
            }
            
            return (totalEntries, ready, inProcess, shipped, delivered);
        }

        // Search stock entries
        public async Task<List<Stock>> SearchStockEntriesAsync(string? searchTerm = null, string? stockStatus = null, int? productId = null)
        {
            var stockEntries = new List<Stock>();
            
            try
            {
                using (var connection = new SqlConnection(_connectionString))
                {
                    await connection.OpenAsync();
                    using (var command = new SqlCommand("sp_SearchStockEntries", connection))
                    {
                        command.CommandType = System.Data.CommandType.StoredProcedure;
                        
                        command.Parameters.AddWithValue("@SearchTerm", (object?)searchTerm ?? DBNull.Value);
                        command.Parameters.AddWithValue("@StockStatus", (object?)stockStatus ?? DBNull.Value);
                        command.Parameters.AddWithValue("@ProductID", (object?)productId ?? DBNull.Value);
                        
                        using (var reader = await command.ExecuteReaderAsync())
                        {
                            while (await reader.ReadAsync())
                            {
                                var stock = MapStock(reader);
                                stockEntries.Add(stock);
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception($"Error searching stock entries: {ex.Message}");
            }
            
            return stockEntries;
        }

        // Get stock by product
        public async Task<List<Stock>> GetStockByProductAsync(int productId)
        {
            var stockEntries = new List<Stock>();
            
            try
            {
                using (var connection = new SqlConnection(_connectionString))
                {
                    await connection.OpenAsync();
                    using (var command = new SqlCommand("sp_GetStockByProduct", connection))
                    {
                        command.CommandType = System.Data.CommandType.StoredProcedure;
                        command.Parameters.AddWithValue("@ProductID", productId);
                        
                        using (var reader = await command.ExecuteReaderAsync())
                        {
                            while (await reader.ReadAsync())
                            {
                                var stock = MapStock(reader);
                                stockEntries.Add(stock);
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception($"Error retrieving stock by product: {ex.Message}");
            }
            
            return stockEntries;
        }

        // Update stock status
        public async Task UpdateStockStatusAsync(int stockId, string newStatus, int progressPercentage)
        {
            try
            {
                using (var connection = new SqlConnection(_connectionString))
                {
                    await connection.OpenAsync();
                    using (var command = new SqlCommand("sp_UpdateStockStatus", connection))
                    {
                        command.CommandType = System.Data.CommandType.StoredProcedure;
                        
                        command.Parameters.AddWithValue("@StockID", stockId);
                        command.Parameters.AddWithValue("@NewStatus", newStatus);
                        command.Parameters.AddWithValue("@ProgressPercentage", progressPercentage);
                        
                        await command.ExecuteNonQueryAsync();
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception($"Error updating stock status: {ex.Message}");
            }
        }

        // Get all products for dropdown
        public async Task<List<Product>> GetProductsForStockAsync()
        {
            var products = new List<Product>();
            
            try
            {
                using (var connection = new SqlConnection(_connectionString))
                {
                    await connection.OpenAsync();
                    using (var command = new SqlCommand("sp_GetProductsForStock", connection))
                    {
                        command.CommandType = System.Data.CommandType.StoredProcedure;
                        
                        using (var reader = await command.ExecuteReaderAsync())
                        {
                            while (await reader.ReadAsync())
                            {
                                var product = new Product
                                {
                                    ProductId = reader.GetInt32(reader.GetOrdinal("ProductID")),
                                    Name = reader.GetString(reader.GetOrdinal("ProductName")),
                                    Category = (ProductCategory)Enum.Parse(typeof(ProductCategory), reader.GetString(reader.GetOrdinal("Category"))),
                                    SKU = reader.IsDBNull(reader.GetOrdinal("SKU")) ? null : reader.GetString(reader.GetOrdinal("SKU"))
                                };
                                products.Add(product);
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception($"Error retrieving products for stock: {ex.Message}");
            }
            
            return products;
        }

        // =====================================================
        // NEW: Stock Management Integration Methods
        // =====================================================
        
        /// <summary>
        /// Get stock management summary (Total, Ready, InProcess, Shipped counts)
        /// </summary>
        public async Task<(int TotalStockEntries, int ReadyProducts, int InProcess, int Shipped)> GetStockManagementSummaryAsync()
        {
            try
            {
                using (var connection = new SqlConnection(_connectionString))
                {
                    await connection.OpenAsync();
                    using (var command = new SqlCommand("sp_GetStockManagement", connection))
                    {
                        command.CommandType = System.Data.CommandType.StoredProcedure;
                        // @Status = NULL returns summary
                        
                        using (var reader = await command.ExecuteReaderAsync())
                        {
                            if (await reader.ReadAsync())
                            {
                                int total = reader.GetInt32(reader.GetOrdinal("TotalStockEntries"));
                                int ready = reader.GetInt32(reader.GetOrdinal("ReadyProducts"));
                                int inProcess = reader.GetInt32(reader.GetOrdinal("InProcess"));
                                int shipped = reader.GetInt32(reader.GetOrdinal("Shipped"));
                                
                                return (total, ready, inProcess, shipped);
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception($"Error retrieving stock summary: {ex.Message}");
            }
            
            return (0, 0, 0, 0);
        }
        
        /// <summary>
        /// Get stock items by status (InProcess, Ready, or Shipped)
        /// </summary>
        public async Task<List<StockManagementItem>> GetStockByStatusAsync(string status)
        {
            var items = new List<StockManagementItem>();
            
            try
            {
                using (var connection = new SqlConnection(_connectionString))
                {
                    await connection.OpenAsync();
                    using (var command = new SqlCommand("sp_GetStockManagement", connection))
                    {
                        command.CommandType = System.Data.CommandType.StoredProcedure;
                        command.Parameters.AddWithValue("@Status", status);
                        
                        using (var reader = await command.ExecuteReaderAsync())
                        {
                            while (await reader.ReadAsync())
                            {
                                items.Add(new StockManagementItem
                                {
                                    StockID = reader.GetInt32(reader.GetOrdinal("StockID")),
                                    BatchNo = reader.GetString(reader.GetOrdinal("BatchNo")),
                                    Product = reader.GetString(reader.GetOrdinal("Product")),
                                    Quantity = reader.GetInt32(reader.GetOrdinal(
                                        status == "InProcess" ? "InProcessQty" : 
                                        status == "Ready" ? "ReadyQty" : "ShippedQty")),
                                    DateAdded = reader.GetDateTime(reader.GetOrdinal("DateAdded")),
                                    Status = reader.GetString(reader.GetOrdinal("Status")),
                                    OrderType = reader.GetString(reader.GetOrdinal("OrderType")),
                                    CustomerName = reader.IsDBNull(reader.GetOrdinal("CustomerName")) ? 
                                        "" : reader.GetString(reader.GetOrdinal("CustomerName"))
                                });
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception($"Error retrieving stock items for status '{status}': {ex.Message}");
            }
            
            return items;
        }

        // Helper method to map SqlDataReader to Stock object
        private Stock MapStock(SqlDataReader reader)
        {
            return new Stock
            {
                StockId = reader.GetInt32(reader.GetOrdinal("StockID")),
                ProductId = reader.GetInt32(reader.GetOrdinal("ProductID")),
                BatchNo = reader.GetString(reader.GetOrdinal("BatchNo")),
                EntryDate = reader.GetDateTime(reader.GetOrdinal("EntryDate")),
                Quantity = reader.GetInt32(reader.GetOrdinal("Quantity")),
                StockStatus = reader.GetString(reader.GetOrdinal("StockStatus")),
                ProgressPercentage = reader.GetInt32(reader.GetOrdinal("ProgressPercentage")),
                Location = reader.IsDBNull(reader.GetOrdinal("Location")) ? null : reader.GetString(reader.GetOrdinal("Location")),
                Notes = reader.IsDBNull(reader.GetOrdinal("Notes")) ? null : reader.GetString(reader.GetOrdinal("Notes")),
                CreatedBy = reader.IsDBNull(reader.GetOrdinal("CreatedBy")) ? null : reader.GetInt32(reader.GetOrdinal("CreatedBy")),
                LastUpdated = reader.GetDateTime(reader.GetOrdinal("LastUpdated")),
                CreatedDate = reader.GetDateTime(reader.GetOrdinal("CreatedDate")),
                ProductName = reader.GetString(reader.GetOrdinal("ProductName")),
                Category = reader.GetString(reader.GetOrdinal("Category")),
                SKU = reader.IsDBNull(reader.GetOrdinal("SKU")) ? null : reader.GetString(reader.GetOrdinal("SKU"))
            };
        }

        // ================================================================================
        // NEW DYNAMIC STOCK MANAGEMENT METHODS
        // ================================================================================

        public async Task<List<ReadyProductModel>> GetReadyProductsAsync()
        {
            var products = new List<ReadyProductModel>();
            try
            {
                using (var connection = new SqlConnection(_connectionString))
                {
                    await connection.OpenAsync();
                    using (var command = new SqlCommand("sp_GetReadyProducts", connection))
                    {
                        command.CommandType = System.Data.CommandType.StoredProcedure;
                        using (var reader = await command.ExecuteReaderAsync())
                        {
                            while (await reader.ReadAsync())
                            {
                                products.Add(new ReadyProductModel
                                {
                                    StockID = reader.GetInt32(reader.GetOrdinal("StockID")),
                                    ProductID = reader.GetInt32(reader.GetOrdinal("ProductID")),
                                    BatchNo = reader.GetString(reader.GetOrdinal("BatchNo")),
                                    Product = reader.GetString(reader.GetOrdinal("Product")),
                                    OrderType = reader.GetString(reader.GetOrdinal("OrderType")),
                                    Quantity = reader.GetInt32(reader.GetOrdinal("Quantity")),
                                    DateAdded = reader.IsDBNull(reader.GetOrdinal("DateAdded")) ? null : reader.GetDateTime(reader.GetOrdinal("DateAdded")),
                                    ProgressPercentage = reader.GetInt32(reader.GetOrdinal("ProgressPercentage")),
                                    CustomerName = reader.IsDBNull(reader.GetOrdinal("CustomerName")) ? null : reader.GetString(reader.GetOrdinal("CustomerName"))
                                });
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception($"Error retrieving ready products: {ex.Message}");
            }
            return products;
        }

        public async Task<List<InProcessProductModel>> GetInProcessProductsAsync()
        {
            var products = new List<InProcessProductModel>();
            try
            {
                using (var connection = new SqlConnection(_connectionString))
                {
                    await connection.OpenAsync();
                    using (var command = new SqlCommand("sp_GetInProcessProducts", connection))
                    {
                        command.CommandType = System.Data.CommandType.StoredProcedure;
                        using (var reader = await command.ExecuteReaderAsync())
                        {
                            while (await reader.ReadAsync())
                            {
                                products.Add(new InProcessProductModel
                                {
                                    StockID = reader.GetInt32(reader.GetOrdinal("StockID")),
                                    ProductID = reader.GetInt32(reader.GetOrdinal("ProductID")),
                                    BatchNo = reader.GetString(reader.GetOrdinal("BatchNo")),
                                    Product = reader.GetString(reader.GetOrdinal("Product")),
                                    OrderType = reader.GetString(reader.GetOrdinal("OrderType")),
                                    TotalQuantity = reader.GetInt32(reader.GetOrdinal("TotalQuantity")),
                                    CompletedQuantity = reader.GetInt32(reader.GetOrdinal("CompletedQuantity")),
                                    RemainingQuantity = reader.GetInt32(reader.GetOrdinal("RemainingQuantity")),
                                    DateAdded = reader.IsDBNull(reader.GetOrdinal("DateAdded")) ? null : reader.GetDateTime(reader.GetOrdinal("DateAdded")),
                                    ProgressPercentage = reader.GetInt32(reader.GetOrdinal("ProgressPercentage")),
                                    CustomerName = reader.IsDBNull(reader.GetOrdinal("CustomerName")) ? null : reader.GetString(reader.GetOrdinal("CustomerName"))
                                });
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception($"Error retrieving in-process products: {ex.Message}");
            }
            return products;
        }

        public async Task<List<ShippedProductModel>> GetShippedProductsAsync()
        {
            var products = new List<ShippedProductModel>();
            try
            {
                using (var connection = new SqlConnection(_connectionString))
                {
                    await connection.OpenAsync();
                    using (var command = new SqlCommand("sp_GetShippedProducts", connection))
                    {
                        command.CommandType = System.Data.CommandType.StoredProcedure;
                        using (var reader = await command.ExecuteReaderAsync())
                        {
                            while (await reader.ReadAsync())
                            {
                                products.Add(new ShippedProductModel
                                {
                                    StockID = reader.GetInt32(reader.GetOrdinal("StockID")),
                                    ProductID = reader.IsDBNull(reader.GetOrdinal("ProductID")) ? null : reader.GetInt32(reader.GetOrdinal("ProductID")),
                                    BatchNo = reader.IsDBNull(reader.GetOrdinal("BatchNo")) ? null : reader.GetString(reader.GetOrdinal("BatchNo")),
                                    Product = reader.IsDBNull(reader.GetOrdinal("Product")) ? null : reader.GetString(reader.GetOrdinal("Product")),
                                    OrderType = reader.GetString(reader.GetOrdinal("OrderType")),
                                    Quantity = reader.IsDBNull(reader.GetOrdinal("Quantity")) ? 0 : reader.GetInt32(reader.GetOrdinal("Quantity")),
                                    DateShipped = reader.IsDBNull(reader.GetOrdinal("DateShipped")) ? null : reader.GetDateTime(reader.GetOrdinal("DateShipped")),
                                    CustomerName = reader.IsDBNull(reader.GetOrdinal("CustomerName")) ? null : reader.GetString(reader.GetOrdinal("CustomerName")),
                                    DeliveryStatus = reader.GetString(reader.GetOrdinal("DeliveryStatus"))
                                });
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception($"Error retrieving shipped products: {ex.Message}");
            }
            return products;
        }

        public async Task<StockStatisticsModel> GetStockStatisticsAsync()
        {
            try
            {
                using (var connection = new SqlConnection(_connectionString))
                {
                    await connection.OpenAsync();
                    using (var command = new SqlCommand("sp_GetStockStatistics", connection))
                    {
                        command.CommandType = System.Data.CommandType.StoredProcedure;
                        using (var reader = await command.ExecuteReaderAsync())
                        {
                            if (await reader.ReadAsync())
                            {
                                return new StockStatisticsModel
                                {
                                    ReadyCount = reader.GetInt32(reader.GetOrdinal("ReadyCount")),
                                    ReadyQuantity = reader.GetInt32(reader.GetOrdinal("ReadyQuantity")),
                                    InProcessCount = reader.GetInt32(reader.GetOrdinal("InProcessCount")),
                                    InProcessQuantity = reader.GetInt32(reader.GetOrdinal("InProcessQuantity")),
                                    ShippedCount = reader.GetInt32(reader.GetOrdinal("ShippedCount")),
                                    ShippedQuantity = reader.GetInt32(reader.GetOrdinal("ShippedQuantity")),
                                    TotalOrders = reader.GetInt32(reader.GetOrdinal("TotalOrders"))
                                };
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception($"Error retrieving stock statistics: {ex.Message}");
            }
            return new StockStatisticsModel();
        }
    }
    
    // ================================================================================
    // MODELS
    // ================================================================================

    public class ReadyProductModel
    {
        public int StockID { get; set; }
        public int ProductID { get; set; }
        public string BatchNo { get; set; }
        public string Product { get; set; }
        public string OrderType { get; set; }
        public int Quantity { get; set; }
        public DateTime? DateAdded { get; set; }
        public int ProgressPercentage { get; set; }
        public string CustomerName { get; set; }
    }

    public class InProcessProductModel
    {
        public int StockID { get; set; }
        public int ProductID { get; set; }
        public string BatchNo { get; set; }
        public string Product { get; set; }
        public string OrderType { get; set; }
        public int TotalQuantity { get; set; }
        public int CompletedQuantity { get; set; }
        public int RemainingQuantity { get; set; }
        public DateTime? DateAdded { get; set; }
        public int ProgressPercentage { get; set; }
        public string CustomerName { get; set; }
    }

    public class ShippedProductModel
    {
        public int StockID { get; set; }
        public int? ProductID { get; set; }
        public string BatchNo { get; set; }
        public string Product { get; set; }
        public string OrderType { get; set; }
        public int Quantity { get; set; }
        public DateTime? DateShipped { get; set; }
        public string CustomerName { get; set; }
        public string DeliveryStatus { get; set; }
    }

    public class StockStatisticsModel
    {
        public int ReadyCount { get; set; }
        public int ReadyQuantity { get; set; }
        public int InProcessCount { get; set; }
        public int InProcessQuantity { get; set; }
        public int ShippedCount { get; set; }
        public int ShippedQuantity { get; set; }
        public int TotalOrders { get; set; }
    }

    /// <summary>
    /// Model for Stock Management items from sp_GetStockManagement
    /// </summary>
    public class StockManagementItem
    {
        public int StockID { get; set; }
        public string BatchNo { get; set; }
        public string Product { get; set; }
        public int Quantity { get; set; }
        public DateTime DateAdded { get; set; }
        public string Status { get; set; }
        public string OrderType { get; set; }
        public string CustomerName { get; set; }
    }
}
