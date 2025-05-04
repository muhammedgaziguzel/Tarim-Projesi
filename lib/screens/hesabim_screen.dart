import 'package:flutter/material.dart';
import 'package:tarim_proje/services/auth_service.dart';
import 'package:tarim_proje/screens/girisekrani_screen.dart';
import 'package:tarim_proje/screens/profili_duzenle_screen.dart';
import 'package:tarim_proje/screens/ayarlar_screen.dart';
import 'package:tarim_proje/screens/favoriler_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HesabimScreen extends StatefulWidget {
  const HesabimScreen({super.key});

  @override
  State<HesabimScreen> createState() => _HesabimScreenState();
}

class _HesabimScreenState extends State<HesabimScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String _name = '';
  late String _surname = '';
  late String _email = '';
  late String _phone = '';

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  Future<void> _getUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          print("Veri çekildi: ${userDoc.data()}");

          print("İsim: ${userDoc['isim']}");
          print("Soyisim: ${userDoc['soyisim']}");
          print("Telefon: ${userDoc['telefon']}");
          print("E-posta: ${user.email}");

          setState(() {
            _name = userDoc['isim'] ?? 'Ad bulunamadı';
            _surname = userDoc['soyisim'] ?? 'Soyad bulunamadı';
            _phone = userDoc['telefon'] ?? 'Telefon bulunamadı';
            _email = user.email ?? '';
          });
        } else {
          print("Kullanıcı verisi bulunamadı");
        }
      } catch (e) {
        print("Veri çekme hatası: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF2C6E49),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2C6E49)),
        useMaterial3: true,
      ),
      home: Scaffold(
        backgroundColor: const Color(0xFFEAE1C8),
        body: SafeArea(
          child: SingleChildScrollView(
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
                        child: const CircleAvatar(
                          radius: 60,
                          backgroundImage:
                              NetworkImage("https://via.placeholder.com/150"),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "$_name $_surname",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C6E49),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.alternate_email,
                              size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            _email,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Bilgi Kartları
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
                      bilgiKart("Ad Soyad", "$_name $_surname", Icons.person),
                      bilgiKart("E-posta", _email, Icons.email),
                      if (_phone.isNotEmpty)
                        bilgiKart("Telefon", _phone, Icons.phone),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Buton
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

                // Menü Seçenekleri
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
                      menuItem(
                        context,
                        "Çıkış Yap",
                        Icons.logout,
                        () async {
                          await AuthService().signOut();
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const GirisekraniScreen()),
                            (route) => false,
                          );
                        },
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
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap, {
    Color? textColor,
  }) {
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
