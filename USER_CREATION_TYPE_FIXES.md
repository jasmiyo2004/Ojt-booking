# User Creation Type Fixes

## Problem
User creation was failing with error: "The relationship from 'User.UserType' to 'UserType' with foreign key properties {'UserIdType' : int?} cannot target the primary key {'UserTypeId' : short}"

## Root Cause
Entity Framework requires foreign key types to EXACTLY match the primary key types they reference.

## Database Schema (Actual from Screenshots)

### [User] Table
- UserId: `int`
- UserTypeId: `int` (column name in DB)
- UserInformationId: `int`

### UserInformation Table
- UserInformationId: `int`
- Number: `bigint`
- StatusId: `smallint`

### UserCredential Table
- UserCredentialId: `smallint`
- UserId: `smallint`

### UserType Table
- UserTypeId: `smallint` (PRIMARY KEY)

## The Critical Issue
The User table's UserTypeId column references UserType.UserTypeId. Since UserType.UserTypeId is `smallint` (short in C#), the foreign key MUST also be `short`, not `int`.

## Fixes Applied

### 1. User.cs
```csharp
public int UserId { get; set; }  // Matches DB: int
public short? UserIdType { get; set; }  // MUST be short to match UserType.UserTypeId
public int? UserInformationId { get; set; }  // Matches DB: int
```

### 2. UserInformation.cs
```csharp
public int UserInformationId { get; set; }  // Matches DB: int
public long? Number { get; set; }  // Matches DB: bigint
public short? StatusId { get; set; }  // Matches DB: smallint
```

### 3. UserCredential.cs
```csharp
public short UserCredentialId { get; set; }  // Matches DB: smallint
public int? UserId { get; set; }  // Should match User.UserId which is int
```

### 4. UsersController.cs
```csharp
// Method signatures use int for UserId
public async Task<ActionResult<object>> GetUser(int id)
public async Task<IActionResult> UpdateUser(int id, ...)
public async Task<IActionResult> DeleteUser(int id)

// Request classes
public class CreateUserRequest {
    public long? Number { get; set; }  // bigint
    public short? StatusId { get; set; }  // smallint
    public short? UserTypeId { get; set; }  // MUST be short to match UserType.UserTypeId
}

public class UpdateUserRequest {
    public long? Number { get; set; }  // bigint
    public short? StatusId { get; set; }  // smallint
    public short? UserTypeId { get; set; }  // MUST be short to match UserType.UserTypeId
}
```

### 5. user_management_page.dart (Flutter)
```dart
final userData = {
  'number': int.tryParse(_numberController.text) ?? 0,  // Convert string to int
  'statusId': 1,  // short
  'userTypeId': _selectedUserTypeId,  // short (1 or 2)
};
```

## Testing Steps

1. Stop the API server
2. Restart the API server (changes are compiled)
3. Try creating a new user from the Flutter app
4. Verify data is saved to all three tables:
   - UserInformation
   - [User]
   - UserCredential

## Database Schema Inconsistency Note

There's a potential issue: UserCredential.UserId is `smallint` but User.UserId is `int`. This means:
- If User.UserId exceeds 32,767, it cannot be stored in UserCredential.UserId
- This is a database design issue that should be addressed by your supervisor
- For now, the C# model uses `int?` for UserCredential.UserId to match User.UserId

