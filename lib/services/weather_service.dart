import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Doğru import

class WeatherService {
  // API anahtarını ihtiyaç duyulduğu anda alacak şekilde getter tanımlıyoruz.
  String get apiKey => dotenv.env['API_KEY'] ?? '';

  // Günlük hava durumu verisini alacak fonksiyon
  Future<Map<String, dynamic>> getWeather(String? city) async {
    final String queryCity = (city?.trim().isEmpty ?? true) ? 'Istanbul' : city!.trim();

    final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q=$queryCity&appid=$apiKey&units=metric&lang=tr');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        var json = jsonDecode(response.body);
        print(json);
        return json;
      } else {
        throw Exception('API Hatası: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Bağlantı Hatası: $e');
    }
  }

  // Haftalık hava durumu tahminini alacak fonksiyon
  Future<List<dynamic>> getWeeklyForecast(String? city) async {
    final String queryCity = (city?.trim().isEmpty ?? true) ? 'Istanbul' : city!.trim();

    final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/forecast?q=$queryCity&appid=$apiKey&units=metric&lang=tr');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(data);
        return data['list'];
      } else {
        throw Exception('API Hatası: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Bağlantı Hatası: $e');
    }
  }
}
