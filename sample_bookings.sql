-- Insert sample bookings for testing
USE [ojt_2026_01]
GO

SET IDENTITY_INSERT [dbo].[Booking] ON
GO

INSERT INTO [dbo].[Booking] (
    [BookingId],
    [BookingNo],
    [StatusId],
    [TransportServiceId],
    [OriginLocationId],
    [DestinationLocationId],
    [VesselScheduleId],
    [CreateUserId],
    [CreateDttm],
    [UpdateUserId],
    [UpdateDttm]
) VALUES
(1, 'BK-2026-001', 4, 9, 4, 10, 1, 'SYSTEM', GETUTCDATE(), 'SYSTEM', GETUTCDATE()),
(2, 'BK-2026-002', 4, 10, 3, 4, 2, 'SYSTEM', GETUTCDATE(), 'SYSTEM', GETUTCDATE()),
(3, 'BK-2026-003', 3, 9, 5, 8, 3, 'SYSTEM', GETUTCDATE(), 'SYSTEM', GETUTCDATE()),
(4, 'BK-2026-004', 4, 11, 8, 3, 4, 'SYSTEM', GETUTCDATE(), 'SYSTEM', GETUTCDATE()),
(5, 'BK-2026-005', 4, 9, 4, 10, 1, 'SYSTEM', GETUTCDATE(), 'SYSTEM', GETUTCDATE())

SET IDENTITY_INSERT [dbo].[Booking] OFF
GO