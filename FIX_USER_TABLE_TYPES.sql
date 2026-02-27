-- Check current data types in User table
SELECT 
    c.name AS ColumnName,
    t.name AS DataType,
    c.max_length AS MaxLength,
    c.precision AS Precision,
    c.scale AS Scale
FROM sys.columns c
INNER JOIN sys.types t ON c.user_type_id = t.user_type_id
WHERE c.object_id = OBJECT_ID('[User]')
ORDER BY c.column_id;

-- If UserId is SMALLINT and needs to be INT, run this:
-- ALTER TABLE [User] ALTER COLUMN UserId INT NOT NULL;

-- If UserInformationId is SMALLINT and needs to be INT, run this:
-- ALTER TABLE [User] ALTER COLUMN UserInformationId INT NULL;
