class UserSession {
  static final UserSession _instance = UserSession._internal();
  factory UserSession() => _instance;
  UserSession._internal();

  // Current logged-in user data
  Map<String, dynamic>? _currentUser;

  // Getters
  Map<String, dynamic>? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  int? get userId => _currentUser?['userId'];
  int? get userTypeId => _currentUser?['userTypeId'];
  String? get userType => _currentUser?['userType'];
  String? get firstName => _currentUser?['firstName'];
  String? get middleName => _currentUser?['middleName'];
  String? get lastName => _currentUser?['lastName'];
  String? get email => _currentUser?['email'];
  String? get number => _currentUser?['number'];
  String? get userCode => _currentUser?['userCode'];
  String? get fullName => _currentUser?['fullName'];

  // Set user session after login
  void setUser(Map<String, dynamic> userData) {
    _currentUser = userData;
  }

  // Clear user session on logout
  void clearUser() {
    _currentUser = null;
  }

  // Get user initials for avatar
  String getInitials() {
    if (_currentUser == null) return '??';

    final first = firstName?.isNotEmpty == true ? firstName![0] : '';
    final last = lastName?.isNotEmpty == true ? lastName![0] : '';

    return '$first$last'.toUpperCase();
  }
}
