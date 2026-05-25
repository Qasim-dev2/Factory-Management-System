=============================================================================
DATABASE SCHEMA & PROCEDURES REFERENCE
Garments Factory Management System
=============================================================================

TABLE OF CONTENTS:
1. TABLE SCHEMAS
   - Employee Table
   - Department Table
   - Role Table
2. RELATIONSHIP DIAGRAMS
3. STORED PROCEDURES BY CATEGORY
4. PROCEDURE TYPES & TRANSACTION FLOW
5. QUICK REFERENCE

=============================================================================
SECTION 1: TABLE SCHEMAS
=============================================================================

────────────────────────────────────────────────────────────────────────────
TABLE: Employee
────────────────────────────────────────────────────────────────────────────

Column Name              Data Type       Constraints          Description
─────────────────────────────────────────────────────────────────────────── 
EmployeeID              INT             PRIMARY KEY          Auto-increment (1, 1)
FirstName               NVARCHAR(50)    NOT NULL             Employee first name
LastName                NVARCHAR(50)    NOT NULL             Employee last name
Position                NVARCHAR(50)    NULL                 Job title/position
Phone                   NVARCHAR(20)    UNIQUE, NULL         Contact phone number
Email                   NVARCHAR(100)   UNIQUE, NULL         Corporate email
DepartmentID            INT             FOREIGN KEY          References Department(DepartmentID)
                                        NOT NULL             
RoleID                  INT             FOREIGN KEY          References Role(RoleID)
                                        NULL                 
Salary                  DECIMAL(10,2)   NULL                 Monthly salary
JoinDate                DATETIME        DEFAULT GETDATE()    Employment start date
Address                 NVARCHAR(255)   NULL                 Residential address
EmergencyContact        NVARCHAR(20)    NULL                 Emergency contact number
CNIC                    NVARCHAR(20)    UNIQUE, NULL         National ID number
IsActive                BIT             DEFAULT 1            Employee status (1=Active, 0=Inactive)
CreatedDate             DATETIME        DEFAULT GETDATE()    Record creation date
Username                NVARCHAR(50)    UNIQUE, NULL         Login username
LastLogin               DATETIME        NULL                 Last login timestamp
PIN                     NVARCHAR(10)    NULL                 Employee PIN for login

INDEXES:
- PK_Employee (EmployeeID)
- IX_Employee_DepartmentID (DepartmentID)
- IX_Employee_RoleID (RoleID)
- IX_Employee_Phone (Phone)
- IX_Employee_Email (Email)
- IX_Employee_Username (Username)
- IX_Employee_IsActive (IsActive)

────────────────────────────────────────────────────────────────────────────
TABLE: Department
────────────────────────────────────────────────────────────────────────────

Column Name              Data Type       Constraints          Description
─────────────────────────────────────────────────────────────────────────── 
DepartmentID            INT             PRIMARY KEY          Department identifier
                                        (1=Sales, 2=Prod, 3=Delivery)
DepartmentName          NVARCHAR(100)   NOT NULL, UNIQUE     Department name
Description             NVARCHAR(500)   NULL                 Department description
CreatedDate             DATETIME        DEFAULT GETDATE()    Record creation date
IsActive                BIT             DEFAULT 1            Department status

INDEXES:
- PK_Department (DepartmentID)
- IX_Department_Name (DepartmentName)

────────────────────────────────────────────────────────────────────────────
TABLE: Role
────────────────────────────────────────────────────────────────────────────

Column Name              Data Type       Constraints          Description
─────────────────────────────────────────────────────────────────────────── 
RoleID                  INT             PRIMARY KEY          Role identifier
                                        (1=Owner, 2=SalesMgr, 3=SalesPerson, 
                                         4=ProdMgr, 5=Tailor, 6=DeliveryPerson)
RoleName                NVARCHAR(50)    NOT NULL, UNIQUE     Role name
Description             NVARCHAR(500)   NULL                 Role permissions/description
CreatedDate             DATETIME        DEFAULT GETDATE()    Record creation date
IsActive                BIT             DEFAULT 1            Role status

EXISTING ROLES:
1. Owner              - System owner, full access to all features and data
2. Sales Manager      - Manages sales team, creates/approves orders
3. Sales Person       - Creates sales orders and deals
4. Production Manager - Manages production, assigns tailors
5. Tailor             - Creates garments, completes production tasks
6. Delivery Person    - Delivers finished orders to customers/retailers

INDEXES:
- PK_Role (RoleID)
- IX_Role_Name (RoleName)


=============================================================================
SECTION 2: RELATIONSHIP DIAGRAM
=============================================================================

Employee ──┐
           ├──→ Department
           │
           └──→ Role

Department:
- 1 Department has MANY Employees
- Employees must belong to exactly 1 Department

Role:
- 1 Role can have MANY Employees
- Employees can have at most 1 Role (optional)

SAMPLE DATA STRUCTURE:
┌─────────────────────────────────────────────────────────────┐
│ SALES DEPARTMENT (DepartmentID = 1)                         │
├─────────────────────────────────────────────────────────────┤
│ ✓ Ahmad Khan    (RoleID=2, Sales Manager)  Manager          │
│ ✓ Ali Ahmed     (RoleID=3, Sales Person)                    │
│ ✓ Fatima Hassan (RoleID=3, Sales Person)                    │
│ ✓ Hira Malik    (RoleID=3, Sales Person)                    │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ PRODUCTION DEPARTMENT (DepartmentID = 2)                    │
├─────────────────────────────────────────────────────────────┤
│ ✓ Hassan Ahmed  (RoleID=4, Production Manager) Manager      │
│ ✓ Zain Ali      (RoleID=5, Tailor)                          │
│ ✓ Bilal Hassan  (RoleID=5, Tailor)                          │
│ ✓ Aisha Khan    (RoleID=5, Tailor)                          │
│ ✓ Samir Hassan  (RoleID=5, Tailor)                          │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ DELIVERY DEPARTMENT (DepartmentID = 3)                      │
├─────────────────────────────────────────────────────────────┤
│ ✓ Muhammad Khan (RoleID=6, Delivery Person) Coordinator    │
│ ✓ Ahmed Ali     (RoleID=6, Delivery Person)                │
│ ✓ Hassan Malik  (RoleID=6, Delivery Person)                │
└─────────────────────────────────────────────────────────────┘


