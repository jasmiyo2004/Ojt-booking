# Auto Mode of Service Implementation

## Overview
The Mode of Service field is now automatically filled based on the LocationTypeDesc of the selected Origin and Destination locations.

## How It Works

### Example:
- **Origin**: Alcoy, CEBU SOUTH BOUND (LocationTypeDesc: "DOOR")
- **Destination**: BATANGAS PORT (LocationTypeDesc: "PIER")
- **Result**: Mode of Service automatically set to "DOOR/PIER"

### Another Example:
- **Origin**: CEBU PORT (LocationTypeDesc: "PIER")
- **Destination**: CAPAS TARLAC (LocationTypeDesc: "DOOR")
- **Result**: Mode of Service automatically set to "PIER/DOOR"

## Backend Changes

### 1. Created LocationType Model
**File**: `booking_api/Models/LocationType.cs`
- New model to represent the LocationType table
- Contains LocationTypeId and LocationTypeDesc fields

### 2. Updated Location Model
**File**: `booking_api/Models/Location.cs`
- Added navigation property to LocationType
- Establishes relationship between Location and LocationType

### 3. Updated ApplicationDbContext
**File**: `booking_api/Data/ApplicationDbContext.cs`
- Added LocationTypes DbSet
- Configured LocationType table mapping
- Added relationship configuration between Location and LocationType

### 4. Updated LocationsController
**File**: `booking_api/Controllers/LocationsController.cs`
- Modified GET endpoints to include LocationType data
- Uses `.Include(l => l.LocationType)` to load related data
- Returns LocationTypeDesc in the API response

## Frontend Changes

### 1. Updated Location Model
**File**: `ojt_booking_web/lib/models/location_model.dart`
- Added `locationTypeDesc` field (nullable String)
- Updated `fromJson` to parse LocationTypeDesc from API
- Updated `toJson` to include LocationTypeDesc

### 2. Updated API Service
**File**: `ojt_booking_web/lib/services/api_service.dart`
- Updated mock data to include LocationTypeDesc
- Added example locations with different types (PIER, DOOR)

### 3. Updated Booking Controller
**File**: `ojt_booking_web/lib/controllers/booking_controller.dart`
- Modified `showLocationPicker` callback signature
- Now passes LocationTypeDesc along with locationDesc and locationId
- Callback: `Function(String locationDesc, int locationId, String? locationTypeDesc)`

### 4. Updated Booking Page
**File**: `ojt_booking_web/lib/views/booking_page.dart`

#### Added State Variables:
```dart
String? selectedOriginType;      // Store origin location type
String? selectedDestinationType; // Store destination location type
```

#### Added Auto-Selection Method:
```dart
void _updateModeOfService() {
  if (selectedOriginType != null && selectedDestinationType != null) {
    final serviceName = '$selectedOriginType/$selectedDestinationType';
    // Finds matching transport service and auto-selects it
  }
}
```

#### Updated Location Pickers:
- Origin and Destination pickers now capture LocationTypeDesc
- Automatically call `_updateModeOfService()` after selection
- Mode of Service updates immediately when both locations are selected

#### Changed Mode of Service Field:
- Changed from dropdown to read-only display field
- Shows auto-filled value with green "auto" icon
- Displays placeholder text when not yet filled

## User Experience

1. User selects **Origin** location
   - System captures LocationTypeDesc (e.g., "PIER")

2. User selects **Destination** location
   - System captures LocationTypeDesc (e.g., "PIER")
   - System automatically determines Mode of Service: "DOOR/PIER"
   - Field updates immediately with green auto-fill indicator

3. Mode of Service field is **read-only**
   - Users cannot manually change it
   - Always reflects the combination of origin and destination types
   - Shows green sparkle icon to indicate auto-fill

## Transport Service Naming Convention

The system expects transport services to be named in the format:
- `PIER/PIER`
- `PIER/DOOR`
- `DOOR/PIER`
- `DOOR/DOOR`

The format is: `ORIGIN_TYPE/DESTINATION_TYPE` (using forward slash `/`)

The matching is case-insensitive.

## Database Requirements

Ensure your database has:
1. **LocationType** table with:
   - LocationTypeId (primary key)
   - LocationTypeDesc (e.g., "PIER", "DOOR")

2. **Location** table with:
   - LocationTypeId (foreign key to LocationType)

3. **TransportService** table with services named according to the convention above

## Testing

Test with these scenarios:
1. PIER → PIER (e.g., CEBU PORT → MANILA PORT) = "PIER/PIER"
2. PIER → DOOR (e.g., CEBU PORT → CAPAS TARLAC) = "PIER/DOOR"
3. DOOR → PIER (e.g., Alcoy CEBU SOUTH BOUND → BATANGAS PORT) = "DOOR/PIER"
4. DOOR → DOOR (e.g., CAPAS TARLAC → Another DOOR location) = "DOOR/DOOR"

## Notes

- The Mode of Service field is now auto-calculated and read-only
- Users must select both Origin and Destination for auto-fill to work
- If no matching transport service is found, it defaults to the first available service
- The system logs the auto-selected service to console for debugging
