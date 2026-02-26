# Setup Initial Admin User

## Quick Start (One Script Does Everything!)

Run this single script in SQL Server Management Studio:

```
COMPLETE_USER_SETUP.sql
```

This script will:
1. ✅ Fix Number column type (INT → NVARCHAR)
2. ✅ Insert User Types (Admin, User)
3. ✅ Verify Status table
4. ✅ Clean up incomplete users
5. ✅ Create initial admin user
6. ✅ Verify everything is set up correctly

## What Gets Created

### Initial Admin User:
- **Name:** Admin User
- **Email:** admin@gothong.com
- **Phone:** 09123456789
- **User Code:** ADMIN001
- **Password:** admin123
- **Type:** Admin
- **Status:** Active

### Database Records:
- 1 record in `UserInformation` table
- 1 record in `User` table
- 1 record in `UserCredential` table
- 2 records in `UserType` table (Admin, User)

## Manual Step-by-Step (If Needed)

If you prefer to run scripts separately:

### Step 1: Fix Number Column
```sql
ALTER TABLE dbo.UserInformation
ALTER COLUMN Number NVARCHAR(50) NULL;
```
File: `ALTER_NUMBER_TO_STRING.sql`

### Step 2: Insert User Types
```sql
INSERT INTO dbo.UserType (UserTypeCd, UserTypeDesc, CreateUserId, CreateDttm, UpdateUserId, UpdateDttm)
VALUES 
    ('ADMIN', 'Admin', 'SYSTEM', GETDATE(), 'SYSTEM', GETDATE()),
    ('USER', 'User', 'SYSTEM', GETDATE(), 'SYSTEM', GETDATE());
```
File: `INSERT_USER_TYPES_SIMPLE.sql`

### Step 3: Create Admin User
File: `CREATE_INITIAL_ADMIN_USER.sql`

## Verification

After running the setup, verify with:

```sql
-- Check all users
SELECT 
    u.UserId,
    ut.UserTypeDesc AS UserType,
    ui.FirstName + ' ' + ui.LastName AS FullName,
    ui.Email,
    ui.UserCode,
    uc.Password
FROM dbo.[User] u
INNER JOIN dbo.UserInformation ui ON u.UserInformationId = ui.UserInformationId
INNER JOIN dbo.UserType ut ON u.UserIdType = ut.UserTypeId
INNER JOIN dbo.UserCredential uc ON u.UserId = uc.UserId;
```

Expected result:
```
UserId | UserType | FullName   | Email              | UserCode  | Password
-------|----------|------------|--------------------|-----------|---------
1      | Admin    | Admin User | admin@gothong.com  | ADMIN001  | admin123
```

## Test in Application

1. **Restart API:**
   ```bash
   cd booking_api
   dotnet run
   ```

2. **Open App:**
   - Navigate to Settings → User Management
   - You should see "Admin User" in the list
   - User type badge should show "Admin"
   - Status badge should show "Active"

3. **Test User Creation:**
   - Click "Add User" button
   - Fill in the form
   - User Type dropdown should show "Admin" and "User"
   - Create a test user
   - Verify it appears in the list

## Login Credentials

Once you implement authentication, use these credentials:

```
User Code: ADMIN001
Password:  admin123
```

⚠️ **Security Note:** Change the password after first login in production!

## Troubleshooting

### Issue: "User Type dropdown is empty"
**Solution:** Run `INSERT_USER_TYPES_SIMPLE.sql`

### Issue: "Number overflow error"
**Solution:** Run `ALTER_NUMBER_TO_STRING.sql`

### Issue: "Admin user already exists"
**Solution:** The script checks and skips if ADMIN001 exists

### Issue: "Status table error"
**Solution:** Verify Status table has StatusId = 1:
```sql
SELECT * FROM dbo.Status WHERE StatusId = 1;
```

## Files Reference

- `COMPLETE_USER_SETUP.sql` - **Run this one!** (does everything)
- `CREATE_INITIAL_ADMIN_USER.sql` - Creates admin user only
- `ALTER_NUMBER_TO_STRING.sql` - Fixes Number column
- `INSERT_USER_TYPES_SIMPLE.sql` - Inserts user types
- `CHECK_USER_RELATIONSHIPS.sql` - Verifies setup
- `CLEANUP_INCOMPLETE_USER.sql` - Cleans up bad data

## After Setup

You now have:
- ✅ Working user management system
- ✅ Initial admin user
- ✅ Ability to create new users
- ✅ User types (Admin/User)
- ✅ Proper database structure

Next steps:
1. Implement authentication/login
2. Add password hashing
3. Add role-based permissions
4. Change default admin password

## Summary

**Easiest way:** Run `COMPLETE_USER_SETUP.sql` - it does everything!

**Result:** You'll have a working admin user (ADMIN001/admin123) and can create more users through the app.
