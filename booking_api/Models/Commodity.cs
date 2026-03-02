using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace BookingApi.Models
{
    [Table("Commodity")]
    public class Commodity
    {
        [Key]
        [Column("CommodityId", TypeName = "smallint")]
        public short CommodityId { get; set; }
        
        [Column("CommodityCd")]
        public string? CommodityCd { get; set; }
        
        [Column("CommodityDesc")]
        public string? CommodityDesc { get; set; }
        
        [Column("CommodityTypeId", TypeName = "smallint")]
        public short? CommodityTypeId { get; set; }
        
        [Column(TypeName = "smallint")]
        public short? StatusId { get; set; }
        public string? CreateUserId { get; set; }
        public DateTime? CreateDttm { get; set; }
        public string? UpdateUserId { get; set; }
        public DateTime? UpdateDttm { get; set; }
    }
}
