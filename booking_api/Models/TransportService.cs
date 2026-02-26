using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace BookingApi.Models
{
    [Table("TransportService")]
    public class TransportService
    {
        [Key]
        [Column("TransportServiceId")]
        public short TransportServiceId { get; set; }
        
        [Column("TransportServiceDesc")]
        public string? TransportServiceDesc { get; set; }
        
        // Add other columns if they exist and are NOT NULL
        public short? StatusId { get; set; }
        public string? CreateUserId { get; set; }
        public DateTime? CreateDttm { get; set; }
        public string? UpdateUserId { get; set; }
        public DateTime? UpdateDttm { get; set; }
    }
}
