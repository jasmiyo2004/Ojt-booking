-- =============================================
-- Check User Relationships and Data
-- This will show if the tables are properly connected
-- =============================================

PRINT '=== 1. CHECK USER TABLE ===';
SELECT 
    UserId,
    UserIdType,
    UserInformationId,
    Remarks,
    CreateUserId,
    CreateDttm
FROM dbo.[User];

PRINT '';
PRINT '=== 2. CHECK USER CREDENTIAL TABLE ===';
SELECT 
    UserCredentialId,
    UserId,
    Password,
    CreateUserId,
    CreateDttm
FROM dbo.UserCredential;

PRINT '';
PRINT '=== 3. CHECK USER INFORMATION TABLE ===';
SELECT 
    UserInformationId,
    FirstName,
    MiddleName,
    LastName,
    Email,
    Number,
    UserCode,
    StatusId,
    CreateUserId,
    CreateDttm
FROM dbo.UserInformation;

PRINT '';
PRINT '=== 4. CHECK USER TYPE TABLE ===';
SELECT 
    UserTypeId,
    UserTypeCd,
    UserTypeDesc
FROM dbo.UserType;

PRINT '';
PRINT '=== 5. JOIN ALL TABLES TO SEE COMPLETE USER DATA ===';
SELECT 
    u.UserId,
    u.UserIdType,
    u.UserInformationId,
    ut.UserTypeDesc AS UserType,
    ui.FirstName,
    ui.MiddleName,
    ui.LastName,
    ui.Email,
    ui.Number,
    ui.UserCode,
    ui.StatusId,
    uc.Password,
    u.CreateDttm AS UserCreatedDate
FROM dbo.[User] u
LEFT JOIN dbo.UserInformation ui ON u.UserInformationId = ui.UserInformationId
LEFT JOIN dbo.UserType ut ON u.UserIdType = ut.UserTypeId
LEFT JOIN dbo.UserCredential uc ON u.UserId = uc.UserId
ORDER BY u.UserId;

PRINT '';
PRINT '=== 6. CHECK FOR ORPHANED RECORDS ===';

-- Check if User has UserInformationId but UserInformation doesn't exist
SELECT 
    u.UserId,
    u.UserInformationId AS 'User.UserInformationId',
    ui.UserInformationId AS 'UserInformation.UserInformationId',
    CASE 
        WHEN ui.UserInformationId IS NULL THEN 'MISSING UserInformation!'
        ELSE 'OK'
    END AS Status
FROM dbo.[User] u
LEFT JOIN dbo.UserInformation ui ON u.UserInformationId = ui.UserInformationId;

PRINT '';
PRINT '=== DIAGNOSIS ===';
PRINT 'If UserInformation table is empty but User table has data:';
PRINT '  - The transaction may have failed partway through';
PRINT '  - UserInformation insert failed but User insert succeeded';
PRINT '  - This means the data is INCOMPLETE and user creation failed';
PRINT '';
PRINT 'Expected behavior:';
PRINT '  - UserInformation should have 1 row';
PRINT '  - User should have 1 row with UserInformationId pointing to UserInformation';
PRINT '  - UserCredential should have 1 row with UserId pointing to User';
