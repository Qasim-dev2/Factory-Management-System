using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Runtime.CompilerServices;

namespace FactoryManagmentSystem.Models
{
    /// <summary>
    /// Deal entity model matching the Deal table in database
    /// </summary>
    public class Deal : INotifyPropertyChanged
    {
        private int _dealId;
        private string _dealTitle = string.Empty;
        private string? _dealType;
        private string? _clientName;
        private string? _contactPerson;
        private string? _email;
        private string? _phone;
        private string? _expectedDuration;
        private DateTime? _startDate;
        private DateTime? _endDate;
        private string? _description;
        private string? _deliveryAddress;
        private string? _city;
        private string? _province;
        private string _status = "Pending";
        private decimal _totalAmount;
        private int? _createdBy;
        private string? _createdByName;
        private DateTime _createdDate;
        private DateTime? _updatedDate;

        public int DealId
        {
            get => _dealId;
            set { _dealId = value; OnPropertyChanged(); }
        }

        public string DealTitle
        {
            get => _dealTitle;
            set { _dealTitle = value; OnPropertyChanged(); }
        }

        public string? DealType
        {
            get => _dealType;
            set { _dealType = value; OnPropertyChanged(); }
        }

        public string? ClientName
        {
            get => _clientName;
            set { _clientName = value; OnPropertyChanged(); }
        }

        public string? ContactPerson
        {
            get => _contactPerson;
            set { _contactPerson = value; OnPropertyChanged(); }
        }

        public string? Email
        {
            get => _email;
            set { _email = value; OnPropertyChanged(); }
        }

        public string? Phone
        {
            get => _phone;
            set { _phone = value; OnPropertyChanged(); }
        }

        public string? ExpectedDuration
        {
            get => _expectedDuration;
            set { _expectedDuration = value; OnPropertyChanged(); }
        }

        public DateTime? StartDate
        {
            get => _startDate;
            set { _startDate = value; OnPropertyChanged(); }
        }

        public DateTime? EndDate
        {
            get => _endDate;
            set { _endDate = value; OnPropertyChanged(); }
        }

        public string? Description
        {
            get => _description;
            set { _description = value; OnPropertyChanged(); }
        }

        public string? DeliveryAddress
        {
            get => _deliveryAddress;
            set { _deliveryAddress = value; OnPropertyChanged(); }
        }

        public string? City
        {
            get => _city;
            set { _city = value; OnPropertyChanged(); }
        }

        public string? Province
        {
            get => _province;
            set { _province = value; OnPropertyChanged(); }
        }

        public string Status
        {
            get => _status;
            set { _status = value; OnPropertyChanged(); }
        }

        public decimal TotalAmount
        {
            get => _totalAmount;
            set { _totalAmount = value; OnPropertyChanged(); }
        }

        public int? CreatedBy
        {
            get => _createdBy;
            set { _createdBy = value; OnPropertyChanged(); }
        }

        public string? CreatedByName
        {
            get => _createdByName;
            set { _createdByName = value; OnPropertyChanged(); }
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

        // Alias properties for simplified UI binding
        public string DealName
        {
            get => DealTitle;
            set { DealTitle = value; OnPropertyChanged(); }
        }

        public string? RequestedBy
        {
            get => ClientName;
            set { ClientName = value; OnPropertyChanged(); }
        }

        public DateTime? Deadline
        {
            get => EndDate;
            set { EndDate = value; OnPropertyChanged(); }
        }

        public event PropertyChangedEventHandler? PropertyChanged;

        protected virtual void OnPropertyChanged([CallerMemberName] string? propertyName = null)
        {
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
        }
    }

    /// <summary>
    /// DealItem entity model matching the DealItem table in database
    /// Represents products included in a deal
    /// </summary>
    public class DealItem : INotifyPropertyChanged
    {
        private int _dealItemId;
        private int _dealId;
        private int _productId;
        private string? _productName;
        private string? _category;
        private string? _sku;
        private int _quantity;
        private decimal _unitPrice;
        private decimal _totalPrice;

        public int DealItemId
        {
            get => _dealItemId;
            set { _dealItemId = value; OnPropertyChanged(); }
        }

        public int DealId
        {
            get => _dealId;
            set { _dealId = value; OnPropertyChanged(); }
        }

        public int ProductId
        {
            get => _productId;
            set { _productId = value; OnPropertyChanged(); }
        }

        public string? ProductName
        {
            get => _productName;
            set { _productName = value; OnPropertyChanged(); }
        }

        public string? Category
        {
            get => _category;
            set { _category = value; OnPropertyChanged(); }
        }

        public string? SKU
        {
            get => _sku;
            set { _sku = value; OnPropertyChanged(); }
        }

        public int Quantity
        {
            get => _quantity;
            set
            {
                _quantity = value;
                OnPropertyChanged();
                // Recalculate total price
                TotalPrice = _quantity * _unitPrice;
            }
        }

        public decimal UnitPrice
        {
            get => _unitPrice;
            set
            {
                _unitPrice = value;
                OnPropertyChanged();
                // Recalculate total price
                TotalPrice = _quantity * _unitPrice;
            }
        }

        public decimal TotalPrice
        {
            get => _totalPrice;
            set { _totalPrice = value; OnPropertyChanged(); }
        }

        public event PropertyChangedEventHandler? PropertyChanged;

        protected virtual void OnPropertyChanged([CallerMemberName] string? propertyName = null)
        {
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
        }
    }

    /// <summary>
    /// Deal statistics for dashboard display
    /// </summary>
    public class DealStatistics
    {
        public int TotalDeals { get; set; }
        public int PendingDeals { get; set; }
        public int DraftDeals { get; set; }
        public int UnderReviewDeals { get; set; }
        public int PendingApprovalDeals { get; set; }
        public int ApprovedDeals { get; set; }
        public int ActiveDeals { get; set; }
        public int InProgressDeals { get; set; }
        public int CompletedDeals { get; set; }
        public int CancelledDeals { get; set; }
        public decimal TotalEstimatedValue { get; set; }
        public decimal AverageEstimatedValue { get; set; }
    }
}

