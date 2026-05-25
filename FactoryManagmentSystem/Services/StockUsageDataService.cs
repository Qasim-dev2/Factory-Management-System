using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Threading.Tasks;
using FactoryManagmentSystem.Models;

namespace FactoryManagmentSystem.Services
{
    public class StockUsageDataService
    {
        private readonly string _connectionString = "Server=QASIM\\SQLEXPRESS;Database=GarmentsFactoryDB;Integrated Security=True;";

        // ================================================================================
        // 1. GET ALL STOCK USAGE RECORDS
        // ================================================================================
        public async Task<List<StockUsageInfo>> GetAllStockUsageAsync()
        {
            var stockUsages = new List<StockUsageInfo>();

            try
            {
                using (var connection = new SqlConnection(_connectionString))
                {
                    await connection.OpenAsync();
                    using (var command = new SqlCommand("sp_GetAllStockUsage", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;

                        using (var reader = await command.ExecuteReaderAsync())
                        {
                            while (await reader.ReadAsync())
                            {
                                stockUsages.Add(new StockUsageInfo
                                {
                                    StockUsageID = reader.GetInt32(reader.GetOrdinal("StockUsageID")),
                                    EmployeeID = reader.GetInt32(reader.GetOrdinal("EmployeeID")),
                                    EmployeeName = reader.GetString(reader.GetOrdinal("EmployeeName")),
                                    ProductionOrderID = reader.GetInt32(reader.GetOrdinal("ProductionOrderID")),
                                    OrderNumber = reader.GetInt32(reader.GetOrdinal("OrderNumber")),
                                    RawMaterialID = reader.GetInt32(reader.GetOrdinal("RawMaterialID")),
                                    MaterialName = reader.GetString(reader.GetOrdinal("MaterialName")),
                                    MaterialCategory = reader.IsDBNull(reader.GetOrdinal("MaterialCategory")) ? "" : reader.GetString(reader.GetOrdinal("MaterialCategory")),
                                    Unit = reader.IsDBNull(reader.GetOrdinal("Unit")) ? "" : reader.GetString(reader.GetOrdinal("Unit")),
                                    QuantityUsed = reader.GetDecimal(reader.GetOrdinal("QuantityUsed")),
                                    TotalCost = reader.GetDecimal(reader.GetOrdinal("TotalCost")),
                                    UsageDate = reader.GetDateTime(reader.GetOrdinal("UsageDate")),
                                    Notes = reader.IsDBNull(reader.GetOrdinal("Notes")) ? "" : reader.GetString(reader.GetOrdinal("Notes"))
                                });
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception($"Error getting stock usage records: {ex.Message}", ex);
            }

            return stockUsages;
        }

        // ================================================================================
        // 2. GET STOCK USAGE BY ID
        // ================================================================================
        public async Task<StockUsageInfo> GetStockUsageByIdAsync(int stockUsageId)
        {
            try
            {
                using (var connection = new SqlConnection(_connectionString))
                {
                    await connection.OpenAsync();
                    using (var command = new SqlCommand("sp_GetStockUsageById", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.AddWithValue("@StockUsageID", stockUsageId);

                        using (var reader = await command.ExecuteReaderAsync())
                        {
                            if (await reader.ReadAsync())
                            {
                                return new StockUsageInfo
                                {
                                    StockUsageID = reader.GetInt32(reader.GetOrdinal("StockUsageID")),
                                    EmployeeID = reader.GetInt32(reader.GetOrdinal("EmployeeID")),
                                    EmployeeName = reader.GetString(reader.GetOrdinal("EmployeeName")),
                                    ProductionOrderID = reader.GetInt32(reader.GetOrdinal("ProductionOrderID")),
                                    OrderNumber = reader.GetInt32(reader.GetOrdinal("OrderNumber")),
                                    RawMaterialID = reader.GetInt32(reader.GetOrdinal("RawMaterialID")),
                                    MaterialName = reader.GetString(reader.GetOrdinal("MaterialName")),
                                    MaterialCategory = reader.IsDBNull(reader.GetOrdinal("MaterialCategory")) ? "" : reader.GetString(reader.GetOrdinal("MaterialCategory")),
                                    Unit = reader.IsDBNull(reader.GetOrdinal("Unit")) ? "" : reader.GetString(reader.GetOrdinal("Unit")),
                                    QuantityUsed = reader.GetDecimal(reader.GetOrdinal("QuantityUsed")),
                                    TotalCost = reader.GetDecimal(reader.GetOrdinal("TotalCost")),
                                    UsageDate = reader.GetDateTime(reader.GetOrdinal("UsageDate")),
                                    Notes = reader.IsDBNull(reader.GetOrdinal("Notes")) ? "" : reader.GetString(reader.GetOrdinal("Notes"))
                                };
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception($"Error getting stock usage by ID: {ex.Message}", ex);
            }

            return null;
        }

        // ================================================================================
        // 3. RECORD STOCK USAGE (With auto-deduction)
        // ================================================================================
        public async Task<int> RecordStockUsageAsync(int employeeId, int productionOrderId, int rawMaterialId, 
            decimal quantityUsed, string notes = null)
        {
            try
            {
                using (var connection = new SqlConnection(_connectionString))
                {
                    await connection.OpenAsync();
                    using (var command = new SqlCommand("sp_RecordStockUsage", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.AddWithValue("@EmployeeID", employeeId);
                        command.Parameters.AddWithValue("@ProductionOrderID", productionOrderId);
                        command.Parameters.AddWithValue("@RawMaterialID", rawMaterialId);
                        command.Parameters.AddWithValue("@QuantityUsed", quantityUsed);
                        command.Parameters.AddWithValue("@Notes", (object)notes ?? DBNull.Value);

                        var outputParam = new SqlParameter("@StockUsageID", SqlDbType.Int)
                        {
                            Direction = ParameterDirection.Output
                        };
                        command.Parameters.Add(outputParam);

                        await command.ExecuteNonQueryAsync();

                        return (int)outputParam.Value;
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception($"Error recording stock usage: {ex.Message}", ex);
            }
        }

        // ================================================================================
        // 4. GET STOCK USAGE BY PRODUCTION ORDER
        // ================================================================================
        public async Task<List<StockUsageInfo>> GetStockUsageByProductionOrderAsync(int productionOrderId)
        {
            var stockUsages = new List<StockUsageInfo>();

            try
            {
                using (var connection = new SqlConnection(_connectionString))
                {
                    await connection.OpenAsync();
                    using (var command = new SqlCommand("sp_GetStockUsageByProductionOrder", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.AddWithValue("@ProductionOrderID", productionOrderId);

                        using (var reader = await command.ExecuteReaderAsync())
                        {
                            while (await reader.ReadAsync())
                            {
                                stockUsages.Add(new StockUsageInfo
                                {
                                    StockUsageID = reader.GetInt32(reader.GetOrdinal("StockUsageID")),
                                    EmployeeID = reader.GetInt32(reader.GetOrdinal("EmployeeID")),
                                    EmployeeName = reader.GetString(reader.GetOrdinal("EmployeeName")),
                                    ProductionOrderID = productionOrderId,
                                    RawMaterialID = reader.GetInt32(reader.GetOrdinal("RawMaterialID")),
                                    MaterialName = reader.GetString(reader.GetOrdinal("MaterialName")),
                                    MaterialCategory = reader.IsDBNull(reader.GetOrdinal("MaterialCategory")) ? "" : reader.GetString(reader.GetOrdinal("MaterialCategory")),
                                    Unit = reader.IsDBNull(reader.GetOrdinal("Unit")) ? "" : reader.GetString(reader.GetOrdinal("Unit")),
                                    QuantityUsed = reader.GetDecimal(reader.GetOrdinal("QuantityUsed")),
                                    TotalCost = reader.GetDecimal(reader.GetOrdinal("TotalCost")),
                                    UsageDate = reader.GetDateTime(reader.GetOrdinal("UsageDate")),
                                    Notes = reader.IsDBNull(reader.GetOrdinal("Notes")) ? "" : reader.GetString(reader.GetOrdinal("Notes"))
                                });
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception($"Error getting stock usage by production order: {ex.Message}", ex);
            }

            return stockUsages;
        }

        // ================================================================================
        // 5. GET STOCK USAGE BY EMPLOYEE (Tailor)
        // ================================================================================
        public async Task<List<StockUsageInfo>> GetStockUsageByEmployeeAsync(int employeeId)
        {
            var stockUsages = new List<StockUsageInfo>();

            try
            {
                using (var connection = new SqlConnection(_connectionString))
                {
                    await connection.OpenAsync();
                    using (var command = new SqlCommand("sp_GetStockUsageByEmployee", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.AddWithValue("@EmployeeID", employeeId);

                        using (var reader = await command.ExecuteReaderAsync())
                        {
                            while (await reader.ReadAsync())
                            {
                                stockUsages.Add(new StockUsageInfo
                                {
                                    StockUsageID = reader.GetInt32(reader.GetOrdinal("StockUsageID")),
                                    EmployeeID = employeeId,
                                    ProductionOrderID = reader.GetInt32(reader.GetOrdinal("ProductionOrderID")),
                                    OrderNumber = reader.GetInt32(reader.GetOrdinal("OrderNumber")),
                                    RawMaterialID = reader.GetInt32(reader.GetOrdinal("RawMaterialID")),
                                    MaterialName = reader.GetString(reader.GetOrdinal("MaterialName")),
                                    MaterialCategory = reader.IsDBNull(reader.GetOrdinal("MaterialCategory")) ? "" : reader.GetString(reader.GetOrdinal("MaterialCategory")),
                                    Unit = reader.IsDBNull(reader.GetOrdinal("Unit")) ? "" : reader.GetString(reader.GetOrdinal("Unit")),
                                    QuantityUsed = reader.GetDecimal(reader.GetOrdinal("QuantityUsed")),
                                    TotalCost = reader.GetDecimal(reader.GetOrdinal("TotalCost")),
                                    UsageDate = reader.GetDateTime(reader.GetOrdinal("UsageDate")),
                                    Notes = reader.IsDBNull(reader.GetOrdinal("Notes")) ? "" : reader.GetString(reader.GetOrdinal("Notes"))
                                });
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception($"Error getting stock usage by employee: {ex.Message}", ex);
            }

            return stockUsages;
        }

        // ================================================================================
        // 6. GET STOCK USAGE BY MATERIAL
        // ================================================================================
        public async Task<List<StockUsageInfo>> GetStockUsageByMaterialAsync(int rawMaterialId)
        {
            var stockUsages = new List<StockUsageInfo>();

            try
            {
                using (var connection = new SqlConnection(_connectionString))
                {
                    await connection.OpenAsync();
                    using (var command = new SqlCommand("sp_GetStockUsageByMaterial", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.AddWithValue("@RawMaterialID", rawMaterialId);

                        using (var reader = await command.ExecuteReaderAsync())
                        {
                            while (await reader.ReadAsync())
                            {
                                stockUsages.Add(new StockUsageInfo
                                {
                                    StockUsageID = reader.GetInt32(reader.GetOrdinal("StockUsageID")),
                                    EmployeeID = reader.GetInt32(reader.GetOrdinal("EmployeeID")),
                                    EmployeeName = reader.GetString(reader.GetOrdinal("EmployeeName")),
                                    ProductionOrderID = reader.GetInt32(reader.GetOrdinal("ProductionOrderID")),
                                    OrderNumber = reader.GetInt32(reader.GetOrdinal("OrderNumber")),
                                    RawMaterialID = rawMaterialId,
                                    QuantityUsed = reader.GetDecimal(reader.GetOrdinal("QuantityUsed")),
                                    TotalCost = reader.GetDecimal(reader.GetOrdinal("TotalCost")),
                                    UsageDate = reader.GetDateTime(reader.GetOrdinal("UsageDate")),
                                    Notes = reader.IsDBNull(reader.GetOrdinal("Notes")) ? "" : reader.GetString(reader.GetOrdinal("Notes"))
                                });
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception($"Error getting stock usage by material: {ex.Message}", ex);
            }

            return stockUsages;
        }

        // ================================================================================
        // 7. GET STOCK USAGE STATISTICS
        // ================================================================================
        public async Task<StockUsageStatistics> GetStockUsageStatisticsAsync()
        {
            try
            {
                using (var connection = new SqlConnection(_connectionString))
                {
                    await connection.OpenAsync();
                    using (var command = new SqlCommand("sp_GetStockUsageStatistics", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;

                        using (var reader = await command.ExecuteReaderAsync())
                        {
                            if (await reader.ReadAsync())
                            {
                                return new StockUsageStatistics
                                {
                                    TotalUsageRecords = reader.GetInt32(reader.GetOrdinal("TotalUsageRecords")),
                                    TotalTailorsUsed = reader.GetInt32(reader.GetOrdinal("TotalTailorsUsed")),
                                    TotalOrdersWithUsage = reader.GetInt32(reader.GetOrdinal("TotalOrdersWithUsage")),
                                    TotalMaterialsUsed = reader.GetInt32(reader.GetOrdinal("TotalMaterialsUsed")),
                                    TotalCostOfMaterialsUsed = reader.GetDecimal(reader.GetOrdinal("TotalCostOfMaterialsUsed")),
                                    AverageCostPerUsage = reader.GetDecimal(reader.GetOrdinal("AverageCostPerUsage"))
                                };
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception($"Error getting stock usage statistics: {ex.Message}", ex);
            }

            return new StockUsageStatistics();
        }

        // ================================================================================
        // 8. DELETE STOCK USAGE (With stock restoration)
        // ================================================================================
        public async Task<bool> DeleteStockUsageAsync(int stockUsageId)
        {
            try
            {
                using (var connection = new SqlConnection(_connectionString))
                {
                    await connection.OpenAsync();
                    using (var command = new SqlCommand("sp_DeleteStockUsage", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.AddWithValue("@StockUsageID", stockUsageId);

                        await command.ExecuteNonQueryAsync();
                        return true;
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception($"Error deleting stock usage: {ex.Message}", ex);
            }
        }

        // ================================================================================
        // 9. SEARCH STOCK USAGE
        // ================================================================================
        public async Task<List<StockUsageInfo>> SearchStockUsageAsync(string searchTerm = null, 
            int? employeeId = null, int? productionOrderId = null, int? rawMaterialId = null, 
            DateTime? startDate = null, DateTime? endDate = null)
        {
            var stockUsages = new List<StockUsageInfo>();

            try
            {
                using (var connection = new SqlConnection(_connectionString))
                {
                    await connection.OpenAsync();
                    using (var command = new SqlCommand("sp_SearchStockUsage", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.AddWithValue("@SearchTerm", (object)searchTerm ?? DBNull.Value);
                        command.Parameters.AddWithValue("@EmployeeID", (object)employeeId ?? DBNull.Value);
                        command.Parameters.AddWithValue("@ProductionOrderID", (object)productionOrderId ?? DBNull.Value);
                        command.Parameters.AddWithValue("@RawMaterialID", (object)rawMaterialId ?? DBNull.Value);
                        command.Parameters.AddWithValue("@StartDate", (object)startDate ?? DBNull.Value);
                        command.Parameters.AddWithValue("@EndDate", (object)endDate ?? DBNull.Value);

                        using (var reader = await command.ExecuteReaderAsync())
                        {
                            while (await reader.ReadAsync())
                            {
                                stockUsages.Add(new StockUsageInfo
                                {
                                    StockUsageID = reader.GetInt32(reader.GetOrdinal("StockUsageID")),
                                    EmployeeID = reader.GetInt32(reader.GetOrdinal("EmployeeID")),
                                    EmployeeName = reader.GetString(reader.GetOrdinal("EmployeeName")),
                                    ProductionOrderID = reader.GetInt32(reader.GetOrdinal("ProductionOrderID")),
                                    OrderNumber = reader.GetInt32(reader.GetOrdinal("OrderNumber")),
                                    RawMaterialID = reader.GetInt32(reader.GetOrdinal("RawMaterialID")),
                                    MaterialName = reader.GetString(reader.GetOrdinal("MaterialName")),
                                    MaterialCategory = reader.IsDBNull(reader.GetOrdinal("MaterialCategory")) ? "" : reader.GetString(reader.GetOrdinal("MaterialCategory")),
                                    Unit = reader.IsDBNull(reader.GetOrdinal("Unit")) ? "" : reader.GetString(reader.GetOrdinal("Unit")),
                                    QuantityUsed = reader.GetDecimal(reader.GetOrdinal("QuantityUsed")),
                                    TotalCost = reader.GetDecimal(reader.GetOrdinal("TotalCost")),
                                    UsageDate = reader.GetDateTime(reader.GetOrdinal("UsageDate")),
                                    Notes = reader.IsDBNull(reader.GetOrdinal("Notes")) ? "" : reader.GetString(reader.GetOrdinal("Notes"))
                                });
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception($"Error searching stock usage: {ex.Message}", ex);
            }

            return stockUsages;
        }

        // ================================================================================
        // 10. CHECK MATERIAL AVAILABILITY
        // ================================================================================
        public async Task<MaterialAvailability> CheckMaterialAvailabilityAsync(int rawMaterialId, decimal requiredQuantity)
        {
            try
            {
                using (var connection = new SqlConnection(_connectionString))
                {
                    await connection.OpenAsync();
                    using (var command = new SqlCommand("sp_CheckMaterialAvailability", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.AddWithValue("@RawMaterialID", rawMaterialId);
                        command.Parameters.AddWithValue("@RequiredQuantity", requiredQuantity);

                        using (var reader = await command.ExecuteReaderAsync())
                        {
                            if (await reader.ReadAsync())
                            {
                                return new MaterialAvailability
                                {
                                    RawMaterialID = reader.GetInt32(reader.GetOrdinal("RawMaterialID")),
                                    MaterialName = reader.GetString(reader.GetOrdinal("MaterialName")),
                                    Category = reader.IsDBNull(reader.GetOrdinal("Category")) ? "" : reader.GetString(reader.GetOrdinal("Category")),
                                    Unit = reader.IsDBNull(reader.GetOrdinal("Unit")) ? "" : reader.GetString(reader.GetOrdinal("Unit")),
                                    AvailableQuantity = reader.GetDecimal(reader.GetOrdinal("AvailableQuantity")),
                                    RequiredQuantity = reader.GetDecimal(reader.GetOrdinal("RequiredQuantity")),
                                    AvailabilityStatus = reader.GetString(reader.GetOrdinal("AvailabilityStatus")),
                                    QuantityDifference = reader.GetDecimal(reader.GetOrdinal("QuantityDifference")),
                                    Supplier = reader.IsDBNull(reader.GetOrdinal("Supplier")) ? "" : reader.GetString(reader.GetOrdinal("Supplier")),
                                    SupplierContact = reader.IsDBNull(reader.GetOrdinal("SupplierContact")) ? "" : reader.GetString(reader.GetOrdinal("SupplierContact"))
                                };
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception($"Error checking material availability: {ex.Message}", ex);
            }

            return null;
        }
    }
}
