using System;

namespace FactoryManagmentSystem
{
    /// <summary>
    /// Stores the currently logged-in user's information across the application
    /// </summary>
    public static class UserSession
    {
        public static int EmployeeID { get; set; }
        public static string FirstName { get; set; }
        public static string LastName { get; set; }
        public static string FullName { get; set; }
        public static string Role { get; set; }
        public static string Username { get; set; }
        public static string Email { get; set; }
        public static string Phone { get; set; }
        public static DateTime? LastLogin { get; set; }
        
        /// <summary>
        /// Check if user is logged in
        /// </summary>
        public static bool IsLoggedIn => EmployeeID > 0;
        
        /// <summary>
        /// Clear session data (for logout)
        /// </summary>
        public static void Clear()
        {
            EmployeeID = 0;
            FirstName = null;
            LastName = null;
            FullName = null;
            Role = null;
            Username = null;
            Email = null;
            Phone = null;
            LastLogin = null;
        }
    }
}
