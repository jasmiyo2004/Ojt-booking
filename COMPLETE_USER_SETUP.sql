-- =============================================
-- COMPLETE USER SETUP SCRIPT
-- Run this to set up everything for user management
-- =============================================

PRINT '╔════════════════════════════════════════════════════════════╗';
PRINT '║         COMPLETE USER MANAGEMENT SETUP                     ║';
PRINT '╚════════════════════════════════════════════════════════════╝';
PRINT '';

-- ============================================
-- STEP 1: Fix Number Column Type
-- ============================================
PRINT '=== STEP 1: Fix Number Column Type ===';
PRINT 'Changing Number column from INT to NVARCHAR(50)...';

BEGIN TRY
    ALTER TABLE dbo.UserInformation
    ALTER COLUMN Number NVARCHAR(50) NULL;
    PRINT '✓ Number column type changed successfully!';
END TRY
BEGIN CATCH
    PRINT '✗ Error changing Number column: ' + ERROR_MESSAGE();
    PRINT '  (This is OK if already NVARCHAR)';
END CATCH

PRINT '';

-- ============================================
-- STEP 2: Insert User Types
-- ============================================
PRINT '=== STEP 2: Insert User Types ===';

-- Insert Admin type
IF NOT EXISTS (SELECT 1 FROM dbo.UserType WHERE UserTypeCd = 'ADMIN')
BEGIN
    SET IDENTITY_INSERT dbo.UserType ON;
    
    INSERT INTO dbo.UserType (UserTypeId, UserTypeCd, UserTypeDesc, CreateUserId, CreateDttm, UpdateUserId, UpdateDttm)
    VALUES (1, 'ADMIN', 'Admin', 'SYSTEM', GETDATE(), 'SYSTEM', GETDATE());
    
    SET IDENTITY_INSERT dbo.UserType OFF;
    PRINT '✓ Admin user type inserted';
END
ELSE
BEGIN
    PRINT '  Admin user type already exists';
END

-- Insert User type
IF NOT EXISTS (SELECT 1 FROM dbo.UserType WHERE UserTypeCd = 'USER')
BEGIN
    SET IDENTITY_INSERT dbo.UserType ON;
    
    INSERT INTO dbo.UserType (UserTypeId, UserTypeCd, UserTypeDesc, CreateUserId, CreateDttm, UpdateUserId, UpdateDttm)
    VALUES (2, 'USER', 'User', 'SYSTEM', GETDATE(), 'SYSTEM', GETDATE());
    
    SET IDENTITY_INSERT dbo.UserType OFF;
    PRINT '✓ User user type inserted';
END
ELSE
BEGIN
    PRINT '  User user type already exists';
END

PRINT '';

-- ============================================
-- STEP 3: Verify Status Table
-- ============================================
PRINT '=== STEP 3: Verify Status Table ===';

IF EXISTS (SELECT 1 FROM dbo.Status WHERE StatusId = 1)
BEGIN
    DECLARE @StatusDesc NVARCHAR(100);
    SELECT @StatusDesc = StatusDesc FROM dbo.Status WHERE StatusId = 1;
    PRINT '✓ Status table has StatusId = 1 (' + @StatusDesc + ')';
END
ELSE
BEGIN
    PRINT '✗ WARNING: Status table does not have StatusId = 1!';
    PRINT '  You may need to insert an Active status';
END

PRINT '';

-- ============================================
-- STEP 4: Clean Up Incomplete Users
-- ============================================
PRINT '=== STEP 4: Clean Up Incomplete Users ===';

-- Delete orphaned credentials
DELETE FROM dbo.UserCredential 
WHERE UserId NOT IN (SELECT UserId FROM dbo.[User]);
PRINT '  Cleaned up orphaned credentials';

-- Delete orphaned user information
DELETE FROM dbo.UserInformation 
WHERE UserInformationId NOT IN (
    SELECT UserInformationId FROM dbo.[User] 
    WHERE UserInformationId IS NOT NULL
);
PRINT '  Cleaned up orphaned user information';

-- Delete users with NULL UserInformationId
DELETE FROM dbo.[User] WHERE UserInformationId IS NULL;
PRINT '  Cleaned up incomplete users';

PRINT '';

