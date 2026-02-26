-- =============================================
-- Insert User Types (Admin and User) - SIMPLE VERSION
-- Run this in your database
-- =============================================

-- Insert Admin user type if not exists
IF NOT EXISTS (SELECT 1 FROM dbo.UserType WHERE UserTypeCd = 'ADMIN')
BEGIN
    INSERT INTO dbo.UserType (UserTypeCd, UserTypeDesc, CreateUserId, CreateDttm, UpdateUserId, UpdateDttm)
    VALUES ('ADMIN', 'Admin', 'SYSTEM', GETDATE(), 'SYSTEM', GETDATE());
    PRINT 'Admin user type inserted!';
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
    PRINT 'User user type inserted!';
END
ELSE
BEGIN
    PRINT 'User user type already exists.';
END

-- Display all user types
SELECT 
    UserTypeId,
    UserTypeCd,
    UserTypeDesc,
    CreateUserId,
    CreateDttm
FROM dbo.UserType 
ORDER BY UserTypeId;

-- Verify count
SELECT COUNT(*) AS UserTypeCount FROM dbo.UserType;
