CREATE DATABASE PortfolioOfEvidencePOneDB;

USE PortfolioOfEvidencePOneDB;

-- ====================================
-- 1. CREATE TABLES
-- ====================================

-- Table: Venues
CREATE TABLE Venues (
    VenueID INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(100) NOT NULL,
    Location NVARCHAR(200) NOT NULL,
    Capacity INT NOT NULL,
    ImageURL NVARCHAR(255)
);

-- Table: Events
CREATE TABLE Events (
    EventID INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(100) NOT NULL,
    StartDate DATE NOT NULL,
    EndDate DATE NOT NULL,
    Notes NVARCHAR(500)
);

-- Table: Bookings
CREATE TABLE Bookings (
    BookingID INT PRIMARY KEY IDENTITY(1,1),
    VenueID INT NOT NULL,
    EventID INT NOT NULL UNIQUE,
    StartDate DATETIME NOT NULL,
    EndDate DATETIME NOT NULL,
    CONSTRAINT FK_Bookings_Venue FOREIGN KEY (VenueID) REFERENCES Venues(VenueID),
    CONSTRAINT FK_Bookings_Event FOREIGN KEY (EventID) REFERENCES Events(EventID),
    CONSTRAINT CHK_Bookings_ValidDates CHECK (StartDate < EndDate)
);

-- ====================================
-- 2. INSERT SAMPLE DATA
-- ====================================

-- Insert Venues
INSERT INTO Venues (Name, Location, Capacity, ImageURL)
VALUES 
('Grand Hall', '123 City Center, Cape Town', 500, 'https://example.com/images/grandhall.jpg'),
('Beachside Pavilion', '77 Ocean Drive, Durban', 300, 'https://example.com/images/beachside.jpg'),
('Skyline Rooftop', '99 High Street, Johannesburg', 150, 'https://example.com/images/skyline.jpg');

-- Insert Events
INSERT INTO Events (Name, StartDate, EndDate, Notes)
VALUES 
('Corporate Year-End Function', '2025-06-20', '2025-06-20', 'Private corporate event for Acme Inc.'),
('Wedding Celebration', '2025-07-15', '2025-07-15', 'Couple wedding reception'),
('Product Launch Party', '2025-08-05', '2025-08-05', 'Launch event for new mobile device');

-- Insert Bookings
INSERT INTO Bookings (VenueID, EventID, StartDate, EndDate)
VALUES 
(1, 1, '2025-06-20 14:00:00', '2025-06-20 23:00:00'),
(2, 2, '2025-07-15 10:00:00', '2025-07-15 22:00:00'),
(3, 3, '2025-08-05 18:00:00', '2025-08-05 23:00:00');

-- ====================================
-- 3. MODIFY FK CONSTRAINTS
-- ====================================

-- Modify the Booking table FK constraints:
ALTER TABLE Bookings
DROP CONSTRAINT FK_Bookings_Venue;

ALTER TABLE Bookings
ADD CONSTRAINT FK_Bookings_Venue
    FOREIGN KEY (VenueID) REFERENCES Venues(VenueID)
    ON DELETE NO ACTION -- Prevent deletion of a venue in use
    ON UPDATE CASCADE;

ALTER TABLE Bookings
DROP CONSTRAINT FK_Bookings_Event;

ALTER TABLE Bookings
ADD CONSTRAINT FK_Bookings_Event
    FOREIGN KEY (EventID) REFERENCES Events(EventID)
    ON DELETE NO ACTION -- Prevent deletion of an event in use
    ON UPDATE CASCADE;

-- ====================================
-- 4. CREATING THE STORED PROCEDURE
-- ====================================

-- Creating the Stored Procedure for the view: (vw_BookingManagement)

USE PortfolioOfEvidencePOneDB;
GO

CREATE OR ALTER PROCEDURE sp_SearchBookings
    @SearchTerm NVARCHAR(100) = NULL,
    @BookingID INT = NULL,
    @EventName NVARCHAR(100) = NULL,
    @DateFrom DATETIME = NULL,
    @DateTo DATETIME = NULL
AS
BEGIN
    SELECT * FROM vw_BookingManagement
    WHERE 
        (@SearchTerm IS NULL OR 
         EventName LIKE '%' + @SearchTerm + '%' OR 
         VenueName LIKE '%' + @SearchTerm + '%')
        AND (@BookingID IS NULL OR BookingID = @BookingID)
        AND (@EventName IS NULL OR EventName LIKE '%' + @EventName + '%')
        AND (@DateFrom IS NULL OR BookingStart >= @DateFrom)
        AND (@DateTo IS NULL OR BookingEnd <= @DateTo)
    ORDER BY BookingStart DESC;
END
GO