using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace BookingApi.Models
{
    public class VesselSchedule
    {
        [Key]
        public short VesselScheduleId { get; set; }
        public short? OriginPortId { get; set; }
        public short? DestinationPortId { get; set; }
        public DateTime? ETD { get; set; }
        public DateTime? ETA { get; set; }
        public short? VesselId { get; set; }
        public string? CreateUserId { get; set; }
        public DateTime? CreateDttm { get; set; }
        public string? UpdateUserId { get; set; }
        public DateTime? UpdateDttm { get; set; }

        [ForeignKey("OriginPortId")]
        public Port? OriginPort { get; set; }

        [ForeignKey("DestinationPortId")]
        public Port? DestinationPort { get; set; }

        [ForeignKey("VesselId")]
        public Vessel? Vessel { get; set; }

        public ICollection<Booking>? Bookings { get; set; }
    }
}