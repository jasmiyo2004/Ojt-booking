# Cancelled Bookings Sorting Implementation

## Overview
Updated the Transaction History page to sort cancelled bookings by CancelDttm (most recent first) with null values at the bottom.

## Changes Made

### 1. Backend (C#)

#### booking_api/Models/BookingDto.cs
- Added `CancelDttm` property to include cancellation timestamp in API responses

```csharp
public DateTime? CancelDttm { get; set; }
```

#### booking_api/Controllers/BookingsController.cs
- Updated GET bookings endpoint to include `CancelDttm` in DTO mapping
- Updated PUT bookings endpoint to include `CancelDttm` in DTO mapping

### 2. Frontend (Flutter)

#### ojt_booking_web/lib/models/booking_model.dart
- Added `cancelDttm` field to Booking model
- Updated constructor to accept `cancelDttm` parameter
- Updated `fromJson` to parse `cancelDttm` from API response

```dart
final DateTime? cancelDttm;

cancelDttm: json['cancelDttm'] != null
    ? DateTime.parse(json['cancelDttm'])
    : null,
```

#### ojt_booking_web/lib/views/history_page.dart
- Updated `filteredBookings` getter to sort cancelled bookings by `cancelDttm`
- Sorting logic:
  1. Bookings with `cancelDttm` are sorted by most recent first (descending)
  2. Bookings with null `cancelDttm` are placed at the bottom
  3. Other filters maintain original sorting

```dart
// Special sorting for Cancelled filter
if (_selectedFilter.toUpperCase() == 'CANCELLED') {
  filtered.sort((a, b) {
    // If both have cancelDttm, sort by most recent first
    if (a.cancelDttm != null && b.cancelDttm != null) {
      return b.cancelDttm!.compareTo(a.cancelDttm!);
    }
    // If only a has cancelDttm, a comes first
    if (a.cancelDttm != null && b.cancelDttm == null) {
      return -1;
    }
    // If only b has cancelDttm, b comes first
    if (a.cancelDttm == null && b.cancelDttm != null) {
      return 1;
    }
    // If both are null, maintain original order
    return 0;
  });
}
```

## Behavior

### When "Cancelled" filter is selected:
1. Bookings are filtered to show only cancelled bookings (StatusId = 5)
2. Bookings are sorted by CancelDttm:
   - Most recently cancelled bookings appear at the top
   - Older cancelled bookings appear below
   - Bookings with null CancelDttm (cancelled before this feature) appear at the bottom

### When other filters are selected:
- Original sorting is maintained (by CreateDttm descending)

## Example Sort Order

```
Cancelled Bookings List:
1. BKCEB100012 - Cancelled: 2026-02-27 09:45:04 (most recent)
2. BKCEB100011 - Cancelled: 2026-02-27 09:30:15
3. BKCEB100010 - Cancelled: 2026-02-27 08:15:22
4. BKCEB100009 - Cancelled: 2026-02-26 14:20:30
5. BKCEB100008 - Cancelled: NULL (old cancellation)
6. BKCEB100007 - Cancelled: NULL (old cancellation)
```

## Testing

1. Navigate to Transaction History page
2. Click on "Cancelled" filter
3. Verify that:
   - Only cancelled bookings are displayed
   - Most recently cancelled bookings appear at the top
   - Bookings with null CancelDttm appear at the bottom
4. Cancel a new booking and verify it appears at the top of the cancelled list
5. Switch to other filters (All, Booked, Completed) and verify normal sorting works

## Notes

- This sorting only applies to the "Cancelled" filter
- Bookings cancelled before the CancelDttm feature was implemented will have null values and appear at the bottom
- The sorting is case-insensitive (works with "Cancelled", "CANCELLED", "cancelled")
- Philippine time (UTC+8) is used for all timestamps
