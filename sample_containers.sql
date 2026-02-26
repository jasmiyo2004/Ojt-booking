-- Insert sample containers for testing
USE [ojt_2026_01]
GO

SET IDENTITY_INSERT [dbo].[Container] ON
GO

INSERT INTO [dbo].[Container] (
    [ContainerId],
    [ContainerNo],
    [ContainerType],
    [Status]
) VALUES
(1, 'GCNU1234567', '20FT', 'Available'),
(2, 'GCNU2345678', '40FT', 'Available'),
(3, 'GCNU3456789', '20FT', 'Available'),
(4, 'GCNU4567890', '40FT', 'Available'),
(5, 'GCNU5678901', '20FT', 'Available'),
(6, 'GCNU6789012', '40FT', 'Available'),
(7, 'GCNU7890123', '20FT', 'Available'),
(8, 'GCNU8901234', '40FT', 'Available'),
(9, 'GCNU9012345', '20FT', 'In Use'),
(10, 'GCNU0123456', '40FT', 'Available')

SET IDENTITY_INSERT [dbo].[Container] OFF
GO