-- ============================================
-- STEP 5: Create Initial Admin User
-- ============================================
PRINT '=== STEP 5: Create Initial Admin User ===';

-- Check if admin already exists
IF EXISTS (SELECT 1 FROM dbo.UserInformation WHERE UserCode = 'ADMIN001')
BEGIN
    PRINT '  Admin user (ADMIN001) already exists';
    PRINT '  Skipping creation...';
END
ELSE
BEGIN
    BEGIN TRANSACTION;
    
    BEGIN TRY
        -- Get Admin UserTypeId
        DECLARE @AdminUserTypeId SMALLINT;
        SELECT @AdminUserTypeId = UserTypeId FROM dbo.UserType WHERE UserTypeCd = 'ADMIN';
        
        -- Insert UserInformation
        INSERT INTO dbo.UserInformation (
            FirstName, MiddleName, LastName, Email, Number, UserCode, StatusId,
            CreateUserId, CreateDttm, UpdateUserId, UpdateDttm
        )
        VALUES (
            'Admin', NULL, 'User', 'admin@gothong.com', '09123456789', 'ADMIN001', 1,
            'SYSTEM', GETDATE(), 'SYSTEM', GETDATE()
        );
        
        DECLARE @UserInformationId INT = SCOPE_IDENTITY();
        
        -- Insert User
        INSERT INTO dbo.[User] (
            UserIdType, UserInformationId, Remarks,
            CreateUserId, CreateDttm, UpdateUserId, UpdateDttm
        )
        VALUES (
            @AdminUserTypeId, @UserInformationId, 'Initial Admin User',
            'SYSTEM', GETDATE(), 'SYSTEM', GETDATE()
        );
        
        DECLARE @UserId INT = SCOPE_IDENTITY();
        
        -- Insert UserCredential
        INSERT INTO dbo.UserCredential (
            UserId, Password,
            CreateUserId, CreateDttm, UpdateUserId, UpdateDttm
        )
        VALUES (
            @UserId, 'admin123',
            'SYSTEM', GETDATE(), 'SYSTEM', GETDATE()
        );
        
        COMMIT TRANSACTION;
        
        PRINT '✓ Initial admin user created successfully!';
        PRINT '';
        PRINT '  Login Credentials:';
        PRINT '    User Code: ADMIN001';
        PRINT '    Password:  admin123';
        
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT '✗ Error creating admin user: ' + ERROR_MESSAGE();
    END CATCH
END

PRINT '';

-- ============================================
-- STEP 6: Verification
-- ============================================
PRINT '=== STEP 6: Verification ===';
PRINT '';

PRINT 'Table Record Counts:';
SELECT 'User' AS TableName, COUNT(*) AS RecordCount FROM dbo.[User]
UNION ALL
SELECT 'UserInformation', COUNT(*) FROM dbo.UserInformation
UNION ALL
SELECT 'UserCredential', COUNT(*) FROM dbo.UserCredential
UNION ALL
SELECT 'UserType', COUNT(*) FROM dbo.UserType;

PRINT '';
PRINT 'All Users:';
SELECT 
    u.UserId,
    ut.UserTypeDesc AS UserType,
    ui.FirstName + ' ' + ISNULL(ui.MiddleName + ' ', '') + ui.LastName AS FullName,
    ui.Email,
    ui.Number AS PhoneNumber,
    ui.UserCode,
    uc.Password
FROM dbo.[User] u
INNER JOIN dbo.UserInformation ui ON u.UserInformationId = ui.UserInformationId
INNER JOIN dbo.UserType ut ON u.UserIdType = ut.UserTypeId
INNER JOIN dbo.UserCredential uc ON u.UserId = uc.UserId
ORDER BY u.UserId;

PRINT '';
PRINT '╔════════════════════════════════════════════════════════════╗';
PRINT '║                    SETUP COMPLETE!                         ║';
PRINT '╚════════════════════════════════════════════════════════════╝';
PRINT '';
PRINT 'Next Steps:';
PRINT '1. Restart your API (dotnet run)';
PRINT '2. Open the app and go to Settings → User Management';
PRINT '3. You should see the admin user in the list';
PRINT '4. Try creating a new user to test the functionality';
PRINT '';
PRINT 'Default Admin Login:';
PRINT '  User Code: ADMIN001';
PRINT '  Password:  admin123';
