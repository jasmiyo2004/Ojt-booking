# 🚀 Quick Reference Card

## Files You Need to Know

| File | Purpose | When to Edit |
|------|---------|--------------|
| `lib/models/booking_model.dart` | Booking data structure | When C# API changes booking fields |
| `lib/services/api_service.dart` | API calls | When connecting to C# backend |
| `lib/views/home_page.dart` | Home screen UI | When changing UI only |

---

## Common Tasks

### Task: Connect to Real C# API
**File:** `lib/services/api_service.dart`
**Line:** 8
**Change:** Update `baseUrl` to your API URL
**Time:** 5 minutes

### Task: Add New Booking Field
**File:** `lib/models/booking_model.dart`
**Add:** New field in class and `fromJson` method
**Time:** 2 minutes

### Task: Change Loading Animation
**File:** `lib/views/home_page.dart`
**Method:** `_buildStatsLoadingSkeleton()` or `_buildBookingsLoadingSkeleton()`
**Time:** 5 minutes

---

## Code Snippets

### Get Bookings
```dart
final bookings = await ApiService().getBookings();
```

### Get Statistics
```dart
final stats = await ApiService().getBookingStats();
```

### Create Booking
```dart
final newBooking = Booking(...);
await ApiService().createBooking(newBooking);
```

---

## Testing

### Test with Mock Data (Current)
```bash
flutter run
# Uses fake data from api_service.dart
```

### Test with Real API
1. Update `baseUrl` in api_service.dart
2. Uncomment API calls
3. `flutter run`

### Test Loading States
In api_service.dart, change:
```dart
await Future.delayed(const Duration(seconds: 1));
// to
await Future.delayed(const Duration(seconds: 5));
```

---

## Debugging

### Check if data is loading
Add print statements:
```dart
print('Loading bookings...');
final bookings = await apiService.getBookings();
print('Loaded ${bookings.length} bookings');
```

### Check API response
In api_service.dart:
```dart
final response = await http.get(...);
print('Status: ${response.statusCode}');
print('Body: ${response.body}');
```

---

## Important URLs

- **Mock Data:** `lib/services/api_service.dart` (line 160+)
- **Loading States:** `lib/views/home_page.dart` (line 400+)
- **Models:** `lib/models/`

---

## Quick Wins

### Add More Mock Bookings
`api_service.dart` → `_getMockBookings()` → Add more `Booking(...)` objects

### Change Loading Time
`api_service.dart` → Change `Duration(seconds: 1)` to any value

### Customize Empty State
`home_page.dart` → `_buildEmptyState()` → Change text/icon

---

## When Things Go Wrong

| Problem | Solution |
|---------|----------|
| "Failed to load data" | Check `api_service.dart` mock data |
| Loading forever | Check `_isLoadingStats` is set to false |
| Empty screen | Check `_recentBookings` has data |
| API not working | Check `baseUrl` and internet connection |

---

## Show Your Supervisor

1. ✅ "I created model classes for type safety"
2. ✅ "I set up a service layer for API calls"
3. ✅ "I added professional loading states"
4. ✅ "Connecting to the C# API will take 5 minutes"

---

## Next Steps

1. ⏳ Wait for C# API URL
2. ⏳ Wait for database schema
3. 🔜 Update `baseUrl`
4. 🔜 Uncomment API calls
5. 🔜 Test with real data
6. 🎉 Done!

---

**Keep this file handy - it has everything you need!** 📌