=============================================================================
SECTION 3: STORED PROCEDURES BY CATEGORY (157 Total)
=============================================================================

────────────────────────────────────────────────────────────────────────────
CATEGORY: AUTHENTICATION PROCEDURES (2)
────────────────────────────────────────────────────────────────────────────
Purpose: Handle user login and session management

1. sp_AuthenticateUser
   ├─ Type: QUERY/SELECT
   ├─ Parameters: @Username (NVARCHAR), @PIN (NVARCHAR)
   ├─ Returns: EmployeeID, FirstName, LastName, RoleID, DepartmentID, Position
   ├─ Logic: Validates credentials and returns employee info on success
   └─ Usage: Called during login process

2. sp_UpdateLastLogin
   ├─ Type: UPDATE/TRANSACTION
   ├─ Parameters: @EmployeeID (INT)
   ├─ Logic: Updates LastLogin timestamp to current time
   └─ Usage: Called after successful authentication


────────────────────────────────────────────────────────────────────────────
CATEGORY: EMPLOYEE MANAGEMENT PROCEDURES (8)
────────────────────────────────────────────────────────────────────────────
Purpose: CRUD operations for employee records

1. sp_GetEmployees
   ├─ Type: SELECT (READ)
   ├─ Parameters: None
   ├─ Returns: All active employees with all details
   └─ Usage: Employee list display

2. sp_GetEmployeeById
   ├─ Type: SELECT (READ)
   ├─ Parameters: @EmployeeID (INT)
   ├─ Returns: Single employee record with department and role info
   └─ Usage: View employee details

3. sp_AddEmployee
   ├─ Type: INSERT (CREATE)
   ├─ Parameters: FirstName, LastName, Position, Phone, Email, DepartmentID, 
   │             RoleID, Salary, JoinDate, Address, EmergencyContact, CNIC, 
   │             Username, PIN
   ├─ Returns: New EmployeeID
   ├─ Logic: Creates new employee record with validation
   └─ Usage: Add new staff member

4. sp_UpdateEmployee
   ├─ Type: UPDATE (MODIFY)
   ├─ Parameters: @EmployeeID + update fields
   ├─ Logic: Updates employee information
   └─ Usage: Edit employee details

5. sp_DeleteEmployee
   ├─ Type: DELETE (SOFT DELETE - sets IsActive = 0)
   ├─ Parameters: @EmployeeID (INT)
   ├─ Logic: Deactivates employee (not hard delete)
   └─ Usage: Remove employee from active roster

6. sp_GetEmployeesByDepartment
   ├─ Type: SELECT (READ)
   ├─ Parameters: @DepartmentID (INT)
   ├─ Returns: All employees in specified department
   └─ Usage: Department roster view

7. sp_UpdateEmployeeCredentials
   ├─ Type: UPDATE (TRANSACTION)
   ├─ Parameters: @EmployeeID, @Username, @PIN
   ├─ Logic: Updates login credentials
   └─ Usage: Password/username reset

8. sp_GetSalesRepresentatives
   ├─ Type: SELECT (READ)
   ├─ Parameters: None
   ├─ Returns: All employees with Sales Person role
   └─ Usage: Filter for sales operations


────────────────────────────────────────────────────────────────────────────
CATEGORY: DEPARTMENT MANAGEMENT PROCEDURES (5)
────────────────────────────────────────────────────────────────────────────
Purpose: Manage departments

1. sp_GetDepartments
   ├─ Type: SELECT (READ)
   ├─ Parameters: None
   ├─ Returns: All active departments
   └─ Usage: Department list

2. sp_GetAllDepartments
   ├─ Type: SELECT (READ)
   ├─ Parameters: None
   ├─ Returns: All departments with employee count
   └─ Usage: Dashboard display

3. sp_GetDepartmentById
   ├─ Type: SELECT (READ)
   ├─ Parameters: @DepartmentID (INT)
   ├─ Returns: Single department with statistics
   └─ Usage: Department details

4. sp_AddDepartment
   ├─ Type: INSERT (CREATE)
   ├─ Parameters: @DepartmentName, @Description
   ├─ Returns: New DepartmentID
   └─ Usage: Create new department

5. sp_UpdateDepartment
   ├─ Type: UPDATE (MODIFY)
   ├─ Parameters: @DepartmentID, @DepartmentName, @Description
   └─ Usage: Edit department info


────────────────────────────────────────────────────────────────────────────
CATEGORY: EMPLOYEE ROLE PROCEDURES (2)
────────────────────────────────────────────────────────────────────────────
Purpose: Manage employee roles

1. sp_GetEmployeeRoles
   ├─ Type: SELECT (READ)
   ├─ Parameters: None
   ├─ Returns: All available roles (1-6)
   └─ Usage: Role dropdown lists

2. sp_GetDepartmentsWithEmployeeCount
   ├─ Type: SELECT (READ)
   ├─ Parameters: None
   ├─ Returns: Departments with count of staff by role
   └─ Usage: Statistics and reporting


