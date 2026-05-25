using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Threading.Tasks;
using FactoryManagmentSystem.Models;

namespace FactoryManagmentSystem.Services
{
    /// <summary>
    /// Data service for Order Approval operations
    /// Handles communication with database stored procedures
    /// </summary>
    public class OrderApprovalDataService
    {
        private readonly string connectionString = "Server=QASIM\\SQLEXPRESS;Database=GarmentsFactoryDB;Trusted_Connection=True;";

        // ================================================================================
        // APPROVAL METHODS (Owner Dashboard)
        // ================================================================================

        /// <summary>
        /// Get all pending approval requests
        /// </summary>
        public async Task<List<OrderApproval>> GetPendingApprovalsAsync()
        {
            var approvals = new List<OrderApproval>();

            using (var connection = new SqlConnection(connectionString))
            {
                await connection.OpenAsync();
                using (var command = new SqlCommand("sp_GetPendingApprovals", connection))
                {
                    command.CommandType = System.Data.CommandType.StoredProcedure;

                    using (var reader = await command.ExecuteReaderAsync())
                    {
                        while (await reader.ReadAsync())
                        {
                            approvals.Add(new OrderApproval
                            {
                                ApprovalID = reader.GetInt32(reader.GetOrdinal("ApprovalID")),
                                OrderType = reader.IsDBNull(reader.GetOrdinal("OrderType")) ? null : reader.GetString(reader.GetOrdinal("OrderType")),
                                OrderID = reader.GetInt32(reader.GetOrdinal("OrderID")),
                                Status = reader.IsDBNull(reader.GetOrdinal("Status")) ? null : reader.GetString(reader.GetOrdinal("Status")),
                                RequestDate = reader.GetDateTime(reader.GetOrdinal("RequestDate")),
                                // Map RequestedBy to SalespersonName for display
                                SalespersonName = reader.IsDBNull(reader.GetOrdinal("RequestedBy")) ? "Unknown" : reader.GetString(reader.GetOrdinal("RequestedBy")),
                                // Map CustomerName to both RetailerName and DealClientName
                                RetailerName = reader.IsDBNull(reader.GetOrdinal("CustomerName")) ? null : reader.GetString(reader.GetOrdinal("CustomerName")),
                                DealClientName = reader.IsDBNull(reader.GetOrdinal("CustomerName")) ? null : reader.GetString(reader.GetOrdinal("CustomerName")),
                                // Map TotalAmount to SalesOrderAmount
                                SalesOrderAmount = reader.IsDBNull(reader.GetOrdinal("TotalAmount")) ? (decimal?)null : reader.GetDecimal(reader.GetOrdinal("TotalAmount"))
                            });
                        }
                    }
                }
            }

            return approvals;
        }

        /// <summary>
        /// Check raw materials availability for an order
        /// </summary>
        public async Task<(List<MaterialCheckResult> Materials, string OverallStatus, string Message)> CheckMaterialsForOrderAsync(string orderType, int orderID)
        {
            var materials = new List<MaterialCheckResult>();
            string overallStatus = "";
            string message = "";

            using (var connection = new SqlConnection(connectionString))
            {
                await connection.OpenAsync();
                using (var command = new SqlCommand("sp_CheckMaterialsForOrder", connection))
                {
                    command.CommandType = System.Data.CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@OrderType", orderType);
                    command.Parameters.AddWithValue("@OrderID", orderID);

                    using (var reader = await command.ExecuteReaderAsync())
                    {
                        // First result set: Material details
                        while (await reader.ReadAsync())
                        {
                            materials.Add(new MaterialCheckResult
                            {
                                ProductID = reader.GetInt32(reader.GetOrdinal("ProductID")),
                                ProductName = reader.IsDBNull(reader.GetOrdinal("ProductName")) ? null : reader.GetString(reader.GetOrdinal("ProductName")),
                                QuantityOrdered = reader.GetInt32(reader.GetOrdinal("QuantityOrdered")),
                                RawMaterialID = reader.IsDBNull(reader.GetOrdinal("RawMaterialID")) ? 0 : reader.GetInt32(reader.GetOrdinal("RawMaterialID")),
                                MaterialName = reader.IsDBNull(reader.GetOrdinal("MaterialName")) ? null : reader.GetString(reader.GetOrdinal("MaterialName")),
                                RequiredQuantity = reader.IsDBNull(reader.GetOrdinal("RequiredQuantity")) ? 0 : reader.GetDecimal(reader.GetOrdinal("RequiredQuantity")),
                                AvailableQuantity = reader.IsDBNull(reader.GetOrdinal("AvailableQuantity")) ? 0 : reader.GetDecimal(reader.GetOrdinal("AvailableQuantity")),
                                Unit = reader.IsDBNull(reader.GetOrdinal("Unit")) ? null : reader.GetString(reader.GetOrdinal("Unit")),
                                Status = reader.IsDBNull(reader.GetOrdinal("Status")) ? null : reader.GetString(reader.GetOrdinal("Status"))
                            });
                        }

                        // Second result set: Overall status
                        if (await reader.NextResultAsync())
                        {
                            if (await reader.ReadAsync())
                            {
                                overallStatus = reader.GetString(reader.GetOrdinal("OverallStatus"));
                                message = reader.GetString(reader.GetOrdinal("Message"));
                            }
                        }
                    }
                }
            }

            return (materials, overallStatus, message);
        }

