# Top Routes Feature Implementation

## Overview
Replaced the "Upcoming Schedule" section on the home page with a "Top Routes" feature that shows the most frequently booked routes with date range filtering.

## Backend Changes

### BookingsController.cs
Added new endpoint: `GET /api/bookings/routes`

**Query Parameters:**
- `period` (optional): "day", "week", or "month" (default: "month")
- `startDate` (optional): Custom start date for date range
- `endDate` (optional): Custom end date for date range

**Response:**
```json
{
  "period": "month",
  "startDate": "2026-02-01T00:00:00Z",
  "endDate": "2026-02-28T23:59:59Z",
  "totalBookings": 45,
  "routes": [
    {
      "route": "CEBU → MANILA",
      "origin": "CEBU",
      "destination": "MANILA",
      "count": 15,
      "percentage": 33.3
    },
    ...
  ]
}
```

**Features:**
- Filters bookings by StatusId = 4 (BOOKED only)
- Uses Philippine timezone (UTC+8) for date calculations
- Returns top 10 routes sorted by booking count
- Calculates percentage of total bookings for each route

## Frontend Changes

### New Files Created

1. **ojt_booking_web/lib/models/route_stats_model.dart**
   - `RouteStats` class: Individual route statistics
   - `RouteStatsResponse` class: API response wrapper

### Modified Files

1. **ojt_booking_web/lib/services/api_service.dart**
   - Added `getRouteStatistics()` method
   - Supports period filtering and custom date ranges

2. **ojt_booking_web/lib/views/home_page.dart**
   - Removed "Upcoming Schedule" section
   - Removed calendar view functionality
   - Added "Top Routes" section with:
     - Period filter chips (Today, This Week, This Month, Custom)
     - Custom date range picker
     - Route list with rankings
     - Percentage badges
     - Total bookings indicator

## UI Features

### Period Filters
- **Today**: Shows routes for current day (Philippine time)
- **This Week**: Shows routes for current week (Sunday to Saturday)
- **This Month**: Shows routes for current month
- **Custom**: Opens date range picker for custom period selection

### Route Display
- Ranked list (1-10)
- Top 3 routes highlighted with gold badges
- Shows route name (Origin → Destination)
- Displays booking count
- Shows percentage of total bookings
- Color-coded percentage badges (blue)

### Empty States
- Loading indicator while fetching data
- "No routes found" message when no bookings in period

## Date Handling
- All date calculations use Philippine timezone (UTC+8)
- Backend converts dates to UTC for database queries
- Frontend displays dates in user-friendly format

## Usage Example

**API Call:**
```
GET /api/bookings/routes?period=week
GET /api/bookings/routes?startDate=2026-02-01&endDate=2026-02-15
```

**Flutter Usage:**
```dart
final stats = await _apiService.getRouteStatistics(
  period: 'month',
);

// Or with custom dates
final stats = await _apiService.getRouteStatistics(
  startDate: DateTime(2026, 2, 1),
  endDate: DateTime(2026, 2, 15),
);
```

## Testing
1. Start the backend API
2. Create several bookings with different routes
3. Navigate to home page
4. Test different period filters
5. Test custom date range selection
6. Verify route rankings and percentages

## Notes
- Only counts bookings with StatusId = 4 (BOOKED)
- Cancelled bookings (StatusId = 5) are excluded
- Routes are sorted by booking count (descending)
- Maximum 10 routes displayed
- Percentages rounded to 1 decimal place