────────────────────────────────────────────────────────────────────────────
CATEGORY: SALES ORDER PROCEDURES (12)
────────────────────────────────────────────────────────────────────────────
Purpose: Manage sales orders from creation to delivery

1. sp_GetAllSalesOrders
   ├─ Type: SELECT (READ)
   ├─ Parameters: None
   ├─ Returns: All sales orders with items and totals
   └─ Usage: Sales order list

2. sp_GetSalesOrderById
   ├─ Type: SELECT (READ)
   ├─ Parameters: @SalesOrderID (INT)
   ├─ Returns: Complete order with line items and details
   └─ Usage: View order details

3. sp_AddSalesOrder
   ├─ Type: INSERT (CREATE + TRIGGER)
   ├─ Parameters: @SalespersonID, @RetailerID, @OrderDate, @DeliveryDate, 
   │             @Notes, @Discount
   ├─ Returns: New SalesOrderID
   ├─ Logic: Creates order and auto-creates approval request
   └─ Usage: Create new sales order

4. sp_AddSalesOrderItem
   ├─ Type: INSERT (CREATE + UPDATE)
   ├─ Parameters: @SalesOrderID, @ProductID, @Quantity, @UnitPrice, @Discount
   ├─ Logic: Adds line item and recalculates order total
   └─ Usage: Add products to order

5. sp_UpdateSalesOrder
   ├─ Type: UPDATE (MODIFY)
   ├─ Parameters: @SalesOrderID, @DeliveryDate, @Discount, @Notes
   └─ Usage: Update order details

6. sp_UpdateSalesOrderStatus
   ├─ Type: UPDATE (TRANSACTION)
   ├─ Parameters: @SalesOrderID, @Status
   ├─ Logic: Updates status (Pending→Approved→Shipped→Delivered)
   └─ Usage: Track order progress

7. sp_DeleteSalesOrder
   ├─ Type: DELETE (SOFT DELETE)
   ├─ Parameters: @SalesOrderID (INT)
   └─ Usage: Cancel order

8. sp_GetSalesOrdersByDateRange
   ├─ Type: SELECT (READ)
   ├─ Parameters: @StartDate, @EndDate
   ├─ Returns: Orders within date range
   └─ Usage: Historical analysis

9. sp_SearchSalesOrders
   ├─ Type: SELECT (READ)
   ├─ Parameters: @SearchTerm (NVARCHAR)
   ├─ Returns: Matching orders
   └─ Usage: Find specific order

10. sp_UpdateSalesOrderTotal
    ├─ Type: UPDATE (CALCULATION)
    ├─ Parameters: @SalesOrderID
    ├─ Logic: Recalculates total from items
    └─ Usage: Auto-update on item changes

11. sp_GetSalesOrderStatistics
    ├─ Type: SELECT (READ - ANALYTICS)
    ├─ Returns: Count, total value, status breakdown
    └─ Usage: Dashboard metrics

12. sp_GetSalesRepresentatives
    ├─ Type: SELECT (READ)
    ├─ Returns: All sales personnel
    └─ Usage: Salesperson dropdown


────────────────────────────────────────────────────────────────────────────
CATEGORY: DEAL PROCEDURES (11)
────────────────────────────────────────────────────────────────────────────
Purpose: Manage customer deals (bulk orders)

1. sp_GetAllDeals
   ├─ Type: SELECT (READ)
   ├─ Returns: All deals
   └─ Usage: Deal list

2. sp_GetDealById
   ├─ Type: SELECT (READ)
   ├─ Parameters: @DealID (INT)
   ├─ Returns: Complete deal with items
   └─ Usage: View deal details

3. sp_AddDeal
   ├─ Type: INSERT (CREATE + TRIGGER)
   ├─ Parameters: @SalespersonID, @RetailerID, @DealDate, @DueDate, 
   │             @TotalAmount, @Notes
   ├─ Returns: New DealID
   ├─ Logic: Creates deal and auto-creates approval request
   └─ Usage: Create new deal

4. sp_AddDealItem
   ├─ Type: INSERT (CREATE + UPDATE)
   ├─ Parameters: @DealID, @ProductID, @Quantity, @UnitPrice, @Discount
   ├─ Logic: Adds item and recalculates deal total
   └─ Usage: Add products to deal

5. sp_UpdateDeal
   ├─ Type: UPDATE (MODIFY)
   ├─ Parameters: @DealID, @DueDate, @Notes, @TotalAmount
   └─ Usage: Update deal details

6. sp_UpdateDealItem
   ├─ Type: UPDATE (MODIFY)
   ├─ Parameters: @DealItemID, @Quantity, @UnitPrice, @Discount
   └─ Usage: Modify deal line item

7. sp_DeleteDeal
   ├─ Type: DELETE (SOFT DELETE)
   ├─ Parameters: @DealID (INT)
   └─ Usage: Cancel deal

8. sp_DeleteDealItem
   ├─ Type: DELETE (TRANSACTION)
   ├─ Parameters: @DealItemID (INT)
   └─ Usage: Remove item from deal

9. sp_GetDealsByStatus
   ├─ Type: SELECT (READ)
   ├─ Parameters: @Status (NVARCHAR)
   ├─ Returns: Deals with specified status
   └─ Usage: Filter by status

10. sp_GetDealsByDateRange
    ├─ Type: SELECT (READ)
    ├─ Parameters: @StartDate, @EndDate
    └─ Usage: Historical deals

11. sp_GetDealStatistics
    ├─ Type: SELECT (READ - ANALYTICS)
    ├─ Returns: Deal count, total value, status breakdown
    └─ Usage: Dashboard metrics


────────────────────────────────────────────────────────────────────────────
CATEGORY: ORDER APPROVAL & WORKFLOW PROCEDURES (4)
────────────────────────────────────────────────────────────────────────────
Purpose: Handle order approval process with transaction safety

