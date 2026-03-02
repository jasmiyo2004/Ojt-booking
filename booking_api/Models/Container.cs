using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace BookingApi.Models
{
    [Table("Container")]
    public class Container
    {
        [Key]
        [Column(TypeName = "smallint")]
        public short ContainerId { get; set; }
        
        public string ContainerNo { get; set; } = string.Empty;
        
        [Column(TypeName = "smallint")]
        public short? ContainerStatusId { get; set; }
        
        [Column(TypeName = "smallint")]
        public short? StatusId { get; set; }
        
        public string? CreateUserId { get; set; }
        public DateTime? CreateDttm { get; set; }
        public string? UpdateUserId { get; set; }
        public DateTime? UpdateDttm { get; set; }
    }
}
