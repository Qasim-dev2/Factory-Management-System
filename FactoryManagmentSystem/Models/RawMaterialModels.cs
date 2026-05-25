using System;
using System.ComponentModel;
using System.Runtime.CompilerServices;

namespace FactoryManagmentSystem.Models
{
    // ================================================================================
    // RAW MATERIAL MODEL - Matches RawMaterial Table Structure
    // ================================================================================
    public class RawMaterialInfo : INotifyPropertyChanged
    {
        private int _rawMaterialID;
        private string _materialName;
        private string _category;
        private string _unit;
        private decimal _quantity;
        private decimal _minimumStock;
        private decimal _unitPrice;
        private string _supplier;
        private string _supplierContact;
        private string _description;
        private string _stockStatus;
        private decimal _totalValue;
        private DateTime? _lastRestockDate;
        private bool _isActive;
        private DateTime _createdDate;
        private DateTime? _updatedDate;

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

        public decimal Quantity
        {
            get => _quantity;
            set 
            { 
                _quantity = value; 
                OnPropertyChanged();
                OnPropertyChanged(nameof(FormattedQuantity));
            }
        }

        public decimal MinimumStock
        {
            get => _minimumStock;
            set { _minimumStock = value; OnPropertyChanged(); }
        }

        public decimal UnitPrice
        {
            get => _unitPrice;
            set 
            { 
                _unitPrice = value; 
                OnPropertyChanged();
                OnPropertyChanged(nameof(FormattedUnitPrice));
            }
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

        public string Description
        {
            get => _description;
            set { _description = value; OnPropertyChanged(); }
        }

        public string StockStatus
        {
            get => _stockStatus;
            set { _stockStatus = value; OnPropertyChanged(); }
        }

        public decimal TotalValue
        {
            get => _totalValue;
            set 
            { 
                _totalValue = value; 
                OnPropertyChanged();
                OnPropertyChanged(nameof(FormattedTotalValue));
            }
        }

        public DateTime? LastRestockDate
        {
            get => _lastRestockDate;
            set 
            { 
                _lastRestockDate = value; 
                OnPropertyChanged();
                OnPropertyChanged(nameof(FormattedLastRestockDate));
            }
        }

        public bool IsActive
        {
            get => _isActive;
            set { _isActive = value; OnPropertyChanged(); }
        }

        public DateTime CreatedDate
        {
            get => _createdDate;
            set { _createdDate = value; OnPropertyChanged(); }
        }

        public DateTime? UpdatedDate
        {
            get => _updatedDate;
            set { _updatedDate = value; OnPropertyChanged(); }
        }

        // Formatted properties for UI display
        public string FormattedQuantity => $"{Quantity:N2} {Unit}";
        public string FormattedUnitPrice => $"Rs. {UnitPrice:N2}";
        public string FormattedTotalValue => $"Rs. {TotalValue:N2}";
        public string FormattedLastRestockDate => LastRestockDate?.ToString("yyyy-MM-dd") ?? "Never";

        // INotifyPropertyChanged implementation
        public event PropertyChangedEventHandler PropertyChanged;

        protected void OnPropertyChanged([CallerMemberName] string propertyName = null)
        {
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
        }
    }

    // ================================================================================
    // RAW MATERIAL STATISTICS MODEL - For Dashboard
    // ================================================================================
    public class RawMaterialStatistics
    {
        public int TotalMaterials { get; set; }
        public int OutOfStockCount { get; set; }
        public int LowStockCount { get; set; }
        public int InStockCount { get; set; }
        public decimal TotalStockValue { get; set; }
        public decimal AverageUnitPrice { get; set; }
        public int TotalCategories { get; set; }
        public int TotalSuppliers { get; set; }

        // Formatted properties
        public string FormattedTotalStockValue => $"Rs. {TotalStockValue:N2}";
        public string FormattedAverageUnitPrice => $"Rs. {AverageUnitPrice:N2}";
    }
}
