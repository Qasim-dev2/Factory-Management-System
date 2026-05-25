# 🗄️ GARMENTS FACTORY DATABASE - COMPLETE DOCUMENTATION

## 📊 Database Overview

**Database Name:** GarmentsFactoryDB  
**Server:** QASIM\SQLEXPRESS  
**Total Tables:** 21  
**Total Procedures:** 157  
**Total Triggers:** 2  
**Version:** 1.0  
**Last Updated:** December 2025

---

## 📁 COMPLETE FILE STRUCTURE

### **Setup & Documentation Files**

| File | Purpose | Objects | Time |
|------|---------|---------|------|
| **000_MASTER_SETUP_GUIDE.sql** | Master setup instructions | Guide only | N/A |
| **00_MASTER_DATABASE_INDEX.md** | Complete documentation index | Index | N/A |
| **95_CompleteDatabase_Schema.sql** | All tables + relationships | 21 tables, 24 FKs, 24 indexes | ~2 min |
| **96_StoredProcedures_Part1_Core.sql** | Core management procedures | ~40 procedures | ~1 min |
| **97_StoredProcedures_Part2_Sales.sql** | Sales & deals procedures | ~25 procedures | ~1 min |
| **98_StoredProcedures_Part3_Production.sql** | Production & finance procedures | ~35 procedures | ~1 min |
| **99_Triggers_Complete.sql** | Automated triggers | 2 triggers | <1 min |
| **100_QuickReference_AllProcedures.sql** | Complete procedure catalog | Reference | <1 min |
| **ER_Diagram.md** | Visual entity relationships | Diagram | N/A |

---

## 🗂️ DATABASE TABLES (21 TABLES)

### **1. Core Management Tables**

#### **Department**
```sql
Fields: 7
Purpose: Organizational structure
Key Fields: DepartmentID (PK), DepartmentName, Budget
Relationships: → Employee (1:N)
```

#### **Employee**
```sql
Fields: 24
Purpose: Staff management with authentication
Key Fields: EmployeeID (PK), DepartmentID (FK), Username, Password
Features: Login tracking, role-based access
Relationships: ← Department (N:1), → Multiple tables as CreatedBy
```

#### **Product**
```sql
Fields: 11
Purpose: Product catalog
Key Fields: ProductID (PK), SKU, ProductName, UnitPrice
Relationships: → ProductMaterialRequirement (1:N), → SalesOrderItem (1:N)
```

#### **RawMaterial**
```sql
Fields: 11
Purpose: Materials with auto-purchase tracking
Key Fields: RawMaterialID (PK), MaterialName, Quantity, MinimumStockLevel
Features: Auto-records purchases, low stock alerts
Relationships: → PurchaseHistory (1:N), → StockUsage (1:N)
```

#### **Retailer**
```sql
Fields: 13
Purpose: B2B customers
Key Fields: RetailerID (PK), CompanyName, ContactPerson
Relationships: → SalesOrder (1:N)
```

### **2. Sales Management Tables**

#### **SalesOrder**
```sql
Fields: 14
Purpose: Customer orders with auto-approval workflow
Key Fields: SalesOrderID (PK), RetailerID (FK), TotalAmount, Status
Features: Auto-creates approval request, triggers delivery creation
Relationships: ← Retailer (N:1), → SalesOrderItem (1:N), → OrderApproval (1:1)
Triggers: 
  - trg_CreateDeliveryOnSalesOrder (AFTER UPDATE)
  - trg_UpdateDeliveryOnSalesOrderStatusChange (AFTER UPDATE)
```

#### **SalesOrderItem**
```sql
Fields: 10
Purpose: Order line items with auto-totaling
Key Fields: SalesOrderItemID (PK), SalesOrderID (FK), ProductID (FK)
Features: Auto-updates parent order total
Relationships: ← SalesOrder (N:1), ← Product (N:1)
```

#### **Deal**
```sql
Fields: 18
Purpose: Large contracts/bulk orders
Key Fields: DealID (PK), ClientName, TotalAmount, Status
Features: Auto-creates approval request
Relationships: → DealItem (1:N), → OrderApproval (1:1)
```

#### **DealItem**
```sql
Fields: 6
Purpose: Deal line items with auto-totaling
Key Fields: DealItemID (PK), DealID (FK), ProductID (FK)
Features: Auto-updates parent deal total
Relationships: ← Deal (N:1), ← Product (N:1)
```

