using System.ComponentModel.DataAnnotations;

namespace BookingApi.Models
{
    public class LocationType
    {
        [Key]
        public short LocationTypeId { get; set; }
        public string? LocationTypeDesc { get; set; }
        public short? StatusId { get; set; }
        public string? CreateUserId { get; set; }
        public DateTime? CreateDttm { get; set; }
        public string? UpdateUserId { get; set; }
        public DateTime? UpdateDttm { get; set; }

        public ICollection<Location>? Locations { get; set; }
    }
}
