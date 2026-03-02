using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace BookingApi.Models
{
    [Table("PaymentMode")]
    public class PaymentMode
    {
        [Key]
        [Column("PaymentModeId", TypeName = "smallint")]
        public short PaymentModeId { get; set; }
        
        [Column("PaymentModeDesc")]
        public string? PaymentModeDesc { get; set; }
        
        [Column(TypeName = "smallint")]
        public short? StatusId { get; set; }
        public string? CreateUserId { get; set; }
        public DateTime? CreateDttm { get; set; }
        public string? UpdateUserId { get; set; }
        public DateTime? UpdateDttm { get; set; }
    }
}
