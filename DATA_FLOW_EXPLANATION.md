# Data Flow Explanation: How Search Modals Get Data from Database

This document explains how data flows from the SQL Server database through the backend API to the Flutter frontend search modals.

---

## Overview of the Architecture

```
Database (SQL Server)
    ↓
Backend API (C# .NET)
    ↓
HTTP Request/Response
    ↓
Frontend API Service (Flutter/Dart)
    ↓
Controller (Flutter/Dart)
    ↓
UI Modal (Flutter/Dart)
```

---

## 1. ORIGIN/DESTINATION LOCATION PICKER

### Database Tables
- **Location** table: Contains LocationId, LocationCd, LocationDesc, PortId, LocationTypeId
- **Port** table: Contains PortId, PortCd, PortDesc
- **LocationType** table: Contains LocationTypeId, LocationTypeDesc

### Backend Flow (C# .NET)

**File**: `booking_api/Controllers/LocationsController.cs`

```csharp
[HttpGet]
public async Task<ActionResult<IEnumerable<Location>>> GetLocations()
{
    // Query the database using Entity Framework
    return await _context.Locations
        .Include(l => l.Port)           // Join with Port table
        .Include(l => l.LocationType)   // Join with LocationType table
        .OrderBy(l => l.LocationDesc)   // Sort by location description
        .ToListAsync();                 // Execute query and return list
}
```

**What happens:**
1. Entity Framework creates a SQL JOIN query
2. Fetches all locations with their related Port and LocationType data
3. Returns JSON response like:
```json
[
  {
    "locationId": 3,
    "locationCd": "VISBCD",
    "locationDesc": "BACOLOD PORT (VISBCD)",
    "portId": 1,
    "locationTypeId": 1,
    "port": {
      "portId": 1,
      "portCd": "BCD",
      "portDesc": "BACOLOD PORT"
    },
    "locationType": {
      "locationTypeId": 1,
      "locationTypeDesc": "Port"
    }
  }
]
```

### Frontend Flow (Flutter/Dart)

**File**: `ojt_booking_web/lib/services/api_service.dart`

```dart
Future<List<Location>> getLocations() async {
  const url = '$baseUrl/locations';  // http://localhost:5000/api/locations
  
  try {
    // Make HTTP GET request to backend
    final response = await http.get(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'}
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      // Parse JSON response
      final List<dynamic> data = json.decode(response.body);
      
      // Convert each JSON object to Location model
      return data.map((json) => Location.fromJson(json)).toList();
    }
  } catch (e) {
    // If API fails, use mock data
    return getMockLocations();
  }
}
```

**File**: `ojt_booking_web/lib/controllers/booking_controller.dart`

```dart
Future<void> showLocationPicker({
  required BuildContext context,
  required String type,  // 'origin' or 'destination'
  required Function(String, int, String) onSelect,
}) async {
  // Call API service to get locations
  final locations = await _apiService.getLocations();
  
  // Show modal dialog with the locations
  await showDialog(
    context: context,
    builder: (context) {
      // Build UI with search, filter, pagination
      // Display locations in a list
    }
  );
}
```

**File**: `ojt_booking_web/lib/views/booking_page.dart`

```dart
_buildSearchField(
  label: 'Origin',
  value: selectedOrigin,
  onTap: () {
    // User clicks the Origin field
    _controller.showLocationPicker(
      context: context,
      type: 'origin',
      onSelect: (locationDesc, locationId, locationType) {
        setState(() {
          selectedOrigin = locationDesc;      // "BACOLOD PORT (VISBCD)"
          selectedOriginId = locationId;      // 3
          selectedOriginType = locationType;  // "Port"
        });
      },
    );
  },
)
```

---

## 2. VESSEL PICKER

### Database Tables
- **Vessel** table: Contains VesselId, VesselCd, VesselDesc

### Backend Flow

**File**: `booking_api/Controllers/VesselsController.cs`

```csharp
[HttpGet]
public async Task<ActionResult<IEnumerable<Vessel>>> GetVessels()
{
    // Simple query - no joins needed
    return await _context.Vessels
        .OrderBy(v => v.VesselDesc)  // Sort alphabetically
        .ToListAsync();
}
```

**SQL Query Generated:**
```sql
SELECT VesselId, VesselCd, VesselDesc
FROM Vessel
ORDER BY VesselDesc
```

