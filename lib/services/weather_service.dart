import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart'; // dotenv paketi

class WeatherService {
  // API anahtarını ihtiyaç duyulduğu anda alacak şekilde getter tanımlıyoruz.
  String get apiKey => dotenv.env['API_KEY'] ?? '';

  // Günlük hava durumu verisini alacak fonksiyon
  Future<Map<String, dynamic>> getWeather(String? city) async {
    // Eğer city boş veya null ise varsayılan olarak "Istanbul" kullan
    final String queryCity =
        (city?.trim().isEmpty ?? true) ? 'Istanbul' : city!.trim();

    final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q=$queryCity&appid=$apiKey&units=metric&lang=tr');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        // Gelen JSON verisini çözümleyip konsola yazdırıyoruz
        var json = jsonDecode(response.body);
        print(json); // Gelen JSON verisini burada konsola yazdırıyoruz

        return json;
      } else {
        throw Exception(
            'API Hatası: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Bağlantı Hatası: $e');
    }
  }

  // Haftalık hava durumu tahminini alacak fonksiyon
  Future<List<dynamic>> getWeeklyForecast(String? city) async {
    // Eğer city boş veya null ise varsayılan olarak "Istanbul" kullan
    final String queryCity =
        (city?.trim().isEmpty ?? true) ? 'Istanbul' : city!.trim();

    final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/forecast?q=$queryCity&appid=$apiKey&units=metric&lang=tr');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Gelen JSON verisini konsola yazdır
        print(data); // Gelen JSON verisini burada konsola yazdırıyoruz

        return data['list']; // 3 saatlik aralıklarla hava tahmini verisi
      } else {
        throw Exception(
            'API Hatası: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Bağlantı Hatası: $e');
    }
  }
}
