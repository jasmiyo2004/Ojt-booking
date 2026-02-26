# Location Picker UI Update

## ✅ Changes Made (As Per Supervisor's Request)

### 1. Three Column Layout
The location picker now displays data in **3 columns side by side**:

| Column 1 | Column 2 | Column 3 |
|----------|----------|----------|
| ☐ Checkbox | Location Code (LocationCD) | Location Name (LocationDesc) |

Example:
```
┌──────────────────────────────────────────────────┐
│  Origin                                      ✕   │
├──────────────────────────────────────────────────┤
│  🔍 Search...                                    │
├──────────────────────────────────────────────────┤
│       | Location Code | Location Name           │
├──────────────────────────────────────────────────┤
│  ☐   | VISCEB        | CEBU PORT               │
│  ☐   | LUZMNI        | MANILA PORT             │
│  ☑   | MINDVO        | DAVAO PORT              │
│  ☐   | MINCGY        | CAGAYAN PORT            │
│  ☐   | LUZBAT        | BATANGAS PORT           │
├──────────────────────────────────────────────────┤
│              Pagination                          │
├──────────────────────────────────────────────────┤
│              [ CONFIRM ]                         │
└──────────────────────────────────────────────────┘
```

### 2. Checkbox Selection
- User must check a checkbox to select a location
- Only one location can be selected at a time
- Selected row is highlighted with golden color
- Clicking anywhere on the row also selects it

### 3. CONFIRM Button at Bottom
- Button is disabled (gray) when no location is selected
- Button is enabled (golden) when a location is checked
- Clicking CONFIRM returns the selected location in format: **"CEBU PORT (VISCEB)"**

### 4. Pagination (Default 5 Items)
- Shows only 5 locations per page
- "Pagination" label appears when there are more than 5 items
- Search resets to page 1

### 5. Search Functionality
- Search by Location Name OR Location Code
- Real-time filtering
- Case-insensitive

## Files Modified

1. **lib/models/location_model.dart**
   - Added `locationCD` field
   - Added `displayName` getter for formatted display

2. **lib/controllers/booking_controller.dart**
   - Completely rewrote `showLocationPicker()` method
   - Added 3-column layout with checkboxes
   - Added CONFIRM button at bottom
   - Added pagination logic (5 items per page)

3. **lib/services/api_service.dart**
   - Updated `getMockLocations()` with location codes
   - Added realistic location codes (VISCEB, LUZMNI, MINDVO, etc.)

## How It Works

1. User clicks "Origin" or "Destination" field
2. Modal opens showing 5 locations with checkboxes
3. User can search to filter locations
4. User clicks checkbox (or row) to select a location
5. Selected row highlights in golden color
6. CONFIRM button becomes enabled
7. User clicks CONFIRM
8. Modal closes and returns: **"CEBU PORT (VISCEB)"**

## Backend Integration

The C# API Location table/model should have:
```csharp
public class Location
{
    public int LocationId { get; set; }
    public string LocationDesc { get; set; }  // e.g., "CEBU PORT"
    public string LocationCD { get; set; }    // e.g., "VISCEB"
}
```

API endpoint should return:
```json
{
  "locationId": 1,
  "locationDesc": "CEBU PORT",
  "locationCD": "VISCEB"
}
```

## Testing

```bash
cd ojt_booking_web
flutter run -d chrome
```

Go to "New Booking" → Click "Origin" or "Destination"

You should see:
- ✅ Three columns: Checkbox | Location Code | Location Name
- ✅ 5 items per page
- ✅ Search functionality
- ✅ CONFIRM button at bottom (disabled until selection)
- ✅ Selected location displays as "CEBU PORT (VISCEB)"

---

**Status:** ✅ Complete and ready for testing
**Date:** February 23, 2026

