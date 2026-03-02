using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace BookingApi.Models
{
    [Table("Port")]
    public class Port
    {
        [Key]
        [Column(TypeName = "smallint")]
        public short PortId { get; set; }
        
        public string? PortCd { get; set; }
        public string? PortDesc { get; set; }
        
        [Column(TypeName = "smallint")]
        public short? StatusId { get; set; }
        
        public string? CreateUserId { get; set; }
        public DateTime? CreateDttm { get; set; }
        public string? UpdateUserId { get; set; }
        public DateTime? UpdateDttm { get; set; }

        public ICollection<Location>? Locations { get; set; }
    }
}
