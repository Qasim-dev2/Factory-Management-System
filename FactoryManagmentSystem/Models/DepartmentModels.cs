using System;
using System.Collections.Generic;
using System.ComponentModel;

namespace FactoryManagmentSystem.Models
{
    // Base Department Model
    public abstract class Department : INotifyPropertyChanged
    {
        public event PropertyChangedEventHandler? PropertyChanged;

        public int Id { get; set; }
        public string DepartmentId { get; set; } = "";
        public string Name { get; set; } = "";
        public string Description { get; set; } = "";
        public string Manager { get; set; } = "";
        public int EmployeeCount { get; set; }
        public decimal Budget { get; set; }
        public DateTime CreatedDate { get; set; }
        public string Status { get; set; } = "Active";

        protected virtual void OnPropertyChanged(string propertyName)
        {
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
        }
    }

    // Production Department
    public class ProductionDepartment : Department
    {
        public int TotalUnitsProduced { get; set; }
        public int DailyProductionTarget { get; set; }
        public int CurrentDayProduction { get; set; }
        public decimal ProductionEfficiency { get; set; }
        public int ActiveProductionLines { get; set; }
        public int TotalProductionLines { get; set; }
        public string CurrentProduct { get; set; } = "";
        public DateTime LastProductionDate { get; set; }
        public List<ProductionMetric> ProductionMetrics { get; set; } = new();

        public decimal ProductionRate => DailyProductionTarget > 0 ? 
            (decimal)CurrentDayProduction / DailyProductionTarget * 100 : 0;
    }

    public class ProductionMetric
    {
        public DateTime Date { get; set; }
        public int UnitsProduced { get; set; }
        public int Target { get; set; }
        public string ProductType { get; set; } = "";
        public decimal Efficiency { get; set; }
    }

    // Maintenance Department
    public class MaintenanceDepartment : Department
    {
        public int TotalMachines { get; set; }
        public int MachinesUnderMaintenance { get; set; }
        public int OperationalMachines { get; set; }
        public int ScheduledMaintenanceCount { get; set; }
        public int CompletedMaintenanceCount { get; set; }
        public decimal MaintenanceCost { get; set; }
        public DateTime LastMaintenanceDate { get; set; }
        public DateTime NextScheduledMaintenance { get; set; }
        public List<MaintenanceRecord> MaintenanceRecords { get; set; } = new();

        public decimal MaintenanceEfficiency => TotalMachines > 0 ? 
            (decimal)OperationalMachines / TotalMachines * 100 : 0;
    }

    public class MaintenanceRecord
    {
        public string MachineId { get; set; } = "";
        public string MachineName { get; set; } = "";
        public string MaintenanceType { get; set; } = "";
        public DateTime ScheduledDate { get; set; }
        public DateTime? CompletedDate { get; set; }
        public string Status { get; set; } = "";
        public decimal Cost { get; set; }
        public string Technician { get; set; } = "";
        public string Notes { get; set; } = "";
    }

    // Finance Department
    public class FinanceDepartment : Department
    {
        public decimal TotalRevenue { get; set; }
        public decimal TotalExpenses { get; set; }
        public decimal MonthlyRevenue { get; set; }
        public decimal MonthlyExpenses { get; set; }
        public decimal NetProfit { get; set; }
        public decimal ProfitMargin { get; set; }
        public int PendingInvoices { get; set; }
        public decimal PendingAmount { get; set; }
        public List<FinancialRecord> FinancialRecords { get; set; } = new();

        public decimal ProfitPercentage => TotalRevenue > 0 ? 
            (NetProfit / TotalRevenue) * 100 : 0;
    }

    public class FinancialRecord
    {
        public DateTime Date { get; set; }
        public string TransactionType { get; set; } = "";
        public decimal Amount { get; set; }
        public string Category { get; set; } = "";
        public string Description { get; set; } = "";
        public string Reference { get; set; } = "";
        public string Status { get; set; } = "";
    }

    // Quality Assurance Department
    public class QualityAssuranceDepartment : Department
    {
        public int TotalInspections { get; set; }
        public int PassedInspections { get; set; }
        public int FailedInspections { get; set; }
        public decimal QualityScore { get; set; }
        public int DefectiveUnits { get; set; }
        public int ReworkUnits { get; set; }
        public int RejectedUnits { get; set; }
        public DateTime LastQualityAudit { get; set; }
        public List<QualityMetric> QualityMetrics { get; set; } = new();

        public decimal PassRate => TotalInspections > 0 ? 
            (decimal)PassedInspections / TotalInspections * 100 : 0;
    }

    public class QualityMetric
    {
        public DateTime Date { get; set; }
        public string ProductType { get; set; } = "";
        public int UnitsInspected { get; set; }
        public int DefectsFound { get; set; }
        public string DefectType { get; set; } = "";
        public string Inspector { get; set; } = "";
        public string Action { get; set; } = "";
        public decimal QualityScore { get; set; }
    }

    // Transport Department
    public class TransportDepartment : Department
    {
        public int TotalDeliveries { get; set; }
        public int CompletedDeliveries { get; set; }
        public int PendingDeliveries { get; set; }
        public int InTransitDeliveries { get; set; }
        public decimal TotalDeliveredUnits { get; set; }
        public decimal PendingDeliveryUnits { get; set; }
        public int AvailableVehicles { get; set; }
        public int TotalVehicles { get; set; }
        public DateTime LastDeliveryDate { get; set; }
        public List<DeliveryRecord> DeliveryRecords { get; set; } = new();

        public decimal DeliveryEfficiency => TotalDeliveries > 0 ? 
            (decimal)CompletedDeliveries / TotalDeliveries * 100 : 0;
    }

    public class DeliveryRecord
    {
        public string DeliveryId { get; set; } = "";
        public DateTime ScheduledDate { get; set; }
        public DateTime? ActualDate { get; set; }
        public string Destination { get; set; } = "";
        public decimal Units { get; set; }
        public string ProductType { get; set; } = "";
        public string VehicleId { get; set; } = "";
        public string Driver { get; set; } = "";
        public string Status { get; set; } = "";
        public string Notes { get; set; } = "";
    }

    // Department Summary for Dashboard
    public class DepartmentSummary
    {
        public string DepartmentName { get; set; } = "";
        public string Status { get; set; } = "";
        public decimal Performance { get; set; }
        public int EmployeeCount { get; set; }
        public decimal Budget { get; set; }
        public string Manager { get; set; } = "";
        public string LastUpdate { get; set; } = "";
        public Dictionary<string, object> KeyMetrics { get; set; } = new();
    }
}