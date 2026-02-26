-- =============================================
-- Get Complete User Information by UserId
-- This shows how the tables are connected
-- =============================================

-- Example: Get all info for UserId = 1
DECLARE @UserId INT = 1;

PRINT '=== Getting User Information for UserId = ' + CAST(@UserId AS VARCHAR) + ' ===';
PRINT '';

-- Step 1: Get User record
PRINT '--- Step 1: User Table ---';
SELECT 
    UserId,
    UserIdType,
    UserInformationId,
    Remarks
FROM dbo.[User]
WHERE UserId = @UserId;

-- Step 2: Get UserType (using UserIdType from User table)
PRINT '';
PRINT '--- Step 2: UserType (via UserIdType) ---';
SELECT 
    ut.UserTypeId,
    ut.UserTypeCd,
    ut.UserTypeDesc
FROM dbo.[User] u
INNER JOIN dbo.UserType ut ON u.UserIdType = ut.UserTypeId
WHERE u.UserId = @UserId;

-- Step 3: Get UserInformation (using UserInformationId from User table)
PRINT '';
PRINT '--- Step 3: UserInformation (via UserInformationId) ---';
SELECT 
    ui.UserInformationId,
    ui.FirstName,
    ui.MiddleName,
    ui.LastName,
    ui.Email,
    ui.Number,
    ui.UserCode,
    ui.StatusId
FROM dbo.[User] u
INNER JOIN dbo.UserInformation ui ON u.UserInformationId = ui.UserInformationId
WHERE u.UserId = @UserId;

-- Step 4: Get UserCredential (using UserId)
PRINT '';
PRINT '--- Step 4: UserCredential (via UserId) ---';
SELECT 
    uc.UserCredentialId,
    uc.UserId,
    uc.Password
FROM dbo.UserCredential uc
WHERE uc.UserId = @UserId;

-- Step 5: Get EVERYTHING in one query (this is what the API does)
PRINT '';
PRINT '--- Step 5: COMPLETE USER DATA (All Tables Joined) ---';
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
LEFT JOIN dbo.UserInformation ui ON u.UserInformationId = ui.UserInformationId
LEFT JOIN dbo.UserType ut ON u.UserIdType = ut.UserTypeId
LEFT JOIN dbo.Status s ON ui.StatusId = s.StatusId
LEFT JOIN dbo.UserCredential uc ON u.UserId = uc.UserId
WHERE u.UserId = @UserId;

PRINT '';
PRINT '=== HOW THE TABLES ARE CONNECTED ===';
PRINT 'User.UserId = 1';
PRINT '  ├─> User.UserIdType ──> UserType.UserTypeId (to get "Admin" or "User")';
PRINT '  ├─> User.UserInformationId ──> UserInformation.UserInformationId (to get name, email, phone)';
PRINT '  └─> UserCredential.UserId ──> User.UserId (to get password)';
PRINT '';
PRINT 'To find user type for UserId=1:';
PRINT '  SELECT ut.UserTypeDesc FROM [User] u';
PRINT '  JOIN UserType ut ON u.UserIdType = ut.UserTypeId';
PRINT '  WHERE u.UserId = 1;';
PRINT '';
PRINT 'To find name for UserId=1:';
PRINT '  SELECT ui.FirstName, ui.LastName FROM [User] u';
PRINT '  JOIN UserInformation ui ON u.UserInformationId = ui.UserInformationId';
PRINT '  WHERE u.UserId = 1;';
