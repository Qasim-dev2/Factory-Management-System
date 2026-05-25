using System;
using System.ComponentModel;
using System.Runtime.CompilerServices;

namespace FactoryManagmentSystem.Models
{
    // ================================================================================
    // ORDER APPROVAL MODELS
    // ================================================================================

    /// <summary>
    /// Represents an order approval request from salesperson to owner
    /// </summary>
    public class OrderApproval : INotifyPropertyChanged
    {
        private int _approvalID;
        private string _orderType;
        private int _orderID;
        private string _status;
        private int? _approvedByOwnerID;
        private DateTime? _approvalDate;
        private string _rejectionReason;
        private int? _productionOrderID;
        private int _requestedByEmployeeID;
        private DateTime _requestDate;

        // Display Fields
        private string _salespersonName;
        private string _salespersonPhone;
        private decimal? _salesOrderAmount;
        private string _salesOrderPriority;
        private string _retailerName;
        private string _dealTitle;
        private string _dealClientName;

        public int ApprovalID
        {
            get => _approvalID;
            set { _approvalID = value; OnPropertyChanged(); }
        }

        public string OrderType
        {
            get => _orderType;
            set { _orderType = value; OnPropertyChanged(); }
        }

        public int OrderID
        {
            get => _orderID;
            set { _orderID = value; OnPropertyChanged(); }
        }

        public string Status
        {
            get => _status;
            set { _status = value; OnPropertyChanged(); }
        }

        public int? ApprovedByOwnerID
        {
            get => _approvedByOwnerID;
            set { _approvedByOwnerID = value; OnPropertyChanged(); }
        }

        public DateTime? ApprovalDate
        {
            get => _approvalDate;
            set { _approvalDate = value; OnPropertyChanged(); }
        }

        public string RejectionReason
        {
            get => _rejectionReason;
            set { _rejectionReason = value; OnPropertyChanged(); }
        }

        public int? ProductionOrderID
        {
            get => _productionOrderID;
            set { _productionOrderID = value; OnPropertyChanged(); }
        }

        public int RequestedByEmployeeID
        {
            get => _requestedByEmployeeID;
            set { _requestedByEmployeeID = value; OnPropertyChanged(); }
        }

        public DateTime RequestDate
        {
            get => _requestDate;
            set { _requestDate = value; OnPropertyChanged(); }
        }

        // Display Properties
        public string SalespersonName
        {
            get => _salespersonName;
            set { _salespersonName = value; OnPropertyChanged(); }
        }

        public string SalespersonPhone
        {
            get => _salespersonPhone;
            set { _salespersonPhone = value; OnPropertyChanged(); }
        }

        public decimal? SalesOrderAmount
        {
            get => _salesOrderAmount;
            set { _salesOrderAmount = value; OnPropertyChanged(); }
        }

        public string SalesOrderPriority
        {
            get => _salesOrderPriority;
            set { _salesOrderPriority = value; OnPropertyChanged(); }
        }

        public string RetailerName
        {
            get => _retailerName;
            set { _retailerName = value; OnPropertyChanged(); }
        }

        public string DealTitle
        {
            get => _dealTitle;
            set { _dealTitle = value; OnPropertyChanged(); }
        }

        public string DealClientName
        {
            get => _dealClientName;
            set { _dealClientName = value; OnPropertyChanged(); }
        }

        // Computed Properties for UI
        public string CustomerName => OrderType == "SalesOrder" ? RetailerName : DealClientName;
        public decimal? OrderAmount => SalesOrderAmount;
        public string Priority => SalesOrderPriority;
        public string OrderReference => $"{OrderType} #{OrderID}";
        public string DealInfo => OrderType == "Deal" ? DealTitle : null;

        public event PropertyChangedEventHandler PropertyChanged;
        protected void OnPropertyChanged([CallerMemberName] string propertyName = null)
        {
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
        }
    }

