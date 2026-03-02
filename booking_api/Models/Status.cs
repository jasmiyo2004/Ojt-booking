using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace BookingApi.Models
{
    [Table("Status")]
    public class Status
    {
        [Key]
        [Column(TypeName = "smallint")]
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
