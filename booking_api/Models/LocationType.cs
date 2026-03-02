using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace BookingApi.Models
{
    [Table("LocationType")]
    public class LocationType
    {
        [Key]
        [Column(TypeName = "smallint")]
        public short LocationTypeId { get; set; }
        
        public string? LocationTypeDesc { get; set; }
        
        [Column(TypeName = "smallint")]
        public short? StatusId { get; set; }
        
        public string? CreateUserId { get; set; }
        public DateTime? CreateDttm { get; set; }
        public string? UpdateUserId { get; set; }
        public DateTime? UpdateDttm { get; set; }

        public ICollection<Location>? Locations { get; set; }
    }
}
