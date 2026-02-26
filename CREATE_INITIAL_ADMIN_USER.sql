-- =============================================
-- Create Initial Admin User
-- This creates a complete admin user across all 3 tables
-- =============================================

-- Prerequisites check
PRINT '=== CHECKING PREREQUISITES ===';

-- Check if UserType table has Admin type
IF NOT EXISTS (SELECT 1 FROM dbo.UserType WHERE UserTypeCd = 'ADMIN')
BEGIN
    PRINT 'ERROR: UserType table does not have ADMIN type!';
    PRINT 'Please run INSERT_USER_TYPES_SIMPLE.sql first';
    RETURN;
END

-- Check if Status table has Active status
IF NOT EXISTS (SELECT 1 FROM dbo.Status WHERE StatusId = 1)
BEGIN
    PRINT 'ERROR: Status table does not have StatusId = 1!';
    PRINT 'Please check your Status table';
    RETURN;
END

PRINT 'Prerequisites OK!';
PRINT '';

-- Start transaction
BEGIN TRANSACTION;

BEGIN TRY
    PRINT '=== CREATING INITIAL ADMIN USER ===';
    
    -- Step 1: Insert UserInformation
    PRINT 'Step 1: Creating UserInformation...';
    INSERT INTO dbo.UserInformation (
        FirstName,
        MiddleName,
        LastName,
        Email,
        Number,
        UserCode,
        StatusId,
        CreateUserId,
        CreateDttm,
        UpdateUserId,
        UpdateDttm
    )
    VALUES (
        'Admin',                    -- FirstName
        NULL,                       -- MiddleName (optional)
        'User',                     -- LastName
        'admin@gothong.com',        -- Email
        '09123456789',              -- Number (phone)
        'ADMIN001',                 -- UserCode
        1,                          -- StatusId (1 = Active)
        'SYSTEM',                   -- CreateUserId
        GETDATE(),                  -- CreateDttm
        'SYSTEM',                   -- UpdateUserId
        GETDATE()                   -- UpdateDttm
    );
    
    DECLARE @UserInformationId INT = SCOPE_IDENTITY();
    PRINT 'UserInformation created with ID: ' + CAST(@UserInformationId AS VARCHAR);
    
    -- Step 2: Insert User
    PRINT 'Step 2: Creating User...';
    
    -- Get Admin UserTypeId
    DECLARE @AdminUserTypeId SMALLINT;
    SELECT @AdminUserTypeId = UserTypeId 
    FROM dbo.UserType 
    WHERE UserTypeCd = 'ADMIN';
    
    INSERT INTO dbo.[User] (
        UserIdType,
        UserInformationId,
        Remarks,
        CreateUserId,
        CreateDttm,
        UpdateUserId,
        UpdateDttm
    )
    VALUES (
        @AdminUserTypeId,           -- UserIdType (Admin)
        @UserInformationId,         -- UserInformationId (link to UserInformation)
        'Initial Admin User',       -- Remarks
        'SYSTEM',                   -- CreateUserId
        GETDATE(),                  -- CreateDttm
        'SYSTEM',                   -- UpdateUserId
        GETDATE()                   -- UpdateDttm
    );
    
    DECLARE @UserId INT = SCOPE_IDENTITY();
    PRINT 'User created with ID: ' + CAST(@UserId AS VARCHAR);
    
    -- Step 3: Insert UserCredential
    PRINT 'Step 3: Creating UserCredential...';
    INSERT INTO dbo.UserCredential (
        UserId,
        Password,
        CreateUserId,
        CreateDttm,
        UpdateUserId,
        UpdateDttm
    )
    VALUES (
        @UserId,                    -- UserId (link to User)
        'admin123',                 -- Password (plain text for now)
        'SYSTEM',                   -- CreateUserId
        GETDATE(),                  -- CreateDttm
        'SYSTEM',                   -- UpdateUserId
        GETDATE()                   -- UpdateDttm
    );
    
    DECLARE @UserCredentialId INT = SCOPE_IDENTITY();
    PRINT 'UserCredential created with ID: ' + CAST(@UserCredentialId AS VARCHAR);
    
    -- Commit transaction
    COMMIT TRANSACTION;
    
    PRINT '';
    PRINT '=== SUCCESS! ===';
    PRINT 'Initial admin user created successfully!';
    PRINT '';
    PRINT 'Login Credentials:';
    PRINT '  User Code: ADMIN001';
    PRINT '  Password:  admin123';
    PRINT '';
    
    -- Display the created user
    PRINT '=== CREATED USER DATA ===';
    SELECT 
        u.UserId,
        ut.UserTypeDesc AS UserType,
        ui.FirstName + ' ' + ISNULL(ui.MiddleName + ' ', '') + ui.LastName AS FullName,
        ui.Email,
        ui.Number AS PhoneNumber,
        ui.UserCode,
        s.StatusDesc AS Status,
        uc.Password,
        u.CreateDttm AS CreatedDate
    FROM dbo.[User] u
    INNER JOIN dbo.UserInformation ui ON u.UserInformationId = ui.UserInformationId
    INNER JOIN dbo.UserType ut ON u.UserIdType = ut.UserTypeId
    INNER JOIN dbo.Status s ON ui.StatusId = s.StatusId
    INNER JOIN dbo.UserCredential uc ON u.UserId = uc.UserId
    WHERE u.UserId = @UserId;
    
END TRY
BEGIN CATCH
    -- Rollback on error
    ROLLBACK TRANSACTION;
    
    PRINT '';
    PRINT '=== ERROR! ===';
    PRINT 'Failed to create admin user!';
    PRINT 'Error Message: ' + ERROR_MESSAGE();
    PRINT 'Error Line: ' + CAST(ERROR_LINE() AS VARCHAR);
    
END CATCH;

PRINT '';
PRINT '=== VERIFICATION ===';
PRINT 'Check all tables:';

SELECT 'User' AS TableName, COUNT(*) AS RecordCount FROM dbo.[User]
UNION ALL
SELECT 'UserInformation', COUNT(*) FROM dbo.UserInformation
UNION ALL
SELECT 'UserCredential', COUNT(*) FROM dbo.UserCredential
UNION ALL
SELECT 'UserType', COUNT(*) FROM dbo.UserType;
