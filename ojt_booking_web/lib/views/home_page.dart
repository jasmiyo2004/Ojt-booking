import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/booking_model.dart';
import '../models/booking_stats.dart';
import '../models/route_stats_model.dart';
import '../services/api_service.dart';
import 'history_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isCalendarExpanded = false;
  final ApiService _apiService = ApiService();
  bool _isLoading = true; // Add loading state

  // Data — loaded from API (defaults shown until API responds)
  BookingStats _stats = BookingStats(
    totalBookings: 0,
    bookedToday: 0,
    numberOfUsers: 0,
    cancelled: 0,
  );
  List<Booking> _recentBookings = [];

  // Route statistics data
  RouteStatsResponse? _routeStats;
  bool _isLoadingRoutes = true;
  String _selectedPeriod = 'month';
  DateTime? _customStartDate;
  DateTime? _customEndDate;
  bool _showAllRoutes = false; // Track if showing all routes or just top 3

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadRouteStats();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      print('HomePage: Loading dashboard data...');
      final stats = await _apiService.getBookingStats();
      final recent = await _apiService.getRecentBookings();
      print(
        'HomePage: Data loaded successfully. Stats: ${stats.totalBookings} total',
      );
      if (mounted) {
        setState(() {
          _stats = stats;
          _recentBookings = recent;
          _isLoading = false;
        });
      }
    } catch (e) {
      // Fallback to mock data when API fails
      print(
        'HomePage: Failed to load dashboard data from API, using mock data. Error: $e',
      );
      final mockStats = _apiService.getMockStats();
      final mockBookings = _apiService.getMockBookings();
      if (mounted) {
        setState(() {
          _stats = mockStats;
          _recentBookings = mockBookings.take(5).toList();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadRouteStats() async {
    setState(() {
      _isLoadingRoutes = true;
    });

    try {
      final stats = await _apiService.getRouteStatistics(
        period: _selectedPeriod,
        startDate: _customStartDate,
        endDate: _customEndDate,
      );
      if (mounted) {
        setState(() {
          _routeStats = stats;
          _isLoadingRoutes = false;
        });
      }
    } catch (e) {
      print('Failed to load route statistics: $e');
      if (mounted) {
        setState(() {
          _isLoadingRoutes = false;
        });
      }
    }
  }

  void _onPeriodChanged(String period) {
    setState(() {
      _selectedPeriod = period;
      _customStartDate = null;
      _customEndDate = null;
      _showAllRoutes = false; // Reset to show top 3 when period changes
    });
    _loadRouteStats();
  }

  Future<void> _selectCustomDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _customStartDate != null && _customEndDate != null
          ? DateTimeRange(start: _customStartDate!, end: _customEndDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _selectedPeriod = 'custom';
        _customStartDate = picked.start;
        _customEndDate = picked.end;
        _showAllRoutes = false; // Reset to show top 3 when date range changes
      });
      _loadRouteStats();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading screen while data loads
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Color(0xFFD4AF37)),
              const SizedBox(height: 16),
              Text(
                'Loading dashboard...',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    final stats = [
      {
        "title": "Total Bookings",
        "count": "${_stats.totalBookings}",
        "icon": Icons.event_note_rounded,
        "color": const Color(0xFF2196F3),
      },
      {
        "title": "Booked Today",
        "count": "${_stats.bookedToday}",
        "icon": Icons.today_rounded,
        "color": const Color(0xFFFF9800),
      },
      {
        "title": "Number of Users",
        "count": "${_stats.numberOfUsers}",
        "icon": Icons.people_rounded,
        "color": const Color(0xFF4CAF50),
      },
      {
        "title": "Cancelled",
        "count": "${_stats.cancelled}",
        "icon": Icons.cancel_rounded,
        "color": const Color(0xFFEF5350),
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          // Yellow header section
          Container(
            decoration: const BoxDecoration(color: Color(0xFFFFEB3B)),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Company branding
                    Row(
                      children: [
                        Container(
                          height: 56,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Gothong Southern',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1B5E20),
                                  letterSpacing: -0.5,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Transport & Logistics',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF424242),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // White content area with rounded top
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Greeting section
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Welcome back! 👋',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF212121),
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat(
                                  'EEEE, MMMM d, y',
                                ).format(DateTime.now()),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[500],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    // Data source indicator (API vs Mock)
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Source: ${_apiService.lastStatsSource == 'api'
                                ? 'API'
                                : _apiService.lastStatsSource == 'mock'
                                ? 'Mock'
                                : 'Unknown'}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Dashboard Overview label
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF1B5E20,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.dashboard_rounded,
                            color: Color(0xFF1B5E20),
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Dashboard Overview',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B5E20),
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Stats grid
                    Builder(
                      builder: (context) {
                        final screenWidth = MediaQuery.of(context).size.width;
                        // Calculate card width: (Screen - Side Paddings - Grid Spacing) / 2
                        final cardWidth = (screenWidth - 48 - 16) / 2;
                        // Target height that fits all content (Icon + Count + Title + Paddings)
                        const targetHeight = 145.0;
                        final dynamicAspectRatio = cardWidth / targetHeight;

                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: dynamicAspectRatio,
                              ),
                          itemCount: stats.length,
                          itemBuilder: (context, index) {
                            final s = stats[index];
                            return _buildStatCard(
                              s['title'] as String,
                              s['count'] as String,
                              s['icon'] as IconData,
                              s['color'] as Color,
                            );
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 32),

                    // Top Routes Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF1B5E20,
                                ).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.trending_up_rounded,
                                color: Color(0xFF1B5E20),
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Top Routes',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF212121),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Period filter chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildPeriodChip('Today', 'day'),
                          const SizedBox(width: 8),
                          _buildPeriodChip('This Week', 'week'),
                          const SizedBox(width: 8),
                          _buildPeriodChip('This Month', 'month'),
                          const SizedBox(width: 8),
                          _buildCustomDateChip(),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Route statistics display
                    _buildTopRoutesCard(),

                    const SizedBox(height: 32),

                    // Recent Transactions header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recent Transactions',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF212121),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HistoryPage(),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFFD4AF37,
                              ).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(
                                  0xFFD4AF37,
                                ).withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'View All',
                                  style: TextStyle(
                                    color: Color(0xFFD4AF37),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Color(0xFFD4AF37),
                                  size: 14,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Transaction list
                    _recentBookings.isEmpty
                        ? _buildEmptyState()
                        : ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _recentBookings.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final booking = _recentBookings[index];
                              return _buildTransactionItem(
                                booking.referenceNumber,
                                booking.route,
                                booking.getFormattedDate(),
                                booking.status,
                              );
                            },
                          ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String count,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            count,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
              height: 1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(
    String ref,
    String route,
    String date,
    String status,
  ) {
    final statusUpper = status.toUpperCase();
    final statusColor = statusUpper == 'BOOKED'
        ? const Color(0xFF4CAF50) // Green
        : statusUpper == 'COMPLETED'
        ? const Color(0xFF2196F3) // Blue
        : const Color(0xFFEF5350); // Red

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.grey[200]!, width: 1.5),
            ),
            child: const Icon(
              Icons.directions_boat_rounded,
              color: Color(0xFF1B5E20),
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ref,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF212121),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  route,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  date,
                  style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodChip(String label, String period) {
    final isSelected = _selectedPeriod == period;
    return GestureDetector(
      onTap: () => _onPeriodChanged(period),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFD4AF37) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFFD4AF37) : Colors.grey[300]!,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomDateChip() {
    final isSelected = _selectedPeriod == 'custom';
    return GestureDetector(
      onTap: _selectCustomDateRange,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFD4AF37) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFFD4AF37) : Colors.grey[300]!,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.date_range_rounded,
              size: 16,
              color: isSelected ? Colors.white : Colors.grey[600],
            ),
            const SizedBox(width: 6),
            Text(
              isSelected && _customStartDate != null && _customEndDate != null
                  ? '${DateFormat('MMM d').format(_customStartDate!)} - ${DateFormat('MMM d').format(_customEndDate!)}'
                  : 'Custom',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopRoutesCard() {
    if (_isLoadingRoutes) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[200]!, width: 1.5),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
        ),
      );
    }

    if (_routeStats == null || _routeStats!.routes.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[200]!, width: 1.5),
        ),
        child: Column(
          children: [
            Icon(Icons.route_rounded, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No routes found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No bookings in the selected period',
              style: TextStyle(fontSize: 13, color: Colors.grey[400]),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Total bookings indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Total: ${_routeStats!.totalBookings} bookings',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4CAF50),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Route list - show top 3 or all based on _showAllRoutes
          ...List.generate(
            _showAllRoutes
                ? _routeStats!.routes.length
                : (_routeStats!.routes.length > 3
                      ? 3
                      : _routeStats!.routes.length),
            (index) {
              final route = _routeStats!.routes[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildRouteItem(route, index + 1),
              );
            },
          ),
          // View All / Show Less button
          if (_routeStats!.routes.length > 3)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Center(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _showAllRoutes = !_showAllRoutes;
                    });
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4AF37).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _showAllRoutes ? 'Show Less' : 'View All',
                          style: const TextStyle(
                            color: Color(0xFFD4AF37),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          _showAllRoutes
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          color: const Color(0xFFD4AF37),
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRouteItem(RouteStats route, int rank) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Row(
        children: [
          // Rank badge
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: rank <= 3
                  ? const Color(0xFFD4AF37).withValues(alpha: 0.2)
                  : Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '$rank',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: rank <= 3 ? const Color(0xFFD4AF37) : Colors.grey[600],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Route info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  route.route,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF212121),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${route.count} bookings',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          // Percentage badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF2196F3).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${route.percentage}%',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2196F3),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Empty state when no bookings
  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEB3B).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.directions_boat_rounded,
              size: 48,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No bookings yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your recent transactions will appear here\nonce you create a new booking.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[400],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
