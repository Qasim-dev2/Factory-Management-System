using System;
using System.ComponentModel;
using System.Runtime.CompilerServices;

namespace FactoryManagmentSystem.Models
{
    public class Stock : INotifyPropertyChanged
    {
        private int _stockId;
        private int _productId;
        private string _batchNo = string.Empty;
        private DateTime _entryDate;
        private int _quantity;
        private string _stockStatus = "Ready";
        private int _progressPercentage = 100;
        private string? _location;
        private string? _notes;
        private int? _createdBy;
        private DateTime _lastUpdated;
        private DateTime _createdDate;
        
        // Product details (for display)
        private string _productName = string.Empty;
        private string _category = string.Empty;
        private string? _sku;

        public int StockId
        {
            get => _stockId;
            set { _stockId = value; OnPropertyChanged(); }
        }

        public int ProductId
        {
            get => _productId;
            set { _productId = value; OnPropertyChanged(); }
        }

        public string BatchNo
        {
            get => _batchNo;
            set { _batchNo = value; OnPropertyChanged(); }
        }

        public DateTime EntryDate
        {
            get => _entryDate;
            set { _entryDate = value; OnPropertyChanged(); }
        }

        public int Quantity
        {
            get => _quantity;
            set { _quantity = value; OnPropertyChanged(); OnPropertyChanged(nameof(QuantityDisplay)); }
        }

        public string StockStatus
        {
            get => _stockStatus;
            set { _stockStatus = value; OnPropertyChanged(); OnPropertyChanged(nameof(StatusDisplay)); OnPropertyChanged(nameof(StatusColor)); }
        }

        public int ProgressPercentage
        {
            get => _progressPercentage;
            set { _progressPercentage = value; OnPropertyChanged(); OnPropertyChanged(nameof(ProgressDisplay)); }
        }

        public string? Location
        {
            get => _location;
            set { _location = value; OnPropertyChanged(); }
        }

        public string? Notes
        {
            get => _notes;
            set { _notes = value; OnPropertyChanged(); }
        }

        public int? CreatedBy
        {
            get => _createdBy;
            set { _createdBy = value; OnPropertyChanged(); }
        }

        public DateTime LastUpdated
        {
            get => _lastUpdated;
            set { _lastUpdated = value; OnPropertyChanged(); }
        }

        public DateTime CreatedDate
        {
            get => _createdDate;
            set { _createdDate = value; OnPropertyChanged(); }
        }

        // Product Display Properties
        public string ProductName
        {
            get => _productName;
            set { _productName = value; OnPropertyChanged(); }
        }

        public string Category
        {
            get => _category;
            set { _category = value; OnPropertyChanged(); }
        }

        public string? SKU
        {
            get => _sku;
            set { _sku = value; OnPropertyChanged(); }
        }

        // Computed Properties for UI Display
        public string QuantityDisplay => $"{Quantity} units";

        public string StatusDisplay => StockStatus switch
        {
            "Ready" => "Ready (Finished Products)",
            "InProcess" => "In Process (Manufacturing)",
            "Shipped" => "Shipped",
            "Delivered" => "Delivered",
            _ => StockStatus
        };

        public string StatusColor => StockStatus switch
        {
            "Ready" => "#4CAF50",      // Green
            "InProcess" => "#FF9800",  // Orange
            "Shipped" => "#2196F3",    // Blue
            "Delivered" => "#9C27B0",  // Purple
            _ => "#757575"             // Gray
        };

        public string ProgressDisplay => $"{ProgressPercentage}%";

        public string DateAddedDisplay => CreatedDate.ToString("MMM dd, yyyy");

        public event PropertyChangedEventHandler? PropertyChanged;

        protected void OnPropertyChanged([CallerMemberName] string? propertyName = null)
        {
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
        }
    }
}
