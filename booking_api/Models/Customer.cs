using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace BookingApi.Models
{
    [Table("Customer")]
    public class Customer
    {
        [Key]
        [Column(TypeName = "smallint")]
        public short CustomerId { get; set; }
        
        public string CustomerCd { get; set; } = string.Empty;
        
        public string? CreateUserId { get; set; }
        public DateTime? CreateDttm { get; set; }
        public string? UpdateUserId { get; set; }
        public DateTime? UpdateDttm { get; set; }

        // Navigation property
        public CustomerInformation? CustomerInformation { get; set; }
    }
}
