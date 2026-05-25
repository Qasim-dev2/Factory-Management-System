using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Threading.Tasks;
using FactoryManagmentSystem.Models;

namespace FactoryManagmentSystem.Services
{
    public class DeliveryDataService
    {
        private readonly string _connectionString = "Server=QASIM\\SQLEXPRESS;Database=GarmentsFactoryDB;Trusted_Connection=True;TrustServerCertificate=True;MultipleActiveResultSets=True;";

        // ================================================================================
        // 1. GET ALL DELIVERIES
        // ================================================================================
        public async Task<List<DeliveryInfo>> GetAllDeliveriesAsync()
        {
            var deliveries = new List<DeliveryInfo>();

            using (SqlConnection conn = new SqlConnection(_connectionString))
            using (SqlCommand cmd = new SqlCommand("sp_GetAllDeliveries", conn))
            {
                cmd.CommandType = System.Data.CommandType.StoredProcedure;
                await conn.OpenAsync();

                using (var reader = await cmd.ExecuteReaderAsync())
                {
                    while (await reader.ReadAsync())
                    {
                        deliveries.Add(new DeliveryInfo
                        {
                            DeliveryID = reader.GetInt32(reader.GetOrdinal("DeliveryID")),
                            SalesOrderID = reader.IsDBNull(reader.GetOrdinal("SalesOrderID")) ? 0 : reader.GetInt32(reader.GetOrdinal("SalesOrderID")),
                            DeliveredBy = reader.IsDBNull(reader.GetOrdinal("DeliveredBy")) ? null : (int?)reader.GetInt32(reader.GetOrdinal("DeliveredBy")),
                            DeliveryDate = reader.IsDBNull(reader.GetOrdinal("DeliveryDate")) ? null : (DateTime?)reader.GetDateTime(reader.GetOrdinal("DeliveryDate")),
                            DeliveryAddress = reader.IsDBNull(reader.GetOrdinal("DeliveryAddress")) ? null : reader.GetString(reader.GetOrdinal("DeliveryAddress")),
                            City = reader.IsDBNull(reader.GetOrdinal("City")) ? null : reader.GetString(reader.GetOrdinal("City")),
                            Province = reader.IsDBNull(reader.GetOrdinal("Province")) ? null : reader.GetString(reader.GetOrdinal("Province")),
                            PostalCode = reader.IsDBNull(reader.GetOrdinal("PostalCode")) ? null : reader.GetString(reader.GetOrdinal("PostalCode")),
                            TrackingNumber = reader.IsDBNull(reader.GetOrdinal("TrackingNumber")) ? null : reader.GetString(reader.GetOrdinal("TrackingNumber")),
                            DeliveryMethod = reader.IsDBNull(reader.GetOrdinal("DeliveryMethod")) ? null : reader.GetString(reader.GetOrdinal("DeliveryMethod")),
                            DeliveryCost = reader.GetDecimal(reader.GetOrdinal("DeliveryCost")),
                            Status = reader.IsDBNull(reader.GetOrdinal("Status")) ? "Pending" : reader.GetString(reader.GetOrdinal("Status")),
                            ReceiverName = reader.IsDBNull(reader.GetOrdinal("ReceiverName")) ? null : reader.GetString(reader.GetOrdinal("ReceiverName")),
                            ReceiverPhone = reader.IsDBNull(reader.GetOrdinal("ReceiverPhone")) ? null : reader.GetString(reader.GetOrdinal("ReceiverPhone")),
                            Notes = reader.IsDBNull(reader.GetOrdinal("Notes")) ? null : reader.GetString(reader.GetOrdinal("Notes")),
                            CreatedDate = reader.GetDateTime(reader.GetOrdinal("CreatedDate")),
                            UpdatedDate = reader.IsDBNull(reader.GetOrdinal("UpdatedDate")) ? null : (DateTime?)reader.GetDateTime(reader.GetOrdinal("UpdatedDate")),
                            // Sales Order Information
                            OrderDate = reader.IsDBNull(reader.GetOrdinal("OrderDate")) ? DateTime.Now : reader.GetDateTime(reader.GetOrdinal("OrderDate")),
                            ExpectedDeliveryDate = reader.IsDBNull(reader.GetOrdinal("ExpectedDeliveryDate")) ? null : (DateTime?)reader.GetDateTime(reader.GetOrdinal("ExpectedDeliveryDate")),
                            OrderAmount = reader.GetDecimal(reader.GetOrdinal("OrderAmount")),
                            OrderStatus = reader.IsDBNull(reader.GetOrdinal("OrderStatus")) ? "" : reader.GetString(reader.GetOrdinal("OrderStatus")),
                            PriorityLevel = reader.IsDBNull(reader.GetOrdinal("PriorityLevel")) ? "" : reader.GetString(reader.GetOrdinal("PriorityLevel")),
                            // Retailer Information
                            RetailerName = reader.IsDBNull(reader.GetOrdinal("RetailerName")) ? "" : reader.GetString(reader.GetOrdinal("RetailerName")),
                            ContactPerson = reader.IsDBNull(reader.GetOrdinal("ContactPerson")) ? "" : reader.GetString(reader.GetOrdinal("ContactPerson")),
                            RetailerPhone = reader.IsDBNull(reader.GetOrdinal("RetailerPhone")) ? "" : reader.GetString(reader.GetOrdinal("RetailerPhone")),
                            RetailerCity = reader.IsDBNull(reader.GetOrdinal("RetailerCity")) ? "" : reader.GetString(reader.GetOrdinal("RetailerCity")),
                            // Sales Rep Information
                            SalesRepName = reader.IsDBNull(reader.GetOrdinal("SalesRepName")) ? "" : reader.GetString(reader.GetOrdinal("SalesRepName")),
                            // Delivered By Employee
                            DeliveredByName = reader.IsDBNull(reader.GetOrdinal("DeliveredByName")) ? "" : reader.GetString(reader.GetOrdinal("DeliveredByName"))
                        });
                    }
                }
            }

            return deliveries;
        }

