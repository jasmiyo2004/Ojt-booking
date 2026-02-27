# Cancelled Booking View Updates

## Overview
Updated the Transaction History page to disable the Edit button for cancelled bookings and display cancellation information in the view modal.

## Changes Made

### 1. Backend (C#)

#### booking_api/Models/BookingDto.cs
- Added `BKCancelRemarks` property to include cancellation remarks in API responses

```csharp
public string? BKCancelRemarks { get; set; }
```

#### booking_api/Controllers/BookingsController.cs
- Updated GET bookings endpoint to include `BKCancelRemarks` in DTO mapping
- Updated PUT bookings endpoint to include `BKCancelRemarks` in DTO mapping

### 2. Frontend (Flutter)

#### ojt_booking_web/lib/models/booking_model.dart
- Added `cancelRemarks` field to Booking model
- Updated constructor to accept `cancelRemarks` parameter
- Updated `fromJson` to parse `bkCancelRemarks` from API response

```dart
final String? cancelRemarks;

cancelRemarks: json['bkCancelRemarks'],
```

#### ojt_booking_web/lib/views/history_page.dart

**1. Disabled Edit Button for Cancelled Bookings:**
- Edit button is hidden for cancelled bookings
- Replaced with a disabled (grey) Edit button that does nothing
- Uses conditional rendering based on booking status

```dart
// Disable Edit button for cancelled bookings
if (booking.status.toUpperCase() != 'CANCELLED')
  _buildActionButton(
    icon: Icons.edit_rounded,
    label: 'Edit',
    color: const Color(0xFFFF9800),
    onTap: () { /* Navigate to edit */ },
  )
else
  _buildActionButton(
    icon: Icons.edit_rounded,
    label: 'Edit',
    color: Colors.grey,
    onTap: () {}, // Disabled - no action
  ),
```

**2. Added Cancellation Information to View Modal:**
- Displays a red-bordered alert box at the top of the modal for cancelled bookings
- Shows "Cancelled Booking" label with cancel icon
- Displays "Cancellation Remark:" label followed by the remarks text
- Only shows if booking status is CANCELLED
- Only displays remarks section if remarks exist and are not empty

```dart
// Cancellation Information (if cancelled)
if (booking.status.toUpperCase() == 'CANCELLED') ...[
  Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFFEF5350).withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: const Color(0xFFEF5350),
        width: 2,
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.cancel_rounded,
              color: Color(0xFFEF5350),
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text(
              'Cancelled Booking',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFEF5350),
              ),
            ),
          ],
        ),
        if (booking.cancelRemarks != null &&
            booking.cancelRemarks!.isNotEmpty) ...[
          const SizedBox(height: 12),
          const Text(
            'Cancellation Remark:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF212121),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            booking.cancelRemarks!,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ],
      ],
    ),
  ),
  const SizedBox(height: 20),
],
```

## UI Behavior

### Edit Button
- **For Active Bookings (Booked, Completed):**
  - Edit button is orange and clickable
  - Navigates to booking page with pre-filled data
  
- **For Cancelled Bookings:**
  - Edit button is grey and disabled
  - Clicking does nothing
  - Visual indicator that editing is not allowed

### View Modal
- **For Active Bookings:**
  - Shows normal booking details
  - No cancellation information displayed

- **For Cancelled Bookings:**
  - Shows red alert box at the top with:
    - Cancel icon
    - "Cancelled Booking" label in red
    - "Cancellation Remark:" label (if remarks exist)
    - Remarks text (if remarks exist)
  - Followed by normal booking details below

## Visual Design

### Cancellation Alert Box
- Background: Light red (rgba(239, 83, 80, 0.1))
- Border: 2px solid red (#EF5350)
- Border radius: 12px
- Padding: 16px
- Icon: Red cancel icon (24px)
- Title: Bold red text (18px)
- Remark label: Bold black text (14px)
- Remark text: Grey text (14px)

## Testing

1. **Test Edit Button Disabled:**
   - Navigate to Transaction History
   - Click on "Cancelled" filter
   - Verify Edit button is grey for all cancelled bookings
   - Click Edit button and verify nothing happens

2. **Test View Modal with Cancellation Info:**
   - Click "View" on a cancelled booking
   - Verify red alert box appears at the top
   - Verify "Cancelled Booking" label is displayed
   - Verify "Cancellation Remark:" label is displayed
   - Verify remarks text is displayed
   - Verify normal booking details appear below

3. **Test View Modal without Remarks:**
   - Cancel a booking without entering remarks
   - Click "View" on that booking
   - Verify "Cancelled Booking" label appears
   - Verify "Cancellation Remark:" section does not appear

4. **Test Active Bookings:**
   - Click "View" on a non-cancelled booking
   - Verify no cancellation alert box appears
   - Verify Edit button is orange and clickable

## Notes
- The Edit button is conditionally rendered, not just disabled
- Cancellation information only appears for bookings with status "CANCELLED" (case-insensitive)
- Remarks section only displays if remarks exist and are not empty
- The cancellation alert box appears before all other booking details
- All styling matches the existing design system (colors, fonts, spacing)
