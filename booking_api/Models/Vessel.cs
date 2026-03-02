using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace BookingApi.Models
{
    [Table("Vessel")]
    public class Vessel
    {
        [Key]
        [Column(TypeName = "smallint")]
        public short VesselId { get; set; }
        
        public string? VesselCd { get; set; }
        public string? VesselDesc { get; set; }
        
        [Column(TypeName = "smallint")]
        public short? StatusId { get; set; }
        
        public string? CreateUserId { get; set; }
        public DateTime? CreateDttm { get; set; }
        public string? UpdateUserId { get; set; }
        public DateTime? UpdateDttm { get; set; }

        public ICollection<VesselSchedule>? VesselSchedules { get; set; }
    }
}