        // ================================================================================
        // 2. GET DELIVERY BY ID
        // ================================================================================
        public async Task<DeliveryInfo> GetDeliveryByIdAsync(int deliveryID)
        {
            DeliveryInfo delivery = null;

            using (SqlConnection conn = new SqlConnection(_connectionString))
            using (SqlCommand cmd = new SqlCommand("sp_GetDeliveryById", conn))
            {
                cmd.CommandType = System.Data.CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@DeliveryID", deliveryID);
                await conn.OpenAsync();

                using (var reader = await cmd.ExecuteReaderAsync())
                {
                    if (await reader.ReadAsync())
                    {
                        delivery = new DeliveryInfo
                        {
                            DeliveryID = reader.GetInt32(reader.GetOrdinal("DeliveryID")),
                            SalesOrderID = reader.IsDBNull(reader.GetOrdinal("SalesOrderID")) ? 0 : reader.GetInt32(reader.GetOrdinal("SalesOrderID")),
                            DeliveredBy = reader.IsDBNull(reader.GetOrdinal("DeliveredBy")) ? null : (int?)reader.GetInt32(reader.GetOrdinal("DeliveredBy")),
                            DeliveryDate = reader.IsDBNull(reader.GetOrdinal("DeliveryDate")) ? null : (DateTime?)reader.GetDateTime(reader.GetOrdinal("DeliveryDate")),
                            DeliveryAddress = reader.IsDBNull(reader.GetOrdinal("DeliveryAddress")) ? null : reader.GetString(reader.GetOrdinal("DeliveryAddress")),
                            City = reader.IsDBNull(reader.GetOrdinal("City")) ? null : reader.GetString(reader.GetOrdinal("City")),
                            Province = reader.IsDBNull(reader.GetOrdinal("Province")) ? null : reader.GetString(reader.GetOrdinal("Province")),
                            PostalCode = reader.IsDBNull(reader.GetOrdinal("PostalCode")) ? null : reader.GetString(reader.GetOrdinal("PostalCode")),
                            // TrackingNumber, DeliveryMethod, DeliveryCost - columns don't exist in database
                            TrackingNumber = null,
                            DeliveryMethod = null,
                            DeliveryCost = 0,
                            Status = reader.IsDBNull(reader.GetOrdinal("Status")) ? "Pending" : reader.GetString(reader.GetOrdinal("Status")),
                            ReceiverName = reader.IsDBNull(reader.GetOrdinal("ReceiverName")) ? null : reader.GetString(reader.GetOrdinal("ReceiverName")),
                            ReceiverPhone = reader.IsDBNull(reader.GetOrdinal("ReceiverPhone")) ? null : reader.GetString(reader.GetOrdinal("ReceiverPhone")),
                            Notes = reader.IsDBNull(reader.GetOrdinal("Notes")) ? null : reader.GetString(reader.GetOrdinal("Notes")),
                            CreatedDate = reader.GetDateTime(reader.GetOrdinal("CreatedDate")),
                            UpdatedDate = reader.IsDBNull(reader.GetOrdinal("UpdatedDate")) ? null : (DateTime?)reader.GetDateTime(reader.GetOrdinal("UpdatedDate")),
                            // Sales Order Information
                            OrderDate = reader.IsDBNull(reader.GetOrdinal("OrderDate")) ? DateTime.Now : reader.GetDateTime(reader.GetOrdinal("OrderDate")),
                            // ExpectedDeliveryDate, PriorityLevel - columns don't exist in SalesOrder table
                            ExpectedDeliveryDate = null,
                            OrderAmount = reader.GetDecimal(reader.GetOrdinal("OrderAmount")),
                            OrderStatus = reader.IsDBNull(reader.GetOrdinal("OrderStatus")) ? "" : reader.GetString(reader.GetOrdinal("OrderStatus")),
                            PriorityLevel = null,
                            OrderShippingAddress = reader.IsDBNull(reader.GetOrdinal("OrderShippingAddress")) ? null : reader.GetString(reader.GetOrdinal("OrderShippingAddress")),
                            // Retailer Information
                            RetailerName = reader.IsDBNull(reader.GetOrdinal("RetailerName")) ? "" : reader.GetString(reader.GetOrdinal("RetailerName")),
                            ContactPerson = reader.IsDBNull(reader.GetOrdinal("ContactPerson")) ? "" : reader.GetString(reader.GetOrdinal("ContactPerson")),
                            RetailerPhone = reader.IsDBNull(reader.GetOrdinal("RetailerPhone")) ? "" : reader.GetString(reader.GetOrdinal("RetailerPhone")),
                            RetailerEmail = reader.IsDBNull(reader.GetOrdinal("RetailerEmail")) ? null : reader.GetString(reader.GetOrdinal("RetailerEmail")),
                            RetailerCity = reader.IsDBNull(reader.GetOrdinal("RetailerCity")) ? "" : reader.GetString(reader.GetOrdinal("RetailerCity")),
                            RetailerProvince = reader.IsDBNull(reader.GetOrdinal("RetailerProvince")) ? null : reader.GetString(reader.GetOrdinal("RetailerProvince")),
                            // Sales Rep Information
                            SalesRepName = reader.IsDBNull(reader.GetOrdinal("SalesRepName")) ? "" : reader.GetString(reader.GetOrdinal("SalesRepName")),
                            SalesRepPhone = reader.IsDBNull(reader.GetOrdinal("SalesRepPhone")) ? null : reader.GetString(reader.GetOrdinal("SalesRepPhone")),
                            // Delivered By Employee
                            DeliveredByName = reader.IsDBNull(reader.GetOrdinal("DeliveredByName")) ? "" : reader.GetString(reader.GetOrdinal("DeliveredByName")),
                            DeliveredByPhone = reader.IsDBNull(reader.GetOrdinal("DeliveredByPhone")) ? null : reader.GetString(reader.GetOrdinal("DeliveredByPhone"))
                        };
                    }
                }
            }

            return delivery;
        }

