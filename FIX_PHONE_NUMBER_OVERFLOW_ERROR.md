# Fix: Phone Number Overflow Error

## Error Message
```
The conversion of the nvarchar value '09544782992' overflowed an int column.
```

## Root Cause
The `Number` column in the `UserInformation` table is defined as `INT` type, but phone numbers:
- Can start with 0 (which gets lost in integers)
- Can exceed INT max value (2,147,483,647)
- Should be stored as text, not numbers

Phone number: `09544782992` = 9,544,782,992 (exceeds INT max)

## Solution: Change Column Type

### Step 1: Backup Database (IMPORTANT!)
Before making schema changes, backup your database:
```sql
BACKUP DATABASE [YourDatabaseName] 
TO DISK = 'C:\Backup\YourDatabase_Backup.bak'
WITH FORMAT, INIT, NAME = 'Before Number Column Change';
```

### Step 2: Check Current Column Type
```sql
SELECT 
    c.name AS ColumnName,
    t.name AS DataType,
    c.max_length AS MaxLength
FROM sys.columns c
INNER JOIN sys.types t ON c.user_type_id = t.user_type_id
WHERE c.object_id = OBJECT_ID('dbo.UserInformation')
    AND c.name = 'Number';
```

Expected result: `DataType = int`

### Step 3: Check for Existing Data
```sql
SELECT * FROM dbo.UserInformation;
```

If there's existing data with phone numbers stored as INT, they may have lost leading zeros.

### Step 4: Alter Column Type
Run this SQL command:

```sql
ALTER TABLE dbo.UserInformation
ALTER COLUMN Number NVARCHAR(50) NULL;
```

This changes the column from `INT` to `NVARCHAR(50)`, which can store:
- Phone numbers with leading zeros: "09544782992"
- International format: "+639544782992"
- Special characters: "(02) 1234-5678"
- Up to 50 characters

### Step 5: Verify the Change
```sql
SELECT 
    c.name AS ColumnName,
    t.name AS DataType,
    c.max_length AS MaxLength
FROM sys.columns c
INNER JOIN sys.types t ON c.user_type_id = t.user_type_id
WHERE c.object_id = OBJECT_ID('dbo.UserInformation')
    AND c.name = 'Number';
```

Expected result: `DataType = nvarchar`, `MaxLength = 100` (50 chars × 2 bytes)

### Step 6: Test User Creation
1. Restart the API (if running): Stop and run `dotnet run` again
2. Try creating a user with phone number: "09544782992"
3. Should succeed without errors

## Quick Fix Script

Run the file: `FIX_NUMBER_COLUMN_TYPE.sql`

OR copy-paste this:

```sql
-- Quick fix: Change Number column to NVARCHAR
ALTER TABLE dbo.UserInformation
ALTER COLUMN Number NVARCHAR(50) NULL;

-- Verify
SELECT 
    c.name AS ColumnName,
    t.name AS DataType
FROM sys.columns c
INNER JOIN sys.types t ON c.user_type_id = t.user_type_id
WHERE c.object_id = OBJECT_ID('dbo.UserInformation')
    AND c.name = 'Number';
```

## Why This Happened

The database schema was likely created with `Number` as `INT` type, but:
- The C# model has `Number` as `string?` (correct)
- The frontend sends phone numbers as strings (correct)
- The database column is INT (incorrect)

When Entity Framework tries to insert "09544782992" into an INT column:
1. It tries to convert the string to int
2. The number 9,544,782,992 exceeds INT max (2,147,483,647)
3. SQL Server throws overflow error

## Alternative: Use BIGINT (Not Recommended)

If you can't change to NVARCHAR, you could use BIGINT:

```sql
ALTER TABLE dbo.UserInformation
ALTER COLUMN Number BIGINT NULL;
```

But this has problems:
- ❌ Loses leading zeros: "09544782992" becomes 9544782992
- ❌ Can't store special characters: "+63", "()", "-"
- ❌ Can't store international format
- ✅ Can store large numbers

**Recommendation: Use NVARCHAR(50)**

## After Fixing

Once the column type is changed:

1. ✅ Phone numbers with leading zeros work
2. ✅ Long phone numbers work
3. ✅ International format works
4. ✅ Special characters work
5. ✅ User creation succeeds

## Test Cases

After fixing, test these phone numbers:

```
09544782992          ✅ Philippine mobile (starts with 0)
+639544782992        ✅ International format
(02) 1234-5678       ✅ Landline with formatting
09123456789          ✅ Standard mobile
639544782992         ✅ Without + prefix
```

All should work without errors.

## Verification Query

After creating a user, verify the data:

```sql
SELECT 
    UserInformationId,
    FirstName,
    LastName,
    Email,
    Number,
    UserCode
FROM dbo.UserInformation
ORDER BY CreateDttm DESC;
```

The `Number` column should show the phone number exactly as entered, including leading zeros.

## Files Created

- `FIX_NUMBER_COLUMN_TYPE.sql` - Script to change column type
- `CHECK_NUMBER_COLUMN_TYPE.sql` - Script to check current type
- `FIX_PHONE_NUMBER_OVERFLOW_ERROR.md` - This guide

## Summary

**Problem:** Number column is INT, phone numbers overflow
**Solution:** Change Number column to NVARCHAR(50)
**Command:** `ALTER TABLE dbo.UserInformation ALTER COLUMN Number NVARCHAR(50) NULL;`
**Result:** Phone numbers store correctly with leading zeros

Run the SQL command and try creating a user again!
