class BookingStats {
  final int totalBookings;
  final int bookedToday;
  final int numberOfUsers;
  final int cancelled;

  BookingStats({
    required this.totalBookings,
    required this.bookedToday,
    required this.numberOfUsers,
    required this.cancelled,
  });

  // Convert JSON from API to BookingStats object
  factory BookingStats.fromJson(Map<String, dynamic> json) {
    return BookingStats(
      totalBookings: json['totalBookings'] ?? 0,
      bookedToday: json['bookedToday'] ?? 0,
      numberOfUsers: json['numberOfUsers'] ?? 0,
      cancelled:
          json['canceled'] ?? json['cancelled'] ?? 0, // Handle both spellings
    );
  }

  // Convert BookingStats object to JSON
  Map<String, dynamic> toJson() {
    return {
      'totalBookings': totalBookings,
      'bookedToday': bookedToday,
      'numberOfUsers': numberOfUsers,
      'cancelled': cancelled,
    };
  }
}
