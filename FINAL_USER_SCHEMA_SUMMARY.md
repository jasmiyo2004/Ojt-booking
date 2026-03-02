# Final User Schema Summary (Based on Database Screenshots)

## Confirmed Database Schema

### [User] Table
- **UserId**: `smallint` (PRIMARY KEY)
- **UserTypeId**: `smallint` (FOREIGN KEY to UserType)
- **UserInformationId**: `smallint` (FOREIGN KEY to UserInformation)
- **Remarks**: `nvarchar(1000)`
- **CreateUserId**: `nvarchar(50)`
- **CreateDttm**: `datetime`
- **UpdateUserId**: `nvarchar(50)`
- **UpdateDttm**: `datetime`

### UserInformation Table
- **UserInformationId**: `smallint` (PRIMARY KEY)
- **FirstName**: `nvarchar(1000)`
- **MiddleName**: `nvarchar(1000)`
- **LastName**: `nvarchar(1000)`
- **Email**: `nvarchar(1000)`
- **Number**: `nvarchar(50)` (changed from int to nvarchar)
- **UserCode**: `nvarchar(50)`
- **StatusId**: `smallint`
- **CreateUserId**: `nvarchar(50)`
- **CreateDttm**: `datetime`
- **UpdateUserId**: `nvarchar(50)`
- **UpdateDttm**: `datetime`

### UserCredential Table
- **UserCredentialId**: `smallint` (PRIMARY KEY)
- **UserId**: `smallint` (FOREIGN KEY to User.UserId)
- **Password**: `nvarchar(1000)`
- **CreateUserId**: `nvarchar(50)`
- **CreateDttm**: `datetime`
- **UpdateUserId**: `nvarchar(50)`
- **UpdateDttm**: `datetime`

### UserType Table
- **UserTypeId**: `smallint` (PRIMARY KEY)
- **UserTypeCd**: `nvarchar(50)`
- **UserTypeDesc**: `nvarchar(1000)`
- **CreateUserId**: `nvarchar(50)`
- **CreateDttm**: `datetime`
- **UpdateUserId**: `nvarchar(50)`
- **UpdateDttm**: `datetime`

## C# Model Types (Should Match)

```csharp
// User.cs
public short UserId { get; set; }
public short? UserIdType { get; set; }  // Maps to UserTypeId column
public short? UserInformationId { get; set; }

// UserInformation.cs
public short UserInformationId { get; set; }
public string? Number { get; set; }  // nvarchar(50)
public short? StatusId { get; set; }

// UserCredential.cs
public short UserCredentialId { get; set; }
public short? UserId { get; set; }  // MUST match User.UserId (smallint)

// UserType.cs
public short UserTypeId { get; set; }
```

## Key Points

1. **ALL ID columns are `smallint` (short in C#)**
2. **Number is `nvarchar(50)` (string in C#)** - changed to support long phone numbers
3. **UserCredential.UserId MUST be `short`** to match User.UserId
4. **All foreign keys must match their referenced primary key types**

## Login Flow

1. User enters UserCode or Email + Password + Role selection
2. API finds UserInformation by UserCode or Email
3. API finds User by UserInformationId
4. API validates User.UserIdType matches selected role
5. API finds UserCredential by User.UserId
6. API validates password
7. Return user data if all checks pass
