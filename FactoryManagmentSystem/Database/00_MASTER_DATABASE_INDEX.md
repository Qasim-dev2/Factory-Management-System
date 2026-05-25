# 📚 GARMENTS FACTORY DATABASE - MASTER INDEX
**Database:** GarmentsFactoryDB  
**Server:** QASIM\SQLEXPRESS  
**Documentation Date:** December 2025  
**Version:** 1.0

---

## 📋 TABLE OF CONTENTS

1. [Quick Start](#quick-start)
2. [Database Schema Files](#database-schema-files)
3. [Stored Procedures Catalog](#stored-procedures-catalog)
4. [Triggers & Automation](#triggers--automation)
5. [Database Statistics](#database-statistics)
6. [Common Usage Examples](#common-usage-examples)
7. [Troubleshooting](#troubleshooting)

---

## 🚀 QUICK START

### Database Setup (In Order)
```sql
-- Step 1: Create database structure
USE master;
GO
-- Execute: 95_CompleteDatabase_Schema.sql

-- Step 2: Create core management procedures
-- Execute: 96_StoredProcedures_Part1_Core.sql

-- Step 3: Create sales & deals procedures
-- Execute: 97_StoredProcedures_Part2_Sales.sql

-- Step 4: Create production & finance procedures
-- Execute: 98_StoredProcedures_Part3_Production.sql

-- Step 5: Create automated triggers
-- Execute: 99_Triggers_Complete.sql

-- Step 6: Quick reference
-- See: 100_QuickReference_AllProcedures.sql
```

---

## 📁 DATABASE SCHEMA FILES

### **95_CompleteDatabase_Schema.sql**
**Purpose:** Complete database structure with all tables, relationships, and indexes

**Contains:**
- ✅ 21 Tables (complete definitions)
- ✅ 24 Foreign Key Relationships
- ✅ 24 Performance Indexes
- ✅ Column descriptions and purposes
- ✅ Relationship documentation

**Tables Included:**
1. Department (organizational structure)
2. Employee (staff management with credentials)
3. Product (inventory items)
4. RawMaterial (materials with auto-purchase tracking)
5. PurchaseHistory (material purchase records)
6. ProductMaterialRequirement (bill of materials)
7. Retailer (B2B customers)
8. SalesOrder (customer orders)
9. SalesOrderItem (order line items with auto-totaling)
10. Deal (large contracts)
11. DealItem (deal line items with auto-totaling)
12. OrderApproval (approval workflow)
13. ProductionOrder (manufacturing orders)
14. TailorAssignment (work assignments)
15. StockUsage (material consumption tracking)
16. Delivery (shipment management)
17. Salary (payroll records)
18. MiscExpense (other expenses)
19. Revenue (income tracking)
20. OrderStatistics (analytics cache)
21. sysdiagrams (ER diagrams)

---

## 📦 STORED PROCEDURES CATALOG

### **Total Procedures: 157**

---

### **96_StoredProcedures_Part1_Core.sql** (~40 procedures)

#### **Section 1: Authentication (3 procedures)**
```sql
sp_AuthenticateUser              -- Login validation
sp_UpdateLastLogin               -- Track login timestamps
sp_UpdateEmployeeCredentials     -- Password management
```

#### **Section 2: Department Management (6 procedures)**
```sql
sp_GetAllDepartments            -- List all departments
sp_GetDepartmentById            -- Single department details
sp_GetDepartmentsWithEmployeeCount  -- Departments + employee counts
sp_AddDepartment                -- Create new department
sp_UpdateDepartment             -- Edit department
sp_DeleteDepartment             -- Remove department
```

#### **Section 3: Employee Management (8 procedures)**
```sql
sp_GetAllEmployees              -- List all employees (24 fields)
sp_GetEmployeeById              -- Single employee details
sp_GetEmployeesByDepartment     -- Filter by department
sp_AddEmployee                  -- Create employee + credentials
sp_UpdateEmployee               -- Edit employee details
sp_DeleteEmployee               -- Remove employee
sp_GetEmployeeRoles             -- Get distinct roles
sp_GetSalesRepresentatives      -- Sales team members
```

#### **Section 4: Product Management (8 procedures)**
```sql
sp_GetAllProducts               -- List all products
sp_GetProductById               -- Single product details
sp_SearchProducts               -- Search by name/SKU
sp_AddProduct                   -- Create product
sp_UpdateProduct                -- Edit product
sp_DeleteProduct                -- Remove product
sp_GetProductMaterials          -- Materials needed for product
sp_AddProductMaterialRequirement -- Define material needs
```

#### **Section 5: Raw Material Management (9 procedures)**
```sql
sp_GetAllRawMaterials           -- List all materials
sp_GetRawMaterialById           -- Single material details
sp_SearchRawMaterials           -- Search materials
sp_CreateRawMaterial            -- Create + AUTO-RECORD purchase
sp_UpdateRawMaterial            -- Update + AUTO-RECORD purchase if qty increases
sp_DeleteRawMaterial            -- Remove material
sp_RestockRawMaterial           -- Restock + AUTO-RECORD purchase
sp_GetLowStockRawMaterials      -- Materials below minimum
sp_GetPurchaseHistory           -- Material purchase records
```

#### **Section 6: Retailer Management (6 procedures)**
```sql
sp_GetAllRetailers              -- List all retailers
sp_GetRetailerById              -- Single retailer details
sp_SearchRetailers              -- Search retailers
sp_AddRetailer                  -- Create retailer
sp_UpdateRetailer               -- Edit retailer
sp_DeleteRetailer               -- Remove retailer
```

---

### **97_StoredProcedures_Part2_Sales.sql** (~25 procedures)

#### **Section 1: Sales Order Management (9 procedures)**
```sql
sp_GetAllSalesOrders            -- List all sales orders
sp_GetSalesOrderById            -- Order + items details
sp_AddSalesOrder                -- Create order + AUTO-CREATE approval request
sp_AddSalesOrderItem            -- Add item + AUTO-UPDATE order total
sp_UpdateSalesOrder             -- Edit order
sp_UpdateSalesOrderStatus       -- Change order status
sp_DeleteSalesOrder             -- Remove order (cascades to items)
sp_GetSalesOrdersByDateRange    -- Filter by date (revenue)
sp_SearchSalesOrders            -- Search orders
```

#### **Section 2: Deal Management (10 procedures)**
```sql
sp_GetAllDeals                  -- List all deals
sp_GetDealById                  -- Deal + items details
sp_AddDeal                      -- Create deal + AUTO-CREATE approval request
sp_AddDealItem                  -- Add item + AUTO-UPDATE deal total
sp_UpdateDeal                   -- Edit deal
sp_DeleteDeal                   -- Remove deal (cascades to items)
sp_DeleteDealItem               -- Remove item + update total
sp_GetDealsByDateRange          -- Filter by date (revenue)
sp_GetDealsByStatus             -- Filter by status
sp_GetDealsByEmployee           -- Created by employee
sp_GetDealItems                 -- Items for deal
```

#### **Section 3: Order Approval & Workflow (4 procedures)**
```sql
sp_GetPendingApprovals          -- Pending approval requests (owner dashboard)
sp_ApproveOrderAndCreateProduction  -- Approve + check materials + create production
sp_RejectOrder                  -- Reject approval request
sp_GetApprovalHistory           -- Approval audit trail
```

---

### **98_StoredProcedures_Part3_Production.sql** (~35 procedures)

#### **Section 1: Production Order Management (5 procedures)**
```sql
sp_GetAllProductionOrders       -- List all production orders
sp_GetProductionOrderById       -- Single order details
sp_UpdateProductionOrder        -- Edit production order
sp_DeleteProductionOrder        -- Remove production order
sp_GetProductionOrdersByStatus  -- Filter by status
```

#### **Section 2: Tailor Assignment & Tracking (5 procedures)**
```sql
sp_GetAllTailorAssignments      -- All assignments
sp_GetTailorAssignmentsByTailor -- Assignments for tailor
sp_UpdateTailorProgress         -- Update completion progress
sp_GetTailorWorkload            -- Current workload stats
sp_GetProductionManagerStatistics -- Production dashboard
```

#### **Section 3: Delivery Management (5 procedures)**
```sql
sp_GetAllDeliveries             -- List all deliveries
sp_GetDeliveriesByPerson        -- Deliveries for person
sp_UpdateDeliveryStatus         -- Update delivery status
sp_GetDeliveriesByStatus        -- Filter by status
sp_GetDeliveryStatistics        -- Delivery dashboard stats
```

#### **Section 4: Stock & Material Usage (5 procedures)**
```sql
sp_GetLowStockRawMaterials      -- Materials below minimum
sp_RecordStockUsage             -- Record material usage
sp_GetStockUsageHistory         -- Usage history
sp_GetPurchaseHistory           -- Purchase history
sp_DeductRawMaterialStock       -- Deduct for production
```

#### **Section 5: Salary Management & Payroll (5 procedures)**
```sql
sp_GetAllSalaries               -- All salary records
sp_GetSalaryByEmployee          -- Employee salary history
sp_AddSalary                    -- Create salary record
sp_UpdateSalary                 -- Edit salary record
sp_GetPendingSalaries           -- Pending payments
sp_AutoPayPastSalaries          -- AUTO-GENERATE monthly salaries
```

#### **Section 6: Revenue & Financial Analytics (10 procedures)**
```sql
sp_GetRevenueByDateRange        -- Revenue from orders + deals
sp_GetMonthlyRevenue            -- Revenue by month
sp_GetExpensesByDateRange       -- Salaries + materials
sp_GetProfitLoss                -- Profit/loss calculation
sp_GetTopSellingProducts        -- Best sellers
sp_GetDepartmentAnalytics       -- Department statistics
sp_GetOwnerDashboardStatistics  -- Owner dashboard
sp_GetSalesManagerStatistics    -- Sales manager dashboard
```

---

## ⚙️ TRIGGERS & AUTOMATION

### **99_Triggers_Complete.sql** (2 triggers)

#### **Trigger 1: trg_CreateDeliveryOnSalesOrder**
**Table:** SalesOrder  
**Event:** AFTER UPDATE  
**Purpose:** Auto-create delivery when order approved

**Workflow:**
```
SalesOrder Status → 'Approved'
    ↓
Trigger Fires
    ↓
Creates Delivery Record:
- SalesOrderID: linked
- DeliveryAddress: from ShippingAddress
- ScheduledDate: +7 days
- Status: 'Pending'
```

**Example:**
```sql
UPDATE SalesOrder SET Status = 'Approved' WHERE SalesOrderID = 1;
-- Automatically creates delivery scheduled for 7 days later
```

---

#### **Trigger 2: trg_UpdateDeliveryOnSalesOrderStatusChange**
**Table:** SalesOrder  
**Event:** AFTER UPDATE  
**Purpose:** Sync delivery status with order status

**Status Mappings:**
```
SalesOrder: 'Completed'  → Delivery: 'Ready for Delivery'
SalesOrder: 'Cancelled'  → Delivery: 'Cancelled'
SalesOrder: 'Rejected'   → Delivery: 'Cancelled'
```

**Example:**
```sql
UPDATE SalesOrder SET Status = 'Completed' WHERE SalesOrderID = 1;
-- Automatically updates delivery to 'Ready for Delivery'
```

---

## 📊 DATABASE STATISTICS

### **Tables:** 21
- Employee Management: 2 tables
- Product Management: 4 tables
- Sales Management: 5 tables
- Production Management: 3 tables
- Financial Management: 3 tables
- System Tables: 4 tables

### **Stored Procedures:** 157
- Authentication: 3
- Department: 6
- Employee: 8
- Product: 8
- Raw Material: 9
- Retailer: 6
- Sales Order: 9
- Deal: 10
- Approval: 4
- Production: 5
- Tailor: 5
- Delivery: 5
- Stock: 5
- Salary: 6
- Analytics: 10
- System: ~58 additional procedures

### **Triggers:** 2
- Auto-delivery creation
- Delivery status sync

### **Relationships:** 24 Foreign Keys
- Department → Employee
- Employee → Multiple tables (CreatedBy, etc.)
- Product → Multiple tables
- SalesOrder → SalesOrderItem
- Deal → DealItem
- ProductionOrder → TailorAssignment
- And more...

### **Indexes:** 24 Performance Indexes
- Foreign key indexes
- Search optimization indexes
- Unique constraints

---

## 💡 COMMON USAGE EXAMPLES

### **1. Create New Sales Order (Complete Workflow)**
```sql
-- Step 1: Create order (auto-creates approval request)
DECLARE @OrderID INT;
EXEC sp_AddSalesOrder
    @OrderDate = '2025-12-15',
    @RetailerID = 1,
    @ShippingAddress = '123 Main St, Lahore',
    @SalesRepID = 5,
    @NewSalesOrderID = @OrderID OUTPUT;

-- Step 2: Add items (auto-updates order total)
DECLARE @ItemID INT;
EXEC sp_AddSalesOrderItem
    @SalesOrderID = @OrderID,
    @ProductID = 1,
    @Quantity = 100,
    @UnitPrice = 500,
    @SalesOrderItemID = @ItemID OUTPUT;

-- Step 3: Owner approves (auto-creates delivery + production)
EXEC sp_ApproveOrderAndCreateProduction
    @ApprovalID = 1,
    @OwnerID = 1,
    @TailorIDs = '10,11,12';  -- Comma-separated tailor IDs
```

### **2. Material Management**
```sql
-- Check low stock materials
EXEC sp_GetLowStockRawMaterials;

-- Restock material (auto-records purchase)
DECLARE @MaterialID INT = 1;
EXEC sp_RestockRawMaterial
    @RawMaterialID = @MaterialID,
    @QuantityToAdd = 500,
    @RecordedBy = 1;
```

### **3. Financial Reports**
```sql
-- Get profit/loss for current month
DECLARE @StartDate DATE = '2025-12-01';
DECLARE @EndDate DATE = '2025-12-31';
EXEC sp_GetProfitLoss @StartDate, @EndDate;

-- Get top selling products
EXEC sp_GetTopSellingProducts @TopCount = 10;

-- Get department analytics
EXEC sp_GetDepartmentAnalytics;
```

### **4. Dashboard Statistics**
```sql
-- Owner Dashboard
EXEC sp_GetOwnerDashboardStatistics;

-- Sales Manager Dashboard
EXEC sp_GetSalesManagerStatistics;

-- Production Manager Dashboard
EXEC sp_GetProductionManagerStatistics;
```

---

## 🔧 TROUBLESHOOTING

### **Issue: Procedure Not Found**
```sql
-- Check if procedure exists
SELECT name, type_desc, create_date 
FROM sys.objects 
WHERE type = 'P' AND name = 'sp_YourProcedureName';

-- Re-run appropriate script file
```

### **Issue: Trigger Not Firing**
```sql
-- Check trigger status
SELECT name, is_disabled, create_date
FROM sys.triggers
WHERE name LIKE 'trg_%';

-- Enable trigger if disabled
ENABLE TRIGGER trg_CreateDeliveryOnSalesOrder ON SalesOrder;
```

### **Issue: Foreign Key Violations**
```sql
-- Check all foreign keys
SELECT 
    fk.name AS ForeignKeyName,
    tp.name AS ParentTable,
    tr.name AS ReferencedTable
FROM sys.foreign_keys fk
JOIN sys.tables tp ON fk.parent_object_id = tp.object_id
JOIN sys.tables tr ON fk.referenced_object_id = tr.object_id
ORDER BY tp.name;
```

### **Issue: Performance Problems**
```sql
-- Check missing indexes
SELECT 
    t.name AS TableName,
    c.name AS ColumnName,
    i.name AS IndexName
FROM sys.tables t
JOIN sys.columns c ON t.object_id = c.object_id
LEFT JOIN sys.index_columns ic ON c.object_id = ic.object_id AND c.column_id = ic.column_id
LEFT JOIN sys.indexes i ON ic.object_id = i.object_id AND ic.index_id = i.index_id
WHERE t.name NOT LIKE 'sys%'
ORDER BY t.name, c.name;
```

---

## 📖 FILE EXECUTION ORDER

**Always execute in this order:**

1. **95_CompleteDatabase_Schema.sql** (Tables + relationships)
2. **96_StoredProcedures_Part1_Core.sql** (Core procedures)
3. **97_StoredProcedures_Part2_Sales.sql** (Sales procedures)
4. **98_StoredProcedures_Part3_Production.sql** (Production procedures)
5. **99_Triggers_Complete.sql** (Automation triggers)

**Optional Reference:**
- **100_QuickReference_AllProcedures.sql** (Complete list with examples)
- **00_MASTER_DATABASE_INDEX.md** (This file - overview)

---

## 📞 SUPPORT & MAINTENANCE

### **Database Backup**
```sql
BACKUP DATABASE GarmentsFactoryDB 
TO DISK = 'C:\Backups\GarmentsFactoryDB.bak'
WITH FORMAT, COMPRESSION;
```

### **Check Database Size**
```sql
EXEC sp_spaceused;
```

### **View All Objects**
```sql
SELECT 
    type_desc AS ObjectType,
    COUNT(*) AS Count
FROM sys.objects
WHERE is_ms_shipped = 0
GROUP BY type_desc
ORDER BY type_desc;
```

---

## ✅ VERIFICATION CHECKLIST

After setup, verify:

- [ ] All 21 tables exist
- [ ] All 157 procedures created
- [ ] Both triggers enabled
- [ ] Foreign keys intact
- [ ] Indexes created
- [ ] Sample data inserted (if using sample scripts)
- [ ] Authentication works
- [ ] Dashboards return data

---

**Last Updated:** December 2025  
**Maintained By:** Database Administrator  
**Version:** 1.0.0
