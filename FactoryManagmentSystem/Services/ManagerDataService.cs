using FactoryManagmentSystem.Models.Manager;

namespace FactoryManagmentSystem.Services
{
    /// <summary>
    /// Service layer for Manager Dashboard operations
    /// Provides easy database integration interface
    /// </summary>
    public interface IManagerDataService
    {
        // Employee Management
        Task<List<Employee>> GetEmployeesAsync(int managerId);
        Task<Employee?> GetEmployeeByIdAsync(int employeeId);
        Task<Employee> CreateEmployeeAsync(Employee employee);
        Task<Employee> UpdateEmployeeAsync(Employee employee);
        Task<bool> DeleteEmployeeAsync(int employeeId);

        // Product Management
        Task<List<Product>> GetProductsAsync();
        Task<Product?> GetProductByIdAsync(int productId);
        Task<Product> CreateProductAsync(Product product);
        Task<Product> UpdateProductAsync(Product product);
        Task<bool> DeleteProductAsync(int productId);

        // Raw Materials Management
        Task<List<RawMaterial>> GetRawMaterialsAsync();
        Task<RawMaterial?> GetRawMaterialByIdAsync(int materialId);
        Task<RawMaterial> CreateRawMaterialAsync(RawMaterial material);
        Task<RawMaterial> UpdateRawMaterialAsync(RawMaterial material);
        Task<bool> DeleteRawMaterialAsync(int materialId);

        // Stock Management
        Task<List<StockEntry>> GetStockEntriesAsync();
        Task<StockEntry> CreateStockEntryAsync(StockEntry entry);
        Task<List<Product>> GetLowStockProductsAsync();

        // Deal Management
        Task<List<Deal>> GetPendingDealsAsync();
        Task<Deal?> GetDealByIdAsync(int dealId);
        Task<bool> ApproveDealAsync(int dealId, int approvedBy, string notes);
        Task<bool> RejectDealAsync(int dealId, int rejectedBy, string notes);

        // Sales Orders Management
        Task<List<SalesOrder>> GetSalesOrdersAsync();
        Task<SalesOrder?> GetSalesOrderByIdAsync(int orderId);
        Task<SalesOrder> CreateSalesOrderAsync(SalesOrder order);
        Task<SalesOrder> UpdateSalesOrderAsync(SalesOrder order);

        // Machinery Management
        Task<List<Machine>> GetMachinesAsync();
        Task<Machine?> GetMachineByIdAsync(int machineId);
        Task<List<MaintenanceRecord>> GetMaintenanceRecordsAsync(int machineId);
        Task<MaintenanceRecord> CreateMaintenanceRecordAsync(MaintenanceRecord record);

        // Vehicle Management
        Task<List<Vehicle>> GetVehiclesAsync();
        Task<Vehicle?> GetVehicleByIdAsync(int vehicleId);
        Task<Vehicle> UpdateVehicleAsync(Vehicle vehicle);
        Task<List<Vehicle>> GetAvailableVehiclesAsync();

        // Delivery Management
        Task<List<Delivery>> GetDeliveriesAsync();
        Task<Delivery?> GetDeliveryByIdAsync(int deliveryId);
        Task<Delivery> CreateDeliveryAsync(Delivery delivery);
        Task<Delivery> UpdateDeliveryAsync(Delivery delivery);
        Task<List<Delivery>> GetScheduledDeliveriesAsync();

        // Customer Management
        Task<List<Customer>> GetCustomersAsync();
        Task<Customer?> GetCustomerByIdAsync(int customerId);

        // Supplier Management
        Task<List<Supplier>> GetSuppliersAsync();
        Task<Supplier?> GetSupplierByIdAsync(int supplierId);
    }

