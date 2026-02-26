class Commodity {
  final int commodityId;
  final String commodityCd;
  final String commodityDesc;

  Commodity({
    required this.commodityId,
    required this.commodityCd,
    required this.commodityDesc,
  });

  factory Commodity.fromJson(Map<String, dynamic> json) {
    return Commodity(
      commodityId: (json['commodityId'] ?? json['CommodityId'] ?? 0) as int,
      commodityCd: json['commodityCd'] ?? json['CommodityCd'] ?? '',
      commodityDesc: json['commodityDesc'] ?? json['CommodityDesc'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'commodityId': commodityId,
      'commodityCd': commodityCd,
      'commodityDesc': commodityDesc,
    };
  }
}
