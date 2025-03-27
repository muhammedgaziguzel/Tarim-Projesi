import 'package:flutter/material.dart';

void main() {
  runApp(const HesabimScreen());
}

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

  // Kullanıcı bilgilerini simüle eden değişkenler
  final String adSoyad = "Ekrem İmamoglu";
  final String email = "imam@example.com";
  final String telefon = "+90 555 123 45 67";
  final String dogumTarihi = "01.01.2000";
  final String profilResmiUrl = "https://via.placeholder.com/150";
  final String kullaniciAdi = "imamoğluEkrem34"; // Added username variable

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAE1C8),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                // Profile Header
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
                        child: CircleAvatar(
                          radius: 60,
                          backgroundImage: NetworkImage(profilResmiUrl),
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

                // Information Cards Section
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
                      bilgiKart("Kullanıcı Adı", kullaniciAdi,
                          Icons.alternate_email), // Added username card
                      bilgiKart("E-posta", email, Icons.email),
                      bilgiKart("Telefon", telefon, Icons.phone),
                      bilgiKart("Doğum Tarihi", dogumTarihi, Icons.cake),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed:
                            () {}, // Düzenleme ekranına yönlendirme eklenebilir
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

                // Additional Options
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
                      menuItem(
                        context,
                        "Adreslerim",
                        Icons.location_on,
                        () {/* Adreslerim sayfasına yönlendirme */},
                      ),
                      const Divider(height: 1),
                      menuItem(
                        context,
                        "Siparişlerim",
                        Icons.shopping_bag,
                        () {/* Siparişlerim sayfasına yönlendirme */},
                      ),
                      const Divider(height: 1),
                      menuItem(
                        context,
                        "Favorilerim",
                        Icons.favorite,
                        () {/* Favorilerim sayfasına yönlendirme */},
                      ),
                      const Divider(height: 1),
                      menuItem(
                        context,
                        "Ayarlar",
                        Icons.settings,
                        () {/* Ayarlar sayfasına yönlendirme */},
                      ),
                      const Divider(height: 1),
                      menuItem(
                        context,
                        "Çıkış Yap",
                        Icons.logout,
                        () {/* Çıkış işlemi */},
                        textColor: Colors.red,
                      ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF2C6E49).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF2C6E49), size: 22),
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
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF2C6E49)),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: textColor,
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
