using System.ComponentModel.DataAnnotations;

namespace BookingApi.Models
{
    public class Vessel
    {
        [Key]
        public short VesselId { get; set; }
        public string? VesselCd { get; set; }
        public string? VesselDesc { get; set; }
        public short? StatusId { get; set; }
        public string? CreateUserId { get; set; }
        public DateTime? CreateDttm { get; set; }
        public string? UpdateUserId { get; set; }
        public DateTime? UpdateDttm { get; set; }

        public ICollection<VesselSchedule>? VesselSchedules { get; set; }
    }
}