1. sp_GetPendingApprovals ⭐ TRANSACTION
   ├─ Type: SELECT (READ)
   ├─ Parameters: None
   ├─ Returns: Orders pending approval with material requirements
   ├─ Logic: Joins SalesOrder/Deal with ApprovalRequest tables
   └─ Usage: Approval queue display

2. sp_ApproveOrder ⭐ TRANSACTION
   ├─ Type: UPDATE (TRANSACTION - MULTI-TABLE)
   ├─ Parameters: @ApprovalRequestID, @ApprovedBy
   ├─ Steps:
   │   1. Validate order has items (BLOCK if empty)
   │   2. Check material availability via sp_CheckMaterialsForOrder
   │   3. If sufficient: Mark order as APPROVED
   │   4. Deduct raw materials from stock
   │   5. Create ProductionOrder
   │   6. Update ApprovalRequest status
   │   7. Record approval timestamp
   ├─ Error Handling: Rollback on any failure
   ├─ Returns: Success/Failure message with details
   └─ Usage: Approve order with full workflow

3. sp_ApproveOrderAndCreateProduction ⭐ TRANSACTION
   ├─ Type: INSERT/UPDATE (MULTI-TABLE TRANSACTION)
   ├─ Parameters: @SalesOrderID/DealID, @ApprovedBy
   ├─ Main Steps:
   │   1. Get order details and items
   │   2. Validate items exist (BLOCK if zero items)
   │   3. Call sp_CheckMaterialsForOrder
   │   4. If pass: Update ApprovalRequest to APPROVED
   │   5. Create ProductionOrder with all items
   │   6. Deduct raw materials (sp_DeductRawMaterialStock)
   │   7. Return ProductionOrderID
   ├─ Error Messages: Specific if material shortage
   ├─ Returns: New ProductionOrderID or error code
   └─ Usage: Full approval-to-production workflow

4. sp_RejectOrder ⭐ TRANSACTION
   ├─ Type: UPDATE (TRANSACTION)
   ├─ Parameters: @ApprovalRequestID, @RejectionReason
   ├─ Logic: Mark approval as REJECTED, notify requestor
   └─ Usage: Reject order with reason


────────────────────────────────────────────────────────────────────────────
CATEGORY: PRODUCTION PROCEDURES (10)
────────────────────────────────────────────────────────────────────────────
Purpose: Manage production orders and tailor assignments

1. sp_GetAllProductionOrders
   ├─ Type: SELECT (READ)
   ├─ Returns: All production orders with status
   └─ Usage: Production list

2. sp_GetProductionOrderById
   ├─ Type: SELECT (READ)
   ├─ Parameters: @ProductionOrderID (INT)
   ├─ Returns: Order details with assigned tailor
   └─ Usage: View production order

3. sp_CreateProductionOrder
   ├─ Type: INSERT (CREATE)
   ├─ Parameters: @SalesOrderID/DealID, @OrderDate
   ├─ Logic: Creates production order from approved sales order
   └─ Usage: Internal procedure (called by approval)

4. sp_UpdateProductionOrder
   ├─ Type: UPDATE (MODIFY)
   ├─ Parameters: @ProductionOrderID, @Status, @CompletionDate
   └─ Usage: Update production status

5. sp_DeleteProductionOrder
   ├─ Type: DELETE (SOFT DELETE)
   ├─ Parameters: @ProductionOrderID (INT)
   └─ Usage: Cancel production

6. sp_GetProductionOrderItems
   ├─ Type: SELECT (READ)
   ├─ Parameters: @ProductionOrderID (INT)
   ├─ Returns: All items in production order
   └─ Usage: View items to produce

7. sp_AddProductionOrderItem
   ├─ Type: INSERT (CREATE)
   ├─ Parameters: @ProductionOrderID, @ProductID, @Quantity
   └─ Usage: Add item to production

8. sp_UpdateProductionOrderItem
   ├─ Type: UPDATE (MODIFY)
   ├─ Parameters: @ProductionOrderItemID, @Status, @Quantity
   └─ Usage: Update item status

9. sp_DeleteProductionOrderItem
   ├─ Type: DELETE (SOFT DELETE)
   ├─ Parameters: @ProductionOrderItemID (INT)
   └─ Usage: Remove item from production

10. sp_GetProductionOrderStatistics
    ├─ Type: SELECT (READ - ANALYTICS)
    ├─ Returns: Count by status, total items
    └─ Usage: Production dashboard


────────────────────────────────────────────────────────────────────────────
CATEGORY: TAILOR ASSIGNMENT PROCEDURES (5)
────────────────────────────────────────────────────────────────────────────
Purpose: Assign tailors to production work

1. sp_AssignTailor ⭐ TRANSACTION
   ├─ Type: INSERT (CREATE + TRIGGER)
   ├─ Parameters: @ProductionOrderID, @TailorID, @AssignedDate
   ├─ Logic: Creates assignment record with transaction safety
   └─ Usage: Assign tailor to production

2. sp_UpdateAssignmentStatus ⭐ TRANSACTION
   ├─ Type: UPDATE (TRANSACTION + TRIGGER)
   ├─ Parameters: @AssignmentID, @Status (In-Progress, Completed)
   ├─ Trigger Logic: If Completed:
   │   - Check if ALL items complete
   │   - If yes: Trigger sp_CreateDeliveryFromProduction
   │   - Update ProductionOrder status to COMPLETED
   └─ Usage: Mark tailor work as complete

3. sp_GetTailorAssignments
   ├─ Type: SELECT (READ)
   ├─ Parameters: @TailorID (INT)
   ├─ Returns: All assignments for tailor (pending + in-progress)
   └─ Usage: Tailor dashboard - show pending work

