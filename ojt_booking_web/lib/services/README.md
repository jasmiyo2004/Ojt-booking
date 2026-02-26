# API Service - Quick Reference

## 🎯 Current Status: MOCK DATA MODE

The app is currently using fake/hardcoded data. This is NORMAL and GOOD for development!

## 📍 Where is the data coming from?

Look at `api_service.dart` at the bottom:

```dart
// Line 160+
List<Booking> _getMockBookings() {
  return [
    Booking(...),  // Fake booking 1
    Booking(...),  // Fake booking 2
    // etc.
  ];
}
```

## 🔄 How to Switch to Real API

### Option 1: Quick Test (One endpoint at a time)

1. Find the method you want to connect (e.g., `getBookings()`)
2. Uncomment these lines:
   ```dart
   final response = await http.get(Uri.parse('$baseUrl/bookings'));
   if (response.statusCode == 200) {
     List<dynamic> data = json.decode(response.body);
     return data.map((json) => Booking.fromJson(json)).toList();
   }
   ```
3. Comment out: `return _getMockBookings();`

### Option 2: Full Switch (All endpoints)

1. Change `baseUrl` at the top
2. Uncomment all `// TODO: Replace with actual API call` sections
3. Delete or comment out all `_getMock...()` calls

## 🧪 Testing Tips

### Test with Mock Data (Current)
```bash
flutter run
# Data loads instantly, always works
```

### Test with Real API
```bash
# 1. Make sure your C# API is running
# 2. Update baseUrl
# 3. flutter run
# Data loads from real server
```

### Test Error Handling
In `api_service.dart`, temporarily add:
```dart
Future<List<Booking>> getBookings() async {
  throw Exception('Test error');  // Simulate error
}
```

## 📊 Expected JSON Format from C# API

### GET /api/bookings
```json
[
  {
    "id": "1",
    "referenceNumber": "BK-2026-001",
    "route": "CEBU → MANILA",
    "origin": "CEBU",
    "destination": "MANILA",
    "bookingDate": "2026-02-15T00:00:00",
    "departureDate": "2026-02-20T00:00:00",
    "status": "BOOKED",
    "customerName": "Juan Dela Cruz",
    "contactNumber": "09123456789"
  }
]
```

### GET /api/bookings/stats
```json
{
  "totalBookings": 150,
  "booked": 15,
  "completed": 120,
  "cancelled": 15
}
```

## ⚠️ Important Notes

1. **Don't delete mock data yet!**
   - Keep it for testing
   - Useful when backend is down
   - Good for demos

2. **The http package is ready**
   - Already in pubspec.yaml
   - Import statements are there
   - Just uncomment the code

3. **Error handling is built-in**
   - Try-catch blocks ready
   - Loading states work
   - User sees friendly messages

## 🚀 Quick Start Checklist

When backend is ready:

- [ ] Get API URL from backend team
- [ ] Update `baseUrl` in api_service.dart (line 8)
- [ ] Test one endpoint first (recommend `getBookingStats()`)
- [ ] If it works, uncomment the rest
- [ ] Remove mock data calls
- [ ] Test the app
- [ ] Celebrate! 🎉

## 💡 Pro Tips

1. **Keep mock data during development**
   ```dart
   // Add a flag to switch between mock and real
   static const bool useMockData = true;
   
   Future<List<Booking>> getBookings() async {
     if (useMockData) {
       return _getMockBookings();
     }
     // Real API call here
   }
   ```

2. **Add logging**
   ```dart
   print('Fetching bookings from: $baseUrl/bookings');
   final response = await http.get(...);
   print('Response: ${response.statusCode}');
   ```

3. **Handle different status codes**
   ```dart
   if (response.statusCode == 200) {
     // Success
   } else if (response.statusCode == 404) {
     throw Exception('Bookings not found');
   } else {
     throw Exception('Server error: ${response.statusCode}');
   }
   ```

---

**Remember:** Mock data is your friend during development! Don't rush to connect the real API until it's fully tested.
