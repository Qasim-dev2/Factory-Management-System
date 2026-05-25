# Database Schema Documentation
## File: 95_CompleteDatabase_Schema.sql

This comprehensive SQL file contains the complete database schema for the **Garments Factory Management System** with detailed comments and documentation.

## File Structure

### PART 1: CORE REFERENCE TABLES
- **Department**: Organizational departments (Production, Sales, Management)
- **EmployeeRole**: Job roles with descriptions

### PART 2: EMPLOYEE MANAGEMENT TABLES
- **Employee**: Staff information, payroll, authentication, specialization, piece rates

### PART 3: PRODUCT & MATERIAL MANAGEMENT TABLES
- **Product**: Garment products with specifications
- **RawMaterial**: Raw materials inventory (fabrics, threads, buttons, etc.)
- **RawMaterialPurchase**: Auto-recorded purchase history (tracks all purchases automatically)
- **ProductMaterialRequirement**: Bill of Materials - what materials needed per product

### PART 4: SALES & RETAIL MANAGEMENT TABLES
- **Retailer**: Retail customer information
- **SalesOrder**: Orders from retailers
- **SalesOrderItem**: Line items with products, quantities, prices

### PART 5: DEALS & SPECIAL PROJECTS TABLES
- **Deal**: Special deals, bulk orders, corporate projects
- **DealItem**: Line items for deals

### PART 6: PRODUCTION & MANUFACTURING TABLES
- **ProductionOrder**: Manufacturing orders created from approved sales/deals
- **TailorAssignment**: Assigns production tasks to employees with tracking

### PART 7: INVENTORY & STOCK MANAGEMENT TABLES
- **Stock**: Finished product inventory tracking with location/batch info

### PART 8: DELIVERY & LOGISTICS TABLES
- **Delivery**: Delivery tracking for sales orders and deals with status

### PART 9: FINANCIAL & REVENUE MANAGEMENT TABLES
- **SalaryPayment**: Monthly salary payment records (auto-calculated)
- **MiscExpense**: Miscellaneous expenses (utilities, maintenance, etc.)
- **MonthlyRevenue**: Monthly financial summary (auto-calculated)

### PART 10: WORKFLOW & APPROVAL TABLES
- **OrderApproval**: Approval workflow for orders before production

## Key Features

### Comprehensive Comments
Every table includes:
- ✅ Table name and purpose
- ✅ Column names with data types
- ✅ Relationship information
- ✅ Inline comments for each column
- ✅ Foreign key constraints documented
- ✅ Unique constraints documented

### Performance Optimization
- **24 Indexes** created across key tables:
  - Employee: 4 indexes (Email, Department, Role, IsActive)
  - Product: 3 indexes (Category, IsActive, SKU)
  - RawMaterial: 3 indexes
  - Retailer: 3 indexes
  - SalesOrder: 4 indexes (Date, Status, Retailer, SalesRep)
  - Deal: 3 indexes (Status, StartDate, CreatedBy)
  - And more for Stock, Delivery, Revenue, etc.

### Relationship Documentation
- **24 Foreign Key Relationships** documented
- Proper cascading delete rules where applicable
- Referential integrity constraints

### Automation Features Documented
1. **Raw Material Purchases** - Auto-recorded when adding/updating materials
2. **Order Totals** - Auto-calculated from line items
3. **Monthly Revenue** - Auto-calculated from all transactions
4. **Salary Payments** - Auto-paid monthly
5. **Order Approvals** - Automatic workflow creation

## Column Details by Table

### Department (5 columns)
- DepartmentID, DepartmentName, Description, CreatedDate, IsActive

### Employee (24 columns)
- Personal: FirstName, LastName, Email, Phone, CNIC, Address, EmergencyContact
- Employment: DepartmentID, RoleID, JoinDate, Position, ShiftType
- Payroll: Salary, PieceRate, TotalPiecesCompleted, Specialization
- Authentication: Username, PIN, LastLogin
- Status: IsActive, CreatedDate

