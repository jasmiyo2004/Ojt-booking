-- Check the most recent booking and its related data
SELECT TOP 1
    b.BookingId,
    b.BookingNo,
    b.ContainerId,
    b.SealNumber,
    c.ContainerNo,
    b.CreateDttm
FROM Booking b
LEFT JOIN Container c ON b.ContainerId = c.ContainerId
ORDER BY b.BookingId DESC;

-- Check BookingParty records for the most recent booking
SELECT TOP 1 @BookingId = BookingId FROM Booking ORDER BY BookingId DESC;

SELECT 
    bp.BookingPartyId,
    bp.BookingId,
    bp.PartyTypeId,
    bp.CustomerId,
    c.CustomerCd,
    ci.FirstName,
    ci.MiddleName,
    ci.LastName,
    CASE 
        WHEN bp.PartyTypeId = 10 THEN 'Agreement Party'
        WHEN bp.PartyTypeId = 11 THEN 'Shipper Party'
        WHEN bp.PartyTypeId = 12 THEN 'Consignee Party'
        ELSE 'Unknown'
    END AS PartyType
FROM BookingParty bp
LEFT JOIN Customer c ON bp.CustomerId = c.CustomerId
LEFT JOIN CustomerInformation ci ON c.CustomerId = ci.CustomerId
WHERE bp.BookingId = (SELECT TOP 1 BookingId FROM Booking ORDER BY BookingId DESC)
ORDER BY bp.PartyTypeId;
