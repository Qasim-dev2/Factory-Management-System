using FactoryManagmentSystem.Models.Salesperson;

namespace FactoryManagmentSystem.Services
{
    /// <summary>
    /// Service interface for Salesperson Dashboard operations
    /// Provides easy database integration interface
    /// </summary>
    public interface ISalespersonDataService
    {
        // Customer Management
        Task<List<SalesCustomer>> GetCustomersAsync(int salespersonId);
        Task<SalesCustomer?> GetCustomerByIdAsync(int customerId);
        Task<SalesCustomer> CreateCustomerAsync(SalesCustomer customer);
        Task<SalesCustomer> UpdateCustomerAsync(SalesCustomer customer);
        Task<bool> DeleteCustomerAsync(int customerId);
        Task<List<SalesCustomer>> SearchCustomersAsync(string searchTerm, int salespersonId);

        // Deal Management
        Task<List<SalesDeal>> GetDealsAsync(int salespersonId);
        Task<SalesDeal?> GetDealByIdAsync(int dealId);
        Task<SalesDeal> CreateDealAsync(SalesDeal deal);
        Task<SalesDeal> UpdateDealAsync(SalesDeal deal);
        Task<bool> DeleteDealAsync(int dealId);
        Task<List<SalesDeal>> GetDealsByStageAsync(string stage, int salespersonId);
        Task<bool> MoveDealToStageAsync(int dealId, string newStage);

        // Deal Activities
        Task<List<DealActivity>> GetDealActivitiesAsync(int dealId);
        Task<DealActivity> CreateDealActivityAsync(DealActivity activity);

        // Sales Orders
        Task<List<SalesOrderHeader>> GetSalesOrdersAsync(int salespersonId);
        Task<SalesOrderHeader?> GetSalesOrderByIdAsync(int orderId);
        Task<SalesOrderHeader> CreateSalesOrderAsync(SalesOrderHeader order);
        Task<SalesOrderHeader> UpdateSalesOrderAsync(SalesOrderHeader order);
        Task<bool> DeleteSalesOrderAsync(int orderId);
        Task<List<SalesOrderHeader>> GetOrdersByStatusAsync(string status, int salespersonId);

        // Deliveries
        Task<List<SalesDelivery>> GetDeliveriesAsync(int salespersonId);
        Task<SalesDelivery?> GetDeliveryByIdAsync(int deliveryId);
        Task<SalesDelivery> CreateDeliveryAsync(SalesDelivery delivery);
        Task<SalesDelivery> UpdateDeliveryAsync(SalesDelivery delivery);
        Task<List<SalesDelivery>> GetDeliveriesByStatusAsync(string status, int salespersonId);

        // Stock Viewing (Read-Only)
        Task<List<SalespersonStockItem>> GetStockItemsAsync();
        Task<SalespersonStockItem?> GetStockItemByIdAsync(int stockItemId);
        Task<List<SalespersonStockItem>> SearchStockItemsAsync(string searchTerm);
        Task<List<SalespersonStockItem>> GetLowStockItemsAsync();

        // Analytics and Reports
        Task<SalesPerformance> GetSalesPerformanceAsync(int salespersonId, DateTime periodStart, DateTime periodEnd);
        Task<Dictionary<string, int>> GetDashboardStatsAsync(int salespersonId);
    }

    /// <summary>
    /// Demo implementation of Salesperson Data Service
    /// Replace with actual database implementation
    /// </summary>
    public class SalespersonDataService : ISalespersonDataService
    {
        // Demo data - replace with actual database context
        private static List<SalesCustomer> _customers = new();
        private static List<SalesDeal> _deals = new();
        private static List<DealActivity> _dealActivities = new();
        private static List<SalesOrderHeader> _salesOrders = new();
        private static List<SalesOrderLine> _orderLines = new();
        private static List<SalesDelivery> _deliveries = new();
        private static List<SalespersonStockItem> _stockItems = new();
        private static List<SalesPerformance> _salesPerformance = new();

        static SalespersonDataService()
        {
            InitializeDemoData();
        }

        #region Customer Management
        public async Task<List<SalesCustomer>> GetCustomersAsync(int salespersonId)
        {
            await Task.Delay(100); // Simulate async operation
            return _customers.Where(c => c.AssignedSalespersonId == salespersonId).ToList();
        }

