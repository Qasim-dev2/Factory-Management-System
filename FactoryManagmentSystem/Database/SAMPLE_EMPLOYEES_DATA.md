# SAMPLE EMPLOYEE DATA FOR GARMENTS FACTORY MANAGEMENT SYSTEM

## 📊 EMPLOYEE DATA STRUCTURE

### Department Structure (Already Exists)
| DepartmentID | DepartmentName |
|--------------|----------------|
| 1            | Sales          |
| 2            | Production     |
| 3            | Delivery       |

### Role Structure (Using Existing RoleIDs)
- RoleID 3: General Employee/Staff
- RoleID 5: Specialist (Tailor, etc.)

---

## 👥 SAMPLE EMPLOYEES TO INSERT

### Format: Clear Preview Before Execution

#### DEPARTMENT 1: SALES (1 Manager + 3 Salespersons)

| # | FirstName | LastName | Position | Phone | Email | DepartmentID | RoleID | Salary | JoinDate | Address | Status | Purpose |
|---|-----------|----------|----------|-------|-------|--------------|--------|--------|----------|---------|--------|---------|
| 1 | **Ahmad** | **Khan** | **Sales Manager** | 0300-1111111 | ahmad.khan@factory.com | 1 | 3 | 80000 | 2025-01-01 | Karachi, Pakistan | Active | Department Head - Oversees sales team |
| 2 | Ali | Ahmed | Salesperson | 0300-2222222 | ali.ahmed@factory.com | 1 | 3 | 40000 | 2025-01-05 | Karachi, Pakistan | Active | Sales Rep - Creates orders & deals |
| 3 | Fatima | Hassan | Salesperson | 0300-3333333 | fatima.hassan@factory.com | 1 | 3 | 40000 | 2025-01-10 | Lahore, Pakistan | Active | Sales Rep - Creates orders & deals |
| 4 | Hira | Malik | Salesperson | 0300-4444444 | hira.malik@factory.com | 1 | 3 | 40000 | 2025-01-15 | Islamabad, Pakistan | Active | Sales Rep - Creates orders & deals |

---

#### DEPARTMENT 2: PRODUCTION (1 Manager + 4 Tailors)

| # | FirstName | LastName | Position | Phone | Email | DepartmentID | RoleID | Salary | JoinDate | Address | Status | Purpose |
|---|-----------|----------|----------|-------|-------|--------------|--------|--------|----------|---------|--------|---------|
| 5 | **Hassan** | **Ahmed** | **Production Manager** | 0300-5555555 | hassan.ahmed@factory.com | 2 | 3 | 75000 | 2025-01-01 | Karachi, Pakistan | Active | Department Head - Oversees production |
| 6 | Zain | Ali | Tailor | 0300-6666666 | zain.ali@factory.com | 2 | 5 | 35000 | 2025-01-05 | Karachi, Pakistan | Active | Master Tailor - High skill level |
| 7 | Bilal | Hassan | Tailor | 0300-7777777 | bilal.hassan@factory.com | 2 | 5 | 32000 | 2025-01-10 | Lahore, Pakistan | Active | Tailor - Garment stitching |
| 8 | Aisha | Khan | Tailor | 0300-8888888 | aisha.khan@factory.com | 2 | 5 | 32000 | 2025-01-15 | Karachi, Pakistan | Active | Tailor - Garment stitching |
| 9 | Samir | Hassan | Tailor | 0300-9999999 | samir.hassan@factory.com | 2 | 5 | 31000 | 2025-01-20 | Islamabad, Pakistan | Active | Tailor - Garment stitching |

---

#### DEPARTMENT 3: DELIVERY (1 Delivery Person + 2 Drivers)

| # | FirstName | LastName | Position | Phone | Email | DepartmentID | RoleID | Salary | JoinDate | Address | Status | Purpose |
|---|-----------|----------|----------|-------|-------|--------------|--------|--------|----------|---------|--------|---------|
| 10 | **Muhammad** | **Khan** | **Delivery Person** | 0300-1010101 | muhammad.khan@factory.com | 3 | 3 | 35000 | 2025-01-01 | Karachi, Pakistan | Active | Chief Delivery Coordinator |
| 11 | Ahmed | Ali | Delivery Driver | 0300-1111112 | ahmed.driver@factory.com | 3 | 3 | 30000 | 2025-01-05 | Lahore, Pakistan | Active | Delivery Driver |
| 12 | Hassan | Malik | Delivery Driver | 0300-1212121 | hassan.driver@factory.com | 3 | 3 | 30000 | 2025-01-10 | Islamabad, Pakistan | Active | Delivery Driver |

