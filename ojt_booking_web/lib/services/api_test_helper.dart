import 'package:http/http.dart' as http;

class ApiTestHelper {
  static const String baseUrl = 'http://localhost:5022/api';

  /// Test if the API is reachable
  static Future<Map<String, dynamic>> testConnection() async {
    try {
      print('Testing API connection to $baseUrl...');

      // Try to ping the API
      final response = await http
          .get(Uri.parse('$baseUrl/bookings'))
          .timeout(const Duration(seconds: 5));

      return {
        'success': true,
        'statusCode': response.statusCode,
        'message': 'API is reachable!',
        'body': response.body.substring(
          0,
          response.body.length > 100 ? 100 : response.body.length,
        ),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Cannot reach API: $e',
        'suggestion': 'Make sure your C# API is running on localhost:5022',
      };
    }
  }

  /// Print connection test results
  static Future<void> printConnectionTest() async {
    print('=== API CONNECTION TEST ===');
    final result = await testConnection();
    result.forEach((key, value) {
      print('$key: $value');
    });
    print('===========================');
  }
}