4. sp_GetAvailableTailors
   ├─ Type: SELECT (READ)
   ├─ Parameters: None
   ├─ Returns: Tailors not currently assigned
   └─ Usage: Tailor dropdown for assignment

5. sp_GetTailorsForAssignment
   ├─ Type: SELECT (READ)
   ├─ Parameters: None
   ├─ Returns: All tailor employees
   └─ Usage: Assignment interface


────────────────────────────────────────────────────────────────────────────
CATEGORY: DELIVERY PROCEDURES (7)
────────────────────────────────────────────────────────────────────────────
Purpose: Manage delivery operations

1. sp_CreateDeliveryFromProduction ⭐ TRANSACTION
   ├─ Type: INSERT (AUTO-TRIGGER)
   ├─ Trigger: Called when ALL tailor assignments completed
   ├─ Parameters: @ProductionOrderID
   ├─ Logic:
   │   1. Create Delivery record
   │   2. Assign to available DeliveryPerson
   │   3. Set DeliveryDate = TODAY + 1 day
   │   4. Status = PENDING
   │   5. Auto-notify delivery person
   ├─ Returns: New DeliveryID
   └─ Usage: Automatic workflow trigger

2. sp_GetAllDeliveries
   ├─ Type: SELECT (READ)
   ├─ Returns: All deliveries with status
   └─ Usage: Delivery list

3. sp_GetDeliveryById
   ├─ Type: SELECT (READ)
   ├─ Parameters: @DeliveryID (INT)
   ├─ Returns: Complete delivery details
   └─ Usage: View delivery

4. sp_UpdateDelivery
   ├─ Type: UPDATE (MODIFY)
   ├─ Parameters: @DeliveryID, @Status, @DeliveryDate
   └─ Usage: Update delivery info

5. sp_UpdateDeliveryStatus
   ├─ Type: UPDATE (TRANSACTION)
   ├─ Parameters: @DeliveryID, @Status (Pending→Shipped→Delivered)
   ├─ Logic: Status transition with validation
   └─ Usage: Track delivery progress

6. sp_GetDeliveryPersonnel
   ├─ Type: SELECT (READ)
   ├─ Returns: All delivery personnel
   └─ Usage: Personnel list

7. sp_GetDeliveryStatistics
   ├─ Type: SELECT (READ - ANALYTICS)
   ├─ Returns: Deliveries by status, on-time rate
   └─ Usage: Delivery dashboard


────────────────────────────────────────────────────────────────────────────
CATEGORY: MATERIAL CHECK & STOCK PROCEDURES (8)
────────────────────────────────────────────────────────────────────────────
Purpose: Validate materials availability before production

1. sp_CheckMaterialsForOrder ⭐ CRITICAL
   ├─ Type: SELECT (READ + VALIDATE)
   ├─ Parameters: @OrderID (SalesOrder or Deal)
   ├─ Returns: 
   │   - ProductID, ProductName, Quantity Needed
   │   - RawMaterialID, MaterialName, QuantityNeeded
   │   - CurrentStock, Shortage (if negative)
   │   - Status (AVAILABLE/SHORT)
   ├─ Logic: For each product → Get materials needed → Check stock
   ├─ Used By: sp_ApproveOrderAndCreateProduction for validation
   └─ Usage: Approval workflow gate

2. sp_CheckMaterialsAvailability
   ├─ Type: SELECT (READ - ALTERNATIVE)
   ├─ Returns: All materials with stock status
   └─ Usage: Alternative check method

3. sp_CheckMaterialAvailability
   ├─ Type: SELECT (READ - LEGACY)
   ├─ Parameters: @MaterialID
   ├─ Returns: Single material availability
   └─ Usage: Individual material check

4. sp_DeductRawMaterialStock ⭐ TRANSACTION
   ├─ Type: UPDATE (TRANSACTION)
   ├─ Parameters: @MaterialID, @Quantity
   ├─ Logic: 
   │   1. Get current stock
   │   2. Subtract quantity
   │   3. If result < 0: ROLLBACK with error
   │   4. Update stock record
   │   5. Log transaction
   ├─ Error: Throws if insufficient stock
   └─ Usage: Called during order approval

5. sp_RecordStockUsage
   ├─ Type: INSERT (LOG + UPDATE)
   ├─ Parameters: @MaterialID, @Quantity, @ProductionOrderID, @UsedBy
   ├─ Logic: Records material consumption
   └─ Usage: Track material usage

6. sp_GetStockUsageByProductionOrder
   ├─ Type: SELECT (READ - ANALYTICS)
   ├─ Parameters: @ProductionOrderID
   ├─ Returns: All materials used
   └─ Usage: Production analytics

7. sp_GetStockManagement
   ├─ Type: SELECT (READ)
   ├─ Returns: Current stock levels by material
   └─ Usage: Inventory dashboard

8. sp_GetInProcessProducts
   ├─ Type: SELECT (READ)
   ├─ Returns: Products currently in production
   └─ Usage: Production tracking


────────────────────────────────────────────────────────────────────────────
CATEGORY: PRODUCT & RAW MATERIAL PROCEDURES (18)
────────────────────────────────────────────────────────────────────────────
Purpose: Manage products and raw materials

PRODUCT PROCEDURES (8):
1. sp_GetAllProducts        - Get all products
2. sp_GetProductById        - Get single product
3. sp_AddProduct            - Create product
4. sp_UpdateProduct         - Modify product
5. sp_DeleteProduct         - Remove product
6. sp_SearchProducts        - Search products
7. sp_GetProductsForOrder   - Products available for orders
8. sp_GetProductsForStock   - Products to stock

