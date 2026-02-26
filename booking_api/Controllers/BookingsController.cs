using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using BookingApi.Data;
using BookingApi.Models;

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
        public async Task<ActionResult<IEnumerable<Booking>>> GetBookings()
        {
            return await _context.Bookings
                .Include(b => b.Status)
                .Include(b => b.OriginLocation)
                .Include(b => b.DestinationLocation)
                .Include(b => b.VesselSchedule)
                    .ThenInclude(vs => vs.Vessel)
                .Include(b => b.Equipment)
                .Include(b => b.PaymentMode)
                .Include(b => b.Commodity)
                .Include(b => b.Vessel)
                .Include(b => b.Container)
                .ToListAsync();
        }

        // GET: api/Bookings/5
        [HttpGet("{id}")]
        public async Task<ActionResult<Booking>> GetBooking(short id)
        {
            var booking = await _context.Bookings
                .Include(b => b.Status)
                .Include(b => b.OriginLocation)
                .Include(b => b.DestinationLocation)
                .Include(b => b.VesselSchedule)
                    .ThenInclude(vs => vs.Vessel)
                .Include(b => b.Equipment)
                .Include(b => b.PaymentMode)
                .Include(b => b.Commodity)
                .Include(b => b.Vessel)
                .Include(b => b.Container)
                .FirstOrDefaultAsync(b => b.BookingId == id);

            if (booking == null)
            {
                return NotFound();
            }

            return booking;
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
        public async Task<ActionResult<Booking>> PostBooking(Booking booking)
        {
            // Set default values
            booking.CreateDttm = DateTime.UtcNow;
            booking.UpdateDttm = DateTime.UtcNow;
            booking.CreateUserId = "SYSTEM"; // You might want to get this from authentication
            booking.UpdateUserId = "SYSTEM";

            // Set default status if not provided (assume BOOKED = 4)
            if (booking.StatusId == null)
            {
                booking.StatusId = 4; // BOOKED status
            }

            _context.Bookings.Add(booking);
            await _context.SaveChangesAsync();

            return CreatedAtAction("GetBooking", new { id = booking.BookingId }, booking);
        }

        // PUT: api/Bookings/5
        [HttpPut("{id}")]
        public async Task<IActionResult> PutBooking(short id, Booking updated)
        {
            var booking = await _context.Bookings.FindAsync(id);
            if (booking == null) return NotFound();

            // Update allowed fields
            booking.BookingNo = updated.BookingNo ?? booking.BookingNo;
            booking.StatusId = updated.StatusId ?? booking.StatusId;
            booking.UpdateUserId = updated.UpdateUserId ?? booking.UpdateUserId;
            booking.UpdateDttm = DateTime.UtcNow;

            _context.Bookings.Update(booking);
            await _context.SaveChangesAsync();

            // Return updated booking with navigation properties
            var refreshed = await _context.Bookings
                .Include(b => b.Status)
                .Include(b => b.OriginLocation)
                .Include(b => b.DestinationLocation)
                .Include(b => b.VesselSchedule).ThenInclude(vs => vs.Vessel)
                .FirstOrDefaultAsync(b => b.BookingId == id);

            return Ok(refreshed);
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