        public async Task<SalesCustomer?> GetCustomerByIdAsync(int customerId)
        {
            await Task.Delay(50);
            return _customers.FirstOrDefault(c => c.CustomerId == customerId);
        }

        public async Task<SalesCustomer> CreateCustomerAsync(SalesCustomer customer)
        {
            await Task.Delay(100);
            customer.CustomerId = _customers.Count + 1;
            customer.CreatedDate = DateTime.Now;
            _customers.Add(customer);
            return customer;
        }

        public async Task<SalesCustomer> UpdateCustomerAsync(SalesCustomer customer)
        {
            await Task.Delay(100);
            var existing = _customers.FirstOrDefault(c => c.CustomerId == customer.CustomerId);
            if (existing != null)
            {
                var index = _customers.IndexOf(existing);
                _customers[index] = customer;
            }
            return customer;
        }

        public async Task<bool> DeleteCustomerAsync(int customerId)
        {
            await Task.Delay(100);
            var customer = _customers.FirstOrDefault(c => c.CustomerId == customerId);
            if (customer != null)
            {
                customer.Status = "Inactive";
                return true;
            }
            return false;
        }

        public async Task<List<SalesCustomer>> SearchCustomersAsync(string searchTerm, int salespersonId)
        {
            await Task.Delay(100);
            return _customers.Where(c => c.AssignedSalespersonId == salespersonId &&
                                       (c.CompanyName.Contains(searchTerm, StringComparison.OrdinalIgnoreCase) ||
                                        c.ContactPerson.Contains(searchTerm, StringComparison.OrdinalIgnoreCase) ||
                                        c.Email.Contains(searchTerm, StringComparison.OrdinalIgnoreCase))).ToList();
        }
        #endregion

        #region Deal Management
        public async Task<List<SalesDeal>> GetDealsAsync(int salespersonId)
        {
            await Task.Delay(100);
            return _deals.Where(d => d.SalespersonId == salespersonId && d.IsActive).ToList();
        }

        public async Task<SalesDeal?> GetDealByIdAsync(int dealId)
        {
            await Task.Delay(50);
            return _deals.FirstOrDefault(d => d.DealId == dealId);
        }

        public async Task<SalesDeal> CreateDealAsync(SalesDeal deal)
        {
            await Task.Delay(100);
            deal.DealId = _deals.Count + 1;
            deal.CreatedDate = DateTime.Now;
            _deals.Add(deal);
            return deal;
        }

        public async Task<SalesDeal> UpdateDealAsync(SalesDeal deal)
        {
            await Task.Delay(100);
            var existing = _deals.FirstOrDefault(d => d.DealId == deal.DealId);
            if (existing != null)
            {
                var index = _deals.IndexOf(existing);
                _deals[index] = deal;
            }
            return deal;
        }

        public async Task<bool> DeleteDealAsync(int dealId)
        {
            await Task.Delay(100);
            var deal = _deals.FirstOrDefault(d => d.DealId == dealId);
            if (deal != null)
            {
                deal.IsActive = false;
                return true;
            }
            return false;
        }

        public async Task<List<SalesDeal>> GetDealsByStageAsync(string stage, int salespersonId)
        {
            await Task.Delay(100);
            return _deals.Where(d => d.Stage == stage && d.SalespersonId == salespersonId && d.IsActive).ToList();
        }

        public async Task<bool> MoveDealToStageAsync(int dealId, string newStage)
        {
            await Task.Delay(100);
            var deal = _deals.FirstOrDefault(d => d.DealId == dealId);
            if (deal != null)
            {
                deal.Stage = newStage;
                if (newStage == "Won" || newStage == "Lost")
                {
                    deal.ActualCloseDate = DateTime.Now;
                }
                return true;
            }
            return false;
        }

        public async Task<List<DealActivity>> GetDealActivitiesAsync(int dealId)
        {
            await Task.Delay(100);
            return _dealActivities.Where(da => da.DealId == dealId)
                                 .OrderByDescending(da => da.ActivityDate).ToList();
        }

        public async Task<DealActivity> CreateDealActivityAsync(DealActivity activity)
        {
            await Task.Delay(100);
            activity.ActivityId = _dealActivities.Count + 1;
            _dealActivities.Add(activity);
            return activity;
        }
        #endregion