    /// <summary>
    /// Demo implementation of Manager Data Service
    /// Replace with actual database implementation
    /// </summary>
    public class ManagerDataService : IManagerDataService
    {
        // Demo data - replace with actual database context
        private static List<Employee> _employees = new();
        private static List<Product> _products = new();
        private static List<RawMaterial> _rawMaterials = new();
        private static List<StockEntry> _stockEntries = new();
        private static List<Deal> _deals = new();
        private static List<SalesOrder> _salesOrders = new();
        private static List<Machine> _machines = new();
        private static List<MaintenanceRecord> _maintenanceRecords = new();
        private static List<Vehicle> _vehicles = new();
        private static List<Delivery> _deliveries = new();
        private static List<Customer> _customers = new();
        private static List<Supplier> _suppliers = new();

        static ManagerDataService()
        {
            // Initialize with demo data
            InitializeDemoData();
        }

        #region Employee Management
        public async Task<List<Employee>> GetEmployeesAsync(int managerId)
        {
            await Task.Delay(100); // Simulate async operation
            return _employees.Where(e => e.ManagerId == managerId || managerId == 0).ToList();
        }

        public async Task<Employee?> GetEmployeeByIdAsync(int employeeId)
        {
            await Task.Delay(50);
            return _employees.FirstOrDefault(e => e.EmployeeId == employeeId);
        }

        public async Task<Employee> CreateEmployeeAsync(Employee employee)
        {
            await Task.Delay(100);
            employee.EmployeeId = _employees.Count + 1;
            _employees.Add(employee);
            return employee;
        }

        public async Task<Employee> UpdateEmployeeAsync(Employee employee)
        {
            await Task.Delay(100);
            var existing = _employees.FirstOrDefault(e => e.EmployeeId == employee.EmployeeId);
            if (existing != null)
            {
                var index = _employees.IndexOf(existing);
                _employees[index] = employee;
            }
            return employee;
        }

        public async Task<bool> DeleteEmployeeAsync(int employeeId)
        {
            await Task.Delay(100);
            var employee = _employees.FirstOrDefault(e => e.EmployeeId == employeeId);
            if (employee != null)
            {
                employee.IsActive = false;
                return true;
            }
            return false;
        }
        #endregion

        #region Product Management
        public async Task<List<Product>> GetProductsAsync()
        {
            await Task.Delay(100);
            return _products.Where(p => p.IsActive).ToList();
        }

        public async Task<Product?> GetProductByIdAsync(int productId)
        {
            await Task.Delay(50);
            return _products.FirstOrDefault(p => p.ProductId == productId);
        }

        public async Task<Product> CreateProductAsync(Product product)
        {
            await Task.Delay(100);
            product.ProductId = _products.Count + 1;
            product.CreatedDate = DateTime.Now;
            _products.Add(product);
            return product;
        }

        public async Task<Product> UpdateProductAsync(Product product)
        {
            await Task.Delay(100);
            var existing = _products.FirstOrDefault(p => p.ProductId == product.ProductId);
            if (existing != null)
            {
                product.LastModified = DateTime.Now;
                var index = _products.IndexOf(existing);
                _products[index] = product;
            }
            return product;
        }

        public async Task<bool> DeleteProductAsync(int productId)
        {
            await Task.Delay(100);
            var product = _products.FirstOrDefault(p => p.ProductId == productId);
            if (product != null)
            {
                product.IsActive = false;
                return true;
            }
            return false;
        }
        #endregion

        #region Raw Materials Management
        public async Task<List<RawMaterial>> GetRawMaterialsAsync()
        {
            await Task.Delay(100);
            return _rawMaterials.Where(rm => rm.IsActive).ToList();
        }

        public async Task<RawMaterial?> GetRawMaterialByIdAsync(int materialId)
        {
            await Task.Delay(50);
            return _rawMaterials.FirstOrDefault(rm => rm.MaterialId == materialId);
        }

        public async Task<RawMaterial> CreateRawMaterialAsync(RawMaterial material)
        {
            await Task.Delay(100);
            material.MaterialId = _rawMaterials.Count + 1;
            _rawMaterials.Add(material);
            return material;
        }