    /// <summary>
    /// Represents material check result for an order
    /// </summary>
    public class MaterialCheckResult : INotifyPropertyChanged
    {
        private int _productID;
        private string _productName;
        private int _quantityOrdered;
        private int _rawMaterialID;
        private string _materialName;
        private decimal _requiredQuantity;
        private decimal _availableQuantity;
        private string _unit;
        private string _status;

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

        public int QuantityOrdered
        {
            get => _quantityOrdered;
            set { _quantityOrdered = value; OnPropertyChanged(); }
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

        public decimal RequiredQuantity
        {
            get => _requiredQuantity;
            set { _requiredQuantity = value; OnPropertyChanged(); }
        }

        public decimal AvailableQuantity
        {
            get => _availableQuantity;
            set { _availableQuantity = value; OnPropertyChanged(); }
        }

        public string Unit
        {
            get => _unit;
            set { _unit = value; OnPropertyChanged(); }
        }

        public string Status
        {
            get => _status;
            set { _status = value; OnPropertyChanged(); OnPropertyChanged(nameof(IsSufficient)); OnPropertyChanged(nameof(StatusDisplay)); OnPropertyChanged(nameof(ShortageDisplay)); }
        }

        // Computed Properties
        public bool IsSufficient => Status == "Available";
        public decimal Shortage => Math.Max(0, RequiredQuantity - AvailableQuantity);
        public string StatusDisplay => IsSufficient ? "✓ Available" : "✗ Insufficient";
        public string RequiredQuantityDisplay => $"{RequiredQuantity:F2} {Unit}";
        public string AvailableQuantityDisplay => $"{AvailableQuantity:F2} {Unit}";
        public string ShortageDisplay => Shortage > 0 ? $"{Shortage:F2} {Unit}" : "-";

        public event PropertyChangedEventHandler PropertyChanged;
        protected void OnPropertyChanged([CallerMemberName] string propertyName = null)
        {
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
        }
    }

    /// <summary>
    /// Represents a tailor assigned to a production order
    /// </summary>
    public class TailorAssignment : INotifyPropertyChanged
    {
        private int _tailorAssignmentID;
        private int _productionOrderID;
        private int _tailorID;
        private int? _assignedByOwnerID;
        private DateTime _assignedDate;
        private string _completionStatus;
        private DateTime? _startedDate;
        private DateTime? _completedDate;
        private string _assignmentNotes;
        private string _completionNotes;

        // Display Fields (from joins)
        private int _quantityOrdered;
        private string _productionStatus;
        private string _priority;
        private DateTime? _expectedEndDate;
        private int _productID;
        private string _productName;
        private string _category;
        private string _material;
        private int _totalTailors;
        private int _completedTailors;
        private string _tailorName;

        public int TailorAssignmentID
        {
            get => _tailorAssignmentID;
            set { _tailorAssignmentID = value; OnPropertyChanged(); }
        }

        public int ProductionOrderID
        {
            get => _productionOrderID;
            set { _productionOrderID = value; OnPropertyChanged(); }
        }

        public int TailorID
        {
            get => _tailorID;
            set { _tailorID = value; OnPropertyChanged(); }
        }

        public int? AssignedByOwnerID
        {
            get => _assignedByOwnerID;
            set { _assignedByOwnerID = value; OnPropertyChanged(); }
        }

        public DateTime AssignedDate
        {
            get => _assignedDate;
            set { _assignedDate = value; OnPropertyChanged(); }
        }

        public string CompletionStatus
        {
            get => _completionStatus;
            set { _completionStatus = value; OnPropertyChanged(); }
        }

        public DateTime? StartedDate
        {
            get => _startedDate;
            set { _startedDate = value; OnPropertyChanged(); }
        }

        public DateTime? CompletedDate
        {
            get => _completedDate;
            set { _completedDate = value; OnPropertyChanged(); }
        }

        public string AssignmentNotes
        {
            get => _assignmentNotes;
            set { _assignmentNotes = value; OnPropertyChanged(); }
        }

