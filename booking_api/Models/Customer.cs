namespace BookingApi.Models
{
    public class Customer
    {
        public int CustomerId { get; set; }
        public string CustomerCd { get; set; } = string.Empty;
        public string FirstName { get; set; } = string.Empty;
        public string MiddleName { get; set; } = string.Empty;
        public string LastName { get; set; } = string.Empty;
        public int PartyTypeId { get; set; }
        public string PartyTypeDesc { get; set; } = string.Empty;
    }
}
