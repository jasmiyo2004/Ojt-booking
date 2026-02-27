import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/booking_model.dart';
import '../models/booking_stats.dart';
import '../models/location_model.dart';
import '../models/transport_service_model.dart';
import '../models/payment_mode_model.dart';
import '../models/equipment_model.dart';
import '../models/vessel_model.dart';
import '../models/commodity_model.dart';
import '../models/customer_model.dart';
import '../models/container_model.dart';
import '../models/vessel_schedule_model.dart';
import '../models/route_stats_model.dart';

class ApiService {
  // TODO: Replace with your actual C# API URL when ready
  static const String baseUrl = 'http://localhost:5022/api';

  // Singleton pattern - only one instance of ApiService
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Public debug fields to let UI know where data came from
  String lastStatsSource = 'unknown'; // 'api' or 'mock'
  String lastBookingsSource = 'unknown';

  // ============================================
  // BOOKINGS API
  // ============================================

  /// Get all bookings
  /// Later: GET /api/bookings
  Future<List<Booking>> getBookings() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/bookings'))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        lastBookingsSource = 'api';
        return data.map((json) => Booking.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load bookings: ${response.statusCode}');
      }
    } catch (e, st) {
      // Fallback to mock data if API fails — log error + stack for debugging
      print(
        'API call failed (getBookings), falling back to mock data. Error: $e',
      );
      print(st);
      lastBookingsSource = 'mock';
      return getMockBookings();
    }
  }

  /// Get recent bookings (last 5)
  /// GET /api/bookings/recent
  Future<List<Booking>> getRecentBookings() async {
    try {
      print(
        'API Service: Fetching recent bookings from $baseUrl/bookings/recent',
      );
      final response = await http
          .get(Uri.parse('$baseUrl/bookings/recent'))
          .timeout(const Duration(seconds: 10));

      print(
        'API Service: Recent bookings response status: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        lastBookingsSource = 'api';
        print(
          'API Service: Successfully loaded ${data.length} recent bookings from API',
        );
        return data.map((json) => Booking.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to load recent bookings: ${response.statusCode}',
        );
      }
    } catch (e, st) {
      // Fallback to mock data if API fails
      print(
        'API call failed (getRecentBookings), falling back to mock data. Error: $e',
      );
      print(st);
      lastBookingsSource = 'mock';
      return getMockBookings().take(5).toList();
    }
  }

  /// Get booking by ID
  /// Later: GET /api/bookings/{id}
  Future<Booking?> getBookingById(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));

    // TODO: Replace with actual API call
    // final response = await http.get(Uri.parse('$baseUrl/bookings/$id'));

    final bookings = await getBookings();
    try {
      return bookings.firstWhere((b) => b.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Create new booking
  /// Later: POST /api/bookings
  Future<Booking> createBooking(Booking booking) async {
    try {
      print('API Service: Attempting to create booking...');
      final jsonData = booking.toJson();
      print('API Service: JSON data: $jsonData');

      final response = await http
          .post(
            Uri.parse('$baseUrl/bookings'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(jsonData),
          )
          .timeout(const Duration(seconds: 10));

      print('API Service: Response status: ${response.statusCode}');
      print('API Service: Response body: ${response.body}');

      if (response.statusCode == 201) {
        final createdBooking = Booking.fromJson(json.decode(response.body));
        print(
          'API Service: Booking created successfully with ID: ${createdBooking.id}',
        );
        return createdBooking;
      } else {
        throw Exception(
          'Failed to create booking: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e, st) {
      // Fallback - just return the booking (for now)
      print(
        'API Service: API call failed for createBooking, returning local object. Error: $e',
      );
      print('API Service: Stack trace: $st');
      return booking;
    }
  }

  /// Create booking with raw data (IDs)
  Future<Map<String, dynamic>> createBookingWithIds(
    Map<String, dynamic> bookingData,
  ) async {
    try {
      print('API Service: Creating booking with IDs: $bookingData');

      final response = await http
          .post(
            Uri.parse('$baseUrl/bookings'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(bookingData),
          )
          .timeout(const Duration(seconds: 10));

      print('API Service: Response status: ${response.statusCode}');
      print('API Service: Response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
          'Failed to create booking: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('API Service: Error creating booking: $e');
      rethrow;
    }
  }

  /// Update booking with raw data (IDs)
  Future<Map<String, dynamic>> updateBookingWithIds(
    String id,
    Map<String, dynamic> bookingData,
  ) async {
    try {
      print('API Service: Updating booking $id with IDs: $bookingData');

      final response = await http
          .put(
            Uri.parse('$baseUrl/bookings/$id'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(bookingData),
          )
          .timeout(const Duration(seconds: 10));

      print('API Service: Response status: ${response.statusCode}');
      print('API Service: Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        // 204 No Content is also a valid success response for PUT
        if (response.body.isNotEmpty) {
          return json.decode(response.body);
        } else {
          // Return the input data if no body returned
          return bookingData;
        }
      } else {
        throw Exception(
          'Failed to update booking: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('API Service: Error updating booking: $e');
      rethrow;
    }
  }

  /// Update booking
  /// Later: PUT /api/bookings/{id}
  Future<Booking> updateBooking(String id, Booking booking) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl/bookings/$id'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(booking.toJson()),
          )
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return Booking.fromJson(data);
      } else {
        throw Exception('Failed to update booking: ${response.statusCode}');
      }
    } catch (e, st) {
      print(
        'API call failed (updateBooking), returning local booking. Error: $e',
      );
      print(st);
      return booking;
    }
  }

  /// Cancel booking
  /// Later: DELETE /api/bookings/{id} or PATCH /api/bookings/{id}/cancel
  Future<bool> cancelBooking(String id, {String? remarks}) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/bookings/$id/cancel'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'UserId': 'SYSTEM', 'Remarks': remarks ?? ''}),
          )
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) return true;
      return false;
    } catch (e, st) {
      print('API call failed (cancelBooking). Error: $e');
      print(st);
      return false;
    }
  }

  // ============================================
  // LOCATIONS API
  // ============================================

  /// Get all locations
  /// GET /api/locations
  Future<List<Location>> getLocations() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/locations'))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        // Debug: Print first location JSON
        if (data.isNotEmpty) {
          print('DEBUG API: First location JSON: ${data[0]}');
        }
        return data.map((json) => Location.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load locations: ${response.statusCode}');
      }
    } catch (e) {
      print(
        'API call failed (getLocations), falling back to mock data. Error: $e',
      );
      return getMockLocations();
    }
  }

  // ============================================
  // TRANSPORT SERVICES API
  // ============================================

  /// Get all transport services
  /// GET /api/transportservices
  Future<List<TransportService>> getTransportServices() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/transportservices'))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => TransportService.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to load transport services: ${response.statusCode}',
        );
      }
    } catch (e) {
      print(
        'API call failed (getTransportServices), falling back to mock data. Error: $e',
      );
      return getMockTransportServices();
    }
  }

  // ============================================
  // STATISTICS API
  // ============================================

  /// Get booking statistics
  /// Later: GET /api/bookings/stats
  Future<BookingStats> getBookingStats() async {
    try {
      print(
        'API Service: Attempting to get booking stats from $baseUrl/bookings/stats',
      );
      final response = await http
          .get(Uri.parse('$baseUrl/bookings/stats'))
          .timeout(const Duration(seconds: 10));
      print('API Service: Stats response status: ${response.statusCode}');
      print('API Service: Stats response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        lastStatsSource = 'api';
        final stats = BookingStats.fromJson(data);
        print(
          'API Service: Successfully parsed stats: ${stats.totalBookings} total, ${stats.bookedToday} booked today, ${stats.numberOfUsers} users, ${stats.cancelled} cancelled',
        );
        return stats;
      } else {
        throw Exception(
          'Failed to load stats: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      // Fallback to mock data if API fails — log details
      print(
        'API call failed (getBookingStats), falling back to mock stats. Error: $e',
      );
      try {
        rethrow; // rethrow to capture stack if available
      } catch (err, st) {
        print(st);
      }
      lastStatsSource = 'mock';
      return getMockStats();
    }
  }

  /// Get route statistics with date filtering
  /// GET /api/bookings/routes
  Future<RouteStatsResponse> getRouteStatistics({
    String period = 'month',
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var url = '$baseUrl/bookings/routes?period=$period';

      if (startDate != null && endDate != null) {
        final startStr = startDate.toIso8601String();
        final endStr = endDate.toIso8601String();
        url = '$baseUrl/bookings/routes?startDate=$startStr&endDate=$endStr';
      }

      print('API Service: Fetching route statistics from $url');
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));

      print('API Service: Route stats response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return RouteStatsResponse.fromJson(data);
      } else {
        throw Exception(
          'Failed to load route statistics: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('API call failed (getRouteStatistics): $e');
      rethrow;
    }
  }

  // ============================================
  // MOCK DATA (Remove when connecting to real API)
  // ============================================

  List<Booking> getMockBookings() {
    return [
      Booking(
        id: '1',
        referenceNumber: 'BK-2026-005',
        route: 'CEBU ➔ MANILA',
        origin: 'CEBU',
        destination: 'MANILA',
        bookingDate: DateTime(2026, 2, 15),
        departureDate: DateTime(2026, 2, 20),
        status: 'BOOKED',
        customerName: 'Juan Dela Cruz',
        contactNumber: '09123456789',
      ),
      Booking(
        id: '2',
        referenceNumber: 'BK-2026-004',
        route: 'MANILA ➔ CEBU',
        origin: 'MANILA',
        destination: 'CEBU',
        bookingDate: DateTime(2026, 2, 14),
        departureDate: DateTime(2026, 2, 19),
        status: 'COMPLETED',
        customerName: 'Maria Santos',
        contactNumber: '09187654321',
      ),
      Booking(
        id: '3',
        referenceNumber: 'BK-2026-003',
        route: 'CEBU ➔ CDO',
        origin: 'CEBU',
        destination: 'CDO',
        bookingDate: DateTime(2026, 2, 13),
        departureDate: DateTime(2026, 2, 18),
        status: 'CANCELLED',
        customerName: 'Pedro Reyes',
        contactNumber: '09198765432',
      ),
      Booking(
        id: '4',
        referenceNumber: 'BK-2026-002',
        route: 'CEBU ➔ MANILA',
        origin: 'CEBU',
        destination: 'MANILA',
        bookingDate: DateTime(2026, 2, 12),
        departureDate: DateTime(2026, 2, 17),
        status: 'BOOKED',
        customerName: 'Ana Garcia',
        contactNumber: '09176543210',
      ),
      Booking(
        id: '5',
        referenceNumber: 'BK-2026-001',
        route: 'MANILA ➔ CEBU',
        origin: 'MANILA',
        destination: 'CEBU',
        bookingDate: DateTime(2026, 2, 11),
        departureDate: DateTime(2026, 2, 16),
        status: 'COMPLETED',
        customerName: 'Jose Rizal',
        contactNumber: '09165432109',
      ),
    ];
  }

  BookingStats getMockStats() {
    return BookingStats(
      totalBookings: 150,
      bookedToday: 15,
      numberOfUsers: 25,
      cancelled: 10,
    );
  }

  List<Location> getMockLocations() {
    return [
      Location(
        locationId: 1,
        locationDesc: 'CEBU PORT',
        locationCD: 'VISCEB',
        locationTypeDesc: 'PIER',
      ),
      Location(
        locationId: 2,
        locationDesc: 'MANILA PORT',
        locationCD: 'LUZMNI',
        locationTypeDesc: 'PIER',
      ),
      Location(
        locationId: 3,
        locationDesc: 'DAVAO PORT',
        locationCD: 'MINDVO',
        locationTypeDesc: 'PIER',
      ),
      Location(
        locationId: 4,
        locationDesc: 'CAGAYAN PORT',
        locationCD: 'MINCGY',
        locationTypeDesc: 'PIER',
      ),
      Location(
        locationId: 5,
        locationDesc: 'BATANGAS PORT',
        locationCD: 'LUZBAT',
        locationTypeDesc: 'PIER',
      ),
      Location(
        locationId: 6,
        locationDesc: 'ZAMBOANGA PORT',
        locationCD: 'MINZAM',
        locationTypeDesc: 'PIER',
      ),
      Location(
        locationId: 7,
        locationDesc: 'ILOILO PORT',
        locationCD: 'VISILO',
        locationTypeDesc: 'PIER',
      ),
      Location(
        locationId: 8,
        locationDesc: 'BACOLOD PORT',
        locationCD: 'VISBCD',
        locationTypeDesc: 'PIER',
      ),
      Location(
        locationId: 9,
        locationDesc: 'CAPAS TARLAC',
        locationCD: 'LUZCAP',
        locationTypeDesc: 'DOOR',
      ),
    ];
  }

  List<TransportService> getMockTransportServices() {
    return [
      TransportService(
        transportServiceId: 1,
        transportServiceDesc: 'Pier to Pier',
      ),
      TransportService(
        transportServiceId: 2,
        transportServiceDesc: 'Door to Door',
      ),
      TransportService(
        transportServiceId: 3,
        transportServiceDesc: 'Pier to Door',
      ),
      TransportService(
        transportServiceId: 4,
        transportServiceDesc: 'Door to Pier',
      ),
    ];
  }

  /// Get all payment modes
  /// GET /api/paymentmodes
  Future<List<PaymentMode>> getPaymentModes() async {
    const url = '$baseUrl/paymentmodes';
    try {
      final response = await http
          .get(Uri.parse(url), headers: {'Content-Type': 'application/json'})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => PaymentMode.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load payment modes: ${response.statusCode}');
      }
    } catch (e) {
      print(
        'API call failed (getPaymentModes), falling back to mock data. Error: $e',
      );
      return getMockPaymentModes();
    }
  }

  List<PaymentMode> getMockPaymentModes() {
    return [
      PaymentMode(paymentModeId: 1, paymentModeDesc: 'Prepaid'),
      PaymentMode(paymentModeId: 2, paymentModeDesc: 'Collect'),
    ];
  }

  /// Get all equipment
  /// GET /api/equipment
  Future<List<Equipment>> getEquipment() async {
    const url = '$baseUrl/equipment';
    try {
      final response = await http
          .get(Uri.parse(url), headers: {'Content-Type': 'application/json'})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Equipment.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load equipment: ${response.statusCode}');
      }
    } catch (e) {
      print(
        'API call failed (getEquipment), falling back to mock data. Error: $e',
      );
      return getMockEquipment();
    }
  }

  List<Equipment> getMockEquipment() {
    return [
      Equipment(
        equipmentId: 1,
        equipmentCd: '20FT',
        equipmentDesc: '20ft Container',
      ),
      Equipment(
        equipmentId: 2,
        equipmentCd: '40FT',
        equipmentDesc: '40ft Container',
      ),
      Equipment(
        equipmentId: 3,
        equipmentCd: 'RFCN',
        equipmentDesc: 'Refrigerated Container',
      ),
    ];
  }

  /// Get all vessels
  /// GET /api/vessels
  Future<List<Vessel>> getVessels() async {
    const url = '$baseUrl/vessels';
    try {
      final response = await http
          .get(Uri.parse(url), headers: {'Content-Type': 'application/json'})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Vessel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load vessels: ${response.statusCode}');
      }
    } catch (e) {
      print(
        'API call failed (getVessels), falling back to mock data. Error: $e',
      );
      return getMockVessels();
    }
  }

  List<Vessel> getMockVessels() {
    return [
      Vessel(vesselId: 1, vesselCd: 'MVPS', vesselDesc: 'MV Pacific Star'),
      Vessel(vesselId: 2, vesselCd: 'MVOV', vesselDesc: 'MV Ocean Voyager'),
      Vessel(vesselId: 3, vesselCd: 'MVSE', vesselDesc: 'MV Sea Explorer'),
    ];
  }

  /// Get all commodities
  /// GET /api/commodities
  Future<List<Commodity>> getCommodities() async {
    const url = '$baseUrl/commodities';
    try {
      final response = await http
          .get(Uri.parse(url), headers: {'Content-Type': 'application/json'})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Commodity.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load commodities: ${response.statusCode}');
      }
    } catch (e) {
      print(
        'API call failed (getCommodities), falling back to mock data. Error: $e',
      );
      return getMockCommodities();
    }
  }

  List<Commodity> getMockCommodities() {
    return [
      Commodity(
        commodityId: 1,
        commodityCd: 'ELEC',
        commodityDesc: 'Electronics',
      ),
      Commodity(commodityId: 2, commodityCd: 'TEXT', commodityDesc: 'Textiles'),
      Commodity(
        commodityId: 3,
        commodityCd: 'FOOD',
        commodityDesc: 'Food Products',
      ),
    ];
  }

  /// GET /api/containers
  Future<List<ContainerData>> getContainers() async {
    const url = '$baseUrl/containers';
    try {
      final response = await http
          .get(Uri.parse(url), headers: {'Content-Type': 'application/json'})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => ContainerData.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load containers: ${response.statusCode}');
      }
    } catch (e) {
      print(
        'API call failed (getContainers), falling back to mock data. Error: $e',
      );
      return getMockContainers();
    }
  }

  List<ContainerData> getMockContainers() {
    return [
      ContainerData(
        containerId: 1,
        containerNo: 'GCNU1234567',
        containerType: '20FT',
        status: 'Available',
      ),
      ContainerData(
        containerId: 2,
        containerNo: 'GCNU2345678',
        containerType: '40FT',
        status: 'Available',
      ),
      ContainerData(
        containerId: 3,
        containerNo: 'GCNU3456789',
        containerType: '20FT',
        status: 'Available',
      ),
      ContainerData(
        containerId: 4,
        containerNo: 'GCNU4567890',
        containerType: '40FT',
        status: 'Available',
      ),
      ContainerData(
        containerId: 5,
        containerNo: 'GCNU5678901',
        containerType: '20FT',
        status: 'Available',
      ),
    ];
  }

  /// Get agreement party customers (PartyTypeId = 10)
  /// GET /api/customers/agreement-parties
  Future<List<Customer>> getAgreementParties() async {
    final url = '$baseUrl/customers/agreement-parties';
    try {
      final response = await http
          .get(Uri.parse(url), headers: {'Content-Type': 'application/json'})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Customer.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to load agreement parties: ${response.statusCode}',
        );
      }
    } catch (e) {
      print(
        'API call failed (getAgreementParties), falling back to mock data. Error: $e',
      );
      return getMockAgreementParties();
    }
  }

  /// Get shipper party customers (PartyTypeId = 11)
  /// GET /api/customers/shipper-parties
  Future<List<Customer>> getShipperParties() async {
    const url = '$baseUrl/customers/shipper-parties';
    try {
      final response = await http
          .get(Uri.parse(url), headers: {'Content-Type': 'application/json'})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Customer.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to load shipper parties: ${response.statusCode}',
        );
      }
    } catch (e) {
      print(
        'API call failed (getShipperParties), falling back to mock data. Error: $e',
      );
      return getMockShipperParties();
    }
  }

  /// Get consignee party customers (PartyTypeId = 12)
  /// GET /api/customers/consignee-parties
  Future<List<Customer>> getConsigneeParties() async {
    const url = '$baseUrl/customers/consignee-parties';
    try {
      final response = await http
          .get(Uri.parse(url), headers: {'Content-Type': 'application/json'})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Customer.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to load consignee parties: ${response.statusCode}',
        );
      }
    } catch (e) {
      print(
        'API call failed (getConsigneeParties), falling back to mock data. Error: $e',
      );
      return getMockConsigneeParties();
    }
  }

  List<Customer> getMockAgreementParties() {
    return [
      Customer(
        customerId: 1,
        customerCd: 'AGR001',
        firstName: 'Juan',
        middleName: 'Santos',
        lastName: 'Dela Cruz',
        partyTypeId: 10,
        partyTypeDesc: 'Agreement Party',
      ),
      Customer(
        customerId: 2,
        customerCd: 'AGR002',
        firstName: 'Maria',
        middleName: 'Garcia',
        lastName: 'Reyes',
        partyTypeId: 10,
        partyTypeDesc: 'Agreement Party',
      ),
      Customer(
        customerId: 3,
        customerCd: 'AGR003',
        firstName: 'Pedro',
        middleName: 'Lopez',
        lastName: 'Santos',
        partyTypeId: 10,
        partyTypeDesc: 'Agreement Party',
      ),
    ];
  }

  List<Customer> getMockShipperParties() {
    return [
      Customer(
        customerId: 4,
        customerCd: 'SHP001',
        firstName: 'Ana',
        middleName: 'Cruz',
        lastName: 'Mendoza',
        partyTypeId: 11,
        partyTypeDesc: 'Shipper Party',
      ),
      Customer(
        customerId: 5,
        customerCd: 'SHP002',
        firstName: 'Jose',
        middleName: 'Ramos',
        lastName: 'Fernandez',
        partyTypeId: 11,
        partyTypeDesc: 'Shipper Party',
      ),
      Customer(
        customerId: 6,
        customerCd: 'SHP003',
        firstName: 'Rosa',
        middleName: 'Torres',
        lastName: 'Villanueva',
        partyTypeId: 11,
        partyTypeDesc: 'Shipper Party',
      ),
    ];
  }

  List<Customer> getMockConsigneeParties() {
    return [
      Customer(
        customerId: 7,
        customerCd: 'CON001',
        firstName: 'Carlos',
        middleName: 'Diaz',
        lastName: 'Martinez',
        partyTypeId: 12,
        partyTypeDesc: 'Consignee Party',
      ),
      Customer(
        customerId: 8,
        customerCd: 'CON002',
        firstName: 'Elena',
        middleName: 'Gomez',
        lastName: 'Rivera',
        partyTypeId: 12,
        partyTypeDesc: 'Consignee Party',
      ),
      Customer(
        customerId: 9,
        customerCd: 'CON003',
        firstName: 'Miguel',
        middleName: 'Hernandez',
        lastName: 'Castro',
        partyTypeId: 12,
        partyTypeDesc: 'Consignee Party',
      ),
    ];
  }

  // ============================================
  // VESSEL SCHEDULES API
  // ============================================

  /// Get vessel schedules with optional filters
  /// GET /api/vesselschedules?originLocationId=1&destinationLocationId=2&vesselId=3
  Future<List<VesselSchedule>> getVesselSchedules({
    int? originLocationId,
    int? destinationLocationId,
    int? vesselId,
  }) async {
    try {
      var url = '$baseUrl/vesselschedules?';
      final params = <String>[];

      if (originLocationId != null) {
        params.add('originLocationId=$originLocationId');
      }
      if (destinationLocationId != null) {
        params.add('destinationLocationId=$destinationLocationId');
      }
      if (vesselId != null) {
        params.add('vesselId=$vesselId');
      }

      url += params.join('&');

      final response = await http
          .get(Uri.parse(url), headers: {'Content-Type': 'application/json'})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => VesselSchedule.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to load vessel schedules: ${response.statusCode}',
        );
      }
    } catch (e) {
      print(
        'API call failed (getVesselSchedules), falling back to mock data. Error: $e',
      );
      return getMockVesselSchedules(
        originLocationId: originLocationId,
        destinationLocationId: destinationLocationId,
        vesselId: vesselId,
      );
    }
  }

  List<VesselSchedule> getMockVesselSchedules({
    int? originLocationId,
    int? destinationLocationId,
    int? vesselId,
  }) {
    final allSchedules = [
      VesselSchedule(
        vesselScheduleId: 1,
        originPortId: 1,
        destinationPortId: 4,
        etd: DateTime(2025, 12, 27, 8, 0),
        eta: DateTime(2025, 12, 29, 4, 0),
        vesselId: 1,
        originPortCd: 'MNL',
        originPortDesc: 'Manila',
        destinationPortCd: 'CEB',
        destinationPortDesc: 'Cebu',
        vesselCd: 'VSL001',
        vesselName: 'MV Pacific Star',
      ),
      VesselSchedule(
        vesselScheduleId: 2,
        originPortId: 1,
        destinationPortId: 4,
        etd: DateTime(2026, 1, 1, 2, 0),
        eta: DateTime(2026, 1, 1, 2, 0),
        vesselId: 1,
        originPortCd: 'MNL',
        originPortDesc: 'Manila',
        destinationPortCd: 'CEB',
        destinationPortDesc: 'Cebu',
        vesselCd: 'VSL001',
        vesselName: 'MV Pacific Star',
      ),
      VesselSchedule(
        vesselScheduleId: 3,
        originPortId: 3,
        destinationPortId: 5,
        etd: DateTime(2025, 12, 27, 8, 0),
        eta: DateTime(2025, 12, 29, 4, 0),
        vesselId: 1,
        originPortCd: 'CGY',
        originPortDesc: 'Cagayan de Oro',
        destinationPortCd: 'ILO',
        destinationPortDesc: 'Iloilo',
        vesselCd: 'VSL001',
        vesselName: 'MV Pacific Star',
      ),
      VesselSchedule(
        vesselScheduleId: 4,
        originPortId: 4,
        destinationPortId: 2,
        etd: DateTime(2025, 12, 30, 6, 0),
        eta: DateTime(2026, 1, 1, 1, 0),
        vesselId: 2,
        originPortCd: 'CEB',
        originPortDesc: 'Cebu',
        destinationPortCd: 'DVA',
        destinationPortDesc: 'Davao',
        vesselCd: 'VSL002',
        vesselName: 'MV Ocean Voyager',
      ),
      VesselSchedule(
        vesselScheduleId: 5,
        originPortId: 5,
        destinationPortId: 8,
        etd: DateTime(2026, 1, 2, 6, 0),
        eta: DateTime(2026, 1, 5, 4, 0),
        vesselId: 2,
        originPortCd: 'ILO',
        originPortDesc: 'Iloilo',
        destinationPortCd: 'ZAM',
        destinationPortDesc: 'Zamboanga',
        vesselCd: 'VSL002',
        vesselName: 'MV Ocean Voyager',
      ),
      VesselSchedule(
        vesselScheduleId: 6,
        originPortId: 6,
        destinationPortId: 4,
        etd: DateTime(2026, 1, 2, 6, 0),
        eta: DateTime(2026, 1, 9, 4, 0),
        vesselId: 3,
        originPortCd: 'GES',
        originPortDesc: 'General Santos',
        destinationPortCd: 'CEB',
        destinationPortDesc: 'Cebu',
        vesselCd: 'VSL003',
        vesselName: 'MV Island Express',
      ),
      VesselSchedule(
        vesselScheduleId: 7,
        originPortId: 7,
        destinationPortId: 3,
        etd: DateTime(2026, 1, 3, 19, 0),
        eta: DateTime(2026, 1, 9, 4, 0),
        vesselId: 4,
        originPortCd: 'TAC',
        originPortDesc: 'Tacloban',
        destinationPortCd: 'CGY',
        destinationPortDesc: 'Cagayan de Oro',
        vesselCd: 'VSL004',
        vesselName: 'MV Coastal Trader',
      ),
      VesselSchedule(
        vesselScheduleId: 8,
        originPortId: 8,
        destinationPortId: 12,
        etd: DateTime(2025, 12, 21, 11, 0),
        eta: DateTime(2025, 12, 27, 8, 0),
        vesselId: 10,
        originPortCd: 'ZAM',
        originPortDesc: 'Zamboanga',
        destinationPortCd: 'BAC',
        destinationPortDesc: 'Bacolod',
        vesselCd: 'VSL010',
        vesselName: 'MV Cargo Master',
      ),
      VesselSchedule(
        vesselScheduleId: 9,
        originPortId: 9,
        destinationPortId: 10,
        etd: DateTime(2025, 12, 21, 11, 0),
        eta: DateTime(2025, 12, 30, 22, 0),
        vesselId: 10,
        originPortCd: 'DUM',
        originPortDesc: 'Dumaguete',
        destinationPortCd: 'TAG',
        destinationPortDesc: 'Tagbilaran',
        vesselCd: 'VSL010',
        vesselName: 'MV Cargo Master',
      ),
    ];

    // Apply filters
    var filtered = allSchedules.where((schedule) {
      if (originLocationId != null &&
          schedule.originPortId != originLocationId) {
        return false;
      }
      if (destinationLocationId != null &&
          schedule.destinationPortId != destinationLocationId) {
        return false;
      }
      if (vesselId != null && schedule.vesselId != vesselId) {
        return false;
      }
      return true;
    }).toList();

    return filtered;
  }

  // ============================================
  // USERS API
  // ============================================

  /// Get all users
  /// GET /api/users
  Future<List<dynamic>> getUsers() async {
    const url = '$baseUrl/users';
    try {
      print('API Service: Fetching users from $url');

      final response = await http
          .get(Uri.parse(url), headers: {'Content-Type': 'application/json'})
          .timeout(const Duration(seconds: 10));

      print('API Service: getUsers response status: ${response.statusCode}');
      print('API Service: getUsers response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('API Service: Loaded ${data.length} users from API');
        return data;
      } else {
        print(
          'API Service: Failed to load users - Status ${response.statusCode}',
        );
        throw Exception('Failed to load users: ${response.statusCode}');
      }
    } catch (e) {
      print('API call failed (getUsers), falling back to mock data. Error: $e');
      return getMockUsers();
    }
  }

  /// Get user types
  /// GET /api/usertypes
  Future<List<dynamic>> getUserTypes() async {
    const url = '$baseUrl/usertypes';
    try {
      print('API Service: Fetching user types from $url');

      final response = await http
          .get(Uri.parse(url), headers: {'Content-Type': 'application/json'})
          .timeout(const Duration(seconds: 10));

      print(
        'API Service: getUserTypes response status: ${response.statusCode}',
      );
      print('API Service: getUserTypes response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('API Service: Loaded ${data.length} user types from API');

        // If API returns empty array, use mock data
        if (data.isEmpty) {
          print('API Service: API returned empty array, using mock data');
          return getMockUserTypes();
        }

        return data;
      } else {
        throw Exception('Failed to load user types: ${response.statusCode}');
      }
    } catch (e) {
      print(
        'API call failed (getUserTypes), falling back to mock data. Error: $e',
      );
      return getMockUserTypes();
    }
  }

  /// Create new user
  /// POST /api/users
  Future<Map<String, dynamic>> createUser(Map<String, dynamic> userData) async {
    const url = '$baseUrl/users';
    try {
      print('API Service: Creating user with data: $userData');

      final response = await http
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(userData),
          )
          .timeout(const Duration(seconds: 10));

      print('API Service: Response status: ${response.statusCode}');
      print('API Service: Response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
          'Failed to create user: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('API Service: Error creating user: $e');
      rethrow;
    }
  }

  /// Update user
  /// PUT /api/users/{id}
  Future<Map<String, dynamic>> updateUser(
    int userId,
    Map<String, dynamic> userData,
  ) async {
    final url = '$baseUrl/users/$userId';
    try {
      final response = await http
          .put(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(userData),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
          'Failed to update user: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('API Service: Error updating user: $e');
      rethrow;
    }
  }

  /// Delete user
  /// DELETE /api/users/{id}
  Future<bool> deleteUser(int userId) async {
    final url = '$baseUrl/users/$userId';
    try {
      final response = await http
          .delete(Uri.parse(url))
          .timeout(const Duration(seconds: 10));

      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      print('API Service: Error deleting user: $e');
      return false;
    }
  }

  // Mock data for users
  List<dynamic> getMockUsers() {
    return [
      {
        'userId': 1,
        'userIdType': 1,
        'firstName': 'John',
        'middleName': 'A',
        'lastName': 'Doe',
        'email': 'john.doe@example.com',
        'number': '09123456789',
        'userCode': 'USR001',
        'statusId': 1,
        'statusDesc': 'Active',
        'userTypeDesc': 'Admin',
        'userTypeCd': 'ADMIN',
      },
      {
        'userId': 2,
        'userIdType': 2,
        'firstName': 'Jane',
        'middleName': 'B',
        'lastName': 'Smith',
        'email': 'jane.smith@example.com',
        'number': '09187654321',
        'userCode': 'USR002',
        'statusId': 1,
        'statusDesc': 'Active',
        'userTypeDesc': 'User',
        'userTypeCd': 'USER',
      },
    ];
  }

  List<dynamic> getMockUserTypes() {
    return [
      {'userTypeId': 1, 'userTypeCd': 'ADMIN', 'userTypeDesc': 'Admin'},
      {'userTypeId': 2, 'userTypeCd': 'USER', 'userTypeDesc': 'User'},
    ];
  }
}
