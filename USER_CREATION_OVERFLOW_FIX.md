# User Creation Overflow Error Fix

## Error
```
Arithmetic overflow error converting expression to data type int
```

## Problem
After database alterations, there's a type mismatch causing overflow when creating users.

## Likely Causes

### 1. UserCredential.UserId Type Mismatch
The UserCredential table has `UserId` as `smallint`, but User.UserId is `int`. When User.UserId exceeds 32,767 (max smallint), it cannot be stored in UserCredential.

### 2. Number Field Type Issue
The Number field in UserInformation might have been changed from `bigint` to `int`, causing overflow for phone numbers like `123456788900`.

## Solution

Run the CHECK_USER_TABLES_CURRENT_SCHEMA.sql to see the current schema, then apply the appropriate fix below:

### Fix 1: If UserCredential.UserId is smallint
```sql
-- Change UserCredential.UserId from smallint to int to match User.UserId
ALTER TABLE UserCredential 
ALTER COLUMN UserId INT NULL;
```

### Fix 2: If Number is int instead of bigint
```sql
-- Change Number from int to bigint
ALTER TABLE UserInformation 
ALTER COLUMN Number BIGINT NULL;
```

### Fix 3: If UserInformationId is wrong type
```sql
-- Ensure UserInformationId is int in both tables
ALTER TABLE UserInformation 
ALTER COLUMN UserInformationId INT NOT NULL;

ALTER TABLE [User]
ALTER COLUMN UserInformationId INT NULL;
```

## Recommended Schema

Based on your database screenshots and requirements:

### [User] Table
- UserId: `int` (PRIMARY KEY)
- UserTypeId: `int`
- UserInformationId: `int`

### UserInformation Table
- UserInformationId: `int` (PRIMARY KEY)
- Number: `bigint` (to store phone numbers up to 19 digits)
- StatusId: `smallint`

### UserCredential Table
- UserCredentialId: `smallint` (PRIMARY KEY)
- UserId: `int` (FOREIGN KEY to User.UserId) - **MUST MATCH User.UserId type**

### UserType Table
- UserTypeId: `smallint` (PRIMARY KEY)

## Testing After Fix

1. Run the schema check SQL
2. Apply the necessary ALTER TABLE statements
3. Restart the API server
4. Try creating a user with a long phone number (e.g., 123456788900)
5. Verify data is saved in all three tables

## C# Model Types (Current)

```csharp
// User.cs
public int UserId { get; set; }
public short? UserIdType { get; set; }  // Maps to UserTypeId (smallint)
public int? UserInformationId { get; set; }

// UserInformation.cs
public int UserInformationId { get; set; }
public long? Number { get; set; }  // bigint
public short? StatusId { get; set; }  // smallint

// UserCredential.cs
public short UserCredentialId { get; set; }
public int? UserId { get; set; }  // Should match User.UserId (int)
```

## Important Note

The most likely issue is **UserCredential.UserId being smallint** when it should be `int` to match User.UserId. This causes overflow when User.UserId exceeds 32,767.
