import 'package:flutter/material.dart';

class WeatherModel {
  final String day;
  final String condition;
  final double temperature;
  final int humidity;
  final double windSpeed;
  final double precipitation;

  WeatherModel({
    required this.day,
    required this.condition,
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.precipitation,
  });

  // API'den gelen JSON verisini model nesnesine dönüştürmek için factory constructor
  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    // 'dt_txt' kısmını 'day' olarak kullanacağız (gün için tarih bilgisi)
    String day = json['dt_txt'] ?? '';

    // 'weather' altındaki 'description' öğesini 'condition' olarak alıyoruz
    String condition = (json['weather'] != null && json['weather'][0] != null)
        ? json['weather'][0]['description'] ?? ''
        : '';

    // 'main' altındaki 'temp' değerini alıyoruz
    double temperature = (json['main'] != null && json['main']['temp'] != null)
        ? json['main']['temp'].toDouble()
        : 0.0;

    // 'main' altındaki 'humidity' değerini alıyoruz
    int humidity = (json['main'] != null && json['main']['humidity'] != null)
        ? json['main']['humidity']
        : 0;

    // 'wind' altındaki 'speed' değerini alıyoruz
    double windSpeed = (json['wind'] != null && json['wind']['speed'] != null)
        ? json['wind']['speed'].toDouble()
        : 0.0;

    // 'rain' altındaki 3 saatlik yağış miktarını alıyoruz (varsa)
    double precipitation = (json['rain'] != null && json['rain']['3h'] != null)
        ? json['rain']['3h'].toDouble()
        : 0.0;

    return WeatherModel(
      day: day,
      condition: condition,
      temperature: temperature,
      humidity: humidity,
      windSpeed: windSpeed,
      precipitation: precipitation,
    );
  }

  // Firestore'a veri gönderirken kullanılacak
  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'condition': condition,
      'temperature': temperature,
      'humidity': humidity,
      'windSpeed': windSpeed,
      'precipitation': precipitation,
    };
  }

  // Hava durumuna göre renk
  Color getWeatherColor() {
    switch (condition) {
      case "Güneşli":
        return Colors.orange;
      case "Parçalı Bulutlu":
        return Colors.lightBlue;
      case "Yağmurlu":
        return Colors.blueGrey;
      case "Fırtınalı":
        return Colors.deepPurple;
      case "Bulutlu":
        return Colors.grey;
      case "Rüzgarlı":
        return Colors.teal;
      default:
        return Colors.blue;
    }
  }

  // Hava durumuna göre ikon
  IconData getWeatherIcon() {
    switch (condition) {
      case "Güneşli":
        return Icons.wb_sunny;
      case "Parçalı Bulutlu":
        return Icons.cloud;
      case "Yağmurlu":
        return Icons.grain;
      case "Fırtınalı":
        return Icons.flash_on;
      case "Bulutlu":
        return Icons.cloud_queue;
      case "Rüzgarlı":
        return Icons.air;
      default:
        return Icons.wb_cloudy;
    }
  }

  // Hava durumuna göre öneri
  String getSuggestion() {
    switch (condition) {
      case "Güneşli":
        return "Bugün hava güneşli! Bitkilerinizi düzenli sulayın ancak fazla sulamaktan kaçının.";
      case "Parçalı Bulutlu":
        return "Bugün hava parçalı bulutlu. Dışarıda yapılacak aktiviteler için uygun bir gün.";
      case "Yağmurlu":
        return "Bugün yağmur var! Sulama yapmanıza gerek yok, toprak doğal olarak nemlenecektir.";
      case "Fırtınalı":
        return "Bugün fırtına bekleniyor! Seraları ve dış mekandaki hassas bitkileri korumaya alın.";
      case "Bulutlu":
        return "Bugün hava bulutlu. Toprak nemini kontrol edin, belki hafif bir sulama gerekebilir.";
      case "Rüzgarlı":
        return "Bugün rüzgar var! İlaçlama yapmaktan kaçının çünkü rüzgar ilacı dağıtabilir.";
      default:
        return "Bugün hava durumu normal. Günlük işlerinize devam edebilirsiniz.";
    }
  }
}
