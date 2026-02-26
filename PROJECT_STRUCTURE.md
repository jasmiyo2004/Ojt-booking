# Gothong Southern Booking System - Project Structure

## ✅ Backend Separated Successfully

The backend API has been moved to a separate folder as requested.

## New Folder Structure

```
Gothong_Booking/
│
├── ojt_booking_web/              ← Flutter Frontend (Web App)
│   ├── lib/
│   │   ├── models/              ← Data models
│   │   ├── services/            ← API service layer
│   │   ├── views/               ← UI pages
│   │   └── controllers/         ← Business logic
│   ├── assets/                  ← Images and resources
│   ├── web/                     ← Web-specific files
│   └── pubspec.yaml             ← Flutter dependencies
│
├── booking_api/                  ← C# Backend API (Separated)
│   ├── Controllers/             ← API endpoints
│   ├── Models/                  ← Database models
│   ├── Data/                    ← Database context
│   ├── Program.cs               ← API configuration
│   ├── appsettings.json         ← Database connection
│   └── BookingApi.csproj        ← C# project file
│
└── sample_bookings.sql          ← Sample database data
```

## How to Run

### Frontend (Flutter)
```bash
cd ojt_booking_web
flutter run -d chrome
```

### Backend (C# API)
```bash
cd booking_api
dotnet run
```

The API runs on: `http://localhost:5022`

## Benefits of This Structure

✅ **Separation of Concerns** - Frontend and backend are completely independent
✅ **Easy Deployment** - Can deploy frontend and backend to different servers
✅ **Team Collaboration** - Frontend and backend developers can work independently
✅ **Version Control** - Can have separate Git repositories if needed
✅ **Professional Structure** - Follows industry best practices

## No Code Changes Needed

The Flutter app is already configured to connect to `http://localhost:5022/api`

Everything will work exactly the same - just run both projects separately!

## Documentation

- **Frontend Guide:** `ojt_booking_web/SETUP_GUIDE.md`
- **Backend Guide:** `booking_api/README.md`
- **How to Run API:** `ojt_booking_web/HOW_TO_RUN_API.md`
- **Connection Guide:** `ojt_booking_web/BACKEND_CONNECTION_GUIDE.md`

## Database Connection

**Server:** 192.168.76.119
**Database:** ojt_2026_01
**User:** jasper
**Password:** Default@123

Connection is configured in `booking_api/appsettings.json`

---

**Status:** ✅ Ready for development and testing
**Last Updated:** February 23, 2026