### **3. Workflow Management Tables**

#### **OrderApproval**
```sql
Fields: 10
Purpose: Order/deal approval workflow
Key Fields: ApprovalID (PK), OrderType, OrderID, Status
Features: Tracks approval requests, rejections
Relationships: Links to SalesOrder or Deal
```

### **4. Production Management Tables**

#### **ProductionOrder**
```sql
Fields: 11
Purpose: Manufacturing orders
Key Fields: ProductionOrderID (PK), ProductID (FK), QuantityOrdered
Features: Status tracking, priority management
Relationships: ← Product (N:1), → TailorAssignment (1:N)
```

#### **TailorAssignment**
```sql
Fields: 12
Purpose: Work assignments for tailors
Key Fields: TailorAssignmentID (PK), TailorID (FK), ProductionOrderID (FK)
Features: Progress tracking, completion status
Relationships: ← Employee (N:1), ← ProductionOrder (N:1)
```

#### **ProductMaterialRequirement**
```sql
Fields: 5
Purpose: Bill of Materials (BOM)
Key Fields: ProductID (FK), RawMaterialID (FK), QuantityRequired
Features: Defines material needs per product
Relationships: ← Product (N:1), ← RawMaterial (N:1)
```

### **5. Stock & Material Management Tables**

#### **PurchaseHistory**
```sql
Fields: 10
Purpose: Material purchase records
Key Fields: PurchaseID (PK), RawMaterialID (FK)
Features: Auto-recorded by material procedures
Relationships: ← RawMaterial (N:1)
```

#### **StockUsage**
```sql
Fields: 8
Purpose: Material consumption tracking
Key Fields: StockUsageID (PK), RawMaterialID (FK), ProductionOrderID (FK)
Features: Tracks who used what for which order
Relationships: ← RawMaterial (N:1), ← ProductionOrder (N:1)
```

### **6. Delivery Management Tables**

#### **Delivery**
```sql
Fields: 12
Purpose: Shipment tracking
Key Fields: DeliveryID (PK), SalesOrderID (FK), DealID (FK)
Features: Auto-created by trigger, status tracking
Relationships: ← SalesOrder (N:1) or ← Deal (N:1)
Created By: trg_CreateDeliveryOnSalesOrder trigger
```

### **7. Financial Management Tables**

#### **Salary**
```sql
Fields: 11
Purpose: Payroll records
Key Fields: SalaryID (PK), EmployeeID (FK), NetSalary
Features: Auto-generated monthly, payment tracking
Relationships: ← Employee (N:1)
```

#### **MiscExpense**
```sql
Fields: 7
Purpose: Other expenses
Key Fields: ExpenseID (PK), Category, Amount
Features: General expense tracking
```

#### **Revenue**
```sql
Fields: 7
Purpose: Income tracking
Key Fields: RevenueID (PK), Source, Amount
Features: Revenue categorization
```

#### **OrderStatistics**
```sql
Fields: 6
Purpose: Analytics cache
Key Fields: StatID (PK), TotalOrders, TotalRevenue
Features: Performance optimization for dashboards
```

---

## 🔄 KEY RELATIONSHIPS

### **Primary Relationships**

```
Department (1) ─────────────→ (N) Employee
Employee (1) ─────────────────→ (N) SalesOrder (as SalesRep)
Employee (1) ─────────────────→ (N) Deal (as CreatedBy)
Employee (1) ─────────────────→ (N) TailorAssignment (as Tailor)
Retailer (1) ─────────────────→ (N) SalesOrder
Product (1) ──────────────────→ (N) SalesOrderItem
Product (1) ──────────────────→ (N) DealItem
Product (1) ──────────────────→ (N) ProductMaterialRequirement
RawMaterial (1) ──────────────→ (N) ProductMaterialRequirement
RawMaterial (1) ──────────────→ (N) PurchaseHistory
RawMaterial (1) ──────────────→ (N) StockUsage
SalesOrder (1) ───────────────→ (N) SalesOrderItem
SalesOrder (1) ───────────────→ (1) OrderApproval
SalesOrder (1) ───────────────→ (1) Delivery
Deal (1) ─────────────────────→ (N) DealItem
Deal (1) ─────────────────────→ (1) OrderApproval
Deal (1) ─────────────────────→ (1) Delivery
ProductionOrder (1) ──────────→ (N) TailorAssignment
ProductionOrder (1) ──────────→ (N) StockUsage
```

