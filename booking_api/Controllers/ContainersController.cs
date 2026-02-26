using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using BookingApi.Data;
using BookingApi.Models;

namespace BookingApi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ContainersController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public ContainersController(ApplicationDbContext context)
        {
            _context = context;
        }

        // GET: api/containers
        [HttpGet]
        public async Task<ActionResult<IEnumerable<Container>>> GetContainers()
        {
            return await _context.Containers
                .Select(c => new Container { ContainerId = c.ContainerId, ContainerNo = c.ContainerNo })
                .OrderBy(c => c.ContainerNo)
                .ToListAsync();
        }

        // GET: api/containers/{id}
        [HttpGet("{id}")]
        public async Task<ActionResult<Container>> GetContainer(short id)
        {
            var container = await _context.Containers.FindAsync(id);

            if (container == null)
            {
                return NotFound();
            }

            return container;
        }
    }
}
