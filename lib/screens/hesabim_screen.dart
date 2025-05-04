import 'package:flutter/material.dart';
import 'package:tarim_proje/services/auth_service.dart';
import 'package:tarim_proje/screens/girisekrani_screen.dart';
import 'package:tarim_proje/screens/profili_duzenle_screen.dart';
import 'package:tarim_proje/screens/ayarlar_screen.dart';
import 'package:tarim_proje/screens/favoriler_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HesabimScreen extends StatelessWidget {
  const HesabimScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF2C6E49),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2C6E49)),
        useMaterial3: true,
      ),
      home: const HesabimEkrani(),
    );
  }
}

class HesabimEkrani extends StatelessWidget {
  const HesabimEkrani({super.key});

  final String adSoyad = "Hasan Akbaba";
  final String email = "Akbabah10@gmail.com";
  final String telefon = "+90 530 579 2039";
  final String dogumTarihi = "04.01.2005";
  final String kullaniciAdi = "Hasanakbaba0";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F2E8),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF2C6E49),
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 120,
                          color: Color.fromARGB(255, 65, 126, 195),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        adSoyad,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C6E49),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.alternate_email,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            kullaniciAdi,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Kişisel Bilgiler",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C6E49),
                        ),
                      ),
                      const SizedBox(height: 12),
                      bilgiKart("Ad Soyad", adSoyad, Icons.person),
                      bilgiKart(
                          "Kullanıcı Adı", kullaniciAdi, Icons.alternate_email),
                      bilgiKart("E-posta", email, Icons.email),
                      bilgiKart("Telefon", telefon, Icons.phone),
                      bilgiKart("Doğum Tarihi", dogumTarihi, Icons.cake),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const ProfilDuzenleScreen()),
                          ).then((_) {
                            _getUserData(); // Geri dönünce bilgileri yenile
                          });
                        },
                        icon: const Icon(Icons.edit, color: Colors.white),
                        label: const Text(
                          "Bilgileri Düzenle",
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2C6E49),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      menuItem(context, "Adreslerim", Icons.location_on, () {}),
                      const Divider(height: 1),
                      menuItem(
                          context, "Siparişlerim", Icons.shopping_bag, () {}),
                      const Divider(height: 1),
                      menuItem(context, "Favorilerim", Icons.favorite, () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const FavorilerScreen()),
                        );
                      }),
                      const Divider(height: 1),
                      menuItem(context, "Ayarlar", Icons.settings, () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AyarlarScreen()),
                        );
                      }),
                      const Divider(height: 1),
                      menuItem(context, "Çıkış Yap", Icons.logout, () {},
                          textColor: Colors.red),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget bilgiKart(String baslik, String deger, IconData icon) {
    final Map<IconData, Color> iconRenkleri = {
      Icons.person: const Color.fromARGB(255, 60, 157, 202),
      Icons.alternate_email: Colors.orange,
      Icons.email: Colors.blue,
      Icons.phone: Colors.green,
      Icons.cake: Colors.pink,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconRenkleri[icon]?.withOpacity(0.1) ??
                  Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child:
                Icon(icon, color: iconRenkleri[icon] ?? Colors.grey, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  baslik,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  deger,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget menuItem(
      BuildContext context, String title, IconData icon, VoidCallback onTap,
      {Color? textColor}) {
    final Map<String, Color> menuRenkleri = {
      "Adreslerim": Colors.deepPurple,
      "Siparişlerim": Colors.brown,
      "Favorilerim": Colors.red,
      "Ayarlar": Colors.indigo,
      "Çıkış Yap": Colors.red,
    };

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: menuRenkleri[title] ?? const Color(0xFF2C6E49)),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: textColor ?? Colors.black,
              ),
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}