---

## ⚙️ AUTOMATED WORKFLOWS

### **1. Sales Order Creation → Approval → Production → Delivery**

```
Step 1: Create Order
  sp_AddSalesOrder
    ↓
  AUTO: Creates OrderApproval (Status: Pending)
    ↓
  sp_AddSalesOrderItem (for each item)
    ↓
  AUTO: Updates SalesOrder.TotalAmount

Step 2: Approval
  sp_GetPendingApprovals (Owner views)
    ↓
  sp_ApproveOrderAndCreateProduction
    ↓
  AUTO: Checks material availability
    ↓
  AUTO: Creates ProductionOrder
    ↓
  AUTO: Creates TailorAssignments
    ↓
  AUTO: Updates OrderApproval (Status: Approved)
    ↓
  AUTO: Updates SalesOrder (Status: Approved)
    ↓
  TRIGGER: trg_CreateDeliveryOnSalesOrder fires
    ↓
  AUTO: Creates Delivery (Status: Pending, +7 days)

Step 3: Production
  sp_UpdateTailorProgress (Tailors update)
    ↓
  sp_UpdateProductionOrder (Status: Completed)
    ↓
  sp_UpdateSalesOrderStatus (Status: Completed)
    ↓
  TRIGGER: trg_UpdateDeliveryOnSalesOrderStatusChange fires
    ↓
  AUTO: Updates Delivery (Status: Ready for Delivery)

Step 4: Delivery
  sp_GetDeliveriesByPerson (Delivery person views)
    ↓
  sp_UpdateDeliveryStatus (Status: In Transit)
    ↓
  sp_UpdateDeliveryStatus (Status: Delivered)
```

### **2. Material Management Workflow**

```
Scenario A: New Material
  sp_CreateRawMaterial
    ↓
  AUTO: Records initial purchase in PurchaseHistory

Scenario B: Restock Material
  sp_RestockRawMaterial
    ↓
  AUTO: Increases RawMaterial.Quantity
    ↓
  AUTO: Records purchase in PurchaseHistory

Scenario C: Production Usage
  sp_DeductRawMaterialStock
    ↓
  AUTO: Reads ProductMaterialRequirement (BOM)
    ↓
  AUTO: Deducts from RawMaterial.Quantity
    ↓
  AUTO: Records in StockUsage

Scenario D: Low Stock Alert
  sp_GetLowStockRawMaterials
    ↓
  Returns materials where Quantity < MinimumStockLevel
```

### **3. Salary Management Workflow**

```
Monthly Salary Generation
  sp_AutoPayPastSalaries (run monthly)
    ↓
  AUTO: Loops through all active employees
    ↓
  AUTO: Creates Salary record for current month
    ↓
  AUTO: Sets Status: Pending

Payment Processing
  sp_GetPendingSalaries (view pending)
    ↓
  sp_UpdateSalary (process payment)
    ↓
  Updates Status: Paid, PaymentDate: Today
```

---

## 📊 PROCEDURE CATEGORIES

### **Authentication (3 procedures)**
- sp_AuthenticateUser
- sp_UpdateLastLogin
- sp_UpdateEmployeeCredentials

### **Department Management (6 procedures)**
- sp_GetAllDepartments
- sp_GetDepartmentById
- sp_GetDepartmentsWithEmployeeCount
- sp_AddDepartment
- sp_UpdateDepartment
- sp_DeleteDepartment

### **Employee Management (8 procedures)**
- sp_GetAllEmployees
- sp_GetEmployeeById
- sp_GetEmployeesByDepartment
- sp_GetEmployeeRoles
- sp_GetSalesRepresentatives
- sp_AddEmployee
- sp_UpdateEmployee
- sp_DeleteEmployee

### **Product Management (8 procedures)**
- sp_GetAllProducts
- sp_GetProductById
- sp_SearchProducts
- sp_AddProduct
- sp_UpdateProduct
- sp_DeleteProduct
- sp_GetProductMaterials
- sp_AddProductMaterialRequirement

### **Raw Material Management (9 procedures)**
- sp_GetAllRawMaterials
- sp_GetRawMaterialById
- sp_SearchRawMaterials
- sp_CreateRawMaterial (AUTO-PURCHASE)
- sp_UpdateRawMaterial (AUTO-PURCHASE if qty increases)
- sp_DeleteRawMaterial
- sp_RestockRawMaterial (AUTO-PURCHASE)
- sp_GetLowStockRawMaterials
- sp_GetPurchaseHistory

