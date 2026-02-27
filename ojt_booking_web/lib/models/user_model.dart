class User {
  final int userId;
  final int? userIdType;
  final int? userInformationId;
  final String? userTypeDesc;
  final String? userTypeCd;
  final String? firstName;
  final String? middleName;
  final String? lastName;
  final String? email;
  final String? number;
  final String? userCode;
  final int? statusId;
  final String? statusDesc;
  final String? remarks;
  final String? createUserId;
  final DateTime? createDttm;
  final String? updateUserId;
  final DateTime? updateDttm;

  User({
    required this.userId,
    this.userIdType,
    this.userInformationId,
    this.userTypeDesc,
    this.userTypeCd,
    this.firstName,
    this.middleName,
    this.lastName,
    this.email,
    this.number,
    this.userCode,
    this.statusId,
    this.statusDesc,
    this.remarks,
    this.createUserId,
    this.createDttm,
    this.updateUserId,
    this.updateDttm,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'] ?? 0,
      userIdType: json['userIdType'],
      userInformationId: json['userInformationId'],
      userTypeDesc: json['userTypeDesc'],
      userTypeCd: json['userTypeCd'],
      firstName: json['firstName'],
      middleName: json['middleName'],
      lastName: json['lastName'],
      email: json['email'],
      number: json['number']?.toString(), // Convert number (bigint) to string
      userCode: json['userCode'],
      statusId: json['statusId'],
      statusDesc: json['statusDesc'],
      remarks: json['remarks'],
      createUserId: json['createUserId'],
      createDttm: json['createDttm'] != null
          ? DateTime.parse(json['createDttm'])
          : null,
      updateUserId: json['updateUserId'],
      updateDttm: json['updateDttm'] != null
          ? DateTime.parse(json['updateDttm'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userIdType': userIdType,
      'userInformationId': userInformationId,
      'userTypeDesc': userTypeDesc,
      'userTypeCd': userTypeCd,
      'firstName': firstName,
      'middleName': middleName,
      'lastName': lastName,
      'email': email,
      'number': number,
      'userCode': userCode,
      'statusId': statusId,
      'statusDesc': statusDesc,
      'remarks': remarks,
      'createUserId': createUserId,
      'createDttm': createDttm?.toIso8601String(),
      'updateUserId': updateUserId,
      'updateDttm': updateDttm?.toIso8601String(),
    };
  }

  String get fullName {
    final parts = [
      firstName,
      middleName,
      lastName,
    ].where((part) => part != null && part.isNotEmpty).toList();
    return parts.join(' ');
  }

  // Helper getters for backward compatibility
  String get username => userCode ?? '';
  String get password => ''; // Password not exposed from backend
  bool get isActive => statusDesc == 'Active';
  String get statusText => statusDesc ?? 'Unknown';
  String get userType => userTypeDesc ?? 'User';

  // Get initials for avatar
  String get initials {
    final first = firstName?.substring(0, 1) ?? '';
    final last = lastName?.substring(0, 1) ?? '';
    return '$first$last'.toUpperCase();
  }

  // CopyWith method for updating user data
  User copyWith({
    int? userId,
    int? userIdType,
    int? userInformationId,
    String? userTypeDesc,
    String? userTypeCd,
    String? firstName,
    String? middleName,
    String? lastName,
    String? email,
    String? number,
    String? userCode,
    int? statusId,
    String? statusDesc,
    String? remarks,
    String? createUserId,
    DateTime? createDttm,
    String? updateUserId,
    DateTime? updateDttm,
  }) {
    return User(
      userId: userId ?? this.userId,
      userIdType: userIdType ?? this.userIdType,
      userInformationId: userInformationId ?? this.userInformationId,
      userTypeDesc: userTypeDesc ?? this.userTypeDesc,
      userTypeCd: userTypeCd ?? this.userTypeCd,
      firstName: firstName ?? this.firstName,
      middleName: middleName ?? this.middleName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      number: number ?? this.number,
      userCode: userCode ?? this.userCode,
      statusId: statusId ?? this.statusId,
      statusDesc: statusDesc ?? this.statusDesc,
      remarks: remarks ?? this.remarks,
      createUserId: createUserId ?? this.createUserId,
      createDttm: createDttm ?? this.createDttm,
      updateUserId: updateUserId ?? this.updateUserId,
      updateDttm: updateDttm ?? this.updateDttm,
    );
  }
}
