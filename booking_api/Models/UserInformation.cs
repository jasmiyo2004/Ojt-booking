using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace BookingApi.Models
{
    [Table("UserInformation")]
    public class UserInformation
    {
        [Key]
        public short UserInformationId { get; set; }  // smallint in database
        
        public string? FirstName { get; set; }
        public string? MiddleName { get; set; }
        public string? LastName { get; set; }
        public string? Email { get; set; }
        public string? Number { get; set; }  // nvarchar(50) in database
        public string? UserCode { get; set; }
        public short? StatusId { get; set; }  // smallint in database
        
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
