class Booking {
  final String id;
  final String referenceNumber;
  final String route;
  final String origin;
  final String destination;
  final DateTime bookingDate;
  final DateTime departureDate;
  final String status; // BOOKED, COMPLETED, CANCELLED

  // Parties
  final String? agreementParty;
  final String? shipperParty;
  final String? consigneeParty;

  // Service & Payment
  final String? modeOfService;
  final String? modeOfPayment;

  // Cargo Details
  final String? commodityName;
  final String? equipmentType;
  final String? declaredValue;
  final String? cargoDescription;
  final String? weight;
  final String? containerNumber;
  final String? seal;

  // Vessel & Trucking
  final String? vesselName;
  final String? trucker;
  final String? plateNumber;
  final String? driver;

  // Customer Info
  final String? customerName;
  final String? contactNumber;

  Booking({
    required this.id,
    required this.referenceNumber,
    required this.route,
    required this.origin,
    required this.destination,
    required this.bookingDate,
    required this.departureDate,
    required this.status,
    this.agreementParty,
    this.shipperParty,
    this.consigneeParty,
    this.modeOfService,
    this.modeOfPayment,
    this.commodityName,
    this.equipmentType,
    this.declaredValue,
    this.cargoDescription,
    this.weight,
    this.containerNumber,
    this.seal,
    this.vesselName,
    this.trucker,
    this.plateNumber,
    this.driver,
    this.customerName,
    this.contactNumber,
  });

  // Convert JSON from API to Booking object
  factory Booking.fromJson(Map<String, dynamic> json) {
    // Extract party information from bookingParties array
    String? agreementParty;
    String? shipperParty;
    String? consigneeParty;

    if (json['bookingParties'] != null) {
      final parties = json['bookingParties'] as List;
      for (var party in parties) {
        final partyTypeId = party['partyTypeId'];
        final customer = party['customer'];
        if (customer != null) {
          final customerName =
              '${customer['firstName'] ?? ''} ${customer['middleName'] ?? ''} ${customer['lastName'] ?? ''}'
                  .trim();
          final customerCode = customer['customerCd'] ?? '';
          final fullDisplay = '$customerName ($customerCode)';

          if (partyTypeId == 10) {
            agreementParty = fullDisplay;
          } else if (partyTypeId == 11) {
            shipperParty = fullDisplay;
          } else if (partyTypeId == 12) {
            consigneeParty = fullDisplay;
          }
        }
      }
    }

    return Booking(
      id: json['bookingId']?.toString() ?? '0',
      referenceNumber: json['bookingNo'] ?? 'N/A',
      route:
          '${json['originLocation']?['locationDesc'] ?? 'Unknown'} ➔ ${json['destinationLocation']?['locationDesc'] ?? 'Unknown'}',
      origin: json['originLocation']?['locationDesc'] ?? 'Unknown',
      destination: json['destinationLocation']?['locationDesc'] ?? 'Unknown',
      bookingDate: json['createDttm'] != null
          ? DateTime.parse(json['createDttm'])
          : DateTime.now(),
      departureDate: json['vesselSchedule']?['etd'] != null
          ? DateTime.parse(json['vesselSchedule']['etd'])
          : DateTime.now(),
      status: json['status']?['statusDesc'] ?? 'PENDING',
      agreementParty: agreementParty,
      shipperParty: shipperParty,
      consigneeParty: consigneeParty,
      modeOfService: 'N/A', // TransportService not included yet
      modeOfPayment: json['paymentMode']?['paymentModeDesc'],
      commodityName: json['commodity']?['commodityDesc'],
      equipmentType: json['equipment']?['equipmentDesc'],
      declaredValue: json['declaredValue']?.toString(),
      cargoDescription: json['cargoDescription'],
      weight: json['weight']?.toString(),
      containerNumber: json['container']?['containerNo'],
      seal: json['sealNumber'],
      vesselName:
          json['vessel']?['vesselDesc'] ??
          json['vesselSchedule']?['vessel']?['vesselDesc'],
      trucker: json['trucker'],
      plateNumber: json['plateNumber'],
      driver: json['driver'],
      customerName: null, // Not stored in current database schema
      contactNumber: null, // Not stored in current database schema
    );
  }

  // Convert Booking object to JSON for API
  Map<String, dynamic> toJson() {
    // Location mappings (these should ideally come from API)
    final locationMap = {
      'Cebu': 4,
      'Manila': 10,
      'Batangas': 2,
      'Cagayan de Oro': 3,
      'Davao': 5,
      'Zamboanga': 11,
    };

    // Service mappings
    final serviceMap = {'CFS/DOOR': 9, 'PIER/PIER': 10, 'DOOR/DOOR': 11};

    return {
      'BookingNo': referenceNumber,
      'StatusId': 4, // Default to BOOKED status
      'TransportServiceId':
          serviceMap[modeOfService] ?? 9, // Default to CFS/DOOR
      'OriginLocationId': locationMap[origin] ?? 4, // Default to Cebu
      'DestinationLocationId':
          locationMap[destination] ?? 10, // Default to Manila
      'VesselScheduleId': 1, // Default to first schedule
      'ConfirmBookingUserId': null,
      'ConfirmBookingDttm': null,
      'CancelBookingUserId': null,
      'CancelBookingDttm': null,
      'CancelBookingRemarks': null,
      'CreateUserId': 'SYSTEM',
      'CreateDttm': DateTime.now().toUtc().toIso8601String(),
      'UpdateUserId': 'SYSTEM',
      'UpdateDttm': DateTime.now().toUtc().toIso8601String(),
    };
  }

  // Helper method to get formatted date
  String getFormattedDate() {
    return '${departureDate.year}-${departureDate.month.toString().padLeft(2, '0')}-${departureDate.day.toString().padLeft(2, '0')}';
  }

  // Helper method to check if booking is active
  bool isActive() {
    return status == 'BOOKED' || status == 'PENDING';
  }
}
