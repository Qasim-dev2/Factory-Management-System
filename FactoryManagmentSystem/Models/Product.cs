using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Runtime.CompilerServices;

namespace FactoryManagmentSystem.Models
{
    public class Product : INotifyPropertyChanged
    {
        private int _productId;
        private string _productCode = string.Empty;
        private string _name = string.Empty;
        private string _description = string.Empty;
        private ProductCategory _category;
        private string _brand = string.Empty;
        private decimal _price;
        private string _currency = "PKR";
        private List<ProductSize> _availableSizes = new List<ProductSize>();
        private List<string> _availableColors = new List<string>();
        private string _material = string.Empty;
        private DateTime _createdDate;
        private DateTime _lastUpdated;
        private bool _isActive = true;
        private ProductionStatus _productionStatus = ProductionStatus.Ready;
        private string? _sku;

        public int ProductId
        {
            get => _productId;
            set { _productId = value; OnPropertyChanged(); }
        }

        public string ProductCode
        {
            get => _productCode;
            set { _productCode = value; OnPropertyChanged(); }
        }

        public string Name
        {
            get => _name;
            set { _name = value; OnPropertyChanged(); }
        }

        public string Description
        {
            get => _description;
            set { _description = value; OnPropertyChanged(); }
        }

        public ProductCategory Category
        {
            get => _category;
            set { _category = value; OnPropertyChanged(); }
        }

        public string Brand
        {
            get => _brand;
            set { _brand = value; OnPropertyChanged(); }
        }

        public decimal Price
        {
            get => _price;
            set { _price = value; OnPropertyChanged(); }
        }

        public string Currency
        {
            get => _currency;
            set { _currency = value; OnPropertyChanged(); }
        }

        public List<ProductSize> AvailableSizes
        {
            get => _availableSizes;
            set { _availableSizes = value; OnPropertyChanged(); }
        }

        public List<string> AvailableColors
        {
            get => _availableColors;
            set { _availableColors = value; OnPropertyChanged(); }
        }

        public string Material
        {
            get => _material;
            set { _material = value; OnPropertyChanged(); }
        }

        public DateTime CreatedDate
        {
            get => _createdDate;
            set { _createdDate = value; OnPropertyChanged(); }
        }

        public DateTime LastUpdated
        {
            get => _lastUpdated;
            set { _lastUpdated = value; OnPropertyChanged(); }
        }

        public bool IsActive
        {
            get => _isActive;
            set { _isActive = value; OnPropertyChanged(); OnPropertyChanged(nameof(Status)); }
        }

        public ProductionStatus ProductionStatus
        {
            get => _productionStatus;
            set { _productionStatus = value; OnPropertyChanged(); OnPropertyChanged(nameof(StatusText)); }
        }

        public string? SKU
        {
            get => _sku;
            set { _sku = value; OnPropertyChanged(); }
        }

        // Computed Properties
        public string Status => IsActive ? "Active" : "Inactive";
        
        public string StatusText => ProductionStatus.ToString();

        public string SizesDisplay => string.Join(", ", AvailableSizes);
        
        public string ColorsDisplay => string.Join(", ", AvailableColors);

        public event PropertyChangedEventHandler? PropertyChanged;
        
        protected virtual void OnPropertyChanged([CallerMemberName] string? propertyName = null)
        {
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
        }
    }

    // Product subtypes for different garment categories
    public class TShirt : Product
    {
        public TShirt()
        {
            Category = ProductCategory.TShirts;
        }
    }

    public class Shirt : Product
    {
        public Shirt()
        {
            Category = ProductCategory.Shirts;
        }
    }

    public class Jeans : Product
    {
        public Jeans()
        {
            Category = ProductCategory.Jeans;
        }
    }

    public class Sweatshirt : Product
    {
        public Sweatshirt()
        {
            Category = ProductCategory.Sweaters;
        }
    }

    public class Jacket : Product
    {
        public Jacket()
        {
            Category = ProductCategory.Jackets;
        }
    }

    public class Dress : Product
    {
        public Dress()
        {
            Category = ProductCategory.Dresses;
        }
    }

    public class Hoodie : Product
    {
        public Hoodie()
        {
            Category = ProductCategory.Hoodies;
        }
    }

    public class Pants : Product
    {
        public Pants()
        {
            Category = ProductCategory.Pants;
        }
    }

    public class Shorts : Product
    {
        public Shorts()
        {
            Category = ProductCategory.Shorts;
        }
    }

    public class Skirt : Product
    {
        public Skirt()
        {
            Category = ProductCategory.Skirts;
        }
    }
}
