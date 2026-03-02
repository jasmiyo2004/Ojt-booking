using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace BookingApi.Models
{
    [Table("TransportService")]
    public class TransportService
    {
        [Key]
        [Column("TransportServiceId", TypeName = "smallint")]
        public short TransportServiceId { get; set; }
        
        [Column("TransportServiceDesc")]
        public string? TransportServiceDesc { get; set; }
        
        [Column(TypeName = "smallint")]
        public short? StatusId { get; set; }
        public string? CreateUserId { get; set; }
        public DateTime? CreateDttm { get; set; }
        public string? UpdateUserId { get; set; }
        public DateTime? UpdateDttm { get; set; }
    }
}
