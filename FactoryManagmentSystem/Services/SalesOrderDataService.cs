using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Text;
using System.Threading.Tasks;
using System.Xml;
using FactoryManagmentSystem.Models;

namespace FactoryManagmentSystem.Services
{
    public class SalesOrderDataService
    {
        private readonly string _connectionString = "Server=QASIM\\SQLEXPRESS;Database=GarmentsFactoryDB;Trusted_Connection=True;TrustServerCertificate=True;MultipleActiveResultSets=True;";

        // ================================================================================
        // 1. GET ALL SALES ORDERS
        // ================================================================================
        public async Task<List<SalesOrder>> GetAllSalesOrdersAsync()
        {
            var salesOrders = new List<SalesOrder>();

            using (SqlConnection conn = new SqlConnection(_connectionString))
            using (SqlCommand cmd = new SqlCommand("sp_GetAllSalesOrders", conn))
            {
                cmd.CommandType = System.Data.CommandType.StoredProcedure;
                await conn.OpenAsync();

                using (var reader = await cmd.ExecuteReaderAsync())
                {
                    while (await reader.ReadAsync())
                    {
                        salesOrders.Add(new SalesOrder
                        {
                            SalesOrderID = reader.GetInt32(reader.GetOrdinal("SalesOrderID")),
                            OrderDate = reader.GetDateTime(reader.GetOrdinal("OrderDate")),
                            Status = reader.IsDBNull(reader.GetOrdinal("Status")) ? null : reader.GetString(reader.GetOrdinal("Status")),
                            // RetailerID not returned by sp_GetAllSalesOrders
                            RetailerName = reader.IsDBNull(reader.GetOrdinal("RetailerName")) ? null : reader.GetString(reader.GetOrdinal("RetailerName")),
                            // ShippingAddress, DiscountPercentage, SubTotal, DiscountAmount not in sp_GetAllSalesOrders
                            TotalAmount = reader.GetDecimal(reader.GetOrdinal("TotalAmount")),
                            // SalesRepID not returned, SalesRepName is returned as SalesRep
                            SalesRepName = reader.IsDBNull(reader.GetOrdinal("SalesRep")) ? null : reader.GetString(reader.GetOrdinal("SalesRep")),
                            CreatedDate = reader.GetDateTime(reader.GetOrdinal("CreatedDate")),
                            UpdatedDate = reader.IsDBNull(reader.GetOrdinal("UpdatedDate")) ? null : (DateTime?)reader.GetDateTime(reader.GetOrdinal("UpdatedDate"))
                        });
                    }
                }
            }

            return salesOrders;
        }