        public async Task<RawMaterial> UpdateRawMaterialAsync(RawMaterial material)
        {
            await Task.Delay(100);
            var existing = _rawMaterials.FirstOrDefault(rm => rm.MaterialId == material.MaterialId);
            if (existing != null)
            {
                var index = _rawMaterials.IndexOf(existing);
                _rawMaterials[index] = material;
            }
            return material;
        }

        public async Task<bool> DeleteRawMaterialAsync(int materialId)
        {
            await Task.Delay(100);
            var material = _rawMaterials.FirstOrDefault(rm => rm.MaterialId == materialId);
            if (material != null)
            {
                material.IsActive = false;
                return true;
            }
            return false;
        }
        #endregion

        #region Stock Management
        public async Task<List<StockEntry>> GetStockEntriesAsync()
        {
            await Task.Delay(100);
            return _stockEntries.OrderByDescending(se => se.TransactionDate).ToList();
        }

        public async Task<StockEntry> CreateStockEntryAsync(StockEntry entry)
        {
            await Task.Delay(100);
            entry.StockEntryId = _stockEntries.Count + 1;
            entry.TransactionDate = DateTime.Now;
            _stockEntries.Add(entry);
            return entry;
        }

        public async Task<List<Product>> GetLowStockProductsAsync()
        {
            await Task.Delay(100);
            return _products.Where(p => p.IsActive && p.StockQuantity <= p.MinimumStock).ToList();
        }
        #endregion

        #region Deal Management
        public async Task<List<Deal>> GetPendingDealsAsync()
        {
            await Task.Delay(100);
            return _deals.Where(d => d.Status == "Pending").ToList();
        }

        public async Task<Deal?> GetDealByIdAsync(int dealId)
        {
            await Task.Delay(50);
            return _deals.FirstOrDefault(d => d.DealId == dealId);
        }

        public async Task<bool> ApproveDealAsync(int dealId, int approvedBy, string notes)
        {
            await Task.Delay(100);
            var deal = _deals.FirstOrDefault(d => d.DealId == dealId);
            if (deal != null)
            {
                deal.Status = "Approved";
                deal.ApprovedBy = approvedBy;
                deal.ApprovedDate = DateTime.Now;
                deal.ApprovalNotes = notes;
                return true;
            }
            return false;
        }

        public async Task<bool> RejectDealAsync(int dealId, int rejectedBy, string notes)
        {
            await Task.Delay(100);
            var deal = _deals.FirstOrDefault(d => d.DealId == dealId);
            if (deal != null)
            {
                deal.Status = "Rejected";
                deal.ApprovedBy = rejectedBy;
                deal.ApprovedDate = DateTime.Now;
                deal.ApprovalNotes = notes;
                return true;
            }
            return false;
        }
        #endregion

        #region Sales Orders Management
        public async Task<List<SalesOrder>> GetSalesOrdersAsync()
        {
            await Task.Delay(100);
            return _salesOrders.OrderByDescending(so => so.OrderDate).ToList();
        }

        public async Task<SalesOrder?> GetSalesOrderByIdAsync(int orderId)
        {
            await Task.Delay(50);
            return _salesOrders.FirstOrDefault(so => so.OrderId == orderId);
        }

        public async Task<SalesOrder> CreateSalesOrderAsync(SalesOrder order)
        {
            await Task.Delay(100);
            order.OrderId = _salesOrders.Count + 1;
            order.OrderDate = DateTime.Now;
            _salesOrders.Add(order);
            return order;
        }

        public async Task<SalesOrder> UpdateSalesOrderAsync(SalesOrder order)
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
        #endregion

        #region Machinery Management
        public async Task<List<Machine>> GetMachinesAsync()
        {
            await Task.Delay(100);
            return _machines.ToList();
        }

        public async Task<Machine?> GetMachineByIdAsync(int machineId)
        {
            await Task.Delay(50);
            return _machines.FirstOrDefault(m => m.MachineId == machineId);
        }

