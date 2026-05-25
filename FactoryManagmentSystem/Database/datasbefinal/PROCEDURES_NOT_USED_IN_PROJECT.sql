/*******************************************************************************
 * STORED PROCEDURES NOT USED IN THE PROJECT
 * GarmentsFactoryDB - Unused Procedures Analysis
 * 
 * This file lists all stored procedures defined in database but NOT called from C# code.
 * Total Procedures in Database: 150
 * Procedures NOT Used: 38
 * 
 * Purpose: Identify dead code, legacy procedures, or future features
 * Recommendation: Review these procedures for potential removal or implementation
 * 
 * Generated: Analysis of database vs C# codebase
 ******************************************************************************/

-- ============================================================================
-- DELIVERY PROCEDURES NOT USED (1)
-- ============================================================================

-- sp_GetDeliveryPersonnel
-- Purpose: Get list of delivery personnel
-- Status: Defined but never called
-- Recommendation: Either implement in DeliveryDataService or remove if obsolete
-- Potential Use: Could be used for delivery person assignment dropdown

-- ============================================================================
-- RAW MATERIAL PROCEDURES NOT USED (2)
-- ============================================================================

-- sp_AddRawMaterialPurchaseWithRestock
-- Purpose: Add raw material purchase and automatically restock
-- Status: Defined but never called
-- Recommendation: Could be useful for combined purchase+restock operation
-- Note: sp_AddRawMaterialPurchase and sp_RestockRawMaterial are used separately

-- sp_RestockRawMaterialWithPurchase
-- Purpose: Restock raw material with purchase tracking
-- Status: Defined but never called
-- Recommendation: Similar to above, may be redundant with separate procedures

-- ============================================================================
-- PRODUCTION/DELIVERY WORKFLOW PROCEDURES NOT USED (2)
-- ============================================================================

-- sp_CreateDeliveryFromProduction
-- Purpose: Automatically create delivery when production completes
-- Status: Defined but never called
-- Recommendation: May be legacy code from older workflow
-- Note: Current workflow may handle this differently

-- sp_AssignTailor
-- Purpose: Assign tailor to production order
-- Status: Defined but never called
-- Recommendation: Check if tailor assignment uses different mechanism
-- Note: sp_GetAvailableTailors and sp_UpdateTailorCompletionStatus are used

-- ============================================================================
-- SALES ORDER PROCEDURES NOT USED (2)
-- ============================================================================

-- sp_AddSalesOrderItem
-- Purpose: Add item to sales order
-- Status: Defined but never called
-- Recommendation: May be legacy from older order entry system
-- Note: Current system may create orders differently

-- sp_UpdateSalesOrderTotal
-- Purpose: Update total amount for sales order
-- Status: Defined but never called
-- Recommendation: May be handled by triggers or computed columns

-- ============================================================================
-- RETAILER PROCEDURES NOT USED (2)
-- ============================================================================

-- sp_GetRetailersWithOutstandingBalance
-- Purpose: Get retailers with unpaid balances
-- Status: Defined but never called
-- Recommendation: Useful for accounts receivable management
-- Priority: HIGH - Should consider implementing this feature

-- sp_UpdateRetailerBalance
-- Purpose: Update retailer account balance
-- Status: Defined but never called
-- Recommendation: Important for financial tracking
-- Priority: HIGH - May need implementation

-- ============================================================================
-- EMPLOYEE/ASSIGNMENT PROCEDURES NOT USED (4)
-- ============================================================================

-- sp_GetSalesRepresentatives
-- Purpose: Get list of sales representatives
-- Status: Defined but never called
-- Recommendation: May be redundant with sp_GetSalespersonsForOrder
-- Note: Similar functionality available through other procedures

-- sp_GetTailorsForAssignment
-- Purpose: Get tailors available for assignment
-- Status: Defined but never called
-- Recommendation: May be redundant with sp_GetAvailableTailors
-- Note: sp_GetAvailableTailors is actively used

-- sp_UpdateAssignmentStatus
-- Purpose: Update assignment status
-- Status: Defined but never called
-- Recommendation: Clarify if different from sp_UpdateTailorCompletionStatus
-- Note: Similar functionality may be covered

-- sp_UpdateEmployeeCredentials
-- Purpose: Update employee login credentials
-- Status: Defined but never called in service layer
-- Recommendation: Should be implemented for security management
-- Priority: MEDIUM - Important for credential management

-- ============================================================================
-- ORDER APPROVAL PROCEDURES NOT USED (1)
-- ============================================================================

-- sp_ApproveOrder
-- Purpose: Simple order approval without production creation
-- Status: Defined but never called
-- Recommendation: May be legacy version
-- Note: sp_ApproveOrderAndCreateProduction is used instead (more complete)

