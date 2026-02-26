class Vessel {
  final int vesselId;
  final String vesselCd;
  final String vesselDesc;

  Vessel({
    required this.vesselId,
    required this.vesselCd,
    required this.vesselDesc,
  });

  factory Vessel.fromJson(Map<String, dynamic> json) {
    return Vessel(
      vesselId: (json['vesselId'] ?? json['VesselId'] ?? 0) as int,
      vesselCd: json['vesselCd'] ?? json['VesselCd'] ?? '',
      vesselDesc: json['vesselDesc'] ?? json['VesselDesc'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vesselId': vesselId,
      'vesselCd': vesselCd,
      'vesselDesc': vesselDesc,
    };
  }
}
