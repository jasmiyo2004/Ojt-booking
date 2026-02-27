# Recent Bookings Fix

## Issue
The Recent Transactions section in the home page was not displaying the top 5 most recent bookings correctly. The bookings were not sorted by creation date.

## Root Cause
The `getRecentBookings()` method in the API service was calling `getBookings()` and taking the first 5 results. While the backend was sorting by `CreateDttm`, there was no dedicated endpoint for recent bookings, which could lead to inefficiency and potential issues.

## Solution
Created a dedicated backend endpoint `/api/bookings/recent` that:
1. Queries only the top 5 bookings (more efficient)
2. Explicitly sorts by `CreateDttm` descending, then by `BookingId` descending
3. Returns complete booking data with all navigation properties

## Changes Made

### 1. Backend (C#)

#### booking_api/Controllers/BookingsController.cs
Added new endpoint `GET /api/bookings/recent`:

```csharp
// GET: api/Bookings/recent
[HttpGet("recent")]
public async Task<ActionResult<IEnumerable<BookingDto>>> GetRecentBookings()
{
    try
    {
        // Get top 5 most recent bookings sorted by CreateDttm descending
        var bookings = await _context.Bookings
            .Include(b => b.Status)
            .Include(b => b.OriginLocation)
            .Include(b => b.DestinationLocation)
            .Include(b => b.VesselSchedule)
                .ThenInclude(vs => vs.Vessel)
            .Include(b => b.VesselSchedule)
                .ThenInclude(vs => vs.OriginPort)
            .Include(b => b.VesselSchedule)
                .ThenInclude(vs => vs.DestinationPort)
            .Include(b => b.Equipment)
            .Include(b => b.PaymentMode)
            .Include(b => b.Commodity)
            .Include(b => b.Vessel)
            .Include(b => b.Container)
            .Include(b => b.BookingParties)
                .ThenInclude(bp => bp.Customer)
            .OrderByDescending(b => b.CreateDttm)
            .ThenByDescending(b => b.BookingId)
            .Take(5)
            .ToListAsync();

        // ... (map to DTOs with customer information)
        
        return Ok(bookingDtos);
    }
    catch (Exception ex)
    {
        return StatusCode(500, new { error = ex.Message });
    }
}
```

**Key Features:**
- Uses `.Take(5)` to limit results at the database level (efficient)
- Sorts by `CreateDttm` descending (most recent first)
- Secondary sort by `BookingId` descending for consistent ordering
- Includes all navigation properties for complete booking data
- Loads customer information separately for performance
- Returns `BookingDto` with all fields including cancellation data

### 2. Frontend (Flutter)

#### ojt_booking_web/lib/services/api_service.dart
Updated `getRecentBookings()` to call the dedicated endpoint:

```dart
/// Get recent bookings (last 5)
/// GET /api/bookings/recent
Future<List<Booking>> getRecentBookings() async {
  try {
    print('API Service: Fetching recent bookings from $baseUrl/bookings/recent');
    final response = await http
        .get(Uri.parse('$baseUrl/bookings/recent'))
        .timeout(const Duration(seconds: 10));
    
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      lastBookingsSource = 'api';
      print('API Service: Successfully loaded ${data.length} recent bookings from API');
      return data.map((json) => Booking.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load recent bookings: ${response.statusCode}');
    }
  } catch (e, st) {
    // Fallback to mock data if API fails
    print('API call failed (getRecentBookings), falling back to mock data. Error: $e');
    print(st);
    lastBookingsSource = 'mock';
    return getMockBookings().take(5).toList();
  }
}
```

**Key Features:**
- Calls dedicated `/api/bookings/recent` endpoint
- Includes debug logging for troubleshooting
- Falls back to mock data if API fails
- Sets `lastBookingsSource` for debugging

## Sorting Logic

### Primary Sort: CreateDttm (Descending)
- Most recently created bookings appear first
- Uses Philippine time (UTC+8) for timestamps

### Secondary Sort: BookingId (Descending)
- Ensures consistent ordering when multiple bookings have the same CreateDttm
- Higher booking IDs (newer) appear first

## Example Order

```
Recent Bookings (Top 5):
1. BK177220523792 - Created: 2026-02-27 09:45:04 (most recent)
2. BK177215710968 - Created: 2026-02-27 09:30:15
3. BK177215605131 - Created: 2026-02-26 14:20:30
4. BK177215813161 - Created: 2026-02-26 10:15:22
5. BK177215930092 - Created: 2026-02-26 08:10:10
```

## Benefits

1. **Performance**: Only queries 5 bookings instead of all bookings
2. **Accuracy**: Explicit sorting ensures correct order
3. **Efficiency**: Database-level `.Take(5)` reduces data transfer
4. **Maintainability**: Dedicated endpoint is easier to modify
5. **Debugging**: Added logging for troubleshooting

## Testing

1. **Test Recent Bookings Display:**
   - Navigate to Home page
   - Verify "Recent Transactions" section shows 5 bookings
   - Verify bookings are sorted by most recent first
   - Create a new booking and verify it appears at the top

2. **Test API Endpoint:**
   - Call `GET /api/bookings/recent` directly
   - Verify response contains exactly 5 bookings
   - Verify bookings are sorted by CreateDttm descending
   - Verify all booking data is included

3. **Test Fallback:**
   - Stop the API server
   - Reload the home page
   - Verify mock data is displayed
   - Verify "Source: Mock" indicator appears

## API Endpoint

**GET** `/api/bookings/recent`

**Response:** Array of BookingDto (max 5 items)

```json
[
  {
    "bookingId": 12,
    "bookingNo": "BK177220523792",
    "statusDesc": "BOOKED",
    "originLocationDesc": "CEBU PORT",
    "destinationLocationDesc": "MANILA PORT",
    "createDttm": "2026-02-27T09:45:04.513",
    ...
  },
  ...
]
```

## Notes
- The endpoint returns a maximum of 5 bookings
- Bookings are sorted by creation date (most recent first)
- All booking statuses are included (BOOKED, COMPLETED, CANCELLED)
- Philippine time (UTC+8) is used for all timestamps
- The home page automatically refreshes when returning from other pages
