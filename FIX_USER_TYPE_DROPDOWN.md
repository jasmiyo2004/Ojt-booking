# Fix: User Type Dropdown Empty

## Problem
The User Type dropdown shows no options (Admin/User) when creating a new user.

## Root Cause
The UserType table in the database is empty, so the API returns an empty array.

## Solution

### Step 1: Insert User Types into Database

Run this SQL script in SQL Server Management Studio:

```sql
-- Insert Admin user type
IF NOT EXISTS (SELECT 1 FROM dbo.UserType WHERE UserTypeCd = 'ADMIN')
BEGIN
    INSERT INTO dbo.UserType (UserTypeCd, UserTypeDesc, CreateUserId, CreateDttm, UpdateUserId, UpdateDttm)
    VALUES ('ADMIN', 'Admin', 'SYSTEM', GETDATE(), 'SYSTEM', GETDATE());
END

-- Insert User user type
IF NOT EXISTS (SELECT 1 FROM dbo.UserType WHERE UserTypeCd = 'USER')
BEGIN
    INSERT INTO dbo.UserType (UserTypeCd, UserTypeDesc, CreateUserId, CreateDttm, UpdateUserId, UpdateDttm)
    VALUES ('USER', 'User', 'SYSTEM', GETDATE(), 'SYSTEM', GETDATE());
END

-- Verify
SELECT * FROM dbo.UserType;
```

OR run the file: `INSERT_USER_TYPES_SIMPLE.sql`

### Step 2: Verify API Endpoint

Test the API endpoint in your browser or Postman:
```
http://localhost:5000/api/usertypes
```

Expected response:
```json
[
  {
    "userTypeId": 1,
    "userTypeCd": "ADMIN",
    "userTypeDesc": "Admin",
    "createUserId": "SYSTEM",
    "createDttm": "2026-02-25T...",
    "updateUserId": "SYSTEM",
    "updateDttm": "2026-02-25T..."
  },
  {
    "userTypeId": 2,
    "userTypeCd": "USER",
    "userTypeDesc": "User",
    "createUserId": "SYSTEM",
    "createDttm": "2026-02-25T...",
    "updateUserId": "SYSTEM",
    "updateDttm": "2026-02-25T..."
  }
]
```

### Step 3: Restart Flutter App

After inserting the data:
1. Stop the Flutter app (Ctrl+C)
2. Restart: `flutter run -d chrome`
3. Navigate to Settings → User Management → Add User
4. Check User Type dropdown - should now show Admin and User

### Step 4: Check Browser Console

If still not working:
1. Open browser console (F12)
2. Look for these messages:
   ```
   API Service: Fetching user types from http://localhost:5000/api/usertypes
   API Service: getUserTypes response status: 200
   API Service: Loaded 2 user types from API
   UserManagementPage: Loaded 2 user types
   ```

## Fallback: Mock Data

If the API is not working, the app will automatically use mock data:
- Admin (userTypeId: 1)
- User (userTypeId: 2)

You should see this in console:
```
API call failed (getUserTypes), falling back to mock data
```

## Verification Checklist

- [ ] UserType table has 2 records (Admin and User)
- [ ] API endpoint returns 200 status
- [ ] API returns array with 2 items
- [ ] Browser console shows "Loaded 2 user types"
- [ ] Dropdown shows "Admin" and "User" options

## Common Issues

### Issue 1: API returns empty array
**Cause:** UserType table is empty
**Fix:** Run INSERT_USER_TYPES_SIMPLE.sql

### Issue 2: API returns 404
**Cause:** UserTypesController not registered or API not running
**Fix:** 
1. Check API is running: `dotnet run` in booking_api folder
2. Verify endpoint: http://localhost:5000/api/usertypes

### Issue 3: API returns 500
**Cause:** Database connection issue
**Fix:** Check connection string in appsettings.json

### Issue 4: Dropdown still empty after inserting data
**Cause:** App cached old data
**Fix:** 
1. Hard refresh browser (Ctrl+Shift+R)
2. Or restart Flutter app

## Debug Commands

### Check UserType table:
```sql
SELECT * FROM dbo.UserType;
```

### Check table structure:
```sql
EXEC sp_help 'dbo.UserType';
```

### Count records:
```sql
SELECT COUNT(*) FROM dbo.UserType;
```

### Delete all and re-insert:
```sql
DELETE FROM dbo.UserType;

INSERT INTO dbo.UserType (UserTypeCd, UserTypeDesc, CreateUserId, CreateDttm, UpdateUserId, UpdateDttm)
VALUES 
    ('ADMIN', 'Admin', 'SYSTEM', GETDATE(), 'SYSTEM', GETDATE()),
    ('USER', 'User', 'SYSTEM', GETDATE(), 'SYSTEM', GETDATE());

SELECT * FROM dbo.UserType;
```

## Expected Result

After fix, the User Type dropdown should show:
- Admin
- User

And you should be able to select one to create a user.

## Files Updated

- `ojt_booking_web/lib/services/api_service.dart` - Added better logging and empty array handling
- `ojt_booking_web/lib/views/user_management_page.dart` - Added debug logging
- `INSERT_USER_TYPES_SIMPLE.sql` - Simple script to insert user types

## Next Steps

1. Run INSERT_USER_TYPES_SIMPLE.sql
2. Verify with: `SELECT * FROM dbo.UserType`
3. Test API: http://localhost:5000/api/usertypes
4. Restart Flutter app
5. Test dropdown in Add User form
