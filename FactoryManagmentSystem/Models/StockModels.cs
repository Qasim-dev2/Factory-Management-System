using System.ComponentModel;
using System.Runtime.CompilerServices;

namespace FactoryManagmentSystem.Models
{
    public class StockItem : INotifyPropertyChanged
    {
        private int _productId;
        private string _name = string.Empty;
        private string _productCode = string.Empty;
        private string _category = string.Empty;
        private int _stockQuantity;
        private int _minimumStock;

        public int ProductId
        {
            get => _productId;
            set { _productId = value; OnPropertyChanged(); }
        }

        public string Name
        {
            get => _name;
            set { _name = value; OnPropertyChanged(); }
        }

        public string ProductCode
        {
            get => _productCode;
            set { _productCode = value; OnPropertyChanged(); }
        }

        public string Category
        {
            get => _category;
            set { _category = value; OnPropertyChanged(); }
        }

        public int StockQuantity
        {
            get => _stockQuantity;
            set { _stockQuantity = value; OnPropertyChanged(); UpdateStockStatus(); }
        }

        public int MinimumStock
        {
            get => _minimumStock;
            set { _minimumStock = value; OnPropertyChanged(); UpdateStockStatus(); }
        }

        public StockStatus StockStatus
        {
            get
            {
                if (StockQuantity == 0) return StockStatus.OutOfStock;
                if (StockQuantity <= MinimumStock) return StockStatus.LowStock;
                return StockStatus.InStock;
            }
        }

        private void UpdateStockStatus()
        {
            // This method is no longer needed as StockStatus is now calculated
            OnPropertyChanged(nameof(StockStatus));
        }

        public event PropertyChangedEventHandler? PropertyChanged;

        protected virtual void OnPropertyChanged([CallerMemberName] string? propertyName = null)
        {
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
        }
    }

    public class ProcessingItem : INotifyPropertyChanged
    {
        private string _orderId = string.Empty;
        private string _productName = string.Empty;
        private int _quantity;
        private string _stage = string.Empty;
        private string _assignedOperator = string.Empty;
        private string _estimatedCompletion = string.Empty;
        private int _progressPercentage;

        public string OrderId
        {
            get => _orderId;
            set { _orderId = value; OnPropertyChanged(); }
        }

        public string ProductName
        {
            get => _productName;
            set { _productName = value; OnPropertyChanged(); }
        }

        public int Quantity
        {
            get => _quantity;
            set { _quantity = value; OnPropertyChanged(); }
        }

        public string Stage
        {
            get => _stage;
            set { _stage = value; OnPropertyChanged(); }
        }

        public string AssignedOperator
        {
            get => _assignedOperator;
            set { _assignedOperator = value; OnPropertyChanged(); }
        }

        public string EstimatedCompletion
        {
            get => _estimatedCompletion;
            set { _estimatedCompletion = value; OnPropertyChanged(); }
        }

        public int ProgressPercentage
        {
            get => _progressPercentage;
            set { _progressPercentage = value; OnPropertyChanged(); }
        }

        public event PropertyChangedEventHandler? PropertyChanged;

        protected virtual void OnPropertyChanged([CallerMemberName] string? propertyName = null)
        {
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
        }
    }

    public class ReadyToShipItem : INotifyPropertyChanged
    {
        private string _orderId = string.Empty;
        private string _productName = string.Empty;
        private string _customerName = string.Empty;
        private int _quantity;
        private string _completedDate = string.Empty;
        private string _priority = string.Empty;
        private string _qualityCheck = string.Empty;
        private string _destination = string.Empty;

        public string OrderId
        {
            get => _orderId;
            set { _orderId = value; OnPropertyChanged(); }
        }

        public string ProductName
        {
            get => _productName;
            set { _productName = value; OnPropertyChanged(); }
        }

        public string CustomerName
        {
            get => _customerName;
            set { _customerName = value; OnPropertyChanged(); }
        }

        public int Quantity
        {
            get => _quantity;
            set { _quantity = value; OnPropertyChanged(); }
        }

        public string CompletedDate
        {
            get => _completedDate;
            set { _completedDate = value; OnPropertyChanged(); }
        }

        public string Priority
        {
            get => _priority;
            set { _priority = value; OnPropertyChanged(); }
        }

        public string QualityCheck
        {
            get => _qualityCheck;
            set { _qualityCheck = value; OnPropertyChanged(); }
        }

        public string Destination
        {
            get => _destination;
            set { _destination = value; OnPropertyChanged(); }
        }

        public event PropertyChangedEventHandler? PropertyChanged;

        protected virtual void OnPropertyChanged([CallerMemberName] string? propertyName = null)
        {
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
        }
    }

    public class ShippedItem : INotifyPropertyChanged
    {
        private string _trackingNumber = string.Empty;
        private string _productName = string.Empty;
        private string _customerName = string.Empty;
        private int _quantity;
        private string _shippedDate = string.Empty;
        private string _deliveryStatus = string.Empty;
        private string _carrier = string.Empty;
        private string _destination = string.Empty;

        public string TrackingNumber
        {
            get => _trackingNumber;
            set { _trackingNumber = value; OnPropertyChanged(); }
        }

        public string ProductName
        {
            get => _productName;
            set { _productName = value; OnPropertyChanged(); }
        }

        public string CustomerName
        {
            get => _customerName;
            set { _customerName = value; OnPropertyChanged(); }
        }

        public int Quantity
        {
            get => _quantity;
            set { _quantity = value; OnPropertyChanged(); }
        }

        public string ShippedDate
        {
            get => _shippedDate;
            set { _shippedDate = value; OnPropertyChanged(); }
        }

        public string DeliveryStatus
        {
            get => _deliveryStatus;
            set { _deliveryStatus = value; OnPropertyChanged(); }
        }

        public string Carrier
        {
            get => _carrier;
            set { _carrier = value; OnPropertyChanged(); }
        }

        public string Destination
        {
            get => _destination;
            set { _destination = value; OnPropertyChanged(); }
        }

        public event PropertyChangedEventHandler? PropertyChanged;

        protected virtual void OnPropertyChanged([CallerMemberName] string? propertyName = null)
        {
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
        }
    }

    public enum StockStatus
    {
        InStock,
        LowStock,
        OutOfStock
    }
}