class ContainerData {
  final int containerId;
  final String containerNo;
  final String? containerType;
  final String? status;

  ContainerData({
    required this.containerId,
    required this.containerNo,
    this.containerType,
    this.status,
  });

  factory ContainerData.fromJson(Map<String, dynamic> json) {
    return ContainerData(
      containerId: (json['containerId'] ?? json['ContainerId'] ?? 0) as int,
      containerNo: json['containerNo'] ?? json['ContainerNo'] ?? '',
      containerType: json['containerType'] ?? json['ContainerType'],
      status: json['status'] ?? json['Status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'containerId': containerId,
      'containerNo': containerNo,
      'containerType': containerType,
      'status': status,
    };
  }
}
