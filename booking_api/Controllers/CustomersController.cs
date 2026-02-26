using Microsoft.AspNetCore.Mvc;
using BookingApi.Models;
using BookingApi.Data;
using Microsoft.EntityFrameworkCore;

namespace BookingApi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class CustomersController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public CustomersController(ApplicationDbContext context)
        {
            _context = context;
        }

        // GET: api/customers/agreement-parties
        [HttpGet("agreement-parties")]
        public async Task<ActionResult<IEnumerable<object>>> GetAgreementParties()
        {
            try
            {
                // Query to join Customer, CustomerType, and CustomerInformation tables
                // Filter for PartyTypeId = 10 (Agreement Party)
                var query = @"
                    SELECT 
                        CAST(c.CustomerId AS SMALLINT) AS CustomerId,
                        c.CustomerCd,
                        ISNULL(ci.FirstName, '') AS FirstName,
                        ISNULL(ci.MiddleName, '') AS MiddleName,
                        ISNULL(ci.LastName, '') AS LastName,
                        CAST(ct.PartyTypeId AS SMALLINT) AS PartyTypeId,
                        CASE 
                            WHEN ct.PartyTypeId = 10 THEN 'Agreement Party'
                            WHEN ct.PartyTypeId = 20 THEN 'Shipper Party'
                            WHEN ct.PartyTypeId = 30 THEN 'Consignee Party'
                            ELSE 'Unknown'
                        END AS PartyTypeDesc
                    FROM dbo.Customer c
                    INNER JOIN dbo.CustomerType ct ON c.CustomerId = ct.CustomerId
                    INNER JOIN dbo.CustomerInformation ci ON c.CustomerId = ci.CustomerId
                    WHERE ct.PartyTypeId = 10";

                var customers = await _context.Database
                    .SqlQueryRaw<CustomerPartyDto>(query)
                    .ToListAsync();

                return Ok(customers);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { error = ex.Message, stackTrace = ex.StackTrace });
            }
        }

        // GET: api/customers/shipper-parties
        [HttpGet("shipper-parties")]
        public async Task<ActionResult<IEnumerable<object>>> GetShipperParties()
        {
            try
            {
                var query = @"
                    SELECT 
                        CAST(c.CustomerId AS SMALLINT) AS CustomerId,
                        c.CustomerCd,
                        ISNULL(ci.FirstName, '') AS FirstName,
                        ISNULL(ci.MiddleName, '') AS MiddleName,
                        ISNULL(ci.LastName, '') AS LastName,
                        CAST(ct.PartyTypeId AS SMALLINT) AS PartyTypeId,
                        CASE 
                            WHEN ct.PartyTypeId = 10 THEN 'Agreement Party'
                            WHEN ct.PartyTypeId = 11 THEN 'Shipper Party'
                            WHEN ct.PartyTypeId = 12 THEN 'Consignee Party'
                            ELSE 'Unknown'
                        END AS PartyTypeDesc
                    FROM dbo.Customer c
                    INNER JOIN dbo.CustomerType ct ON c.CustomerId = ct.CustomerId
                    INNER JOIN dbo.CustomerInformation ci ON c.CustomerId = ci.CustomerId
                    WHERE ct.PartyTypeId = 11";

                var customers = await _context.Database
                    .SqlQueryRaw<CustomerPartyDto>(query)
                    .ToListAsync();

                return Ok(customers);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { error = ex.Message, stackTrace = ex.StackTrace });
            }
        }

        // GET: api/customers/consignee-parties
        [HttpGet("consignee-parties")]
        public async Task<ActionResult<IEnumerable<object>>> GetConsigneeParties()
        {
            try
            {
                var query = @"
                    SELECT 
                        CAST(c.CustomerId AS SMALLINT) AS CustomerId,
                        c.CustomerCd,
                        ISNULL(ci.FirstName, '') AS FirstName,
                        ISNULL(ci.MiddleName, '') AS MiddleName,
                        ISNULL(ci.LastName, '') AS LastName,
                        CAST(ct.PartyTypeId AS SMALLINT) AS PartyTypeId,
                        CASE 
                            WHEN ct.PartyTypeId = 10 THEN 'Agreement Party'
                            WHEN ct.PartyTypeId = 11 THEN 'Shipper Party'
                            WHEN ct.PartyTypeId = 12 THEN 'Consignee Party'
                            ELSE 'Unknown'
                        END AS PartyTypeDesc
                    FROM dbo.Customer c
                    INNER JOIN dbo.CustomerType ct ON c.CustomerId = ct.CustomerId
                    INNER JOIN dbo.CustomerInformation ci ON c.CustomerId = ci.CustomerId
                    WHERE ct.PartyTypeId = 12";

                var customers = await _context.Database
                    .SqlQueryRaw<CustomerPartyDto>(query)
                    .ToListAsync();

                return Ok(customers);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { error = ex.Message, stackTrace = ex.StackTrace });
            }
        }
    }

    // DTO for customer data from joined tables
    public class CustomerPartyDto
    {
        public short CustomerId { get; set; }
        public string CustomerCd { get; set; } = string.Empty;
        public string FirstName { get; set; } = string.Empty;
        public string MiddleName { get; set; } = string.Empty;
        public string LastName { get; set; } = string.Empty;
        public short PartyTypeId { get; set; }
        public string PartyTypeDesc { get; set; } = string.Empty;
    }
}