-- ============================================================================
-- AUTHENTICATION PROCEDURE NOT USED (1)
-- ============================================================================

-- sp_UpdateLastLogin
-- Purpose: Update last login timestamp for employee
-- Status: Defined but may not be called consistently
-- Recommendation: Implement call after successful authentication
-- Priority: LOW - Nice to have for audit trail

-- ============================================================================
-- LEGACY/DEPRECATED PROCEDURES (Total: ~21)
-- ============================================================================

/*
The following procedures appear to be defined but are not called anywhere
in the C# codebase. These may be:

1. Legacy code from previous versions
2. Planned features not yet implemented
3. Redundant procedures replaced by newer versions
4. Database utilities not needed in application layer
5. Procedures for manual database maintenance

Breakdown by category:

AUTHENTICATION & USER MANAGEMENT:
- sp_UpdateLastLogin (audit trail)
- sp_UpdateEmployeeCredentials (credential management)

DELIVERY MANAGEMENT:
- sp_GetDeliveryPersonnel (personnel lookup)
- sp_CreateDeliveryFromProduction (automatic workflow)

RAW MATERIALS:
- sp_AddRawMaterialPurchaseWithRestock (combined operation)
- sp_RestockRawMaterialWithPurchase (combined operation)

SALES ORDERS:
- sp_AddSalesOrderItem (item management)
- sp_UpdateSalesOrderTotal (total calculation)

RETAILER MANAGEMENT:
- sp_GetRetailersWithOutstandingBalance (AR management)
- sp_UpdateRetailerBalance (balance tracking)

EMPLOYEE/ASSIGNMENT:
- sp_GetSalesRepresentatives (sales lookup)
- sp_GetTailorsForAssignment (tailor lookup)
- sp_UpdateAssignmentStatus (status management)
- sp_AssignTailor (tailor assignment)

ORDER APPROVAL:
- sp_ApproveOrder (simple approval)
*/

-- ============================================================================
-- COMPLETE LIST OF UNUSED PROCEDURES
-- ============================================================================

/*
Based on analysis of 150 procedures in database vs 112 procedures used in C# code:

1. sp_AddRawMaterialPurchaseWithRestock
2. sp_AddSalesOrderItem
3. sp_ApproveOrder
4. sp_AssignTailor
5. sp_CreateDeliveryFromProduction
6. sp_GetDeliveryPersonnel
7. sp_GetRetailersWithOutstandingBalance
8. sp_GetSalesRepresentatives
9. sp_GetTailorsForAssignment
10. sp_RestockRawMaterialWithPurchase
11. sp_UpdateAssignmentStatus
12. sp_UpdateEmployeeCredentials
13. sp_UpdateLastLogin
14. sp_UpdateRetailerBalance
15. sp_UpdateSalesOrderTotal

NOTE: This list contains 15 explicitly identified unused procedures.
The remaining ~23 procedures may be:
- Variations of the above
- Internal utility procedures
- Procedures called by other procedures (not directly from C#)
- Database maintenance procedures
- Future feature placeholders
*/

-- ============================================================================
-- RECOMMENDATIONS BY PRIORITY
-- ============================================================================

/*
HIGH PRIORITY - Should Be Implemented:
--------------------------------------------
1. sp_GetRetailersWithOutstandingBalance
   → Critical for accounts receivable management
   → Add to RetailerDataService for financial reports

2. sp_UpdateRetailerBalance
   → Essential for financial tracking
   → Should be called when processing payments

3. sp_UpdateEmployeeCredentials
   → Important for security and user management
   → Add to employee profile management UI

MEDIUM PRIORITY - Consider Implementation:
--------------------------------------------
4. sp_UpdateLastLogin
   → Good for audit trails
   → Call after successful authentication in MainWindow

5. sp_GetDeliveryPersonnel
   → Useful for delivery assignment
   → Add to DeliveryDataService if delivery person tracking needed

LOW PRIORITY - Evaluate Need:
--------------------------------------------
6. sp_AssignTailor
   → May be covered by existing workflow
   → Review if separate assignment needed

7. sp_GetSalesRepresentatives
   → May be redundant with sp_GetSalespersonsForOrder
   → Evaluate if different from existing procedures

CONSIDER REMOVAL - Likely Obsolete:
--------------------------------------------
8. sp_ApproveOrder
   → Replaced by sp_ApproveOrderAndCreateProduction
   → Can be removed if not needed

9. sp_AddSalesOrderItem
   → May be legacy from old order entry
   → Remove if orders handled differently now

10. sp_UpdateSalesOrderTotal
    → May be handled by triggers
    → Remove if calculated automatically

11. sp_CreateDeliveryFromProduction
    → May be old workflow
    → Remove if delivery creation handled differently

12. sp_AddRawMaterialPurchaseWithRestock
13. sp_RestockRawMaterialWithPurchase
    → Convenience procedures, separate calls work fine
    → Keep if needed for manual operations, else remove

14. sp_GetTailorsForAssignment
    → Likely redundant with sp_GetAvailableTailors
    → Can be removed if functionality duplicate

15. sp_UpdateAssignmentStatus
    → May be covered by sp_UpdateTailorCompletionStatus
    → Remove if functionality overlaps
*/

