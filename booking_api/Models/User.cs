using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace BookingApi.Models
{
    [Table("User")]
    public class User
    {
        [Key]
        public short UserId { get; set; }  // smallint in database
        
        [Column("UserTypeId")]
        public short? UserIdType { get; set; }  // smallint in database
        
        public short? UserInformationId { get; set; }  // smallint in database
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
