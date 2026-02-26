using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace BookingApi.Models
{
    public class BookingParty
    {
        [Key]
        public short BookingPartyId { get; set; }
        public short? BookingId { get; set; }
        public short? PartyTypeId { get; set; }
        public int? CustomerId { get; set; }
        
        public string? CreateUserId { get; set; }
        public DateTime? CreateDttm { get; set; }
        public string? UpdateUserId { get; set; }
        public DateTime? UpdateDttm { get; set; }

        [ForeignKey("BookingId")]
        public Booking? Booking { get; set; }

        [ForeignKey("CustomerId")]
        public Customer? Customer { get; set; }
    }
}
