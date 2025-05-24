import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class BilgilerScreen extends StatelessWidget {
  const BilgilerScreen({super.key});

  // URL'yi güvenli bir şekilde başlatan yardımcı fonksiyon
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Bağlantı açılamadı: $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tema renkleri
    const Color backgroundColor = Color(0xFFEAE1C8);
    const Color buttonColor = Color(0xFF2C6E49);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: buttonColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 6,
              shadowColor: Colors.black26,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        size: 80, color: buttonColor),
                    const SizedBox(height: 16),
                    const Text(
                      "Tarım Cepte",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "v1.0.0",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Divider(height: 32, thickness: 1),
                    const Text(
                      "Bu uygulama, kullanıcıların hayatını kolaylaştırmak için geliştirilmiştir. Daha fazla bilgi almak için aşağıdaki bağlantıyı ziyaret edebilirsiniz.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _launchURL("https://youtu.be/IA2Y3KipGGU"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 2,
                        ),
                        child: const Text(
                          "Tanıtım Videosu",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}