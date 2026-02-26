using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using BookingApi.Data;
using BookingApi.Models;

namespace BookingApi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class TransportServicesController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public TransportServicesController(ApplicationDbContext context)
        {
            _context = context;
        }

        // GET: api/TransportServices
        [HttpGet]
        public async Task<ActionResult<IEnumerable<TransportService>>> GetTransportServices()
        {
            return await _context.TransportServices
                .OrderBy(ts => ts.TransportServiceDesc)
                .ToListAsync();
        }

        // GET: api/TransportServices/5
        [HttpGet("{id}")]
        public async Task<ActionResult<TransportService>> GetTransportService(short id)
        {
            var transportService = await _context.TransportServices.FindAsync(id);

            if (transportService == null)
            {
                return NotFound();
            }

            return transportService;
        }
    }
}