        #region Sales Orders
        public async Task<List<SalesOrderHeader>> GetSalesOrdersAsync(int salespersonId)
        {
            await Task.Delay(100);
            return _salesOrders.Where(so => so.SalespersonId == salespersonId)
                              .OrderByDescending(so => so.OrderDate).ToList();
        }

        public async Task<SalesOrderHeader?> GetSalesOrderByIdAsync(int orderId)
        {
            await Task.Delay(50);
            return _salesOrders.FirstOrDefault(so => so.OrderId == orderId);
        }

        public async Task<SalesOrderHeader> CreateSalesOrderAsync(SalesOrderHeader order)
        {
            await Task.Delay(100);
            order.OrderId = _salesOrders.Count + 1;
            order.OrderDate = DateTime.Now;
            _salesOrders.Add(order);
            return order;
        }

        public async Task<SalesOrderHeader> UpdateSalesOrderAsync(SalesOrderHeader order)
        {
            await Task.Delay(100);
            var existing = _salesOrders.FirstOrDefault(so => so.OrderId == order.OrderId);
            if (existing != null)
            {
                var index = _salesOrders.IndexOf(existing);
                _salesOrders[index] = order;
            }
            return order;
        }

        public async Task<bool> DeleteSalesOrderAsync(int orderId)
        {
            await Task.Delay(100);
            var order = _salesOrders.FirstOrDefault(so => so.OrderId == orderId);
            if (order != null && order.Status == "Draft")
            {
                order.Status = "Cancelled";
                return true;
            }
            return false;
        }

        public async Task<List<SalesOrderHeader>> GetOrdersByStatusAsync(string status, int salespersonId)
        {
            await Task.Delay(100);
            return _salesOrders.Where(so => so.Status == status && so.SalespersonId == salespersonId).ToList();
        }
        #endregion

        #region Deliveries
        public async Task<List<SalesDelivery>> GetDeliveriesAsync(int salespersonId)
        {
            await Task.Delay(100);
            return _deliveries.Where(d => d.SalespersonId == salespersonId)
                             .OrderByDescending(d => d.ScheduledDate).ToList();
        }

        public async Task<SalesDelivery?> GetDeliveryByIdAsync(int deliveryId)
        {
            await Task.Delay(50);
            return _deliveries.FirstOrDefault(d => d.DeliveryId == deliveryId);
        }

        public async Task<SalesDelivery> CreateDeliveryAsync(SalesDelivery delivery)
        {
            await Task.Delay(100);
            delivery.DeliveryId = _deliveries.Count + 1;
            _deliveries.Add(delivery);
            return delivery;
        }

        public async Task<SalesDelivery> UpdateDeliveryAsync(SalesDelivery delivery)
        {
            await Task.Delay(100);
            var existing = _deliveries.FirstOrDefault(d => d.DeliveryId == delivery.DeliveryId);
            if (existing != null)
            {
                var index = _deliveries.IndexOf(existing);
                _deliveries[index] = delivery;
            }
            return delivery;
        }

        public async Task<List<SalesDelivery>> GetDeliveriesByStatusAsync(string status, int salespersonId)
        {
            await Task.Delay(100);
            return _deliveries.Where(d => d.Status == status && d.SalespersonId == salespersonId).ToList();
        }
        #endregion

        #region Stock Viewing (Read-Only)
        public async Task<List<SalespersonStockItem>> GetStockItemsAsync()
        {
            await Task.Delay(100); // Simulate database delay
            return _stockItems.Where(si => si.IsActive).ToList();
        }

        public async Task<SalespersonStockItem?> GetStockItemByIdAsync(int stockItemId)
        {
            await Task.Delay(50);
            return _stockItems.FirstOrDefault(si => si.StockItemId == stockItemId);
        }

        public async Task<List<SalespersonStockItem>> SearchStockItemsAsync(string searchTerm)
        {
            await Task.Delay(100);
            return _stockItems.Where(si => si.IsActive &&
                                         (si.ProductName.Contains(searchTerm, StringComparison.OrdinalIgnoreCase) ||
                                          si.ProductCode.Contains(searchTerm, StringComparison.OrdinalIgnoreCase) ||
                                          si.Category.Contains(searchTerm, StringComparison.OrdinalIgnoreCase))).ToList();
        }

        public async Task<List<SalespersonStockItem>> GetLowStockItemsAsync()
        {
            await Task.Delay(100);
            return _stockItems.Where(si => si.IsActive && si.CurrentStock <= si.MinimumStock).ToList();
        }
        #endregion

