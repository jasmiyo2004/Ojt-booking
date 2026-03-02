-- This script needs to be run AFTER you know what the plain text passwords are
-- You'll need to generate BCrypt hashes for each password and update them

-- Example: If you know the passwords, you can update them one by one
-- The BCrypt hash for "password123" would be something like:
-- $2a$11$xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

-- For now, you can either:
-- 1. Reset all user passwords through the User Management interface (which will hash them)
-- 2. Or manually update each password hash in the database

-- To see current passwords (ONLY for migration purposes):
SELECT 
    u.UserId,
    ui.UserCode,
    ui.Email,
    uc.Password as CurrentPassword
FROM [User] u
INNER JOIN UserInformation ui ON u.UserInformationId = ui.UserInformationId
INNER JOIN UserCredential uc ON u.UserId = uc.UserId
WHERE ui.StatusId = 1;

-- After you have the BCrypt hashes, update like this:
-- UPDATE UserCredential 
-- SET Password = '$2a$11$[BCrypt_Hash_Here]'
-- WHERE UserId = [UserId];
