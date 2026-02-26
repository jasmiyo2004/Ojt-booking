import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import '../controllers/booking_controller.dart';
import '../services/api_service.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final ApiService _api = ApiService();
  String _selectedFilter = 'All';

  List<Booking> _bookings = [];
  bool _loading = true;

  List<Booking> get filteredBookings {
    if (_selectedFilter == 'All') return _bookings;
    return _bookings
        .where((b) => b.status.toUpperCase() == _selectedFilter.toUpperCase())
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() => _loading = true);

    try {
      final list = await _api.getBookings();
      if (mounted) {
        setState(() {
          _bookings = list;
          _loading = false;
        });
      }
    } catch (e) {
      print('Error loading bookings: $e');
      if (mounted) {
        setState(() {
          _bookings = [];
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Page title
                        const Text(
                          'Transaction History',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF212121),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'View and manage your booking transactions',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Filter chips
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children:
                                ['All', 'Booked', 'Completed', 'Cancelled']
                                    .map(
                                      (filter) => Padding(
                                        padding: const EdgeInsets.only(
                                          right: 8,
                                        ),
                                        child: _buildFilterChip(filter),
                                      ),
                                    )
                                    .toList(),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),

                  // Booking list
                  Expanded(
                    child: _loading
                        ? Center(child: CircularProgressIndicator())
                        : (filteredBookings.isEmpty
                              ? _buildEmptyState()
                              : ListView.separated(
                                  padding: const EdgeInsets.fromLTRB(
                                    24,
                                    0,
                                    24,
                                    24,
                                  ),
                                  itemCount: filteredBookings.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    final booking = filteredBookings[index];
                                    return _buildBookingCard(booking);
                                  },
                                )),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String filter) {
    final isSelected = _selectedFilter == filter;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = filter),
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
          filter,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildBookingCard(Booking booking) {
    final statusColor = _getStatusColor(booking.status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Boat icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey[200]!, width: 1.5),
                ),
                child: const Icon(
                  Icons.directions_boat_rounded,
                  color: Color(0xFF1B5E20),
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              // Booking details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.referenceNumber,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF212121),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      booking.route,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      booking.getFormattedDate(),
                      style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                    ),
                  ],
                ),
              ),
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  booking.status,
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
          const SizedBox(height: 12),
          // Divider
          Container(height: 1, color: Colors.grey[200]),
          const SizedBox(height: 8),
          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildActionButton(
                icon: Icons.visibility_rounded,
                label: 'View',
                color: const Color(0xFF2196F3),
                onTap: () => _showViewModal(context, booking),
              ),
              const SizedBox(width: 8),
              _buildActionButton(
                icon: Icons.edit_rounded,
                label: 'Edit',
                color: const Color(0xFFFF9800),
                onTap: () => _showEditModal(context, booking),
              ),
              const SizedBox(width: 8),
              _buildActionButton(
                icon: Icons.cancel_rounded,
                label: 'Cancel',
                color: const Color(0xFFEF5350),
                onTap: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Cancel Booking'),
                      content: const Text(
                        'Are you sure you want to cancel this booking?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('No'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Yes'),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true) {
                    final ok = await _api.cancelBooking(booking.id);
                    if (ok) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Booking cancelled')),
                      );
                      await _loadBookings();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Failed to cancel booking'),
                        ),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEB3B).withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.inbox_rounded,
                size: 56,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No bookings found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Transactions matching your filter will appear here',
              style: TextStyle(fontSize: 14, color: Colors.grey[400]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'BOOKED':
        return const Color(0xFF2196F3);
      case 'COMPLETED':
        return const Color(0xFF4CAF50);
      case 'CANCELLED':
        return const Color(0xFFEF5350);
      default:
        return const Color(0xFF2196F3);
    }
  }

  // VIEW MODAL - Shows ALL booking data (read-only)
  void _showViewModal(BuildContext context, Booking booking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Modal header
              Container(
                padding: const EdgeInsets.fromLTRB(24, 16, 16, 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEB3B).withValues(alpha: 0.15),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF1B5E20,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.receipt_long_rounded,
                            color: Color(0xFF1B5E20),
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          "Booking Details",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF212121),
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, size: 18),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildModalSection(
                        icon: Icons.route_rounded,
                        title: "Route Information",
                        children: [
                          _buildReadOnlyField("Origin", booking.origin),
                          _buildReadOnlyField(
                            "Destination",
                            booking.destination,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildModalSection(
                        icon: Icons.directions_boat_rounded,
                        title: "Vessel & Schedule",
                        children: [
                          _buildReadOnlyField(
                            "Vessel Name",
                            booking.vesselName ?? "N/A",
                          ),
                          _buildReadOnlyField(
                            "Vessel Schedule",
                            "ETD: ${booking.getFormattedDate()}",
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildModalSection(
                        icon: Icons.inventory_2_rounded,
                        title: "Cargo Details",
                        children: [
                          _buildReadOnlyField(
                            "Equipment Type",
                            booking.equipmentType ?? "N/A",
                          ),
                          _buildReadOnlyField(
                            "Commodity Name",
                            booking.commodityName ?? "N/A",
                          ),
                          _buildReadOnlyField(
                            "Weight",
                            booking.weight ?? "N/A",
                          ),
                          _buildReadOnlyField(
                            "Declared Value",
                            booking.declaredValue ?? "N/A",
                          ),
                          _buildReadOnlyField(
                            "Cargo Description",
                            booking.cargoDescription ?? "N/A",
                          ),
                          _buildReadOnlyField(
                            "Container Number",
                            booking.containerNumber ?? "N/A",
                          ),
                          _buildReadOnlyField(
                            "Seal Number",
                            booking.seal ?? "N/A",
                          ),
                          _buildReadOnlyField(
                            "Agreement Party",
                            booking.agreementParty ?? "N/A",
                          ),
                          _buildReadOnlyField(
                            "Shipper Party",
                            booking.shipperParty ?? "N/A",
                          ),
                          _buildReadOnlyField(
                            "Consignee Party",
                            booking.consigneeParty ?? "N/A",
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildModalSection(
                        icon: Icons.payment_rounded,
                        title: "Payment & Trucking",
                        children: [
                          _buildReadOnlyField(
                            "Mode of Payment",
                            booking.modeOfPayment ?? "N/A",
                          ),
                          _buildReadOnlyField(
                            "Trucker",
                            booking.trucker ?? "N/A",
                          ),
                          _buildReadOnlyField(
                            "Plate Number",
                            booking.plateNumber ?? "N/A",
                          ),
                          _buildReadOnlyField(
                            "Driver",
                            booking.driver ?? "N/A",
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              // Close button
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      "Close",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // EDIT MODAL - Editable form matching booking creation
  void _showEditModal(BuildContext context, Booking booking) {
    final BookingController controller = BookingController();

    // Controllers pre-filled with existing data
    final departureDateController = TextEditingController(
      text: booking.getFormattedDate(),
    );

    // State variables for dropdowns
    String selectedOrigin = booking.origin;
    String selectedDestination = booking.destination;
    String selectedAgreementParty =
        booking.agreementParty ?? "Search Selection";
    String selectedShipper = booking.shipperParty ?? "Search Selection";
    String selectedConsignee = booking.consigneeParty ?? "Search Selection";
    String selectedCommodity = booking.commodityName ?? "Search Selection";
    String selectedEquipment = booking.equipmentType ?? "Search Selection";
    String selectedVessel = booking.vesselName ?? "Search Selection";
    String? selectedService = booking.modeOfService ?? "Pier to Pier";
    String? selectedPayment = booking.modeOfPayment ?? "Prepaid";

    final declaredValueController = TextEditingController(
      text: booking.declaredValue ?? '',
    );
    final cargoDescController = TextEditingController(
      text: booking.cargoDescription ?? '',
    );
    final weightController = TextEditingController(text: booking.weight ?? '');
    final containerController = TextEditingController(
      text: booking.containerNumber ?? '',
    );
    final sealController = TextEditingController(text: booking.seal ?? '');
    final truckerController = TextEditingController(
      text: booking.trucker ?? '',
    );
    final plateController = TextEditingController(
      text: booking.plateNumber ?? '',
    );
    final driverController = TextEditingController(text: booking.driver ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.9,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Modal header
                  Container(
                    padding: const EdgeInsets.fromLTRB(24, 16, 16, 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEB3B).withValues(alpha: 0.15),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(28),
                        topRight: Radius.circular(28),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFFFF9800,
                                ).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.edit_rounded,
                                color: Color(0xFFFF9800),
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              "Edit Booking",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF212121),
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, size: 18),
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildModalSection(
                            icon: Icons.route_rounded,
                            title: "Route Information",
                            children: [
                              _buildModalSearchField(
                                "Origin",
                                selectedOrigin,
                                () {
                                  controller.showSearchPicker(
                                    context: context,
                                    title: "Origin",
                                    options: [
                                      "CEBU",
                                      "MANILA",
                                      "DAVAO",
                                      "BATANGAS",
                                      "CAGAYAN DE ORO",
                                    ],
                                    onSelect: (val) => setModalState(
                                      () => selectedOrigin = val,
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 12),
                              _buildModalSearchField(
                                "Destination",
                                selectedDestination,
                                () {
                                  controller.showSearchPicker(
                                    context: context,
                                    title: "Destination",
                                    options: [
                                      "CEBU",
                                      "MANILA",
                                      "DAVAO",
                                      "ZAMBOANGA",
                                      "BATANGAS",
                                    ],
                                    onSelect: (val) => setModalState(
                                      () => selectedDestination = val,
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 12),
                              _buildModalSearchField(
                                "Target Departure Date",
                                departureDateController.text,
                                () async {
                                  final DateTime? picked = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2101),
                                  );
                                  if (picked != null) {
                                    setModalState(() {
                                      departureDateController.text =
                                          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                                    });
                                  }
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          _buildModalSection(
                            icon: Icons.people_alt_rounded,
                            title: "Parties",
                            children: [
                              _buildModalSearchField(
                                "Agreement Party",
                                selectedAgreementParty,
                                () {
                                  controller.showSearchPicker(
                                    context: context,
                                    title: "Agreement Party",
                                    options: [
                                      "GOTHONG-001",
                                      "GOTHONG-002",
                                      "WALMART-PH",
                                      "SM-LOGISTICS",
                                    ],
                                    onSelect: (val) => setModalState(
                                      () => selectedAgreementParty = val,
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 12),
                              _buildModalSearchField(
                                "Shipper Party",
                                selectedShipper,
                                () {
                                  controller.showSearchPicker(
                                    context: context,
                                    title: "Shipper Party",
                                    options: [
                                      "Party 1",
                                      "Party 2",
                                      "Party 3",
                                      "Party 4",
                                    ],
                                    onSelect: (val) => setModalState(
                                      () => selectedShipper = val,
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 12),
                              _buildModalSearchField(
                                "Consignee Party",
                                selectedConsignee,
                                () {
                                  controller.showSearchPicker(
                                    context: context,
                                    title: "Consignee Party",
                                    options: [
                                      "Consignee 1",
                                      "Consignee 2",
                                      "Consignee 3",
                                      "Consignee 4",
                                    ],
                                    onSelect: (val) => setModalState(
                                      () => selectedConsignee = val,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          _buildModalSection(
                            icon: Icons.payment_rounded,
                            title: "Service & Payment",
                            children: [
                              _buildModalDropdown(
                                "Mode of Service",
                                selectedService,
                                [
                                  "Pier to Pier",
                                  "Door to Door",
                                  "Pier to Door",
                                ],
                                (val) =>
                                    setModalState(() => selectedService = val),
                              ),
                              const SizedBox(height: 12),
                              _buildModalDropdown(
                                "Mode of Payment",
                                selectedPayment,
                                ["Prepaid", "Collect"],
                                (val) =>
                                    setModalState(() => selectedPayment = val),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          _buildModalSection(
                            icon: Icons.inventory_2_rounded,
                            title: "Cargo Details",
                            children: [
                              _buildModalSearchField(
                                "Commodity Name",
                                selectedCommodity,
                                () {
                                  controller.showSearchPicker(
                                    context: context,
                                    title: "Commodity Name",
                                    options: [
                                      "Commodity 1",
                                      "Commodity 2",
                                      "Commodity 3",
                                      "Commodity 4",
                                    ],
                                    onSelect: (val) => setModalState(
                                      () => selectedCommodity = val,
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 12),
                              _buildModalSearchField(
                                "Equipment Type",
                                selectedEquipment,
                                () {
                                  controller.showSearchPicker(
                                    context: context,
                                    title: "Equipment Type",
                                    options: [
                                      "Equipment 1",
                                      "Equipment 2",
                                      "Equipment 3",
                                      "Equipment 4",
                                    ],
                                    onSelect: (val) => setModalState(
                                      () => selectedEquipment = val,
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 12),
                              _buildModalTextField(
                                declaredValueController,
                                "Declared Value",
                                "₱0.00",
                              ),
                              const SizedBox(height: 12),
                              _buildModalTextField(
                                cargoDescController,
                                "Cargo Description",
                                "Describe cargo",
                              ),
                              const SizedBox(height: 12),
                              _buildModalTextField(
                                weightController,
                                "Weight",
                                "kg",
                              ),
                              const SizedBox(height: 12),
                              _buildModalTextField(
                                containerController,
                                "Container Number",
                                "CONT-XXX",
                              ),
                              const SizedBox(height: 12),
                              _buildModalTextField(
                                sealController,
                                "Seal",
                                "SEAL-XXX",
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          _buildModalSection(
                            icon: Icons.directions_boat_rounded,
                            title: "Vessel & Trucking",
                            children: [
                              _buildModalSearchField(
                                "Vessel Name",
                                selectedVessel,
                                () {
                                  controller.showSearchPicker(
                                    context: context,
                                    title: "Vessel Name",
                                    options: [
                                      "Vessel 1",
                                      "Vessel 2",
                                      "Vessel 3",
                                      "Vessel 4",
                                      "Vessel 5",
                                    ],
                                    onSelect: (val) => setModalState(
                                      () => selectedVessel = val,
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 12),
                              _buildModalTextField(
                                truckerController,
                                "Trucker",
                                "Trucking company",
                              ),
                              const SizedBox(height: 12),
                              _buildModalTextField(
                                plateController,
                                "Plate Number",
                                "ABC-1234",
                              ),
                              const SizedBox(height: 12),
                              _buildModalTextField(
                                driverController,
                                "Driver",
                                "Driver name",
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                  // Action buttons
                  Container(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 50,
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: Colors.grey[300]!,
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Text(
                                "Cancel",
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () async {
                                // Build updated booking from modal fields
                                final parsedDeparture =
                                    DateTime.tryParse(
                                      departureDateController.text,
                                    ) ??
                                    booking.departureDate;
                                final updatedBooking = Booking(
                                  id: booking.id,
                                  referenceNumber: booking.referenceNumber,
                                  route:
                                      '$selectedOrigin ➔ $selectedDestination',
                                  origin: selectedOrigin,
                                  destination: selectedDestination,
                                  bookingDate: booking.bookingDate,
                                  departureDate: parsedDeparture,
                                  status: booking.status,
                                  agreementParty: selectedAgreementParty,
                                  shipperParty: selectedShipper,
                                  consigneeParty: selectedConsignee,
                                  modeOfService: selectedService,
                                  modeOfPayment: selectedPayment,
                                  commodityName: selectedCommodity,
                                  equipmentType: selectedEquipment,
                                  declaredValue: declaredValueController.text,
                                  cargoDescription: cargoDescController.text,
                                  weight: weightController.text,
                                  containerNumber: containerController.text,
                                  seal: sealController.text,
                                  vesselName: selectedVessel,
                                  trucker: truckerController.text,
                                  plateNumber: plateController.text,
                                  driver: driverController.text,
                                  customerName: booking.customerName,
                                  contactNumber: booking.contactNumber,
                                );

                                final result = await _api.updateBooking(
                                  booking.id,
                                  updatedBooking,
                                );
                                if (result.id != '0') {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text(
                                        'Booking updated successfully!',
                                      ),
                                      behavior: SnackBarBehavior.floating,
                                      backgroundColor: const Color(0xFF4CAF50),
                                    ),
                                  );
                                  await _loadBookings();
                                  Navigator.pop(context);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Failed to update booking'),
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFD4AF37),
                                foregroundColor: Colors.white,
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text(
                                "Save Changes",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Helper widgets
  Widget _buildModalSection({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF1B5E20).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: const Color(0xFF1B5E20), size: 18),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B5E20),
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ...children,
      ],
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[500],
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF212121),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModalSearchField(
    String label,
    String value,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!, width: 1),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF212121),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.search_rounded,
                color: Color(0xFFD4AF37),
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModalTextField(
    TextEditingController controller,
    String label,
    String hint,
  ) {
    return TextField(
      controller: controller,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(
          fontSize: 13,
          color: Colors.grey[500],
          fontWeight: FontWeight.w500,
        ),
        hintStyle: TextStyle(fontSize: 14, color: Colors.grey[400]),
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD4AF37), width: 1.5),
        ),
      ),
    );
  }

  Widget _buildModalDropdown(
    String label,
    String? value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: Color(0xFF212121),
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontSize: 13,
          color: Colors.grey[500],
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD4AF37), width: 1.5),
        ),
      ),
      items: items.map((String val) {
        return DropdownMenuItem<String>(value: val, child: Text(val));
      }).toList(),
      onChanged: onChanged,
    );
  }
}
