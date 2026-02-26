using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace BookingApi.Models
{
    public class Location
    {
        [Key]
        public short LocationId { get; set; }
        public string? LocationCd { get; set; }
        public string? LocationDesc { get; set; }
        public short? PortId { get; set; }
        public short? LocationTypeId { get; set; }
        public short? StatusId { get; set; }
        public string? CreateUserId { get; set; }
        public DateTime? CreateDttm { get; set; }
        public string? UpdateUserId { get; set; }
        public DateTime? UpdateDttm { get; set; }

        [ForeignKey("PortId")]
        public Port? Port { get; set; }

        [ForeignKey("LocationTypeId")]
        public LocationType? LocationType { get; set; }

        public ICollection<Booking>? OriginBookings { get; set; }
        public ICollection<Booking>? DestinationBookings { get; set; }
    }
}