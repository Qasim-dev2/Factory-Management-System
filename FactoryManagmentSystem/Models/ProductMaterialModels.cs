using System;
using System.ComponentModel;

namespace FactoryManagmentSystem.Models
{
    /// <summary>
    /// Product Material Requirement - Bill of Materials (BOM)
    /// Defines which raw materials are needed for each product
    /// </summary>
    public class ProductMaterialRequirement : INotifyPropertyChanged
    {
        private int _requirementID;
        private int _productID;
        private string _productName;
        private int _rawMaterialID;
        private string _materialName;
        private string _materialCategory;
        private decimal _quantityRequired;
        private string _unit;
        private decimal _materialUnitPrice;
        private decimal _totalMaterialCost;
        private decimal _availableStock;
        private string _stockStatus;
        private string _notes;
        private DateTime _createdDate;
        private DateTime _updatedDate;

        public int RequirementID
        {
            get => _requirementID;
            set { _requirementID = value; OnPropertyChanged(nameof(RequirementID)); }
        }

        public int ProductID
        {
            get => _productID;
            set { _productID = value; OnPropertyChanged(nameof(ProductID)); }
        }

        public string ProductName
        {
            get => _productName;
            set { _productName = value; OnPropertyChanged(nameof(ProductName)); }
        }

        public int RawMaterialID
        {
            get => _rawMaterialID;
            set { _rawMaterialID = value; OnPropertyChanged(nameof(RawMaterialID)); }
        }

        public string MaterialName
        {
            get => _materialName;
            set { _materialName = value; OnPropertyChanged(nameof(MaterialName)); }
        }

        public string MaterialCategory
        {
            get => _materialCategory;
            set { _materialCategory = value; OnPropertyChanged(nameof(MaterialCategory)); }
        }

        public decimal QuantityRequired
        {
            get => _quantityRequired;
            set { _quantityRequired = value; OnPropertyChanged(nameof(QuantityRequired)); OnPropertyChanged(nameof(QuantityRequiredFormatted)); }
        }

        public string Unit
        {
            get => _unit;
            set { _unit = value; OnPropertyChanged(nameof(Unit)); }
        }

        public decimal MaterialUnitPrice
        {
            get => _materialUnitPrice;
            set { _materialUnitPrice = value; OnPropertyChanged(nameof(MaterialUnitPrice)); }
        }

        public decimal TotalMaterialCost
        {
            get => _totalMaterialCost;
            set { _totalMaterialCost = value; OnPropertyChanged(nameof(TotalMaterialCost)); OnPropertyChanged(nameof(TotalMaterialCostFormatted)); }
        }

        public decimal AvailableStock
        {
            get => _availableStock;
            set { _availableStock = value; OnPropertyChanged(nameof(AvailableStock)); OnPropertyChanged(nameof(AvailableStockFormatted)); }
        }

        public string StockStatus
        {
            get => _stockStatus;
            set { _stockStatus = value; OnPropertyChanged(nameof(StockStatus)); }
        }

        public string Notes
        {
            get => _notes;
            set { _notes = value; OnPropertyChanged(nameof(Notes)); }
        }

        public DateTime CreatedDate
        {
            get => _createdDate;
            set { _createdDate = value; OnPropertyChanged(nameof(CreatedDate)); }
        }

        public DateTime UpdatedDate
        {
            get => _updatedDate;
            set { _updatedDate = value; OnPropertyChanged(nameof(UpdatedDate)); }
        }

        // Formatted Properties for Display
        public string QuantityRequiredFormatted => $"{QuantityRequired:N2} {Unit}";
        public string TotalMaterialCostFormatted => $"Rs. {TotalMaterialCost:N2}";
        public string AvailableStockFormatted => $"{AvailableStock:N2} {Unit}";

        public event PropertyChangedEventHandler PropertyChanged;
        protected void OnPropertyChanged(string propertyName)
        {
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
        }
    }

    /// <summary>
    /// Material requirements calculation for production orders
    /// Shows how much of each material is needed and if it's available
    /// </summary>
    public class ProductionMaterialRequirement : INotifyPropertyChanged
    {
        private int _rawMaterialID;
        private string _materialName;
        private string _category;
        private string _unit;
        private decimal _quantityPerUnit;
        private decimal _totalQuantityRequired;
        private decimal _availableStock;
        private string _stockStatus;
        private decimal _stockBalanceAfterProduction;
        private decimal _unitPrice;
        private decimal _totalMaterialCost;

        public int RawMaterialID
        {
            get => _rawMaterialID;
            set { _rawMaterialID = value; OnPropertyChanged(nameof(RawMaterialID)); }
        }

        public string MaterialName
        {
            get => _materialName;
            set { _materialName = value; OnPropertyChanged(nameof(MaterialName)); }
        }