        /// <summary>
        /// Approve order and create production (with tailor assignment)
        /// </summary>
        public async Task<(bool Success, string Message, int? ProductionOrderID)> ApproveOrderAsync(int approvalID, int ownerID, string tailorIDs)
        {
            using (var connection = new SqlConnection(connectionString))
            {
                await connection.OpenAsync();
                using (var command = new SqlCommand("sp_ApproveOrderAndCreateProduction", connection))
                {
                    command.CommandType = System.Data.CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@ApprovalID", approvalID);
                    command.Parameters.AddWithValue("@OwnerID", ownerID);
                    command.Parameters.AddWithValue("@TailorIDs", (object)tailorIDs ?? DBNull.Value);

                    try
                    {
                        using (var reader = await command.ExecuteReaderAsync())
                        {
                            if (await reader.ReadAsync())
                            {
                                string result = reader.GetString(reader.GetOrdinal("Result"));
                                string message = reader.GetString(reader.GetOrdinal("Message"));
                                int? productionOrderID = reader.IsDBNull(reader.GetOrdinal("ProductionOrderID")) 
                                    ? (int?)null 
                                    : reader.GetInt32(reader.GetOrdinal("ProductionOrderID"));

                                return (result == "Success", message, productionOrderID);
                            }
                        }
                    }
                    catch (SqlException ex)
                    {
                        return (false, ex.Message, null);
                    }
                }
            }

            return (false, "Unknown error occurred", null);
        }

        /// <summary>
        /// Reject order with reason
        /// </summary>
        public async Task<(bool Success, string Message)> RejectOrderAsync(int approvalID, int ownerID, string rejectionReason)
        {
            using (var connection = new SqlConnection(connectionString))
            {
                await connection.OpenAsync();
                using (var command = new SqlCommand("sp_RejectOrder", connection))
                {
                    command.CommandType = System.Data.CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@ApprovalID", approvalID);
                    command.Parameters.AddWithValue("@OwnerID", ownerID);
                    command.Parameters.AddWithValue("@RejectionReason", rejectionReason);

                    try
                    {
                        using (var reader = await command.ExecuteReaderAsync())
                        {
                            if (await reader.ReadAsync())
                            {
                                string result = reader.GetString(reader.GetOrdinal("Result"));
                                string message = reader.GetString(reader.GetOrdinal("Message"));
                                return (result == "Success", message);
                            }
                        }
                    }
                    catch (SqlException ex)
                    {
                        return (false, ex.Message);
                    }
                }
            }

            return (false, "Unknown error occurred");
        }