### **Retailer Management (6 procedures)**
- sp_GetAllRetailers
- sp_GetRetailerById
- sp_SearchRetailers
- sp_AddRetailer
- sp_UpdateRetailer
- sp_DeleteRetailer

### **Sales Order Management (9 procedures)**
- sp_GetAllSalesOrders
- sp_GetSalesOrderById
- sp_AddSalesOrder (AUTO-APPROVAL REQUEST)
- sp_AddSalesOrderItem (AUTO-TOTAL)
- sp_UpdateSalesOrder
- sp_UpdateSalesOrderStatus
- sp_DeleteSalesOrder
- sp_GetSalesOrdersByDateRange
- sp_SearchSalesOrders

### **Deal Management (10 procedures)**
- sp_GetAllDeals
- sp_GetDealById
- sp_GetDealItems
- sp_AddDeal (AUTO-APPROVAL REQUEST)
- sp_AddDealItem (AUTO-TOTAL)
- sp_UpdateDeal
- sp_DeleteDeal
- sp_DeleteDealItem
- sp_GetDealsByDateRange
- sp_GetDealsByStatus
- sp_GetDealsByEmployee

### **Order Approval (4 procedures)**
- sp_GetPendingApprovals
- sp_ApproveOrderAndCreateProduction (AUTO-PRODUCTION + TAILORS)
- sp_RejectOrder
- sp_GetApprovalHistory

### **Production Management (10 procedures)**
- sp_GetAllProductionOrders
- sp_GetProductionOrderById
- sp_GetProductionOrdersByStatus
- sp_UpdateProductionOrder
- sp_DeleteProductionOrder
- sp_GetAllTailorAssignments
- sp_GetTailorAssignmentsByTailor
- sp_UpdateTailorProgress
- sp_GetTailorWorkload
- sp_GetProductionManagerStatistics

### **Delivery Management (5 procedures)**
- sp_GetAllDeliveries
- sp_GetDeliveriesByPerson
- sp_GetDeliveriesByStatus
- sp_UpdateDeliveryStatus
- sp_GetDeliveryStatistics

### **Stock Management (10 procedures)**
- sp_GetLowStockRawMaterials
- sp_RecordStockUsage
- sp_GetStockUsageHistory
- sp_GetPurchaseHistory
- sp_DeductRawMaterialStock (AUTO-BOM DEDUCTION)
- Plus additional stock procedures...

### **Financial Management (15 procedures)**
- sp_GetAllSalaries
- sp_GetSalaryByEmployee
- sp_AddSalary
- sp_UpdateSalary
- sp_GetPendingSalaries
- sp_AutoPayPastSalaries (AUTO-GENERATE MONTHLY)
- sp_GetRevenueByDateRange
- sp_GetMonthlyRevenue
- sp_GetExpensesByDateRange
- sp_GetProfitLoss
- Plus additional finance procedures...

### **Analytics & Dashboards (15 procedures)**
- sp_GetOwnerDashboardStatistics
- sp_GetSalesManagerStatistics
- sp_GetProductionManagerStatistics
- sp_GetDeliveryStatistics
- sp_GetDepartmentAnalytics
- sp_GetTopSellingProducts
- Plus additional analytics procedures...

---

## 🎯 SUMMARY

**Total Database Objects:**
- 21 Tables
- 157 Stored Procedures
- 2 Automated Triggers
- 24 Foreign Key Relationships
- 24+ Performance Indexes

**Key Features:**
- ✅ Complete audit trail (CreatedDate, UpdatedDate on all tables)
- ✅ Role-based access control (Employee roles)
- ✅ Automated workflows (triggers + procedures)
- ✅ Auto-calculation (order totals, material usage)
- ✅ Financial tracking (revenue, expenses, profit/loss)
- ✅ Production management (tailors, materials, orders)
- ✅ Delivery tracking (auto-creation, status sync)
- ✅ Stock management (low stock alerts, usage tracking)

**Ready for:**
- Production deployment
- Multi-user concurrent access
- Financial reporting
- Performance analytics
- Inventory management
- Order fulfillment
- Employee management

---

**Last Updated:** December 2025  
**Version:** 1.0.0  
**Status:** Production Ready ✅
