using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace BookingApi.Models
{
    [Table("User")]
    public class User
    {
        [Key]
        public int UserId { get; set; }
        
        public short? UserIdType { get; set; }
        public int? UserInformationId { get; set; }
        public string? Remarks { get; set; }
        
        // Audit Fields
        public string? CreateUserId { get; set; }
        public DateTime? CreateDttm { get; set; }
        public string? UpdateUserId { get; set; }
        public DateTime? UpdateDttm { get; set; }

        // Navigation Properties
        [ForeignKey("UserInformationId")]
        public UserInformation? UserInformation { get; set; }
        
        [ForeignKey("UserIdType")]
        public UserType? UserType { get; set; }
    }
}