        public async Task<List<MaintenanceRecord>> GetMaintenanceRecordsAsync(int machineId)
        {
            await Task.Delay(100);
            return _maintenanceRecords.Where(mr => mr.MachineId == machineId)
                                    .OrderByDescending(mr => mr.MaintenanceDate).ToList();
        }

        public async Task<MaintenanceRecord> CreateMaintenanceRecordAsync(MaintenanceRecord record)
        {
            await Task.Delay(100);
            record.MaintenanceId = _maintenanceRecords.Count + 1;
            _maintenanceRecords.Add(record);
            return record;
        }
        #endregion

        #region Vehicle Management
        public async Task<List<Vehicle>> GetVehiclesAsync()
        {
            await Task.Delay(100);
            return _vehicles.ToList();
        }

        public async Task<Vehicle?> GetVehicleByIdAsync(int vehicleId)
        {
            await Task.Delay(50);
            return _vehicles.FirstOrDefault(v => v.VehicleId == vehicleId);
        }

        public async Task<Vehicle> UpdateVehicleAsync(Vehicle vehicle)
        {
            await Task.Delay(100);
            var existing = _vehicles.FirstOrDefault(v => v.VehicleId == vehicle.VehicleId);
            if (existing != null)
            {
                var index = _vehicles.IndexOf(existing);
                _vehicles[index] = vehicle;
            }
            return vehicle;
        }

        public async Task<List<Vehicle>> GetAvailableVehiclesAsync()
        {
            await Task.Delay(100);
            return _vehicles.Where(v => v.Status == "Available").ToList();
        }
        #endregion

        #region Delivery Management
        public async Task<List<Delivery>> GetDeliveriesAsync()
        {
            await Task.Delay(100);
            return _deliveries.OrderByDescending(d => d.ScheduledDate).ToList();
        }

        public async Task<Delivery?> GetDeliveryByIdAsync(int deliveryId)
        {
            await Task.Delay(50);
            return _deliveries.FirstOrDefault(d => d.DeliveryId == deliveryId);
        }

        public async Task<Delivery> CreateDeliveryAsync(Delivery delivery)
        {
            await Task.Delay(100);
            delivery.DeliveryId = _deliveries.Count + 1;
            _deliveries.Add(delivery);
            return delivery;
        }

        public async Task<Delivery> UpdateDeliveryAsync(Delivery delivery)
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

        public async Task<List<Delivery>> GetScheduledDeliveriesAsync()
        {
            await Task.Delay(100);
            return _deliveries.Where(d => d.Status == "Scheduled").ToList();
        }
        #endregion

        #region Customer and Supplier Management
        public async Task<List<Customer>> GetCustomersAsync()
        {
            await Task.Delay(100);
            return _customers.Where(c => c.IsActive).ToList();
        }

        public async Task<Customer?> GetCustomerByIdAsync(int customerId)
        {
            await Task.Delay(50);
            return _customers.FirstOrDefault(c => c.CustomerId == customerId);
        }

        public async Task<List<Supplier>> GetSuppliersAsync()
        {
            await Task.Delay(100);
            return _suppliers.Where(s => s.IsActive).ToList();
        }

        public async Task<Supplier?> GetSupplierByIdAsync(int supplierId)
        {
            await Task.Delay(50);
            return _suppliers.FirstOrDefault(s => s.SupplierId == supplierId);
        }
        #endregion

