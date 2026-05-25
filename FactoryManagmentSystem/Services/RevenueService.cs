using System;
using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;
using Microsoft.Data.SqlClient;

namespace FactoryManagmentSystem.Services
{
    /// <summary>
    /// Monthly Revenue Data Model
    /// </summary>
    public class MonthlyRevenueModel
    {
        public int RevenueID { get; set; }
        public int Year { get; set; }
        public int Month { get; set; }
        public string MonthName { get; set; } = string.Empty;

        // Income
        public decimal SalesIncome { get; set; }
        public decimal DealIncome { get; set; }
        public decimal TotalIncome => SalesIncome + DealIncome;

        // Expenses
        public bool SalariesPaid { get; set; }
        public decimal TotalSalaries { get; set; }
        public decimal RawMaterialCost { get; set; }
        public decimal MiscExpense { get; set; }
        public decimal TotalExpense => TotalSalaries + RawMaterialCost + MiscExpense;

        // Profit
        public decimal NetProfit => TotalIncome - TotalExpense;

        public string Notes { get; set; } = string.Empty;

        // Display helpers
        public string SalaryStatus => SalariesPaid ? "✅ Paid" : "⏳ Pending";
        public string ProfitStatus => NetProfit >= 0 ? "Profit" : "Loss";
        public string ProfitColor => NetProfit >= 0 ? "Green" : "Red";
    }

    /// <summary>
    /// Yearly Summary Model
    /// </summary>
    public class YearlySummaryModel
    {
        public int Year { get; set; }
        public decimal TotalSalesIncome { get; set; }
        public decimal TotalDealIncome { get; set; }
        public decimal TotalIncome { get; set; }
        public decimal TotalSalaries { get; set; }
        public decimal TotalRawMaterial { get; set; }
        public decimal TotalMisc { get; set; }
        public decimal TotalExpense { get; set; }
        public decimal NetProfit { get; set; }
        public int MonthsWithData { get; set; }
    }

    /// <summary>
    /// Revenue Service - Handles all revenue-related database operations
    /// </summary>
    public class RevenueService
    {
        private readonly string _connectionString;

        public RevenueService()
        {
            _connectionString = "Server=QASIM\\SQLEXPRESS;Database=GarmentsFactoryDB;Trusted_Connection=True;TrustServerCertificate=True;";
        }

        public RevenueService(string connectionString)
        {
            _connectionString = connectionString;
        }

        #region Get Revenue Data

        /// <summary>
        /// Get monthly revenue for a specific month
        /// </summary>
        public async Task<MonthlyRevenueModel?> GetMonthRevenueAsync(int year, int month)
        {
            try
            {
                using var connection = new SqlConnection(_connectionString);
                await connection.OpenAsync();

                using var command = new SqlCommand("sp_GetMonthRevenue", connection);
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@Year", year);
                command.Parameters.AddWithValue("@Month", month);

                using var reader = await command.ExecuteReaderAsync();
                if (await reader.ReadAsync())
                {
                    return MapToRevenueModel(reader);
                }
                return null;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error getting month revenue: {ex.Message}");
                throw;
            }
        }