        #region Analytics and Reports
        public async Task<SalesPerformance> GetSalesPerformanceAsync(int salespersonId, DateTime periodStart, DateTime periodEnd)
        {
            await Task.Delay(100);
            return _salesPerformance.FirstOrDefault(sp => sp.SalespersonId == salespersonId &&
                                                         sp.PeriodStart <= periodStart &&
                                                         sp.PeriodEnd >= periodEnd) ?? new SalesPerformance
            {
                SalespersonId = salespersonId,
                PeriodStart = periodStart,
                PeriodEnd = periodEnd,
                TotalSales = 125000,
                Target = 150000,
                DealsWon = 8,
                DealsLost = 3,
                NewCustomers = 5,
                WinRate = 72.7m,
                AverageDealSize = 15625
            };
        }

        public async Task<Dictionary<string, int>> GetDashboardStatsAsync(int salespersonId)
        {
            await Task.Delay(100);
            
            var stats = new Dictionary<string, int>
            {
                ["ActiveDeals"] = _deals.Count(d => d.SalespersonId == salespersonId && d.IsActive),
                ["TotalCustomers"] = _customers.Count(c => c.AssignedSalespersonId == salespersonId && c.Status == "Active"),
                ["OpenOrders"] = _salesOrders.Count(so => so.SalespersonId == salespersonId && 
                                                         (so.Status == "Submitted" || so.Status == "Processing")),
                ["PendingDeliveries"] = _deliveries.Count(d => d.SalespersonId == salespersonId && 
                                                              (d.Status == "Scheduled" || d.Status == "InTransit"))
            };

            return stats;
        }
        #endregion