RAW MATERIAL PROCEDURES (10):
1. sp_GetAllRawMaterials         - Get all materials
2. sp_GetRawMaterialById         - Get single material
3. sp_CreateRawMaterial          - Create material
4. sp_UpdateRawMaterial          - Modify material
5. sp_DeleteRawMaterial          - Remove material
6. sp_SearchRawMaterials         - Search materials
7. sp_AddRawMaterialPurchase     - Record purchase
8. sp_RestockRawMaterial         - Update stock
9. sp_GetRawMaterialStatistics   - Material analytics
10. sp_AddProductMaterialRequirement - Define material needs per product


────────────────────────────────────────────────────────────────────────────
CATEGORY: RETAILER PROCEDURES (6)
────────────────────────────────────────────────────────────────────────────
Purpose: Manage customer retailers

1. sp_GetAllRetailers
2. sp_GetRetailerById
3. sp_AddRetailer
4. sp_UpdateRetailer
5. sp_DeleteRetailer
6. sp_GetRetailersForOrder


────────────────────────────────────────────────────────────────────────────
CATEGORY: FINANCIAL & ANALYTICS PROCEDURES (15)
────────────────────────────────────────────────────────────────────────────
Purpose: Generate reports and financial metrics

1. sp_GetSalesDepartmentStats
   ├─ Type: SELECT (ANALYTICS)
   ├─ Returns: Sales stats (orders, deals, revenue)
   └─ Usage: Sales dashboard

2. sp_GetProductionDepartmentStats
   ├─ Type: SELECT (ANALYTICS)
   ├─ Returns: Production stats (orders, completion rate)
   └─ Usage: Production dashboard

3. sp_GetDeliveryStatistics
   ├─ Type: SELECT (ANALYTICS)
   ├─ Returns: Delivery stats (on-time rate, average time)
   └─ Usage: Delivery dashboard

4. sp_GetRevenueByDateRange
   ├─ Type: SELECT (ANALYTICS)
   ├─ Parameters: @StartDate, @EndDate
   ├─ Returns: Total revenue, breakdown by product
   └─ Usage: Financial reporting

5. sp_GetMonthRevenue
   ├─ Type: SELECT (ANALYTICS)
   ├─ Parameters: @Month, @Year
   └─ Usage: Monthly revenue

6. sp_GetYearlyRevenue
   ├─ Type: SELECT (ANALYTICS)
   ├─ Parameters: @Year
   └─ Usage: Annual revenue

7. sp_CalculateMonthlyRevenue
   ├─ Type: CALCULATE (AGGREGATE)
   ├─ Parameters: @Month, @Year
   └─ Usage: Compute revenue

8. sp_GetMonthlySalaryStatus
   ├─ Type: SELECT (ANALYTICS)
   ├─ Parameters: @Month, @Year
   ├─ Returns: Salary payment status
   └─ Usage: Payroll dashboard

9. sp_GetUnpaidSalaryMonths
   ├─ Type: SELECT (ANALYTICS)
   ├─ Returns: Employees with unpaid salary
   └─ Usage: HR alerts

10. sp_GetExpensesByDateRange
    ├─ Type: SELECT (ANALYTICS)
    ├─ Parameters: @StartDate, @EndDate
    └─ Usage: Expense reporting

11. sp_GetApprovalHistory
    ├─ Type: SELECT (AUDIT)
    ├─ Returns: All approvals with timestamps
    └─ Usage: Audit trail

12. sp_GetDealsByEmployee
    ├─ Type: SELECT (ANALYTICS)
    ├─ Parameters: @EmployeeID
    └─ Usage: Employee performance

13. sp_GetDeliveryAssignments
    ├─ Type: SELECT (READ)
    ├─ Returns: Delivery assignments
    └─ Usage: Delivery tracking

14. sp_GetRetailerStatistics
    ├─ Type: SELECT (ANALYTICS)
    ├─ Returns: Retailer performance
    └─ Usage: Customer analytics

15. sp_GetPurchasesByDateRange
    ├─ Type: SELECT (ANALYTICS)
    ├─ Parameters: @StartDate, @EndDate
    └─ Usage: Purchase history


=============================================================================
SECTION 4: PROCEDURE TYPES & TRANSACTION FLOW
=============================================================================

────────────────────────────────────────────────────────────────────────────
PROCEDURE CLASSIFICATION BY TYPE
────────────────────────────────────────────────────────────────────────────

1. READ/SELECT PROCEDURES (QUERIES)
   Purpose: Retrieve data without modification
   ├─ Safe to call multiple times
   ├─ No transaction needed
   ├─ Examples: sp_GetEmployees, sp_GetAllSalesOrders, sp_GetPendingApprovals

2. CREATE/INSERT PROCEDURES
   Purpose: Add new records
   ├─ Single table operations
   ├─ May trigger validation
   ├─ Examples: sp_AddEmployee, sp_AddSalesOrder

3. UPDATE/MODIFY PROCEDURES
   Purpose: Change existing records
   ├─ Single table operations
   ├─ Examples: sp_UpdateEmployee, sp_UpdateSalesOrderStatus

4. DELETE PROCEDURES (SOFT DELETE)
   Purpose: Remove records (set IsActive = 0)
   ├─ Preserves data integrity
   ├─ Examples: sp_DeleteEmployee, sp_DeleteSalesOrder

5. TRANSACTION PROCEDURES ⭐ (CRITICAL)
   Purpose: Multi-step operations requiring atomicity
   ├─ All steps succeed or all fail (ROLLBACK)
   ├─ Use BEGIN/COMMIT/ROLLBACK
   ├─ Examples:
   │   ✓ sp_ApproveOrderAndCreateProduction
   │   ✓ sp_CreateDeliveryFromProduction
   │   ✓ sp_UpdateAssignmentStatus
   │   ✓ sp_DeductRawMaterialStock

