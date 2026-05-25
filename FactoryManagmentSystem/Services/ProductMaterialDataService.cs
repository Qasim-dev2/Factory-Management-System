using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Threading.Tasks;
using FactoryManagmentSystem.Models;

namespace FactoryManagmentSystem.Services
{
    /// <summary>
    /// Service for managing Product Material Requirements (Bill of Materials)
    /// Handles CRUD operations and material calculations for production orders
    /// </summary>
    public class ProductMaterialDataService
    {
        private readonly string _connectionString = "Server=QASIM\\SQLEXPRESS;Database=GarmentsFactoryDB;Integrated Security=True;";

        /// <summary>
        /// Add a material requirement to a product
        /// </summary>
        public async Task<int> AddProductMaterialRequirementAsync(
            int productId, 
            int rawMaterialId, 
            decimal quantityRequired, 
            string unit, 
            string notes = null)
        {
            using (var connection = new SqlConnection(_connectionString))
            {
                await connection.OpenAsync();
                using (var command = new SqlCommand("sp_AddProductMaterialRequirement", connection))
                {
                    command.CommandType = System.Data.CommandType.StoredProcedure;

                    command.Parameters.AddWithValue("@ProductID", productId);
                    command.Parameters.AddWithValue("@RawMaterialID", rawMaterialId);
                    command.Parameters.AddWithValue("@QuantityRequired", quantityRequired);
                    command.Parameters.AddWithValue("@Unit", unit);
                    command.Parameters.AddWithValue("@Notes", (object)notes ?? DBNull.Value);

                    var outputParam = new SqlParameter("@NewRequirementID", System.Data.SqlDbType.Int)
                    {
                        Direction = System.Data.ParameterDirection.Output
                    };
                    command.Parameters.Add(outputParam);

                    await command.ExecuteNonQueryAsync();
                    return (int)outputParam.Value;
                }
            }
        }

