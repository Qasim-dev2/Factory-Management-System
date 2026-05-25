# Factory Management System - Database Setup Instructions

## 🎯 What We've Accomplished

Your Factory Management System now has:
- **4 Role-Based Dashboards**: Owner, Manager, Employee, Salesperson
- **Database Integration**: SQL Server with user authentication
- **Dropdown Login System**: Your existing UI now connects to the database
- **Fallback Authentication**: Works even if database is not set up yet

## 🔧 Database Setup (Optional but Recommended)

### Step 1: Install SQL Server
If you don't have SQL Server installed:
- **Option A**: Install SQL Server Express (Free) from Microsoft
- **Option B**: Use SQL Server LocalDB (comes with Visual Studio)

### Step 2: Execute Database Scripts
1. Open SQL Server Management Studio (SSMS)
2. Connect to your SQL Server instance
3. Execute the scripts in this order:
   - First: `Database/01_CreateDatabase.sql`
   - Then: `Database/02_SampleData.sql`

### Step 3: Update Connection String (If Needed)
In `App.xaml.cs`, the connection string is already set for common configurations:
- SQL Server Express: `.\SQLEXPRESS`
- LocalDB: `(localdb)\MSSQLLocalDB`

If you have a different setup, update the `GetConnectionString()` method.

## 🎮 How to Test

### With Database (Recommended):
1. Run the application: `dotnet run`
2. Select role from dropdown
3. Select user ID (loaded from database)
4. Select password (auto-filled)
5. Click LOGIN

### Without Database (Fallback):
The system works with hardcoded credentials if database is not available.

## 👥 User Accounts in Database

| Role | User IDs | Password |
|------|----------|-----------|
| **Owner** | owner1, owner2 | Owner123! |
| **Manager** | manager1, manager2 | Manager123! |
| **Employee** | employee1, employee2 | Employee123! |
| **Salesperson** | sales1, sales2 | Sales123! |

## 🔄 How It Works

1. **Role Selection**: User selects their role from dropdown
2. **Database Query**: System loads available user IDs for that role from database
3. **Password Auto-fill**: Standard password for the role is automatically selected
4. **Authentication**: System authenticates against database using secure password hashing
5. **Session Creation**: Creates secure session token for the user
6. **Dashboard Redirect**: Redirects to role-appropriate dashboard
7. **Audit Logging**: Logs all login attempts and user actions

## 🛡️ Security Features

- **Password Hashing**: PBKDF2 with salt (100,000 iterations)
- **Session Management**: Secure token-based sessions
- **Failed Login Tracking**: Account lockout after 5 failed attempts
- **Audit Trail**: All user actions are logged
- **Role-Based Permissions**: Each role has specific module access

## 🎨 Dashboard Integration

After successful login, users are redirected to:
- `Views/OwnerDashboard.xaml` - Full system access
- `Views/ManagerDashboard.xaml` - Management features
- `Views/EmployeeDashboard.xaml` - Operational features
- `Views/SalespersonDashboard.xaml` - Sales-focused features

## 🚀 Next Steps

1. **Test the application** with your existing dashboards
2. **Execute database scripts** when ready for full database integration
3. **Customize user accounts** by adding more users to the database
4. **Extend permissions** by modifying role access in the database

The system is designed to work seamlessly with your existing GUI workflow while providing professional database-driven authentication when available!