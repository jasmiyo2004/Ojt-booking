# Booking Table Column Name Fix

## Issue Found

The C# Booking model had incorrect column names that didn't match the database:

### Database (Correct):
- `ContainerId` (smallint) - FK to Container table
- `SealNumber` (nvarchar(50))

### Model (Was Incorrect):
- `ContainerNumber` (string) ❌
- `Seal` (string) ❌

## Fix Applied

Updated `booking_api/Models/Booking.cs`:

```csharp
// Changed from:
public string? ContainerNumber { get; set; }
public string? Seal { get; set; }

// To:
public short? ContainerId { get; set; }
public string? SealNumber { get; set; }

// Added navigation property:
[ForeignKey("ContainerId")]
public Container? Container { get; set; }
```

## Why This Matters

- `ContainerId` is a **foreign key** to the Container table (stores container ID, not the number itself)
- `SealNumber` is the seal number as a string
- The Container table has the actual `ContainerNo` field

## Database Structure

```
Booking Table
├─ ContainerId (smallint) ──> Container.ContainerId
│                              └─ ContainerNo (actual container number)
└─ SealNumber (nvarchar(50)) - Seal number string
```

## Testing

### Step 1: Restart API
After the model change, restart your API:
```bash
cd booking_api
dotnet run
```

### Step 2: Test Booking Creation
1. Open your app
2. Go to Booking page
3. Fill in all fields
4. Click "Book"
5. Check for success message

### Step 3: Verify in Database
Run `TEST_BOOKING_SAVE.sql` to check:
- Booking was created
- All fields are populated
- Foreign keys are correct
- No NULL values where they shouldn't be

## Expected Booking Data

When you create a booking, the database should have:

```
BookingId: 1
BookingNo: "BK-2026-001"
StatusId: 4 (BOOKED)
OriginLocationId: (selected origin)
DestinationLocationId: (selected destination)
TransportServiceId: (selected service)
VesselId: (selected vessel)
VesselScheduleId: (selected schedule)
EquipmentId: (selected equipment)
CommodityId: (selected commodity)
Weight: (entered weight)
DeclaredValue: (entered value)
CargoDescription: (entered description)
ContainerId: (selected container ID)
SealNumber: (entered seal number)
PaymentModeId: (selected payment mode)
Trucker: (entered trucker)
PlateNumber: (entered plate)
Driver: (entered driver)
CreateUserId: "SYSTEM"
CreateDttm: (current datetime)
```

## Verification Queries

### Check if bookings exist:
```sql
SELECT COUNT(*) FROM dbo.Booking;
```

### View all bookings with details:
```sql
SELECT 
    b.BookingId,
    b.BookingNo,
    s.StatusDesc,
    ol.LocationDesc AS Origin,
    dl.LocationDesc AS Destination,
    v.VesselName,
    cont.ContainerNo,
    b.SealNumber,
    b.CreateDttm
FROM dbo.Booking b
LEFT JOIN dbo.Status s ON b.StatusId = s.StatusId
LEFT JOIN dbo.Location ol ON b.OriginLocationId = ol.LocationId
LEFT JOIN dbo.Location dl ON b.DestinationLocationId = dl.LocationId
LEFT JOIN dbo.Vessel v ON b.VesselId = v.VesselId
LEFT JOIN dbo.Container cont ON b.ContainerId = cont.ContainerId
ORDER BY b.CreateDttm DESC;
```

### Check for NULL values:
```sql
SELECT 
    BookingId,
    CASE WHEN ContainerId IS NULL THEN 'MISSING' ELSE 'OK' END AS ContainerId,
    CASE WHEN SealNumber IS NULL THEN 'MISSING' ELSE 'OK' END AS SealNumber
FROM dbo.Booking;
```

## Common Issues

### Issue 1: "ContainerNumber not found"
**Cause:** Old model used `ContainerNumber` instead of `ContainerId`
**Fix:** Model updated ✅

### Issue 2: "Seal not found"
**Cause:** Old model used `Seal` instead of `SealNumber`
**Fix:** Model updated ✅

### Issue 3: Container number not showing
**Cause:** Need to join with Container table to get ContainerNo
**Fix:** Use the verification query above that joins with Container table

## Files Modified

- `booking_api/Models/Booking.cs` - Fixed column names
- `TEST_BOOKING_SAVE.sql` - Created verification script
- `CHECK_BOOKING_TABLE_STRUCTURE.sql` - Created structure check script

## Next Steps

1. ✅ Model updated to match database
2. ⏳ Restart API
3. ⏳ Test booking creation
4. ⏳ Run TEST_BOOKING_SAVE.sql to verify
5. ⏳ Check that all fields are saved correctly

The booking model now matches your database structure exactly!
