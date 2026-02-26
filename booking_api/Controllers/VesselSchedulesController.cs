using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using BookingApi.Data;
using BookingApi.Models;

namespace BookingApi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class VesselSchedulesController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public VesselSchedulesController(ApplicationDbContext context)
        {
            _context = context;
        }

        // GET: api/VesselSchedules?originLocationId=1&destinationLocationId=2&vesselId=3
        [HttpGet]
        public async Task<ActionResult<IEnumerable<object>>> GetVesselSchedules(
            [FromQuery] int? originLocationId = null,
            [FromQuery] int? destinationLocationId = null,
            [FromQuery] int? vesselId = null)
        {
            try
            {
                // First, get the PortIds from the LocationIds
                int? originPortId = null;
                int? destinationPortId = null;

                if (originLocationId.HasValue)
                {
                    var originLocation = await _context.Locations
                        .Where(l => l.LocationId == originLocationId.Value)
                        .Select(l => l.PortId)
                        .FirstOrDefaultAsync();
                    originPortId = originLocation;
                }

                if (destinationLocationId.HasValue)
                {
                    var destinationLocation = await _context.Locations
                        .Where(l => l.LocationId == destinationLocationId.Value)
                        .Select(l => l.PortId)
                        .FirstOrDefaultAsync();
                    destinationPortId = destinationLocation;
                }

                var query = @"
                    SELECT 
                        CAST(vs.VesselScheduleId AS INT) as VesselScheduleId,
                        CAST(vs.OriginPortId AS INT) as OriginPortId,
                        CAST(vs.DestinationPortId AS INT) as DestinationPortId,
                        vs.ETD,
                        vs.ETA,
                        CAST(vs.VesselId AS INT) as VesselId,
                        originPort.PortCd as OriginPortCd,
                        originPort.PortDesc as OriginPortDesc,
                        destPort.PortCd as DestinationPortCd,
                        destPort.PortDesc as DestinationPortDesc,
                        v.VesselCd,
                        v.VesselDesc as VesselName
                    FROM dbo.VesselSchedule vs
                    INNER JOIN dbo.Port originPort ON vs.OriginPortId = originPort.PortId
                    INNER JOIN dbo.Port destPort ON vs.DestinationPortId = destPort.PortId
                    INNER JOIN dbo.Vessel v ON vs.VesselId = v.VesselId
                    WHERE 1=1";

                var parameters = new List<object>();

                if (originPortId.HasValue)
                {
                    query += " AND vs.OriginPortId = {0}";
                    parameters.Add(originPortId.Value);
                }

                if (destinationPortId.HasValue)
                {
                    query += destinationPortId.HasValue && originPortId.HasValue 
                        ? " AND vs.DestinationPortId = {1}" 
                        : " AND vs.DestinationPortId = {0}";
                    parameters.Add(destinationPortId.Value);
                }

                if (vesselId.HasValue)
                {
                    int paramIndex = parameters.Count;
                    query += $" AND vs.VesselId = {{{paramIndex}}}";
                    parameters.Add(vesselId.Value);
                }

                query += " ORDER BY vs.ETD";

                var schedules = await _context.Database
                    .SqlQueryRaw<VesselScheduleDetailDto>(query, parameters.ToArray())
                    .ToListAsync();

                return Ok(schedules);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Error retrieving vessel schedules", error = ex.Message });
            }
        }
    }

    // DTO for the query result
    public class VesselScheduleDetailDto
    {
        public int VesselScheduleId { get; set; }
        public int OriginPortId { get; set; }
        public int DestinationPortId { get; set; }
        public DateTime? ETD { get; set; }
        public DateTime? ETA { get; set; }
        public int VesselId { get; set; }
        public string OriginPortCd { get; set; } = string.Empty;
        public string OriginPortDesc { get; set; } = string.Empty;
        public string DestinationPortCd { get; set; } = string.Empty;
        public string DestinationPortDesc { get; set; } = string.Empty;
        public string VesselCd { get; set; } = string.Empty;
        public string VesselName { get; set; } = string.Empty;
    }
}
