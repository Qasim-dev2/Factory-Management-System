# Paper Factory Management System - Login Page

## Overview
This is a modern, full-screen login page for a Paper Factory Management System built with WPF (.NET). The system features a dark theme with smooth animations, role-based authentication, and clean architecture designed for easy database integration.

## Features

### 🎨 Modern UI Design
- **Full-screen dark theme** with gradient backgrounds
- **Smooth animations** including floating background elements and fade-in effects
- **Responsive design** that adapts to all laptop resolutions
- **Professional styling** with custom buttons, input fields, and transitions
- **Live animated wallpaper** with floating geometric shapes

### 🔐 Authentication System
- **Role-based login** with dropdown selection
- **Four user roles**: Owner, Manager, Employee, Salesperson
- **Secure authentication** with ID and password validation
- **Demo credentials** for testing (see below)
- **Input validation** with user-friendly error messages

### 🚀 Navigation & Routing
- **Role-specific dashboards** that open based on user selection
- **Smooth transitions** between login and dashboard screens
- **Logout functionality** that returns to login page
- **Keyboard shortcuts** (Enter to login, Escape to exit)

### 🏗️ Database-Ready Architecture
- **Clean separation** of concerns with Models, Data, and UI layers
- **User model hierarchy** with Owner, Manager, Employee, and Salesperson classes
- **Authentication service** ready for database integration
- **Entity Framework setup** prepared for future database connection

## Demo Credentials

Use these credentials to test the application:

### Owner
- **ID**: OWNER001
- **Password**: owner123

### Managers
- **ID**: MGR001, **Password**: manager123
- **ID**: MGR002, **Password**: manager456

### Employees
- **ID**: EMP001, **Password**: emp123
- **ID**: EMP002, **Password**: emp456

### Salespersons
- **ID**: SALES001, **Password**: sales123
- **ID**: SALES002, **Password**: sales456

## Project Structure

```
FactoryManagmentSystem/
├── MainWindow.xaml              # Login page UI
├── MainWindow.xaml.cs           # Login page logic
├── OwnerDashboard.xaml/.cs      # Owner dashboard
├── ManagerDashboard.xaml/.cs    # Manager dashboard
├── EmployeeDashboard.xaml/.cs   # Employee dashboard
├── SalespersonDashboard.xaml/.cs # Salesperson dashboard
├── Models/
│   └── User.cs                  # User models and authentication service
├── Data/
│   └── FactoryDbContext.cs      # Database context (prepared for EF)
└── FactoryManagmentSystem.csproj # Project file
```

## How to Use

### 1. Starting the Application
- Run `dotnet run` in the project directory
- The application opens in full-screen mode with animated background

### 2. Logging In
1. **Select Role**: Choose from Owner, Manager, Employee, or Salesperson
2. **Enter ID**: Input fields appear after role selection
3. **Enter Password**: Complete the authentication form
4. **Login**: Click the LOGIN button or press Enter

### 3. Dashboard Features
Each role has a customized dashboard with relevant functions:
- **Owner**: User management, financial reports, factory overview, analytics
- **Manager**: Employee management, production planning, quality control
- **Employee**: Task management, time tracking, equipment status
- **Salesperson**: Customer management, orders, sales reports, targets

### 4. Logging Out
- Click the "Logout" button in any dashboard to return to login page

## Database Integration Guide

The system is designed for easy database integration. Follow these steps when ready:

### 1. Install Entity Framework Packages
```bash
dotnet add package Microsoft.EntityFrameworkCore
dotnet add package Microsoft.EntityFrameworkCore.SqlServer
dotnet add package Microsoft.EntityFrameworkCore.Tools
dotnet add package Microsoft.EntityFrameworkCore.Design
```

### 2. Configure Connection String
Add to app.config or appsettings.json:
```xml
<connectionStrings>
  <add name="DefaultConnection" 
       connectionString="Server=(localdb)\mssqllocaldb;Database=PaperFactoryDB;Trusted_Connection=true;" />
</connectionStrings>
```

### 3. Enable Database Context
- Uncomment code in `Data/FactoryDbContext.cs`
- Update `AuthenticationService` to use database queries
- Add dependency injection configuration

### 4. Create Database
```bash
Add-Migration InitialCreate
Update-Database
```

## Technical Details

### Technologies Used
- **.NET 10** with Windows Presentation Foundation (WPF)
- **C# 12** with nullable reference types
- **XAML** for UI design with custom styles and animations
- **MVVM-ready architecture** for future expansion

### Key Components
- **Custom Styles**: Modern button, textbox, and combobox designs
- **Animations**: Storyboard-based animations for smooth transitions
- **Gradient Backgrounds**: Multi-layer gradients for visual depth
- **Responsive Layout**: Grid-based layout that scales with window size
- **Type Safety**: Comprehensive null checking and error handling

### Performance Features
- **Lightweight animations** that don't impact performance
- **Efficient rendering** with hardware acceleration
- **Memory-conscious** design patterns
- **Fast startup time** with minimal dependencies

## Customization Options

### Themes
- Modify gradient brushes in MainWindow.xaml Resources
- Change color schemes by updating gradient stop colors
- Adjust animation speeds in Storyboard durations

### Branding
- Update window titles and welcome messages
- Replace emoji icons with company logos
- Customize dashboard layouts and buttons

### Authentication
- Add additional user roles by extending the UserRole enum
- Implement password complexity requirements
- Add session management and timeout features

### UI Enhancements
- Add forgot password functionality
- Implement remember me checkbox
- Add multi-language support

## Future Enhancements

### Planned Features
- **Multi-factor authentication** (MFA)
- **Active Directory integration**
- **Audit logging** for security compliance
- **Session management** with timeout
- **Password reset** functionality
- **User profile management**
- **Theme switching** (light/dark mode)

### Database Integration
- **SQL Server** support with Entity Framework
- **MySQL/PostgreSQL** compatibility
- **Cloud database** integration (Azure SQL, AWS RDS)
- **Data encryption** for sensitive information

## Support & Documentation

### Getting Help
- Check the demo credentials if login fails
- Ensure all NuGet packages are restored
- Verify .NET 10 is installed on your system
- Review error messages in the status area

### Contributing
The codebase is structured for easy contribution:
- Models are separated for clear data representation
- UI components are modular and reusable
- Authentication logic is centralized
- Database integration points are clearly marked

---

**Note**: This is a front-end implementation with demo data. The authentication service includes detailed instructions for connecting to a real database when you're ready to integrate with your backend system.