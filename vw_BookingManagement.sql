USE PortfolioOfEvidencePOneDB;
GO

CREATE VIEW vw_BookingManagement AS
SELECT 
    b.BookingID,
    e.EventID,
    e.Name AS EventName,
    e.StartDate AS EventDate,
    e.Notes AS EventNotes,
    v.VenueID,
    v.Name AS VenueName,
    v.Location AS VenueLocation,
    v.Capacity AS VenueCapacity,
    v.ImageURL AS VenueImage,
    b.StartDate AS BookingStart,
    b.EndDate AS BookingEnd,
    DATEDIFF(HOUR, b.StartDate, b.EndDate) AS DurationHours,
    CASE 
        WHEN b.StartDate < GETDATE() THEN 'Completed'
        WHEN b.StartDate <= DATEADD(DAY, 7, GETDATE()) THEN 'Upcoming (7 days)'
        ELSE 'Future Booking'
    END AS BookingStatus
FROM 
    Bookings b
    INNER JOIN Events e ON b.EventID = e.EventID
    INNER JOIN Venues v ON b.VenueID = v.VenueID;
GO