        /// <summary>
        /// Update material requirement quantities
        /// </summary>
        public async Task<bool> UpdateProductMaterialRequirementAsync(
            int requirementId,
            decimal quantityRequired,
            string unit,
            string notes = null)
        {
            try
            {
                using (var connection = new SqlConnection(_connectionString))
                {
                    await connection.OpenAsync();
                    using (var command = new SqlCommand("sp_UpdateProductMaterialRequirement", connection))
                    {
                        command.CommandType = System.Data.CommandType.StoredProcedure;

                        command.Parameters.AddWithValue("@RequirementID", requirementId);
                        command.Parameters.AddWithValue("@QuantityRequired", quantityRequired);
                        command.Parameters.AddWithValue("@Unit", unit);
                        command.Parameters.AddWithValue("@Notes", (object)notes ?? DBNull.Value);

                        await command.ExecuteNonQueryAsync();
                        return true;
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error updating material requirement: {ex.Message}");
                return false;
            }
        }

        /// <summary>
        /// Delete (soft delete) a material requirement
        /// </summary>
        public async Task<bool> DeleteProductMaterialRequirementAsync(int requirementId)
        {
            try
            {
                using (var connection = new SqlConnection(_connectionString))
                {
                    await connection.OpenAsync();
                    using (var command = new SqlCommand("sp_DeleteProductMaterialRequirement", connection))
                    {
                        command.CommandType = System.Data.CommandType.StoredProcedure;
                        command.Parameters.AddWithValue("@RequirementID", requirementId);

                        await command.ExecuteNonQueryAsync();
                        return true;
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error deleting material requirement: {ex.Message}");
                return false;
            }
        }

        /// <summary>
        /// Get Bill of Materials (BOM) for a specific product
        /// Shows all materials needed to make one unit of the product
        /// </summary>
        public async Task<List<ProductMaterialRequirement>> GetProductMaterialsAsync(int productId)
        {
            var materials = new List<ProductMaterialRequirement>();

            try
            {
                using (var connection = new SqlConnection(_connectionString))
                {
                    await connection.OpenAsync();
                    using (var command = new SqlCommand("sp_GetProductMaterials", connection))
                    {
                        command.CommandType = System.Data.CommandType.StoredProcedure;
                        command.Parameters.AddWithValue("@ProductID", productId);

                        using (var reader = await command.ExecuteReaderAsync())
                        {
                            while (await reader.ReadAsync())
                            {
                                materials.Add(new ProductMaterialRequirement
                                {
                                    RequirementID = reader.GetInt32(reader.GetOrdinal("RequirementID")),
                                    ProductID = reader.GetInt32(reader.GetOrdinal("ProductID")),
                                    ProductName = reader.GetString(reader.GetOrdinal("ProductName")),
                                    RawMaterialID = reader.GetInt32(reader.GetOrdinal("RawMaterialID")),
                                    MaterialName = reader.GetString(reader.GetOrdinal("MaterialName")),
                                    MaterialCategory = reader.IsDBNull(reader.GetOrdinal("MaterialCategory")) 
                                        ? "" : reader.GetString(reader.GetOrdinal("MaterialCategory")),
                                    QuantityRequired = reader.GetDecimal(reader.GetOrdinal("QuantityRequired")),
                                    Unit = reader.GetString(reader.GetOrdinal("Unit")),
                                    MaterialUnitPrice = reader.GetDecimal(reader.GetOrdinal("MaterialUnitPrice")),
                                    TotalMaterialCost = reader.GetDecimal(reader.GetOrdinal("TotalMaterialCost")),
                                    AvailableStock = reader.GetDecimal(reader.GetOrdinal("AvailableStock")),
                                    StockStatus = reader.GetString(reader.GetOrdinal("StockStatus")),
                                    Notes = reader.IsDBNull(reader.GetOrdinal("Notes")) 
                                        ? "" : reader.GetString(reader.GetOrdinal("Notes")),
                                    CreatedDate = reader.GetDateTime(reader.GetOrdinal("CreatedDate")),
                                    UpdatedDate = reader.GetDateTime(reader.GetOrdinal("UpdatedDate"))
                                });
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error getting product materials: {ex.Message}");
            }

            return materials;
        }

        /// <summary>
        /// Calculate total material requirements for a production order
        /// Multiplies BOM quantities by order quantity and checks availability
        /// </summary>
        public async Task<List<ProductionMaterialRequirement>> CalculateProductionOrderMaterialsAsync(
            int productId, 
            int orderQuantity)
        {
            var requirements = new List<ProductionMaterialRequirement>();

            try
            {
                using (var connection = new SqlConnection(_connectionString))
                {
                    await connection.OpenAsync();
                    using (var command = new SqlCommand("sp_CalculateProductionOrderMaterialRequirements", connection))
                    {
                        command.CommandType = System.Data.CommandType.StoredProcedure;
                        command.Parameters.AddWithValue("@ProductID", productId);
                        command.Parameters.AddWithValue("@Quantity", orderQuantity);

                        using (var reader = await command.ExecuteReaderAsync())
                        {
                            while (await reader.ReadAsync())
                            {
                                requirements.Add(new ProductionMaterialRequirement
                                {
                                    RawMaterialID = reader.GetInt32(reader.GetOrdinal("RawMaterialID")),
                                    MaterialName = reader.GetString(reader.GetOrdinal("MaterialName")),
                                    Category = reader.IsDBNull(reader.GetOrdinal("Category")) 
                                        ? "" : reader.GetString(reader.GetOrdinal("Category")),
                                    Unit = reader.GetString(reader.GetOrdinal("Unit")),
                                    QuantityPerUnit = reader.GetDecimal(reader.GetOrdinal("QuantityPerUnit")),
                                    TotalQuantityRequired = reader.GetDecimal(reader.GetOrdinal("TotalQuantityRequired")),
                                    AvailableStock = reader.GetDecimal(reader.GetOrdinal("AvailableStock")),
                                    StockStatus = reader.GetString(reader.GetOrdinal("StockStatus")),
                                    StockBalanceAfterProduction = reader.GetDecimal(reader.GetOrdinal("StockBalanceAfterProduction")),
                                    UnitPrice = reader.GetDecimal(reader.GetOrdinal("UnitPrice")),
                                    TotalMaterialCost = reader.GetDecimal(reader.GetOrdinal("TotalMaterialCost"))
                                });
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error calculating production order materials: {ex.Message}");
            }

            return requirements;
        }

        /// <summary>
        /// Check if all materials are available for a production order
        /// Returns availability status and list of missing materials
        /// </summary>
        public async Task<(bool AllAvailable, int MissingCount, List<MaterialAvailabilityInfo> Details)> 
            CheckMaterialsAvailabilityAsync(int productId, int orderQuantity)
        {
            bool allAvailable = false;
            int missingCount = 0;
            var details = new List<MaterialAvailabilityInfo>();

            try
            {
                using (var connection = new SqlConnection(_connectionString))
                {
                    await connection.OpenAsync();
                    using (var command = new SqlCommand("sp_CheckMaterialsAvailability", connection))
                    {
                        command.CommandType = System.Data.CommandType.StoredProcedure;
                        command.Parameters.AddWithValue("@ProductID", productId);
                        command.Parameters.AddWithValue("@Quantity", orderQuantity);

                        var allAvailableParam = new SqlParameter("@AllMaterialsAvailable", System.Data.SqlDbType.Bit)
                        {
                            Direction = System.Data.ParameterDirection.Output
                        };
                        var missingCountParam = new SqlParameter("@MissingMaterialsCount", System.Data.SqlDbType.Int)
                        {
                            Direction = System.Data.ParameterDirection.Output
                        };

                        command.Parameters.Add(allAvailableParam);
                        command.Parameters.Add(missingCountParam);

                        using (var reader = await command.ExecuteReaderAsync())
                        {
                            while (await reader.ReadAsync())
                            {
                                details.Add(new MaterialAvailabilityInfo
                                {
                                    RawMaterialID = reader.GetInt32(reader.GetOrdinal("RawMaterialID")),
                                    MaterialName = reader.GetString(reader.GetOrdinal("MaterialName")),
                                    RequiredQuantity = reader.GetDecimal(reader.GetOrdinal("RequiredQuantity")),
                                    AvailableStock = reader.GetDecimal(reader.GetOrdinal("AvailableStock")),
                                    IsAvailable = reader.GetInt32(reader.GetOrdinal("IsAvailable")) == 1
                                });
                            }
                        }

                        allAvailable = (bool)allAvailableParam.Value;
                        missingCount = (int)missingCountParam.Value;
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error checking materials availability: {ex.Message}");
            }

            return (allAvailable, missingCount, details);
        }

        /// <summary>
        /// Get all product-material requirements in the system
        /// Useful for admin/manager overview
        /// </summary>
        public async Task<List<ProductMaterialRequirement>> GetAllProductMaterialRequirementsAsync()
        {
            var requirements = new List<ProductMaterialRequirement>();

            try
            {
                using (var connection = new SqlConnection(_connectionString))
                {
                    await connection.OpenAsync();
                    using (var command = new SqlCommand("sp_GetAllProductMaterialRequirements", connection))
                    {
                        command.CommandType = System.Data.CommandType.StoredProcedure;

                        using (var reader = await command.ExecuteReaderAsync())
                        {
                            while (await reader.ReadAsync())
                            {
                                var requirement = new ProductMaterialRequirement
                                {
                                    RequirementID = reader.GetInt32(reader.GetOrdinal("RequirementID")),
                                    ProductID = reader.GetInt32(reader.GetOrdinal("ProductID")),
                                    ProductName = reader.GetString(reader.GetOrdinal("ProductName")),
                                    RawMaterialID = reader.GetInt32(reader.GetOrdinal("RawMaterialID")),
                                    MaterialName = reader.GetString(reader.GetOrdinal("MaterialName")),
                                    MaterialCategory = reader.IsDBNull(reader.GetOrdinal("MaterialCategory")) 
                                        ? "" : reader.GetString(reader.GetOrdinal("MaterialCategory")),
                                    QuantityRequired = reader.GetDecimal(reader.GetOrdinal("QuantityRequired")),
                                    Unit = reader.GetString(reader.GetOrdinal("Unit")),
                                    MaterialUnitPrice = reader.GetDecimal(reader.GetOrdinal("UnitPrice")),
                                    TotalMaterialCost = reader.GetDecimal(reader.GetOrdinal("CostPerUnit")),
                                    AvailableStock = reader.GetDecimal(reader.GetOrdinal("CurrentStock")),
                                    Notes = reader.IsDBNull(reader.GetOrdinal("Notes")) 
                                        ? "" : reader.GetString(reader.GetOrdinal("Notes")),
                                    CreatedDate = reader.GetDateTime(reader.GetOrdinal("CreatedDate"))
                                };

                                // Calculate stock status
                                if (requirement.AvailableStock >= requirement.QuantityRequired)
                                    requirement.StockStatus = "Available";
                                else if (requirement.AvailableStock > 0)
                                    requirement.StockStatus = "Insufficient";
                                else
                                    requirement.StockStatus = "Out of Stock";

                                requirements.Add(requirement);
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error getting all product material requirements: {ex.Message}");
            }

            return requirements;
        }
    }
}
