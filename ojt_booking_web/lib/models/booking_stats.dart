class BookingStats {
  final int totalBookings;
  final int booked;
  final int completed;
  final int cancelled;

  BookingStats({
    required this.totalBookings,
    required this.booked,
    required this.completed,
    required this.cancelled,
  });

  // Convert JSON from API to BookingStats object
  factory BookingStats.fromJson(Map<String, dynamic> json) {
    return BookingStats(
      totalBookings: json['totalBookings'] ?? 0,
      booked: json['booked'] ?? 0,
      completed: json['completed'] ?? 0,
      cancelled: json['canceled'] ?? json['cancelled'] ?? 0, // Handle both spellings
    );
  }

  // Convert BookingStats object to JSON
  Map<String, dynamic> toJson() {
    return {
      'totalBookings': totalBookings,
      'booked': booked,
      'completed': completed,
      'cancelled': cancelled,
    };
  }
}
