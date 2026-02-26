-- =============================================
-- ALTER Number column from INT to NVARCHAR (String)
-- Run this in SQL Server Management Studio
-- =============================================

-- Step 1: Check current data type
PRINT '=== BEFORE CHANGE ===';
SELECT 
    c.name AS ColumnName,
    t.name AS DataType,
    c.max_length AS MaxLength,
    c.is_nullable AS IsNullable
FROM sys.columns c
INNER JOIN sys.types t ON c.user_type_id = t.user_type_id
WHERE c.object_id = OBJECT_ID('dbo.UserInformation')
    AND c.name = 'Number';

-- Step 2: ALTER the column to NVARCHAR(50)
PRINT '';
PRINT '=== CHANGING COLUMN TYPE ===';

ALTER TABLE dbo.UserInformation
ALTER COLUMN Number NVARCHAR(50) NULL;

PRINT 'Column type changed successfully!';

-- Step 3: Verify the change
PRINT '';
PRINT '=== AFTER CHANGE ===';
SELECT 
    c.name AS ColumnName,
    t.name AS DataType,
    c.max_length AS MaxLength,
    c.is_nullable AS IsNullable
FROM sys.columns c
INNER JOIN sys.types t ON c.user_type_id = t.user_type_id
WHERE c.object_id = OBJECT_ID('dbo.UserInformation')
    AND c.name = 'Number';

PRINT '';
PRINT '=== DONE! ===';
PRINT 'Number column is now NVARCHAR(50) and can store phone numbers as strings.';
PRINT 'You can now create users with phone numbers like: 09544782992';
