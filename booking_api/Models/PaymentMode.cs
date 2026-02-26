using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace BookingApi.Models
{
    [Table("PaymentMode")]
    public class PaymentMode
    {
        [Key]
        [Column("PaymentModeId")]
        public short PaymentModeId { get; set; }
        
        [Column("PaymentModeDesc")]
        public string? PaymentModeDesc { get; set; }
        
        // Add other columns if they exist and are NOT NULL
        public short? StatusId { get; set; }
        public string? CreateUserId { get; set; }
        public DateTime? CreateDttm { get; set; }
        public string? UpdateUserId { get; set; }
        public DateTime? UpdateDttm { get; set; }
    }
}