        public string Category
        {
            get => _category;
            set { _category = value; OnPropertyChanged(nameof(Category)); }
        }

        public string Unit
        {
            get => _unit;
            set { _unit = value; OnPropertyChanged(nameof(Unit)); }
        }

        public decimal QuantityPerUnit
        {
            get => _quantityPerUnit;
            set { _quantityPerUnit = value; OnPropertyChanged(nameof(QuantityPerUnit)); OnPropertyChanged(nameof(QuantityPerUnitFormatted)); }
        }

        public decimal TotalQuantityRequired
        {
            get => _totalQuantityRequired;
            set { _totalQuantityRequired = value; OnPropertyChanged(nameof(TotalQuantityRequired)); OnPropertyChanged(nameof(TotalQuantityRequiredFormatted)); }
        }

        public decimal AvailableStock
        {
            get => _availableStock;
            set { _availableStock = value; OnPropertyChanged(nameof(AvailableStock)); OnPropertyChanged(nameof(AvailableStockFormatted)); }
        }

        public string StockStatus
        {
            get => _stockStatus;
            set { _stockStatus = value; OnPropertyChanged(nameof(StockStatus)); }
        }

        public decimal StockBalanceAfterProduction
        {
            get => _stockBalanceAfterProduction;
            set { _stockBalanceAfterProduction = value; OnPropertyChanged(nameof(StockBalanceAfterProduction)); OnPropertyChanged(nameof(StockBalanceFormatted)); }
        }

        public decimal UnitPrice
        {
            get => _unitPrice;
            set { _unitPrice = value; OnPropertyChanged(nameof(UnitPrice)); }
        }

        public decimal TotalMaterialCost
        {
            get => _totalMaterialCost;
            set { _totalMaterialCost = value; OnPropertyChanged(nameof(TotalMaterialCost)); OnPropertyChanged(nameof(TotalMaterialCostFormatted)); }
        }

        // Formatted Properties
        public string QuantityPerUnitFormatted => $"{QuantityPerUnit:N2} {Unit}";
        public string TotalQuantityRequiredFormatted => $"{TotalQuantityRequired:N2} {Unit}";
        public string AvailableStockFormatted => $"{AvailableStock:N2} {Unit}";
        public string StockBalanceFormatted => $"{StockBalanceAfterProduction:N2} {Unit}";
        public string TotalMaterialCostFormatted => $"Rs. {TotalMaterialCost:N2}";

        // Status Flags
        public bool IsSufficient => StockStatus == "Sufficient";
        public bool IsInsufficient => StockStatus?.Contains("Insufficient") == true;
        public bool IsOutOfStock => StockStatus?.Contains("Out of Stock") == true;

        public event PropertyChangedEventHandler PropertyChanged;
        protected void OnPropertyChanged(string propertyName)
        {
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
        }
    }

    /// <summary>
    /// Material availability check result
    /// Used to verify if production order can be started
    /// </summary>
    public class MaterialAvailabilityInfo : INotifyPropertyChanged
    {
        private int _rawMaterialID;
        private string _materialName;
        private decimal _requiredQuantity;
        private decimal _availableStock;
        private bool _isAvailable;

        public int RawMaterialID
        {
            get => _rawMaterialID;
            set { _rawMaterialID = value; OnPropertyChanged(nameof(RawMaterialID)); }
        }

        public string MaterialName
        {
            get => _materialName;
            set { _materialName = value; OnPropertyChanged(nameof(MaterialName)); }
        }

        public decimal RequiredQuantity
        {
            get => _requiredQuantity;
            set { _requiredQuantity = value; OnPropertyChanged(nameof(RequiredQuantity)); OnPropertyChanged(nameof(RequiredQuantityFormatted)); }
        }

        public decimal AvailableStock
        {
            get => _availableStock;
            set { _availableStock = value; OnPropertyChanged(nameof(AvailableStock)); OnPropertyChanged(nameof(AvailableStockFormatted)); }
        }

        public bool IsAvailable
        {
            get => _isAvailable;
            set { _isAvailable = value; OnPropertyChanged(nameof(IsAvailable)); OnPropertyChanged(nameof(StatusText)); }
        }

        // Formatted Properties
        public string RequiredQuantityFormatted => $"{RequiredQuantity:N2}";
        public string AvailableStockFormatted => $"{AvailableStock:N2}";
        public string StatusText => IsAvailable ? "✓ Available" : "✗ Insufficient";
        public decimal Shortage => RequiredQuantity - AvailableStock;
        public string ShortageFormatted => Shortage > 0 ? $"Need {Shortage:N2} more" : "Sufficient";

        public event PropertyChangedEventHandler PropertyChanged;
        protected void OnPropertyChanged(string propertyName)
        {
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
        }
    }
}
