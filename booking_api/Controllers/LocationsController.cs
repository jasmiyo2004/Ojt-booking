using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using BookingApi.Data;
using BookingApi.Models;

namespace BookingApi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class LocationsController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public LocationsController(ApplicationDbContext context)
        {
            _context = context;
        }

        // GET: api/Locations
        [HttpGet]
        public async Task<ActionResult<IEnumerable<object>>> GetLocations()
        {
            var locations = await _context.Locations
                .Include(l => l.LocationType)
                .OrderBy(l => l.LocationDesc)
                .Select(l => new
                {
                    l.LocationId,
                    l.LocationCd,
                    l.LocationDesc,
                    l.LocationTypeId,
                    LocationTypeDesc = l.LocationType != null ? l.LocationType.LocationTypeDesc : null
                })
                .ToListAsync();

            return Ok(locations);
        }

        // GET: api/Locations/5
        [HttpGet("{id}")]
        public async Task<ActionResult<object>> GetLocation(short id)
        {
            var location = await _context.Locations
                .Include(l => l.LocationType)
                .Where(l => l.LocationId == id)
                .Select(l => new
                {
                    l.LocationId,
                    l.LocationCd,
                    l.LocationDesc,
                    l.LocationTypeId,
                    LocationTypeDesc = l.LocationType != null ? l.LocationType.LocationTypeDesc : null
                })
                .FirstOrDefaultAsync();

            if (location == null)
            {
                return NotFound();
            }

            return location;
        }
    }
}