---

## 📋 SUMMARY

| Department | Manager | Position Count | Total Staff | Roles |
|------------|---------|-----------------|------------|-------|
| Sales | Ahmad Khan (1) | Salesperson (3) | 4 | 1 Manager + 3 Salespersons |
| Production | Hassan Ahmed (1) | Tailor (4) | 5 | 1 Manager + 4 Tailors |
| Delivery | Muhammad Khan (1) | Delivery Driver (2) | 3 | 1 Coordinator + 2 Drivers |
| **TOTAL** | **3 Managers** | **9 Staff** | **12 Employees** | **Balanced Team** |

---

## 🎯 SQL SCRIPT TO INSERT SAMPLE EMPLOYEES

```sql
-- =============================================
-- INSERT SAMPLE EMPLOYEES
-- Garments Factory Management System
-- Date: December 17, 2025
-- =============================================

USE GarmentsFactoryDB;
GO

PRINT '🔄 Starting employee data insertion...';
PRINT '';

-- =============================================
-- DEPARTMENT 1: SALES EMPLOYEES
-- =============================================

PRINT '📌 DEPARTMENT 1: SALES (1 Manager + 3 Salespersons)';

-- Sales Manager
INSERT INTO Employee (FirstName, LastName, Position, Phone, Email, DepartmentID, RoleID, Salary, JoinDate, Address, IsActive, CreatedDate, Username, PIN)
VALUES ('Ahmad', 'Khan', 'Sales Manager', '0300-1111111', 'ahmad.khan@factory.com', 1, 3, 80000, '2025-01-01', 'Karachi, Pakistan', 1, GETDATE(), 'ahmad_khan', '1234');

-- Salesperson 1
INSERT INTO Employee (FirstName, LastName, Position, Phone, Email, DepartmentID, RoleID, Salary, JoinDate, Address, IsActive, CreatedDate, Username, PIN)
VALUES ('Ali', 'Ahmed', 'Salesperson', '0300-2222222', 'ali.ahmed@factory.com', 1, 3, 40000, '2025-01-05', 'Karachi, Pakistan', 1, GETDATE(), 'ali_ahmed', '1234');

-- Salesperson 2
INSERT INTO Employee (FirstName, LastName, Position, Phone, Email, DepartmentID, RoleID, Salary, JoinDate, Address, IsActive, CreatedDate, Username, PIN)
VALUES ('Fatima', 'Hassan', 'Salesperson', '0300-3333333', 'fatima.hassan@factory.com', 1, 3, 40000, '2025-01-10', 'Lahore, Pakistan', 1, GETDATE(), 'fatima_hassan', '1234');

-- Salesperson 3
INSERT INTO Employee (FirstName, LastName, Position, Phone, Email, DepartmentID, RoleID, Salary, JoinDate, Address, IsActive, CreatedDate, Username, PIN)
VALUES ('Hira', 'Malik', 'Salesperson', '0300-4444444', 'hira.malik@factory.com', 1, 3, 40000, '2025-01-15', 'Islamabad, Pakistan', 1, GETDATE(), 'hira_malik', '1234');

PRINT '   ✅ Added 1 Sales Manager + 3 Salespersons';

-- =============================================
-- DEPARTMENT 2: PRODUCTION EMPLOYEES
-- =============================================

PRINT '';
PRINT '📌 DEPARTMENT 2: PRODUCTION (1 Manager + 4 Tailors)';

-- Production Manager
INSERT INTO Employee (FirstName, LastName, Position, Phone, Email, DepartmentID, RoleID, Salary, JoinDate, Address, IsActive, CreatedDate, Username, PIN)
VALUES ('Hassan', 'Ahmed', 'Production Manager', '0300-5555555', 'hassan.ahmed@factory.com', 2, 3, 75000, '2025-01-01', 'Karachi, Pakistan', 1, GETDATE(), 'hassan_ahmed', '1234');

-- Tailor 1
INSERT INTO Employee (FirstName, LastName, Position, Phone, Email, DepartmentID, RoleID, Salary, JoinDate, Address, IsActive, CreatedDate, Username, PIN)
VALUES ('Zain', 'Ali', 'Tailor', '0300-6666666', 'zain.ali@factory.com', 2, 5, 35000, '2025-01-05', 'Karachi, Pakistan', 1, GETDATE(), 'zain_ali', '1234');

-- Tailor 2
INSERT INTO Employee (FirstName, LastName, Position, Phone, Email, DepartmentID, RoleID, Salary, JoinDate, Address, IsActive, CreatedDate, Username, PIN)
VALUES ('Bilal', 'Hassan', 'Tailor', '0300-7777777', 'bilal.hassan@factory.com', 2, 5, 32000, '2025-01-10', 'Lahore, Pakistan', 1, GETDATE(), 'bilal_hassan', '1234');

-- Tailor 3
INSERT INTO Employee (FirstName, LastName, Position, Phone, Email, DepartmentID, RoleID, Salary, JoinDate, Address, IsActive, CreatedDate, Username, PIN)
VALUES ('Aisha', 'Khan', 'Tailor', '0300-8888888', 'aisha.khan@factory.com', 2, 5, 32000, '2025-01-15', 'Karachi, Pakistan', 1, GETDATE(), 'aisha_khan', '1234');

-- Tailor 4
INSERT INTO Employee (FirstName, LastName, Position, Phone, Email, DepartmentID, RoleID, Salary, JoinDate, Address, IsActive, CreatedDate, Username, PIN)
VALUES ('Samir', 'Hassan', 'Tailor', '0300-9999999', 'samir.hassan@factory.com', 2, 5, 31000, '2025-01-20', 'Islamabad, Pakistan', 1, GETDATE(), 'samir_hassan', '1234');

PRINT '   ✅ Added 1 Production Manager + 4 Tailors';

-- =============================================
-- DEPARTMENT 3: DELIVERY EMPLOYEES
-- =============================================

PRINT '';
PRINT '📌 DEPARTMENT 3: DELIVERY (1 Coordinator + 2 Drivers)';

-- Delivery Person / Coordinator
INSERT INTO Employee (FirstName, LastName, Position, Phone, Email, DepartmentID, RoleID, Salary, JoinDate, Address, IsActive, CreatedDate, Username, PIN)
VALUES ('Muhammad', 'Khan', 'Delivery Person', '0300-1010101', 'muhammad.khan@factory.com', 3, 3, 35000, '2025-01-01', 'Karachi, Pakistan', 1, GETDATE(), 'muhammad_khan', '1234');

-- Delivery Driver 1
INSERT INTO Employee (FirstName, LastName, Position, Phone, Email, DepartmentID, RoleID, Salary, JoinDate, Address, IsActive, CreatedDate, Username, PIN)
VALUES ('Ahmed', 'Ali', 'Delivery Driver', '0300-1111112', 'ahmed.driver@factory.com', 3, 3, 30000, '2025-01-05', 'Lahore, Pakistan', 1, GETDATE(), 'ahmed_driver', '1234');

-- Delivery Driver 2
INSERT INTO Employee (FirstName, LastName, Position, Phone, Email, DepartmentID, RoleID, Salary, JoinDate, Address, IsActive, CreatedDate, Username, PIN)
VALUES ('Hassan', 'Malik', 'Delivery Driver', '0300-1212121', 'hassan.driver@factory.com', 3, 3, 30000, '2025-01-10', 'Islamabad, Pakistan', 1, GETDATE(), 'hassan_malik', '1234');

PRINT '   ✅ Added 1 Delivery Coordinator + 2 Delivery Drivers';

-- =============================================
-- VERIFICATION
-- =============================================

PRINT '';
PRINT '========================================';
PRINT '✅ ALL EMPLOYEES INSERTED SUCCESSFULLY';
PRINT '========================================';
PRINT '';

PRINT '📋 SUMMARY:';
PRINT '';
PRINT '   SALES DEPARTMENT:';
SELECT '      ' + FirstName + ' ' + LastName + ' (' + Position + ')' AS EmployeeInfo FROM Employee WHERE DepartmentID = 1 ORDER BY EmployeeID;

PRINT '';
PRINT '   PRODUCTION DEPARTMENT:';
SELECT '      ' + FirstName + ' ' + LastName + ' (' + Position + ')' AS EmployeeInfo FROM Employee WHERE DepartmentID = 2 ORDER BY EmployeeID;

PRINT '';
PRINT '   DELIVERY DEPARTMENT:';
SELECT '      ' + FirstName + ' ' + LastName + ' (' + Position + ')' AS EmployeeInfo FROM Employee WHERE DepartmentID = 3 ORDER BY EmployeeID;

PRINT '';
PRINT '📊 TOTAL EMPLOYEE COUNT:';
SELECT COUNT(*) AS TotalEmployees FROM Employee WHERE IsActive = 1;

PRINT '';
PRINT '💰 SALARY SUMMARY:';
SELECT DepartmentID, 
       (SELECT DepartmentName FROM Department WHERE DepartmentID = e.DepartmentID) AS Department,
       COUNT(*) AS EmployeeCount,
       SUM(Salary) AS TotalSalary,
       AVG(Salary) AS AverageSalary
FROM Employee e
WHERE IsActive = 1
GROUP BY DepartmentID
ORDER BY DepartmentID;

PRINT '';
PRINT '🔐 LOGIN CREDENTIALS:';
PRINT '   Default PIN for all: 1234';
PRINT '   Usernames: ahmad_khan, ali_ahmed, fatima_hassan, hira_malik,';
PRINT '             hassan_ahmed, zain_ali, bilal_hassan, aisha_khan, samir_hassan,';
PRINT '             muhammad_khan, ahmed_driver, hassan_malik';

GO
```

