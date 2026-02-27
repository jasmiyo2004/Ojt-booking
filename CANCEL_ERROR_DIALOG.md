# Cancel Error Dialog Implementation

## Overview
Added error handling to prevent users from cancelling a booking that is already cancelled. Shows a clear error dialog with the booking number.

## Changes Made

### 1. Error Dialog Widget
**File:** `ojt_booking_web/lib/widgets/error_dialog.dart`

Added new static method `showCancelError()`:

```dart
static void showCancelError(BuildContext context, {required String bookingNumber}) {
  show(
    context: context,
    title: 'CANCEL ERROR',
    message: 'Booking Number: $bookingNumber is already cancelled.',
  );
}
```

**Features:**
- Title: "CANCEL ERROR"
- Message: "Booking Number: {BOOKING_NUMBER} is already cancelled."
- OK button to dismiss
- Consistent styling with other error dialogs

### 2. History Page Validation
**File:** `ojt_booking_web/lib/views/history_page.dart`

Added validation check before showing cancel confirmation:

```dart
_buildActionButton(
  icon: Icons.cancel_rounded,
  label: 'Cancel',
  color: const Color(0xFFEF5350),
  onTap: () async {
    // Check if booking is already cancelled
    if (booking.status.toUpperCase() == 'CANCELLED') {
      ErrorDialog.showCancelError(
        context,
        bookingNumber: booking.referenceNumber,
      );
      return;
    }

    // Continue with normal cancel flow...
  },
),
```

## Flow

### Scenario 1: Cancelling an Active Booking (Normal Flow)
1. User clicks "Cancel" button on a BOOKED or COMPLETED booking
2. Initial confirmation dialog appears: "Are you sure you want to cancel this booking: {BOOKING_NUMBER}?"
3. User clicks "YES"
4. Remarks input dialog appears
5. User enters remarks and clicks "CONFIRM"
6. Booking is cancelled successfully
7. Success dialog appears

### Scenario 2: Attempting to Cancel an Already Cancelled Booking (Error Flow)
1. User clicks "Cancel" button on a CANCELLED booking
2. **Error dialog immediately appears**: "CANCEL ERROR - Booking Number: {BOOKING_NUMBER} is already cancelled."
3. User clicks "OK"
4. Dialog closes, no further action taken
5. Booking remains cancelled (no API call made)

## Error Dialog Design

### Visual Appearance
- **Width**: 500px
- **Border Radius**: 4px
- **Padding**: 24px
- **Title**: 
  - Text: "CANCEL ERROR"
  - Font Size: 24px
  - Font Weight: Bold
  - Color: Black
- **Message**: 
  - Text: "Booking Number: {BOOKING_NUMBER} is already cancelled."
  - Font Size: 16px
  - Color: Black (87% opacity)
- **Button**:
  - Text: "OK"
  - Background: Blue
  - Text Color: White
  - Font Size: 16px
  - Font Weight: 500
  - Padding: 32px horizontal, 12px vertical
  - Border Radius: 4px

## Benefits

1. **Prevents Duplicate Cancellations**: Users cannot accidentally cancel a booking twice
2. **Clear Error Message**: Shows exactly which booking is already cancelled
3. **Consistent UX**: Error dialog matches the style of other dialogs in the app
4. **No Unnecessary API Calls**: Validation happens before making API request
5. **User-Friendly**: Clear message helps users understand why the action failed

## Testing

1. **Test Normal Cancellation:**
   - Navigate to Transaction History
   - Click "Cancel" on a BOOKED booking
   - Verify normal cancel flow works (confirmation → remarks → success)

2. **Test Already Cancelled Error:**
   - Navigate to Transaction History
   - Click "Cancelled" filter
   - Click "Cancel" button on a cancelled booking
   - Verify error dialog appears with correct booking number
   - Click "OK" and verify dialog closes
   - Verify booking remains cancelled

3. **Test Error Dialog Styling:**
   - Trigger the cancel error
   - Verify dialog matches the design specifications
   - Verify "OK" button works correctly

4. **Test Case Sensitivity:**
   - Verify the check works regardless of status case (CANCELLED, Cancelled, cancelled)

## Code Location

- **Error Dialog Method**: `ojt_booking_web/lib/widgets/error_dialog.dart` (line ~95)
- **Validation Check**: `ojt_booking_web/lib/views/history_page.dart` (line ~415)

## Related Files

- `ojt_booking_web/lib/widgets/error_dialog.dart` - Error dialog widget
- `ojt_booking_web/lib/views/history_page.dart` - Transaction history page
- `ojt_booking_web/lib/widgets/confirm_dialog.dart` - Confirmation dialogs
- `ojt_booking_web/lib/widgets/success_dialog.dart` - Success dialogs

## Notes

- The validation is case-insensitive (uses `.toUpperCase()`)
- The error dialog is non-dismissible (must click OK)
- The check happens before any API calls, improving performance
- The error message includes the specific booking number for clarity
- This follows the same pattern as other error dialogs in the app
