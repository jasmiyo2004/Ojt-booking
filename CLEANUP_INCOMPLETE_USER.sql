-- =============================================
-- Cleanup Incomplete User Data
-- Run this to delete the incomplete user and start fresh
-- =============================================

PRINT '=== BEFORE CLEANUP ===';
PRINT 'User records:';
SELECT COUNT(*) AS UserCount FROM dbo.[User];
PRINT 'UserCredential records:';
SELECT COUNT(*) AS CredentialCount FROM dbo.UserCredential;
PRINT 'UserInformation records:';
SELECT COUNT(*) AS UserInfoCount FROM dbo.UserInformation;

PRINT '';
PRINT '=== DELETING INCOMPLETE USER DATA ===';

-- Delete in correct order (child tables first)
DELETE FROM dbo.UserCredential WHERE UserId = 1;
PRINT 'Deleted UserCredential for UserId = 1';

DELETE FROM dbo.[User] WHERE UserId = 1;
PRINT 'Deleted User with UserId = 1';

-- If there's orphaned UserInformation, delete it too
DELETE FROM dbo.UserInformation 
WHERE UserInformationId NOT IN (SELECT UserInformationId FROM dbo.[User] WHERE UserInformationId IS NOT NULL);
PRINT 'Deleted orphaned UserInformation records';

PRINT '';
PRINT '=== AFTER CLEANUP ===';
PRINT 'User records:';
SELECT COUNT(*) AS UserCount FROM dbo.[User];
PRINT 'UserCredential records:';
SELECT COUNT(*) AS CredentialCount FROM dbo.UserCredential;
PRINT 'UserInformation records:';
SELECT COUNT(*) AS UserInfoCount FROM dbo.UserInformation;

PRINT '';
PRINT '=== CLEANUP COMPLETE ===';
PRINT 'All incomplete user data has been removed.';
PRINT '';
PRINT 'NEXT STEPS:';
PRINT '1. Make sure you ran: ALTER_NUMBER_TO_STRING.sql';
PRINT '2. Make sure UserType table has Admin/User records';
PRINT '3. Try creating a user again in the app';
PRINT '4. Check that all 3 tables get populated';
