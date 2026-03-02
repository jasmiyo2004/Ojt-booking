namespace BookingApi.Models
{
    public class BookingDto
    {
        public int BookingId { get; set; }
        public string? BookingNo { get; set; }
        public int? StatusId { get; set; }
        public string? StatusDesc { get; set; }
        
        // Locations with IDs
        public int? OriginLocationId { get; set; }
        public string? OriginLocationDesc { get; set; }
        public int? DestinationLocationId { get; set; }
        public string? DestinationLocationDesc { get; set; }
        
        // Vessel & Schedule with IDs
        public int? VesselId { get; set; }
        public string? VesselDesc { get; set; }
        public VesselScheduleDto? VesselSchedule { get; set; }
        
        // Cargo with IDs
        public int? EquipmentId { get; set; }
        public string? EquipmentDesc { get; set; }
        public int? CommodityId { get; set; }
        public string? CommodityDesc { get; set; }
        public int? Weight { get; set; }
        public int? DeclaredValue { get; set; }
        public string? CargoDescription { get; set; }
        public int? ContainerId { get; set; }
        public string? ContainerNo { get; set; }
        public string? SealNumber { get; set; }
        
        // Parties
        public List<BookingPartyDto>? BookingParties { get; set; }
        
        // Payment & Trucking with IDs
        public int? PaymentModeId { get; set; }
        public string? PaymentModeDesc { get; set; }
        public string? Trucker { get; set; }
        public string? PlateNumber { get; set; }
        public string? Driver { get; set; }
        
        // Timestamps
        public DateTime? CreateDttm { get; set; }
        public DateTime? UpdateDttm { get; set; }
        public DateTime? CancelDttm { get; set; }
        public string? BKCancelRemarks { get; set; }
    }
    
    public class VesselScheduleDto
    {
        public int VesselScheduleId { get; set; }
        public string? VesselDesc { get; set; }
        public string? OriginPortDesc { get; set; }
        public string? DestinationPortDesc { get; set; }
        public DateTime? Etd { get; set; }
        public DateTime? Eta { get; set; }
    }
    
    public class BookingPartyDto
    {
        public int BookingPartyId { get; set; }
        public int? PartyTypeId { get; set; }
        public CustomerDto? Customer { get; set; }
    }
    
    public class CustomerDto
    {
        public int CustomerId { get; set; }
        public string? CustomerCd { get; set; }
        public string? FirstName { get; set; }
        public string? MiddleName { get; set; }
        public string? LastName { get; set; }
    }
}