        /// <summary>
        /// Get all monthly revenue for a year
        /// </summary>
        public async Task<List<MonthlyRevenueModel>> GetYearlyRevenueAsync(int year)
        {
            var revenues = new List<MonthlyRevenueModel>();
            try
            {
                using var connection = new SqlConnection(_connectionString);
                await connection.OpenAsync();

                using var command = new SqlCommand("sp_GetYearlyRevenue", connection);
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@Year", year);

                using var reader = await command.ExecuteReaderAsync();
                while (await reader.ReadAsync())
                {
                    revenues.Add(MapToRevenueModel(reader));
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error getting yearly revenue: {ex.Message}");
                throw;
            }
            return revenues;
        }

        /// <summary>
        /// Get yearly summary
        /// </summary>
        public async Task<YearlySummaryModel> GetYearlySummaryAsync(int year)
        {
            var revenues = await GetYearlyRevenueAsync(year);
            
            return new YearlySummaryModel
            {
                Year = year,
                TotalSalesIncome = revenues.Sum(r => r.SalesIncome),
                TotalDealIncome = revenues.Sum(r => r.DealIncome),
                TotalIncome = revenues.Sum(r => r.TotalIncome),
                TotalSalaries = revenues.Sum(r => r.TotalSalaries),
                TotalRawMaterial = revenues.Sum(r => r.RawMaterialCost),
                TotalMisc = revenues.Sum(r => r.MiscExpense),
                TotalExpense = revenues.Sum(r => r.TotalExpense),
                NetProfit = revenues.Sum(r => r.NetProfit),
                MonthsWithData = revenues.Count
            };
        }

        #endregion

        #region Calculate & Refresh

        /// <summary>
        /// Calculate/Refresh monthly revenue from actual sales and deals
        /// </summary>
        public async Task<MonthlyRevenueModel?> CalculateMonthlyRevenueAsync(int year, int month)
        {
            try
            {
                using var connection = new SqlConnection(_connectionString);
                await connection.OpenAsync();

                using var command = new SqlCommand("sp_CalculateMonthlyRevenue", connection);
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@Year", year);
                command.Parameters.AddWithValue("@Month", month);

                using var reader = await command.ExecuteReaderAsync();
                if (await reader.ReadAsync())
                {
                    return MapToRevenueModel(reader);
                }
                return null;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error calculating revenue: {ex.Message}");
                throw;
            }
        }

        #endregion

        #region Expense Operations

        /// <summary>
        /// Pay salaries for a month
        /// </summary>
        public async Task<MonthlyRevenueModel?> PaySalariesAsync(int year, int month)
        {
            try
            {
                using var connection = new SqlConnection(_connectionString);
                await connection.OpenAsync();

                using var command = new SqlCommand("sp_PayMonthlySalaries", connection);
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@Year", year);
                command.Parameters.AddWithValue("@Month", month);

                using var reader = await command.ExecuteReaderAsync();
                if (await reader.ReadAsync())
                {
                    return MapToRevenueModel(reader);
                }
                return null;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error paying salaries: {ex.Message}");
                throw;
            }
        }

        /// <summary>
        /// Add miscellaneous expense
        /// </summary>
        public async Task<MonthlyRevenueModel?> AddMiscExpenseAsync(int year, int month, decimal amount, string? description = null)
        {
            try
            {
                using var connection = new SqlConnection(_connectionString);
                await connection.OpenAsync();

                using var command = new SqlCommand("sp_AddMiscExpense", connection);
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@Year", year);
                command.Parameters.AddWithValue("@Month", month);
                command.Parameters.AddWithValue("@Amount", amount);
                command.Parameters.AddWithValue("@Description", (object?)description ?? DBNull.Value);

                using var reader = await command.ExecuteReaderAsync();
                if (await reader.ReadAsync())
                {
                    return MapToRevenueModel(reader);
                }
                return null;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error adding misc expense: {ex.Message}");
                throw;
            }
        }

        /// <summary>
        /// Add raw material cost
        /// </summary>
        public async Task<MonthlyRevenueModel?> AddRawMaterialCostAsync(int year, int month, decimal amount)
        {
            try
            {
                using var connection = new SqlConnection(_connectionString);
                await connection.OpenAsync();

                using var command = new SqlCommand("sp_AddRawMaterialCost", connection);
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@Year", year);
                command.Parameters.AddWithValue("@Month", month);
                command.Parameters.AddWithValue("@Amount", amount);

                using var reader = await command.ExecuteReaderAsync();
                if (await reader.ReadAsync())
                {
                    return MapToRevenueModel(reader);
                }
                return null;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error adding raw material cost: {ex.Message}");
                throw;
            }
        }

        /// <summary>
        /// Reset miscellaneous expenses for a month
        /// </summary>
        public async Task<MonthlyRevenueModel?> ResetMiscExpenseAsync(int year, int month)
        {
            try
            {
                using var connection = new SqlConnection(_connectionString);
                await connection.OpenAsync();

                using var command = new SqlCommand("sp_ResetMiscExpense", connection);
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@Year", year);
                command.Parameters.AddWithValue("@Month", month);

                using var reader = await command.ExecuteReaderAsync();
                if (await reader.ReadAsync())
                {
                    return MapToRevenueModel(reader);
                }
                return null;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error resetting misc expense: {ex.Message}");
                throw;
            }
        }

        #endregion

        #region Helpers

        /// <summary>
        /// Get available years with revenue data
        /// </summary>
        public async Task<List<int>> GetAvailableYearsAsync()
        {
            var years = new List<int>();
            try
            {
                using var connection = new SqlConnection(_connectionString);
                await connection.OpenAsync();

                using var command = new SqlCommand(
                    "SELECT DISTINCT [Year] FROM MonthlyRevenue ORDER BY [Year] DESC", 
                    connection);

                using var reader = await command.ExecuteReaderAsync();
                while (await reader.ReadAsync())
                {
                    years.Add(reader.GetInt32(0));
                }

                // Always include current year
                int currentYear = DateTime.Now.Year;
                if (!years.Contains(currentYear))
                {
                    years.Insert(0, currentYear);
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error getting available years: {ex.Message}");
                // Return at least current year
                years.Add(DateTime.Now.Year);
            }
            return years;
        }

        private MonthlyRevenueModel MapToRevenueModel(SqlDataReader reader)
        {
            return new MonthlyRevenueModel
            {
                RevenueID = reader.IsDBNull(reader.GetOrdinal("RevenueID")) ? 0 : reader.GetInt32(reader.GetOrdinal("RevenueID")),
                Year = reader.GetInt32(reader.GetOrdinal("Year")),
                Month = reader.GetInt32(reader.GetOrdinal("Month")),
                MonthName = reader.IsDBNull(reader.GetOrdinal("MonthName")) ? "" : reader.GetString(reader.GetOrdinal("MonthName")),
                SalesIncome = reader.IsDBNull(reader.GetOrdinal("SalesIncome")) ? 0 : reader.GetDecimal(reader.GetOrdinal("SalesIncome")),
                DealIncome = reader.IsDBNull(reader.GetOrdinal("DealIncome")) ? 0 : reader.GetDecimal(reader.GetOrdinal("DealIncome")),
                SalariesPaid = reader.IsDBNull(reader.GetOrdinal("SalariesPaid")) ? false : reader.GetBoolean(reader.GetOrdinal("SalariesPaid")),
                TotalSalaries = reader.IsDBNull(reader.GetOrdinal("TotalSalaries")) ? 0 : reader.GetDecimal(reader.GetOrdinal("TotalSalaries")),
                RawMaterialCost = reader.IsDBNull(reader.GetOrdinal("RawMaterialCost")) ? 0 : reader.GetDecimal(reader.GetOrdinal("RawMaterialCost")),
                MiscExpense = reader.IsDBNull(reader.GetOrdinal("MiscExpense")) ? 0 : reader.GetDecimal(reader.GetOrdinal("MiscExpense")),
                Notes = reader.IsDBNull(reader.GetOrdinal("Notes")) ? "" : reader.GetString(reader.GetOrdinal("Notes"))
            };
        }

        #endregion
    }
}
