import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TodoService {
  final String baseUrl = dotenv.env['BASE_URL'] ?? 'http://10.0.2.2:8080';

  Future<List<dynamic>> fetchTodos(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/todos/$userId'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Görevler alınamadı');
    }
  }

  Future<void> addTodo(String title, int userId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/todos'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'title': title, 'user_id': userId}),
    );

    if (response.statusCode != 200) {
      throw Exception('Görev eklenemedi');
    }
  }
}
