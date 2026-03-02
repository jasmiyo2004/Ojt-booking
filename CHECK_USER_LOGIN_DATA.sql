-- Check the actual data types in the User tables
SELECT 
    c.TABLE_NAME,
    c.COLUMN_NAME,
    c.DATA_TYPE,
    c.CHARACTER_MAXIMUM_LENGTH,
    c.NUMERIC_PRECISION,
    c.NUMERIC_SCALE
FROM INFORMATION_SCHEMA.COLUMNS c
WHERE c.TABLE_NAME IN ('User', 'UserInformation', 'UserCredential', 'UserType', 'Status')
ORDER BY c.TABLE_NAME, c.ORDINAL_POSITION;

-- Check if there are any users in the database
SELECT 
    ui.UserInformationId,
    ui.UserCode,
    ui.Email,
    ui.StatusId,
    u.UserId,
    u.UserTypeId,
    uc.UserCredentialId,
    uc.Password
FROM UserInformation ui
LEFT JOIN [User] u ON u.UserInformationId = ui.UserInformationId
LEFT JOIN UserCredential uc ON uc.UserId = u.UserId
WHERE ui.UserCode = 'JGC' OR ui.Email = 'JGC';
