import '../models/weather_model.dart';
import '../services/weather_service.dart';  // WeatherService'i içeri aktar

class WeatherRepository {
  final WeatherService _weatherService = WeatherService();

  // API'den haftalık hava durumu verisini al
  Future<List<WeatherModel>> getWeeklyForecast(String city) async {
    try {
      final List<dynamic> rawData =
          await _weatherService.getWeeklyForecast(city);

      // Verinin doğru formatta olup olmadığını kontrol et
      if (rawData.isEmpty) {
        throw Exception("Haftalık hava durumu verisi bulunamadı.");
      }

      // Her bir rawData öğesini WeatherModel'e çevir
      List<WeatherModel> forecast = rawData.map((item) {
        if (item is Map<String, dynamic>) {
          return WeatherModel.fromJson(item);  // Burada doğru şekilde dönüştürme yapılıyor
        } else {
          throw Exception("Veri formatı hatalı.");
        }
      }).toList();

      return forecast;
    } catch (e) {
      throw Exception("API verileri alınırken bir hata oluştu: $e");
    }
  }
}
