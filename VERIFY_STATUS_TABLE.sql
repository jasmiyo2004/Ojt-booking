-- Verify Status table has Active status
-- This is critical for user creation to work

-- Check all statuses
SELECT 
    StatusId,
    StatusCd,
    StatusDesc,
    CreateUserId,
    CreateDttm
FROM dbo.Status
ORDER BY StatusId;

-- Check specifically for Active status
SELECT 
    StatusId,
    StatusDesc
FROM dbo.Status
WHERE StatusDesc LIKE '%Active%' OR StatusCd LIKE '%ACT%';

-- If Active status doesn't exist or has different ID, insert it
-- Uncomment and run if needed:
/*
IF NOT EXISTS (SELECT 1 FROM dbo.Status WHERE StatusId = 1)
BEGIN
    SET IDENTITY_INSERT dbo.Status ON;
    
    INSERT INTO dbo.Status (StatusId, StatusCd, StatusDesc, CreateUserId, CreateDttm, UpdateUserId, UpdateDttm)
    VALUES (1, 'ACT', 'Active', 'SYSTEM', GETDATE(), 'SYSTEM', GETDATE());
    
    SET IDENTITY_INSERT dbo.Status OFF;
END
*/

-- Verify UserType table has Admin and User types
SELECT 
    UserTypeId,
    UserTypeCd,
    UserTypeDesc,
    CreateUserId,
    CreateDttm
FROM dbo.UserType
ORDER BY UserTypeId;
