-- Fix Deal procedures and add sample data
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Update sp_GetAllDeals with CreatedByName
DROP PROCEDURE IF EXISTS sp_GetAllDeals;
GO

CREATE PROCEDURE sp_GetAllDeals
    @SearchTerm NVARCHAR(200) = '',
    @StatusFilter NVARCHAR(50) = 'All'
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        d.DealID,
        d.DealTitle,
        d.DealType,
        d.ClientName,
        d.ContactPerson,
        d.Email,
        d.Phone,
        d.ExpectedDuration,
        d.StartDate,
        d.EndDate,
        d.Description,
        d.Status,
        d.CreatedBy,
        ISNULL(e.FirstName + ' ' + e.LastName, 'Owner') AS CreatedByName,
        d.CreatedDate,
        d.UpdatedDate,
        d.DeliveryAddress,
        d.City,
        d.Province
    FROM Deal d
    LEFT JOIN Employee e ON d.CreatedBy = e.EmployeeID
    WHERE (@SearchTerm = '' OR d.DealTitle LIKE '%' + @SearchTerm + '%' OR d.ClientName LIKE '%' + @SearchTerm + '%' OR d.ContactPerson LIKE '%' + @SearchTerm + '%')
      AND (@StatusFilter = 'All' OR d.Status = @StatusFilter)
    ORDER BY d.CreatedDate DESC;
END
GO

PRINT 'sp_GetAllDeals updated with CreatedByName';
GO

-- Update sp_GetDealById with CreatedByName
DROP PROCEDURE IF EXISTS sp_GetDealById;
GO

CREATE PROCEDURE sp_GetDealById
    @DealID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        d.DealID,
        d.DealTitle,
        d.DealType,
        d.ClientName,
        d.ContactPerson,
        d.Email,
        d.Phone,
        d.ExpectedDuration,
        d.StartDate,
        d.EndDate,
        d.Description,
        d.Status,
        d.CreatedBy,
        ISNULL(e.FirstName + ' ' + e.LastName, 'Owner') AS CreatedByName,
        d.CreatedDate,
        d.UpdatedDate,
        d.DeliveryAddress,
        d.City,
        d.Province
    FROM Deal d
    LEFT JOIN Employee e ON d.CreatedBy = e.EmployeeID
    WHERE d.DealID = @DealID;
END
GO

PRINT 'sp_GetDealById updated with CreatedByName';
GO

-- Insert sample deals
DELETE FROM Deal;
GO

INSERT INTO Deal (DealTitle, DealType, ClientName, ContactPerson, Email, Phone, ExpectedDuration, StartDate, EndDate, Description, Status, CreatedBy, CreatedDate, DeliveryAddress, City, Province)
VALUES 
('Bulk T-Shirt Order for Event', 'Bulk Order', 'ABC Events Company', 'Ahmed Khan', 'ahmed@abcevents.com', '0300-1234567', '2 weeks', GETDATE(), DATEADD(DAY, 14, GETDATE()), 'Custom printed t-shirts for corporate event with company logo', 'Pending', NULL, GETDATE(), 'Plot 45, Industrial Area', 'Lahore', 'Punjab'),

('Custom Uniform Design', 'Custom Design', 'Royal School System', 'Sara Malik', 'sara@royalschool.edu.pk', '0321-9876543', '1 month', GETDATE(), DATEADD(DAY, 30, GETDATE()), 'School uniforms for 200 students - custom design with embroidery', 'Pending', NULL, GETDATE(), '12-B, Model Town', 'Karachi', 'Sindh'),

('Wholesale Jeans Order', 'Wholesale', 'Fashion Hub Retailers', 'Bilal Ahmed', 'bilal@fashionhub.pk', '0333-5556677', '3 weeks', GETDATE(), DATEADD(DAY, 21, GETDATE()), 'Wholesale order of 500 jeans in various sizes for retail distribution', 'Active', NULL, DATEADD(DAY, -2, GETDATE()), 'Shop 23, Main Market', 'Islamabad', 'Punjab');
GO

PRINT '3 sample deals inserted successfully';
GO

PRINT '=================================================================';
PRINT 'All fixes applied! Deals table now has sample data.';
PRINT '=================================================================';
