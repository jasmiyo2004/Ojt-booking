-- Check Status table for Active status ID
SELECT * FROM dbo.Status WHERE StatusDesc LIKE '%Active%';

-- Check UserType table
SELECT * FROM dbo.UserType;

-- Check existing users structure
SELECT TOP 5 
    u.UserId,
    u.UserIdType,
    u.UserInformationId,
    ut.UserTypeDesc,
    ui.FirstName,
    ui.MiddleName,
    ui.LastName,
    ui.Email,
    ui.Number,
    ui.UserCode,
    ui.StatusId,
    s.StatusDesc,
    uc.Password
FROM dbo.[User] u
LEFT JOIN dbo.UserType ut ON u.UserIdType = ut.UserTypeId
LEFT JOIN dbo.UserInformation ui ON u.UserInformationId = ui.UserInformationId
LEFT JOIN dbo.Status s ON ui.StatusId = s.StatusId
LEFT JOIN dbo.UserCredential uc ON u.UserId = uc.UserId
ORDER BY u.CreateDttm DESC;

-- Check table structures
EXEC sp_help 'dbo.User';
EXEC sp_help 'dbo.UserInformation';
EXEC sp_help 'dbo.UserCredential';
EXEC sp_help 'dbo.UserType';