### Product (14 columns)
- ProductID, ProductName, Description, Category, Brand, SalePrice
- Specifications: Material, AvailableSizes, AvailableColors
- Inventory: SKU, ProductionStatus, IsActive
- Timestamps: CreatedDate, UpdatedDate

### RawMaterial (15 columns)
- RawMaterialID, MaterialName, Category, Unit
- Inventory: Quantity, MinimumStock, StockStatus, LastRestockDate
- Supplier: Supplier, SupplierContact
- Pricing: UnitPrice
- Metadata: Description, IsActive, CreatedDate, UpdatedDate

### RawMaterialPurchase (11 columns) - **AUTO-RECORDED**
- PurchaseID, RawMaterialID, MaterialName, PurchaseDate
- Quantity, Unit, UnitPrice, TotalAmount
- SupplierName, InvoiceNumber, Notes, CreatedDate

### SalesOrder (10 columns)
- SalesOrderID, OrderDate, Status, RetailerID
- Pricing: TotalAmount, SubTotal, DiscountPercentage, DiscountAmount
- ShippingAddress, SalesRepID, CreatedDate, UpdatedDate

### Deal (18 columns)
- DealID, DealTitle, DealType
- Client: ClientName, ContactPerson, Email, Phone
- Dates: StartDate, EndDate, ExpectedDuration
- Location: DeliveryAddress, City, Province
- Business: Status, TotalAmount, Description, CreatedBy
- Timestamps: CreatedDate, UpdatedDate

### MonthlyRevenue (16 columns) - **AUTO-CALCULATED**
- RevenueID, Year, Month, MonthName
- Income: SalesIncome, DealIncome, TotalIncome
- Expenses: TotalSalaries, RawMaterialCost, MiscExpense, TotalExpense
- Summary: NetProfit, SalariesPaid, Notes
- Timestamps: CreatedDate, UpdatedDate

## Data Integrity Features

1. **Unique Constraints**
   - Department.DepartmentName (UNIQUE)
   - EmployeeRole.RoleName (UNIQUE)
   - Employee.Email (UNIQUE)
   - Employee.Username (UNIQUE)
   - Product.SKU (UNIQUE)
   - MonthlyRevenue (Year, Month) unique combination

2. **Foreign Key Constraints**
   - CASCADE DELETE on: SalesOrderItem, DealItem (when parent deleted)
   - NO ACTION on: All other relationships (prevent deletion if children exist)

3. **NOT NULL Constraints**
   - Applied to critical fields:
     - Employee: FirstName, LastName, DepartmentID, RoleID
     - Product: ProductName, SalePrice
     - RawMaterial: MaterialName, Quantity, UnitPrice
     - SalesOrder: RetailerID, TotalAmount
     - And many more...

## Usage

To use this schema:

```sql
-- 1. Open SQL Server Management Studio
-- 2. Connect to your SQL Server instance
-- 3. Run the entire script: 95_CompleteDatabase_Schema.sql
-- 4. All tables will be created with proper relationships and indexes

-- Example: Query to see all tables
SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE'

-- Example: Query to see all relationships
SELECT * FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE WHERE REFERENCED_TABLE_NAME IS NOT NULL
```

## Total Statistics

- **21 Main Tables** (excluding sysdiagrams)
- **24 Foreign Key Relationships**
- **24 Indexes** for performance optimization
- **Multiple Unique Constraints**
- **Complete Documentation** with inline comments for every column
- **691 Lines** of well-organized, production-ready SQL

## Notes

- All tables have timestamps (CreatedDate, UpdatedDate where appropriate)
- IDENTITY columns automatically generate primary keys
- Proper data types selected based on expected content
- Decimal(18,2) used for monetary values (precision for financial calculations)
- NVARCHAR used for text fields (Unicode support)
- Comprehensive indexing strategy for common queries