### Frontend Flow

Same pattern as Location picker:
1. `api_service.dart` calls `GET /api/vessels`
2. Converts JSON to `Vessel` model objects
3. `booking_controller.dart` shows modal with vessel list
4. User selects vessel, stores `vesselId` and `vesselDesc`

---

## 3. EQUIPMENT TYPE PICKER

### Database Tables
- **Equipment** table: Contains EquipmentId, EquipmentCd, EquipmentDesc

### Backend Flow

**File**: `booking_api/Controllers/EquipmentController.cs`

```csharp
[HttpGet]
public async Task<ActionResult<IEnumerable<Equipment>>> GetEquipment()
{
    return await _context.Equipment
        .OrderBy(e => e.EquipmentDesc)
        .ToListAsync();
}
```

### Frontend Flow
Same pattern - API call → Model conversion → Modal display → Selection

---

## 4. COMMODITY PICKER

### Database Tables
- **Commodity** table: Contains CommodityId, CommodityCd, CommodityDesc

### Backend Flow

**File**: `booking_api/Controllers/CommoditiesController.cs`

```csharp
[HttpGet]
public async Task<ActionResult<IEnumerable<Commodity>>> GetCommodities()
{
    return await _context.Commodities
        .OrderBy(c => c.CommodityDesc)
        .ToListAsync();
}
```

### Frontend Flow
- Has category filter (Commodity Name/Code)
- Search functionality
- Pagination (5 items per page)

---

## 5. CONTAINER NUMBER PICKER

### Database Tables
- **Container** table: Contains ContainerId, ContainerNo

### Backend Flow

**File**: `booking_api/Controllers/ContainersController.cs`

```csharp
[HttpGet]
public async Task<ActionResult<IEnumerable<object>>> GetContainers()
{
    // Returns mock data for now
    var containers = new[]
    {
        new { ContainerId = 1, ContainerNo = "CONT-001" },
        new { ContainerId = 2, ContainerNo = "CONT-002" },
        // ... more containers
    };
    return Ok(containers);
}
```

### Frontend Flow
- Simple 2-column layout (Checkbox, Container Number)
- No category dropdown
- Search by container number only

---

## 6. AGREEMENT PARTY PICKER

### Database Tables
- **Customer** table: Contains CustomerId, CustomerCd
- **CustomerType** table: Links CustomerId to PartyTypeId
- **CustomerInformation** table: Contains FirstName, MiddleName, LastName
- **PartyType** table: Contains PartyTypeId, PartyTypeDesc

### Backend Flow

**File**: `booking_api/Controllers/CustomersController.cs`

```csharp
[HttpGet("agreement-parties")]
public async Task<ActionResult<IEnumerable<object>>> GetAgreementParties()
{
    var query = @"
        SELECT 
            CAST(c.CustomerId AS INT) AS CustomerId,
            c.CustomerCd,
            ISNULL(ci.FirstName, '') AS FirstName,
            ISNULL(ci.MiddleName, '') AS MiddleName,
            ISNULL(ci.LastName, '') AS LastName,
            CAST(ct.PartyTypeId AS INT) AS PartyTypeId
        FROM dbo.Customer c
        INNER JOIN dbo.CustomerType ct ON c.CustomerId = ct.CustomerId
        INNER JOIN dbo.CustomerInformation ci ON c.CustomerId = ci.CustomerId
        WHERE ct.PartyTypeId = 10";  // Filter for Agreement Party
    
    var customers = await _context.Database
        .SqlQueryRaw<CustomerDto>(query)
        .ToListAsync();
    
    return Ok(customers);
}
```

**SQL Explanation:**
1. **JOIN Customer with CustomerType**: Links customer to their party type
2. **JOIN with CustomerInformation**: Gets customer's name details
3. **WHERE PartyTypeId = 10**: Filters only Agreement Party customers
4. **ISNULL()**: Converts NULL values to empty strings
5. **CAST to INT**: Converts smallint to int to avoid type mismatch

**Returns JSON:**
```json
[
  {
    "customerId": 1,
    "customerCd": "PHCEB2026020002",
    "firstName": "Fubar",
    "middleName": "",
    "lastName": "Philippines",
    "partyTypeId": 10
  }
]
```

### Frontend Flow

