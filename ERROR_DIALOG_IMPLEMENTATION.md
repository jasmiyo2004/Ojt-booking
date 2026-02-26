# Error Dialog Implementation

## Overview
Created a reusable error dialog widget for displaying validation errors in the booking form. The dialogs follow a consistent design pattern with red accent colors and clear messaging.

## File Structure

### New File Created
**File**: `ojt_booking_web/lib/widgets/error_dialog.dart`

A reusable widget class for displaying error dialogs throughout the application.

## Dialog Design

### Visual Elements

1. **Container**
   - White background
   - 20px border radius
   - 2px red border (#EF5350)
   - Max width: 400px
   - Min width: 300px
   - 24px padding

2. **Error Icon**
   - Red circular background (10% opacity)
   - Error outline icon (48px)
   - Red color (#EF5350)
   - 16px padding

3. **Title**
   - Font size: 22px
   - Bold weight
   - Dark color (#212121)
   - Letter spacing: 0.5
   - Center aligned

4. **Message**
   - Font size: 15px
   - Gray color (#757575)
   - Line height: 1.5
   - Center aligned

5. **OK Button**
   - Full width
   - Height: 50px
   - Red background (#EF5350)
   - White text
   - Bold font (16px)
   - Letter spacing: 1
   - 12px border radius
   - No elevation (flat design)

### Spacing
- Icon to Title: 20px
- Title to Message: 12px
- Message to Button: 24px

## Usage

### Generic Error Dialog
```dart
ErrorDialog.show(
  context: context,
  title: 'ERROR TITLE',
  message: 'Error message goes here.',
);
```

### Predefined Error Dialogs

#### 1. Origin Error
Shows when user tries to select an origin that matches the destination.

```dart
ErrorDialog.showOriginError(context);
```

**Display:**
- Title: "ORIGIN ERROR"
- Message: "Origin should not be the same with destination."

#### 2. Destination Error
Shows when user tries to select a destination that matches the origin.

```dart
ErrorDialog.showDestinationError(context);
```

**Display:**
- Title: "DESTINATION ERROR"
- Message: "Destination should not be the same with origin."

## Validation Logic

### Location Selection Validation

**File**: `ojt_booking_web/lib/views/booking_page.dart`

#### Origin Selection
```dart
onSelect: (locationDesc, locationId, locationTypeDesc) {
  // Check if origin is same as destination
  if (selectedDestinationId != null &&
      locationId == selectedDestinationId) {
    ErrorDialog.showOriginError(context);
    return; // Don't update state
  }
  
  // Update state if validation passes
  setState(() {
    selectedOrigin = locationDesc;
    selectedOriginId = locationId;
    selectedOriginType = locationTypeDesc;
  });
  _updateModeOfService();
}
```

#### Destination Selection
```dart
onSelect: (locationDesc, locationId, locationTypeDesc) {
  // Check if destination is same as origin
  if (selectedOriginId != null &&
      locationId == selectedOriginId) {
    ErrorDialog.showDestinationError(context);
    return; // Don't update state
  }
  
  // Update state if validation passes
  setState(() {
    selectedDestination = locationDesc;
    selectedDestinationId = locationId;
    selectedDestinationType = locationTypeDesc;
  });
  _updateModeOfService();
}
```

## Validation Flow

### Scenario 1: Origin Selection
1. User selects origin location
2. System checks if destination is already selected
3. If destination exists and matches selected origin:
   - Show "ORIGIN ERROR" dialog
   - Don't update origin field
   - User must select different location
4. If validation passes:
   - Update origin field
   - Update Mode of Service

### Scenario 2: Destination Selection
1. User selects destination location
2. System checks if origin is already selected
3. If origin exists and matches selected destination:
   - Show "DESTINATION ERROR" dialog
   - Don't update destination field
   - User must select different location
4. If validation passes:
   - Update destination field
   - Update Mode of Service

## User Experience

### Error Prevention
- Validation happens immediately on selection
- User sees error before field updates
- Clear error message explains the issue
- User must acknowledge error by clicking OK
- Field remains unchanged, allowing user to select again

### Dialog Behavior
- **Modal**: User must interact with dialog
- **Barrier Dismissible**: False (must click OK)
- **Single Action**: Only OK button
- **Auto-close**: Closes when OK is clicked
- **No Data Loss**: Original selection preserved

## Color Scheme

### Error Red
- **Primary**: #EF5350
- **Background**: #EF5350 with 10% opacity
- **Border**: #EF5350 with 2px width

### Text Colors
- **Title**: #212121 (dark gray)
- **Message**: #757575 (medium gray)
- **Button Text**: #FFFFFF (white)

## Extensibility

### Adding New Error Dialogs

To add a new error dialog:

1. Add a static method to `ErrorDialog` class:
```dart
static void showCustomError(BuildContext context) {
  show(
    context: context,
    title: 'CUSTOM ERROR',
    message: 'Your custom error message here.',
  );
}
```

2. Use in validation:
```dart
if (validationFails) {
  ErrorDialog.showCustomError(context);
  return;
}
```

## Testing Scenarios

### Test Case 1: Origin Same as Destination
1. Select "CEBU PORT" as destination
2. Try to select "CEBU PORT" as origin
3. Expected: "ORIGIN ERROR" dialog appears
4. Click OK
5. Origin field remains empty/unchanged

### Test Case 2: Destination Same as Origin
1. Select "MANILA PORT" as origin
2. Try to select "MANILA PORT" as destination
3. Expected: "DESTINATION ERROR" dialog appears
4. Click OK
5. Destination field remains empty/unchanged

### Test Case 3: Valid Selection
1. Select "CEBU PORT" as origin
2. Select "MANILA PORT" as destination
3. Expected: No error, both fields update
4. Mode of Service auto-fills

### Test Case 4: Changing Selection
1. Select "CEBU PORT" as origin
2. Select "MANILA PORT" as destination
3. Try to change destination to "CEBU PORT"
4. Expected: "DESTINATION ERROR" dialog appears
5. Destination remains "MANILA PORT"

## Benefits

1. **Consistent Design**: All error dialogs look the same
2. **Reusable**: Easy to add new error types
3. **User-Friendly**: Clear messaging and single action
4. **Validation**: Prevents invalid data entry
5. **Maintainable**: Centralized error dialog logic
6. **Accessible**: Large touch targets and clear text
7. **Professional**: Matches app design language

## Future Enhancements

Possible additions:
- Warning dialogs (yellow/orange theme)
- Success dialogs (green theme)
- Confirmation dialogs (with Yes/No buttons)
- Info dialogs (blue theme)
- Custom icons per dialog type
- Animation on dialog appearance
- Sound feedback (optional)