        public string CompletionNotes
        {
            get => _completionNotes;
            set { _completionNotes = value; OnPropertyChanged(); }
        }

        // Display Properties
        public int QuantityOrdered
        {
            get => _quantityOrdered;
            set { _quantityOrdered = value; OnPropertyChanged(); }
        }

        public string ProductionStatus
        {
            get => _productionStatus;
            set { _productionStatus = value; OnPropertyChanged(); }
        }

        public string Priority
        {
            get => _priority;
            set { _priority = value; OnPropertyChanged(); }
        }

        public DateTime? ExpectedEndDate
        {
            get => _expectedEndDate;
            set { _expectedEndDate = value; OnPropertyChanged(); }
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

        public string Material
        {
            get => _material;
            set { _material = value; OnPropertyChanged(); }
        }

        public int TotalTailors
        {
            get => _totalTailors;
            set { _totalTailors = value; OnPropertyChanged(); }
        }

        public int CompletedTailors
        {
            get => _completedTailors;
            set { _completedTailors = value; OnPropertyChanged(); }
        }

        public string TailorName
        {
            get => _tailorName;
            set { _tailorName = value; OnPropertyChanged(); }
        }

        // UI Properties for button visibility and colors
        private System.Windows.Visibility _startButtonVisibility;
        private System.Windows.Visibility _completeButtonVisibility;
        private System.Windows.Visibility _completedTextVisibility;
        private string _statusColor;
        private string _priorityColor;

        public System.Windows.Visibility StartButtonVisibility
        {
            get => _startButtonVisibility;
            set { _startButtonVisibility = value; OnPropertyChanged(); }
        }

        public System.Windows.Visibility CompleteButtonVisibility
        {
            get => _completeButtonVisibility;
            set { _completeButtonVisibility = value; OnPropertyChanged(); }
        }

        public System.Windows.Visibility CompletedTextVisibility
        {
            get => _completedTextVisibility;
            set { _completedTextVisibility = value; OnPropertyChanged(); }
        }

        public string StatusColor
        {
            get => _statusColor;
            set { _statusColor = value; OnPropertyChanged(); }
        }

        public string PriorityColor
        {
            get => _priorityColor;
            set { _priorityColor = value; OnPropertyChanged(); }
        }

        // Computed Properties
        public bool IsIncomplete => CompletionStatus == "Incomplete";
        public bool IsInProgress => CompletionStatus == "InProgress";
        public bool IsComplete => CompletionStatus == "Complete";
        public string ProgressDisplay => $"{CompletedTailors}/{TotalTailors} Tailors Completed";

        public event PropertyChangedEventHandler PropertyChanged;
        protected void OnPropertyChanged([CallerMemberName] string propertyName = null)
        {
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
        }
    }

    /// <summary>
    /// Represents a tailor available for assignment
    /// </summary>
    public class AvailableTailor : INotifyPropertyChanged
    {
        private int _employeeID;
        private string _tailorName;
        private string _phone;
        private string _email;
        private string _departmentName;
        private string _roleName;
        private int _activeAssignments;
        private bool _isSelected;

        public int EmployeeID
        {
            get => _employeeID;
            set { _employeeID = value; OnPropertyChanged(); }
        }

        public string TailorName
        {
            get => _tailorName;
            set { _tailorName = value; OnPropertyChanged(); }
        }

        public string Phone
        {
            get => _phone;
            set { _phone = value; OnPropertyChanged(); }
        }

        public string Email
        {
            get => _email;
            set { _email = value; OnPropertyChanged(); }
        }

        public string DepartmentName
        {
            get => _departmentName;
            set { _departmentName = value; OnPropertyChanged(); }
        }

        public string RoleName
        {
            get => _roleName;
            set { _roleName = value; OnPropertyChanged(); }
        }

