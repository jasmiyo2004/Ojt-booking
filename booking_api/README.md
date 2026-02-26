# Gothong Southern Booking API

ASP.NET Core Web API for the Gothong Southern Booking System.

## Quick Start

### Run the API

```bash
cd booking_api
dotnet run
```

The API will start on: `http://localhost:5022`

### Test the API

Open in browser: `http://localhost:5022/api/bookings`

Or use Swagger UI: `http://localhost:5022/swagger`

## Database Connection

**Server:** 192.168.76.119
**Database:** ojt_2026_01
**User:** jasper
**Password:** Default@123

Connection string is configured in `appsettings.json`

## Available Endpoints

- `GET /api/bookings` - Get all bookings
- `GET /api/bookings/{id}` - Get booking by ID
- `POST /api/bookings` - Create new booking
- `PUT /api/bookings/{id}` - Update booking
- `POST /api/bookings/{id}/cancel` - Cancel booking
- `GET /api/bookings/stats` - Get booking statistics
- `GET /api/locations` - Get all locations
- `GET /api/vessels` - Get all vessels
- `GET /api/equipment` - Get all equipment
- `GET /api/commodities` - Get all commodities
- `GET /api/paymentmodes` - Get all payment modes
- `GET /api/transportservices` - Get all transport services

## Project Structure

```
booking_api/
├── Controllers/        ← API endpoints
├── Models/            ← Data models
├── Data/              ← Database context
├── Program.cs         ← App configuration
└── appsettings.json   ← Configuration (DB connection)
```

## Frontend Connection

The Flutter frontend (`ojt_booking_web`) is configured to connect to this API at:
`http://localhost:5022/api`

Make sure this API is running before testing the Flutter app.

## Troubleshooting

**Cannot connect to database?**
- Check if SQL Server is running on 192.168.76.119
- Verify database `ojt_2026_01` exists
- Test connection using SQL Server Management Studio

**Port already in use?**
- Change port in `Properties/launchSettings.json`
- Update Flutter's `api_service.dart` with new port

**CORS errors?**
- Already configured in `Program.cs`
- Restart API after any changes

## Need Help?

See the detailed guide in the Flutter project:
`ojt_booking_web/HOW_TO_RUN_API.md`
