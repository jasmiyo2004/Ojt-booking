-- =============================================
-- Test Booking Save and Verification
-- =============================================

PRINT '=== CHECKING BOOKING TABLE ===';
PRINT '';

-- Check if Booking table has any records
SELECT COUNT(*) AS TotalBookings FROM dbo.Booking;

-- Show all bookings
PRINT '';
PRINT '=== ALL BOOKINGS ===';
SELECT 
    BookingId,
    BookingNo,
    StatusId,
    OriginLocationId,
    DestinationLocationId,
    TransportServiceId,
    VesselId,
    VesselScheduleId,
    EquipmentId,
    CommodityId,
    Weight,
    DeclaredValue,
    CargoDescription,
    ContainerId,
    SealNumber,
    PaymentModeId,
    Trucker,
    PlateNumber,
    Driver,
    CreateUserId,
    CreateDttm
FROM dbo.Booking
ORDER BY CreateDttm DESC;

PRINT '';
PRINT '=== BOOKING WITH RELATED DATA ===';
-- Show bookings with related table data
SELECT 
    b.BookingId,
    b.BookingNo,
    s.StatusDesc AS Status,
    ol.LocationDesc AS OriginLocation,
    dl.LocationDesc AS DestinationLocation,
    ts.TransportServiceDesc AS TransportService,
    v.VesselName AS Vessel,
    e.EquipmentDesc AS Equipment,
    c.CommodityDesc AS Commodity,
    b.Weight,
    b.DeclaredValue,
    b.CargoDescription,
    cont.ContainerNo AS ContainerNumber,
    b.SealNumber,
    pm.PaymentModeDesc AS PaymentMode,
    b.Trucker,
    b.PlateNumber,
    b.Driver,
    b.CreateDttm AS CreatedDate
FROM dbo.Booking b
LEFT JOIN dbo.Status s ON b.StatusId = s.StatusId
LEFT JOIN dbo.Location ol ON b.OriginLocationId = ol.LocationId
LEFT JOIN dbo.Location dl ON b.DestinationLocationId = dl.LocationId
LEFT JOIN dbo.TransportService ts ON b.TransportServiceId = ts.TransportServiceId
LEFT JOIN dbo.Vessel v ON b.VesselId = v.VesselId
LEFT JOIN dbo.Equipment e ON b.EquipmentId = e.EquipmentId
LEFT JOIN dbo.Commodity c ON b.CommodityId = c.CommodityId
LEFT JOIN dbo.Container cont ON b.ContainerId = cont.ContainerId
LEFT JOIN dbo.PaymentMode pm ON b.PaymentModeId = pm.PaymentModeId
ORDER BY b.CreateDttm DESC;

PRINT '';
PRINT '=== CHECK FOR NULL VALUES ===';
-- Check which fields are NULL in bookings
SELECT 
    BookingId,
    CASE WHEN BookingNo IS NULL THEN 'NULL' ELSE 'OK' END AS BookingNo,
    CASE WHEN StatusId IS NULL THEN 'NULL' ELSE 'OK' END AS StatusId,
    CASE WHEN OriginLocationId IS NULL THEN 'NULL' ELSE 'OK' END AS OriginLocationId,
    CASE WHEN DestinationLocationId IS NULL THEN 'NULL' ELSE 'OK' END AS DestinationLocationId,
    CASE WHEN TransportServiceId IS NULL THEN 'NULL' ELSE 'OK' END AS TransportServiceId,
    CASE WHEN VesselId IS NULL THEN 'NULL' ELSE 'OK' END AS VesselId,
    CASE WHEN VesselScheduleId IS NULL THEN 'NULL' ELSE 'OK' END AS VesselScheduleId,
    CASE WHEN EquipmentId IS NULL THEN 'NULL' ELSE 'OK' END AS EquipmentId,
    CASE WHEN CommodityId IS NULL THEN 'NULL' ELSE 'OK' END AS CommodityId,
    CASE WHEN ContainerId IS NULL THEN 'NULL' ELSE 'OK' END AS ContainerId,
    CASE WHEN PaymentModeId IS NULL THEN 'NULL' ELSE 'OK' END AS PaymentModeId
FROM dbo.Booking
ORDER BY BookingId DESC;

PRINT '';
PRINT '=== SUMMARY ===';
PRINT 'Total Bookings: ';
SELECT COUNT(*) FROM dbo.Booking;

PRINT 'Bookings with Status: ';
SELECT COUNT(*) FROM dbo.Booking WHERE StatusId IS NOT NULL;

PRINT 'Bookings with Origin: ';
SELECT COUNT(*) FROM dbo.Booking WHERE OriginLocationId IS NOT NULL;

PRINT 'Bookings with Destination: ';
SELECT COUNT(*) FROM dbo.Booking WHERE DestinationLocationId IS NOT NULL;

PRINT 'Bookings with Vessel: ';
SELECT COUNT(*) FROM dbo.Booking WHERE VesselId IS NOT NULL;