**File**: `ojt_booking_web/lib/models/customer_model.dart`

```dart
class Customer {
  final String firstName;
  final String middleName;
  final String lastName;
  
  // Computed property that combines names
  String get fullName {
    final parts = [firstName, middleName, lastName]
        .where((part) => part.isNotEmpty && part.toUpperCase() != 'NULL')
        .toList();
    return parts.join(' ');  // "Fubar Philippines" (skips empty middleName)
  }
}
```

**Display:**
- 3 columns: Checkbox, Customer Code, Customer Name
- Category filter: Customer Name or Customer Code
- Search functionality
- Pagination (5 items per page)

---

## 7. SHIPPER PARTY PICKER

### Database Tables
Same as Agreement Party (Customer, CustomerType, CustomerInformation)

### Backend Flow

**File**: `booking_api/Controllers/CustomersController.cs`

```csharp
[HttpGet("shipper-parties")]
public async Task<ActionResult<IEnumerable<object>>> GetShipperParties()
{
    // Same query as Agreement Party but with different filter
    WHERE ct.PartyTypeId = 11  // Filter for Shipper Party
}
```

**Key Difference:** Only the `PartyTypeId` filter changes (11 instead of 10)

---

## 8. CONSIGNEE PARTY PICKER

### Database Tables
Same as Agreement Party and Shipper Party

### Backend Flow

```csharp
[HttpGet("consignee-parties")]
public async Task<ActionResult<IEnumerable<object>>> GetConsigneeParties()
{
    WHERE ct.PartyTypeId = 12  // Filter for Consignee Party
}
```

**Key Difference:** PartyTypeId = 12

---

## 9. VESSEL SCHEDULE PICKER

### Database Tables
- **VesselSchedule** table: Contains VesselScheduleId, OriginPortId, DestinationPortId, ETD, ETA, VesselId
- **Port** table: For origin and destination port details
- **Vessel** table: For vessel details
- **Location** table: To map LocationId to PortId

### Backend Flow

**File**: `booking_api/Controllers/VesselSchedulesController.cs`

```csharp
[HttpGet]
public async Task<ActionResult<IEnumerable<object>>> GetVesselSchedules(
    [FromQuery] int? originLocationId = null,
    [FromQuery] int? destinationLocationId = null,
    [FromQuery] int? vesselId = null)
{
    // Step 1: Convert LocationId to PortId
    int? originPortId = null;
    if (originLocationId.HasValue)
    {
        var originLocation = await _context.Locations
            .Where(l => l.LocationId == originLocationId.Value)
            .Select(l => l.PortId)
            .FirstOrDefaultAsync();
        originPortId = originLocation;
    }
    
    // Step 2: Query vessel schedules with filters
    var query = @"
        SELECT 
            CAST(vs.VesselScheduleId AS INT) as VesselScheduleId,
            CAST(vs.OriginPortId AS INT) as OriginPortId,
            CAST(vs.DestinationPortId AS INT) as DestinationPortId,
            vs.ETD,
            vs.ETA,
            CAST(vs.VesselId AS INT) as VesselId,
            originPort.PortCd as OriginPortCd,
            originPort.PortDesc as OriginPortDesc,
            destPort.PortCd as DestinationPortCd,
            destPort.PortDesc as DestinationPortDesc,
            v.VesselCd,
            v.VesselDesc as VesselName
        FROM dbo.VesselSchedule vs
        INNER JOIN dbo.Port originPort ON vs.OriginPortId = originPort.PortId
        INNER JOIN dbo.Port destPort ON vs.DestinationPortId = destPort.PortId
        INNER JOIN dbo.Vessel v ON vs.VesselId = v.VesselId
        WHERE 1=1
        AND vs.OriginPortId = @p0
        AND vs.DestinationPortId = @p1
        AND vs.VesselId = @p2
        ORDER BY vs.ETD";
}
```

**Complex Flow Explanation:**

1. **User selects Origin**: Stores `LocationId = 3` (Bacolod Port)
2. **User selects Destination**: Stores `LocationId = 2` (Cebu Port)
3. **User selects Vessel**: Stores `VesselId = 1` (DON ALFONSO SR)
4. **User clicks Vessel Schedule field**:
   - Frontend sends: `originLocationId=3`, `destinationLocationId=2`, `vesselId=1`
