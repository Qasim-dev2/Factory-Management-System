using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Threading.Tasks;
using FactoryManagmentSystem.Models;

namespace FactoryManagmentSystem.Services
{
    public class RawMaterialDataService
    {
        private readonly string _connectionString = "Server=QASIM\\SQLEXPRESS;Database=GarmentsFactoryDB;Integrated Security=True;";

        // ================================================================================
        // 1. GET ALL RAW MATERIALS
        // ================================================================================
        public async Task<List<RawMaterialInfo>> GetAllRawMaterialsAsync()
        {
            var materials = new List<RawMaterialInfo>();

            try
            {
                using (var connection = new SqlConnection(_connectionString))
                {
                    await connection.OpenAsync();

                    using (var command = new SqlCommand("sp_GetAllRawMaterials", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;

                        using (var reader = await command.ExecuteReaderAsync())
                        {
                            while (await reader.ReadAsync())
                            {
                                materials.Add(new RawMaterialInfo
                                {
                                    RawMaterialID = reader.GetInt32(reader.GetOrdinal("RawMaterialID")),
                                    MaterialName = reader.GetString(reader.GetOrdinal("MaterialName")),
                                    Category = reader.IsDBNull(reader.GetOrdinal("Category")) ? string.Empty : reader.GetString(reader.GetOrdinal("Category")),
                                    Unit = reader.IsDBNull(reader.GetOrdinal("Unit")) ? string.Empty : reader.GetString(reader.GetOrdinal("Unit")),
                                    Quantity = reader.GetDecimal(reader.GetOrdinal("Quantity")),
                                    MinimumStock = reader.GetDecimal(reader.GetOrdinal("MinimumStock")),
                                    UnitPrice = reader.GetDecimal(reader.GetOrdinal("UnitPrice")),
                                    Supplier = reader.IsDBNull(reader.GetOrdinal("Supplier")) ? string.Empty : reader.GetString(reader.GetOrdinal("Supplier")),
                                    SupplierContact = reader.IsDBNull(reader.GetOrdinal("SupplierContact")) ? string.Empty : reader.GetString(reader.GetOrdinal("SupplierContact")),
                                    Description = reader.IsDBNull(reader.GetOrdinal("Description")) ? string.Empty : reader.GetString(reader.GetOrdinal("Description")),
                                    StockStatus = reader.GetString(reader.GetOrdinal("StockStatus")),
                                    TotalValue = reader.GetDecimal(reader.GetOrdinal("TotalValue")),
                                    LastRestockDate = reader.IsDBNull(reader.GetOrdinal("LastRestockDate")) ? (DateTime?)null : reader.GetDateTime(reader.GetOrdinal("LastRestockDate")),
                                    IsActive = reader.GetBoolean(reader.GetOrdinal("IsActive")),
                                    CreatedDate = reader.GetDateTime(reader.GetOrdinal("CreatedDate")),
                                    UpdatedDate = reader.IsDBNull(reader.GetOrdinal("UpdatedDate")) ? (DateTime?)null : reader.GetDateTime(reader.GetOrdinal("UpdatedDate"))
                                });
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception($"Error retrieving raw materials: {ex.Message}", ex);
            }

            return materials;
        }

        // ================================================================================
        // 2. GET RAW MATERIAL BY ID
        // ================================================================================
        public async Task<RawMaterialInfo> GetRawMaterialByIdAsync(int rawMaterialId)
        {
            RawMaterialInfo material = null;

            try
            {
                using (var connection = new SqlConnection(_connectionString))
                {
                    await connection.OpenAsync();

                    using (var command = new SqlCommand("sp_GetRawMaterialById", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.AddWithValue("@RawMaterialID", rawMaterialId);

                        using (var reader = await command.ExecuteReaderAsync())
                        {
                            if (await reader.ReadAsync())
                            {
                                material = new RawMaterialInfo
                                {
                                    RawMaterialID = reader.GetInt32(reader.GetOrdinal("RawMaterialID")),
                                    MaterialName = reader.GetString(reader.GetOrdinal("MaterialName")),
                                    Category = reader.IsDBNull(reader.GetOrdinal("Category")) ? string.Empty : reader.GetString(reader.GetOrdinal("Category")),
                                    Unit = reader.IsDBNull(reader.GetOrdinal("Unit")) ? string.Empty : reader.GetString(reader.GetOrdinal("Unit")),
                                    Quantity = reader.GetDecimal(reader.GetOrdinal("Quantity")),
                                    MinimumStock = reader.GetDecimal(reader.GetOrdinal("MinimumStock")),
                                    UnitPrice = reader.GetDecimal(reader.GetOrdinal("UnitPrice")),
                                    Supplier = reader.IsDBNull(reader.GetOrdinal("Supplier")) ? string.Empty : reader.GetString(reader.GetOrdinal("Supplier")),
                                    SupplierContact = reader.IsDBNull(reader.GetOrdinal("SupplierContact")) ? string.Empty : reader.GetString(reader.GetOrdinal("SupplierContact")),
                                    Description = reader.IsDBNull(reader.GetOrdinal("Description")) ? string.Empty : reader.GetString(reader.GetOrdinal("Description")),
                                    StockStatus = reader.GetString(reader.GetOrdinal("StockStatus")),
                                    TotalValue = reader.GetDecimal(reader.GetOrdinal("TotalValue")),
                                    LastRestockDate = reader.IsDBNull(reader.GetOrdinal("LastRestockDate")) ? (DateTime?)null : reader.GetDateTime(reader.GetOrdinal("LastRestockDate")),
                                    IsActive = reader.GetBoolean(reader.GetOrdinal("IsActive")),
                                    CreatedDate = reader.GetDateTime(reader.GetOrdinal("CreatedDate")),
                                    UpdatedDate = reader.IsDBNull(reader.GetOrdinal("UpdatedDate")) ? (DateTime?)null : reader.GetDateTime(reader.GetOrdinal("UpdatedDate"))
                                };
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception($"Error retrieving raw material: {ex.Message}", ex);
            }

            return material;
        }

        // ================================================================================
        // 3. CREATE RAW MATERIAL
        // ================================================================================
        public async Task<int> CreateRawMaterialAsync(RawMaterialInfo material)
        {
            int newMaterialId = 0;

            try
            {
                using (var connection = new SqlConnection(_connectionString))
                {
                    await connection.OpenAsync();

                    using (var command = new SqlCommand("sp_CreateRawMaterial", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;

                        command.Parameters.AddWithValue("@MaterialName", material.MaterialName);
                        command.Parameters.AddWithValue("@Category", string.IsNullOrEmpty(material.Category) ? (object)DBNull.Value : material.Category);
                        command.Parameters.AddWithValue("@Unit", string.IsNullOrEmpty(material.Unit) ? (object)DBNull.Value : material.Unit);
                        command.Parameters.AddWithValue("@Quantity", material.Quantity);
                        command.Parameters.AddWithValue("@MinimumStock", material.MinimumStock);
                        command.Parameters.AddWithValue("@UnitPrice", material.UnitPrice);
                        command.Parameters.AddWithValue("@Supplier", string.IsNullOrEmpty(material.Supplier) ? (object)DBNull.Value : material.Supplier);
                        command.Parameters.AddWithValue("@SupplierContact", string.IsNullOrEmpty(material.SupplierContact) ? (object)DBNull.Value : material.SupplierContact);
                        command.Parameters.AddWithValue("@Description", string.IsNullOrEmpty(material.Description) ? (object)DBNull.Value : material.Description);

                        var outputParam = new SqlParameter("@RawMaterialID", SqlDbType.Int)
                        {
                            Direction = ParameterDirection.Output
                        };
                        command.Parameters.Add(outputParam);

                        await command.ExecuteNonQueryAsync();

                        newMaterialId = (int)outputParam.Value;
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception($"Error creating raw material: {ex.Message}", ex);
            }

            return newMaterialId;
        }

        // ================================================================================
        // 4. UPDATE RAW MATERIAL
        // ================================================================================
        public async Task<bool> UpdateRawMaterialAsync(RawMaterialInfo material)
        {
            try
            {
                using (var connection = new SqlConnection(_connectionString))
                {
                    await connection.OpenAsync();

                    using (var command = new SqlCommand("sp_UpdateRawMaterial", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;

                        command.Parameters.AddWithValue("@RawMaterialID", material.RawMaterialID);
                        command.Parameters.AddWithValue("@MaterialName", material.MaterialName);
                        command.Parameters.AddWithValue("@Category", string.IsNullOrEmpty(material.Category) ? (object)DBNull.Value : material.Category);
                        command.Parameters.AddWithValue("@Unit", string.IsNullOrEmpty(material.Unit) ? (object)DBNull.Value : material.Unit);
                        command.Parameters.AddWithValue("@Quantity", material.Quantity);
                        command.Parameters.AddWithValue("@MinimumStock", material.MinimumStock);
                        command.Parameters.AddWithValue("@UnitPrice", material.UnitPrice);
                        command.Parameters.AddWithValue("@Supplier", string.IsNullOrEmpty(material.Supplier) ? (object)DBNull.Value : material.Supplier);
                        command.Parameters.AddWithValue("@SupplierContact", string.IsNullOrEmpty(material.SupplierContact) ? (object)DBNull.Value : material.SupplierContact);
                        command.Parameters.AddWithValue("@Description", string.IsNullOrEmpty(material.Description) ? (object)DBNull.Value : material.Description);

                        await command.ExecuteNonQueryAsync();
                    }
                }

                return true;
            }
            catch (Exception ex)
            {
                throw new Exception($"Error updating raw material: {ex.Message}", ex);
            }
        }

        // ================================================================================
        // 5. DELETE RAW MATERIAL
        // ================================================================================
        public async Task<bool> DeleteRawMaterialAsync(int rawMaterialId)
        {
            try
            {
                using (var connection = new SqlConnection(_connectionString))
                {
                    await connection.OpenAsync();

                    using (var command = new SqlCommand("sp_DeleteRawMaterial", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.AddWithValue("@RawMaterialID", rawMaterialId);

                        await command.ExecuteNonQueryAsync();
                    }
                }

                return true;
            }
            catch (Exception ex)
            {
                throw new Exception($"Error deleting raw material: {ex.Message}", ex);
            }
        }

        // ================================================================================
        // 6. SEARCH RAW MATERIALS
        // ================================================================================
        public async Task<List<RawMaterialInfo>> SearchRawMaterialsAsync(string searchTerm = null, string category = null, string stockStatus = null)
        {
            var materials = new List<RawMaterialInfo>();

            try
            {
                using (var connection = new SqlConnection(_connectionString))
                {
                    await connection.OpenAsync();

                    using (var command = new SqlCommand("sp_SearchRawMaterials", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;

                        command.Parameters.AddWithValue("@SearchTerm", string.IsNullOrEmpty(searchTerm) ? (object)DBNull.Value : searchTerm);
                        command.Parameters.AddWithValue("@Category", string.IsNullOrEmpty(category) ? (object)DBNull.Value : category);
                        command.Parameters.AddWithValue("@StockStatus", string.IsNullOrEmpty(stockStatus) ? (object)DBNull.Value : stockStatus);

                        using (var reader = await command.ExecuteReaderAsync())
                        {
                            while (await reader.ReadAsync())
                            {
                                materials.Add(new RawMaterialInfo
                                {
                                    RawMaterialID = reader.GetInt32(reader.GetOrdinal("RawMaterialID")),
                                    MaterialName = reader.GetString(reader.GetOrdinal("MaterialName")),
                                    Category = reader.IsDBNull(reader.GetOrdinal("Category")) ? string.Empty : reader.GetString(reader.GetOrdinal("Category")),
                                    Unit = reader.IsDBNull(reader.GetOrdinal("Unit")) ? string.Empty : reader.GetString(reader.GetOrdinal("Unit")),
                                    Quantity = reader.GetDecimal(reader.GetOrdinal("Quantity")),
                                    MinimumStock = reader.GetDecimal(reader.GetOrdinal("MinimumStock")),
                                    UnitPrice = reader.GetDecimal(reader.GetOrdinal("UnitPrice")),
                                    Supplier = reader.IsDBNull(reader.GetOrdinal("Supplier")) ? string.Empty : reader.GetString(reader.GetOrdinal("Supplier")),
                                    StockStatus = reader.GetString(reader.GetOrdinal("StockStatus")),
                                    TotalValue = reader.GetDecimal(reader.GetOrdinal("TotalValue"))
                                });
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception($"Error searching raw materials: {ex.Message}", ex);
            }

            return materials;
        }

        // ================================================================================
        // 7. GET RAW MATERIAL STATISTICS
        // ================================================================================
        public async Task<RawMaterialStatistics> GetRawMaterialStatisticsAsync()
        {
            var statistics = new RawMaterialStatistics();

            try
            {
                using (var connection = new SqlConnection(_connectionString))
                {
                    await connection.OpenAsync();

                    using (var command = new SqlCommand("sp_GetRawMaterialStatistics", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;

                        using (var reader = await command.ExecuteReaderAsync())
                        {
                            if (await reader.ReadAsync())
                            {
                                statistics.TotalMaterials = reader.GetInt32(reader.GetOrdinal("TotalMaterials"));
                                statistics.OutOfStockCount = reader.GetInt32(reader.GetOrdinal("OutOfStockCount"));
                                statistics.LowStockCount = reader.GetInt32(reader.GetOrdinal("LowStockCount"));
                                statistics.InStockCount = reader.GetInt32(reader.GetOrdinal("InStockCount"));
                                statistics.TotalStockValue = reader.GetDecimal(reader.GetOrdinal("TotalStockValue"));
                                statistics.AverageUnitPrice = reader.GetDecimal(reader.GetOrdinal("AverageUnitPrice"));
                                statistics.TotalCategories = reader.GetInt32(reader.GetOrdinal("TotalCategories"));
                                statistics.TotalSuppliers = reader.GetInt32(reader.GetOrdinal("TotalSuppliers"));
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception($"Error retrieving raw material statistics: {ex.Message}", ex);
            }

            return statistics;
        }

        // ================================================================================
        // 8. RESTOCK RAW MATERIAL
        // ================================================================================
        public async Task<bool> RestockRawMaterialAsync(int rawMaterialId, decimal quantityToAdd, decimal? newUnitPrice = null)
        {
            try
            {
                using (var connection = new SqlConnection(_connectionString))
                {
                    await connection.OpenAsync();

                    using (var command = new SqlCommand("sp_RestockRawMaterial", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;

                        command.Parameters.AddWithValue("@RawMaterialID", rawMaterialId);
                        command.Parameters.AddWithValue("@QuantityToAdd", quantityToAdd);
                        command.Parameters.AddWithValue("@NewUnitPrice", newUnitPrice.HasValue ? (object)newUnitPrice.Value : DBNull.Value);

                        await command.ExecuteNonQueryAsync();
                    }
                }

                return true;
            }
            catch (Exception ex)
            {
                throw new Exception($"Error restocking raw material: {ex.Message}", ex);
            }
        }

        // ================================================================================
        // 8b. UPDATE RAW MATERIAL STOCK (For Production Order Deduction)
        // ================================================================================
        public async Task<bool> UpdateRawMaterialStockAsync(int rawMaterialId, decimal quantityChange)
        {
            try
            {
                using (var connection = new SqlConnection(_connectionString))
                {
                    await connection.OpenAsync();

                    // Use the correct stored procedure for DEDUCTION
                    using (var command = new SqlCommand("sp_DeductRawMaterialStock", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;

                        command.Parameters.AddWithValue("@RawMaterialID", rawMaterialId);
                        command.Parameters.AddWithValue("@QuantityToDeduct", Math.Abs(quantityChange)); // Always positive for deduction

                        await command.ExecuteNonQueryAsync();
                    }
                }

                return true;
            }
            catch (Exception ex)
            {
                throw new Exception($"Error deducting raw material stock: {ex.Message}", ex);
            }
        }

        // ================================================================================
        // 9. GET DISTINCT CATEGORIES (For Filter Dropdown)
        // ================================================================================
        public async Task<List<string>> GetDistinctCategoriesAsync()
        {
            var categories = new List<string>();

            try
            {
                using (var connection = new SqlConnection(_connectionString))
                {
                    await connection.OpenAsync();

                    string query = "SELECT DISTINCT Category FROM RawMaterial WHERE IsActive = 1 AND Category IS NOT NULL ORDER BY Category";

                    using (var command = new SqlCommand(query, connection))
                    {
                        using (var reader = await command.ExecuteReaderAsync())
                        {
                            while (await reader.ReadAsync())
                            {
                                categories.Add(reader.GetString(0));
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception($"Error retrieving categories: {ex.Message}", ex);
            }

            return categories;
        }

        // ================================================================================
        // 10. GET DISTINCT SUPPLIERS (For Filter Dropdown)
        // ================================================================================
        public async Task<List<string>> GetDistinctSuppliersAsync()
        {
            var suppliers = new List<string>();

            try
            {
                using (var connection = new SqlConnection(_connectionString))
                {
                    await connection.OpenAsync();

                    string query = "SELECT DISTINCT Supplier FROM RawMaterial WHERE IsActive = 1 AND Supplier IS NOT NULL ORDER BY Supplier";

                    using (var command = new SqlCommand(query, connection))
                    {
                        using (var reader = await command.ExecuteReaderAsync())
                        {
                            while (await reader.ReadAsync())
                            {
                                suppliers.Add(reader.GetString(0));
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception($"Error retrieving suppliers: {ex.Message}", ex);
            }

            return suppliers;
        }
    }
}