        #region Demo Data Initialization
        private static void InitializeDemoData()
        {
            // Sample Employees
            _employees.AddRange(new[]
            {
                new Employee { EmployeeId = 1, FirstName = "John", LastName = "Smith", EmployeeNumber = "EMP001", Department = "Production", Position = "Supervisor", Email = "john.smith@factory.com", PhoneNumber = "555-0101", HireDate = DateTime.Now.AddYears(-2), Salary = 65000, IsActive = true, ManagerId = 1 },
                new Employee { EmployeeId = 2, FirstName = "Sarah", LastName = "Johnson", EmployeeNumber = "EMP002", Department = "Quality Control", Position = "Inspector", Email = "sarah.johnson@factory.com", PhoneNumber = "555-0102", HireDate = DateTime.Now.AddYears(-1), Salary = 55000, IsActive = true, ManagerId = 1 },
                new Employee { EmployeeId = 3, FirstName = "Mike", LastName = "Davis", EmployeeNumber = "EMP003", Department = "Maintenance", Position = "Technician", Email = "mike.davis@factory.com", PhoneNumber = "555-0103", HireDate = DateTime.Now.AddMonths(-6), Salary = 50000, IsActive = true, ManagerId = 1 }
            });

            // Sample Products
            _products.AddRange(new[]
            {
                new Product { ProductId = 1, ProductName = "A4 Copy Paper", ProductCode = "PP001", Description = "High quality white copy paper", Category = "Office Paper", UnitPrice = 5.99m, StockQuantity = 1500, MinimumStock = 200, IsActive = true },
                new Product { ProductId = 2, ProductName = "Cardboard Boxes", ProductCode = "CB001", Description = "Corrugated cardboard boxes", Category = "Packaging", UnitPrice = 2.50m, StockQuantity = 800, MinimumStock = 100, IsActive = true },
                new Product { ProductId = 3, ProductName = "Tissue Paper", ProductCode = "TP001", Description = "Soft facial tissue", Category = "Consumer Paper", UnitPrice = 1.99m, StockQuantity = 50, MinimumStock = 100, IsActive = true }
            });

            // Sample Raw Materials
            _rawMaterials.AddRange(new[]
            {
                new RawMaterial { MaterialId = 1, MaterialName = "Wood Pulp", MaterialCode = "WP001", Unit = "tons", UnitCost = 450.00m, CurrentStock = 25.5, MinimumStock = 10.0, SupplierId = 1, IsActive = true },
                new RawMaterial { MaterialId = 2, MaterialName = "Recycled Paper", MaterialCode = "RP001", Unit = "tons", UnitCost = 320.00m, CurrentStock = 15.2, MinimumStock = 8.0, SupplierId = 2, IsActive = true }
            });

            // Sample Deals
            _deals.AddRange(new[]
            {
                new Deal { DealId = 1, DealTitle = "Office Supply Contract", DealNumber = "D001", CustomerId = 1, DealValue = 25000.00m, Status = "Pending", Description = "Annual office paper supply contract", CreatedDate = DateTime.Now.AddDays(-5) },
                new Deal { DealId = 2, DealTitle = "Packaging Materials", DealNumber = "D002", CustomerId = 2, DealValue = 15000.00m, Status = "Pending", Description = "Bulk cardboard order", CreatedDate = DateTime.Now.AddDays(-3) }
            });

            // Sample Customers
            _customers.AddRange(new[]
            {
                new Customer { CustomerId = 1, CompanyName = "ABC Corporation", ContactPerson = "Robert Wilson", Email = "rwilson@abccorp.com", PhoneNumber = "555-1001", Address = "123 Business St, City, State", IsActive = true },
                new Customer { CustomerId = 2, CompanyName = "XYZ Industries", ContactPerson = "Lisa Brown", Email = "lbrown@xyzind.com", PhoneNumber = "555-1002", Address = "456 Industrial Ave, City, State", IsActive = true }
            });

            // Sample Suppliers
            _suppliers.AddRange(new[]
            {
                new Supplier { SupplierId = 1, CompanyName = "Forest Products Inc", ContactPerson = "Tom Green", Email = "tgreen@forestprod.com", PhoneNumber = "555-2001", Address = "789 Forest Rd, City, State", IsActive = true },
                new Supplier { SupplierId = 2, CompanyName = "Recycle Materials Ltd", ContactPerson = "Amy White", Email = "awhite@recycle.com", PhoneNumber = "555-2002", Address = "321 Recycle Blvd, City, State", IsActive = true }
            });
        }
        #endregion
    }
}