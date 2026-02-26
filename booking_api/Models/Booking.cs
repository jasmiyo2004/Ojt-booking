using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace BookingApi.Models
{
    public class Booking
    {
        [Key]
        public short BookingId { get; set; }
        public string? BookingNo { get; set; }
        public short? StatusId { get; set; }
        public short? TransportServiceId { get; set; }
        public short? OriginLocationId { get; set; }
        public short? DestinationLocationId { get; set; }
        public short? VesselScheduleId { get; set; }
        public short? EquipmentId { get; set; }
        public short? PaymentModeId { get; set; }
        public short? CommodityId { get; set; }
        public short? VesselId { get; set; }
        
        public int? DeclaredValue { get; set; }
        public string? CargoDescription { get; set; }
        public int? Weight { get; set; }
        public short? ContainerId { get; set; }
        public string? SealNumber { get; set; }
        public string? Trucker { get; set; }
        public string? PlateNumber { get; set; }
        public string? Driver { get; set; }
        
        public string? CreateUserId { get; set; }
        public DateTime? CreateDttm { get; set; }
        public string? UpdateUserId { get; set; }
        public DateTime? UpdateDttm { get; set; }

        [ForeignKey("StatusId")]
        public Status? Status { get; set; }

        [ForeignKey("OriginLocationId")]
        public Location? OriginLocation { get; set; }

        [ForeignKey("DestinationLocationId")]
        public Location? DestinationLocation { get; set; }

        [ForeignKey("VesselScheduleId")]
        public VesselSchedule? VesselSchedule { get; set; }

        [ForeignKey("EquipmentId")]
        public Equipment? Equipment { get; set; }

        [ForeignKey("PaymentModeId")]
        public PaymentMode? PaymentMode { get; set; }

        [ForeignKey("CommodityId")]
        public Commodity? Commodity { get; set; }

        [ForeignKey("VesselId")]
        public Vessel? Vessel { get; set; }

        [ForeignKey("ContainerId")]
        public Container? Container { get; set; }

        // Navigation property for booking parties
        public ICollection<BookingParty> BookingParties { get; set; } = new List<BookingParty>();
    }
}