6. ANALYTICS/REPORTING PROCEDURES
   Purpose: Generate statistics and reports
   ├─ Complex aggregations
   ├─ Used for dashboards
   ├─ Examples: sp_GetSalesDepartmentStats, sp_GetRevenueByDateRange

7. TRIGGER PROCEDURES
   Purpose: Auto-execute on specific conditions
   ├─ Called by UPDATE/INSERT triggers
   ├─ Examples:
   │   ✓ sp_ApproveOrderAndCreateProduction (on order approval)
   │   ✓ sp_CreateDeliveryFromProduction (on tailor completion)

────────────────────────────────────────────────────────────────────────────
MAIN TRANSACTION FLOW: ORDER → APPROVAL → PRODUCTION → DELIVERY
────────────────────────────────────────────────────────────────────────────

STEP 1: CREATE ORDER (Sales Team)
─────────────────────────────────────
Call: sp_AddSalesOrder or sp_AddDeal
├─ Creates SalesOrder/Deal record
├─ Auto-triggers: Creates ApprovalRequest (Status = PENDING)
├─ Returns: OrderID
└─ Result: Order in "Pending Approval" state

STEP 2: APPROVAL WITH VALIDATION (Manager)
─────────────────────────────────────────────
Call: sp_ApproveOrderAndCreateProduction ⭐ TRANSACTION
├─ Input: @OrderID, @ApprovedBy
│
├─ VALIDATION GATE:
│   ├─ Check: Order has items? (Block if 0 items)
│   ├─ Call: sp_CheckMaterialsForOrder
│   ├─ Validate: All materials in stock?
│   └─ Result: PASS or FAIL with details
│
├─ ON PASS:
│   ├─ Step 1: Update ApprovalRequest.Status = "APPROVED"
│   ├─ Step 2: Create ProductionOrder from SalesOrder
│   ├─ Step 3: Call sp_DeductRawMaterialStock (Automatic)
│   ├─ Step 4: Update stock records
│   ├─ Step 5: Assign production order to department
│   └─ COMMIT Transaction
│
├─ ON FAIL:
│   ├─ Return error message with shortage details
│   ├─ Suggest reordering materials
│   └─ ROLLBACK all changes
│
└─ Result: ProductionOrder created and materials deducted


STEP 3: ASSIGN TAILORS (Production Manager)
──────────────────────────────────────────────
Call: sp_AssignTailor ⭐ TRANSACTION
├─ Input: @ProductionOrderID, @TailorID
├─ Creates: ProductionAssignment record
├─ Auto-triggers: Update ProductionOrder status = "IN_PRODUCTION"
└─ Result: Tailor has work in their dashboard


STEP 4: COMPLETE TAILOR WORK (Tailor)
───────────────────────────────────────
Call: sp_UpdateAssignmentStatus ⭐ TRANSACTION
├─ Input: @AssignmentID, @Status = "COMPLETED"
│
├─ CHECKS:
│   └─ Are ALL items in production complete?
│
├─ IF YES (All items complete):
│   ├─ Call: sp_CreateDeliveryFromProduction (AUTOMATIC)
│   │   ├─ Create Delivery record
│   │   ├─ Auto-assign: DeliveryPerson from Delivery dept
│   │   ├─ Set: DeliveryDate = TODAY + 1 day
│   │   └─ Status = "PENDING"
│   │
│   ├─ Update: ProductionOrder.Status = "COMPLETED"
│   ├─ Update: SalesOrder.Status = "READY_FOR_DELIVERY"
│   └─ Auto-notify: Delivery person
│
├─ IF NO (Some items still pending):
│   └─ Update assignment status, wait for others
│
└─ Result: Automatic delivery creation


STEP 5: DELIVERY & COMPLETION (Delivery Person)
────────────────────────────────────────────────
Call: sp_UpdateDeliveryStatus ⭐ TRANSACTION
├─ Sequence:
│   1. Status = "PENDING" → "SHIPPED" (Pick up from warehouse)
│   2. Status = "SHIPPED" → "DELIVERED" (Delivered to customer)
│
├─ On "DELIVERED":
│   ├─ Update: SalesOrder.Status = "DELIVERED"
│   ├─ Update: Retailer balance (if payment pending)
│   ├─ Record: Delivery timestamp
│   └─ Auto-notify: Customer and sales team
│
└─ Result: Order complete, payment due


STEP 6: FINANCIAL RECORD (Accounting)
───────────────────────────────────────
Call: sp_CalculateMonthlyRevenue
├─ Aggregate: All DELIVERED orders for month
├─ Calculate: Revenue - Expenses = Profit
└─ Result: Monthly financial statement


────────────────────────────────────────────────────────────────────────────
ERROR HANDLING IN TRANSACTIONS
────────────────────────────────────────────────────────────────────────────

SCENARIO 1: Insufficient Materials
──────────────────────────────────
Order: 100 shirts needing 200m fabric (only 150m available)
├─ sp_CheckMaterialsForOrder detects shortage
├─ Returns: SHORTAGE - 50m needed
├─ Approval blocked with message:
│  "Insufficient fabric. Need 50m more. Reorder first."
├─ No changes to database (ROLLBACK)
└─ User action: Reorder materials, then resubmit


SCENARIO 2: Order with Zero Items
──────────────────────────────────
User creates order but adds no products
├─ sp_ApproveOrderAndCreateProduction checks
├─ Detects: OrderItems count = 0
├─ Blocks approval with message:
│  "Cannot approve order with no items. Add products first."
├─ No transaction executed
└─ User action: Add items, then resubmit


