class UserType {
  final int userTypeId;
  final String? userTypeCd;
  final String? userTypeDesc;

  UserType({required this.userTypeId, this.userTypeCd, this.userTypeDesc});

  factory UserType.fromJson(Map<String, dynamic> json) {
    return UserType(
      userTypeId: json['userTypeId'] ?? 0,
      userTypeCd: json['userTypeCd'],
      userTypeDesc: json['userTypeDesc'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userTypeId': userTypeId,
      'userTypeCd': userTypeCd,
      'userTypeDesc': userTypeDesc,
    };
  }
}