        // ================================================================================
        // 3. GET DELIVERY BY SALES ORDER ID
        // ================================================================================
        public async Task<DeliveryInfo> GetDeliveryBySalesOrderIdAsync(int salesOrderID)
        {
            DeliveryInfo delivery = null;

            using (SqlConnection conn = new SqlConnection(_connectionString))
            using (SqlCommand cmd = new SqlCommand("sp_GetDeliveryBySalesOrderId", conn))
            {
                cmd.CommandType = System.Data.CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@SalesOrderID", salesOrderID);
                await conn.OpenAsync();

                using (var reader = await cmd.ExecuteReaderAsync())
                {
                    if (await reader.ReadAsync())
                    {
                        delivery = new DeliveryInfo
                        {
                            DeliveryID = reader.GetInt32(reader.GetOrdinal("DeliveryID")),
                            SalesOrderID = reader.GetInt32(reader.GetOrdinal("SalesOrderID")),
                            DeliveredBy = reader.IsDBNull(reader.GetOrdinal("DeliveredBy")) ? null : (int?)reader.GetInt32(reader.GetOrdinal("DeliveredBy")),
                            DeliveryDate = reader.IsDBNull(reader.GetOrdinal("DeliveryDate")) ? null : (DateTime?)reader.GetDateTime(reader.GetOrdinal("DeliveryDate")),
                            DeliveryAddress = reader.IsDBNull(reader.GetOrdinal("DeliveryAddress")) ? null : reader.GetString(reader.GetOrdinal("DeliveryAddress")),
                            City = reader.IsDBNull(reader.GetOrdinal("City")) ? null : reader.GetString(reader.GetOrdinal("City")),
                            Province = reader.IsDBNull(reader.GetOrdinal("Province")) ? null : reader.GetString(reader.GetOrdinal("Province")),
                            PostalCode = reader.IsDBNull(reader.GetOrdinal("PostalCode")) ? null : reader.GetString(reader.GetOrdinal("PostalCode")),
                            Status = reader.IsDBNull(reader.GetOrdinal("Status")) ? null : reader.GetString(reader.GetOrdinal("Status")),
                            ReceiverName = reader.IsDBNull(reader.GetOrdinal("ReceiverName")) ? null : reader.GetString(reader.GetOrdinal("ReceiverName")),
                            ReceiverPhone = reader.IsDBNull(reader.GetOrdinal("ReceiverPhone")) ? null : reader.GetString(reader.GetOrdinal("ReceiverPhone")),
                            Notes = reader.IsDBNull(reader.GetOrdinal("Notes")) ? null : reader.GetString(reader.GetOrdinal("Notes")),
                            CreatedDate = reader.GetDateTime(reader.GetOrdinal("CreatedDate")),
                            UpdatedDate = reader.IsDBNull(reader.GetOrdinal("UpdatedDate")) ? null : (DateTime?)reader.GetDateTime(reader.GetOrdinal("UpdatedDate"))
                        };
                    }
                }
            }

            return delivery;
        }