        public int ActiveAssignments
        {
            get => _activeAssignments;
            set { _activeAssignments = value; OnPropertyChanged(); }
        }

        public bool IsSelected
        {
            get => _isSelected;
            set { _isSelected = value; OnPropertyChanged(); }
        }

        // Computed Properties
        public string WorkloadStatus => ActiveAssignments == 0 ? "Available" :
                                       ActiveAssignments <= 2 ? "Light Load" :
                                       ActiveAssignments <= 5 ? "Moderate Load" : "Heavy Load";

        public event PropertyChangedEventHandler PropertyChanged;
        protected void OnPropertyChanged([CallerMemberName] string propertyName = null)
        {
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
        }
    }

    /// <summary>
    /// Delivery information model with UI properties for binding
    /// </summary>
    public class DeliveryInfo : INotifyPropertyChanged
    {
        private int _deliveryID;
        private int? _salesOrderID;
        private int? _dealID;
        private string _orderType;
        private string _status;
        private DateTime? _deliveryDate;
        private string _deliveryAddress;
        private string _city;
        private string _province;
        private string _receiverName;
        private string _receiverPhone;
        private string _notes;
        private string _customerName;
        private DateTime _createdDate;
        private DateTime? _updatedDate;

        // UI-specific properties
        private System.Windows.Visibility _dispatchButtonVisibility;
        private System.Windows.Visibility _deliverButtonVisibility;
        private System.Windows.Visibility _completedTextVisibility;
        private string _statusColor;

        public int DeliveryID
        {
            get => _deliveryID;
            set { _deliveryID = value; OnPropertyChanged(); }
        }

        public int? SalesOrderID
        {
            get => _salesOrderID;
            set { _salesOrderID = value; OnPropertyChanged(); }
        }

        public int? DealID
        {
            get => _dealID;
            set { _dealID = value; OnPropertyChanged(); }
        }

        public string OrderType
        {
            get => _orderType;
            set { _orderType = value; OnPropertyChanged(); }
        }

        public string Status
        {
            get => _status;
            set { _status = value; OnPropertyChanged(); }
        }

        public DateTime? DeliveryDate
        {
            get => _deliveryDate;
            set { _deliveryDate = value; OnPropertyChanged(); }
        }

        public string DeliveryAddress
        {
            get => _deliveryAddress;
            set { _deliveryAddress = value; OnPropertyChanged(); }
        }

        public string City
        {
            get => _city;
            set { _city = value; OnPropertyChanged(); }
        }

        public string Province
        {
            get => _province;
            set { _province = value; OnPropertyChanged(); }
        }

        public string ReceiverName
        {
            get => _receiverName;
            set { _receiverName = value; OnPropertyChanged(); }
        }

        public string ReceiverPhone
        {
            get => _receiverPhone;
            set { _receiverPhone = value; OnPropertyChanged(); }
        }

        public string Notes
        {
            get => _notes;
            set { _notes = value; OnPropertyChanged(); }
        }

        public string CustomerName
        {
            get => _customerName;
            set { _customerName = value; OnPropertyChanged(); }
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

        // UI Properties
        public System.Windows.Visibility DispatchButtonVisibility
        {
            get => _dispatchButtonVisibility;
            set { _dispatchButtonVisibility = value; OnPropertyChanged(); }
        }

        public System.Windows.Visibility DeliverButtonVisibility
        {
            get => _deliverButtonVisibility;
            set { _deliverButtonVisibility = value; OnPropertyChanged(); }
        }

        public System.Windows.Visibility CompletedTextVisibility
        {
            get => _completedTextVisibility;
            set { _completedTextVisibility = value; OnPropertyChanged(); }
        }

        public string StatusColor
        {
            get => _statusColor;
            set { _statusColor = value; OnPropertyChanged(); }
        }

        public event PropertyChangedEventHandler PropertyChanged;
        protected void OnPropertyChanged([CallerMemberName] string propertyName = null)
        {
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
        }
    }
}
