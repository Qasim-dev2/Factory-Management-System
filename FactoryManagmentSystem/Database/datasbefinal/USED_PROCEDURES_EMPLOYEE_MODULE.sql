-- =============================================
-- USED PROCEDURES: EMPLOYEE & ADMIN MODULE
-- Only procedures actively used in the project
-- With Frontend Button/Action Mapping
-- Generated: December 17, 2025
-- =============================================

/*
==============================================
AUTHENTICATION & AUTHORIZATION (3 Procedures)
==============================================
*/

-- ============================================================================
-- sp_AuthenticateUser
-- ============================================================================
-- SERVICE: Called directly in MainWindow.xaml.cs (Line 307)
-- FRONTEND: MainWindow - Login Screen
-- BUTTON/ACTION: "Login" button
-- PURPOSE: Authenticates user credentials and retrieves role information
-- PARAMETERS: @Username NVARCHAR(50), @PIN NVARCHAR(50)
-- RETURNS: EmployeeID, FirstName, LastName, RoleID, RoleName, DepartmentID, 
--          IsActive, LastLogin
-- AUTO-ACTIONS: 
--   - Validates username and PIN match
--   - Checks IsActive = 1
--   - Returns employee details for session
-- ROUTING: Based on RoleID, routes to appropriate dashboard:
--   RoleID 1 → OwnerDashboard
--   RoleID 2 → SalesManagerDashboard  
--   RoleID 3 → SalespersonDashboard
--   RoleID 4 → ProductionManagerDashboard
--   RoleID 5 → TailorDashboard
--   RoleID 6 → DeliveryPersonDashboard
-- ============================================================================

-- ============================================================================
-- sp_UpdateLastLogin
-- ============================================================================
-- SERVICE: AuthenticationService.cs / MainWindow.xaml.cs
-- FRONTEND: MainWindow - Login Screen
-- BUTTON/ACTION: Auto-called after successful login
-- PURPOSE: Updates employee's last login timestamp
-- PARAMETERS: @EmployeeID INT, @LoginDateTime DATETIME
-- AUTO-ACTIONS: Sets Employee.LastLogin = NOW
-- TRACKING: Used for activity monitoring and security auditing
-- ============================================================================

-- ============================================================================
-- sp_ChangeEmployeePassword
-- ============================================================================
-- SERVICE: EmployeeDataService.cs → ChangePasswordAsync()
-- FRONTEND: All Dashboards - Profile/Settings menu
-- BUTTON/ACTION: "Change Password" menu item → Password Change Dialog
-- PURPOSE: Allows employee to change their password/PIN
-- PARAMETERS: @EmployeeID INT, @OldPassword NVARCHAR(50), @NewPassword NVARCHAR(50)
-- VALIDATION: 
--   - Verifies old password matches
--   - Ensures new password meets requirements
-- SECURITY: Passwords should be hashed (currently using PIN for simplicity)
-- ============================================================================


/*
==============================================
EMPLOYEE MANAGEMENT (12 Procedures)
==============================================
*/

-- ============================================================================
-- sp_GetAllEmployees
-- ============================================================================
-- SERVICE: EmployeeDataService.cs → GetAllEmployeesAsync()
-- FRONTEND: OwnerDashboard → Employees → EmployeeManagementView
-- BUTTON/ACTION: Page Load (Automatic)
-- PURPOSE: Retrieves all employees with role and department details
-- RETURNS: EmployeeID, FirstName, LastName, RoleName, DepartmentName, 
--          PhoneNumber, Email, IsActive, HireDate
-- ============================================================================

-- ============================================================================
-- sp_GetEmployeeById
-- ============================================================================
-- SERVICE: EmployeeDataService.cs → GetEmployeeByIdAsync()
-- FRONTEND: Employee Management View
-- BUTTON/ACTION: "View Details" button
-- PURPOSE: Fetches detailed information for a specific employee
-- PARAMETERS: @EmployeeID INT
-- RETURNS: Complete employee record including personal and employment details
-- ============================================================================

-- ============================================================================
-- sp_AddEmployee
-- ============================================================================
-- SERVICE: EmployeeDataService.cs → AddEmployeeAsync()
-- FRONTEND: Employee Management View
-- BUTTON/ACTION: "Add Employee" button
-- PURPOSE: Creates a new employee record
-- PARAMETERS: @FirstName, @LastName, @RoleID, @DepartmentID, @PhoneNumber, 
--             @Email, @Address, @Salary, @HireDate, @Username, @PIN
-- AUTO-ACTIONS: Sets IsActive=1, CreatedDate=NOW
-- VALIDATION: Ensures username is unique
-- ============================================================================

