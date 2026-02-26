namespace BookingApi.Models
{
    public class BookingDto
    {
        public short BookingId { get; set; }
        public string? BookingNo { get; set; }
        public short? StatusId { get; set; }
        public string? StatusDesc { get; set; }
        
        // Locations with IDs
        public short? OriginLocationId { get; set; }
        public string? OriginLocationDesc { get; set; }
        public short? DestinationLocationId { get; set; }
        public string? DestinationLocationDesc { get; set; }
        
        // Vessel & Schedule with IDs
        public short? VesselId { get; set; }
        public string? VesselDesc { get; set; }
        public VesselScheduleDto? VesselSchedule { get; set; }
        
        // Cargo with IDs
        public short? EquipmentId { get; set; }
        public string? EquipmentDesc { get; set; }
        public short? CommodityId { get; set; }
        public string? CommodityDesc { get; set; }
        public int? Weight { get; set; }
        public int? DeclaredValue { get; set; }
        public string? CargoDescription { get; set; }
        public short? ContainerId { get; set; }
        public string? ContainerNo { get; set; }
        public string? SealNumber { get; set; }
        
        // Parties
        public List<BookingPartyDto>? BookingParties { get; set; }
        
        // Payment & Trucking with IDs
        public short? PaymentModeId { get; set; }
        public string? PaymentModeDesc { get; set; }
        public string? Trucker { get; set; }
        public string? PlateNumber { get; set; }
        public string? Driver { get; set; }
        
        // Timestamps
        public DateTime? CreateDttm { get; set; }
        public DateTime? UpdateDttm { get; set; }
    }
    
    public class VesselScheduleDto
    {
        public short VesselScheduleId { get; set; }
        public string? VesselDesc { get; set; }
        public string? OriginPortDesc { get; set; }
        public string? DestinationPortDesc { get; set; }
        public DateTime? Etd { get; set; }
        public DateTime? Eta { get; set; }
    }
    
    public class BookingPartyDto
    {
        public short BookingPartyId { get; set; }
        public short? PartyTypeId { get; set; }
        public CustomerDto? Customer { get; set; }
    }
    
    public class CustomerDto
    {
        public short CustomerId { get; set; }
        public string? CustomerCd { get; set; }
        public string? FirstName { get; set; }
        public string? MiddleName { get; set; }
        public string? LastName { get; set; }
    }
}