        // ================================================================================
        // 2. GET SALES ORDER BY ID (WITH ITEMS)
        // ================================================================================
        public async Task<SalesOrder> GetSalesOrderByIdAsync(int salesOrderID)
        {
            SalesOrder salesOrder = null;

            using (SqlConnection conn = new SqlConnection(_connectionString))
            using (SqlCommand cmd = new SqlCommand("sp_GetSalesOrderById", conn))
            {
                cmd.CommandType = System.Data.CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@SalesOrderID", salesOrderID);
                await conn.OpenAsync();

                using (var reader = await cmd.ExecuteReaderAsync())
                {
                    // Read Sales Order Header
                    if (await reader.ReadAsync())
                    {
                        salesOrder = new SalesOrder
                        {
                            SalesOrderID = reader.GetInt32(reader.GetOrdinal("SalesOrderID")),
                            OrderDate = reader.GetDateTime(reader.GetOrdinal("OrderDate")),
                            Status = reader.IsDBNull(reader.GetOrdinal("Status")) ? null : reader.GetString(reader.GetOrdinal("Status")),
                            RetailerID = reader.GetInt32(reader.GetOrdinal("RetailerID")),
                            RetailerName = reader.IsDBNull(reader.GetOrdinal("RetailerName")) ? null : reader.GetString(reader.GetOrdinal("RetailerName")),
                            ShippingAddress = reader.IsDBNull(reader.GetOrdinal("ShippingAddress")) ? null : reader.GetString(reader.GetOrdinal("ShippingAddress")),
                            DiscountPercentage = reader.GetDecimal(reader.GetOrdinal("DiscountPercentage")),
                            SubTotal = reader.GetDecimal(reader.GetOrdinal("SubTotal")),
                            DiscountAmount = reader.GetDecimal(reader.GetOrdinal("DiscountAmount")),
                            TotalAmount = reader.GetDecimal(reader.GetOrdinal("TotalAmount")),
                            SalesRepID = reader.IsDBNull(reader.GetOrdinal("SalesRepID")) ? null : (int?)reader.GetInt32(reader.GetOrdinal("SalesRepID")),
                            SalesRepName = reader.IsDBNull(reader.GetOrdinal("SalesRepName")) ? null : reader.GetString(reader.GetOrdinal("SalesRepName")),
                            CreatedDate = reader.GetDateTime(reader.GetOrdinal("CreatedDate")),
                            UpdatedDate = reader.IsDBNull(reader.GetOrdinal("UpdatedDate")) ? null : (DateTime?)reader.GetDateTime(reader.GetOrdinal("UpdatedDate"))
                        };
                    }

                    // Read Sales Order Items
                    if (salesOrder != null && await reader.NextResultAsync())
                    {
                        while (await reader.ReadAsync())
                        {
                            salesOrder.Items.Add(new SalesOrderItem
                            {
                                SalesOrderItemID = reader.GetInt32(reader.GetOrdinal("SalesOrderItemID")),
                                SalesOrderID = reader.GetInt32(reader.GetOrdinal("SalesOrderID")),
                                ProductID = reader.GetInt32(reader.GetOrdinal("ProductID")),
                                ProductName = reader.IsDBNull(reader.GetOrdinal("ProductName")) ? null : reader.GetString(reader.GetOrdinal("ProductName")),
                                Category = reader.IsDBNull(reader.GetOrdinal("Category")) ? null : reader.GetString(reader.GetOrdinal("Category")),
                                Brand = reader.IsDBNull(reader.GetOrdinal("Brand")) ? null : reader.GetString(reader.GetOrdinal("Brand")),
                                Size = reader.IsDBNull(reader.GetOrdinal("Size")) ? null : reader.GetString(reader.GetOrdinal("Size")),
                                Color = reader.IsDBNull(reader.GetOrdinal("Color")) ? null : reader.GetString(reader.GetOrdinal("Color")),
                                Quantity = reader.GetInt32(reader.GetOrdinal("Quantity")),
                                UnitPrice = reader.GetDecimal(reader.GetOrdinal("UnitPrice")),
                                Discount = reader.GetDecimal(reader.GetOrdinal("Discount")),
                                TotalPrice = reader.GetDecimal(reader.GetOrdinal("TotalPrice"))
                            });
                        }
                    }
                }
            }

            return salesOrder;
        }

