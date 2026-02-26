import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/booking_model.dart';

class ApiTestPage extends StatefulWidget {
  const ApiTestPage({super.key});

  @override
  State<ApiTestPage> createState() => _ApiTestPageState();
}

class _ApiTestPageState extends State<ApiTestPage> {
  final ApiService _apiService = ApiService();
  String _testResult = 'Press a button to test';
  bool _isLoading = false;

  Future<void> _testGetBookings() async {
    setState(() {
      _isLoading = true;
      _testResult = 'Testing GET /api/bookings...';
    });

    try {
      final bookings = await _apiService.getBookings();
      setState(() {
        _testResult =
            '''
✅ SUCCESS!
Source: ${_apiService.lastBookingsSource}
Found ${bookings.length} bookings
First booking: ${bookings.isNotEmpty ? bookings.first.referenceNumber : 'None'}

${_apiService.lastBookingsSource == 'mock' ? '⚠️ Using MOCK data - API not connected' : '🎉 Connected to real API!'}
''';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _testResult = '❌ ERROR:\n$e';
        _isLoading = false;
      });
    }
  }

  Future<void> _testGetStats() async {
    setState(() {
      _isLoading = true;
      _testResult = 'Testing GET /api/bookings/stats...';
    });

    try {
      final stats = await _apiService.getBookingStats();
      setState(() {
        _testResult =
            '''
✅ SUCCESS!
Source: ${_apiService.lastStatsSource}
Total: ${stats.totalBookings}
Booked: ${stats.booked}
Completed: ${stats.completed}
Cancelled: ${stats.cancelled}

${_apiService.lastStatsSource == 'mock' ? '⚠️ Using MOCK data - API not connected' : '🎉 Connected to real API!'}
''';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _testResult = '❌ ERROR:\n$e';
        _isLoading = false;
      });
    }
  }

  Future<void> _testCreateBooking() async {
    setState(() {
      _isLoading = true;
      _testResult = 'Testing POST /api/bookings...';
    });

    try {
      final testBooking = Booking(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        referenceNumber: 'TEST-${DateTime.now().millisecondsSinceEpoch}',
        route: 'TEST → TEST',
        origin: 'TEST ORIGIN',
        destination: 'TEST DESTINATION',
        bookingDate: DateTime.now(),
        departureDate: DateTime.now().add(const Duration(days: 5)),
        status: 'BOOKED',
        customerName: 'Test Customer',
        contactNumber: '09123456789',
      );

      final result = await _apiService.createBooking(testBooking);
      setState(() {
        _testResult =
            '''
✅ Booking Created!
ID: ${result.id}
Reference: ${result.referenceNumber}
Route: ${result.route}

Check your database to see if it was saved!
''';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _testResult = '❌ ERROR:\n$e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Connection Test'),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'API Configuration',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Base URL: ${ApiService.baseUrl}'),
                    const SizedBox(height: 4),
                    const Text(
                      'Make sure your C# API is running on this URL!',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _testGetBookings,
              icon: const Icon(Icons.list),
              label: const Text('Test GET Bookings'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _testGetStats,
              icon: const Icon(Icons.bar_chart),
              label: const Text('Test GET Stats'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _testCreateBooking,
              icon: const Icon(Icons.add),
              label: const Text('Test CREATE Booking'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Test Results:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(),
                      Expanded(
                        child: SingleChildScrollView(
                          child: _isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : Text(
                                  _testResult,
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
