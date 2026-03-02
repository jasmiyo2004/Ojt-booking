# Booking Details Dialog - Timestamps Implementation

## Changes Made

### 1. Updated Booking Model (`ojt_booking_web/lib/models/booking_model.dart`)
- Added `updateDttm` field to store the last update timestamp
- Updated `fromJson` to parse `updateDttm` from API response
- Updated constructor to include the new field

### 2. Updated History Page (`ojt_booking_web/lib/views/history_page.dart`)
- Removed the "Close" button at the bottom of booking details dialog
- Added timestamps section showing:
  - **Created**: Always displayed with booking creation date/time
  - **Updated**: Only displayed if the booking has been updated (when `updateDttm` is not null)
- Format: `YYYY-MM-DD HH:MM` (24-hour format)
- Styled with icons and proper spacing

## UI Changes

### Before:
- Close button at bottom (redundant with X button in upper right)

### After:
- Created timestamp with clock icon
- Updated timestamp with update icon (conditional display)
- Clean, informative display at bottom of dialog

## Technical Details

- Timestamps are formatted in Philippine time (UTC+8)
- The X button in the upper right corner remains for closing the dialog
- Updated timestamp only appears when the booking has been modified
- Both timestamps use consistent formatting for readability
