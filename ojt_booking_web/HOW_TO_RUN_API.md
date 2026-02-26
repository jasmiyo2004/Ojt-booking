# How to Run Your C# Booking API

## Your API is now in: `booking_api` folder (outside ojt_booking_web)

**New folder structure:**
```
Gothong_Booking/
├── ojt_booking_web/     ← Flutter frontend
└── booking_api/         ← C# backend (moved here)
```

## Step 1: Install .NET SDK (if not installed)

1. Go to: https://dotnet.microsoft.com/download
2. Download .NET 8.0 SDK (or latest version)
3. Install it
4. Restart your terminal/command prompt

## Step 2: Run the API

### Option A: Using Command Line (Recommended)

1. Open a NEW terminal/command prompt
2. Navigate to your project:
   ```
   cd C:\Users\OJT\Desktop\Gothong_Booking\booking_api
   ```

3. Run the API:
   ```
   dotnet run
   ```

4. You should see output like:
   ```
   info: Microsoft.Hosting.Lifetime[14]
         Now listening on: http://localhost:5022
   info: Microsoft.Hosting.Lifetime[0]
         Application started. Press Ctrl+C to shut down.
   ```

5. **IMPORTANT:** Note the port number (e.g., 5022)
6. Keep this terminal window open while testing

### Option B: Using Visual Studio

1. Open Visual Studio
2. File → Open → Project/Solution
3. Navigate to: `C:\Users\OJT\Desktop\Gothong_Booking\booking_api`
4. Open `BookingApi.csproj`
5. Press F5 or click the green "Run" button
6. The API will start and open Swagger UI in your browser

### Option C: Using Visual Studio Code

1. Open VS Code
2. Open the `booking_api` folder
3. Open terminal in VS Code (Ctrl + `)
4. Run: `dotnet run`

## Step 3: Verify API is Running

Once the API is running, open your browser and go to:
- http://localhost:5022/api/bookings

You should see JSON data (bookings from your database) or an empty array `[]`

## Step 4: Test with Swagger (Optional)

If you used Visual Studio or want to test endpoints:
- Go to: http://localhost:5022/swagger
- You'll see all available endpoints
- You can test them directly from the browser

## Step 5: Connect Flutter to API

Your Flutter app is already configured to connect to:
- URL: `http://localhost:5022/api`
- This is set in: `lib/services/api_service.dart`

### If your API runs on a different port:

1. Check what port your API is using (from the terminal output)
2. Update Flutter:
   - Open: `lib/services/api_service.dart`
   - Change line 10: `static const String baseUrl = 'http://localhost:YOUR_PORT/api';`
3. Hot restart Flutter app (press 'R' in terminal)

## Step 6: Test the Connection

1. Make sure your C# API is running (Step 2)
2. In your Flutter app, go to: **Settings → API Connection Test**
3. Click "Test GET Bookings"
4. If successful, you'll see: "🎉 Connected to real API!"
5. Click "Test CREATE Booking" to add a test booking
6. Check your SSMS database to verify it was saved

## Troubleshooting

### Error: "Cannot connect to database"

**Check your connection string in `booking_api/appsettings.json`:**
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=192.168.76.119,1433;Database=ojt_2026_01;User Id=jasper;Password=Default@123;TrustServerCertificate=True;"
  }
}
```

**Verify:**
- SQL Server is running on 192.168.76.119
- Database `ojt_2026_01` exists
- User `jasper` can login with password `Default@123`
- You can connect using SQL Server Management Studio with these credentials

### Error: "dotnet command not found"

- .NET SDK is not installed or not in PATH
- Install .NET SDK from: https://dotnet.microsoft.com/download
- Restart your terminal after installation

### Error: "Port already in use"

- Another application is using port 5022
- Either:
  1. Stop the other application
  2. Or change the port in `booking_api/Properties/launchSettings.json`
  3. Then update Flutter's `api_service.dart` with the new port

### Error: "CORS policy error" in browser console

- This is already configured in your `Program.cs`
- Make sure the line `app.UseCors("AllowAll");` is present
- Restart the API after any changes

### Flutter shows "Using MOCK data"

This means Flutter cannot reach your C# API. Check:
1. Is the C# API running? (Check terminal)
2. Is it running on port 5022? (Check terminal output)
3. Can you access http://localhost:5022/api/bookings in browser?
4. Is Flutter's `api_service.dart` pointing to the correct port?

## Database Schema

Your C# API expects these tables in SSMS:
- `Bookings` - Main booking table
- `Statuses` - Booking statuses (BOOKED, COMPLETED, CANCELLED, etc.)
- `Locations` - Origin and destination locations
- `Vessels` - Vessel information
- `VesselSchedules` - Vessel schedules
- `Ports` - Port information

Make sure these tables exist in your `ojt_2026_01` database.

## Quick Test Checklist

- [ ] .NET SDK is installed
- [ ] SQL Server is accessible at 192.168.76.119
- [ ] Database `ojt_2026_01` exists
- [ ] Can login to SSMS with jasper/Default@123
- [ ] C# API is running (terminal shows "Now listening on...")
- [ ] Can access http://localhost:5022/api/bookings in browser
- [ ] Flutter app is running
- [ ] API Test Page shows "Connected to real API!"
- [ ] Test booking appears in SSMS database

## Need Help?

If you're still having issues:
1. Share the error message from the C# API terminal
2. Share the error from browser console (F12)
3. Verify you can connect to SSMS with the credentials
4. Check if the database tables exist