        #region Demo Data Initialization
        private static void InitializeDemoData()
        {
            // Sample Customers
            _customers.AddRange(new[]
            {
                new SalesCustomer { CustomerId = 1, CompanyName = "ABC Corporation", ContactPerson = "John Smith", Position = "Purchasing Manager", Email = "john.smith@abc.com", PhoneNumber = "555-0101", Address = "123 Business St", City = "Business City", State = "NY", PostalCode = "10001", AssignedSalespersonId = 1, Status = "Active", Priority = "High" },
                new SalesCustomer { CustomerId = 2, CompanyName = "XYZ Industries", ContactPerson = "Sarah Johnson", Position = "Operations Director", Email = "sarah.johnson@xyz.com", PhoneNumber = "555-0102", Address = "456 Industrial Ave", City = "Industrial Town", State = "CA", PostalCode = "90001", AssignedSalespersonId = 1, Status = "Active", Priority = "Medium" },
                new SalesCustomer { CustomerId = 3, CompanyName = "Global Enterprises", ContactPerson = "Mike Davis", Position = "Procurement Head", Email = "mike.davis@global.com", PhoneNumber = "555-0103", Address = "789 Corporate Blvd", City = "Metro City", State = "TX", PostalCode = "75001", AssignedSalespersonId = 1, Status = "Active", Priority = "High" }
            });

            // Sample Deals
            _deals.AddRange(new[]
            {
                new SalesDeal { DealId = 1, DealTitle = "ABC Corp Annual Contract", DealNumber = "D-2024-001", CustomerId = 1, EstimatedValue = 50000, ProbabilityPercent = 80, Stage = "Negotiation", Priority = "High", SalespersonId = 1, Description = "Annual paper supply contract", ExpectedCloseDate = DateTime.Now.AddDays(15), IsActive = true },
                new SalesDeal { DealId = 2, DealTitle = "XYZ Custom Packaging", DealNumber = "D-2024-002", CustomerId = 2, EstimatedValue = 25000, ProbabilityPercent = 60, Stage = "Proposal", Priority = "Medium", SalespersonId = 1, Description = "Custom packaging solution", ExpectedCloseDate = DateTime.Now.AddDays(30), IsActive = true },
                new SalesDeal { DealId = 3, DealTitle = "Global Office Supplies", DealNumber = "D-2024-003", CustomerId = 3, EstimatedValue = 75000, ProbabilityPercent = 90, Stage = "Closing", Priority = "High", SalespersonId = 1, Description = "Complete office paper solution", ExpectedCloseDate = DateTime.Now.AddDays(7), IsActive = true }
            });

            // Sample Sales Orders
            _salesOrders.AddRange(new[]
            {
                new SalesOrderHeader { OrderId = 1, OrderNumber = "SO-2024-001", CustomerId = 1, OrderDate = DateTime.Now.AddDays(-5), RequestedDeliveryDate = DateTime.Now.AddDays(10), SubtotalAmount = 15000, TaxAmount = 1200, TotalAmount = 16200, Status = "Processing", SalespersonId = 1, ShippingAddress = "123 Business St, Business City, NY 10001" },
                new SalesOrderHeader { OrderId = 2, OrderNumber = "SO-2024-002", CustomerId = 2, OrderDate = DateTime.Now.AddDays(-3), RequestedDeliveryDate = DateTime.Now.AddDays(15), SubtotalAmount = 8500, TaxAmount = 680, TotalAmount = 9180, Status = "Submitted", SalespersonId = 1, ShippingAddress = "456 Industrial Ave, Industrial Town, CA 90001" }
            });

            // Sample Deliveries
            _deliveries.AddRange(new[]
            {
                new SalesDelivery { DeliveryId = 1, DeliveryNumber = "DEL-2024-001", OrderId = 1, ScheduledDate = DateTime.Now.AddDays(2), DeliveryAddress = "123 Business St, Business City, NY 10001", DeliveryContact = "John Smith", ContactPhone = "555-0101", Status = "Scheduled", TrackingNumber = "TRK123456", CarrierName = "Fast Delivery Co", SalespersonId = 1 },
                new SalesDelivery { DeliveryId = 2, DeliveryNumber = "DEL-2024-002", OrderId = 2, ScheduledDate = DateTime.Now.AddDays(5), DeliveryAddress = "456 Industrial Ave, Industrial Town, CA 90001", DeliveryContact = "Sarah Johnson", ContactPhone = "555-0102", Status = "InTransit", TrackingNumber = "TRK789012", CarrierName = "Quick Ship Express", SalespersonId = 1 }
            });

            // Sample Stock Items
            _stockItems.AddRange(new[]
            {
                new SalespersonStockItem { StockItemId = 1, ProductName = "A4 Copy Paper", ProductCode = "PP001", Description = "High quality white copy paper", Category = "Office Paper", CurrentStock = 1500, ReservedStock = 200, AvailableStock = 1300, MinimumStock = 300, UnitPrice = 5.99m, Unit = "Ream", IsActive = true },
                new SalespersonStockItem { StockItemId = 2, ProductName = "Legal Size Paper", ProductCode = "PP002", Description = "Legal size white paper", Category = "Office Paper", CurrentStock = 800, ReservedStock = 100, AvailableStock = 700, MinimumStock = 200, UnitPrice = 7.99m, Unit = "Ream", IsActive = true },
                new SalespersonStockItem { StockItemId = 3, ProductName = "Cardboard Boxes", ProductCode = "CB001", Description = "Corrugated cardboard shipping boxes", Category = "Packaging", CurrentStock = 250, ReservedStock = 50, AvailableStock = 200, MinimumStock = 100, UnitPrice = 2.50m, Unit = "Each", IsActive = true },
                new SalespersonStockItem { StockItemId = 4, ProductName = "Tissue Paper", ProductCode = "TP001", Description = "Soft facial tissue", Category = "Consumer Paper", CurrentStock = 50, ReservedStock = 25, AvailableStock = 25, MinimumStock = 100, UnitPrice = 1.99m, Unit = "Box", IsActive = true }
            });

            // Sample Deal Activities
            _dealActivities.AddRange(new[]
            {
                new DealActivity { ActivityId = 1, DealId = 1, ActivityType = "Call", Subject = "Initial contact with John Smith", Description = "Discussed requirements and timeline", ActivityDate = DateTime.Now.AddDays(-10), Status = "Completed", CreatedBy = 1 },
                new DealActivity { ActivityId = 2, DealId = 1, ActivityType = "Meeting", Subject = "Product demonstration", Description = "Showed product samples and capabilities", ActivityDate = DateTime.Now.AddDays(-7), Status = "Completed", CreatedBy = 1 },
                new DealActivity { ActivityId = 3, DealId = 2, ActivityType = "Email", Subject = "Proposal sent", Description = "Sent detailed proposal with pricing", ActivityDate = DateTime.Now.AddDays(-5), Status = "Completed", CreatedBy = 1 }
            });
        }
        #endregion
    }
}