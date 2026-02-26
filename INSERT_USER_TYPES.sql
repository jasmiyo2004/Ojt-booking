-- =============================================
-- Insert User Types (Admin and User)
-- =============================================

USE [your_database_name];  -- Replace with your actual database name
GO

-- Check if UserType table exists
IF OBJECT_ID('dbo.UserType', 'U') IS NOT NULL
BEGIN
    -- Insert Admin user type if not exists
    IF NOT EXISTS (SELECT 1 FROM dbo.UserType WHERE UserTypeCd = 'ADMIN')
    BEGIN
        INSERT INTO dbo.UserType (UserTypeCd, UserTypeDesc, CreateUserId, CreateDttm, UpdateUserId, UpdateDttm)
        VALUES ('ADMIN', 'Admin', 'SYSTEM', GETDATE(), 'SYSTEM', GETDATE());
        PRINT 'Admin user type inserted successfully!';
    END
    ELSE
    BEGIN
        PRINT 'Admin user type already exists.';
    END

    -- Insert User user type if not exists
    IF NOT EXISTS (SELECT 1 FROM dbo.UserType WHERE UserTypeCd = 'USER')
    BEGIN
        INSERT INTO dbo.UserType (UserTypeCd, UserTypeDesc, CreateUserId, CreateDttm, UpdateUserId, UpdateDttm)
        VALUES ('USER', 'User', 'SYSTEM', GETDATE(), 'SYSTEM', GETDATE());
        PRINT 'User user type inserted successfully!';
    END
    ELSE
    BEGIN
        PRINT 'User user type already exists.';
    END

    -- Display all user types
    SELECT * FROM dbo.UserType ORDER BY UserTypeId;
END
ELSE
BEGIN
    PRINT 'ERROR: UserType table does not exist!';
END
GO
