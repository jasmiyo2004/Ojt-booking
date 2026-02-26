# Diagnosis: Empty UserInformation Table

## What I See in Your Screenshot

### User Table (Top) ✅
- Has 1 row
- UserId = 1
- UserIdType = (has a value)
- UserInformationId = (should have a value, but might be NULL)

### UserCredential Table (Middle) ✅
- Has 1 row
- UserCredentialId = 1
- UserId = 1 ← Connected to User table
- Password = "admin123"

### UserInformation Table (Bottom) ❌
- **EMPTY - No rows!**
- This is the problem!

### UserType Table (Not shown)
- Should have Admin/User types

## The Problem

When you created a user, the **UserInformation record was NOT created**. This means:

1. ❌ No FirstName, LastName, Email, Phone, UserCode saved
2. ✅ User record created (but UserInformationId is probably NULL)
3. ✅ UserCredential created (password saved)

## Why This Happened

The transaction likely failed at the UserInformation insert step, possibly due to:
1. The Number column being INT (overflow error we just fixed)
2. StatusId not existing in Status table
3. Some other constraint violation

## How to Check

Run this query:

```sql
-- Check if User has UserInformationId
SELECT 
    UserId,
    UserIdType,
    UserInformationId,
    CASE 
        WHEN UserInformationId IS NULL THEN 'PROBLEM: UserInformationId is NULL!'
        ELSE 'OK: UserInformationId = ' + CAST(UserInformationId AS VARCHAR)
    END AS Status
FROM dbo.[User]
WHERE UserId = 1;
```

Expected results:
- **If UserInformationId is NULL**: The UserInformation insert failed
- **If UserInformationId has a value**: Check if that ID exists in UserInformation table

## How Tables SHOULD Be Connected

```
User Table (UserId=1)
├─ UserIdType = 1 ──────────> UserType.UserTypeId = 1 (Admin)
├─ UserInformationId = 1 ───> UserInformation.UserInformationId = 1 (Name, Email, Phone)
└─ UserId = 1 <────────────── UserCredential.UserId = 1 (Password)
```

## To Find User Type for UserId=1

```sql
SELECT 
    u.UserId,
    ut.UserTypeDesc AS UserType
FROM dbo.[User] u
INNER JOIN dbo.UserType ut ON u.UserIdType = ut.UserTypeId
WHERE u.UserId = 1;
```

This will show: `UserId=1, UserType=Admin` (or User)

## To Find Name for UserId=1

```sql
SELECT 
    u.UserId,
    ui.FirstName,
    ui.MiddleName,
    ui.LastName,
    ui.Email,
    ui.Number
FROM dbo.[User] u
INNER JOIN dbo.UserInformation ui ON u.UserInformationId = ui.UserInformationId
WHERE u.UserId = 1;
```

**This will return NO ROWS if UserInformation is empty!**

## Solution

### Option 1: Delete Incomplete User and Try Again

```sql
-- Delete the incomplete user
DELETE FROM dbo.UserCredential WHERE UserId = 1;
DELETE FROM dbo.[User] WHERE UserId = 1;

-- Now try creating user again in the app
-- Make sure you've run: ALTER_NUMBER_TO_STRING.sql first!
```

### Option 2: Manually Complete the User Data

```sql
-- Insert missing UserInformation
INSERT INTO dbo.UserInformation (
    FirstName, MiddleName, LastName, Email, Number, UserCode, StatusId,
    CreateUserId, CreateDttm, UpdateUserId, UpdateDttm
)
VALUES (
    'Admin', NULL, 'User', 'admin@example.com', '09123456789', 'ADMIN001', 1,
    'SYSTEM', GETDATE(), 'SYSTEM', GETDATE()
);

-- Get the new UserInformationId
DECLARE @UserInformationId INT = SCOPE_IDENTITY();

-- Update User table to link to UserInformation
UPDATE dbo.[User]
SET UserInformationId = @UserInformationId
WHERE UserId = 1;

-- Verify
SELECT 
    u.UserId,
    ut.UserTypeDesc,
    ui.FirstName + ' ' + ui.LastName AS FullName,
    ui.Email,
    uc.Password
FROM dbo.[User] u
LEFT JOIN dbo.UserInformation ui ON u.UserInformationId = ui.UserInformationId
LEFT JOIN dbo.UserType ut ON u.UserIdType = ut.UserTypeId
LEFT JOIN dbo.UserCredential uc ON u.UserId = uc.UserId
WHERE u.UserId = 1;
```

## Recommended Steps

1. **Run CHECK_USER_RELATIONSHIPS.sql** to see current state
2. **Run ALTER_NUMBER_TO_STRING.sql** to fix the Number column
3. **Delete incomplete user** (Option 1 above)
4. **Try creating user again** in the app
5. **Run CHECK_USER_RELATIONSHIPS.sql** again to verify all 3 tables have data

## After Fix

When user creation works correctly, you should see:

### User Table
- UserId = 1
- UserIdType = 1 (or 2)
- UserInformationId = 1 ← Links to UserInformation

### UserCredential Table
- UserCredentialId = 1
- UserId = 1 ← Links to User
- Password = "admin123"

### UserInformation Table
- UserInformationId = 1 ← Linked from User
- FirstName = "Admin"
- LastName = "User"
- Email = "admin@example.com"
- Number = "09123456789"
- UserCode = "ADMIN001"
- StatusId = 1

### UserType Table
- UserTypeId = 1
- UserTypeDesc = "Admin"

All connected! ✅

## Files to Run

1. `CHECK_USER_RELATIONSHIPS.sql` - Diagnose current state
2. `GET_USER_BY_ID.sql` - See how to query connected data
3. `ALTER_NUMBER_TO_STRING.sql` - Fix Number column type
4. Delete incomplete user and try again
