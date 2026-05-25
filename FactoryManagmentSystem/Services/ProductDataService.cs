using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Threading.Tasks;
using FactoryManagmentSystem.Models;

namespace FactoryManagmentSystem.Services
{
    public class ProductDataService
    {
        private readonly string _connectionString = "Server=QASIM\\SQLEXPRESS;Database=GarmentsFactoryDB;Integrated Security=True;";

        public async Task<List<Product>> GetAllProductsAsync()
        {
            var products = new List<Product>();

            using (SqlConnection connection = new SqlConnection(_connectionString))
            {
                await connection.OpenAsync();

                string query = @"
                    SELECT 
                        ProductID,
                        ProductName,
                        Description,
                        Category,
                        Brand,
                        SalePrice,
                        Material,
                        AvailableSizes,
                        AvailableColors,
                        ProductionStatus,
                        SKU,
                        IsActive,
                        CreatedDate,
                        UpdatedDate
                    FROM Product
                    WHERE IsActive = 1
                    ORDER BY ProductName";

                using (SqlCommand command = new SqlCommand(query, connection))
                using (SqlDataReader reader = await command.ExecuteReaderAsync())
                {
                    while (await reader.ReadAsync())
                    {
                        var product = new Product
                        {
                            ProductId = reader.GetInt32(reader.GetOrdinal("ProductID")),
                            Name = reader.GetString(reader.GetOrdinal("ProductName")),
                            Description = reader.IsDBNull(reader.GetOrdinal("Description")) ? string.Empty : reader.GetString(reader.GetOrdinal("Description")),
                            
                            // Map Category string to enum
                            Category = ParseProductCategory(reader.IsDBNull(reader.GetOrdinal("Category")) ? string.Empty : reader.GetString(reader.GetOrdinal("Category"))),
                            
                            Brand = reader.IsDBNull(reader.GetOrdinal("Brand")) ? string.Empty : reader.GetString(reader.GetOrdinal("Brand")),
                            Price = reader.GetDecimal(reader.GetOrdinal("SalePrice")),
                            Material = reader.IsDBNull(reader.GetOrdinal("Material")) ? string.Empty : reader.GetString(reader.GetOrdinal("Material")),
                            
                            // Map ProductionStatus string to enum
                            ProductionStatus = ParseProductionStatus(reader.IsDBNull(reader.GetOrdinal("ProductionStatus")) ? "Active" : reader.GetString(reader.GetOrdinal("ProductionStatus"))),
                            
                            SKU = reader.IsDBNull(reader.GetOrdinal("SKU")) ? null : reader.GetString(reader.GetOrdinal("SKU")),
                            IsActive = reader.IsDBNull(reader.GetOrdinal("IsActive")) ? true : reader.GetBoolean(reader.GetOrdinal("IsActive")),
                            CreatedDate = reader.GetDateTime(reader.GetOrdinal("CreatedDate")),
                            LastUpdated = reader.IsDBNull(reader.GetOrdinal("UpdatedDate")) ? reader.GetDateTime(reader.GetOrdinal("CreatedDate")) : reader.GetDateTime(reader.GetOrdinal("UpdatedDate"))
                        };

                        products.Add(product);
                    }
                }
            }

            return products;
        }

        private ProductCategory ParseProductCategory(string category)
        {
            if (string.IsNullOrEmpty(category))
                return ProductCategory.TShirts;

            // Try to parse the category string to enum
            if (Enum.TryParse<ProductCategory>(category.Replace(" ", "").Replace("-", ""), true, out ProductCategory result))
            {
                return result;
            }

            // Default fallback
            return ProductCategory.TShirts;
        }

        private ProductionStatus ParseProductionStatus(string status)
        {
            if (string.IsNullOrEmpty(status))
                return ProductionStatus.Ready;

            // Try to parse the status string to enum
            if (Enum.TryParse<ProductionStatus>(status.Replace(" ", ""), true, out ProductionStatus result))
            {
                return result;
            }

            // Map database values to enum values
            switch (status.ToLower())
            {
                case "active":
                    return ProductionStatus.Ready;
                case "indevelopment":
                    return ProductionStatus.Planning;
                case "discontinued":
                    return ProductionStatus.Discontinued;
                case "outofstock":
                    return ProductionStatus.OnHold;
                default:
                    return ProductionStatus.Ready;
            }
        }
    }
}