        // ================================================================================
        // 3. ADD SALES ORDER WITH ITEMS
        // ================================================================================
        public async Task<int> AddSalesOrderAsync(SalesOrder order)
        {
            using (SqlConnection conn = new SqlConnection(_connectionString))
            {
                await conn.OpenAsync();
                
                // Set QUOTED_IDENTIFIER ON for compatibility with indexes
                using (SqlCommand setCmd = new SqlCommand("SET QUOTED_IDENTIFIER ON", conn))
                {
                    await setCmd.ExecuteNonQueryAsync();
                }

                // Step 1: Create the sales order
                int newOrderId;
                using (SqlCommand cmd = new SqlCommand("sp_AddSalesOrder", conn))
                {
                    cmd.CommandType = System.Data.CommandType.StoredProcedure;

                    // Order Information
                    cmd.Parameters.AddWithValue("@OrderDate", order.OrderDate);
                    cmd.Parameters.AddWithValue("@Status", order.Status ?? "Pending");
                    cmd.Parameters.AddWithValue("@RetailerID", order.RetailerID);
                    cmd.Parameters.AddWithValue("@ShippingAddress", (object)order.ShippingAddress ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@DiscountPercentage", order.DiscountPercentage);
                    cmd.Parameters.AddWithValue("@SubTotal", order.SubTotal);
                    cmd.Parameters.AddWithValue("@DiscountAmount", order.DiscountAmount);
                    cmd.Parameters.AddWithValue("@TotalAmount", order.TotalAmount);
                    cmd.Parameters.AddWithValue("@SalesRepID", (object)order.SalesRepID ?? DBNull.Value);

                    // Output Parameter
                    SqlParameter outputParam = new SqlParameter("@NewSalesOrderID", System.Data.SqlDbType.Int)
                    {
                        Direction = System.Data.ParameterDirection.Output
                    };
                    cmd.Parameters.Add(outputParam);

                    await cmd.ExecuteNonQueryAsync();
                    newOrderId = (int)outputParam.Value;
                }

                // Step 2: Add order items if provided
                if (order.Items != null && order.Items.Count > 0)
                {
                    foreach (var item in order.Items)
                    {
                        using (SqlCommand itemCmd = new SqlCommand("sp_AddSalesOrderItem", conn))
                        {
                            itemCmd.CommandType = System.Data.CommandType.StoredProcedure;
                            itemCmd.Parameters.AddWithValue("@SalesOrderID", newOrderId);
                            itemCmd.Parameters.AddWithValue("@ProductID", item.ProductID);
                            itemCmd.Parameters.AddWithValue("@Quantity", item.Quantity);
                            itemCmd.Parameters.AddWithValue("@UnitPrice", item.UnitPrice);

                            SqlParameter itemIdParam = new SqlParameter("@SalesOrderItemID", System.Data.SqlDbType.Int)
                            {
                                Direction = System.Data.ParameterDirection.Output
                            };
                            itemCmd.Parameters.Add(itemIdParam);

                            await itemCmd.ExecuteNonQueryAsync();
                        }
                    }
                }

                return newOrderId;
            }
        }

        // ================================================================================
        // 4. UPDATE SALES ORDER WITH ITEMS
        // ================================================================================
        public async Task UpdateSalesOrderAsync(SalesOrder order)
        {
            using (SqlConnection conn = new SqlConnection(_connectionString))
            using (SqlCommand cmd = new SqlCommand("sp_UpdateSalesOrder", conn))
            {
                cmd.CommandType = System.Data.CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@SalesOrderID", order.SalesOrderID);
                cmd.Parameters.AddWithValue("@OrderDate", order.OrderDate);
                cmd.Parameters.AddWithValue("@Status", order.Status ?? "Pending");
                cmd.Parameters.AddWithValue("@RetailerID", order.RetailerID);
                cmd.Parameters.AddWithValue("@ShippingAddress", (object)order.ShippingAddress ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@DiscountPercentage", order.DiscountPercentage);
                cmd.Parameters.AddWithValue("@SubTotal", order.SubTotal);
                cmd.Parameters.AddWithValue("@DiscountAmount", order.DiscountAmount);
                cmd.Parameters.AddWithValue("@TotalAmount", order.TotalAmount);
                cmd.Parameters.AddWithValue("@SalesRepID", (object)order.SalesRepID ?? DBNull.Value);

                // Order Items XML
                if (order.Items != null && order.Items.Count > 0)
                {
                    string itemsXml = GenerateOrderItemsXml(order.Items);
                    cmd.Parameters.AddWithValue("@OrderItemsXML", itemsXml);
                }
                else
                {
                    cmd.Parameters.AddWithValue("@OrderItemsXML", DBNull.Value);
                }

                await conn.OpenAsync();
                await cmd.ExecuteNonQueryAsync();
            }
        }

        // ================================================================================
        // 5. DELETE SALES ORDER
        // ================================================================================
        public async Task DeleteSalesOrderAsync(int salesOrderID)
        {
            using (SqlConnection conn = new SqlConnection(_connectionString))
            {
                await conn.OpenAsync();
                
                // Set QUOTED_IDENTIFIER ON for compatibility with indexes
                using (SqlCommand setCmd = new SqlCommand("SET QUOTED_IDENTIFIER ON", conn))
                {
                    await setCmd.ExecuteNonQueryAsync();
                }

                using (SqlCommand cmd = new SqlCommand("sp_DeleteSalesOrder", conn))
                {
                    cmd.CommandType = System.Data.CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@SalesOrderID", salesOrderID);
                    await cmd.ExecuteNonQueryAsync();
                }
            }
        }

        // ================================================================================
        // 6. GET RETAILERS FOR ORDER
        // ================================================================================
        public async Task<List<RetailerForOrder>> GetRetailersForOrderAsync()
        {
            var retailers = new List<RetailerForOrder>();

            using (SqlConnection conn = new SqlConnection(_connectionString))
            using (SqlCommand cmd = new SqlCommand("sp_GetRetailersForOrder", conn))
            {
                cmd.CommandType = System.Data.CommandType.StoredProcedure;
                await conn.OpenAsync();

                using (var reader = await cmd.ExecuteReaderAsync())
                {
                    while (await reader.ReadAsync())
                    {
                        retailers.Add(new RetailerForOrder
                        {
                            RetailerID = reader.GetInt32(reader.GetOrdinal("RetailerID")),
                            CompanyName = reader.IsDBNull(reader.GetOrdinal("CompanyName")) ? null : reader.GetString(reader.GetOrdinal("CompanyName")),
                            ContactPerson = reader.IsDBNull(reader.GetOrdinal("ContactPerson")) ? null : reader.GetString(reader.GetOrdinal("ContactPerson")),
                            Phone = reader.IsDBNull(reader.GetOrdinal("Phone")) ? null : reader.GetString(reader.GetOrdinal("Phone")),
                            Email = reader.IsDBNull(reader.GetOrdinal("Email")) ? null : reader.GetString(reader.GetOrdinal("Email")),
                            City = reader.IsDBNull(reader.GetOrdinal("City")) ? null : reader.GetString(reader.GetOrdinal("City")),
                            Province = reader.IsDBNull(reader.GetOrdinal("Province")) ? null : reader.GetString(reader.GetOrdinal("Province")),
                            ShippingAddress = reader.IsDBNull(reader.GetOrdinal("ShippingAddress")) ? null : reader.GetString(reader.GetOrdinal("ShippingAddress")),
                            Status = reader.IsDBNull(reader.GetOrdinal("Status")) ? null : reader.GetString(reader.GetOrdinal("Status"))
                        });
                    }
                }
            }

            return retailers;
        }

        // ================================================================================
        // 7. GET SALESPERSONS FOR ORDER
        // ================================================================================
        public async Task<List<SalespersonForOrder>> GetSalespersonsForOrderAsync()
        {
            var salespersons = new List<SalespersonForOrder>();
            
            using (SqlConnection conn = new SqlConnection(_connectionString))
            using (SqlCommand cmd = new SqlCommand("sp_GetSalespersonsForOrder", conn))
            {
                cmd.CommandType = System.Data.CommandType.StoredProcedure;
                await conn.OpenAsync();

                using (var reader = await cmd.ExecuteReaderAsync())
                {
                    while (await reader.ReadAsync())
                    {
                        salespersons.Add(new SalespersonForOrder
                        {
                            EmployeeID = reader.GetInt32(reader.GetOrdinal("EmployeeID")),
                            FullName = reader.IsDBNull(reader.GetOrdinal("FullName")) ? null : reader.GetString(reader.GetOrdinal("FullName")),
                            Email = reader.IsDBNull(reader.GetOrdinal("Email")) ? null : reader.GetString(reader.GetOrdinal("Email")),
                            Phone = reader.IsDBNull(reader.GetOrdinal("Phone")) ? null : reader.GetString(reader.GetOrdinal("Phone")),
                            Department = reader.IsDBNull(reader.GetOrdinal("Department")) ? null : reader.GetString(reader.GetOrdinal("Department"))
                        });
                    }
                }
            }
            
            return salespersons;
        }

        // ================================================================================
        // 8. GET PRODUCTS FOR ORDER
        // ================================================================================
        public async Task<List<ProductForOrder>> GetProductsForOrderAsync()
        {
            var products = new List<ProductForOrder>();

            using (SqlConnection conn = new SqlConnection(_connectionString))
            using (SqlCommand cmd = new SqlCommand("sp_GetProductsForOrder", conn))
            {
                cmd.CommandType = System.Data.CommandType.StoredProcedure;
                await conn.OpenAsync();

                using (var reader = await cmd.ExecuteReaderAsync())
                {
                    while (await reader.ReadAsync())
                    {
                        products.Add(new ProductForOrder
                        {
                            ProductID = reader.GetInt32(reader.GetOrdinal("ProductID")),
                            ProductName = reader.IsDBNull(reader.GetOrdinal("ProductName")) ? null : reader.GetString(reader.GetOrdinal("ProductName")),
                            Category = reader.IsDBNull(reader.GetOrdinal("Category")) ? null : reader.GetString(reader.GetOrdinal("Category")),
                            Brand = reader.IsDBNull(reader.GetOrdinal("Brand")) ? null : reader.GetString(reader.GetOrdinal("Brand")),
                            SalePrice = reader.GetDecimal(reader.GetOrdinal("SalePrice")),
                            AvailableSizes = reader.IsDBNull(reader.GetOrdinal("AvailableSizes")) ? null : reader.GetString(reader.GetOrdinal("AvailableSizes")),
                            AvailableColors = reader.IsDBNull(reader.GetOrdinal("AvailableColors")) ? null : reader.GetString(reader.GetOrdinal("AvailableColors")),
                            ProductionStatus = reader.IsDBNull(reader.GetOrdinal("ProductionStatus")) ? null : reader.GetString(reader.GetOrdinal("ProductionStatus"))
                        });
                    }
                }
            }

            return products;
        }

        // ================================================================================
        // 8. SEARCH SALES ORDERS
        // ================================================================================
        public async Task<List<SalesOrder>> SearchSalesOrdersAsync(string searchTerm, string status, int? retailerID, DateTime? startDate, DateTime? endDate)
        {
            var salesOrders = new List<SalesOrder>();

            using (SqlConnection conn = new SqlConnection(_connectionString))
            using (SqlCommand cmd = new SqlCommand("sp_SearchSalesOrders", conn))
            {
                cmd.CommandType = System.Data.CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@SearchTerm", (object)searchTerm ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@Status", (object)status ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@RetailerID", (object)retailerID ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@StartDate", (object)startDate ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@EndDate", (object)endDate ?? DBNull.Value);

                await conn.OpenAsync();

                using (var reader = await cmd.ExecuteReaderAsync())
                {
                    while (await reader.ReadAsync())
                    {
                        salesOrders.Add(new SalesOrder
                        {
                            SalesOrderID = reader.GetInt32(reader.GetOrdinal("SalesOrderID")),
                            OrderDate = reader.GetDateTime(reader.GetOrdinal("OrderDate")),
                            Status = reader.IsDBNull(reader.GetOrdinal("Status")) ? null : reader.GetString(reader.GetOrdinal("Status")),
                            RetailerID = reader.GetInt32(reader.GetOrdinal("RetailerID")),
                            RetailerName = reader.IsDBNull(reader.GetOrdinal("RetailerName")) ? null : reader.GetString(reader.GetOrdinal("RetailerName")),
                            ShippingAddress = reader.IsDBNull(reader.GetOrdinal("ShippingAddress")) ? null : reader.GetString(reader.GetOrdinal("ShippingAddress")),
                            DiscountPercentage = reader.GetDecimal(reader.GetOrdinal("DiscountPercentage")),
                            SubTotal = reader.GetDecimal(reader.GetOrdinal("SubTotal")),
                            DiscountAmount = reader.GetDecimal(reader.GetOrdinal("DiscountAmount")),
                            TotalAmount = reader.GetDecimal(reader.GetOrdinal("TotalAmount")),
                            SalesRepID = reader.IsDBNull(reader.GetOrdinal("SalesRepID")) ? null : (int?)reader.GetInt32(reader.GetOrdinal("SalesRepID")),
                            SalesRepName = reader.IsDBNull(reader.GetOrdinal("SalesRepName")) ? null : reader.GetString(reader.GetOrdinal("SalesRepName")),
                            CreatedDate = reader.GetDateTime(reader.GetOrdinal("CreatedDate")),
                            UpdatedDate = reader.IsDBNull(reader.GetOrdinal("UpdatedDate")) ? null : (DateTime?)reader.GetDateTime(reader.GetOrdinal("UpdatedDate"))
                        });
                    }
                }
            }

            return salesOrders;
        }

        // ================================================================================
        // 9. GET SALES ORDER STATISTICS
        // ================================================================================
        public async Task<SalesOrderStatistics> GetSalesOrderStatisticsAsync()
        {
            SalesOrderStatistics stats = null;

            using (SqlConnection conn = new SqlConnection(_connectionString))
            using (SqlCommand cmd = new SqlCommand("sp_GetSalesOrderStatistics", conn))
            {
                cmd.CommandType = System.Data.CommandType.StoredProcedure;
                await conn.OpenAsync();

                using (var reader = await cmd.ExecuteReaderAsync())
                {
                    if (await reader.ReadAsync())
                    {
                        stats = new SalesOrderStatistics
                        {
                            TotalOrders = reader.GetInt32(reader.GetOrdinal("TotalOrders")),
                            PendingOrders = reader.GetInt32(reader.GetOrdinal("PendingOrders")),
                            ConfirmedOrders = reader.GetInt32(reader.GetOrdinal("ConfirmedOrders")),
                            InProductionOrders = reader.GetInt32(reader.GetOrdinal("InProductionOrders")),
                            ShippedOrders = reader.GetInt32(reader.GetOrdinal("ShippedOrders")),
                            DeliveredOrders = reader.GetInt32(reader.GetOrdinal("DeliveredOrders")),
                            RushOrders = reader.GetInt32(reader.GetOrdinal("RushOrders")),
                            PendingPayments = reader.GetInt32(reader.GetOrdinal("PendingPayments")),
                            PaidOrders = reader.GetInt32(reader.GetOrdinal("PaidOrders")),
                            TotalRevenue = reader.IsDBNull(reader.GetOrdinal("TotalRevenue")) ? 0 : reader.GetDecimal(reader.GetOrdinal("TotalRevenue")),
                            AverageOrderValue = reader.IsDBNull(reader.GetOrdinal("AverageOrderValue")) ? 0 : reader.GetDecimal(reader.GetOrdinal("AverageOrderValue")),
                            TodayOrders = reader.GetInt32(reader.GetOrdinal("TodayOrders")),
                            LastWeekOrders = reader.GetInt32(reader.GetOrdinal("LastWeekOrders")),
                            LastMonthOrders = reader.GetInt32(reader.GetOrdinal("LastMonthOrders"))
                        };
                    }
                }
            }

            return stats;
        }

        // ================================================================================
        // 10. UPDATE SALES ORDER STATUS
        // ================================================================================
        public async Task UpdateSalesOrderStatusAsync(int salesOrderID, string status)
        {
            using (SqlConnection conn = new SqlConnection(_connectionString))
            using (SqlCommand cmd = new SqlCommand("sp_UpdateSalesOrderStatus", conn))
            {
                cmd.CommandType = System.Data.CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@SalesOrderID", salesOrderID);
                cmd.Parameters.AddWithValue("@Status", status);

                await conn.OpenAsync();
                await cmd.ExecuteNonQueryAsync();
            }
        }

        // ================================================================================
        // 11. GET SALES ORDER ITEMS BY ORDER ID
        // ================================================================================
        public async Task<List<SalesOrderItem>> GetSalesOrderItemsAsync(int salesOrderID)
        {
            var items = new List<SalesOrderItem>();

            using (SqlConnection conn = new SqlConnection(_connectionString))
            using (SqlCommand cmd = new SqlCommand("SELECT * FROM SalesOrderItem WHERE SalesOrderID = @SalesOrderID", conn))
            {
                cmd.Parameters.AddWithValue("@SalesOrderID", salesOrderID);

                await conn.OpenAsync();
                using (var reader = await cmd.ExecuteReaderAsync())
                {
                    while (await reader.ReadAsync())
                    {
                        items.Add(new SalesOrderItem
                        {
                            SalesOrderItemID = reader.GetInt32(reader.GetOrdinal("SalesOrderItemID")),
                            SalesOrderID = reader.GetInt32(reader.GetOrdinal("SalesOrderID")),
                            ProductID = reader.GetInt32(reader.GetOrdinal("ProductID")),
                            Size = reader.IsDBNull(reader.GetOrdinal("Size")) ? null : reader.GetString(reader.GetOrdinal("Size")),
                            Color = reader.IsDBNull(reader.GetOrdinal("Color")) ? null : reader.GetString(reader.GetOrdinal("Color")),
                            Quantity = reader.GetInt32(reader.GetOrdinal("Quantity")),
                            UnitPrice = reader.GetDecimal(reader.GetOrdinal("UnitPrice")),
                            Discount = reader.GetDecimal(reader.GetOrdinal("Discount"))
                        });
                    }
                }
            }

            return items;
        }

        // ================================================================================
        // HELPER: GENERATE XML FOR ORDER ITEMS
        // ================================================================================
        private string GenerateOrderItemsXml(List<SalesOrderItem> items)
        {
            var sb = new StringBuilder();
            sb.Append("<Items>");

            foreach (var item in items)
            {
                sb.Append("<Item>");
                sb.AppendFormat("<ProductID>{0}</ProductID>", item.ProductID);
                sb.AppendFormat("<Size>{0}</Size>", System.Security.SecurityElement.Escape(item.Size ?? ""));
                sb.AppendFormat("<Color>{0}</Color>", System.Security.SecurityElement.Escape(item.Color ?? ""));
                sb.AppendFormat("<Quantity>{0}</Quantity>", item.Quantity);
                sb.AppendFormat("<UnitPrice>{0}</UnitPrice>", item.UnitPrice);
                sb.AppendFormat("<Discount>{0}</Discount>", item.Discount);
                sb.Append("</Item>");
            }

            sb.Append("</Items>");
            return sb.ToString();
        }
    }
}