        /// <summary>
        /// Get available tailors for assignment
        /// </summary>
        public async Task<List<AvailableTailor>> GetAvailableTailorsAsync()
        {
            var tailors = new List<AvailableTailor>();

            using (var connection = new SqlConnection(connectionString))
            {
                await connection.OpenAsync();
                using (var command = new SqlCommand("sp_GetAvailableTailors", connection))
                {
                    command.CommandType = System.Data.CommandType.StoredProcedure;

                    using (var reader = await command.ExecuteReaderAsync())
                    {
                        while (await reader.ReadAsync())
                        {
                            tailors.Add(new AvailableTailor
                            {
                                EmployeeID = reader.GetInt32(reader.GetOrdinal("EmployeeID")),
                                TailorName = reader.GetString(reader.GetOrdinal("TailorName")),
                                Phone = reader.IsDBNull(reader.GetOrdinal("Phone")) ? null : reader.GetString(reader.GetOrdinal("Phone")),
                                Email = reader.IsDBNull(reader.GetOrdinal("Email")) ? null : reader.GetString(reader.GetOrdinal("Email")),
                                DepartmentName = reader.IsDBNull(reader.GetOrdinal("DepartmentName")) ? null : reader.GetString(reader.GetOrdinal("DepartmentName")),
                                RoleName = reader.IsDBNull(reader.GetOrdinal("RoleName")) ? null : reader.GetString(reader.GetOrdinal("RoleName")),
                                ActiveAssignments = reader.GetInt32(reader.GetOrdinal("ActiveAssignments"))
                            });
                        }
                    }
                }
            }

            return tailors;
        }

        /// <summary>
        /// Get approval history (all, approved, rejected, or pending)
        /// </summary>
        public async Task<List<OrderApproval>> GetApprovalHistoryAsync(string status = null)
        {
            var approvals = new List<OrderApproval>();

            using (var connection = new SqlConnection(connectionString))
            {
                await connection.OpenAsync();
                using (var command = new SqlCommand("sp_GetApprovalHistory", connection))
                {
                    command.CommandType = System.Data.CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@Status", (object)status ?? DBNull.Value);

                    using (var reader = await command.ExecuteReaderAsync())
                    {
                        while (await reader.ReadAsync())
                        {
                            approvals.Add(new OrderApproval
                            {
                                ApprovalID = reader.GetInt32(reader.GetOrdinal("ApprovalID")),
                                OrderType = reader.GetString(reader.GetOrdinal("OrderType")),
                                OrderID = reader.GetInt32(reader.GetOrdinal("OrderID")),
                                Status = reader.GetString(reader.GetOrdinal("Status")),
                                RequestDate = reader.GetDateTime(reader.GetOrdinal("RequestDate")),
                                ApprovalDate = reader.IsDBNull(reader.GetOrdinal("ApprovalDate")) ? (DateTime?)null : reader.GetDateTime(reader.GetOrdinal("ApprovalDate")),
                                RejectionReason = reader.IsDBNull(reader.GetOrdinal("RejectionReason")) ? null : reader.GetString(reader.GetOrdinal("RejectionReason")),
                                SalespersonName = reader.IsDBNull(reader.GetOrdinal("RequestedBy")) ? null : reader.GetString(reader.GetOrdinal("RequestedBy"))
                            });
                        }
                    }
                }
            }

            return approvals;
        }

        // ================================================================================
        // TAILOR METHODS (Tailor Dashboard)
        // ================================================================================

