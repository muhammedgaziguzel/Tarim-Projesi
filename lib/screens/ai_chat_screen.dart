import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatMessage {
  final String text;
  final bool isUser;
  final File? image;

  ChatMessage({required this.text, required this.isUser, this.image});
}

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  _AiChatScreenState createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;

  final String _chatApiUrl = "http://10.0.2.2:3001/chat";
  final String _imageApiUrl = "http://10.0.2.2:3001/predict";

  void _sendMessage() async {
    String text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _isLoading = true;
    });
    _controller.clear();

    try {
      String response = await _callChatApi(text);
      setState(() {
        _messages.add(ChatMessage(text: response, isUser: false));
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(text: "Hata: $e", isUser: false));
        _isLoading = false;
      });
    }
  }

  void _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      File image = File(pickedFile.path);

      setState(() {
        _messages.add(ChatMessage(text: "Görsel gönderildi", isUser: true, image: image));
        _isLoading = true;
      });

      try {
        String response = await _callImageApi(image);
        setState(() {
          _messages.add(ChatMessage(text: response, isUser: false));
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _messages.add(ChatMessage(text: "Görsel analiz hatası: $e", isUser: false));
          _isLoading = false;
        });
      }
    }
  }

  Future<String> _callChatApi(String message) async {
    final response = await http.post(
      Uri.parse(_chatApiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'message': message}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['response'] ?? 'Yanıt alınamadı';
    } else {
      throw 'Chat API hatası: ${response.statusCode}';
    }
  }

  Future<String> _callImageApi(File image) async {
    var request = http.MultipartRequest('POST', Uri.parse(_imageApiUrl));
    request.files.add(await http.MultipartFile.fromPath('image', image.path));

    var response = await request.send();
    var responseData = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final data = jsonDecode(responseData);
      return "Tahmin: ${data['prediction']}\nGüven: ${data['confidence']}%\n${data['description'] ?? ''}";
    } else {
      throw 'Image API hatası: ${response.statusCode}';
    }
  }

  BoxDecoration messageBubbleDecoration(bool isUser) {
    return BoxDecoration(
      color: isUser ? Colors.green.shade100 : Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 10,
          offset: const Offset(4, 4),
        ),
        BoxShadow(
          color: Colors.white.withOpacity(0.9),
          blurRadius: 5,
          offset: const Offset(-2, -2),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF2F5),
      appBar: AppBar(
        title: const Text('Tarım Chat Bot'),
        centerTitle: true,
        elevation: 4,
        backgroundColor: Colors.green.shade600,
        shadowColor: Colors.green.shade200,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return Align(
                  alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(14),
                    decoration: messageBubbleDecoration(message.isUser),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (message.image != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              message.image!,
                              height: 160,
                              width: 160,
                              fit: BoxFit.cover,
                            ),
                          ),
                        if (message.image != null) const SizedBox(height: 8),
                        Text(
                          message.text,
                          style: const TextStyle(fontSize: 15, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFE0E5EC),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _buildCircleButton(Icons.photo, () => _pickImage(ImageSource.gallery)),
                  const SizedBox(width: 8),
                  _buildCircleButton(Icons.camera_alt, () => _pickImage(ImageSource.camera)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F6FA),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 6,
                            offset: const Offset(2, 3),
                          ),
                          BoxShadow(
                            color: Colors.white,
                            blurRadius: 4,
                            offset: const Offset(-2, -2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: 'Mesaj yaz...',
                          border: InputBorder.none,
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FloatingActionButton(
                    onPressed: _sendMessage,
                    backgroundColor: Colors.green,
                    elevation: 4,
                    mini: true,
                    child: const Icon(Icons.send, size: 20),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFE0E5EC),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade400,
              offset: const Offset(4, 4),
              blurRadius: 8,
            ),
            const BoxShadow(
              color: Colors.white,
              offset: Offset(-4, -4),
              blurRadius: 8,
            ),
          ],
        ),
        child: Icon(icon, color: Colors.green),
      ),
    );
  }
}
