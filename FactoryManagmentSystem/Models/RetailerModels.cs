using System;
using System.ComponentModel;
using System.Runtime.CompilerServices;

namespace FactoryManagmentSystem.Models
{
    // ================================================================================
    // RETAILER MODEL - Simplified Structure
    // ================================================================================
    public class Retailer : INotifyPropertyChanged
    {
        private int _retailerID;
        private string _companyName;
        private string _contactPerson;
        private string _phone;
        private string _email;
        private string _alternativePhone;
        private string _address;
        private string _city;
        private string _province;
        private string _postalCode;
        private string _status;
        private bool _isActive;
        private DateTime _createdDate;
        private DateTime? _updatedDate;

        public int RetailerID
        {
            get => _retailerID;
            set { _retailerID = value; OnPropertyChanged(); }
        }

        public string CompanyName
        {
            get => _companyName;
            set { _companyName = value; OnPropertyChanged(); }
        }

        public string ContactPerson
        {
            get => _contactPerson;
            set { _contactPerson = value; OnPropertyChanged(); }
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

        public string AlternativePhone
        {
            get => _alternativePhone;
            set { _alternativePhone = value; OnPropertyChanged(); }
        }

        public string Address
        {
            get => _address;
            set { _address = value; OnPropertyChanged(); }
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

        public string PostalCode
        {
            get => _postalCode;
            set { _postalCode = value; OnPropertyChanged(); }
        }

        public string Status
        {
            get => _status;
            set { _status = value; OnPropertyChanged(); }
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

        // Computed property for display
        public string FullLocation => $"{City}, {Province}";

        public event PropertyChangedEventHandler PropertyChanged;

        protected virtual void OnPropertyChanged([CallerMemberName] string propertyName = null)
        {
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
        }
    }

    // ================================================================================
    // RETAILER STATISTICS MODEL
    // ================================================================================
    public class RetailerStatistics
    {
        public int TotalRetailers { get; set; }
        public int ActiveRetailers { get; set; }
        public int InactiveRetailers { get; set; }
        public int CitiesCovered { get; set; }
    }
}
