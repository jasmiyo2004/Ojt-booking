using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace BookingApi.Models
{
    [Table("Equipment")]
    public class Equipment
    {
        [Key]
        [Column("EquipmentId")]
        public short EquipmentId { get; set; }
        
        [Column("EquipmentCd")]
        public string? EquipmentCd { get; set; }
        
        [Column("EquipmentDesc")]
        public string? EquipmentDesc { get; set; }
        
        // Add other columns if they exist and are NOT NULL
        public short? StatusId { get; set; }
        public string? CreateUserId { get; set; }
        public DateTime? CreateDttm { get; set; }
        public string? UpdateUserId { get; set; }
        public DateTime? UpdateDttm { get; set; }
    }
}
