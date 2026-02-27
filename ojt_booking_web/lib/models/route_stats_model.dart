class RouteStats {
  final String route;
  final String origin;
  final String destination;
  final int count;
  final double percentage;

  RouteStats({
    required this.route,
    required this.origin,
    required this.destination,
    required this.count,
    required this.percentage,
  });

  factory RouteStats.fromJson(Map<String, dynamic> json) {
    return RouteStats(
      route: json['route'] ?? '',
      origin: json['origin'] ?? '',
      destination: json['destination'] ?? '',
      count: json['count'] ?? 0,
      percentage: (json['percentage'] ?? 0).toDouble(),
    );
  }
}

class RouteStatsResponse {
  final String period;
  final DateTime startDate;
  final DateTime endDate;
  final int totalBookings;
  final List<RouteStats> routes;

  RouteStatsResponse({
    required this.period,
    required this.startDate,
    required this.endDate,
    required this.totalBookings,
    required this.routes,
  });

  factory RouteStatsResponse.fromJson(Map<String, dynamic> json) {
    return RouteStatsResponse(
      period: json['period'] ?? 'month',
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      totalBookings: json['totalBookings'] ?? 0,
      routes:
          (json['routes'] as List<dynamic>?)
              ?.map((r) => RouteStats.fromJson(r))
              .toList() ??
          [],
    );
  }
}