5. **Backend receives request**:
   - Looks up Location table: LocationId 3 → PortId 1
   - Looks up Location table: LocationId 2 → PortId 2
6. **Backend queries VesselSchedule**:
   - Filters: `OriginPortId=1 AND DestinationPortId=2 AND VesselId=1`
   - JOINs with Port table to get port names
   - JOINs with Vessel table to get vessel name
7. **Returns matching schedules**

### Frontend Flow

**File**: `ojt_booking_web/lib/controllers/booking_controller.dart`

```dart
Future<void> showVesselSchedulePicker({
  required int originLocationId,
  required int destinationLocationId,
  required int vesselId,
}) async {
  // Call API with filters
  final schedules = await _apiService.getVesselSchedules(
    originLocationId: originLocationId,
    destinationLocationId: destinationLocationId,
    vesselId: vesselId,
  );
  
  // Format dates with timezone adjustment (+8 hours)
  final etdStr = schedule.etd != null
      ? () {
          final adjustedEtd = schedule.etd!.add(const Duration(hours: 8));
          return '${adjustedEtd.month}/${adjustedEtd.day}/${adjustedEtd.year} '
                 '${adjustedEtd.hour}:${adjustedEtd.minute}';
        }()
      : 'N/A';
  
  // Display in modal with 5 columns:
  // Checkbox | POL | POD | ETD | ETA
}
```

---

## Common Patterns Across All Pickers

### 1. Error Handling
```dart
try {
  // Try to call real API
  final response = await http.get(url);
  return parseResponse(response);
} catch (e) {
  // If API fails, use mock data
  return getMockData();
}
```

### 2. Model Conversion
```dart
// JSON from API
{"customerId": 1, "customerCd": "ABC"}

// Convert to Dart object
Customer.fromJson(json) {
  return Customer(
    customerId: json['customerId'],
    customerCd: json['customerCd'],
  );
}
```

### 3. Search & Filter
```dart
final filtered = items.where((item) {
  if (searchQuery.isEmpty) return true;
  return item.name.toLowerCase().contains(searchQuery.toLowerCase());
}).toList();
```

### 4. Pagination
```dart
const itemsPerPage = 5;
final startIndex = currentPage * itemsPerPage;
final endIndex = min(startIndex + itemsPerPage, items.length);
final paginated = items.sublist(startIndex, endIndex);
```

### 5. Selection & Callback
```dart
onSelect: (displayValue, id) {
  setState(() {
    selectedValue = displayValue;  // For display
    selectedId = id;               // For database
  });
}
```

---

## Data Flow Summary

1. **User Action**: Clicks a search field
2. **Frontend Controller**: Calls API service method
3. **API Service**: Makes HTTP GET request to backend
4. **Backend Controller**: Receives request
5. **Backend Query**: Executes SQL query (with JOINs if needed)
6. **Database**: Returns rows
7. **Backend**: Converts to JSON and sends response
8. **API Service**: Parses JSON to Dart models
9. **Controller**: Shows modal with data
10. **User**: Searches, filters, selects item
11. **Callback**: Returns selected value and ID to booking page
12. **State Update**: Updates UI with selected value

---

## Key Concepts

### Why Store Both Display Value and ID?
```dart
selectedOrigin = "BACOLOD PORT (VISBCD)";  // For showing to user
selectedOriginId = 3;                       // For saving to database
```

### Why Use CAST in SQL?
```sql
CAST(c.CustomerId AS INT)  -- Database has smallint, but C# expects int
```

### Why Add 8 Hours to Time?
```dart
adjustedEtd = schedule.etd!.add(const Duration(hours: 8));
// Database stores UTC time, we need UTC+8 (Philippine Time)
```

### Why Use ISNULL in SQL?
```sql
ISNULL(ci.MiddleName, '')  -- Convert NULL to empty string
// Prevents "NULL NULL" from appearing in customer names
```

---

## Troubleshooting Tips

1. **No data showing**: Check if backend API is running
2. **Type mismatch errors**: Use CAST in SQL queries
3. **NULL values showing**: Use ISNULL or COALESCE in SQL
4. **Wrong timezone**: Add/subtract hours in frontend
5. **Slow loading**: Check database indexes on foreign keys

---

This architecture follows the **Repository Pattern** and **Separation of Concerns** principles, making the code maintainable and testable.
