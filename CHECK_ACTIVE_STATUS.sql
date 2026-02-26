-- =============================================
-- Check Active Status in Status Table
-- =============================================

USE [your_database_name];  -- Replace with your actual database name
GO

-- Display all statuses to find Active status
SELECT * FROM dbo.Status ORDER BY StatusId;
GO

-- If Active status doesn't exist, insert it
-- Uncomment the lines below if you need to insert Active status
/*
IF NOT EXISTS (SELECT 1 FROM dbo.Status WHERE StatusDesc = 'Active')
BEGIN
    INSERT INTO dbo.Status (StatusDesc, CreateUserId, CreateDttm, UpdateUserId, UpdateDttm)
    VALUES ('Active', 'SYSTEM', GETDATE(), 'SYSTEM', GETDATE());
    PRINT 'Active status inserted successfully!';
END
ELSE
BEGIN
    PRINT 'Active status already exists.';
END
GO
*/