SCENARIO 3: Material Deduction Failure
───────────────────────────────────────
During approval, sp_DeductRawMaterialStock fails
├─ Previous steps (order update, production creation) already done
├─ Stock deduction fails: Not enough inventory
├─ Transaction: ROLLBACK all previous changes
├─ Database: Remains consistent (no orphaned records)
├─ User sees: Error with details
└─ User action: Fix material issue, resubmit


=============================================================================
SECTION 5: QUICK REFERENCE
=============================================================================

────────────────────────────────────────────────────────────────────────────
EMPLOYEE OPERATIONS QUICK REFERENCE
────────────────────────────────────────────────────────────────────────────

Get All Employees:
  EXEC sp_GetEmployees;

Get By ID:
  EXEC sp_GetEmployeeById @EmployeeID = 15;

Get By Department:
  EXEC sp_GetEmployeesByDepartment @DepartmentID = 1;

Add Employee:
  EXEC sp_AddEmployee
    @FirstName = 'John',
    @LastName = 'Doe',
    @Position = 'Sales Person',
    @DepartmentID = 1,
    @RoleID = 3,
    @Phone = '0300-1234567',
    @Email = 'john@factory.com',
    @Salary = 40000,
    @Username = 'john_doe',
    @PIN = '1234';

Update Employee:
  EXEC sp_UpdateEmployee
    @EmployeeID = 15,
    @Salary = 45000,
    @Position = 'Senior Salesperson';

Delete Employee (Soft Delete):
  EXEC sp_DeleteEmployee @EmployeeID = 15;

Get Department List:
  EXEC sp_GetDepartments;

Get All Roles:
  EXEC sp_GetEmployeeRoles;


────────────────────────────────────────────────────────────────────────────
ORDER WORKFLOW QUICK REFERENCE
────────────────────────────────────────────────────────────────────────────

Create Sales Order:
  EXEC sp_AddSalesOrder
    @SalespersonID = 12,
    @RetailerID = 1,
    @OrderDate = GETDATE(),
    @DeliveryDate = DATEADD(DAY, 7, GETDATE());
  Returns: @SalesOrderID

Add Item to Order:
  EXEC sp_AddSalesOrderItem
    @SalesOrderID = 1,
    @ProductID = 5,
    @Quantity = 100,
    @UnitPrice = 500;

View Pending Approvals:
  EXEC sp_GetPendingApprovals;

Approve Order (WITH VALIDATION):
  EXEC sp_ApproveOrderAndCreateProduction
    @SalesOrderID = 1,
    @ApprovedBy = 2;  ← ManagerID
  Returns: @ProductionOrderID or Error

Assign Tailor:
  EXEC sp_AssignTailor
    @ProductionOrderID = 1,
    @TailorID = 6;

Mark Work Complete:
  EXEC sp_UpdateAssignmentStatus
    @AssignmentID = 1,
    @Status = 'Completed';
  → Automatically creates Delivery!

View Delivery:
  EXEC sp_GetAllDeliveries;

Update Delivery Status:
  EXEC sp_UpdateDeliveryStatus
    @DeliveryID = 1,
    @Status = 'Delivered';


────────────────────────────────────────────────────────────────────────────
SAMPLE DATA CURRENT STATE (December 17, 2025)
────────────────────────────────────────────────────────────────────────────

EMPLOYEES: 17 Total (12 new sample + 5 existing)

Sales Department (Dept 1):
- Ahmad Khan (ID:11, RoleID:2, Sales Manager) [NEW]
- Ali Ahmed (ID:12, RoleID:3, Sales Person) [NEW]
- Fatima Hassan (ID:13, RoleID:3, Sales Person) [NEW]
- Hira Malik (ID:14, RoleID:3, Sales Person) [NEW]
- Plus 2 existing employees

Production Department (Dept 2):
- Hassan Ahmed (ID:15, RoleID:4, Production Manager) [NEW]
- Zain Ali (ID:16, RoleID:5, Tailor) [NEW]
- Bilal Hassan (ID:17, RoleID:5, Tailor) [NEW]
- Aisha Khan (ID:18, RoleID:5, Tailor) [NEW]
- Samir Hassan (ID:19, RoleID:5, Tailor) [NEW]
- Plus 1 existing employee

Delivery Department (Dept 3):
- Muhammad Khan (ID:20, RoleID:6, Delivery Person) [NEW]
- Ahmed Ali (ID:21, RoleID:6, Delivery Person) [NEW]
- Hassan Malik (ID:22, RoleID:6, Delivery Person) [NEW]
- Plus 2 existing employees

DEFAULT CREDENTIALS (New Employees):
- Username: firstname_lastname
- PIN: 1234
- LastLogin: NULL


────────────────────────────────────────────────────────────────────────────
COMMONLY USED PARAMETER VALUES
────────────────────────────────────────────────────────────────────────────

DepartmentID:
  1 = Sales
  2 = Production
  3 = Delivery

RoleID:
  1 = Owner
  2 = Sales Manager
  3 = Sales Person / Staff / Delivery Person
  4 = Production Manager
  5 = Tailor
  6 = Delivery Person

Order Status:
  Pending, Approved, In-Progress, Completed, Shipped, Delivered, Cancelled

Approval Status:
  Pending, Approved, Rejected, In-Review

Delivery Status:
  Pending, Shipped, Delivered, Cancelled

Tailor Assignment Status:
  Pending, In-Progress, Completed, On-Hold

=============================================================================
END OF DATABASE SCHEMA & PROCEDURES REFERENCE
=============================================================================

Last Updated: December 17, 2025
Total Procedures: 157 (excluding system procedures)
Total Tables: 20+
Sample Data: 12 employees inserted (3 departments, 1 manager each)

FOR COMPLETE SQL: See other database files in /Database folder
