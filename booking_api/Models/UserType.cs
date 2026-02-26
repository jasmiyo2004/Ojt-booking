using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace BookingApi.Models
{
    [Table("UserType")]
    public class UserType
    {
        [Key]
        public short UserTypeId { get; set; }
        
        public string? UserTypeCd { get; set; }
        public string? UserTypeDesc { get; set; }
        
        // Audit Fields
        public string? CreateUserId { get; set; }
        public DateTime? CreateDttm { get; set; }
        public string? UpdateUserId { get; set; }
        public DateTime? UpdateDttm { get; set; }
    }
}