        /// <summary>
        /// Get tailor's assignments
        /// </summary>
        public async Task<List<TailorAssignment>> GetTailorAssignmentsAsync(int tailorID, string status = null)
        {
            var assignments = new List<TailorAssignment>();

            using (var connection = new SqlConnection(connectionString))
            {
                await connection.OpenAsync();
                using (var command = new SqlCommand("sp_GetTailorAssignments", connection))
                {
                    command.CommandType = System.Data.CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@TailorID", tailorID);
                    command.Parameters.AddWithValue("@Status", (object)status ?? DBNull.Value);

                    using (var reader = await command.ExecuteReaderAsync())
                    {
                        while (await reader.ReadAsync())
                        {
                            assignments.Add(new TailorAssignment
                            {
                                TailorAssignmentID = reader.GetInt32(reader.GetOrdinal("TailorAssignmentID")),
                                ProductionOrderID = reader.IsDBNull(reader.GetOrdinal("ProductionOrderID")) ? 0 : reader.GetInt32(reader.GetOrdinal("ProductionOrderID")),
                                CompletionStatus = reader.IsDBNull(reader.GetOrdinal("CompletionStatus")) ? "Incomplete" : reader.GetString(reader.GetOrdinal("CompletionStatus")),
                                AssignedDate = reader.GetDateTime(reader.GetOrdinal("AssignedDate")),
                                CompletedDate = reader.IsDBNull(reader.GetOrdinal("CompletedDate")) ? (DateTime?)null : reader.GetDateTime(reader.GetOrdinal("CompletedDate")),
                                QuantityOrdered = reader.GetInt32(reader.GetOrdinal("QuantityOrdered")),
                                ProductionStatus = reader.IsDBNull(reader.GetOrdinal("ProductionStatus")) ? "Pending" : reader.GetString(reader.GetOrdinal("ProductionStatus")),
                                Priority = reader.IsDBNull(reader.GetOrdinal("Priority")) ? "Normal" : reader.GetString(reader.GetOrdinal("Priority")),
                                ExpectedEndDate = reader.IsDBNull(reader.GetOrdinal("ExpectedEndDate")) ? (DateTime?)null : reader.GetDateTime(reader.GetOrdinal("ExpectedEndDate")),
                                ProductID = reader.IsDBNull(reader.GetOrdinal("ProductID")) ? 0 : reader.GetInt32(reader.GetOrdinal("ProductID")),
                                ProductName = reader.IsDBNull(reader.GetOrdinal("ProductName")) ? "" : reader.GetString(reader.GetOrdinal("ProductName")),
                                Category = reader.IsDBNull(reader.GetOrdinal("Category")) ? "" : reader.GetString(reader.GetOrdinal("Category")),
                                Material = reader.IsDBNull(reader.GetOrdinal("Material")) ? "" : reader.GetString(reader.GetOrdinal("Material")),
                                TotalTailors = reader.GetInt32(reader.GetOrdinal("TotalTailors")),
                                CompletedTailors = reader.GetInt32(reader.GetOrdinal("CompletedTailors"))
                            });
                        }
                    }
                }
            }

            return assignments;
        }

        /// <summary>
        /// Update tailor completion status
        /// </summary>
        public async Task<(bool Success, string Message, bool AllTailorsCompleted)> UpdateTailorStatusAsync(
            int tailorAssignmentID, int tailorID, string newStatus, string completionNotes = null)
        {
            using (var connection = new SqlConnection(connectionString))
            {
                await connection.OpenAsync();
                using (var command = new SqlCommand("sp_UpdateTailorCompletionStatus", connection))
                {
                    command.CommandType = System.Data.CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@TailorAssignmentID", tailorAssignmentID);
                    command.Parameters.AddWithValue("@TailorID", tailorID);
                    command.Parameters.AddWithValue("@NewStatus", newStatus);
                    command.Parameters.AddWithValue("@CompletionNotes", (object)completionNotes ?? DBNull.Value);

                    try
                    {
                        using (var reader = await command.ExecuteReaderAsync())
                        {
                            if (await reader.ReadAsync())
                            {
                                string result = reader.GetString(reader.GetOrdinal("Result"));
                                string message = reader.GetString(reader.GetOrdinal("Message"));
                                // AllTailorsCompleted can be BIT (boolean) or INT, handle both
                                int allCompletedInt = Convert.ToInt32(reader["AllTailorsCompleted"]);
                                bool allCompleted = allCompletedInt == 1;
                                return (result == "Success", message, allCompleted);
                            }
                        }
                    }
                    catch (SqlException ex)
                    {
                        return (false, ex.Message, false);
                    }
                }
            }

            return (false, "Unknown error occurred", false);
        }

        // ================================================================================
        // DELIVERY METHODS (Delivery Management)
        // ================================================================================

