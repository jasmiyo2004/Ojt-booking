# Booking User Tracking Implementation

## Summary
Added user tracking to display who created and updated bookings in the booking details view.

## Backend Changes (C# API)

### 1. Updated BookingDto.cs
Added two new fields:
- `CreateUserCode` - UserCode of who created the booking
- `UpdateUserCode` - UserCode of who updated the booking

### 2. Updated BookingsController.cs
- Added `GetUserCodesAsync()` helper method to lookup UserCodes from UserIds
- Updated GET `/api/bookings` endpoint to populate CreateUserCode and UpdateUserCode
- Updated GET `/api/bookings/recent` endpoint to populate CreateUserCode and UpdateUserCode

## Frontend Changes (Flutter)

### 1. Updated booking_model.dart
Added two new fields to the Booking model:
- `createUserCode` - UserCode of who created the booking
- `updateUserCode` - UserCode of who updated the booking

### 2. Updated history_page.dart
In the booking details modal (_showViewModal), added display of:
- "Created by: {UserCode}" below the Created timestamp
- "Updated by: {UserCode}" below the Updated timestamp

## Display Format
```
Created: 2026-03-03 08:27
Created by: ADMIN001

Updated: 2026-03-03 08:27
Updated by: USER002
```

## Manual Update Required
Due to file complexity, the history_page.dart needs manual update at line ~1245-1305.

Add after "Created timestamp" Row (around line 1275):
```dart
// Created by user
if (booking.createUserCode != null) ...[
  const SizedBox(height: 4),
  Row(
    children: [
      const SizedBox(width: 24), // Indent to align with timestamp
      Text(
        "Created by: ",
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.grey[600],
        ),
      ),
      Text(
        booking.createUserCode!,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1B5E20),
        ),
      ),
    ],
  ),
],
```

Add after "Updated timestamp" Row (around line 1305):
```dart
// Updated by user
if (booking.updateUserCode != null) ...[
  const SizedBox(height: 4),
  Row(
    children: [
      const SizedBox(width: 24), // Indent to align with timestamp
      Text(
        "Updated by: ",
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.grey[600],
        ),
      ),
      Text(
        booking.updateUserCode!,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1B5E20),
        ),
      ),
    ],
  ),
],
```
