import 'package:flutter/material.dart';
import '../controllers/booking_controller.dart';
import '../models/transport_service_model.dart';
import '../models/payment_mode_model.dart';
import '../models/vessel_schedule_model.dart';
import '../models/customer_model.dart';
import '../models/booking_model.dart';
import '../models/location_model.dart';
import '../services/api_service.dart';
import '../widgets/success_dialog.dart';
import '../widgets/error_dialog.dart';
import '../widgets/confirm_dialog.dart';

class BookingPage extends StatefulWidget {
  final Booking? bookingToEdit; // Optional booking for editing

  const BookingPage({super.key, this.bookingToEdit});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final BookingController _controller = BookingController();
  final ApiService _apiService = ApiService();

  // Variables to hold selected values
  String selectedOrigin = "Select Origin";
  int? selectedOriginId; // Store location ID
  String? selectedOriginType; // Store origin location type
  String selectedDestination = "Select Destination";
  int? selectedDestinationId; // Store location ID
  String? selectedDestinationType; // Store destination location type
  String selectedAgreementParty = "Search Selection";
  int? selectedAgreementPartyId; // Store customer ID
  Customer? selectedAgreementPartyObj; // Store full customer object
  String selectedShipper = "Search Selection";
  int? selectedShipperId; // Store customer ID
  Customer? selectedShipperObj; // Store full customer object
  String selectedConsignee = "Search Selection";
  int? selectedConsigneeId; // Store customer ID
  Customer? selectedConsigneeObj; // Store full customer object
  String selectedCommodity = "Search Selection";
  int? selectedCommodityId; // Store commodity ID
  String selectedEquipment = "Search Selection";
  int? selectedEquipmentId; // Store equipment ID
  String selectedVessel = "Search Selection";
  int? selectedVesselId; // Store vessel ID
  String selectedVesselSchedule = "Search Selection";
  int? selectedVesselScheduleId; // Store vessel schedule ID
  VesselSchedule?
  selectedVesselScheduleObj; // Store full vessel schedule object
  String selectedContainer = "Search Selection";
  int? selectedContainerId; // Store container ID
  String? selectedService; // Changed to String
  int? selectedServiceId; // Store service ID
  String? selectedPayment;
  int? selectedPaymentId; // Store payment mode ID

  // Transport services list
  List<TransportService> _transportServices = [];
  bool _isLoadingServices = true;

  // Payment modes list
  List<PaymentMode> _paymentModes = [];
  bool _isLoadingPaymentModes = true;

  final _departureDateController = TextEditingController();
  final _declaredValueController = TextEditingController();
  final _cargoDescController = TextEditingController();
  final _weightController = TextEditingController();
  final _sealController = TextEditingController();
  final _truckerController = TextEditingController();
  final _plateController = TextEditingController();
  final _driverController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTransportServices();
    _loadPaymentModes();