---

## 🧪 VERIFICATION QUERIES (Run After Insertion)

### Check All Employees
```sql
SELECT EmployeeID, FirstName + ' ' + LastName AS Name, Position, 
       (SELECT DepartmentName FROM Department WHERE DepartmentID = Employee.DepartmentID) AS Department,
       Salary, JoinDate, IsActive
FROM Employee
WHERE IsActive = 1
ORDER BY DepartmentID, EmployeeID;
```

### Check Employee Count by Department
```sql
SELECT DepartmentID, (SELECT DepartmentName FROM Department WHERE DepartmentID = e.DepartmentID) AS Department,
       COUNT(*) AS EmployeeCount
FROM Employee e
WHERE IsActive = 1
GROUP BY DepartmentID
ORDER BY DepartmentID;
```

### Check Managers
```sql
SELECT EmployeeID, FirstName + ' ' + LastName AS ManagerName, Position, 
       (SELECT DepartmentName FROM Department WHERE DepartmentID = Employee.DepartmentID) AS Department,
       Salary
FROM Employee
WHERE Position LIKE '%Manager%' AND IsActive = 1
ORDER BY DepartmentID;
```

### Check Tailors (for Production)
```sql
SELECT EmployeeID, FirstName + ' ' + LastName AS TailorName, Position, Phone, Email
FROM Employee
WHERE Position = 'Tailor' AND IsActive = 1
ORDER BY EmployeeID;
```

### Check Delivery Personnel
```sql
SELECT EmployeeID, FirstName + ' ' + LastName AS Name, Position, Phone
FROM Employee
WHERE (Position LIKE '%Delivery%' OR Position LIKE '%Driver%') AND IsActive = 1
ORDER BY EmployeeID;
```

---

## ✅ APPROVED FOR EXECUTION

**Total Employees to Insert:** 12  
**Departments Covered:** 3 (Sales, Production, Delivery)  
**Managers:** 3 (1 per department)  
**Staff:** 9 (Salespersons, Tailors, Drivers)  
**All Fields Filled:** Yes ✅
- FirstName, LastName
- Position
- Phone (Pakistan numbers format)
- Email (factory domain)
- DepartmentID (1, 2, or 3)
- RoleID (3 for most, 5 for Tailors)
- Salary (appropriate per position)
- JoinDate
- Address
- IsActive (1 = Active)
- Username (login name)
- PIN (1234 for all)

---

**Ready to Execute?** Type "YES" and I'll run the SQL script!