-- ============================================================================
-- sp_UpdateEmployee
-- ============================================================================
-- SERVICE: EmployeeDataService.cs → UpdateEmployeeAsync()
-- FRONTEND: Employee Management View
-- BUTTON/ACTION: "Update Employee" button
-- PURPOSE: Updates existing employee information
-- PARAMETERS: @EmployeeID, @FirstName, @LastName, @RoleID, @DepartmentID, 
--             @PhoneNumber, @Email, @Address, @Salary
-- NOTE: Does not update Username/PIN (use separate procedure)
-- ============================================================================

-- ============================================================================
-- sp_DeleteEmployee
-- ============================================================================
-- SERVICE: EmployeeDataService.cs → DeleteEmployeeAsync()
-- FRONTEND: Employee Management View
-- BUTTON/ACTION: "Delete Employee" button (or "Deactivate")
-- PURPOSE: Soft deletes employee (sets IsActive=0)
-- PARAMETERS: @EmployeeID INT
-- NOTE: Typically soft delete to preserve historical data
-- ALTERNATIVE: Hard delete removes record entirely
-- ============================================================================

-- ============================================================================
-- sp_GetEmployeesByRole
-- ============================================================================
-- SERVICE: EmployeeDataService.cs → GetEmployeesByRoleAsync()
-- FRONTEND: Employee Management View, Role-based filtering
-- BUTTON/ACTION: Role filter dropdown
-- PURPOSE: Filters employees by their role
-- PARAMETERS: @RoleID INT
-- USED FOR: Finding all salespeople, tailors, delivery persons, etc.
-- ============================================================================

-- ============================================================================
-- sp_GetEmployeesByDepartment
-- ============================================================================
-- SERVICE: EmployeeDataService.cs → GetEmployeesByDepartmentAsync()
-- FRONTEND: Employee Management View, Department filtering
-- BUTTON/ACTION: Department filter dropdown
-- PURPOSE: Filters employees by their department
-- PARAMETERS: @DepartmentID INT
-- USED FOR: Department-wise employee management
-- ============================================================================

-- ============================================================================
-- sp_SearchEmployees
-- ============================================================================
-- SERVICE: EmployeeDataService.cs → SearchEmployeesAsync()
-- FRONTEND: Employee Management View
-- BUTTON/ACTION: Search box text change
-- PURPOSE: Searches employees by various criteria
-- PARAMETERS: @SearchTerm NVARCHAR(100)
-- SEARCHES: FirstName, LastName, Email, PhoneNumber, Username
-- ============================================================================

-- ============================================================================
-- sp_GetEmployeeStatistics
-- ============================================================================
-- SERVICE: EmployeeDataService.cs → GetEmployeeStatisticsAsync()
-- FRONTEND: OwnerDashboard - HR Stats Panel
-- BUTTON/ACTION: Page Load (Dashboard stats cards)
-- PURPOSE: Provides summary statistics for employees
-- RETURNS: TotalEmployees, ActiveEmployees, ByRole (counts per role), 
--          ByDepartment, NewHiresThisMonth
-- ============================================================================

-- ============================================================================
-- sp_GetEmployeesForTailorAssignment
-- ============================================================================
-- SERVICE: EmployeeDataService.cs / TailorService.cs → GetTailorsForAssignmentAsync()
-- FRONTEND: ProductionManagerDashboard - Assign Tailor dialog
-- BUTTON/ACTION: "Assign Tailor" button (populates tailor dropdown)
-- PURPOSE: Gets all active employees with Role='Tailor'
-- RETURNS: EmployeeID, FullName, CurrentAssignmentsCount
-- FILTER: RoleID=5 (Tailor), IsActive=1
-- SORTED BY: CurrentAssignmentsCount ASC (least busy first)
-- ============================================================================

-- ============================================================================
-- sp_GetEmployeesForDeliveryAssignment
-- ============================================================================
-- SERVICE: EmployeeDataService.cs / DeliveryDataService.cs → GetDeliveryPersonsAsync()
-- FRONTEND: Delivery Management - Auto-assignment or manual selection
-- BUTTON/ACTION: Auto-called when creating delivery
-- PURPOSE: Gets all active employees with Role='Delivery Person'
-- RETURNS: EmployeeID, FullName, CurrentDeliveriesCount
-- FILTER: RoleID=6 (Delivery Person), IsActive=1
-- SORTED BY: CurrentDeliveriesCount ASC (least busy first)
-- ============================================================================

