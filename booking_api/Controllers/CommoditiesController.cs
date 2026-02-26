using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using BookingApi.Data;
using BookingApi.Models;

namespace BookingApi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class CommoditiesController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public CommoditiesController(ApplicationDbContext context)
        {
            _context = context;
        }

        // GET: api/Commodities
        [HttpGet]
        public async Task<ActionResult<IEnumerable<Commodity>>> GetCommodities()
        {
            return await _context.Commodities
                .OrderBy(c => c.CommodityDesc)
                .ToListAsync();
        }

        // GET: api/Commodities/5
        [HttpGet("{id}")]
        public async Task<ActionResult<Commodity>> GetCommodityById(short id)
        {
            var commodity = await _context.Commodities.FindAsync(id);

            if (commodity == null)
            {
                return NotFound();
            }

            return commodity;
        }
    }
}
