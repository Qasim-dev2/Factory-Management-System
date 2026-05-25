namespace FactoryManagmentSystem.Models
{
    public enum ProductCategory
    {
        TShirts,
        Jeans,
        Jackets,
        Shirts,
        Dresses,
        Pants,
        Shorts,
        Sweaters,
        Sweatshirts,
        Hoodies,
        Skirts,
        Accessories
    }

    public enum ProductionStatus
    {
        Planned,
        Planning,
        InProduction,
        QualityCheck,
        Ready,
        Completed,
        Shipped,
        OnHold,
        Cancelled,
        Discontinued
    }

    public enum ProductSize
    {
        XS,
        S,
        M,
        L,
        XL,
        XXL,
        XXXL
    }
}
