using System.ComponentModel.DataAnnotations;

namespace BookingApi.Models
{
    public class Status
    {
        [Key]
        public short StatusId { get; set; }
        public string? StatusCd { get; set; }
        public string? StatusDesc { get; set; }
        public string? CreateUserId { get; set; }
        public DateTime? CreateDttm { get; set; }
        public string? UpdateUserId { get; set; }
        public DateTime? UpdateDttm { get; set; }

        public ICollection<Booking>? Bookings { get; set; }
    }
}