    // Pre-fill data if editing (async)
    if (widget.bookingToEdit != null) {
      // Call async method without await in initState
      Future.microtask(() => _prefillBookingData());
    }
  }

  Future<void> _prefillBookingData() async {
    final booking = widget.bookingToEdit!;

    // Pre-fill text controllers first
    _weightController.text = booking.weight ?? '';
    _declaredValueController.text = booking.declaredValue ?? '';
    _cargoDescController.text = booking.cargoDescription ?? '';
    _sealController.text = booking.seal ?? '';
    _truckerController.text = booking.trucker ?? '';
    _plateController.text = booking.plateNumber ?? '';
    _driverController.text = booking.driver ?? '';

    setState(() {
      // Set origin and destination with IDs from booking
      selectedOrigin = booking.origin;
      selectedOriginId = booking.originLocationId;

      selectedDestination = booking.destination;
      selectedDestinationId = booking.destinationLocationId;

      // Set vessel with ID
      selectedVessel = booking.vesselName ?? "Search Selection";
      selectedVesselId = booking.vesselId;

      // Set equipment with ID
      selectedEquipment = booking.equipmentType ?? "Search Selection";
      selectedEquipmentId = booking.equipmentId;

      // Set commodity with ID
      selectedCommodity = booking.commodityName ?? "Search Selection";
      selectedCommodityId = booking.commodityId;

      // Set container with ID
      selectedContainer = booking.containerNumber ?? "Search Selection";
      selectedContainerId = booking.containerId;

      // Set payment mode with ID
      selectedPayment = booking.modeOfPayment;
      selectedPaymentId = booking.paymentModeId;

      // Set vessel schedule with ID
      selectedVesselScheduleId = booking.vesselScheduleId;
      if (booking.vesselScheduleId != null) {
        selectedVesselSchedule = 'Schedule ${booking.vesselScheduleId}';
      }

      // Set parties with IDs
      selectedAgreementParty = booking.agreementParty ?? "Search Selection";
      selectedAgreementPartyId = booking.agreementPartyId;

      selectedShipper = booking.shipperParty ?? "Search Selection";
      selectedShipperId = booking.shipperPartyId;

      selectedConsignee = booking.consigneeParty ?? "Search Selection";
      selectedConsigneeId = booking.consigneePartyId;
    });

    // Load location types for mode of service auto-fill
    try {
      final locations = await _apiService.getLocations();

      if (locations.isEmpty) {
        print('Warning: No locations loaded');
        return;
      }

      Location? originLocation;
      Location? destinationLocation;

      try {
        originLocation = locations.firstWhere(
          (loc) => loc.locationId == booking.originLocationId,
        );
      } catch (e) {
        print('Origin location not found, using first location');
        originLocation = locations.first;
      }

      try {
        destinationLocation = locations.firstWhere(
          (loc) => loc.locationId == booking.destinationLocationId,
        );
      } catch (e) {
        print('Destination location not found, using first location');
        destinationLocation = locations.first;
      }

      setState(() {
        selectedOriginType = originLocation?.locationTypeDesc;
        selectedDestinationType = destinationLocation?.locationTypeDesc;
      });

      // Auto-update Mode of Service based on origin and destination types
      _updateModeOfService();

      // Load vessel schedule object if we have the ID
      if (booking.vesselScheduleId != null &&
          booking.originLocationId != null &&
          booking.destinationLocationId != null &&
          booking.vesselId != null) {
        final schedules = await _apiService.getVesselSchedules(
          originLocationId: booking.originLocationId!,
          destinationLocationId: booking.destinationLocationId!,
          vesselId: booking.vesselId!,
        );

        if (schedules.isNotEmpty) {
          VesselSchedule? matchingSchedule;
          try {
            matchingSchedule = schedules.firstWhere(
              (s) => s.vesselScheduleId == booking.vesselScheduleId,
            );
          } catch (e) {
            print('Vessel schedule not found, using first schedule');
            matchingSchedule = schedules.first;
          }

          setState(() {
            selectedVesselScheduleObj = matchingSchedule;
          });
        }
      }
    } catch (e) {
      print('Error prefilling booking data: $e');
      // Don't show error to user, just log it
      // The form will still be usable with the basic data that was set
    }
  }

  Future<void> _loadTransportServices() async {
    try {
      final services = await _apiService.getTransportServices();
      setState(() {
        // Remove duplicates based on transportServiceDesc
        final seen = <String>{};
        _transportServices = services.where((service) {
          if (seen.contains(service.transportServiceDesc)) {
            return false;
          }
          seen.add(service.transportServiceDesc);
          return true;
        }).toList();
        _isLoadingServices = false;
      });
    } catch (e) {
      print('Error loading transport services: $e');
      setState(() {
        _isLoadingServices = false;
      });
    }
  }

  Future<void> _loadPaymentModes() async {
    try {
      final modes = await _apiService.getPaymentModes();
      setState(() {
        // Remove duplicates based on paymentModeDesc
        final seen = <String>{};
        _paymentModes = modes.where((mode) {
          if (seen.contains(mode.paymentModeDesc)) {
            return false;
          }
          seen.add(mode.paymentModeDesc);
          return true;
        }).toList();
        _isLoadingPaymentModes = false;
      });
    } catch (e) {
      print('Error loading payment modes: $e');
      setState(() {
        _isLoadingPaymentModes = false;
      });
    }
  }

  @override
  void dispose() {
    _departureDateController.dispose();
    _declaredValueController.dispose();
    _cargoDescController.dispose();
    _weightController.dispose();
    _sealController.dispose();
    _truckerController.dispose();
    _plateController.dispose();
    _driverController.dispose();
    super.dispose();
  }

  // Method to automatically determine Mode of Service based on origin and destination types
  void _updateModeOfService() {
    if (selectedOriginType != null && selectedDestinationType != null) {
      // Construct the service name: "ORIGIN_TYPE/DESTINATION_TYPE"
      final serviceName = '$selectedOriginType/$selectedDestinationType';

      // Find matching transport service
      final matchingService = _transportServices.firstWhere(
        (service) =>
            service.transportServiceDesc.toUpperCase() ==
            serviceName.toUpperCase(),
        orElse: () => _transportServices.first,
      );

      setState(() {
        selectedService = matchingService.transportServiceDesc;
        selectedServiceId = matchingService.transportServiceId;
      });

      print(
        'Auto-selected Mode of Service: $selectedService (ID: $selectedServiceId)',
      );
      print(
        'Origin Type: $selectedOriginType, Destination Type: $selectedDestinationType',
      );
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Page title
                    Text(
                      widget.bookingToEdit != null
                          ? 'Edit Booking'
                          : 'New Booking',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF212121),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.bookingToEdit != null
                          ? 'Update the booking details below'
                          : 'Fill in the details to create a new booking transaction',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // === Route Information Section ===
                    _buildSectionCard(
                      icon: Icons.route_rounded,
                      title: 'Route Information',
                      children: [
                        _buildSearchField(
                          label: 'Origin',
                          value: selectedOrigin,
                          icon: Icons.flight_takeoff_rounded,
                          onTap: () async {
                            await _controller.showLocationPicker(
                              context: context,
                              title: "Origin",
                              currentLocationId: selectedDestinationId,
                              errorType: 'origin',
                              onSelect:
                                  (locationDesc, locationId, locationTypeDesc) {
                                    setState(() {
                                      selectedOrigin = locationDesc;
                                      selectedOriginId = locationId;
                                      selectedOriginType = locationTypeDesc;
                                    });
                                    // Auto-update Mode of Service if both locations are selected
                                    _updateModeOfService();
                                  },
                            );
                          },
                          onClear: () {
                            setState(() {
                              selectedOrigin = "Select Origin";
                              selectedOriginId = null;
                              selectedOriginType = null;
                              // Clear Mode of Service when origin is cleared
                              selectedService = null;
                              selectedServiceId = null;
                            });
                          },
                        ),
                        const SizedBox(height: 14),
                        _buildSearchField(
                          label: 'Destination',
                          value: selectedDestination,
                          icon: Icons.flight_land_rounded,
                          onTap: () async {
                            await _controller.showLocationPicker(
                              context: context,
                              title: "Destination",
                              currentLocationId: selectedOriginId,
                              errorType: 'destination',
                              onSelect:
                                  (locationDesc, locationId, locationTypeDesc) {
                                    setState(() {
                                      selectedDestination = locationDesc;
                                      selectedDestinationId = locationId;
                                      selectedDestinationType =
                                          locationTypeDesc;
                                    });
                                    // Auto-update Mode of Service if both locations are selected
                                    _updateModeOfService();
                                  },
                            );
                          },
                          onClear: () {
                            setState(() {
                              selectedDestination = "Select Destination";
                              selectedDestinationId = null;
                              selectedDestinationType = null;
                              // Clear Mode of Service when destination is cleared
                              selectedService = null;
                              selectedServiceId = null;
                            });
                          },
                        ),
                        const SizedBox(height: 14),
                        _isLoadingServices
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8F9FA),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.grey[300]!,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.miscellaneous_services_rounded,
                                      color: Colors.grey[500],
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    const Text('Loading services...'),
                                    const Spacer(),
                                    const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8F9FA),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.grey[300]!,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.miscellaneous_services_rounded,
                                      color: Colors.grey[500],
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Mode of Service',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey[500],
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 0.3,
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            selectedService ??
                                                'Auto-filled based on locations',
                                            style: TextStyle(
                                              fontSize: 15,
                                              color: selectedService != null
                                                  ? const Color(0xFF212121)
                                                  : Colors.grey[400],
                                              fontWeight:
                                                  selectedService != null
                                                  ? FontWeight.w600
                                                  : FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFF4CAF50,
                                        ).withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.auto_awesome,
                                        color: Color(0xFF4CAF50),
                                        size: 18,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // === Vessel & Schedule Section ===
                    _buildSectionCard(
                      icon: Icons.directions_boat_rounded,
                      title: 'Vessel & Schedule',
                      children: [
                        _buildSearchField(
                          label: 'Vessel Name',
                          value: selectedVessel,
                          icon: Icons.sailing_rounded,
                          onTap: () {
                            _controller.showVesselPicker(
                              context: context,
                              onSelect: (vesselDesc, vesselId) {
                                setState(() {
                                  selectedVessel = vesselDesc;
                                  selectedVesselId = vesselId;
                                });
                              },
                            );
                          },
                          onClear: () {
                            setState(() {
                              selectedVessel = "Search Selection";
                              selectedVesselId = null;
                            });
                          },
                        ),
                        const SizedBox(height: 14),
                        _buildSearchField(
                          label: 'Vessel Schedule',
                          value: selectedVesselSchedule,
                          icon: Icons.schedule_rounded,
                          onTap: () {
                            // Check if origin, destination, and vessel are selected
                            if (selectedOriginId == null ||
                                selectedDestinationId == null ||
                                selectedVesselId == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Please select Origin, Destination, and Vessel first',
                                  ),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                              return;
                            }

                            _controller.showVesselSchedulePicker(
                              context: context,
                              originLocationId: selectedOriginId!,
                              destinationLocationId: selectedDestinationId!,
                              vesselId: selectedVesselId!,
                              onSelect:
                                  (scheduleDisplay, scheduleId, scheduleObj) {
                                    setState(() {
                                      selectedVesselSchedule = scheduleDisplay;
                                      selectedVesselScheduleId = scheduleId;
                                      selectedVesselScheduleObj = scheduleObj;
                                    });
                                  },
                            );
                          },
                          onClear: () {
                            setState(() {
                              selectedVesselSchedule = "Search Selection";
                              selectedVesselScheduleId = null;
                              selectedVesselScheduleObj = null;
                            });
                          },
                        ),
                        // Display vessel schedule details when selected
                        if (selectedVesselScheduleObj != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFBF0),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(
                                  0xFFD4AF37,
                                ).withValues(alpha: 0.3),
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Vessel Schedule',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1B5E20),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // Table header
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        'POL',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        'POD',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        'ETD',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        'ETA',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                // Table data
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        '${selectedVesselScheduleObj!.originPortDesc} (${selectedVesselScheduleObj!.originPortCd})',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF424242),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        '${selectedVesselScheduleObj!.destinationPortDesc} (${selectedVesselScheduleObj!.destinationPortCd})',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF424242),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        selectedVesselScheduleObj!.etd != null
                                            ? () {
                                                final adjustedEtd =
                                                    selectedVesselScheduleObj!
                                                        .etd!
                                                        .add(
                                                          const Duration(
                                                            hours: 8,
                                                          ),
                                                        );
                                                return '${adjustedEtd.year}-${adjustedEtd.month.toString().padLeft(2, '0')}-${adjustedEtd.day.toString().padLeft(2, '0')} ${adjustedEtd.hour.toString().padLeft(2, '0')}:${adjustedEtd.minute.toString().padLeft(2, '0')}:00';
                                              }()
                                            : 'N/A',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF424242),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        selectedVesselScheduleObj!.eta != null
                                            ? () {
                                                final adjustedEta =
                                                    selectedVesselScheduleObj!
                                                        .eta!
                                                        .add(
                                                          const Duration(
                                                            hours: 8,
                                                          ),
                                                        );
                                                return '${adjustedEta.year}-${adjustedEta.month.toString().padLeft(2, '0')}-${adjustedEta.day.toString().padLeft(2, '0')} ${adjustedEta.hour.toString().padLeft(2, '0')}:${adjustedEta.minute.toString().padLeft(2, '0')}:00';
                                              }()
                                            : 'N/A',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF424242),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 16),

                    // === Cargo Details Section ===
                    _buildSectionCard(
                      icon: Icons.inventory_2_rounded,
                      title: 'Cargo Details',
                      children: [
                        _buildSearchField(
                          label: 'Equipment Type',
                          value: selectedEquipment,
                          icon: Icons.build_rounded,
                          onTap: () {
                            _controller.showEquipmentPicker(
                              context: context,
                              onSelect: (equipmentDesc, equipmentId) {
                                setState(() {
                                  selectedEquipment = equipmentDesc;
                                  selectedEquipmentId = equipmentId;
                                });
                              },
                            );
                          },
                          onClear: () {
                            setState(() {
                              selectedEquipment = "Search Selection";
                              selectedEquipmentId = null;
                            });
                          },
                        ),
                        const SizedBox(height: 14),
                        _buildSearchField(
                          label: 'Commodity Name',
                          value: selectedCommodity,
                          icon: Icons.category_rounded,
                          onTap: () {
                            _controller.showCommodityPicker(
                              context: context,
                              onSelect: (commodityDesc, commodityId) {
                                setState(() {
                                  selectedCommodity = commodityDesc;
                                  selectedCommodityId = commodityId;
                                });
                              },
                            );
                          },
                          onClear: () {
                            setState(() {
                              selectedCommodity = "Search Selection";
                              selectedCommodityId = null;
                            });
                          },
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStyledTextField(
                                controller: _weightController,
                                label: 'Weight',
                                hint: 'kg',
                                icon: Icons.scale_rounded,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStyledTextField(
                                controller: _declaredValueController,
                                label: 'Declared Value',
                                hint: '₱0.00',
                                icon: Icons.monetization_on_rounded,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _buildStyledTextField(
                          controller: _cargoDescController,
                          label: 'Cargo Description',
                          hint: 'Describe the cargo',
                          icon: Icons.description_rounded,
                        ),
                        const SizedBox(height: 14),
                        _buildSearchField(
                          label: 'Container Number',
                          value: selectedContainer,
                          icon: Icons.inventory_2_rounded,
                          onTap: () {
                            _controller.showContainerPicker(
                              context: context,
                              onSelect: (containerNo, containerId) {
                                setState(() {
                                  selectedContainer = containerNo;
                                  selectedContainerId = containerId;
                                });
                              },
                            );
                          },
                          onClear: () {
                            setState(() {
                              selectedContainer = "Search Selection";
                              selectedContainerId = null;
                            });
                          },
                        ),
                        const SizedBox(height: 14),
                        _buildStyledTextField(
                          controller: _sealController,
                          label: 'Seal Number',
                          hint: 'SEAL-XXX',
                          icon: Icons.verified_rounded,
                        ),

                        const SizedBox(height: 14),
                        _buildSearchField(
                          label: 'Agreement Party',
                          value: selectedAgreementParty,
                          icon: Icons.handshake_rounded,
                          onTap: () {
                            _controller.showAgreementPartyPicker(
                              context: context,
                              onSelect: (customerName, customerId, customerObj) {
                                setState(() {
                                  selectedAgreementParty =
                                      '${customerObj.fullName} (${customerObj.customerCd})';
                                  selectedAgreementPartyId = customerId;
                                  selectedAgreementPartyObj = customerObj;
                                });
                              },
                            );
                          },
                          onClear: () {
                            setState(() {
                              selectedAgreementParty = "Search Selection";
                              selectedAgreementPartyId = null;
                              selectedAgreementPartyObj = null;
                            });
                          },
                        ),
                        const SizedBox(height: 14),
                        _buildSearchField(
                          label: 'Shipper Party',
                          value: selectedShipper,
                          icon: Icons.local_shipping_rounded,
                          onTap: () {
                            _controller.showShipperPartyPicker(
                              context: context,
                              onSelect: (customerName, customerId, customerObj) {
                                setState(() {
                                  selectedShipper =
                                      '${customerObj.fullName} (${customerObj.customerCd})';
                                  selectedShipperId = customerId;
                                  selectedShipperObj = customerObj;
                                });
                              },
                            );
                          },
                          onClear: () {
                            setState(() {
                              selectedShipper = "Search Selection";
                              selectedShipperId = null;
                              selectedShipperObj = null;
                            });
                          },
                        ),
                        const SizedBox(height: 14),
                        _buildSearchField(
                          label: 'Consignee Party',
                          value: selectedConsignee,
                          icon: Icons.person_pin_rounded,
                          onTap: () {
                            _controller.showConsigneePartyPicker(
                              context: context,
                              onSelect: (consigneeName, consigneeId, consigneeObj) {
                                setState(() {
                                  selectedConsignee =
                                      '${consigneeObj.fullName} (${consigneeObj.customerCd})';
                                  selectedConsigneeId = consigneeId;
                                  selectedConsigneeObj = consigneeObj;
                                });
                              },
                            );
                          },
                          onClear: () {
                            setState(() {
                              selectedConsignee = "Search Selection";
                              selectedConsigneeId = null;
                              selectedConsigneeObj = null;
                            });
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // === Payment & Trucking Section ===
                    _buildSectionCard(
                      icon: Icons.payment_rounded,
                      title: 'Payment & Trucking',
                      children: [
                        _isLoadingPaymentModes
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8F9FA),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.grey[300]!,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.account_balance_wallet_rounded,
                                      color: Colors.grey[500],
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    const Text('Loading payment modes...'),
                                    const Spacer(),
                                    const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : _buildStyledDropdown(
                                label: 'Mode of Payment',
                                value: selectedPayment,
                                icon: Icons.account_balance_wallet_rounded,
                                items: _paymentModes
                                    .map((pm) => pm.paymentModeDesc)
                                    .toList(),
                                onChanged: (val) {
                                  setState(() {
                                    selectedPayment = val;
                                    // Find and store the payment mode ID
                                    try {
                                      final mode = _paymentModes.firstWhere(
                                        (pm) => pm.paymentModeDesc == val,
                                      );
                                      selectedPaymentId = mode.paymentModeId;
                                    } catch (e) {
                                      selectedPaymentId = null;
                                    }
                                  });
                                },
                              ),
                        const SizedBox(height: 14),
                        _buildStyledTextField(
                          controller: _truckerController,
                          label: 'Trucker',
                          hint: 'Trucking company',
                          icon: Icons.local_shipping_outlined,
                        ),
                        const SizedBox(height: 14),
                        _buildStyledTextField(
                          controller: _plateController,
                          label: 'Plate Number',
                          hint: 'ABC-1234',
                          icon: Icons.confirmation_number_rounded,
                        ),
                        const SizedBox(height: 14),
                        _buildStyledTextField(
                          controller: _driverController,
                          label: 'Driver',
                          hint: 'Driver name',
                          icon: Icons.person_rounded,
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () async {
                          // Debug: Print all field values
                          print('=== BOOKING VALIDATION DEBUG ===');
                          print('selectedOrigin: $selectedOrigin');
                          print('selectedDestination: $selectedDestination');
                          print('selectedService: $selectedService');
                          print(
                            'selectedAgreementParty: $selectedAgreementParty',
                          );
                          print('selectedShipper: $selectedShipper');
                          print('selectedConsignee: $selectedConsignee');
                          print('selectedEquipment: $selectedEquipment');
                          print('selectedCommodity: $selectedCommodity');
                          print('selectedVessel: $selectedVessel');
                          print(
                            'selectedVesselScheduleId: $selectedVesselScheduleId',
                          );
                          print('selectedPayment: $selectedPayment');
                          print('selectedContainer: $selectedContainer');
                          print(
                            'departureDate: ${_departureDateController.text}',
                          );
                          print(
                            'declaredValue: ${_declaredValueController.text}',
                          );
                          print('cargoDesc: ${_cargoDescController.text}');
                          print('weight: ${_weightController.text}');
                          print('seal: ${_sealController.text}');
                          print('trucker: ${_truckerController.text}');
                          print('plate: ${_plateController.text}');
                          print('driver: ${_driverController.text}');
                          print('================================');

                          // Validate required fields
                          if (selectedOrigin == "Select Origin" ||
                              selectedDestination == "Select Destination" ||
                              selectedService == null ||
                              selectedAgreementParty == "Search Selection" ||
                              selectedShipper == "Search Selection" ||
                              selectedConsignee == "Search Selection" ||
                              selectedEquipment == "Search Selection" ||
                              selectedCommodity == "Search Selection" ||
                              selectedVessel == "Search Selection" ||
                              selectedVesselScheduleId == null ||
                              selectedPayment == null ||
                              selectedContainer == "Search Selection" ||
                              _declaredValueController.text.isEmpty ||
                              _cargoDescController.text.isEmpty ||
                              _weightController.text.isEmpty ||
                              _sealController.text.isEmpty ||
                              _truckerController.text.isEmpty ||
                              _plateController.text.isEmpty ||
                              _driverController.text.isEmpty) {
                            // Debug: Print which fields are missing
                            print('=== MISSING FIELDS ===');
                            if (selectedOrigin == "Select Origin")
                              print('- Origin');
                            if (selectedDestination == "Select Destination")
                              print('- Destination');
                            if (selectedService == null) print('- Service');
                            if (selectedAgreementParty == "Search Selection")
                              print('- Agreement Party');
                            if (selectedShipper == "Search Selection")
                              print('- Shipper');
                            if (selectedConsignee == "Search Selection")
                              print('- Consignee');
                            if (selectedEquipment == "Search Selection")
                              print('- Equipment');
                            if (selectedCommodity == "Search Selection")
                              print('- Commodity');
                            if (selectedVessel == "Search Selection")
                              print('- Vessel');
                            if (selectedVesselScheduleId == null)
                              print('- Vessel Schedule');
                            if (selectedPayment == null) print('- Payment');
                            if (selectedContainer == "Search Selection")
                              print('- Container');
                            if (_declaredValueController.text.isEmpty)
                              print('- Declared Value');
                            if (_cargoDescController.text.isEmpty)
                              print('- Cargo Description');
                            if (_weightController.text.isEmpty)
                              print('- Weight');
                            if (_sealController.text.isEmpty)
                              print('- Seal Number');
                            if (_truckerController.text.isEmpty)
                              print('- Trucker');
                            if (_plateController.text.isEmpty)
                              print('- Plate Number');
                            if (_driverController.text.isEmpty)
                              print('- Driver');
                            print('======================');

                            ErrorDialog.showConfirmError(context);
                            return;
                          }

                          // Create booking object with IDs
                          final bookingData = {
                            'BookingNo':
                                'BK-${DateTime.now().millisecondsSinceEpoch}',
                            'StatusId': 4, // BOOKED status
                            'TransportServiceId': selectedServiceId,
                            'OriginLocationId': selectedOriginId,
                            'DestinationLocationId': selectedDestinationId,
                            'PaymentModeId': selectedPaymentId,
                            'EquipmentId': selectedEquipmentId,
                            'CommodityId': selectedCommodityId,
                            'VesselId': selectedVesselId,
                            'VesselScheduleId': selectedVesselScheduleId,
                            'DeclaredValue':
                                _declaredValueController.text.isNotEmpty
                                ? double.tryParse(_declaredValueController.text)
                                : null,
                            'CargoDescription':
                                _cargoDescController.text.isNotEmpty
                                ? _cargoDescController.text
                                : null,
                            'Weight': _weightController.text.isNotEmpty
                                ? double.tryParse(_weightController.text)
                                : null,
                            'ContainerId': selectedContainerId,
                            'SealNumber': _sealController.text.isNotEmpty
                                ? _sealController.text
                                : null,
                            'Trucker': _truckerController.text.isNotEmpty
                                ? _truckerController.text
                                : null,
                            'PlateNumber': _plateController.text.isNotEmpty
                                ? _plateController.text
                                : null,
                            'Driver': _driverController.text.isNotEmpty
                                ? _driverController.text
                                : null,
                            'CreateUserId': 'SYSTEM',
                            'CreateDttm': DateTime.now()
                                .toUtc()
                                .toIso8601String(),
                            'UpdateUserId': 'SYSTEM',
                            'UpdateDttm': DateTime.now()
                                .toUtc()
                                .toIso8601String(),
                            // Party IDs
                            'AgreementPartyId': selectedAgreementPartyId,
                            'ShipperPartyId': selectedShipperId,
                            'ConsigneePartyId': selectedConsigneeId,
                          };

                          // Determine if we're creating or updating
                          final isEditing = widget.bookingToEdit != null;

                          // If editing, show confirmation dialog first
                          if (isEditing) {
                            final confirmed =
                                await ConfirmDialog.showUpdateBooking(
                                  context,
                                  bookingNumber:
                                      widget.bookingToEdit!.referenceNumber,
                                );

                            if (!confirmed) {
                              return; // User cancelled
                            }

                            // User confirmed, proceed with update
                            try {
                              // Show loading
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Updating booking...'),
                                ),
                              );

                              // UPDATE existing booking
                              print(
                                'Updating booking ${widget.bookingToEdit!.id} with data: $bookingData',
                              );
                              final result = await _apiService
                                  .updateBookingWithIds(
                                    widget.bookingToEdit!.id,
                                    bookingData,
                                  );
                              print('Booking updated successfully: $result');

                              // Hide loading snackbar
                              ScaffoldMessenger.of(
                                context,
                              ).hideCurrentSnackBar();

                              // Show success dialog and wait for user to click OK
                              await showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => SuccessDialog(
                                  title: 'UPDATE BOOKING',
                                  message:
                                      'Booking Number: ${result['bookingNo'] ?? widget.bookingToEdit!.referenceNumber} was successfully updated.',
                                  bookingNumber: null,
                                ),
                              );

                              // Navigate back to history page AFTER user clicks OK
                              Navigator.of(context).pop();
                            } catch (e) {
                              // Error
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to update booking: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                            return; // Exit early after handling update
                          }

                          // CREATE new booking (show confirmation first)
                          try {
                            // Show confirmation dialog first
                            final confirmed =
                                await ConfirmDialog.showSubmitBooking(context);

                            if (!confirmed) {
                              return; // User cancelled
                            }

                            // User confirmed, proceed with creation
                            // Show loading
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Creating booking...'),
                              ),
                            );

                            print('Creating booking with data: $bookingData');
                            final result = await _apiService
                                .createBookingWithIds(bookingData);
                            print('Booking created successfully: $result');

                            // Hide loading snackbar
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();

                            // Show success dialog
                            SuccessDialog.show(
                              context,
                              title: 'BOOKING CREATED',
                              message: 'Your booking was successfully created!',
                              bookingNumber: result['bookingNo'] ?? 'N/A',
                            );

                            // Clear form
                            setState(() {
                              selectedOrigin = "Select Origin";
                              selectedDestination = "Select Destination";
                              selectedAgreementParty = "Search Selection";
                              selectedShipper = "Search Selection";
                              selectedConsignee = "Search Selection";
                              selectedCommodity = "Search Selection";
                              selectedEquipment = "Search Selection";
                              selectedVessel = "Search Selection";
                              selectedContainer = "Search Selection";
                              selectedService = null;
                              selectedPayment = null;
                            });

                            _departureDateController.clear();
                            _declaredValueController.clear();
                            _cargoDescController.clear();
                            _weightController.clear();
                            _sealController.clear();
                            _truckerController.clear();
                            _plateController.clear();
                            _driverController.clear();
                          } catch (e) {
                            // Error
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to create booking: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD4AF37),
                          foregroundColor: Colors.white,
                          elevation: 4,
                          shadowColor: const Color(
                            0xFFD4AF37,
                          ).withValues(alpha: 0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_circle_rounded, size: 22),
                            const SizedBox(width: 10),
                            Text(
                              widget.bookingToEdit != null
                                  ? 'UPDATE BOOKING'
                                  : 'SUBMIT BOOKING',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // === REUSABLE WIDGETS ===

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
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
          // Section header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B5E20).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: const Color(0xFF1B5E20), size: 20),
              ),
              const SizedBox(width: 12),
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
          const SizedBox(height: 18),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSearchField({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
    VoidCallback? onClear,
  }) {
    final isPlaceholder =
        value == "Select Origin" ||
        value == "Select Destination" ||
        value == "Search Selection";
    final hasContent = !isPlaceholder;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!, width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey[500], size: 20),
            const SizedBox(width: 12),
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
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 15,
                      color: isPlaceholder
                          ? Colors.grey[400]
                          : const Color(0xFF212121),
                      fontWeight: isPlaceholder
                          ? FontWeight.w400
                          : FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            hasContent && onClear != null
                ? InkWell(
                    onTap: onClear,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF5350).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Color(0xFFEF5350),
                        size: 18,
                      ),
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.search_rounded,
                      color: Color(0xFFD4AF37),
                      size: 18,
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildStyledTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.grey[500], size: 20),
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

  Widget _buildStyledDropdown({
    required String label,
    required String? value,
    required IconData icon,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: Color(0xFF212121),
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey[500], size: 20),
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
