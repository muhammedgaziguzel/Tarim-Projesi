import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'screens/girisekrani_screen.dart';
import 'screens/home_screen.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Tüm API anahtarlarını içeren tek bir .env dosyasını yükle
    await dotenv.load(fileName: "app.env");
    print("✅ app.env dosyası yüklendi:");
    print("  API_KEY: ${dotenv.env['API_KEY']}");
    print("  TODO_BASE_URL: ${dotenv.env['TODO_BASE_URL']}");
    print("  CALENDAR_API_BASE_URL: ${dotenv.env['CALENDAR_API_BASE_URL']}");

    // Gerekli değerlerin kontrolü
    if (dotenv.env['API_KEY'] == null || dotenv.env['API_KEY']!.isEmpty) {
      print(
          "❌ API_KEY boş veya hatalı! Lütfen app.env dosyasını kontrol edin.");
    }

    if (dotenv.env['TODO_BASE_URL'] == null ||
        dotenv.env['TODO_BASE_URL']!.isEmpty) {
      print(
          "❌ TODO_BASE_URL boş veya hatalı! Lütfen app.env dosyasını kontrol edin.");
    }

    if (dotenv.env['CALENDAR_API_BASE_URL'] == null ||
        dotenv.env['CALENDAR_API_BASE_URL']!.isEmpty) {
      print(
          "❌ CALENDAR_API_BASE_URL boş veya hatalı! Lütfen app.env dosyasını kontrol edin.");
    }
  } catch (e) {
    print("❌ app.env yüklenemedi: $e");
  }

  // Firebase başlat
  await Firebase.initializeApp();

  // Uygulama başlasın
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tarım Dostunuz',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.hasData) {
            return const HomeScreen();
          }
          return const GirisekraniScreen();
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
