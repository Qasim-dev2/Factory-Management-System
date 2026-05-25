using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Runtime.CompilerServices;

namespace FactoryManagmentSystem.Models
{
    // ================================================================================
    // SALES ORDER MODEL - Matches SalesOrder table structure
    // ================================================================================
    public class SalesOrder : INotifyPropertyChanged
    {
        private int _salesOrderID;
        private DateTime _orderDate;
        private string _status;
        private int _retailerID;
        private string _retailerName;
        private string _shippingAddress;
        private decimal _discountPercentage;
        private decimal _subTotal;
        private decimal _discountAmount;
        private decimal _totalAmount;
        private int? _salesRepID;
        private string _salesRepName;
        private DateTime _createdDate;
        private DateTime? _updatedDate;
        private int _itemCount;

        public int SalesOrderID
        {
            get => _salesOrderID;
            set { _salesOrderID = value; OnPropertyChanged(); }
        }

        public DateTime OrderDate
        {
            get => _orderDate;
            set { _orderDate = value; OnPropertyChanged(); }
        }

        public string Status
        {
            get => _status;
            set { _status = value; OnPropertyChanged(); }
        }

        public int RetailerID
        {
            get => _retailerID;
            set { _retailerID = value; OnPropertyChanged(); }
        }

        public string RetailerName
        {
            get => _retailerName;
            set { _retailerName = value; OnPropertyChanged(); }
        }

        public string ShippingAddress
        {
            get => _shippingAddress;
            set { _shippingAddress = value; OnPropertyChanged(); }
        }

        public decimal DiscountPercentage
        {
            get => _discountPercentage;
            set 
            { 
                _discountPercentage = value; 
                OnPropertyChanged();
                // Auto-calculate discount amount when percentage changes
                DiscountAmount = (_subTotal * value) / 100;
            }
        }

        public decimal SubTotal
        {
            get => _subTotal;
            set 
            { 
                _subTotal = value; 
                OnPropertyChanged();
                // Recalculate discount amount and total when subtotal changes
                DiscountAmount = (value * _discountPercentage) / 100;
                TotalAmount = value - _discountAmount;
            }
        }

        public decimal DiscountAmount
        {
            get => _discountAmount;
            set 
            { 
                _discountAmount = value; 
                OnPropertyChanged();
                // Recalculate total when discount amount changes
                TotalAmount = _subTotal - value;
            }
        }

        public decimal TotalAmount
        {
            get => _totalAmount;
            set { _totalAmount = value; OnPropertyChanged(); }
        }

        public int? SalesRepID
        {
            get => _salesRepID;
            set { _salesRepID = value; OnPropertyChanged(); }
        }

        public string SalesRepName
        {
            get => _salesRepName;
            set { _salesRepName = value; OnPropertyChanged(); }
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

        public int ItemCount
        {
            get => _itemCount;
            set { _itemCount = value; OnPropertyChanged(); }
        }

        // Order Items Collection
        public List<SalesOrderItem> Items { get; set; } = new List<SalesOrderItem>();

        public event PropertyChangedEventHandler PropertyChanged;
        protected void OnPropertyChanged([CallerMemberName] string propertyName = null)
        {
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
        }
    }

    // ================================================================================
    // SALES ORDER ITEM MODEL - Matches SalesOrderItem table structure
    // ================================================================================
    public class SalesOrderItem : INotifyPropertyChanged
    {
        private int _salesOrderItemID;
        private int _salesOrderID;
        private int _productID;
        private string _productName;
        private string _category;
        private string _brand;
        private string _size;
        private string _color;
        private int _quantity;
        private decimal _unitPrice;
        private decimal _discount;
        private decimal _totalPrice;

        public int SalesOrderItemID
        {
            get => _salesOrderItemID;
            set { _salesOrderItemID = value; OnPropertyChanged(); }
        }

        public int SalesOrderID
        {
            get => _salesOrderID;
            set { _salesOrderID = value; OnPropertyChanged(); }
        }

        public int ProductID
        {
            get => _productID;
            set { _productID = value; OnPropertyChanged(); }
        }

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

        public string Brand
        {
            get => _brand;
            set { _brand = value; OnPropertyChanged(); }
        }

        public string Size
        {
            get => _size;
            set { _size = value; OnPropertyChanged(); }
        }

        public string Color
        {
            get => _color;
            set { _color = value; OnPropertyChanged(); }
        }

        public int Quantity
        {
            get => _quantity;
            set
            {
                _quantity = value;
                OnPropertyChanged();
                OnPropertyChanged(nameof(TotalPrice));
            }
        }

        public decimal UnitPrice
        {
            get => _unitPrice;
            set
            {
                _unitPrice = value;
                OnPropertyChanged();
                OnPropertyChanged(nameof(TotalPrice));
            }
        }

        public decimal Discount
        {
            get => _discount;
            set
            {
                _discount = value;
                OnPropertyChanged();
                OnPropertyChanged(nameof(TotalPrice));
            }
        }

        public decimal TotalPrice
        {
            get => (_quantity * _unitPrice) - _discount;
            set { _totalPrice = value; OnPropertyChanged(); }
        }

        public event PropertyChangedEventHandler PropertyChanged;
        protected void OnPropertyChanged([CallerMemberName] string propertyName = null)
        {
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
        }
    }

    // ================================================================================
    // RETAILER FOR ORDER MODEL - Simplified retailer for dropdowns
    // ================================================================================
    public class RetailerForOrder
    {
        public int RetailerID { get; set; }
        public string CompanyName { get; set; }
        public string ContactPerson { get; set; }
        public string Phone { get; set; }
        public string Email { get; set; }
        public string City { get; set; }
        public string Province { get; set; }
        public string ShippingAddress { get; set; }
        public string Status { get; set; }
    }

    // ================================================================================
    // PRODUCT FOR ORDER MODEL - Simplified product for dropdowns
    // ================================================================================
    public class ProductForOrder
    {
        public int ProductID { get; set; }
        public string ProductName { get; set; }
        public string Category { get; set; }
        public string Brand { get; set; }
        public decimal SalePrice { get; set; }
        public string AvailableSizes { get; set; }
        public string AvailableColors { get; set; }
        public string ProductionStatus { get; set; }
    }

    // ================================================================================
    // SALESPERSON FOR ORDER - For dropdown in order forms
    // ================================================================================
    public class SalespersonForOrder
    {
        public int EmployeeID { get; set; }
        public string FullName { get; set; }
        public string Email { get; set; }
        public string Phone { get; set; }
        public string Department { get; set; }
    }

    // ================================================================================
    // SALES ORDER STATISTICS MODEL
    // ================================================================================
    public class SalesOrderStatistics
    {
        public int TotalOrders { get; set; }
        public int PendingOrders { get; set; }
        public int ConfirmedOrders { get; set; }
        public int InProductionOrders { get; set; }
        public int ShippedOrders { get; set; }
        public int DeliveredOrders { get; set; }
        public int RushOrders { get; set; }
        public int PendingPayments { get; set; }
        public int PaidOrders { get; set; }
        public decimal TotalRevenue { get; set; }
        public decimal AverageOrderValue { get; set; }
        public int TodayOrders { get; set; }
        public int LastWeekOrders { get; set; }
        public int LastMonthOrders { get; set; }
    }
}
