# API Routes Explanation

## What Are Routes?

**Routes** (or API endpoints) are the URLs that the frontend uses to communicate with the backend. Think of them as "addresses" where specific data lives.

---

## Route Structure

A typical route looks like this:

```
http://localhost:5000/api/locations
└─────┬─────┘ └──┬──┘ └────┬────┘
   Base URL    Prefix   Resource
```

- **Base URL**: Where your backend server is running
- **Prefix**: Usually `/api` to indicate it's an API
- **Resource**: What data you're accessing (locations, vessels, customers, etc.)

---

## Routes in Your Booking System

### 1. Locations Route

**Backend (C#)**
```csharp
[Route("api/[controller]")]  // This creates the route pattern
[ApiController]
public class LocationsController : ControllerBase
{
    [HttpGet]  // Responds to GET requests
    public async Task<ActionResult<IEnumerable<Location>>> GetLocations()
    {
        // This method is called when someone visits:
        // GET http://localhost:5000/api/locations
    }
}
```

**Frontend (Dart)**
```dart
Future<List<Location>> getLocations() async {
  const url = '$baseUrl/locations';  // http://localhost:5000/api/locations
  final response = await http.get(Uri.parse(url));
}
```

**Route**: `GET /api/locations`
- **Purpose**: Get all locations
- **Returns**: List of locations with port and type info

---

### 2. Vessels Route

**Backend**
```csharp
[Route("api/[controller]")]
public class VesselsController : ControllerBase
{
    [HttpGet]
    public async Task<ActionResult<IEnumerable<Vessel>>> GetVessels()
    {
        // GET http://localhost:5000/api/vessels
    }
}
```

**Frontend**
```dart
const url = '$baseUrl/vessels';  // http://localhost:5000/api/vessels
```

**Route**: `GET /api/vessels`
- **Purpose**: Get all vessels
- **Returns**: List of vessels

---

### 3. Equipment Route

**Route**: `GET /api/equipment`
- **Purpose**: Get all equipment types
- **Returns**: List of equipment

---

### 4. Commodities Route

**Route**: `GET /api/commodities`
- **Purpose**: Get all commodities
- **Returns**: List of commodities

---

### 5. Containers Route

**Route**: `GET /api/containers`
- **Purpose**: Get all containers
- **Returns**: List of container numbers

---

### 6. Customer Routes (Multiple Endpoints)

These are **sub-routes** - different endpoints under the same controller:

**Backend**
```csharp
[Route("api/[controller]")]
public class CustomersController : ControllerBase
{
    [HttpGet("agreement-parties")]  // Sub-route
    public async Task<ActionResult> GetAgreementParties()
    {
        // GET http://localhost:5000/api/customers/agreement-parties
    }

    [HttpGet("shipper-parties")]  // Different sub-route
    public async Task<ActionResult> GetShipperParties()
    {
        // GET http://localhost:5000/api/customers/shipper-parties
    }

    [HttpGet("consignee-parties")]  // Another sub-route
    public async Task<ActionResult> GetConsigneeParties()
    {
        // GET http://localhost:5000/api/customers/consignee-parties
    }
}
```

**Routes**:
- `GET /api/customers/agreement-parties` - Get customers with PartyTypeId = 10
- `GET /api/customers/shipper-parties` - Get customers with PartyTypeId = 11
- `GET /api/customers/consignee-parties` - Get customers with PartyTypeId = 12

**Why separate routes?** Each route filters for a different party type, so the frontend gets exactly what it needs.

---

### 7. Vessel Schedules Route (With Query Parameters)

**Backend**
```csharp
[Route("api/[controller]")]
public class VesselSchedulesController : ControllerBase
{
    [HttpGet]
    public async Task<ActionResult> GetVesselSchedules(
        [FromQuery] int? originLocationId = null,
        [FromQuery] int? destinationLocationId = null,
        [FromQuery] int? vesselId = null)
    {
        // GET http://localhost:5000/api/vesselschedules?originLocationId=3&destinationLocationId=2&vesselId=1
    }
}
```

**Frontend**
```dart
Future<List<VesselSchedule>> getVesselSchedules({
  int? originLocationId,
  int? destinationLocationId,
  int? vesselId,
}) async {
  var url = '$baseUrl/vesselschedules?';
  
  // Build query string
  if (originLocationId != null) {
    url += 'originLocationId=$originLocationId&';
  }
  if (destinationLocationId != null) {
    url += 'destinationLocationId=$destinationLocationId&';
  }
  if (vesselId != null) {
    url += 'vesselId=$vesselId';
  }
  
  // Final URL: http://localhost:5000/api/vesselschedules?originLocationId=3&destinationLocationId=2&vesselId=1
}
```

**Route**: `GET /api/vesselschedules?originLocationId={id}&destinationLocationId={id}&vesselId={id}`
- **Purpose**: Get filtered vessel schedules
- **Query Parameters**: Filters for origin, destination, and vessel
- **Returns**: List of matching schedules

---

### 8. Bookings Route (POST - Creating Data)

**Backend**
```csharp
[Route("api/[controller]")]
public class BookingsController : ControllerBase
{
    [HttpPost]  // Responds to POST requests (creating new data)
    public async Task<ActionResult<Booking>> CreateBooking(Booking booking)
    {
        // POST http://localhost:5000/api/bookings
        // Body contains booking data as JSON
    }
}
```

**Frontend**
```dart
Future<void> createBooking(Map<String, dynamic> bookingData) async {
  const url = '$baseUrl/bookings';
  
  final response = await http.post(
    Uri.parse(url),
    headers: {'Content-Type': 'application/json'},
    body: json.encode(bookingData),  // Send data in request body
  );
}
```

**Route**: `POST /api/bookings`
- **Purpose**: Create a new booking
- **Sends**: Booking data in JSON format
- **Returns**: Created booking with ID

---

## HTTP Methods (Verbs)

Routes use different HTTP methods for different actions:

| Method | Purpose | Example |
|--------|---------|---------|
| **GET** | Read/Retrieve data | `GET /api/locations` - Get all locations |
| **POST** | Create new data | `POST /api/bookings` - Create a booking |
| **PUT** | Update existing data | `PUT /api/bookings/123` - Update booking #123 |
| **DELETE** | Delete data | `DELETE /api/bookings/123` - Delete booking #123 |

---

## Complete Route Map for Your System

```
Backend API Routes (C# .NET)
├── GET  /api/locations
├── GET  /api/vessels
├── GET  /api/equipment
├── GET  /api/commodities
├── GET  /api/containers
├── GET  /api/customers/agreement-parties
├── GET  /api/customers/shipper-parties
├── GET  /api/customers/consignee-parties
├── GET  /api/vesselschedules?originLocationId={id}&destinationLocationId={id}&vesselId={id}
├── GET  /api/transportservices
├── GET  /api/paymentmodes
├── POST /api/bookings
└── GET  /api/bookings
```

---

## How Routes Work: Step-by-Step

### Example: Getting Locations

1. **User clicks Origin field** in Flutter app

2. **Frontend calls API service**:
   ```dart
   final locations = await _apiService.getLocations();
   ```

3. **API service makes HTTP request**:
   ```dart
   GET http://localhost:5000/api/locations
   ```

4. **Backend receives request**:
   - ASP.NET Core routing sees `/api/locations`
   - Finds `LocationsController`
   - Calls `GetLocations()` method

5. **Backend queries database**:
   ```csharp
   return await _context.Locations
       .Include(l => l.Port)
       .Include(l => l.LocationType)
       .ToListAsync();
   ```

6. **Backend sends response**:
   ```json
   HTTP 200 OK
   Content-Type: application/json
   
   [
     {
       "locationId": 3,
       "locationCd": "VISBCD",
       "locationDesc": "BACOLOD PORT (VISBCD)",
       ...
     }
   ]
   ```

7. **Frontend receives response**:
   ```dart
   final List<dynamic> data = json.decode(response.body);
   return data.map((json) => Location.fromJson(json)).toList();
   ```

8. **UI displays data** in the modal picker

---

## Route Attributes in C#

### `[Route]` Attribute
```csharp
[Route("api/[controller]")]  // [controller] is replaced with class name minus "Controller"
public class LocationsController  // Becomes: /api/locations
```

### `[HttpGet]` Attribute
```csharp
[HttpGet]  // Simple GET endpoint
public async Task<ActionResult> GetAll()

[HttpGet("{id}")]  // GET with ID parameter: /api/locations/5
public async Task<ActionResult> GetById(int id)

[HttpGet("agreement-parties")]  // GET with custom path: /api/customers/agreement-parties
public async Task<ActionResult> GetAgreementParties()
```

### `[FromQuery]` Attribute
```csharp
[HttpGet]
public async Task<ActionResult> GetVesselSchedules(
    [FromQuery] int? originLocationId,  // Gets value from query string
    [FromQuery] int? destinationLocationId,
    [FromQuery] int? vesselId)
{
    // URL: /api/vesselschedules?originLocationId=3&destinationLocationId=2&vesselId=1
}
```

---

## Why Use Routes?

### 1. **Organization**
Routes organize your API logically:
```
/api/locations     - Everything about locations
/api/vessels       - Everything about vessels
/api/customers     - Everything about customers
```

### 2. **RESTful Design**
Follows REST (Representational State Transfer) principles:
- Resources are nouns (locations, vessels)
- Actions are HTTP methods (GET, POST, PUT, DELETE)

### 3. **Clear Communication**
Frontend developers know exactly where to get data:
```dart
// Need locations? Call this route:
GET /api/locations

// Need vessels? Call this route:
GET /api/vessels
```

### 4. **Filtering & Parameters**
Routes can accept parameters to filter data:
```
GET /api/vesselschedules?vesselId=1
GET /api/customers/agreement-parties
```

---

## Common Route Patterns

### 1. Collection Route
```
GET /api/locations  - Get all locations
```

### 2. Single Item Route
```
GET /api/locations/5  - Get location with ID 5
```

### 3. Sub-Resource Route
```
GET /api/customers/agreement-parties  - Get specific type of customers
```

### 4. Filtered Route
```
GET /api/vesselschedules?vesselId=1&originLocationId=3
```

### 5. Action Route
```
POST /api/bookings/123/confirm  - Perform action on booking 123
```

---

## Testing Routes

You can test routes using tools like:

### 1. Browser (for GET requests only)
```
http://localhost:5000/api/locations
```

### 2. Postman
- Set method: GET, POST, PUT, DELETE
- Enter URL: http://localhost:5000/api/locations
- Add headers, body, query parameters
- Click Send

### 3. Swagger (Built into ASP.NET Core)
```
http://localhost:5000/swagger
```
- Lists all routes
- Can test each route
- Shows request/response formats

### 4. curl (Command line)
```bash
curl http://localhost:5000/api/locations
```

---

## Route Configuration in Your Project

### Backend: Program.cs or Startup.cs
```csharp
app.MapControllers();  // This enables all routes from controllers
```

### Frontend: api_service.dart
```dart
class ApiService {
  final String baseUrl = 'http://localhost:5000/api';
  
  // Each method corresponds to a route
  Future<List<Location>> getLocations() async {
    const url = '$baseUrl/locations';  // Route: /api/locations
  }
  
  Future<List<Vessel>> getVessels() async {
    const url = '$baseUrl/vessels';  // Route: /api/vessels
  }
}
```

---

## Summary

**Routes are the "addresses" where your data lives on the backend.**

- Frontend says: "I need locations"
- Frontend calls: `GET /api/locations`
- Backend responds: "Here are all the locations"

Each picker in your booking system uses a specific route to get its data:
- Origin/Destination → `/api/locations`
- Vessel → `/api/vessels`
- Equipment → `/api/equipment`
- Commodity → `/api/commodities`
- Container → `/api/containers`
- Agreement Party → `/api/customers/agreement-parties`
- Shipper Party → `/api/customers/shipper-parties`
- Consignee Party → `/api/customers/consignee-parties`
- Vessel Schedule → `/api/vesselschedules?filters...`

Routes make your API organized, predictable, and easy to use!
