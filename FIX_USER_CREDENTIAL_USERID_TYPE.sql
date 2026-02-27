-- Fix UserCredential.UserId type mismatch
-- This is the most likely cause of the overflow error

-- First, check if there are any existing records that would be affected
SELECT 
    UserCredentialId,
    UserId,
    'Current Type: smallint, Target Type: int' AS Note
FROM UserCredential;

-- Change UserCredential.UserId from smallint to int to match User.UserId
-- This allows UserId values greater than 32,767
ALTER TABLE UserCredential 
ALTER COLUMN UserId INT NULL;

-- Verify the change
SELECT 
    c.name AS ColumnName,
    t.name AS DataType,
    c.max_length AS MaxLength,
    c.is_nullable AS IsNullable
FROM sys.columns c
INNER JOIN sys.types t ON c.user_type_id = t.user_type_id
WHERE c.object_id = OBJECT_ID('UserCredential')
AND c.name = 'UserId';

-- Expected result: DataType should now be 'int' instead of 'smallint'
