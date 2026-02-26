class VesselSchedule {
  final int vesselScheduleId;
  final int originPortId;
  final int destinationPortId;
  final DateTime? etd;
  final DateTime? eta;
  final int vesselId;
  final String originPortCd;
  final String originPortDesc;
  final String destinationPortCd;
  final String destinationPortDesc;
  final String vesselCd;
  final String vesselName;

  VesselSchedule({
    required this.vesselScheduleId,
    required this.originPortId,
    required this.destinationPortId,
    this.etd,
    this.eta,
    required this.vesselId,
    required this.originPortCd,
    required this.originPortDesc,
    required this.destinationPortCd,
    required this.destinationPortDesc,
    required this.vesselCd,
    required this.vesselName,
  });

  factory VesselSchedule.fromJson(Map<String, dynamic> json) {
    return VesselSchedule(
      vesselScheduleId: json['vesselScheduleId'] ?? 0,
      originPortId: json['originPortId'] ?? 0,
      destinationPortId: json['destinationPortId'] ?? 0,
      etd: json['etd'] != null ? DateTime.parse(json['etd']) : null,
      eta: json['eta'] != null ? DateTime.parse(json['eta']) : null,
      vesselId: json['vesselId'] ?? 0,
      originPortCd: json['originPortCd'] ?? '',
      originPortDesc: json['originPortDesc'] ?? '',
      destinationPortCd: json['destinationPortCd'] ?? '',
      destinationPortDesc: json['destinationPortDesc'] ?? '',
      vesselCd: json['vesselCd'] ?? '',
      vesselName: json['vesselName'] ?? '',
    );
  }

  String get pol => '$originPortCd - $originPortDesc';
  String get pod => '$destinationPortCd - $destinationPortDesc';

  String get etdFormatted {
    if (etd == null) return 'N/A';
    return '${etd!.year}-${etd!.month.toString().padLeft(2, '0')}-${etd!.day.toString().padLeft(2, '0')}';
  }

  String get etaFormatted {
    if (eta == null) return 'N/A';
    return '${eta!.year}-${eta!.month.toString().padLeft(2, '0')}-${eta!.day.toString().padLeft(2, '0')}';
  }
}
