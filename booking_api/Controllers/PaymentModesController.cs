using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using BookingApi.Data;
using BookingApi.Models;

namespace BookingApi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class PaymentModesController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public PaymentModesController(ApplicationDbContext context)
        {
            _context = context;
        }

        // GET: api/PaymentModes
        [HttpGet]
        public async Task<ActionResult<IEnumerable<PaymentMode>>> GetPaymentModes()
        {
            return await _context.PaymentModes
                .OrderBy(pm => pm.PaymentModeDesc)
                .ToListAsync();
        }

        // GET: api/PaymentModes/5
        [HttpGet("{id}")]
        public async Task<ActionResult<PaymentMode>> GetPaymentMode(short id)
        {
            var paymentMode = await _context.PaymentModes.FindAsync(id);

            if (paymentMode == null)
            {
                return NotFound();
            }

            return paymentMode;
        }
    }
}
