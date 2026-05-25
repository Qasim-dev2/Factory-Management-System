using System;
using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;
using Microsoft.Data.SqlClient;

namespace FactoryManagmentSystem.Services
{
    #region Models

    /// <summary>
    /// Revenue Summary for Date Range
    /// </summary>
    public class RevenueSummaryModel
    {
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        
        // Income
        public decimal SalesIncome { get; set; }
        public decimal DealIncome { get; set; }
        public decimal TotalIncome => SalesIncome + DealIncome;
        
        // Expenses
        public decimal RawMaterialCost { get; set; }
        public decimal MiscExpense { get; set; }
        public decimal SalaryExpense { get; set; }
        public decimal TotalExpense => RawMaterialCost + MiscExpense + SalaryExpense;
        
        // Profit
        public decimal NetProfit => TotalIncome - TotalExpense;
        public decimal ProfitMargin => TotalIncome > 0 ? (NetProfit / TotalIncome) * 100 : 0;
    }

    /// <summary>
    /// Sales Order Item for Revenue View
    /// </summary>
    public class RevenueSalesOrderItem
    {
        public int SalesOrderID { get; set; }
        public DateTime OrderDate { get; set; }
        public string RetailerName { get; set; } = string.Empty;
        public string Status { get; set; } = string.Empty;
        public decimal TotalAmount { get; set; }
    }

    /// <summary>
    /// Deal Item for Revenue
    /// </summary>
    public class RevenueDealItem
    {
        public int DealID { get; set; }
        public string DealTitle { get; set; } = string.Empty;
        public string ClientName { get; set; } = string.Empty;
        public DateTime StartDate { get; set; }
        public string Status { get; set; } = string.Empty;
        public decimal TotalAmount { get; set; }
    }

    /// <summary>
    /// Raw Material Purchase Item
    /// </summary>
    public class PurchaseItem
    {
        public int PurchaseID { get; set; }
        public string MaterialName { get; set; } = string.Empty;
        public DateTime PurchaseDate { get; set; }
        public decimal Quantity { get; set; }
        public string Unit { get; set; } = string.Empty;
        public decimal UnitPrice { get; set; }
        public decimal TotalAmount { get; set; }
        public string SupplierName { get; set; } = string.Empty;
    }

    /// <summary>
    /// Misc Expense Item
    /// </summary>
    public class ExpenseItem
    {
        public int ExpenseID { get; set; }
        public DateTime ExpenseDate { get; set; }
        public string Category { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public decimal Amount { get; set; }
        public string PaidTo { get; set; } = string.Empty;
    }

    /// <summary>
    /// Salary Status
    /// </summary>
    public class SalaryStatusModel
    {
        public int Month { get; set; }
        public int Year { get; set; }
        public decimal TotalSalary { get; set; }
        public int EmployeeCount { get; set; }
        public bool IsPaid { get; set; }
        public string MonthName => new DateTime(Year, Month, 1).ToString("MMMM yyyy");
    }

    #endregion

    /// <summary>
    /// Simplified Revenue Service - Date Range Based
    /// </summary>
    public class SimpleRevenueService
    {
        private readonly string _connectionString;

        public SimpleRevenueService()
        {
            _connectionString = "Server=QASIM\\SQLEXPRESS;Database=GarmentsFactoryDB;Trusted_Connection=True;TrustServerCertificate=True;";
        }

        #region Get Revenue Summary

