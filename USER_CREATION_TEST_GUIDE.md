# User Creation Test Guide

## Database Tables Structure

The user creation process involves 4 tables:

### 1. UserInformation Table
Stores personal and contact information:
- `UserInformationId` (PK, auto-increment)
- `FirstName`
- `MiddleName`
- `LastName`
- `Email`
- `Number`
- `UserCode`
- `StatusId` (FK to Status table)
- Audit fields: `CreateUserId`, `CreateDttm`, `UpdateUserId`, `UpdateDttm`

### 2. User Table
Links user type to user information:
- `UserId` (PK, auto-increment)
- `UserIdType` (FK to UserType table) - stores the user type (Admin/User)
- `UserInformationId` (FK to UserInformation table)
- `Remarks`
- Audit fields: `CreateUserId`, `CreateDttm`, `UpdateUserId`, `UpdateDttm`

### 3. UserCredential Table
Stores authentication credentials:
- `UserCredentialId` (PK, auto-increment)
- `UserId` (FK to User table)
- `Password` (plain text - TODO: implement hashing)
- Audit fields: `CreateUserId`, `CreateDttm`, `UpdateUserId`, `UpdateDttm`

### 4. UserType Table
Reference table for user types:
- `UserTypeId` (PK)
- `UserTypeCd` (code)
- `UserTypeDesc` (description: "Admin" or "User")
- Audit fields

## User Creation Flow

### Backend (C# API)
Location: `booking_api/Controllers/UsersController.cs`

**POST /api/users** endpoint creates user in 3 steps:

1. **Create UserInformation record**
   - Inserts FirstName, MiddleName, LastName, Email, Number, UserCode, StatusId
   - Returns UserInformationId

2. **Create User record**
   - Inserts UserIdType (user type), UserInformationId
   - Returns UserId

3. **Create UserCredential record**
   - Inserts UserId, Password
   - Returns UserCredentialId

All 3 operations are wrapped in a transaction - if any fails, all are rolled back.

### Frontend (Flutter)
Location: `ojt_booking_web/lib/views/user_management_page.dart`

**UserFormDialog** collects user input:

Field sequence (as requested):
1. First Name (required)
2. Middle Name (optional)
3. Last Name (required)
4. Email (required)
5. Number (required)
6. Status (disabled, automatically Active - StatusId = 1)
7. User Type (dropdown: Admin/User - required)
8. User Code (required)
9. Password (required for new users, optional for edits)

**Data sent to API:**
```json
{
  "firstName": "string",
  "middleName": "string or null",
  "lastName": "string",
  "email": "string",
  "number": "string",
  "userCode": "string",
  "statusId": 1,
  "userTypeId": number,
  "password": "string",
  "createUserId": "SYSTEM"
}
```

## Testing Steps

### Prerequisites
1. Ensure SQL Server is running
2. Ensure API is running (check `booking_api/Properties/launchSettings.json` for port)
3. Run the SQL script `CHECK_USER_TABLES.sql` to verify:
   - Status table has StatusId = 1 for "Active"
   - UserType table has records (should have been inserted via `INSERT_USER_TYPES.sql`)

### Test User Creation

1. **Navigate to User Management**
   - Open app
   - Go to Settings tab
   - Click "User Management" card

2. **Click "Add User" button** (floating action button)

3. **Fill in the form:**
   - First Name: "Test"
   - Middle Name: "Middle" (optional)
   - Last Name: "User"
   - Email: "test.user@example.com"
   - Number: "09123456789"
   - Status: (disabled, shows "Active")
   - User Type: Select "Admin" or "User"
   - User Code: "TESTUSER01"
   - Password: "password123"

4. **Click "CREATE USER"**

5. **Expected Results:**
   - Success snackbar: "User created successfully!"
   - User list refreshes
   - New user appears in the list
   - User card shows:
     - Initials (TU)
     - Full name (Test Middle User)
     - User code (TESTUSER01)
     - User type badge
     - Active status badge

### Verify in Database

Run this query to verify the user was created:

```sql
SELECT 
    u.UserId,
    u.UserIdType,
    ut.UserTypeDesc,
    ui.FirstName,
    ui.MiddleName,
    ui.LastName,
    ui.Email,
    ui.Number,
    ui.UserCode,
    s.StatusDesc,
    uc.Password
FROM dbo.[User] u
INNER JOIN dbo.UserInformation ui ON u.UserInformationId = ui.UserInformationId
INNER JOIN dbo.UserType ut ON u.UserIdType = ut.UserTypeId
INNER JOIN dbo.Status s ON ui.StatusId = s.StatusId
LEFT JOIN dbo.UserCredential uc ON u.UserId = uc.UserId
WHERE ui.UserCode = 'TESTUSER01';
```

Expected result:
- 1 row returned
- All fields populated correctly
- Password stored (plain text for now)

## Troubleshooting

### Error: "Failed to create user: 500"
**Possible causes:**
1. StatusId = 1 doesn't exist in Status table
   - Solution: Run `SELECT * FROM Status` to find correct Active status ID
   - Update `statusId: 1` in `user_management_page.dart` line 1186

2. UserType not found
   - Solution: Run `INSERT_USER_TYPES.sql` to insert user types
   - Verify with `SELECT * FROM UserType`

3. Database connection issue
   - Solution: Check `appsettings.json` connection string
   - Verify SQL Server is running

### Error: "Please enter Password"
**Cause:** Password field is required for new users

**Solution:** Enter a password (minimum 1 character)

### Error: "Please select user type"
**Cause:** User type dropdown not selected

**Solution:** Select either "Admin" or "User" from dropdown

### User created but not showing in list
**Cause:** List not refreshing

**Solution:** 
1. Check browser console for errors
2. Verify API is returning the new user in GET /api/users
3. Try navigating away and back to User Management

### Password not saving
**Cause:** Password field is empty or validation failing

**Solution:** 
1. Ensure password is entered
2. Check backend logs for errors
3. Verify UserCredential table has the record

## API Endpoints Used

### GET /api/users
Returns all users with joined data from UserInformation, UserType, and Status tables

### GET /api/usertypes
Returns all user types for the dropdown

### POST /api/users
Creates new user (UserInformation + User + UserCredential)

### PUT /api/users/{id}
Updates existing user

### DELETE /api/users/{id}
Deletes user (UserCredential + User + UserInformation)

## Important Notes

1. **StatusId = 1** is hardcoded as "Active" - verify this matches your Status table
2. **Password is plain text** - TODO: implement hashing before production
3. **Transaction handling** - All 3 table inserts are atomic (all succeed or all fail)
4. **Audit fields** - CreateUserId and UpdateUserId are set to "SYSTEM"
5. **Middle name is optional** - Can be null or empty string
6. **User type is required** - Must select from dropdown

## Next Steps

1. Test user creation with the steps above
2. Verify data in database
3. Test user editing
4. Test user activation/deactivation
5. Implement password hashing
6. Implement actual authentication/login system
