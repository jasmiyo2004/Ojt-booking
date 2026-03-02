using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace BookingApi.Models
{
    [Table("VesselSchedule")]
    public class VesselSchedule
    {
        [Key]
        [Column(TypeName = "smallint")]
        public short VesselScheduleId { get; set; }
        
        [Column(TypeName = "smallint")]
        public short? OriginPortId { get; set; }
        
        [Column(TypeName = "smallint")]
        public short? DestinationPortId { get; set; }
        
        public DateTime? ETD { get; set; }
        public DateTime? ETA { get; set; }
        
        [Column(TypeName = "smallint")]
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
