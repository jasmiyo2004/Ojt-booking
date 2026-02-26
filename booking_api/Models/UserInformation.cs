using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace BookingApi.Models
{
    [Table("UserInformation")]
    public class UserInformation
    {
        [Key]
        public int UserInformationId { get; set; }
        
        public string? FirstName { get; set; }
        public string? MiddleName { get; set; }
        public string? LastName { get; set; }
        public string? Email { get; set; }
        public string? Number { get; set; }
        public string? UserCode { get; set; }
        public short? StatusId { get; set; }
        
        // Audit Fields
        public string? CreateUserId { get; set; }
        public DateTime? CreateDttm { get; set; }
        public string? UpdateUserId { get; set; }
        public DateTime? UpdateDttm { get; set; }

        // Navigation Properties
        [ForeignKey("StatusId")]
        public Status? Status { get; set; }
    }
}
