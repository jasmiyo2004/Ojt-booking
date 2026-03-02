using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace BookingApi.Models
{
    [Table("BookingParty")]
    public class BookingParty
    {
        [Key]
        [Column(TypeName = "smallint")]
        public short BookingPartyId { get; set; }
        
        [Column(TypeName = "smallint")]
        public short? BookingId { get; set; }  // Booking.BookingId is smallint
        
        [Column(TypeName = "smallint")]
        public short? PartyTypeId { get; set; }
        
        [Column(TypeName = "smallint")]
        public short? CustomerId { get; set; }
        
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
