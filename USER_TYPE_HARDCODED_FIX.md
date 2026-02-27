# User Type Dropdown - Hardcoded Values

## Change Summary

Updated the User Type dropdown in the user creation/edit form to use hardcoded values instead of fetching from the API.

## User Type Values

- **Admin** = UserTypeId: 1
- **Local** = UserTypeId: 2

## Changes Made

### ojt_booking_web/lib/views/user_management_page.dart

#### 1. Updated UserFormDialog Class
```dart
class UserFormDialog extends StatefulWidget {
  final User? user;
  final List<dynamic>? userTypes; // Made optional
  final Function(Map<String, dynamic>) onSave;

  const UserFormDialog({
    super.key,
    this.user,
    this.userTypes, // No longer required
    required this.onSave,
  });
}
```

#### 2. Hardcoded Dropdown Items
```dart
// 7. User Type (dropdown) - Hardcoded Admin and Local
DropdownButtonFormField<int>(
  value: _selectedUserTypeId,
  items: const [
    DropdownMenuItem<int>(
      value: 1,
      child: Text('Admin'),
    ),
    DropdownMenuItem<int>(
      value: 2,
      child: Text('Local'),
    ),
  ],
  onChanged: (value) => setState(() => _selectedUserTypeId = value),
  validator: (value) => value == null ? 'Please select user type' : null,
)
```

#### 3. Removed userTypes Parameter from Dialog Calls
```dart
// Add User Dialog
UserFormDialog(
  onSave: (userData) async { ... },
)

// Edit User Dialog
UserFormDialog(
  user: user,
  onSave: (userData) async { ... },
)
```

## Benefits

1. ✅ No dependency on UserType API endpoint
2. ✅ Simpler code - no need to fetch user types
3. ✅ Faster loading - no API call needed
4. ✅ More reliable - works even if API fails
5. ✅ Clear mapping: Admin=1, Local=2

## Database Mapping

When a user is created/updated:
- Selecting "Admin" sends `userTypeId: 1` to the API
- Selecting "Local" sends `userTypeId: 2` to the API
- The API saves this value to `[User].UserTypeId` column

## Testing

1. **Open User Management**:
   - Go to Settings → User Management

2. **Add New User**:
   - Click "+" button
   - Fill in all fields
   - User Type dropdown should show:
     - Admin
     - Local
   - Select "Admin" or "Local"
   - Click "CREATE USER"

3. **Verify in Database**:
   ```sql
   SELECT u.UserId, u.UserTypeId, ui.FirstName, ui.LastName
   FROM [User] u
   JOIN UserInformation ui ON u.UserInformationId = ui.UserInformationId
   ORDER BY u.UserId DESC;
   ```
   - Admin users should have UserTypeId = 1
   - Local users should have UserTypeId = 2

## Notes

- The UserType table in the database should have:
  - UserTypeId = 1, UserTypeDesc = 'Admin'
  - UserTypeId = 2, UserTypeDesc = 'Local'
- The hardcoded values match these database records
- No need to modify the backend API
- The API still accepts `userTypeId` as a short (Int16)
