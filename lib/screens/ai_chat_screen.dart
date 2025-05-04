import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class ApiService {
  final String apiUrl = "http://10.0.2.2:5001/predict";

  Future<Map<String, dynamic>?> sendImage(File imageFile) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));

      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseData);
        if (data.containsKey('label') && data.containsKey('confidence')) {
          return {
            "status": "success",
            "label": data['label'],
            "confidence": data['confidence'],
            "solution": data['solution'] ?? "Çözüm bulunamadı."
          };
        } else {
          return {
            "status": "error",
            "message": "API'den beklenen formatta yanıt alınamadı."
          };
        }
      } else {
        return {"status": "error", "message": "Tahmin alınamadı"};
      }
    } catch (e) {
      return {"status": "error", "message": "Bağlantı hatası"};
    }
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final bool isImage;

  ChatMessage({required this.text, required this.isUser, this.isImage = false});
}

Future<String> sendMessage(String userId, String message, {String? context}) async {
  final url = Uri.parse('http://10.0.2.2:5000/chat');

  final body = {
    'userId': userId,
    'message': message,
  };

  if (context != null) {
    body['context'] = context;
  }

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(body),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['reply'];
  } else {
    throw Exception('API hatası: ${response.statusCode}');
  }
}

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final Color primaryColor = const Color(0xFF2c6e49);
  final Color secondaryColor = const Color(0xFFeae1c8);

  final List<ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ApiService _apiService = ApiService();

  File? _selectedImage;
  bool _isLoading = false;
  String apiResponse = "";
  String? lastPredictionLabel;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _isLoading = true;
    });

    _controller.clear();
    _scrollToBottom();

    try {
      final response = await sendMessage(
        "kullanici_1",
        text,
        context: lastPredictionLabel,
      );

      setState(() {
        _messages.add(ChatMessage(text: response, isUser: false));
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (e) {
      _showErrorDialog("Yanıt alınırken bir hata oluştu:\n$e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> analyzeImage(File image) async {
    var result = await _apiService.sendImage(image);
    if (result != null &&
        result["status"] == "success" &&
        result.containsKey('label') &&
        result.containsKey('confidence')) {
      lastPredictionLabel = result['label'];
      setState(() {
        apiResponse =
            "✅ Tahmin: ${result['label']}\nGüven: ${(result['confidence'] * 100).toStringAsFixed(2)}%\n\nÇözüm:\n${result['solution']}";
      });
    } else {
      setState(() {
        apiResponse = "❌ Tahmin alınamadı!";
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: source);

      if (picked != null) {
        File image = File(picked.path);
        setState(() {
          _selectedImage = image;
          lastPredictionLabel = null;
          _messages.add(ChatMessage(
            text: "Görsel yüklendi",
            isUser: true,
            isImage: true,
          ));
          _isLoading = true;
        });
        _scrollToBottom();

        await analyzeImage(image);

        setState(() {
          _isLoading = false;
          _messages.add(ChatMessage(
            text: apiResponse,
            isUser: false,
          ));
        });

        _scrollToBottom();
      }
    } catch (e) {
      _showErrorDialog("Görsel seçilirken bir hata oluştu: $e");
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Hata", style: TextStyle(color: primaryColor)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text("Tamam", style: TextStyle(color: primaryColor)),
          ),
        ],
      ),
    );
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: secondaryColor,
      builder: (_) => Wrap(
        children: [
          ListTile(
            leading: Icon(Icons.photo_library, color: primaryColor),
            title: const Text("Galeriden Seç"),
            onTap: () {
              Navigator.pop(context);
              _pickImage(ImageSource.gallery);
            },
          ),
          ListTile(
            leading: Icon(Icons.camera_alt, color: primaryColor),
            title: const Text("Kamerayla Çek"),
            onTap: () {
              Navigator.pop(context);
              _pickImage(ImageSource.camera);
            },
          ),
          ListTile(
            leading: Icon(Icons.delete, color: Colors.red),
            title: const Text("Görseli Kaldır"),
            onTap: () {
              if (_selectedImage != null) {
                setState(() {
                  _selectedImage = null;
                  lastPredictionLabel = null;
                  _messages.add(ChatMessage(
                    text: "Görsel kaldırıldı",
                    isUser: true,
                  ));
                });
              }
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Yapay Zekâ Asistanı", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.image, color: Colors.white),
            onPressed: _showImageOptions,
            tooltip: "Görsel Ekle",
          ),
        ],
        backgroundColor: primaryColor,
        elevation: 2,
      ),
      body: Container(
        color: secondaryColor.withOpacity(0.3),
        child: Column(
          children: [
            if (_selectedImage != null)
              Container(
                padding: const EdgeInsets.all(8.0),
                margin: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  border: Border.all(color: primaryColor, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Seçilen Görsel:", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        _selectedImage!,
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    if (apiResponse.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          apiResponse,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            Expanded(
              child: _messages.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chat_bubble_outline, size: 80, color: primaryColor.withOpacity(0.5)),
                          const SizedBox(height: 16),
                          Text("Bir görsel yükleyip sohbete başlayın!", style: TextStyle(color: primaryColor, fontSize: 16)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(8.0),
                      itemCount: _messages.length,
                      itemBuilder: (ctx, index) {
                        final message = _messages[index];
                        return Align(
                          alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.75,
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: message.isUser ? primaryColor : secondaryColor,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  message.isUser ? "🧑‍🌾 Sen" : "🤖 Yapay Zekâ",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: message.isUser ? Colors.white : primaryColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  message.text,
                                  style: TextStyle(
                                    color: message.isUser ? Colors.white : Colors.black87,
                                  ),
                                ),
                                if (message.isImage)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Icon(
                                      Icons.image,
                                      color: message.isUser ? Colors.white70 : primaryColor.withOpacity(0.7),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            if (_isLoading)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text("Yapay zekâ düşünüyor...", style: TextStyle(color: primaryColor, fontStyle: FontStyle.italic)),
                  ],
                ),
              ),
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, -1)),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: "Sorunuzu yazın...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: secondaryColor.withOpacity(0.3),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Material(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(50),
                    child: InkWell(
                      onTap: _sendMessage,
                      borderRadius: BorderRadius.circular(50),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        child: const Icon(Icons.send_rounded, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
