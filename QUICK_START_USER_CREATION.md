# Quick Start: User Creation Testing

## Prerequisites Check ✓

### 1. Database Setup
Run these SQL queries in SQL Server Management Studio:

```sql
-- Check Status table (StatusId = 1 should be Active)
SELECT * FROM dbo.Status WHERE StatusId = 1;

-- Check UserType table (should have Admin and User)
SELECT * FROM dbo.UserType;
```

If UserType is empty, run: `INSERT_USER_TYPES.sql`

### 2. API Running
```bash
cd booking_api
dotnet run
```
Should see: `Now listening on: http://localhost:5000`

### 3. Flutter App Running
```bash
cd ojt_booking_web
flutter run -d chrome
```

## Test User Creation (5 Steps)

### Step 1: Navigate to User Management
- Open app in browser
- Click "Settings" tab (bottom navigation)
- Click "User Management" card

### Step 2: Click Add User
- Click yellow "Add User" button (bottom right)

### Step 3: Fill Form
```
First Name:    Test
Middle Name:   Middle
Last Name:     User
Email:         test@example.com
Number:        09123456789
Status:        (disabled - shows "Active")
User Type:     Select "Admin" or "User"
User Code:     TESTUSER01
Password:      password123
```

### Step 4: Submit
- Click "CREATE USER" button
- Should see: "User created successfully!" (green snackbar)
- User list refreshes automatically

### Step 5: Verify
Check in database:
```sql
SELECT TOP 1
    u.UserId,
    ut.UserTypeDesc,
    ui.FirstName + ' ' + ui.LastName AS Name,
    ui.Email,
    ui.UserCode,
    s.StatusDesc,
    uc.Password
FROM dbo.[User] u
INNER JOIN dbo.UserInformation ui ON u.UserInformationId = ui.UserInformationId
INNER JOIN dbo.UserType ut ON u.UserIdType = ut.UserTypeId
INNER JOIN dbo.Status s ON ui.StatusId = s.StatusId
LEFT JOIN dbo.UserCredential uc ON u.UserId = uc.UserId
ORDER BY u.CreateDttm DESC;
```

Expected: 1 row with all your test data

## Troubleshooting

### Error: "Failed to create user: 500"
**Fix:** Check StatusId = 1 exists in Status table
```sql
SELECT * FROM dbo.Status WHERE StatusId = 1;
```

### Error: "Please select user type"
**Fix:** Click the User Type dropdown and select Admin or User

### Error: "Please enter Password"
**Fix:** Type any password in the Password field

### User not showing in list
**Fix:** Check browser console (F12) for errors

### API not responding
**Fix:** 
1. Check API is running: `http://localhost:5000/api/users`
2. Check `appsettings.json` connection string
3. Restart API

## Success Indicators ✓

- ✅ Green success message appears
- ✅ User appears in list with correct name
- ✅ User card shows initials (TU)
- ✅ User type badge shows (Admin/User)
- ✅ Status badge shows "Active" in green
- ✅ Database has 3 new records (UserInformation, User, UserCredential)

## What Gets Created

When you create a user, 3 database records are inserted:

1. **UserInformation** - Personal info (name, email, phone, user code)
2. **User** - Links user type to user information
3. **UserCredential** - Stores password

All 3 are created in a transaction - if any fails, none are created.

## Field Mapping

| Form Field | Database Table | Column Name |
|------------|----------------|-------------|
| First Name | UserInformation | FirstName |
| Middle Name | UserInformation | MiddleName |
| Last Name | UserInformation | LastName |
| Email | UserInformation | Email |
| Number | UserInformation | Number |
| User Code | UserInformation | UserCode |
| Status | UserInformation | StatusId (1 = Active) |
| User Type | User | UserIdType |
| Password | UserCredential | Password |

## Next Actions

After successful test:
1. ✅ Test editing a user (click "Edit" button)
2. ✅ Test viewing user details (click "View" button)
3. ✅ Test activating/deactivating (click "Activate"/"Deactivate")
4. ✅ Create multiple users with different types
5. ✅ Test search functionality

## Important Notes

⚠️ **Password is plain text** - Not secure for production
⚠️ **No login system yet** - Authentication needs to be implemented
⚠️ **StatusId = 1 hardcoded** - Assumes Active status is ID 1

## Files to Reference

- `USER_CREATION_TEST_GUIDE.md` - Detailed testing guide
- `USER_CREATION_IMPLEMENTATION_SUMMARY.md` - Technical details
- `CHECK_USER_TABLES.sql` - Database verification queries
- `VERIFY_STATUS_TABLE.sql` - Status table check

---

**Ready to test!** Follow the 5 steps above to create your first user.
