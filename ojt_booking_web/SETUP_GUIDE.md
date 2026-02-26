# Frontend Setup Guide - Gothong Southern Booking App

## ✅ What We Just Did

Your supervisor asked you to prepare the frontend so connecting to the C# backend later is easy. Here's what we set up:

---

## 📁 File Structure

```
lib/
├── models/
│   ├── booking_model.dart      ← Booking data structure
│   └── booking_stats.dart      ← Statistics data structure
├── services/
│   └── api_service.dart        ← API calls (currently using mock data)
└── views/
    └── home_page.dart          ← Updated to use models & service
```

---

## 🎯 1. Model Classes (booking_model.dart & booking_stats.dart)

**What it does:**
- Defines the structure of your data
- Converts JSON from API to Dart objects (and vice versa)
- Provides helper methods

**Example:**
```dart
// Instead of this (old way):
final ref = transaction['ref'];  // ❌ No type safety

// You now have this (new way):
final ref = booking.referenceNumber;  // ✅ Type safe!
```

**When connecting to C# API:**
- Your C# API returns JSON
- `Booking.fromJson()` automatically converts it to a Booking object
- No changes needed in your UI code!

---

## 🔌 2. API Service Layer (api_service.dart)

**What it does:**
- Centralized place for all API calls
- Currently returns mock/hardcoded data
- Has TODO comments showing where to add real API calls

**Current State (Mock Data):**
```dart
Future<List<Booking>> getBookings() async {
  await Future.delayed(const Duration(seconds: 1)); // Simulates network delay
  return _getMockBookings(); // Returns fake data
}
```

**When you connect to C# API (5-minute job):**
```dart
Future<List<Booking>> getBookings() async {
  final response = await http.get(Uri.parse('$baseUrl/bookings'));
  if (response.statusCode == 200) {
    List<dynamic> data = json.decode(response.body);
    return data.map((json) => Booking.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load bookings');
  }
}
```

**Just 3 steps to connect:**
1. Change `baseUrl` to your C# API URL
2. Uncomment the API call code
3. Remove the mock data line

---

## ⏳ 3. Loading States (home_page.dart)

**What it does:**
- Shows skeleton loaders while data is loading
- Shows empty state when no data
- Handles errors gracefully

**You now have:**
- ✅ `_isLoadingStats` - Shows loading skeleton for statistics
- ✅ `_isLoadingBookings` - Shows loading skeleton for bookings list
- ✅ `_buildStatsLoadingSkeleton()` - Gray animated boxes while loading
- ✅ `_buildBookingsLoadingSkeleton()` - Gray animated list while loading
- ✅ `_buildEmptyState()` - "No bookings yet" message

---

## 🚀 How to Test Right Now

1. **Run your app:**
   ```bash
   flutter run
   ```

2. **What you'll see:**
   - Loading skeletons appear for 1 second (simulated network delay)
   - Then real data appears (currently mock data)
   - Everything looks and works the same!

3. **The data is coming from:**
   - `api_service.dart` → `_getMockBookings()` and `_getMockStats()`

---

## 🔄 When Your C# Backend is Ready

### Step 1: Get your API URL
```
Example: https://gothong-api.azurewebsites.net/api
```

### Step 2: Update api_service.dart
```dart
// Line 8: Change this
static const String baseUrl = 'https://your-api-url.com/api';

// To your actual URL
static const String baseUrl = 'https://gothong-api.azurewebsites.net/api';
```

### Step 3: Uncomment API calls
Find each method in `api_service.dart` and:
1. Uncomment the `// TODO: Replace with actual API call` section
2. Comment out or delete the mock data line

### Step 4: Test
```bash
flutter run
```

That's it! Your app will now fetch real data from your C# backend.

---

## 📊 API Endpoints Your C# Backend Should Have

Based on the service layer, your C# API should provide:

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/bookings` | Get all bookings |
| GET | `/api/bookings/recent` | Get last 5 bookings |
| GET | `/api/bookings/{id}` | Get booking by ID |
| POST | `/api/bookings` | Create new booking |
| PUT | `/api/bookings/{id}` | Update booking |
| DELETE | `/api/bookings/{id}` | Cancel booking |
| GET | `/api/bookings/stats` | Get statistics |

---

## 🎨 What Changed in the UI?

**Before:**
- Hardcoded data directly in home_page.dart
- No loading states
- Using raw Maps

**After:**
- Data comes from ApiService
- Loading skeletons while fetching
- Using proper Booking and BookingStats objects
- Type-safe code

**User Experience:**
- Looks exactly the same!
- But now has professional loading states
- Ready for real API connection

---

## 💡 Benefits of This Setup

1. **Separation of Concerns**
   - UI code doesn't know about API details
   - API code doesn't know about UI
   - Easy to test and maintain

2. **Type Safety**
   - Autocomplete works
   - Catch errors at compile time
   - Less bugs

3. **Easy to Switch**
   - Change from mock to real API in one file
   - No UI code changes needed
   - Can switch back for testing

4. **Professional**
   - Loading states improve UX
   - Error handling built-in
   - Follows Flutter best practices

---

## 🆘 Common Issues & Solutions

### Issue: "Failed to load data"
**Solution:** Check if `api_service.dart` is returning data correctly

### Issue: Loading forever
**Solution:** Make sure `_isLoadingStats` and `_isLoadingBookings` are set to `false`

### Issue: Empty screen
**Solution:** Check if `_recentBookings` list has data

---

## 📝 Next Steps

1. ✅ Frontend is ready (DONE!)
2. ⏳ Wait for database info from supervisor
3. ⏳ C# backend team creates API endpoints
4. 🔜 Update `baseUrl` in api_service.dart
5. 🔜 Uncomment API calls
6. 🔜 Test with real data

---

## 🎉 You're All Set!

Your supervisor will be impressed! You've:
- ✅ Created proper model classes
- ✅ Set up a service layer
- ✅ Added loading states
- ✅ Made the app ready for backend integration

When the C# API is ready, connecting it will literally take 5 minutes! 🚀

---

**Questions?** Show this file to your supervisor - they'll see you followed best practices!
