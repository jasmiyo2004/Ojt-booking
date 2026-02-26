-- Check the most recent booking with all related data
DECLARE @BookingId SMALLINT;
SELECT TOP 1 @BookingId = BookingId FROM Booking ORDER BY BookingId DESC;

SELECT 
    'BOOKING INFO' AS Section,
    b.BookingId,
    b.BookingNo,
    b.VesselScheduleId,
    b.VesselId,
    b.EquipmentId,
    b.CommodityId,
    b.ContainerId,
    b.SealNumber,
    b.Weight,
    b.DeclaredValue,
    b.CargoDescription
FROM Booking b
WHERE b.BookingId = @BookingId;

SELECT 
    'VESSEL SCHEDULE' AS Section,
    vs.VesselScheduleId,
    vs.VesselId,
    v.VesselDesc AS VesselName,
    vs.OriginPortId,
    op.PortDesc AS OriginPort,
    vs.DestinationPortId,
    dp.PortDesc AS DestinationPort,
    vs.ETD,
    vs.ETA
FROM VesselSchedule vs
LEFT JOIN Vessel v ON vs.VesselId = v.VesselId
LEFT JOIN Port op ON vs.OriginPortId = op.PortId
LEFT JOIN Port dp ON vs.DestinationPortId = dp.PortId
WHERE vs.VesselScheduleId = (SELECT VesselScheduleId FROM Booking WHERE BookingId = @BookingId);

SELECT 
    'VESSEL' AS Section,
    v.VesselId,
    v.VesselDesc
FROM Vessel v
WHERE v.VesselId = (SELECT VesselId FROM Booking WHERE BookingId = @BookingId);

SELECT 
    'EQUIPMENT' AS Section,
    e.EquipmentId,
    e.EquipmentDesc
FROM Equipment e
WHERE e.EquipmentId = (SELECT EquipmentId FROM Booking WHERE BookingId = @BookingId);

SELECT 
    'COMMODITY' AS Section,
    c.CommodityId,
    c.CommodityDesc
FROM Commodity c
WHERE c.CommodityId = (SELECT CommodityId FROM Booking WHERE BookingId = @BookingId);

SELECT 
    'CONTAINER' AS Section,
    c.ContainerId,
    c.ContainerNo
FROM Container c
WHERE c.ContainerId = (SELECT ContainerId FROM Booking WHERE BookingId = @BookingId);

SELECT 
    'BOOKING PARTIES' AS Section,
    bp.BookingPartyId,
    bp.PartyTypeId,
    CASE 
        WHEN bp.PartyTypeId = 10 THEN 'Agreement Party'
        WHEN bp.PartyTypeId = 11 THEN 'Shipper Party'
        WHEN bp.PartyTypeId = 12 THEN 'Consignee Party'
    END AS PartyType,
    bp.CustomerId,
    c.CustomerCd,
    ci.FirstName,
    ci.MiddleName,
    ci.LastName
FROM BookingParty bp
LEFT JOIN Customer c ON bp.CustomerId = c.CustomerId
LEFT JOIN CustomerInformation ci ON c.CustomerId = ci.CustomerId
WHERE bp.BookingId = @BookingId
ORDER BY bp.PartyTypeId;
