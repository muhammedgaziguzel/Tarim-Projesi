import 'package:flutter/material.dart';
import 'package:tarim_proje/screens/ip_secme_screen.dart'; // 🔥 IP ekranı import edildi

class DrawerMenu extends StatelessWidget {
  final Function(int) onItemTapped;
  final int selectedIndex;

  const DrawerMenu({
    super.key,
    required this.onItemTapped,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: const Color.fromARGB(255, 247, 245, 240),
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF798C74),
              ),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  'Tarım Uygulaması',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // Ana Menü
            ListTile(
              leading: const Icon(Icons.school, color: Colors.deepPurple),
              title: const Text('Dersler'),
              onTap: () => onItemTapped(0),
              selected: selectedIndex == 0,
            ),
            ListTile(
              leading: const Icon(Icons.monetization_on, color: Colors.green),
              title: const Text('Tarım Kredisi'),
              onTap: () => onItemTapped(1),
              selected: selectedIndex == 1,
            ),
            ListTile(
              leading: const Icon(Icons.inventory, color: Colors.brown),
              title: const Text('Malzemeler'),
              onTap: () => onItemTapped(2),
              selected: selectedIndex == 2,
            ),
            ListTile(
              leading: const Icon(Icons.list, color: Colors.orange),
              title: const Text('Yapılacaklar'),
              onTap: () => onItemTapped(3),
              selected: selectedIndex == 3,
            ),
            ListTile(
              leading: const Icon(Icons.photo_album, color: Colors.blue),
              title: const Text('Galeri'),
              onTap: () => onItemTapped(4),
              selected: selectedIndex == 4,
            ),
            ListTile(
              leading: const Icon(Icons.info, color: Colors.teal),
              title: const Text('Bilgiler'),
              onTap: () => onItemTapped(5),
              selected: selectedIndex == 5,
            ),
            const Divider(),
            // 🔥 IP Ayarları bölümü eklendi
            ListTile(
              leading: const Icon(Icons.settings_ethernet, color: Colors.grey),
              title: const Text('IP Ayarları'),
              onTap: () {
                Navigator.pop(context); // Drawer'ı kapat
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const IpSecmeScreen()),
                );
              },
            ),
            const Divider(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Destek',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF798C74),
                ),
              ),
            ),
            const ListTile(
              leading: Icon(Icons.email, color: Colors.redAccent),
              title: Text('E-posta: support@tarim.com'),
            ),
            const ListTile(
              leading: Icon(Icons.phone, color: Colors.indigo),
              title: Text('Telefon: +90 123 456 78 90'),
            ),
            const ListTile(
              leading: Icon(Icons.help_outline, color: Colors.cyan),
              title: Text('Yardım & SSS'),
            ),
          ],
        ),
      ),
    );
  }
}