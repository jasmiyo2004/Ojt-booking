using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace BookingApi.Models
{
    [Table("UserCredential")]
    public class UserCredential
    {
        [Key]
        public int UserCredentialId { get; set; }
        
        public int? UserId { get; set; }
        public string? Password { get; set; }
        
        // Audit Fields
        public string? CreateUserId { get; set; }
        public DateTime? CreateDttm { get; set; }
        public string? UpdateUserId { get; set; }
        public DateTime? UpdateDttm { get; set; }

        // Navigation Properties
        [ForeignKey("UserId")]
        public User? User { get; set; }
    }
}
