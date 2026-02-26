class Location {
  final int locationId;
  final String locationDesc;
  final String locationCD;
  final String? locationTypeDesc;

  Location({
    required this.locationId,
    required this.locationDesc,
    required this.locationCD,
    this.locationTypeDesc,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      locationId: json['locationId'] ?? json['LocationId'] ?? 0,
      locationDesc: json['locationDesc'] ?? json['LocationDesc'] ?? '',
      // Handle both LocationCD and LocationCd (case variations)
      locationCD:
          json['locationCD'] ??
          json['LocationCD'] ??
          json['locationCd'] ??
          json['LocationCd'] ??
          '',
      locationTypeDesc: json['locationTypeDesc'] ?? json['LocationTypeDesc'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'locationId': locationId,
      'locationDesc': locationDesc,
      'locationCD': locationCD,
      'locationTypeDesc': locationTypeDesc,
    };
  }

  // Helper method to display location in format: "CEBU PORT (VISCEB)"
  String get displayName => '$locationDesc ($locationCD)';
}