        /// <summary>
        /// Get revenue summary for a date range
        /// </summary>
        public async Task<RevenueSummaryModel> GetRevenueSummaryAsync(DateTime startDate, DateTime endDate)
        {
            var summary = new RevenueSummaryModel { StartDate = startDate, EndDate = endDate };
            
            try
            {
                using var connection = new SqlConnection(_connectionString);
                await connection.OpenAsync();

                using var command = new SqlCommand("sp_GetRevenueByDateRange", connection);
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@StartDate", startDate.Date);
                command.Parameters.AddWithValue("@EndDate", endDate.Date);

                using var reader = await command.ExecuteReaderAsync();
                if (await reader.ReadAsync())
                {
                    summary.SalesIncome = reader.IsDBNull(reader.GetOrdinal("SalesIncome")) ? 0 : reader.GetDecimal(reader.GetOrdinal("SalesIncome"));
                    summary.DealIncome = reader.IsDBNull(reader.GetOrdinal("DealIncome")) ? 0 : reader.GetDecimal(reader.GetOrdinal("DealIncome"));
                    summary.RawMaterialCost = reader.IsDBNull(reader.GetOrdinal("RawMaterialCost")) ? 0 : reader.GetDecimal(reader.GetOrdinal("RawMaterialCost"));
                    summary.MiscExpense = reader.IsDBNull(reader.GetOrdinal("MiscExpense")) ? 0 : reader.GetDecimal(reader.GetOrdinal("MiscExpense"));
                    summary.SalaryExpense = reader.IsDBNull(reader.GetOrdinal("SalaryExpense")) ? 0 : reader.GetDecimal(reader.GetOrdinal("SalaryExpense"));
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error getting revenue summary: {ex.Message}");
                throw;
            }
            
            return summary;
        }

        #endregion

        #region Get Sales Orders

        public async Task<List<RevenueSalesOrderItem>> GetSalesOrdersAsync(DateTime startDate, DateTime endDate)
        {
            var orders = new List<RevenueSalesOrderItem>();
            
            try
            {
                using var connection = new SqlConnection(_connectionString);
                await connection.OpenAsync();

                using var command = new SqlCommand("sp_GetSalesOrdersByDateRange", connection);
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@StartDate", startDate.Date);
                command.Parameters.AddWithValue("@EndDate", endDate.Date);

                using var reader = await command.ExecuteReaderAsync();
                while (await reader.ReadAsync())
                {
                    orders.Add(new RevenueSalesOrderItem
                    {
                        SalesOrderID = reader.GetInt32(reader.GetOrdinal("SalesOrderID")),
                        OrderDate = reader.GetDateTime(reader.GetOrdinal("OrderDate")),
                        RetailerName = reader.IsDBNull(reader.GetOrdinal("RetailerName")) ? "" : reader.GetString(reader.GetOrdinal("RetailerName")),
                        Status = reader.IsDBNull(reader.GetOrdinal("Status")) ? "" : reader.GetString(reader.GetOrdinal("Status")),
                        TotalAmount = reader.IsDBNull(reader.GetOrdinal("TotalAmount")) ? 0 : reader.GetDecimal(reader.GetOrdinal("TotalAmount"))
                    });
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error getting sales orders: {ex.Message}");
            }
            
            return orders;
        }

        #endregion

        #region Get Deals

        public async Task<List<RevenueDealItem>> GetDealsAsync(DateTime startDate, DateTime endDate)
        {
            var deals = new List<RevenueDealItem>();
            
            try
            {
                using var connection = new SqlConnection(_connectionString);
                await connection.OpenAsync();

                using var command = new SqlCommand("sp_GetDealsByDateRange", connection);
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@StartDate", startDate.Date);
                command.Parameters.AddWithValue("@EndDate", endDate.Date);

                using var reader = await command.ExecuteReaderAsync();
                while (await reader.ReadAsync())
                {
                    deals.Add(new RevenueDealItem
                    {
                        DealID = reader.GetInt32(reader.GetOrdinal("DealID")),
                        DealTitle = reader.IsDBNull(reader.GetOrdinal("DealTitle")) ? "" : reader.GetString(reader.GetOrdinal("DealTitle")),
                        ClientName = reader.IsDBNull(reader.GetOrdinal("ClientName")) ? "" : reader.GetString(reader.GetOrdinal("ClientName")),
                        StartDate = reader.GetDateTime(reader.GetOrdinal("StartDate")),
                        Status = reader.IsDBNull(reader.GetOrdinal("Status")) ? "" : reader.GetString(reader.GetOrdinal("Status")),
                        TotalAmount = reader.IsDBNull(reader.GetOrdinal("TotalAmount")) ? 0 : reader.GetDecimal(reader.GetOrdinal("TotalAmount"))
                    });
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error getting deals: {ex.Message}");
            }
            
            return deals;
        }

        #endregion

        #region Get Purchases

        public async Task<List<PurchaseItem>> GetPurchasesAsync(DateTime startDate, DateTime endDate)
        {
            var purchases = new List<PurchaseItem>();
            
            try
            {
                using var connection = new SqlConnection(_connectionString);
                await connection.OpenAsync();

                using var command = new SqlCommand("sp_GetPurchasesByDateRange", connection);
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@StartDate", startDate.Date);
                command.Parameters.AddWithValue("@EndDate", endDate.Date);

                using var reader = await command.ExecuteReaderAsync();
                while (await reader.ReadAsync())
                {
                    purchases.Add(new PurchaseItem
                    {
                        PurchaseID = reader.GetInt32(reader.GetOrdinal("PurchaseID")),
                        MaterialName = reader.GetString(reader.GetOrdinal("MaterialName")),
                        PurchaseDate = reader.GetDateTime(reader.GetOrdinal("PurchaseDate")),
                        Quantity = reader.GetDecimal(reader.GetOrdinal("Quantity")),
                        Unit = reader.IsDBNull(reader.GetOrdinal("Unit")) ? "" : reader.GetString(reader.GetOrdinal("Unit")),
                        UnitPrice = reader.GetDecimal(reader.GetOrdinal("UnitPrice")),
                        TotalAmount = reader.GetDecimal(reader.GetOrdinal("TotalAmount")),
                        SupplierName = reader.IsDBNull(reader.GetOrdinal("SupplierName")) ? "" : reader.GetString(reader.GetOrdinal("SupplierName"))
                    });
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error getting purchases: {ex.Message}");
            }
            
            return purchases;
        }

        #endregion

        #region Get Expenses

        public async Task<List<ExpenseItem>> GetExpensesAsync(DateTime startDate, DateTime endDate)
        {
            var expenses = new List<ExpenseItem>();
            
            try
            {
                using var connection = new SqlConnection(_connectionString);
                await connection.OpenAsync();

                using var command = new SqlCommand("sp_GetExpensesByDateRange", connection);
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@StartDate", startDate.Date);
                command.Parameters.AddWithValue("@EndDate", endDate.Date);

                using var reader = await command.ExecuteReaderAsync();
                while (await reader.ReadAsync())
                {
                    expenses.Add(new ExpenseItem
                    {
                        ExpenseID = reader.GetInt32(reader.GetOrdinal("ExpenseID")),
                        ExpenseDate = reader.GetDateTime(reader.GetOrdinal("ExpenseDate")),
                        Category = reader.IsDBNull(reader.GetOrdinal("Category")) ? "" : reader.GetString(reader.GetOrdinal("Category")),
                        Description = reader.IsDBNull(reader.GetOrdinal("Description")) ? "" : reader.GetString(reader.GetOrdinal("Description")),
                        Amount = reader.GetDecimal(reader.GetOrdinal("Amount")),
                        PaidTo = reader.IsDBNull(reader.GetOrdinal("PaidTo")) ? "" : reader.GetString(reader.GetOrdinal("PaidTo"))
                    });
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error getting expenses: {ex.Message}");
            }
            
            return expenses;
        }

        #endregion

        #region Add Purchase

        public async Task<int> AddPurchaseAsync(string materialName, DateTime purchaseDate, decimal quantity, 
            string unit, decimal unitPrice, string? supplierName = null, string? notes = null)
        {
            try
            {
                using var connection = new SqlConnection(_connectionString);
                await connection.OpenAsync();

                using var command = new SqlCommand("sp_AddRawMaterialPurchase", connection);
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@MaterialName", materialName);
                command.Parameters.AddWithValue("@PurchaseDate", purchaseDate.Date);
                command.Parameters.AddWithValue("@Quantity", quantity);
                command.Parameters.AddWithValue("@Unit", (object?)unit ?? DBNull.Value);
                command.Parameters.AddWithValue("@UnitPrice", unitPrice);
                command.Parameters.AddWithValue("@SupplierName", (object?)supplierName ?? DBNull.Value);
                command.Parameters.AddWithValue("@Notes", (object?)notes ?? DBNull.Value);

                using var reader = await command.ExecuteReaderAsync();
                if (await reader.ReadAsync())
                {
                    return Convert.ToInt32(reader["PurchaseID"]);
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error adding purchase: {ex.Message}");
                throw;
            }
            return 0;
        }

        #endregion

        #region Add Expense

        public async Task<int> AddExpenseAsync(DateTime expenseDate, decimal amount, string? category = null, 
            string? description = null, string? paidTo = null)
        {
            try
            {
                using var connection = new SqlConnection(_connectionString);
                await connection.OpenAsync();

                using var command = new SqlCommand("sp_AddMiscExpense", connection);
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@ExpenseDate", expenseDate.Date);
                command.Parameters.AddWithValue("@Amount", amount);
                command.Parameters.AddWithValue("@Category", (object?)category ?? DBNull.Value);
                command.Parameters.AddWithValue("@Description", (object?)description ?? DBNull.Value);
                command.Parameters.AddWithValue("@PaidTo", (object?)paidTo ?? DBNull.Value);

                using var reader = await command.ExecuteReaderAsync();
                if (await reader.ReadAsync())
                {
                    return Convert.ToInt32(reader["ExpenseID"]);
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error adding expense: {ex.Message}");
                throw;
            }
            return 0;
        }

        #endregion

        #region Salary Management

        public async Task<SalaryStatusModel> GetSalaryStatusAsync(int month, int year)
        {
            var status = new SalaryStatusModel { Month = month, Year = year };
            
            try
            {
                using var connection = new SqlConnection(_connectionString);
                await connection.OpenAsync();

                using var command = new SqlCommand("sp_GetMonthlySalaryStatus", connection);
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@Month", month);
                command.Parameters.AddWithValue("@Year", year);

                using var reader = await command.ExecuteReaderAsync();
                if (await reader.ReadAsync())
                {
                    status.TotalSalary = reader.GetDecimal(reader.GetOrdinal("TotalSalary"));
                    status.EmployeeCount = reader.GetInt32(reader.GetOrdinal("EmployeeCount"));
                    status.IsPaid = reader.GetInt32(reader.GetOrdinal("IsPaid")) == 1;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error getting salary status: {ex.Message}");
            }
            
            return status;
        }

        public async Task<(bool Success, decimal TotalAmount, int EmployeeCount)> PayMonthlySalaryAsync(int month, int year)
        {
            try
            {
                using var connection = new SqlConnection(_connectionString);
                await connection.OpenAsync();

                using var command = new SqlCommand("sp_PayMonthlySalary", connection);
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@Month", month);
                command.Parameters.AddWithValue("@Year", year);

                using var reader = await command.ExecuteReaderAsync();
                if (await reader.ReadAsync())
                {
                    var statusText = reader.GetString(reader.GetOrdinal("Status"));
                    var totalAmount = reader.GetDecimal(reader.GetOrdinal("TotalAmount"));
                    var empCount = reader.GetInt32(reader.GetOrdinal("EmployeeCount"));
                    
                    return (statusText == "Paid", totalAmount, empCount);
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error paying salary: {ex.Message}");
                throw;
            }
            
            return (false, 0, 0);
        }

        /// <summary>
        /// Auto-pay all past month salaries (from system start Sep 2025)
        /// </summary>
        public async Task<(int PaymentsAdded, decimal MonthlySalary, int EmployeeCount)> AutoPayPastSalariesAsync()
        {
            try
            {
                using var connection = new SqlConnection(_connectionString);
                await connection.OpenAsync();

                using var command = new SqlCommand("sp_AutoPayPastSalaries", connection);
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@SystemStartMonth", 9);
                command.Parameters.AddWithValue("@SystemStartYear", 2025);

                using var reader = await command.ExecuteReaderAsync();
                if (await reader.ReadAsync())
                {
                    var paymentsAdded = reader.GetInt32(reader.GetOrdinal("NewPaymentsAdded"));
                    var monthlySalary = reader.GetDecimal(reader.GetOrdinal("MonthlySalaryAmount"));
                    var empCount = reader.GetInt32(reader.GetOrdinal("EmployeeCount"));
                    
                    return (paymentsAdded, monthlySalary, empCount);
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error auto-paying salaries: {ex.Message}");
            }
            
            return (0, 0, 0);
        }

        /// <summary>
        /// Get list of all salary months with paid/unpaid status
        /// </summary>
        public async Task<List<SalaryMonthStatus>> GetSalaryHistoryAsync()
        {
            var history = new List<SalaryMonthStatus>();
            
            try
            {
                using var connection = new SqlConnection(_connectionString);
                await connection.OpenAsync();

                using var command = new SqlCommand("sp_GetUnpaidSalaryMonths", connection);
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@SystemStartMonth", 9);
                command.Parameters.AddWithValue("@SystemStartYear", 2025);

                using var reader = await command.ExecuteReaderAsync();
                while (await reader.ReadAsync())
                {
                    history.Add(new SalaryMonthStatus
                    {
                        Year = reader.GetInt32(reader.GetOrdinal("Year")),
                        Month = reader.GetInt32(reader.GetOrdinal("Month")),
                        MonthName = reader.GetString(reader.GetOrdinal("MonthName")),
                        IsPaid = reader.GetInt32(reader.GetOrdinal("IsPaid")) == 1,
                        PaidAmount = reader.GetDecimal(reader.GetOrdinal("PaidAmount"))
                    });
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error getting salary history: {ex.Message}");
            }
            
            return history;
        }

        #endregion
    }

    /// <summary>
    /// Salary Month Status Model
    /// </summary>
    public class SalaryMonthStatus
    {
        public int Year { get; set; }
        public int Month { get; set; }
        public string MonthName { get; set; } = string.Empty;
        public bool IsPaid { get; set; }
        public decimal PaidAmount { get; set; }
        public string Status => IsPaid ? "✅ Paid" : "⏳ Pending";
        public string DisplayName => $"{MonthName} {Year}";
    }
}
