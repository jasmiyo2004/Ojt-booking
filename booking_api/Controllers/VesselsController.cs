using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using BookingApi.Data;
using BookingApi.Models;

namespace BookingApi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class VesselsController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public VesselsController(ApplicationDbContext context)
        {
            _context = context;
        }

        // GET: api/Vessels
        [HttpGet]
        public async Task<ActionResult<IEnumerable<Vessel>>> GetVessels()
        {
            return await _context.Vessels
                .OrderBy(v => v.VesselDesc)
                .ToListAsync();
        }

        // GET: api/Vessels/5
        [HttpGet("{id}")]
        public async Task<ActionResult<Vessel>> GetVesselById(short id)
        {
            var vessel = await _context.Vessels.FindAsync(id);

            if (vessel == null)
            {
                return NotFound();
            }

            return vessel;
        }
    }
}
