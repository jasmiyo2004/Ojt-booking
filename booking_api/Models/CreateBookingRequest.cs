namespace BookingApi.Models
{
    public class CreateBookingRequest
    {
        // Booking fields
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

        // Party IDs
        public int? AgreementPartyId { get; set; }  // CustomerId for Agreement Party (PartyTypeId = 10)
        public int? ShipperPartyId { get; set; }     // CustomerId for Shipper Party (PartyTypeId = 11)
        public int? ConsigneePartyId { get; set; }   // CustomerId for Consignee Party (PartyTypeId = 12)
    }
}