-- ============================================================================
-- sp_UpdateEmployeeStatus
-- ============================================================================
-- SERVICE: EmployeeDataService.cs → UpdateEmployeeStatusAsync()
-- FRONTEND: Employee Management View
-- BUTTON/ACTION: "Activate" / "Deactivate" toggle button
-- PURPOSE: Activates or deactivates an employee
-- PARAMETERS: @EmployeeID INT, @IsActive BIT
-- USED FOR: Temporary suspension or reactivation without deleting record
-- ============================================================================


/*
==============================================
DEPARTMENT MANAGEMENT (10 Procedures)
==============================================
*/

-- ============================================================================
-- sp_GetAllDepartments
-- ============================================================================
-- SERVICE: DepartmentDataService.cs → GetAllDepartmentsAsync()
-- FRONTEND: OwnerDashboard → Departments
-- BUTTON/ACTION: Page Load (Automatic)
-- PURPOSE: Retrieves all departments with manager and employee count
-- RETURNS: DepartmentID, DepartmentName, ManagerName, EmployeeCount, Budget
-- ============================================================================

-- ============================================================================
-- sp_GetDepartmentById
-- ============================================================================
-- SERVICE: DepartmentDataService.cs → GetDepartmentByIdAsync()
-- FRONTEND: Department Management View
-- BUTTON/ACTION: "View Details" button
-- PURPOSE: Fetches detailed information for a specific department
-- PARAMETERS: @DepartmentID INT
-- RETURNS: Complete department record with manager and stats
-- ============================================================================

-- ============================================================================
-- sp_AddDepartment
-- ============================================================================
-- SERVICE: DepartmentService.cs → AddDepartmentAsync()
-- FRONTEND: Department Management View
-- BUTTON/ACTION: "Add Department" button
-- PURPOSE: Creates a new department record
-- PARAMETERS: @DepartmentName NVARCHAR(100), @ManagerID INT, @Budget DECIMAL, 
--             @NewDepartmentID OUTPUT
-- RETURNS: @NewDepartmentID (newly created department ID)
-- NOTE: Fixed OUTPUT parameter handling in DepartmentService.cs
-- ============================================================================

-- ============================================================================
-- sp_UpdateDepartment
-- ============================================================================
-- SERVICE: DepartmentDataService.cs → UpdateDepartmentAsync()
-- FRONTEND: Department Management View
-- BUTTON/ACTION: "Update Department" button
-- PURPOSE: Updates existing department information
-- PARAMETERS: @DepartmentID, @DepartmentName, @ManagerID, @Budget
-- ============================================================================

-- ============================================================================
-- sp_DeleteDepartment
-- ============================================================================
-- SERVICE: DepartmentDataService.cs → DeleteDepartmentAsync()
-- FRONTEND: Department Management View
-- BUTTON/ACTION: "Delete Department" button
-- PURPOSE: Removes a department from the system
-- PARAMETERS: @DepartmentID INT
-- VALIDATION: Prevents deletion if employees are assigned
-- ============================================================================

-- ============================================================================
-- sp_GetDepartmentEmployees
-- ============================================================================
-- SERVICE: DepartmentDataService.cs → GetDepartmentEmployeesAsync()
-- FRONTEND: Department Details View
-- BUTTON/ACTION: "View Employees" button
-- PURPOSE: Lists all employees in a specific department
-- PARAMETERS: @DepartmentID INT
-- RETURNS: EmployeeID, FullName, RoleName, Salary, HireDate
-- ============================================================================

-- ============================================================================
-- sp_GetDepartmentStatistics
-- ============================================================================
-- SERVICE: DepartmentDataService.cs → GetDepartmentStatisticsAsync()
-- FRONTEND: Department Management View, OwnerDashboard
-- BUTTON/ACTION: Page Load (Dashboard stats)
-- PURPOSE: Provides summary statistics for departments
-- RETURNS: TotalDepartments, TotalBudget, AvgEmployeesPerDept, 
--          LargestDepartment, SmallestDepartment
-- ============================================================================

