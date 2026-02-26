-- =============================================
-- Fix Number column type in UserInformation table
-- Change from INT to NVARCHAR to store phone numbers properly
-- =============================================

-- Step 1: Check current data type
SELECT 
    c.name AS ColumnName,
    t.name AS DataType,
    c.max_length AS MaxLength
FROM sys.columns c
INNER JOIN sys.types t ON c.user_type_id = t.user_type_id
WHERE c.object_id = OBJECT_ID('dbo.UserInformation')
    AND c.name = 'Number';

-- Step 2: Check if there's existing data
SELECT COUNT(*) AS RecordCount FROM dbo.UserInformation;

-- Step 3: Alter the column type
-- WARNING: This will fail if there's data that can't be converted
-- If you have existing data, you may need to backup first

ALTER TABLE dbo.UserInformation
ALTER COLUMN Number NVARCHAR(50) NULL;

PRINT 'Number column type changed to NVARCHAR(50)';

-- Step 4: Verify the change
SELECT 
    c.name AS ColumnName,
    t.name AS DataType,
    c.max_length AS MaxLength
FROM sys.columns c
INNER JOIN sys.types t ON c.user_type_id = t.user_type_id
WHERE c.object_id = OBJECT_ID('dbo.UserInformation')
    AND c.name = 'Number';

PRINT 'Column type change completed successfully!';
