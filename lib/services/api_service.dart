import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static String _baseIp = "127.0.0.1"; // Varsayılan IP

  // Uygulama başlatılırken çağrılmalı
  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _baseIp = prefs.getString('ip_adresi') ?? "127.0.0.1";
  }

  // Dinamik URL'ler
  String get flaskUrl => "http://$_baseIp:5002";
  String get nodeUrl => "http://$_baseIp:5001";

  // Görsel analizi için Flask API'ye istek
  Future<Map<String, dynamic>?> sendImage(File imageFile) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$flaskUrl/predict'));
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));

      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return json.decode(responseData);
      } else {
        print("❌ Flask API Hatası: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("❌ Flask Bağlantı Hatası: $e");
      return null;
    }
  }

  // Mesaj ve opsiyonel görseli aynı anda göndermek için Node.js API'ye istek
  Future<Map<String, dynamic>?> sendMessageWithImage(String message, {File? imageFile, required String userId}) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$nodeUrl/chat'));
      request.fields['userId'] = userId;
      request.fields['message'] = message;

      if (imageFile != null) {
        request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
      }

      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return jsonDecode(responseData);
      } else {
        print('❌ Node.js API Hatası: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Node.js Hata: $e');
      return null;
    }
  }

  // Sadece mesaj göndermek için (dinamik IP ile)
  Future<String?> sendMessage(String message, {required String userId, String? contextLabel}) async {
    final uri = Uri.parse('$flaskUrl/predict');
    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'message': message,
          'user_id': userId,
          if (contextLabel != null) 'context': contextLabel,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['reply'];
      } else {
        print("Hata: ${response.body}");
        return null;
      }
    } catch (e) {
      print("İstek hatası: $e");
      return null;
    }
  }

  // IP adresini kaydet ve bellekte güncelle
  static Future<void> saveIpAddress(String ip) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ip_adresi', ip);
    _baseIp = ip;
  }

  // Flask ping ile bağlantı testi
  static Future<bool> testConnection(String ip) async {
    try {
      final url = Uri.parse("http://$ip:5002/ping");
      final response = await http.get(url).timeout(Duration(seconds: 3));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}