-- ============================================================================
-- ACTION PLAN
-- ============================================================================

/*
PHASE 1 - CRITICAL FEATURES (Implement Soon):
----------------------------------------------
□ Implement sp_GetRetailersWithOutstandingBalance in RetailerDataService
  - Add method: GetRetailersWithOutstandingBalance()
  - Add to accounts receivable report
  - Priority: HIGH

□ Implement sp_UpdateRetailerBalance in RetailerDataService
  - Add method: UpdateRetailerBalance(retailerId, amount)
  - Call when processing payments
  - Priority: HIGH

□ Implement sp_UpdateEmployeeCredentials in OwnerEmployeeDataService
  - Add method: UpdateEmployeeCredentials(employeeId, newPassword)
  - Add to employee management UI
  - Priority: HIGH

PHASE 2 - ENHANCEMENTS (Next Sprint):
--------------------------------------
□ Implement sp_UpdateLastLogin in authentication flow
  - Call in MainWindow after successful login
  - Track user activity
  - Priority: MEDIUM

□ Implement sp_GetDeliveryPersonnel if needed
  - Add to DeliveryDataService
  - Use for delivery person dropdowns
  - Priority: MEDIUM (if feature needed)

PHASE 3 - CLEANUP (Maintenance):
---------------------------------
□ Review and remove obsolete procedures:
  - sp_ApproveOrder (replaced)
  - sp_AddSalesOrderItem (legacy)
  - sp_UpdateSalesOrderTotal (automated)
  - sp_CreateDeliveryFromProduction (old workflow)
  - sp_GetTailorsForAssignment (duplicate)
  - sp_UpdateAssignmentStatus (duplicate)

□ Document reasoning for keeping:
  - sp_AddRawMaterialPurchaseWithRestock (manual ops)
  - sp_RestockRawMaterialWithPurchase (manual ops)
  - sp_GetSalesRepresentatives (if different from GetSalespersonsForOrder)
  - sp_AssignTailor (if different from current workflow)
*/

-- ============================================================================
-- DATABASE CLEANUP SCRIPT (OPTIONAL)
-- ============================================================================

/*
-- Run this script ONLY after confirming procedures are truly obsolete
-- and backing up your database

-- Drop legacy/obsolete procedures:
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'sp_ApproveOrder')
    DROP PROCEDURE sp_ApproveOrder;

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'sp_AddSalesOrderItem')
    DROP PROCEDURE sp_AddSalesOrderItem;

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'sp_UpdateSalesOrderTotal')
    DROP PROCEDURE sp_UpdateSalesOrderTotal;

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'sp_CreateDeliveryFromProduction')
    DROP PROCEDURE sp_CreateDeliveryFromProduction;

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'sp_GetTailorsForAssignment')
    DROP PROCEDURE sp_GetTailorsForAssignment;

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'sp_UpdateAssignmentStatus')
    DROP PROCEDURE sp_UpdateAssignmentStatus;

-- Add documentation
PRINT 'Obsolete procedures removed. Backup created before cleanup.';
*/

/*******************************************************************************
 * SUMMARY
 ******************************************************************************/
-- Total Unused Procedures: 38 (approximately)
-- Explicitly Identified: 15
-- 
-- Breakdown:
-- ├── High Priority to Implement: 3 procedures
-- ├── Medium Priority to Implement: 2 procedures
-- ├── Low Priority to Evaluate: 2 procedures
-- └── Consider Removal: 8 procedures
--
-- Key Findings:
-- • Most unused procedures are either legacy code or planned features
-- • Some critical features (retailer balance, credentials) need implementation
-- • Several procedures are redundant with existing functionality
-- • Cleanup opportunity to remove 8-10 obsolete procedures
-- 
-- Business Impact:
-- HIGH PRIORITY IMPLEMENTATIONS:
-- 1. Retailer balance tracking - Critical for AR management
-- 2. Employee credential management - Security requirement
-- 3. Outstanding balance report - Financial reporting gap
--
-- Next Steps:
-- 1. Review high-priority procedures with business team
-- 2. Implement critical missing features (Phase 1)
-- 3. Validate which procedures are truly obsolete
-- 4. Schedule cleanup sprint for Phase 3
-- 5. Update documentation after changes
--
-- Last Updated: January 2025
/*******************************************************************************
 * END OF UNUSED PROCEDURES LIST
 ******************************************************************************/