-- ============================================================================
-- sp_TransferEmployee
-- ============================================================================
-- SERVICE: EmployeeDataService.cs → TransferEmployeeAsync()
-- FRONTEND: Employee Management View
-- BUTTON/ACTION: "Transfer Employee" button
-- PURPOSE: Moves an employee from one department to another
-- PARAMETERS: @EmployeeID INT, @NewDepartmentID INT
-- AUTO-ACTIONS: Updates Employee.DepartmentID, records transfer history
-- ============================================================================

-- ============================================================================
-- sp_GetDepartmentBudgetUtilization
-- ============================================================================
-- SERVICE: DepartmentDataService.cs → GetDepartmentBudgetUtilizationAsync()
-- FRONTEND: OwnerDashboard - Financial Reports
-- BUTTON/ACTION: "Department Budget Report" button
-- PURPOSE: Shows budget vs actual spending per department
-- PARAMETERS: @DepartmentID INT (NULL = all departments)
-- RETURNS: DepartmentName, Budget, TotalSalaries, UtilizationPercent, Status
-- CALCULATION: UtilizationPercent = (TotalSalaries / Budget) * 100
-- ============================================================================

-- ============================================================================
-- sp_GetManagersByDepartment
-- ============================================================================
-- SERVICE: DepartmentDataService.cs → GetManagersAsync()
-- FRONTEND: Department Management - Manager assignment dropdown
-- BUTTON/ACTION: Page Load (populates manager dropdown)
-- PURPOSE: Gets all employees eligible to be department managers
-- RETURNS: EmployeeID, FullName, CurrentDepartment
-- FILTER: Role IN ('Manager', 'Owner', 'Production Manager', 'Sales Manager')
-- ============================================================================


/*
==============================================
ROLE MANAGEMENT (5 Procedures)
==============================================
*/

-- ============================================================================
-- sp_GetAllRoles
-- ============================================================================
-- SERVICE: EmployeeDataService.cs → GetAllRolesAsync()
-- FRONTEND: Employee Management - Role assignment
-- BUTTON/ACTION: Page Load (populates role dropdown)
-- PURPOSE: Retrieves all available roles in the system
-- RETURNS: RoleID, RoleName, Description, PermissionLevel
-- ROLES: Owner, Sales Manager, Salesperson, Production Manager, Tailor, Delivery Person
-- ============================================================================

-- ============================================================================
-- sp_GetRoleById
-- ============================================================================
-- SERVICE: EmployeeDataService.cs → GetRoleByIdAsync()
-- FRONTEND: Role Management View
-- BUTTON/ACTION: "View Role Details" button
-- PURPOSE: Fetches detailed information for a specific role
-- PARAMETERS: @RoleID INT
-- RETURNS: Complete role definition with permissions
-- ============================================================================

-- ============================================================================
-- sp_GetEmployeeCountByRole
-- ============================================================================
-- SERVICE: EmployeeDataService.cs → GetEmployeeCountByRoleAsync()
-- FRONTEND: OwnerDashboard - HR Analytics
-- BUTTON/ACTION: Page Load (Dashboard role distribution chart)
-- PURPOSE: Counts employees in each role
-- RETURNS: RoleName, EmployeeCount
-- USED FOR: Role distribution pie chart
-- ============================================================================

-- ============================================================================
-- sp_GetRolePermissions
-- ============================================================================
-- SERVICE: EmployeeDataService.cs → GetRolePermissionsAsync()
-- FRONTEND: Role Management View
-- BUTTON/ACTION: "View Permissions" button
-- PURPOSE: Shows what actions a role can perform
-- PARAMETERS: @RoleID INT
-- RETURNS: PermissionName, CanView, CanCreate, CanUpdate, CanDelete
-- USED FOR: Access control and authorization
-- ============================================================================

-- ============================================================================
-- sp_UpdateEmployeeRole
-- ============================================================================
-- SERVICE: EmployeeDataService.cs → UpdateEmployeeRoleAsync()
-- FRONTEND: Employee Management View
-- BUTTON/ACTION: "Change Role" button
-- PURPOSE: Assigns a different role to an employee
-- PARAMETERS: @EmployeeID INT, @NewRoleID INT
-- AUTO-ACTIONS: Updates Employee.RoleID, records role change history
-- IMPACT: Changes dashboard access and permissions
-- ============================================================================


PRINT '✓ Employee & Admin Module procedures documented';
PRINT '✓ 3 Authentication procedures';
PRINT '✓ 12 Employee Management procedures';
PRINT '✓ 10 Department Management procedures';
PRINT '✓ 5 Role Management procedures';
PRINT '✓ Total: 30 procedures with frontend button mappings';
GO
