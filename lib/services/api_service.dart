import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class ApiService {
  final String apiUrl = "http://10.0.2.2:5001/predict";  // 📌 Emülatör için!

  Future<Map<String, dynamic>?> sendImage(File imageFile) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.headers.addAll({"Content-Type": "multipart/form-data"});  
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));

      print("📡 Flutter'dan API'ye Gönderilen Görsel: ${imageFile.path}");

      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      print("📡 API’den Dönen Yanıt: $responseData");
      print("📡 API HTTP Durum Kodu: ${response.statusCode}");

      if (response.statusCode == 200) {
        try {
          var jsonData = json.decode(responseData);

          if (jsonData.containsKey('label') && jsonData.containsKey('confidence')) {
            print("✅ API'den gelen tahmin: ${jsonData['label']}, Güven: ${jsonData['confidence']}");
            return jsonData;
          } else {
            print("⚠️ API Yanıtı Beklenen Format Değil!");
            return {"status": "error", "message": "Yanıt formatı hatalı"};
          }
        } catch (e) {
          print("❌ JSON dönüşüm hatası: $e");
          return {"status": "error", "message": "Yanıt çözümlenemedi"};
        }
      } else {
        print("❌ API Hatası: ${response.statusCode}");
        return {"status": "error", "message": "Tahmin alınamadı (${response.statusCode})"};
      }
    } catch (e) {
      print("❌ Beklenmedik bir hata oluştu: $e");
      return {"status": "error", "message": "Bağlantı hatası: $e"};
    }
  }
}
