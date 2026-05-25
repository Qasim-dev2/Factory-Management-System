-- Update sp_GetTailorAssignments to properly join with Product table
-- This ensures ProductName is retrieved correctly

DROP PROCEDURE IF EXISTS sp_GetTailorAssignments;
GO

CREATE PROCEDURE sp_GetTailorAssignments
    @TailorID INT = NULL,
    @Status NVARCHAR(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        ta.AssignmentID AS TailorAssignmentID,
        ISNULL(ta.ProductionOrderID, 0) AS ProductionOrderID,
        ISNULL(ta.ProductID, 0) AS ProductID,
        ISNULL(p.ProductName, 'N/A') AS ProductName,
        ISNULL(p.Category, '') AS Category,
        ISNULL(p.Material, '') AS Material,
        ISNULL(ta.Status, 'Incomplete') AS CompletionStatus,
        ta.QuantityAssigned AS QuantityOrdered,
        ISNULL(po.Status, 'Pending') AS ProductionStatus,
        ISNULL(po.Priority, 'Normal') AS Priority,
        ta.AssignedDate,
        po.ExpectedEndDate,
        ta.CompletedDate,
        0 AS TotalTailors,
        0 AS CompletedTailors,
        e.FirstName + ' ' + e.LastName AS TailorName
    FROM TailorAssignment ta
    LEFT JOIN Employee e ON ta.TailorID = e.EmployeeID
    LEFT JOIN Product p ON ta.ProductID = p.ProductID
    LEFT JOIN ProductionOrder po ON ta.ProductionOrderID = po.ProductionOrderID
    WHERE (@TailorID IS NULL OR ta.TailorID = @TailorID)
      AND (@Status IS NULL OR ta.Status = @Status)
    ORDER BY ta.AssignedDate DESC;
END
GO
