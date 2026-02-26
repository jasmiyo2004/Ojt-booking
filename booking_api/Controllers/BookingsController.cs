using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using BookingApi.Data;
using BookingApi.Models;
using System.Linq;

namespace BookingApi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class BookingsController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public BookingsController(ApplicationDbContext context)
        {
            _context = context;
        }

        // GET: api/Bookings
        [HttpGet]
        public async Task<ActionResult<IEnumerable<BookingDto>>> GetBookings()
        {
            try
            {
                var bookings = await _context.Bookings
                    .Include(b => b.Status)
                    .Include(b => b.OriginLocation)
                    .Include(b => b.DestinationLocation)
                    .Include(b => b.VesselSchedule)
                        .ThenInclude(vs => vs.Vessel)
                    .Include(b => b.VesselSchedule)
                        .ThenInclude(vs => vs.OriginPort)
                    .Include(b => b.VesselSchedule)
                        .ThenInclude(vs => vs.DestinationPort)
                    .Include(b => b.Equipment)
                    .Include(b => b.PaymentMode)
                    .Include(b => b.Commodity)
                    .Include(b => b.Vessel)
                    .Include(b => b.Container)
                    .Include(b => b.BookingParties)
                        .ThenInclude(bp => bp.Customer)
                    .OrderByDescending(b => b.CreateDttm)
                    .ThenByDescending(b => b.BookingId)
                    .ToListAsync();

                // Load CustomerInformation separately
                var customerIds = bookings
                    .SelectMany(b => b.BookingParties)
                    .Where(bp => bp.CustomerId.HasValue)
                    .Select(bp => bp.CustomerId!.Value)
                    .Distinct()
                    .ToList();

                var customerInfos = new Dictionary<short, CustomerInformation>();
                if (customerIds.Any())
                {
                    var infos = await _context.CustomerInformations
                        .Where(ci => ci.CustomerId.HasValue && customerIds.Contains(ci.CustomerId.Value))
                        .ToListAsync();
                    
                    foreach (var info in infos)
                    {
                        if (info.CustomerId.HasValue)
                        {
                            customerInfos[info.CustomerId.Value] = info;
                        }
                    }
                }

                // Map to DTOs
                var bookingDtos = bookings.Select(b => new BookingDto
                {
                    BookingId = b.BookingId,
                    BookingNo = b.BookingNo,
                    StatusId = b.StatusId,
                    StatusDesc = b.Status?.StatusDesc,
                    OriginLocationId = b.OriginLocationId,
                    OriginLocationDesc = b.OriginLocation?.LocationDesc,
                    DestinationLocationId = b.DestinationLocationId,
                    DestinationLocationDesc = b.DestinationLocation?.LocationDesc,
                    VesselId = b.VesselId,
                    VesselDesc = b.Vessel?.VesselDesc ?? b.VesselSchedule?.Vessel?.VesselDesc,
                    VesselSchedule = b.VesselSchedule == null ? null : new VesselScheduleDto
                    {
                        VesselScheduleId = b.VesselSchedule.VesselScheduleId,
                        VesselDesc = b.VesselSchedule.Vessel?.VesselDesc,
                        OriginPortDesc = b.VesselSchedule.OriginPort?.PortDesc,
                        DestinationPortDesc = b.VesselSchedule.DestinationPort?.PortDesc,
                        Etd = b.VesselSchedule.ETD,
                        Eta = b.VesselSchedule.ETA
                    },
                    EquipmentId = b.EquipmentId,
                    EquipmentDesc = b.Equipment?.EquipmentDesc,
                    CommodityId = b.CommodityId,
                    CommodityDesc = b.Commodity?.CommodityDesc,
                    Weight = b.Weight,
                    DeclaredValue = b.DeclaredValue,
                    CargoDescription = b.CargoDescription,
                    ContainerId = b.ContainerId,
                    ContainerNo = b.Container?.ContainerNo,
                    SealNumber = b.SealNumber,
                    BookingParties = b.BookingParties.Select(bp => new BookingPartyDto
                    {
                        BookingPartyId = bp.BookingPartyId,
                        PartyTypeId = bp.PartyTypeId,
                        Customer = bp.Customer == null ? null : new CustomerDto
                        {
                            CustomerId = bp.Customer.CustomerId,
                            CustomerCd = bp.Customer.CustomerCd,
                            FirstName = bp.CustomerId.HasValue && customerInfos.ContainsKey(bp.CustomerId.Value) 
                                ? customerInfos[bp.CustomerId.Value].FirstName 
                                : null,
                            MiddleName = bp.CustomerId.HasValue && customerInfos.ContainsKey(bp.CustomerId.Value) 
                                ? customerInfos[bp.CustomerId.Value].MiddleName 
                                : null,
                            LastName = bp.CustomerId.HasValue && customerInfos.ContainsKey(bp.CustomerId.Value) 
                                ? customerInfos[bp.CustomerId.Value].LastName 
                                : null
                        }
                    }).ToList(),
                    PaymentModeId = b.PaymentModeId,
                    PaymentModeDesc = b.PaymentMode?.PaymentModeDesc,
                    Trucker = b.Trucker,
                    PlateNumber = b.PlateNumber,
                    Driver = b.Driver,
                    CreateDttm = b.CreateDttm,
                    UpdateDttm = b.UpdateDttm
                }).ToList();

                return Ok(bookingDtos);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { error = ex.Message, innerError = ex.InnerException?.Message, stackTrace = ex.StackTrace });
            }
        }

        // GET: api/Bookings/5
        [HttpGet("{id}")]
        public async Task<ActionResult<Booking>> GetBooking(short id)
        {
            try
            {
                var booking = await _context.Bookings
                    .Include(b => b.Status)
                    .Include(b => b.OriginLocation)
                    .Include(b => b.DestinationLocation)
                    .Include(b => b.VesselSchedule)
                        .ThenInclude(vs => vs.Vessel)
                    .Include(b => b.VesselSchedule)
                        .ThenInclude(vs => vs.OriginPort)
                    .Include(b => b.VesselSchedule)
                        .ThenInclude(vs => vs.DestinationPort)
                    .Include(b => b.Equipment)
                    .Include(b => b.PaymentMode)
                    .Include(b => b.Commodity)
                    .Include(b => b.Vessel)
                    .Include(b => b.Container)
                    .Include(b => b.BookingParties)
                        .ThenInclude(bp => bp.Customer)
                    .FirstOrDefaultAsync(b => b.BookingId == id);

                if (booking == null)
                {
                    return NotFound();
                }

                // Load CustomerInformation for all customers in booking parties
                if (booking.BookingParties.Any())
                {
                    var customerIds = booking.BookingParties
                        .Where(bp => bp.CustomerId.HasValue)
                        .Select(bp => bp.CustomerId!.Value)
                        .Distinct()
                        .ToList();

                    if (customerIds.Any())
                    {
                        var customerInfos = await _context.CustomerInformations
                            .Where(ci => ci.CustomerId.HasValue && customerIds.Contains(ci.CustomerId.Value))
                            .ToListAsync();

                        foreach (var party in booking.BookingParties)
                        {
                            if (party.Customer != null && party.CustomerId.HasValue)
                            {
                                party.Customer.CustomerInformation = customerInfos
                                    .FirstOrDefault(ci => ci.CustomerId == party.CustomerId);
                            }
                        }
                    }
                }

                return booking;
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { error = ex.Message, innerError = ex.InnerException?.Message, stackTrace = ex.StackTrace });
            }
        }

        // GET: api/Bookings/stats
        [HttpGet("stats")]
        public async Task<ActionResult<object>> GetBookingStats()
        {
            var totalBookings = await _context.Bookings.CountAsync();
            var booked = await _context.Bookings.CountAsync(b => b.StatusId == 4); // BOOK status
            var completed = await _context.Bookings.CountAsync(b => b.StatusId == 3); // CONF status
            var canceled = await _context.Bookings.CountAsync(b => b.StatusId == 5); // CANCEL status

            return new
            {
                totalBookings,
                booked,
                completed,
                canceled
            };
        }

        // POST: api/Bookings
        [HttpPost]
        public async Task<ActionResult<Booking>> PostBooking(CreateBookingRequest request)
        {
            // Create the booking
            var booking = new Booking
            {
                BookingNo = request.BookingNo,
                StatusId = request.StatusId ?? 4, // Default to BOOKED
                TransportServiceId = request.TransportServiceId,
                OriginLocationId = request.OriginLocationId,
                DestinationLocationId = request.DestinationLocationId,
                VesselScheduleId = request.VesselScheduleId,
                EquipmentId = request.EquipmentId,
                PaymentModeId = request.PaymentModeId,
                CommodityId = request.CommodityId,
                VesselId = request.VesselId,
                DeclaredValue = request.DeclaredValue,
                CargoDescription = request.CargoDescription,
                Weight = request.Weight,
                ContainerId = request.ContainerId,
                SealNumber = request.SealNumber,
                Trucker = request.Trucker,
                PlateNumber = request.PlateNumber,
                Driver = request.Driver,
                CreateDttm = DateTime.UtcNow,
                UpdateDttm = DateTime.UtcNow,
                CreateUserId = request.CreateUserId ?? "SYSTEM",
                UpdateUserId = request.UpdateUserId ?? "SYSTEM"
            };

            _context.Bookings.Add(booking);
            await _context.SaveChangesAsync();

            // Create BookingParty records for the 3 parties
            var bookingParties = new List<BookingParty>();

            if (request.AgreementPartyId.HasValue)
            {
                bookingParties.Add(new BookingParty
                {
                    BookingId = booking.BookingId,
                    PartyTypeId = 10, // Agreement Party
                    CustomerId = request.AgreementPartyId.Value,
                    CreateUserId = "SYSTEM",
                    CreateDttm = DateTime.UtcNow,
                    UpdateUserId = "SYSTEM",
                    UpdateDttm = DateTime.UtcNow
                });
            }

            if (request.ShipperPartyId.HasValue)
            {
                bookingParties.Add(new BookingParty
                {
                    BookingId = booking.BookingId,
                    PartyTypeId = 11, // Shipper Party
                    CustomerId = request.ShipperPartyId.Value,
                    CreateUserId = "SYSTEM",
                    CreateDttm = DateTime.UtcNow,
                    UpdateUserId = "SYSTEM",
                    UpdateDttm = DateTime.UtcNow
                });
            }

            if (request.ConsigneePartyId.HasValue)
            {
                bookingParties.Add(new BookingParty
                {
                    BookingId = booking.BookingId,
                    PartyTypeId = 12, // Consignee Party
                    CustomerId = request.ConsigneePartyId.Value,
                    CreateUserId = "SYSTEM",
                    CreateDttm = DateTime.UtcNow,
                    UpdateUserId = "SYSTEM",
                    UpdateDttm = DateTime.UtcNow
                });
            }

            if (bookingParties.Any())
            {
                _context.BookingParties.AddRange(bookingParties);
                await _context.SaveChangesAsync();
            }

            return CreatedAtAction("GetBooking", new { id = booking.BookingId }, booking);
        }

        // PUT: api/Bookings/5
        [HttpPut("{id}")]
        public async Task<IActionResult> PutBooking(short id, [FromBody] CreateBookingRequest request)
        {
            var booking = await _context.Bookings
                .Include(b => b.BookingParties)
                .FirstOrDefaultAsync(b => b.BookingId == id);
            
            if (booking == null) return NotFound();

            // Update booking fields
            booking.BookingNo = request.BookingNo ?? booking.BookingNo;
            booking.StatusId = request.StatusId ?? booking.StatusId;
            booking.TransportServiceId = request.TransportServiceId ?? booking.TransportServiceId;
            booking.OriginLocationId = request.OriginLocationId ?? booking.OriginLocationId;
            booking.DestinationLocationId = request.DestinationLocationId ?? booking.DestinationLocationId;
            booking.PaymentModeId = request.PaymentModeId ?? booking.PaymentModeId;
            booking.EquipmentId = request.EquipmentId ?? booking.EquipmentId;
            booking.CommodityId = request.CommodityId ?? booking.CommodityId;
            booking.VesselId = request.VesselId ?? booking.VesselId;
            booking.VesselScheduleId = request.VesselScheduleId ?? booking.VesselScheduleId;
            booking.DeclaredValue = request.DeclaredValue ?? booking.DeclaredValue;
            booking.CargoDescription = request.CargoDescription ?? booking.CargoDescription;
            booking.Weight = request.Weight ?? booking.Weight;
            booking.ContainerId = request.ContainerId ?? booking.ContainerId;
            booking.SealNumber = request.SealNumber ?? booking.SealNumber;
            booking.Trucker = request.Trucker ?? booking.Trucker;
            booking.PlateNumber = request.PlateNumber ?? booking.PlateNumber;
            booking.Driver = request.Driver ?? booking.Driver;
            booking.UpdateUserId = request.UpdateUserId ?? "SYSTEM";
            booking.UpdateDttm = DateTime.UtcNow;

            // Update booking parties if provided
            if (request.AgreementPartyId.HasValue || request.ShipperPartyId.HasValue || request.ConsigneePartyId.HasValue)
            {
                // Remove existing booking parties
                _context.BookingParties.RemoveRange(booking.BookingParties);

                // Add new booking parties
                if (request.AgreementPartyId.HasValue)
                {
                    booking.BookingParties.Add(new BookingParty
                    {
                        BookingId = booking.BookingId,
                        PartyTypeId = 10, // Agreement Party
                        CustomerId = request.AgreementPartyId.Value
                    });
                }

                if (request.ShipperPartyId.HasValue)
                {
                    booking.BookingParties.Add(new BookingParty
                    {
                        BookingId = booking.BookingId,
                        PartyTypeId = 11, // Shipper Party
                        CustomerId = request.ShipperPartyId.Value
                    });
                }

                if (request.ConsigneePartyId.HasValue)
                {
                    booking.BookingParties.Add(new BookingParty
                    {
                        BookingId = booking.BookingId,
                        PartyTypeId = 12, // Consignee Party
                        CustomerId = request.ConsigneePartyId.Value
                    });
                }
            }

            _context.Bookings.Update(booking);
            await _context.SaveChangesAsync();

            // Return updated booking with navigation properties
            var refreshed = await _context.Bookings
                .Include(b => b.Status)
                .Include(b => b.OriginLocation)
                .Include(b => b.DestinationLocation)
                .Include(b => b.VesselSchedule)
                    .ThenInclude(vs => vs.Vessel)
                .Include(b => b.VesselSchedule)
                    .ThenInclude(vs => vs.OriginPort)
                .Include(b => b.VesselSchedule)
                    .ThenInclude(vs => vs.DestinationPort)
                .Include(b => b.Equipment)
                .Include(b => b.PaymentMode)
                .Include(b => b.Commodity)
                .Include(b => b.Vessel)
                .Include(b => b.Container)
                .Include(b => b.BookingParties)
                    .ThenInclude(bp => bp.Customer)
                .FirstOrDefaultAsync(b => b.BookingId == id);

            // Load CustomerInformation separately
            var customerIds = refreshed!.BookingParties
                .Where(bp => bp.CustomerId.HasValue)
                .Select(bp => bp.CustomerId!.Value)
                .Distinct()
                .ToList();

            var customerInfos = new Dictionary<short, CustomerInformation>();
            if (customerIds.Any())
            {
                var infos = await _context.CustomerInformations
                    .Where(ci => ci.CustomerId.HasValue && customerIds.Contains(ci.CustomerId.Value))
                    .ToListAsync();
                
                foreach (var info in infos)
                {
                    if (info.CustomerId.HasValue)
                    {
                        customerInfos[info.CustomerId.Value] = info;
                    }
                }
            }

            // Map to DTO
            var bookingDto = new BookingDto
            {
                BookingId = refreshed.BookingId,
                BookingNo = refreshed.BookingNo,
                StatusId = refreshed.StatusId,
                StatusDesc = refreshed.Status?.StatusDesc,
                OriginLocationId = refreshed.OriginLocationId,
                OriginLocationDesc = refreshed.OriginLocation?.LocationDesc,
                DestinationLocationId = refreshed.DestinationLocationId,
                DestinationLocationDesc = refreshed.DestinationLocation?.LocationDesc,
                VesselId = refreshed.VesselId,
                VesselDesc = refreshed.Vessel?.VesselDesc ?? refreshed.VesselSchedule?.Vessel?.VesselDesc,
                VesselSchedule = refreshed.VesselSchedule == null ? null : new VesselScheduleDto
                {
                    VesselScheduleId = refreshed.VesselSchedule.VesselScheduleId,
                    VesselDesc = refreshed.VesselSchedule.Vessel?.VesselDesc,
                    OriginPortDesc = refreshed.VesselSchedule.OriginPort?.PortDesc,
                    DestinationPortDesc = refreshed.VesselSchedule.DestinationPort?.PortDesc,
                    Etd = refreshed.VesselSchedule.ETD,
                    Eta = refreshed.VesselSchedule.ETA
                },
                EquipmentId = refreshed.EquipmentId,
                EquipmentDesc = refreshed.Equipment?.EquipmentDesc,
                CommodityId = refreshed.CommodityId,
                CommodityDesc = refreshed.Commodity?.CommodityDesc,
                Weight = refreshed.Weight,
                DeclaredValue = refreshed.DeclaredValue,
                CargoDescription = refreshed.CargoDescription,
                ContainerId = refreshed.ContainerId,
                ContainerNo = refreshed.Container?.ContainerNo,
                SealNumber = refreshed.SealNumber,
                BookingParties = refreshed.BookingParties.Select(bp => new BookingPartyDto
                {
                    BookingPartyId = bp.BookingPartyId,
                    PartyTypeId = bp.PartyTypeId,
                    Customer = bp.Customer == null ? null : new CustomerDto
                    {
                        CustomerId = bp.Customer.CustomerId,
                        CustomerCd = bp.Customer.CustomerCd,
                        FirstName = bp.CustomerId.HasValue && customerInfos.ContainsKey(bp.CustomerId.Value) 
                            ? customerInfos[bp.CustomerId.Value].FirstName 
                            : null,
                        MiddleName = bp.CustomerId.HasValue && customerInfos.ContainsKey(bp.CustomerId.Value) 
                            ? customerInfos[bp.CustomerId.Value].MiddleName 
                            : null,
                        LastName = bp.CustomerId.HasValue && customerInfos.ContainsKey(bp.CustomerId.Value) 
                            ? customerInfos[bp.CustomerId.Value].LastName 
                            : null
                    }
                }).ToList(),
                PaymentModeId = refreshed.PaymentModeId,
                PaymentModeDesc = refreshed.PaymentMode?.PaymentModeDesc,
                Trucker = refreshed.Trucker,
                PlateNumber = refreshed.PlateNumber,
                Driver = refreshed.Driver,
                CreateDttm = refreshed.CreateDttm,
                UpdateDttm = refreshed.UpdateDttm
            };

            return Ok(bookingDto);
        }

        // POST: api/Bookings/{id}/cancel
        [HttpPost("{id}/cancel")]
        public async Task<IActionResult> CancelBooking(short id, [FromBody] CancelRequest? req)
        {
            var booking = await _context.Bookings.FindAsync(id);
            if (booking == null) return NotFound();

            // Try to map to a "cancelled" status if such exists
            var cancelStatus = await _context.Statuses.FirstOrDefaultAsync(s => s.StatusDesc!.ToUpper().Contains("CANCEL"));
            if (cancelStatus != null)
            {
                booking.StatusId = cancelStatus.StatusId;
            }

            booking.UpdateDttm = DateTime.UtcNow;
            booking.UpdateUserId = req?.UserId ?? "SYSTEM";

            _context.Bookings.Update(booking);
            await _context.SaveChangesAsync();

            var refreshed = await _context.Bookings
                .Include(b => b.Status)
                .Include(b => b.OriginLocation)
                .Include(b => b.DestinationLocation)
                .Include(b => b.VesselSchedule).ThenInclude(vs => vs.Vessel)
                .FirstOrDefaultAsync(b => b.BookingId == id);

            return Ok(refreshed);
        }
    }

    public class CancelRequest
    {
        public string? UserId { get; set; }
        public string? Remarks { get; set; }
    }
}