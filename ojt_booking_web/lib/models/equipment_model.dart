class Equipment {
  final int equipmentId;
  final String equipmentCd;
  final String equipmentDesc;

  Equipment({
    required this.equipmentId,
    required this.equipmentCd,
    required this.equipmentDesc,
  });

  factory Equipment.fromJson(Map<String, dynamic> json) {
    return Equipment(
      equipmentId: json['equipmentId'] ?? json['EquipmentId'] ?? 0,
      equipmentCd: json['equipmentCd'] ?? json['EquipmentCd'] ?? '',
      equipmentDesc: json['equipmentDesc'] ?? json['EquipmentDesc'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'equipmentId': equipmentId,
      'equipmentCd': equipmentCd,
      'equipmentDesc': equipmentDesc,
    };
  }
}
