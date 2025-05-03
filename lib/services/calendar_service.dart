import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CalendarService {
  final String baseUrl = dotenv.env['CALENDAR_API_BASE_URL'] ?? '';

  Future<Map<String, dynamic>> createEvent(Map<String, dynamic> eventData) async {
    final url = Uri.parse('$baseUrl/create-event');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(eventData),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('API Hatası: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Bağlantı hatası: $e');
    }
  }
}
