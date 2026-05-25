using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Threading.Tasks;
using FactoryManagmentSystem.Models;

namespace FactoryManagmentSystem.Services
{
    public class ProductService
    {
        private readonly string _connectionString;

        public ProductService()
        {
            _connectionString = "Server=QASIM\\SQLEXPRESS;Database=GarmentsFactoryDB;Trusted_Connection=True;TrustServerCertificate=True;MultipleActiveResultSets=True;";
        }

        // Get all products
        public async Task<List<Product>> GetAllProductsAsync()
        {
            var products = new List<Product>();
            
            try
            {
                using (var connection = new SqlConnection(_connectionString))
                {
                    await connection.OpenAsync();
                    using (var command = new SqlCommand("sp_GetAllProducts", connection))
                    {
                        command.CommandType = System.Data.CommandType.StoredProcedure;
                        
                        using (var reader = await command.ExecuteReaderAsync())
                        {
                            while (await reader.ReadAsync())
                            {
                                var product = MapProduct(reader);
                                products.Add(product);
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception($"Error retrieving products: {ex.Message}");
            }
            
            return products;
        }

        // Get product by ID
        public async Task<Product?> GetProductByIdAsync(int productId)
        {
            Product? product = null;
            
            try
            {
                using (var connection = new SqlConnection(_connectionString))
                {
                    await connection.OpenAsync();
                    using (var command = new SqlCommand("sp_GetProductById", connection))
                    {
                        command.CommandType = System.Data.CommandType.StoredProcedure;
                        command.Parameters.AddWithValue("@ProductID", productId);
                        
                        using (var reader = await command.ExecuteReaderAsync())
                        {
                            if (await reader.ReadAsync())
                            {
                                product = MapProduct(reader);
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception($"Error retrieving product: {ex.Message}");
            }
            
            return product;
        }

        // Add new product
        public async Task<int> AddProductAsync(Product product)
        {
            int newProductId = 0;
            
            try
            {
                using (var connection = new SqlConnection(_connectionString))
                {
                    await connection.OpenAsync();
                    using (var command = new SqlCommand("sp_AddProduct", connection))
                    {
                        command.CommandType = System.Data.CommandType.StoredProcedure;
                        
                        command.Parameters.AddWithValue("@ProductName", product.Name);
                        command.Parameters.AddWithValue("@Description", (object)product.Description ?? DBNull.Value);
                        command.Parameters.AddWithValue("@Category", product.Category.ToString());
                        command.Parameters.AddWithValue("@Brand", (object)product.Brand ?? DBNull.Value);
                        command.Parameters.AddWithValue("@SalePrice", product.Price);
                        command.Parameters.AddWithValue("@Material", (object)product.Material ?? DBNull.Value);
                        command.Parameters.AddWithValue("@AvailableSizes", string.Join(",", product.AvailableSizes));
                        command.Parameters.AddWithValue("@AvailableColors", string.Join(",", product.AvailableColors));
                        command.Parameters.AddWithValue("@ProductionStatus", product.ProductionStatus.ToString());
                        command.Parameters.AddWithValue("@SKU", (object)product.SKU ?? DBNull.Value);
                        
                        // Add OUTPUT parameter
                        var outputParam = new SqlParameter("@NewProductID", SqlDbType.Int)
                        {
                            Direction = ParameterDirection.Output
                        };
                        command.Parameters.Add(outputParam);
                        
                        await command.ExecuteNonQueryAsync();
                        newProductId = (int)outputParam.Value;
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception($"Error adding product: {ex.Message}");
            }
            
            return newProductId;
        }

        // Update product
        public async Task<bool> UpdateProductAsync(Product product)
        {
            try
            {
                using (var connection = new SqlConnection(_connectionString))
                {
                    await connection.OpenAsync();
                    using (var command = new SqlCommand("sp_UpdateProduct", connection))
                    {
                        command.CommandType = System.Data.CommandType.StoredProcedure;
                        
                        command.Parameters.AddWithValue("@ProductID", product.ProductId);
                        command.Parameters.AddWithValue("@ProductName", product.Name);
                        command.Parameters.AddWithValue("@Description", (object)product.Description ?? DBNull.Value);
                        command.Parameters.AddWithValue("@Category", product.Category.ToString());
                        command.Parameters.AddWithValue("@Brand", (object)product.Brand ?? DBNull.Value);
                        command.Parameters.AddWithValue("@SalePrice", product.Price);
                        command.Parameters.AddWithValue("@Material", (object)product.Material ?? DBNull.Value);
                        command.Parameters.AddWithValue("@AvailableSizes", string.Join(",", product.AvailableSizes));
                        command.Parameters.AddWithValue("@AvailableColors", string.Join(",", product.AvailableColors));
                        command.Parameters.AddWithValue("@ProductionStatus", product.ProductionStatus.ToString());
                        command.Parameters.AddWithValue("@SKU", (object)product.SKU ?? DBNull.Value);
                        command.Parameters.AddWithValue("@IsActive", product.IsActive);
                        
                        await command.ExecuteNonQueryAsync();
                        return true;
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception($"Error updating product: {ex.Message}");
            }
        }

        // Delete product
        public async Task<bool> DeleteProductAsync(int productId)
        {
            try
            {
                using (var connection = new SqlConnection(_connectionString))
                {
                    await connection.OpenAsync();
                    using (var command = new SqlCommand("sp_DeleteProduct", connection))
                    {
                        command.CommandType = System.Data.CommandType.StoredProcedure;
                        command.Parameters.AddWithValue("@ProductID", productId);
                        
                        await command.ExecuteNonQueryAsync();
                        return true;
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception($"Error deleting product: {ex.Message}");
            }
        }

        // Search products
        public async Task<List<Product>> SearchProductsAsync(string searchTerm = null, string category = null, string status = null)
        {
            var products = new List<Product>();
            
            try
            {
                using (var connection = new SqlConnection(_connectionString))
                {
                    await connection.OpenAsync();
                    using (var command = new SqlCommand("sp_SearchProducts", connection))
                    {
                        command.CommandType = System.Data.CommandType.StoredProcedure;
                        
                        command.Parameters.AddWithValue("@SearchTerm", (object)searchTerm ?? DBNull.Value);
                        command.Parameters.AddWithValue("@Category", (object)category ?? DBNull.Value);
                        command.Parameters.AddWithValue("@Status", (object)status ?? DBNull.Value);
                        
                        using (var reader = await command.ExecuteReaderAsync())
                        {
                            while (await reader.ReadAsync())
                            {
                                var product = MapProduct(reader);
                                products.Add(product);
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception($"Error searching products: {ex.Message}");
            }
            
            return products;
        }

        // Helper method to map database reader to Product object
        private Product MapProduct(SqlDataReader reader)
        {
            // Parse category
            var categoryString = reader.IsDBNull(3) ? "TShirts" : reader.GetString(3);
            ProductCategory category;
            if (!Enum.TryParse(categoryString, out category))
            {
                category = ProductCategory.TShirts;
            }

            // Parse production status
            var statusString = reader.IsDBNull(9) ? "Active" : reader.GetString(9);
            ProductionStatus productionStatus;
            if (!Enum.TryParse(statusString, out productionStatus))
            {
                productionStatus = ProductionStatus.Ready;
            }

            // Parse sizes
            var sizesString = reader.IsDBNull(7) ? "" : reader.GetString(7);
            var sizes = new List<ProductSize>();
            if (!string.IsNullOrEmpty(sizesString))
            {
                foreach (var sizeStr in sizesString.Split(','))
                {
                    if (Enum.TryParse<ProductSize>(sizeStr.Trim(), out var size))
                    {
                        sizes.Add(size);
                    }
                }
            }

            // Parse colors
            var colorsString = reader.IsDBNull(8) ? "" : reader.GetString(8);
            var colors = string.IsNullOrEmpty(colorsString) 
                ? new List<string>() 
                : colorsString.Split(',').Select(c => c.Trim()).ToList();

            var product = new Product
            {
                ProductId = reader.GetInt32(0),
                Name = reader.GetString(1),
                Description = reader.IsDBNull(2) ? "" : reader.GetString(2),
                Category = category,
                Brand = reader.IsDBNull(4) ? "" : reader.GetString(4),
                Price = reader.GetDecimal(5),
                Material = reader.IsDBNull(6) ? "" : reader.GetString(6),
                AvailableSizes = sizes,
                AvailableColors = colors,
                ProductionStatus = productionStatus,
                SKU = reader.IsDBNull(10) ? null : reader.GetString(10),
                IsActive = reader.GetBoolean(11),
                CreatedDate = reader.GetDateTime(12),
                LastUpdated = reader.IsDBNull(13) ? reader.GetDateTime(12) : reader.GetDateTime(13)
            };

            return product;
        }

        // Check if SKU already exists in database
        public async Task<bool> CheckSKUExistsAsync(string sku, int? excludeProductId = null)
        {
            try
            {
                using (var connection = new SqlConnection(_connectionString))
                {
                    await connection.OpenAsync();
                    var query = excludeProductId.HasValue 
                        ? "SELECT COUNT(*) FROM Product WHERE SKU = @SKU AND ProductID != @ProductID"
                        : "SELECT COUNT(*) FROM Product WHERE SKU = @SKU";
                    
                    using (var command = new SqlCommand(query, connection))
                    {
                        command.Parameters.AddWithValue("@SKU", sku);
                        if (excludeProductId.HasValue)
                            command.Parameters.AddWithValue("@ProductID", excludeProductId.Value);
                        
                        var count = (int)await command.ExecuteScalarAsync();
                        return count > 0;
                    }
                }
            }
            catch
            {
                return false;
            }
        }

        // Get next available product code (PC001, PC002, etc.)
        public async Task<string> GetNextProductCodeAsync()
        {
            try
            {
                using (var connection = new SqlConnection(_connectionString))
                {
                    await connection.OpenAsync();
                    // Get the highest SKU that starts with 'PC' and extract the number
                    var query = @"
                        SELECT TOP 1 SKU 
                        FROM Product 
                        WHERE SKU LIKE 'PC%' 
                        AND LEN(SKU) = 5 
                        AND ISNUMERIC(SUBSTRING(SKU, 3, 3)) = 1
                        ORDER BY CAST(SUBSTRING(SKU, 3, 3) AS INT) DESC";
                    
                    using (var command = new SqlCommand(query, connection))
                    {
                        var result = await command.ExecuteScalarAsync();
                        
                        if (result != null && result != DBNull.Value)
                        {
                            string lastCode = result.ToString();
                            // Extract number part (e.g., "PC001" -> "001" -> 1)
                            if (lastCode.Length >= 5 && int.TryParse(lastCode.Substring(2), out int lastNumber))
                            {
                                int nextNumber = lastNumber + 1;
                                return $"PC{nextNumber:D3}"; // Format as PC001, PC002, etc.
                            }
                        }
                        
                        // If no existing codes found, start with PC001
                        return "PC001";
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception($"Error generating next product code: {ex.Message}");
            }
        }
    }
}
