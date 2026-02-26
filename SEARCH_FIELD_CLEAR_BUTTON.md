# Search Field Clear Button Implementation

## Overview
Added dynamic button behavior to all search/modal fields in the booking form. Fields now show:
- **Search icon** (gold) when empty
- **Remove/Clear icon** (red) when filled

## Visual Behavior

### Empty State
```
┌─────────────────────────────────────┐
│ 🔍 Origin                           │
│    Select Origin              [🔍]  │
└─────────────────────────────────────┘
```
- Shows gold search icon
- Placeholder text in gray
- Clicking opens the selection modal

### Filled State
```
┌─────────────────────────────────────┐
│ 🔍 Origin                           │
│    CEBU PORT (VISCEB)         [✕]  │
└─────────────────────────────────────┘
```
- Shows red close/remove icon
- Selected value in bold black
- Clicking the X clears the field
- Clicking the field opens the selection modal

## Implementation Details

### Updated Widget Signature
**File**: `ojt_booking_web/lib/views/booking_page.dart`

```dart
Widget _buildSearchField({
  required String label,
  required String value,
  required IconData icon,
  required VoidCallback onTap,
  VoidCallback? onClear,  // NEW: Optional clear callback
})
```

### Logic
```dart
final hasContent = !isPlaceholder;

// Show remove button if has content AND onClear is provided
hasContent && onClear != null
  ? RemoveButton(onTap: onClear)
  : SearchButton()
```

## Fields Updated

All search/modal fields now have clear functionality:

### 1. Route Information
- **Origin**: Clears location, ID, type, and Mode of Service
- **Destination**: Clears location, ID, type, and Mode of Service

### 2. Vessel & Schedule
- **Vessel Name**: Clears vessel selection and ID
- **Vessel Schedule**: Clears date controller

### 3. Cargo Details
- **Equipment Type**: Clears equipment selection and ID
- **Commodity Name**: Clears commodity selection and ID

### 4. Parties
- **Agreement Party**: Resets to "Search Selection"
- **Shipper Party**: Resets to "Search Selection"
- **Consignee Party**: Resets to "Search Selection"

## Special Behavior

### Origin & Destination Clear
When either Origin or Destination is cleared:
```dart
onClear: () {
  setState(() {
    selectedOrigin = "Select Origin";
    selectedOriginId = null;
    selectedOriginType = null;
    // IMPORTANT: Also clears Mode of Service
    selectedService = null;
    selectedServiceId = null;
  });
}
```

This ensures Mode of Service is reset when locations change, since it's auto-calculated based on location types.

## User Experience

1. **Empty Field**
   - User sees gold search icon
   - Clicks anywhere on field → Opens selection modal
   
2. **Filled Field**
   - User sees red X icon
   - Clicks field body → Opens selection modal (can change selection)
   - Clicks X icon → Clears the field immediately
   
3. **Quick Reset**
   - No need to open modal to clear
   - One click on X removes the selection
   - Field returns to empty state

## Styling

### Search Icon (Empty)
- Color: Gold (#D4AF37)
- Background: Gold with 15% opacity
- Icon: `Icons.search_rounded`

### Remove Icon (Filled)
- Color: Red (#EF5350)
- Background: Red with 15% opacity
- Icon: `Icons.close_rounded`

Both icons are:
- Size: 18px
- Padding: 6px
- Border radius: 8px
- Clickable with InkWell ripple effect

## Code Example

```dart
_buildSearchField(
  label: 'Origin',
  value: selectedOrigin,
  icon: Icons.flight_takeoff_rounded,
  onTap: () {
    // Open location picker modal
    _controller.showLocationPicker(...);
  },
  onClear: () {
    // Clear the selection
    setState(() {
      selectedOrigin = "Select Origin";
      selectedOriginId = null;
      selectedOriginType = null;
      selectedService = null;
      selectedServiceId = null;
    });
  },
),
```

## Benefits

1. **Better UX**: Users can quickly clear fields without opening modals
2. **Visual Feedback**: Clear indication of field state (empty vs filled)
3. **Consistency**: All search fields behave the same way
4. **Efficiency**: Reduces clicks needed to reset form fields
5. **Intuitive**: Standard pattern users expect from modern forms