        /// <summary>
        /// Get all delivery assignments
        /// </summary>
        public async Task<List<DeliveryInfo>> GetDeliveryAssignmentsAsync(int? deliveryPersonID = null, string status = null)
        {
            var deliveries = new List<DeliveryInfo>();

            using (var connection = new SqlConnection(connectionString))
            {
                await connection.OpenAsync();
                using (var command = new SqlCommand("sp_GetDeliveryAssignments", connection))
                {
                    command.CommandType = System.Data.CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@DeliveryPersonID", (object)deliveryPersonID ?? DBNull.Value);
                    command.Parameters.AddWithValue("@Status", (object)status ?? DBNull.Value);

                    using (var reader = await command.ExecuteReaderAsync())
                    {
                        while (await reader.ReadAsync())
                        {
                            deliveries.Add(new DeliveryInfo
                            {
                                DeliveryID = reader.GetInt32(reader.GetOrdinal("DeliveryID")),
                                SalesOrderID = reader.IsDBNull(reader.GetOrdinal("SalesOrderID")) 
                                    ? (int?)null 
                                    : reader.GetInt32(reader.GetOrdinal("SalesOrderID")),
                                DealID = reader.IsDBNull(reader.GetOrdinal("DealID")) 
                                    ? (int?)null 
                                    : reader.GetInt32(reader.GetOrdinal("DealID")),
                                OrderType = reader.IsDBNull(reader.GetOrdinal("OrderType")) 
                                    ? null 
                                    : reader.GetString(reader.GetOrdinal("OrderType")),
                                Status = reader.GetString(reader.GetOrdinal("Status")),
                                DeliveryDate = reader.IsDBNull(reader.GetOrdinal("DeliveryDate")) 
                                    ? (DateTime?)null 
                                    : reader.GetDateTime(reader.GetOrdinal("DeliveryDate")),
                                DeliveryAddress = reader.IsDBNull(reader.GetOrdinal("DeliveryAddress")) 
                                    ? null 
                                    : reader.GetString(reader.GetOrdinal("DeliveryAddress")),
                                City = reader.IsDBNull(reader.GetOrdinal("City")) 
                                    ? null 
                                    : reader.GetString(reader.GetOrdinal("City")),
                                Province = reader.IsDBNull(reader.GetOrdinal("Province")) 
                                    ? null 
                                    : reader.GetString(reader.GetOrdinal("Province")),
                                ReceiverName = reader.IsDBNull(reader.GetOrdinal("ReceiverName")) 
                                    ? null 
                                    : reader.GetString(reader.GetOrdinal("ReceiverName")),
                                ReceiverPhone = reader.IsDBNull(reader.GetOrdinal("ReceiverPhone")) 
                                    ? null 
                                    : reader.GetString(reader.GetOrdinal("ReceiverPhone")),
                                CustomerName = reader.IsDBNull(reader.GetOrdinal("CustomerName")) 
                                    ? null 
                                    : reader.GetString(reader.GetOrdinal("CustomerName")),
                                Notes = reader.IsDBNull(reader.GetOrdinal("Notes")) 
                                    ? null 
                                    : reader.GetString(reader.GetOrdinal("Notes")),
                                CreatedDate = reader.GetDateTime(reader.GetOrdinal("CreatedDate"))
                            });
                        }
                    }
                }
            }

            return deliveries;
        }

        /// <summary>
        /// Update delivery status (Pending → InTransit → Delivered)
        /// </summary>
        public async Task<(bool success, string message)> UpdateDeliveryStatusAsync(
            int deliveryID, 
            int deliveryPersonID, 
            string newStatus, 
            string notes = null)
        {
            using (var connection = new SqlConnection(connectionString))
            {
                await connection.OpenAsync();
                using (var command = new SqlCommand("sp_UpdateDeliveryStatus", connection))
                {
                    command.CommandType = System.Data.CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@DeliveryID", deliveryID);
                    command.Parameters.AddWithValue("@DeliveryPersonID", deliveryPersonID);
                    command.Parameters.AddWithValue("@NewStatus", newStatus);
                    command.Parameters.AddWithValue("@Notes", (object)notes ?? DBNull.Value);

                    try
                    {
                        using (var reader = await command.ExecuteReaderAsync())
                        {
                            if (await reader.ReadAsync())
                            {
                                string result = reader.GetString(reader.GetOrdinal("Result"));
                                string message = reader.GetString(reader.GetOrdinal("Message"));
                                return (result == "Success", message);
                            }
                        }
                    }
                    catch (SqlException ex)
                    {
                        return (false, ex.Message);
                    }
                }
            }

            return (false, "Unknown error occurred");
        }
    }
}
