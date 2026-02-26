class PaymentMode {
  final int paymentModeId;
  final String paymentModeDesc;

  PaymentMode({required this.paymentModeId, required this.paymentModeDesc});

  factory PaymentMode.fromJson(Map<String, dynamic> json) {
    return PaymentMode(
      paymentModeId: json['paymentModeId'] ?? json['PaymentModeId'] ?? 0,
      paymentModeDesc: json['paymentModeDesc'] ?? json['PaymentModeDesc'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'paymentModeId': paymentModeId, 'paymentModeDesc': paymentModeDesc};
  }
}
