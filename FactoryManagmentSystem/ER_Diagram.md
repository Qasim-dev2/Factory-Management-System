# Factory Management System - ER Diagram

## Entity Relationship Diagram

```mermaid
erDiagram
    EMPLOYEE {
        int EmployeeID PK
        string FirstName
        string LastName
        string Email
        string PhoneNumber
        decimal Salary
        int DepartmentID FK
        int RoleID FK
        datetime JoinDate
        datetime HireDate
        datetime UpdatedDate
    }

    DEPARTMENT {
        int DepartmentID PK
        string DepartmentName
        string Description
    }

    EMPLOYEEROLE {
        int RoleID PK
        string RoleName
        string Description
    }

    PRODUCT {
        int ProductID PK
        string ProductName
        string Description
        string Category
        string SubCategory
        int ManufacturingTime
        decimal Price
    }

    RAWMATERIAL {
        int RawMaterialID PK
        string MaterialName
        string Category
        string Unit
        decimal Quantity
        decimal MinimumStock
        decimal UnitPrice
        string Supplier
        string SupplierContact
        string Description
    }

    RAWMATERIALPURCHASE {
        int PurchaseID PK
        int RawMaterialID FK
        string MaterialName
        datetime PurchaseDate
        decimal Quantity
        string Unit
        decimal UnitPrice
        decimal TotalAmount
        string SupplierName
        string Notes
    }

    PRODUCTMATERIALREQUIREMENT {
        int RequirementID PK
        int ProductID FK
        int RawMaterialID FK
        decimal QuantityRequired
    }

    SALESORDER {
        int SalesOrderID PK
        datetime OrderDate
        int RetailerID FK
        int SalesRepID FK
        decimal TotalAmount
        string Status
        datetime UpdatedDate
    }

    SALESORDERITEM {
        int SalesOrderItemID PK
        int SalesOrderID FK
        int ProductID FK
        int Quantity
        decimal UnitPrice
    }

    RETAILER {
        int RetailerID PK
        string CompanyName
        string ContactPerson
        string Email
        string PhoneNumber
        string Address
        string City
        string Province
        string PostalCode
    }

    DEAL {
        int DealID PK
        string DealTitle
        string DealType
        string ClientName
        string ContactPerson
        string Email
        string Phone
        string ExpectedDuration
        datetime StartDate
        datetime EndDate
        string Description
        string Status
        int CreatedBy FK
        string DeliveryAddress
        string City
        string Province
        decimal TotalAmount
        datetime CreatedDate
        datetime UpdatedDate
    }

    DEALITEM {
        int DealItemID PK
        int DealID FK
        int ProductID FK
        int Quantity
        decimal UnitPrice
    }

    PRODUCTIONORDER {
        int ProductionOrderID PK
        int ProductID FK
        int QuantityOrdered
        string Status
        string Priority
        int CreatedByEmployeeID FK
        datetime CreatedDate
        datetime StartDate
        datetime CompletedDate
    }

    TAILORASSIGNMENT {
        int AssignmentID PK
        int TailorID FK
        int ProductionOrderID FK
        int ProductID FK
        int QuantityAssigned
        datetime AssignedDate
        string Status
        datetime CompletedDate
        int DealID FK
        int SalesOrderID FK
    }

    DELIVERY {
        int DeliveryID PK
        int SalesOrderID FK
        int DealID FK
        int DeliveredBy FK
        string DeliveryAddress
        string City
        string Province
        string PostalCode
        string Status
        datetime DeliveryDate
        datetime CreatedDate
        string Notes
    }

    SALARYPAYMENT {
        int PaymentID PK
        int EmployeeID FK
        decimal TotalAmount
        datetime PaymentDate
    }

    MISCEXPENSE {
        int ExpenseID PK
        string ExpenseName
        decimal Amount
        string Category
        datetime ExpenseDate
        string Description
    }

    STOCK {
        int StockID PK
        int ProductID FK
        int QuantityStocked
        string Location
        datetime StockedDate
        int CreatedBy FK
    }

    MONTHLYREVENUE {
        int RevenueID PK
        int Month
        int Year
        decimal SalesIncome
        decimal DealIncome
        decimal ExpenseAmount
        decimal TotalProfit
    }

    ORDERAPPROVAL {
        int ApprovalID PK
        string OrderType
        int OrderID
        int RequestedByEmployeeID
        string Status
        datetime RequestDate
        datetime ApprovalDate
        int ApprovedBy
        string ApprovalStatus
        datetime CreatedDate
    }

    %% Relationships
    EMPLOYEE ||--o{ SALESORDER : "creates"
    EMPLOYEE ||--o{ DEAL : "creates"
    EMPLOYEE ||--o{ PRODUCTIONORDER : "creates"
    EMPLOYEE ||--o{ DELIVERY : "delivers"
    EMPLOYEE ||--o{ STOCK : "stocks"
    EMPLOYEE ||--o{ SALARYPAYMENT : "receives"
    EMPLOYEE ||--o{ TAILORASSIGNMENT : "assigned"

    EMPLOYEE }o--|| DEPARTMENT : "belongs to"
    EMPLOYEE }o--|| EMPLOYEEROLE : "has"

    PRODUCT ||--o{ SALESORDERITEM : "included in"
    PRODUCT ||--o{ DEALITEM : "included in"
    PRODUCT ||--o{ PRODUCTIONORDER : "produced"
    PRODUCT ||--o{ STOCK : "stocked"
    PRODUCT ||--o{ TAILORASSIGNMENT : "assigned"
    PRODUCT }o--|| PRODUCTMATERIALREQUIREMENT : "requires"

    RAWMATERIAL ||--o{ RAWMATERIALPURCHASE : "purchased"
    RAWMATERIAL }o--|| PRODUCTMATERIALREQUIREMENT : "used in"

    SALESORDER ||--o{ SALESORDERITEM : "contains"
    SALESORDER ||--o{ DELIVERY : "delivered"
    SALESORDER ||--o{ TAILORASSIGNMENT : "assigned"
    SALESORDER }o--|| RETAILER : "from"

    RETAILER ||--o{ SALESORDER : "places"

    DEAL ||--o{ DEALITEM : "contains"
    DEAL ||--o{ DELIVERY : "delivered"
    DEAL ||--o{ TAILORASSIGNMENT : "assigned"

    PRODUCTIONORDER ||--o{ TAILORASSIGNMENT : "has"

    TAILORASSIGNMENT }o--|| EMPLOYEE : "tailor"
    TAILORASSIGNMENT }o--|| PRODUCT : "product"
    TAILORASSIGNMENT }o--|| PRODUCTIONORDER : "production"
```

