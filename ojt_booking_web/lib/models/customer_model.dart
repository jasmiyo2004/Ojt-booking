class Customer {
  final int customerId;
  final String customerCd;
  final String firstName;
  final String middleName;
  final String lastName;
  final int partyTypeId;
  final String partyTypeDesc;

  Customer({
    required this.customerId,
    required this.customerCd,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.partyTypeId,
    required this.partyTypeDesc,
  });

  // Helper to get full name
  String get fullName {
    final parts = [
      firstName,
      middleName,
      lastName,
    ].where((part) => part.isNotEmpty && part.toUpperCase() != 'NULL').toList();
    return parts.join(' ');
  }

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      customerId: (json['customerId'] ?? json['CustomerId'] ?? 0) as int,
      customerCd: json['customerCd'] ?? json['CustomerCd'] ?? '',
      firstName: json['firstName'] ?? json['FirstName'] ?? '',
      middleName: json['middleName'] ?? json['MiddleName'] ?? '',
      lastName: json['lastName'] ?? json['LastName'] ?? '',
      partyTypeId: (json['partyTypeId'] ?? json['PartyTypeId'] ?? 0) as int,
      partyTypeDesc: json['partyTypeDesc'] ?? json['PartyTypeDesc'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'customerCd': customerCd,
      'firstName': firstName,
      'middleName': middleName,
      'lastName': lastName,
      'partyTypeId': partyTypeId,
      'partyTypeDesc': partyTypeDesc,
    };
  }
}
