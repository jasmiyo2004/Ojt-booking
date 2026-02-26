# Backend Connection Guide - C# ASP.NET to SSMS

**Note:** The backend API is now in a separate folder (`booking_api`) outside of the Flutter project folder.

## Your Database Details
- **Database Name:** ojt_2026_01
- **Server:** 192.168.76.119
- **Authentication:** SQL Server Authentication
- **Login:** jasper
- **Password:** Default@123
- **Encryption:** Mandatory
- **Trust Server Certificate:** Yes

## Connection String for C# ASP.NET

In your C# project's `appsettings.json`, your connection string should look like this:

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=192.168.76.119;Database=ojt_2026_01;User Id=jasper;Password=Default@123;TrustServerCertificate=True;Encrypt=True;"
  }
}
```

## Troubleshooting Steps

### 1. Check if your C# API is running
- Open Visual Studio
- Press F5 or click "Run" to start your API
- Look for the URL it's running on (should be something like `http://localhost:5022` or `https://localhost:7022`)
- Make sure the port matches what's in your Flutter `api_service.dart` (currently set to 5022)

### 2. Update Flutter API URL if needed
If your C# API is running on a different port, update this file:
- File: `lib/services/api_service.dart`
- Line: `static const String baseUrl = 'http://localhost:5022/api';`
- Change `5022` to your actual port number

### 3. Test Database Connection in C# (Visual Studio)

In your C# API project, add this test endpoint to verify database connection:

```csharp
// In your BookingsController.cs or create a TestController.cs
[ApiController]
[Route("api/[controller]")]
public class TestController : ControllerBase
{
    private readonly YourDbContext _context; // Replace with your actual DbContext name

    public TestController(YourDbContext context)
    {
        _context = context;
    }

    [HttpGet("connection")]
    public IActionResult TestConnection()
    {
        try
        {
            var canConnect = _context.Database.CanConnect();
            if (canConnect)
            {
                var bookingCount = _context.Bookings.Count();
                return Ok(new { 
                    success = true, 
                    message = "Database connected successfully!",
                    bookingCount = bookingCount
                });
            }
            return BadRequest(new { success = false, message = "Cannot connect to database" });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { success = false, message = ex.Message });
        }
    }
}
```

### 4. Common Issues & Solutions

#### Issue: "Cannot open database"
**Solution:** 
- Check if SQL Server is running on 192.168.76.119
- Verify the database name is exactly `ojt_2026_01`
- Make sure user `jasper` has access to this database

#### Issue: "Login failed for user 'jasper'"
**Solution:**
- Verify password is correct: `Default@123`
- Check if SQL Server Authentication is enabled (not just Windows Auth)
- Verify user `jasper` exists and has proper permissions

#### Issue: "A network-related or instance-specific error"
**Solution:**
- Check if SQL Server is configured to allow remote connections
- Verify TCP/IP is enabled in SQL Server Configuration Manager
- Check if port 1433 is open (default SQL Server port)
- Try pinging 192.168.76.119 from command prompt

#### Issue: Flutter app not saving to database
**Solution:**
- Make sure your C# API is running (check Visual Studio)
- Check the browser console (F12) for error messages
- Verify the API endpoint URL matches in both Flutter and C#
- Check C# API logs/console for incoming requests

### 5. Enable CORS in C# API

Your C# API needs to allow requests from Flutter web app. In `Program.cs`:

```csharp
// Add this before builder.Build()
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowFlutter",
        policy =>
        {
            policy.WithOrigins("http://localhost:*") // Allow any localhost port
                  .AllowAnyHeader()
                  .AllowAnyMethod();
        });
});

// Add this after app.Build() and before app.Run()
app.UseCors("AllowFlutter");
```

### 6. Check Your C# Booking Model

Make sure your C# Booking model matches the Flutter model. Required fields:
- Id (string or int)
- ReferenceNumber (string)
- Origin (string)
- Destination (string)
- BookingDate (DateTime)
- DepartureDate (DateTime)
- Status (string)
- Route (string)
- All other fields from booking_model.dart

### 7. Verify API Endpoints

Your C# API should have these endpoints:
- `GET /api/bookings` - Get all bookings
- `GET /api/bookings/{id}` - Get booking by ID
- `POST /api/bookings` - Create new booking
- `PUT /api/bookings/{id}` - Update booking
- `GET /api/bookings/stats` - Get statistics

### 8. Test API with Postman or Browser

Before testing with Flutter, test your C# API directly:
1. Start your C# API in Visual Studio
2. Open browser and go to: `http://localhost:5022/api/bookings`
3. You should see JSON data or an empty array
4. If you get an error, the problem is in your C# API, not Flutter

## Quick Checklist

- [ ] SQL Server is running on 192.168.76.119
- [ ] Database `ojt_2026_01` exists
- [ ] User `jasper` can login with password `Default@123`
- [ ] Connection string in `appsettings.json` is correct
- [ ] C# API is running in Visual Studio
- [ ] CORS is enabled in C# API
- [ ] API endpoints are working (test in browser)
- [ ] Flutter `api_service.dart` has correct URL and port

## Need More Help?

If it's still not working:
1. Check Visual Studio Output window for errors
2. Check SQL Server Management Studio - can you connect with the same credentials?
3. Share the error message from Visual Studio console
4. Share the error from browser console (F12) when creating a booking
