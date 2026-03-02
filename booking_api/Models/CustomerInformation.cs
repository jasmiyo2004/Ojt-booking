using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace BookingApi.Models
{
    [Table("CustomerInformation")]
    public class CustomerInformation
    {
        [Key]
        [Column(TypeName = "smallint")]
        public short CustomerInformationId { get; set; }
        
        [Column(TypeName = "smallint")]
        public short? CustomerId { get; set; }
        
        public string? FirstName { get; set; }
        public string? MiddleName { get; set; }
        public string? LastName { get; set; }
        
        public string? CreateUserId { get; set; }
        public DateTime? CreateDttm { get; set; }
        public string? UpdateUserId { get; set; }
        public DateTime? UpdateDttm { get; set; }

        [ForeignKey("CustomerId")]
        public Customer? Customer { get; set; }
    }
}
