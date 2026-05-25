using System;
using System.ComponentModel;
using System.Runtime.CompilerServices;

namespace FactoryManagmentSystem.Models
{
    // ================================================================================
    // STOCK USAGE INFO MODEL
    // ================================================================================
    public class StockUsageInfo : INotifyPropertyChanged
    {
        private int _stockUsageID;
        private int _employeeID;
        private string _employeeName;
        private int _productionOrderID;
        private int _orderNumber;
        private int _rawMaterialID;
        private string _materialName;
        private string _materialCategory;
        private string _unit;
        private decimal _quantityUsed;
        private decimal _totalCost;
        private DateTime _usageDate;
        private string _notes;

        public int StockUsageID
        {
            get => _stockUsageID;
            set { _stockUsageID = value; OnPropertyChanged(); }
        }

        public int EmployeeID
        {
            get => _employeeID;
            set { _employeeID = value; OnPropertyChanged(); }
        }

        public string EmployeeName
        {
            get => _employeeName;
            set { _employeeName = value; OnPropertyChanged(); }
        }

        public int ProductionOrderID
        {
            get => _productionOrderID;
            set { _productionOrderID = value; OnPropertyChanged(); }
        }

        public int OrderNumber
        {
            get => _orderNumber;
            set { _orderNumber = value; OnPropertyChanged(); }
        }

        public int RawMaterialID
        {
            get => _rawMaterialID;
            set { _rawMaterialID = value; OnPropertyChanged(); }
        }

        public string MaterialName
        {
            get => _materialName;
            set { _materialName = value; OnPropertyChanged(); }
        }

        public string MaterialCategory
        {
            get => _materialCategory;
            set { _materialCategory = value; OnPropertyChanged(); }
        }

        public string Unit
        {
            get => _unit;
            set { _unit = value; OnPropertyChanged(); }
        }

        public decimal QuantityUsed
        {
            get => _quantityUsed;
            set { _quantityUsed = value; OnPropertyChanged(); OnPropertyChanged(nameof(QuantityUsedFormatted)); }
        }

        public decimal TotalCost
        {
            get => _totalCost;
            set { _totalCost = value; OnPropertyChanged(); OnPropertyChanged(nameof(TotalCostFormatted)); }
        }

        public DateTime UsageDate
        {
            get => _usageDate;
            set { _usageDate = value; OnPropertyChanged(); OnPropertyChanged(nameof(UsageDateFormatted)); }
        }

        public string Notes
        {
            get => _notes;
            set { _notes = value; OnPropertyChanged(); }
        }

        // Formatted Properties for Display
        public string QuantityUsedFormatted => $"{QuantityUsed:N2} {Unit}";
        public string TotalCostFormatted => $"Rs. {TotalCost:N2}";
        public string UsageDateFormatted => UsageDate.ToString("dd MMM yyyy");

        public event PropertyChangedEventHandler PropertyChanged;
        protected void OnPropertyChanged([CallerMemberName] string propertyName = null)
        {
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
        }
    }

    // ================================================================================
    // STOCK USAGE STATISTICS MODEL
    // ================================================================================
    public class StockUsageStatistics : INotifyPropertyChanged
    {
        private int _totalUsageRecords;
        private int _totalTailorsUsed;
        private int _totalOrdersWithUsage;
        private int _totalMaterialsUsed;
        private decimal _totalCostOfMaterialsUsed;
        private decimal _averageCostPerUsage;

        public int TotalUsageRecords
        {
            get => _totalUsageRecords;
            set { _totalUsageRecords = value; OnPropertyChanged(); }
        }

        public int TotalTailorsUsed
        {
            get => _totalTailorsUsed;
            set { _totalTailorsUsed = value; OnPropertyChanged(); }
        }

        public int TotalOrdersWithUsage
        {
            get => _totalOrdersWithUsage;
            set { _totalOrdersWithUsage = value; OnPropertyChanged(); }
        }

        public int TotalMaterialsUsed
        {
            get => _totalMaterialsUsed;
            set { _totalMaterialsUsed = value; OnPropertyChanged(); }
        }

        public decimal TotalCostOfMaterialsUsed
        {
            get => _totalCostOfMaterialsUsed;
            set { _totalCostOfMaterialsUsed = value; OnPropertyChanged(); OnPropertyChanged(nameof(TotalCostFormatted)); }
        }

        public decimal AverageCostPerUsage
        {
            get => _averageCostPerUsage;
            set { _averageCostPerUsage = value; OnPropertyChanged(); OnPropertyChanged(nameof(AverageCostFormatted)); }
        }

        // Formatted Properties for Display
        public string TotalCostFormatted => $"Rs. {TotalCostOfMaterialsUsed:N2}";
        public string AverageCostFormatted => $"Rs. {AverageCostPerUsage:N2}";

        public event PropertyChangedEventHandler PropertyChanged;
        protected void OnPropertyChanged([CallerMemberName] string propertyName = null)
        {
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
        }
    }

    // ================================================================================
    // MATERIAL AVAILABILITY MODEL
    // ================================================================================
    public class MaterialAvailability : INotifyPropertyChanged
    {
        private int _rawMaterialID;
        private string _materialName;
        private string _category;
        private string _unit;
        private decimal _availableQuantity;
        private decimal _requiredQuantity;
        private string _availabilityStatus;
        private decimal _quantityDifference;
        private string _supplier;
        private string _supplierContact;

        public int RawMaterialID
        {
            get => _rawMaterialID;
            set { _rawMaterialID = value; OnPropertyChanged(); }
        }

        public string MaterialName
        {
            get => _materialName;
            set { _materialName = value; OnPropertyChanged(); }
        }

        public string Category
        {
            get => _category;
            set { _category = value; OnPropertyChanged(); }
        }

        public string Unit
        {
            get => _unit;
            set { _unit = value; OnPropertyChanged(); }
        }

        public decimal AvailableQuantity
        {
            get => _availableQuantity;
            set { _availableQuantity = value; OnPropertyChanged(); OnPropertyChanged(nameof(AvailableQuantityFormatted)); }
        }

        public decimal RequiredQuantity
        {
            get => _requiredQuantity;
            set { _requiredQuantity = value; OnPropertyChanged(); OnPropertyChanged(nameof(RequiredQuantityFormatted)); }
        }

        public string AvailabilityStatus
        {
            get => _availabilityStatus;
            set { _availabilityStatus = value; OnPropertyChanged(); }
        }

        public decimal QuantityDifference
        {
            get => _quantityDifference;
            set { _quantityDifference = value; OnPropertyChanged(); OnPropertyChanged(nameof(QuantityDifferenceFormatted)); }
        }

        public string Supplier
        {
            get => _supplier;
            set { _supplier = value; OnPropertyChanged(); }
        }

        public string SupplierContact
        {
            get => _supplierContact;
            set { _supplierContact = value; OnPropertyChanged(); }
        }

        // Formatted Properties for Display
        public string AvailableQuantityFormatted => $"{AvailableQuantity:N2} {Unit}";
        public string RequiredQuantityFormatted => $"{RequiredQuantity:N2} {Unit}";
        public string QuantityDifferenceFormatted => $"{QuantityDifference:N2} {Unit}";

        public bool IsAvailable => AvailabilityStatus == "Available";
        public bool IsInsufficient => AvailabilityStatus == "Insufficient";
        public bool IsOutOfStock => AvailabilityStatus == "Out of Stock";

        public event PropertyChangedEventHandler PropertyChanged;
        protected void OnPropertyChanged([CallerMemberName] string propertyName = null)
        {
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
        }
    }
}
