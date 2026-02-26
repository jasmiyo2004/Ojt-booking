class TransportService {
  final int transportServiceId;
  final String transportServiceDesc;

  TransportService({
    required this.transportServiceId,
    required this.transportServiceDesc,
  });

  factory TransportService.fromJson(Map<String, dynamic> json) {
    return TransportService(
      transportServiceId:
          json['transportServiceId'] ?? json['TransportServiceId'] ?? 0,
      transportServiceDesc:
          json['transportServiceDesc'] ?? json['TransportServiceDesc'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transportServiceId': transportServiceId,
      'transportServiceDesc': transportServiceDesc,
    };
  }
}
