# Cancel Booking Implementation

## Overview
Implemented a three-step cancel booking flow with confirmation dialogs, remarks input, and success notification.

## Flow

### Step 1: Initial Confirmation Dialog
- Shows "CANCEL" title
- Message: "Are you sure you want to cancel this booking: {BOOKING_NUMBER}?"
- Buttons: YES (blue) and NO (gray)
- If NO is clicked, the flow stops

### Step 2: Remarks Input Dialog
- Shows "CONFIRM CANCEL" title
- Label: "Remarks:"
- Multi-line text field for entering cancellation remarks
- Buttons: CONFIRM (blue) and CANCEL (gray)
- If CANCEL is clicked, the flow stops
- Remarks are saved to the BKCancelRemarks column in the Booking table

### Step 3: Success Dialog
- Shows "CANCELLED BOOKING" title
- Message: "Booking Number: {BOOKING_NUMBER} was successfully cancelled."
- Button: OK (blue)
- After clicking OK, the transaction history automatically refreshes

## Files Modified

### Backend (C#)
1. **booking_api/Models/Booking.cs**
   - Added `BKCancelRemarks` property to store cancellation remarks
   - Added `CancelDttm` property to store cancellation date and time

2. **booking_api/Controllers/BookingsController.cs**
   - Updated `CancelBooking` method to save remarks to `BKCancelRemarks` field
   - Updated `CancelBooking` method to save current UTC timestamp to `CancelDttm` field
   - Remarks are passed in the request body

### Frontend (Flutter)
1. **ojt_booking_web/lib/widgets/confirm_dialog.dart**
   - Added `showCancelBooking()` static method for initial confirmation
   - Uses YES/NO buttons instead of CONFIRM/CANCEL

2. **ojt_booking_web/lib/widgets/remarks_dialog.dart** (NEW FILE)
   - Created new widget for remarks input
   - Multi-line text field for entering cancellation remarks
   - `showCancelRemarks()` static method returns the entered remarks or null

3. **ojt_booking_web/lib/widgets/success_dialog.dart**
   - Added `showCancelSuccess()` static method for cancel success notification
   - Displays "CANCELLED BOOKING" title with booking number

4. **ojt_booking_web/lib/services/api_service.dart**
   - Updated `cancelBooking()` method to accept optional `remarks` parameter
   - Sends remarks to the backend API

5. **ojt_booking_web/lib/views/history_page.dart**
   - Updated cancel button logic to implement the three-step flow
   - Added imports for all dialog widgets
   - Shows error dialog if cancellation fails
   - Automatically refreshes booking list after successful cancellation

## Dialog Styling
All dialogs follow a consistent design:
- Width: 500px
- Border radius: 4px
- Padding: 24px
- Title: 24px bold black text
- Message: 16px regular black text
- Buttons: Blue primary button, gray secondary button
- Button text: 16px bold uppercase

## API Endpoint
**POST** `/api/bookings/{id}/cancel`

Request body:
```json
{
  "UserId": "SYSTEM",
  "Remarks": "User entered remarks here"
}
```

Response: Returns the updated booking object with StatusId set to 5 (CANCELLED)

## Database Changes
- Added `BKCancelRemarks` column to Booking table (string/nvarchar) - Stores the cancellation remarks
- Added `CancelDttm` column to Booking table (DateTime) - Stores the date and time when booking was cancelled
- Both fields are automatically populated when a booking is successfully cancelled
- All timestamps (`CreateDttm`, `UpdateDttm`, `CancelDttm`) are saved in Philippine time (UTC+8)

## Testing
1. Navigate to Transaction History page
2. Click "Cancel" button on any booking
3. Verify initial confirmation dialog appears with YES/NO buttons
4. Click YES
5. Verify remarks input dialog appears
6. Enter remarks and click CONFIRM
7. Verify success dialog appears with booking number
8. Click OK
9. Verify booking list refreshes and booking status is updated to CANCELLED

## Error Handling
- If API call fails, shows error dialog with "CANCEL ERROR" title
- If user clicks NO or CANCEL at any step, the flow stops gracefully
- Network errors are caught and displayed to the user


## Philippine Time Implementation

All timestamps in the Booking table are automatically saved in Philippine time (UTC+8):

### Helper Method
```csharp
private DateTime GetPhilippineTime()
{
    return DateTime.UtcNow.AddHours(8);
}
```

### Timestamp Fields
- **CreateDttm**: Set to Philippine time when booking is created (never changes)
- **UpdateDttm**: Set to Philippine time when booking is created or updated
- **CancelDttm**: Set to Philippine time when booking is cancelled

This ensures all timestamps in the database match the local Philippine timezone without requiring timezone conversion in the application layer.