        // ================================================================================
        // 4. UPDATE DELIVERY
        // ================================================================================
        public async Task<bool> UpdateDeliveryAsync(DeliveryInfo delivery)
        {
            using (SqlConnection conn = new SqlConnection(_connectionString))
            using (SqlCommand cmd = new SqlCommand("sp_UpdateDelivery", conn))
            {
                cmd.CommandType = System.Data.CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@DeliveryID", delivery.DeliveryID);
                cmd.Parameters.AddWithValue("@DeliveredBy", delivery.DeliveredBy.HasValue ? (object)delivery.DeliveredBy.Value : DBNull.Value);
                cmd.Parameters.AddWithValue("@DeliveryDate", delivery.DeliveryDate.HasValue ? (object)delivery.DeliveryDate.Value : DBNull.Value);
                cmd.Parameters.AddWithValue("@DeliveryAddress", !string.IsNullOrEmpty(delivery.DeliveryAddress) ? (object)delivery.DeliveryAddress : DBNull.Value);
                cmd.Parameters.AddWithValue("@City", !string.IsNullOrEmpty(delivery.City) ? (object)delivery.City : DBNull.Value);
                cmd.Parameters.AddWithValue("@Province", !string.IsNullOrEmpty(delivery.Province) ? (object)delivery.Province : DBNull.Value);
                cmd.Parameters.AddWithValue("@PostalCode", !string.IsNullOrEmpty(delivery.PostalCode) ? (object)delivery.PostalCode : DBNull.Value);
                cmd.Parameters.AddWithValue("@Status", delivery.Status);
                cmd.Parameters.AddWithValue("@ReceiverName", !string.IsNullOrEmpty(delivery.ReceiverName) ? (object)delivery.ReceiverName : DBNull.Value);
                cmd.Parameters.AddWithValue("@ReceiverPhone", !string.IsNullOrEmpty(delivery.ReceiverPhone) ? (object)delivery.ReceiverPhone : DBNull.Value);
                cmd.Parameters.AddWithValue("@Notes", !string.IsNullOrEmpty(delivery.Notes) ? (object)delivery.Notes : DBNull.Value);

                await conn.OpenAsync();
                await cmd.ExecuteNonQueryAsync();
                return true;
            }
        }

