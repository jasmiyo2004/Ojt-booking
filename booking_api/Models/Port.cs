using System.ComponentModel.DataAnnotations;

namespace BookingApi.Models
{
    public class Port
    {
        [Key]
        public short PortId { get; set; }
        public string? PortCd { get; set; }
        public string? PortDesc { get; set; }
        public short? StatusId { get; set; }
        public string? CreateUserId { get; set; }
        public DateTime? CreateDttm { get; set; }
        public string? UpdateUserId { get; set; }
        public DateTime? UpdateDttm { get; set; }

        public ICollection<Location>? Locations { get; set; }
    }
}