## Database Schema Overview

### Core Entities

| Entity | Purpose | Key Fields |
|--------|---------|-----------|
| **Employee** | Staff members with roles and departments | EmployeeID, FirstName, LastName, Salary, RoleID |
| **Department** | Organizational departments | DepartmentID, DepartmentName |
| **EmployeeRole** | Job roles (Owner, Manager, Tailor, etc.) | RoleID, RoleName |
| **Product** | Garment products | ProductID, ProductName, Category, Price |
| **RawMaterial** | Raw materials (fabric, thread, etc.) | RawMaterialID, MaterialName, Quantity, UnitPrice |

### Sales & Orders

| Entity | Purpose | Key Fields |
|--------|---------|-----------|
| **Retailer** | Retail customers | RetailerID, CompanyName, ContactPerson |
| **SalesOrder** | Orders from retailers | SalesOrderID, OrderDate, RetailerID, Status |
| **SalesOrderItem** | Line items in sales orders | SalesOrderItemID, SalesOrderID, ProductID, Quantity |
| **Deal** | Special deals/projects | DealID, DealTitle, ClientName, Status |
| **DealItem** | Line items in deals | DealItemID, DealID, ProductID, Quantity |

### Production & Manufacturing

| Entity | Purpose | Key Fields |
|--------|---------|-----------|
| **ProductionOrder** | Manufacturing orders | ProductionOrderID, ProductID, QuantityOrdered, Status |
| **TailorAssignment** | Assign products to tailors | AssignmentID, TailorID, ProductID, QuantityAssigned |
| **ProductMaterialRequirement** | Material needed per product | ProductID, RawMaterialID, QuantityRequired |
| **Stock** | Product stock tracking | StockID, ProductID, QuantityStocked, Location |

### Finance & Logistics

| Entity | Purpose | Key Fields |
|--------|---------|-----------|
| **Delivery** | Order/Deal deliveries | DeliveryID, SalesOrderID/DealID, DeliveryDate, Status |
| **SalaryPayment** | Employee salary records | PaymentID, EmployeeID, TotalAmount, PaymentDate |
| **RawMaterialPurchase** | Purchase tracking (automated) | PurchaseID, RawMaterialID, PurchaseDate, TotalAmount |
| **MiscExpense** | Other expenses | ExpenseID, ExpenseName, Amount, Category |
| **MonthlyRevenue** | Financial summary | RevenueID, Month, Year, SalesIncome, ExpenseAmount |

### Workflow Management

| Entity | Purpose | Key Fields |
|--------|---------|-----------|
| **OrderApproval** | Approval workflow for orders/deals | ApprovalID, OrderType, OrderID, Status, ApprovalDate |

## Key Relationships

### Sales Flow
```
Retailer → SalesOrder → SalesOrderItem → Product
                                      ↓
                            ProductionOrder
                                      ↓
                            TailorAssignment
                                      ↓
                            (Delivery)
```

### Deal Flow
```
Deal → DealItem → Product
         ↓
    ProductionOrder
         ↓
    TailorAssignment
         ↓
    (Delivery)
```

### Material Flow
```
RawMaterial ← (Automated Purchase)
     ↓
ProductMaterialRequirement
     ↓
Product
     ↓
SalesOrder / Deal
```

### Revenue Tracking (Automated)
```
SalesOrder → Revenue
Deal → Revenue
RawMaterialPurchase → Expense
SalaryPayment → Expense
MiscExpense → Expense
= MonthlyRevenue (Profit/Loss)
```

## Automation Features

✅ **Auto-Record Purchases**: Raw material additions/updates automatically recorded in `RawMaterialPurchase`
✅ **Auto-Calculate Totals**: Sales order and deal item totals auto-calculated
✅ **Auto-Pay Salaries**: Monthly salaries automatically deducted from revenue
✅ **Auto-Track Revenue**: All income/expenses automatically tracked in `MonthlyRevenue`
✅ **Approval Workflow**: Orders/deals require approval before production