        // ================================================================================
        // 5. UPDATE DELIVERY STATUS (Quick Update)
        // ================================================================================
        public async Task<bool> UpdateDeliveryStatusAsync(int deliveryID, string status, string trackingNumber = null, string notes = null)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(_connectionString))
                using (SqlCommand cmd = new SqlCommand("sp_UpdateDeliveryStatus", conn))
                {
                    cmd.CommandType = System.Data.CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@DeliveryID", deliveryID);
                    cmd.Parameters.AddWithValue("@Status", status);
                    cmd.Parameters.AddWithValue("@TrackingNumber", !string.IsNullOrEmpty(trackingNumber) ? (object)trackingNumber : DBNull.Value);
                    cmd.Parameters.AddWithValue("@Notes", !string.IsNullOrEmpty(notes) ? (object)notes : DBNull.Value);

                    await conn.OpenAsync();
                    await cmd.ExecuteNonQueryAsync();
                    return true;
                }
            }
            catch (Exception ex)
            {
                // Detailed error with full exception details
                var errorDetails = $"SQL Error Details:\n" +
                                 $"Message: {ex.Message}\n" +
                                 $"Source: {ex.Source}\n" +
                                 $"StackTrace: {ex.StackTrace}\n" +
                                 $"DeliveryID: {deliveryID}\n" +
                                 $"Status: {status}";
                
                if (ex.InnerException != null)
                    errorDetails += $"\nInner: {ex.InnerException.Message}";
                
                throw new Exception(errorDetails, ex);
            }
        }

        // ================================================================================
        // 6. DELETE DELIVERY
        // ================================================================================
        public async Task<bool> DeleteDeliveryAsync(int deliveryID)
        {
            using (SqlConnection conn = new SqlConnection(_connectionString))
            using (SqlCommand cmd = new SqlCommand("sp_DeleteDelivery", conn))
            {
                cmd.CommandType = System.Data.CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@DeliveryID", deliveryID);

                await conn.OpenAsync();
                await cmd.ExecuteNonQueryAsync();
                return true;
            }
        }

        // ================================================================================
        // 7. SEARCH DELIVERIES
        // ================================================================================
        public async Task<List<DeliveryInfo>> SearchDeliveriesAsync(string searchTerm = null, string status = null, 
            string deliveryMethod = null, DateTime? startDate = null, DateTime? endDate = null)
        {
            var deliveries = new List<DeliveryInfo>();

            using (SqlConnection conn = new SqlConnection(_connectionString))
            using (SqlCommand cmd = new SqlCommand("sp_SearchDeliveries", conn))
            {
                cmd.CommandType = System.Data.CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@SearchTerm", !string.IsNullOrEmpty(searchTerm) ? (object)searchTerm : DBNull.Value);
                cmd.Parameters.AddWithValue("@Status", !string.IsNullOrEmpty(status) ? (object)status : DBNull.Value);
                cmd.Parameters.AddWithValue("@DeliveryMethod", !string.IsNullOrEmpty(deliveryMethod) ? (object)deliveryMethod : DBNull.Value);
                cmd.Parameters.AddWithValue("@StartDate", startDate.HasValue ? (object)startDate.Value : DBNull.Value);
                cmd.Parameters.AddWithValue("@EndDate", endDate.HasValue ? (object)endDate.Value : DBNull.Value);

                await conn.OpenAsync();

                using (var reader = await cmd.ExecuteReaderAsync())
                {
                    while (await reader.ReadAsync())
                    {
                        deliveries.Add(new DeliveryInfo
                        {
                            DeliveryID = reader.GetInt32(reader.GetOrdinal("DeliveryID")),
                            SalesOrderID = reader.GetInt32(reader.GetOrdinal("SalesOrderID")),
                            DeliveryDate = reader.IsDBNull(reader.GetOrdinal("DeliveryDate")) ? null : (DateTime?)reader.GetDateTime(reader.GetOrdinal("DeliveryDate")),
                            Status = reader.IsDBNull(reader.GetOrdinal("Status")) ? null : reader.GetString(reader.GetOrdinal("Status")),
                            DeliveryMethod = reader.IsDBNull(reader.GetOrdinal("DeliveryMethod")) ? null : reader.GetString(reader.GetOrdinal("DeliveryMethod")),
                            TrackingNumber = reader.IsDBNull(reader.GetOrdinal("TrackingNumber")) ? null : reader.GetString(reader.GetOrdinal("TrackingNumber")),
                            DeliveryCost = reader.GetDecimal(reader.GetOrdinal("DeliveryCost")),
                            RetailerName = reader.IsDBNull(reader.GetOrdinal("RetailerName")) ? null : reader.GetString(reader.GetOrdinal("RetailerName")),
                            ContactPerson = reader.IsDBNull(reader.GetOrdinal("ContactPerson")) ? null : reader.GetString(reader.GetOrdinal("ContactPerson")),
                            RetailerCity = reader.IsDBNull(reader.GetOrdinal("RetailerCity")) ? null : reader.GetString(reader.GetOrdinal("RetailerCity")),
                            OrderAmount = reader.GetDecimal(reader.GetOrdinal("OrderAmount")),
                            SalesRepName = reader.IsDBNull(reader.GetOrdinal("SalesRepName")) ? null : reader.GetString(reader.GetOrdinal("SalesRepName")),
                            DeliveredByName = reader.IsDBNull(reader.GetOrdinal("DeliveredByName")) ? null : reader.GetString(reader.GetOrdinal("DeliveredByName"))
                        });
                    }
                }
            }

            return deliveries;
        }

        // ================================================================================
        // 8. GET DELIVERY STATISTICS
        // ================================================================================
        public async Task<DeliveryStatistics> GetDeliveryStatisticsAsync()
        {
            DeliveryStatistics stats = new DeliveryStatistics();

            try
            {
                using (SqlConnection conn = new SqlConnection(_connectionString))
                using (SqlCommand cmd = new SqlCommand("sp_GetDeliveryStatistics", conn))
                {
                    cmd.CommandType = System.Data.CommandType.StoredProcedure;
                    await conn.OpenAsync();

                    using (var reader = await cmd.ExecuteReaderAsync())
                    {
                        if (await reader.ReadAsync())
                        {
                            // Safe column reading with default values
                            stats.TotalDeliveries = GetSafeInt32(reader, "TotalDeliveries");
                            stats.PendingDeliveries = GetSafeInt32(reader, "PendingDeliveries");
                            stats.InTransitDeliveries = GetSafeInt32(reader, "InTransitDeliveries");
                            stats.DeliveredCount = GetSafeInt32(reader, "DeliveredCount");
                            stats.FailedDeliveries = GetSafeInt32(reader, "FailedDeliveries");
                            stats.ReturnedDeliveries = GetSafeInt32(reader, "ReturnedDeliveries");
                            stats.TodayDeliveries = GetSafeInt32(reader, "TodayDeliveries");
                            stats.LastWeekDeliveries = GetSafeInt32(reader, "LastWeekDeliveries");
                            stats.LastMonthDeliveries = GetSafeInt32(reader, "LastMonthDeliveries");
                            stats.TotalDeliveryCost = GetSafeDecimal(reader, "TotalDeliveryCost");
                            stats.AverageDeliveryCost = GetSafeDecimal(reader, "AverageDeliveryCost");
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                // Log error and return default statistics
                System.Diagnostics.Debug.WriteLine($"Error getting delivery statistics: {ex.Message}");
            }

            return stats;
        }

        // Helper methods for safe data reading
        private int GetSafeInt32(SqlDataReader reader, string columnName)
        {
            try
            {
                int ordinal = reader.GetOrdinal(columnName);
                return reader.IsDBNull(ordinal) ? 0 : reader.GetInt32(ordinal);
            }
            catch
            {
                return 0;
            }
        }

        private decimal GetSafeDecimal(SqlDataReader reader, string columnName)
        {
            try
            {
                int ordinal = reader.GetOrdinal(columnName);
                return reader.IsDBNull(ordinal) ? 0 : reader.GetDecimal(ordinal);
            }
            catch
            {
                return 0;
            }
        }
    }

    // ================================================================================
    // DELIVERY MODELS
    // ================================================================================
    public class DeliveryInfo
    {
        // Delivery Fields
        public int DeliveryID { get; set; }
        public int? SalesOrderID { get; set; }
        public int? DealID { get; set; }
        public string OrderType { get; set; }
        public int? DeliveredBy { get; set; }
        public DateTime? DeliveryDate { get; set; }
        public string DeliveryAddress { get; set; }
        public string City { get; set; }
        public string Province { get; set; }
        public string PostalCode { get; set; }
        public string TrackingNumber { get; set; }
        public string DeliveryMethod { get; set; }
        public decimal DeliveryCost { get; set; }
        public string Status { get; set; }
        public string ReceiverName { get; set; }
        public string ReceiverPhone { get; set; }
        public string Notes { get; set; }
        public DateTime CreatedDate { get; set; }
        public DateTime? UpdatedDate { get; set; }

        // Sales Order Information
        public DateTime OrderDate { get; set; }
        public DateTime? ExpectedDeliveryDate { get; set; }
        public decimal OrderAmount { get; set; }
        public string OrderStatus { get; set; }
        public string PriorityLevel { get; set; }
        public string OrderShippingAddress { get; set; }

        // Retailer/Client Information
        public string CustomerName { get; set; }
        public string RetailerName { get; set; }
        public string ContactPerson { get; set; }
        public string RetailerPhone { get; set; }
        public string RetailerEmail { get; set; }
        public string RetailerCity { get; set; }
        public string RetailerProvince { get; set; }

        // Sales Rep Information
        public string SalesRepName { get; set; }
        public string SalesRepPhone { get; set; }

        // Delivered By Employee
        public string DeliveredByName { get; set; }
        public string DeliveredByPhone { get; set; }
    }

    public class DeliveryStatistics
    {
        public int TotalDeliveries { get; set; }
        public int PendingDeliveries { get; set; }
        public int InTransitDeliveries { get; set; }
        public int DeliveredCount { get; set; }
        public int FailedDeliveries { get; set; }
        public int ReturnedDeliveries { get; set; }
        public int TodayDeliveries { get; set; }
        public int LastWeekDeliveries { get; set; }
        public int LastMonthDeliveries { get; set; }
        public decimal TotalDeliveryCost { get; set; }
        public decimal AverageDeliveryCost { get; set; }
    }
}
