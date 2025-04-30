import 'package:flutter/material.dart';

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
        color: const Color.fromARGB(255, 237, 206, 169),
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 223, 133, 31),
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
              leading:
                  Icon(Icons.school, color: Color.fromARGB(255, 161, 155, 148)),
              title: const Text('Dersler'),
              onTap: () => onItemTapped(0),
              selected: selectedIndex == 0,
            ),
            ListTile(
              leading: Icon(Icons.monetization_on,
                  color: Color.fromARGB(255, 161, 155, 148)),
              title: const Text('Tarım Kredisi'),
              onTap: () => onItemTapped(1),
              selected: selectedIndex == 1,
            ),
            ListTile(
              leading: Icon(Icons.inventory,
                  color: Color.fromARGB(255, 161, 155, 148)),
              title: const Text('Malzemeler'),
              onTap: () => onItemTapped(2),
              selected: selectedIndex == 2,
            ),
            // Yeni Menü Öğeleri
            ListTile(
              leading:
                  Icon(Icons.list, color: Color.fromARGB(255, 161, 155, 148)),
              title: const Text('Yapılacaklar'),
              onTap: () => onItemTapped(3),
              selected: selectedIndex == 3,
            ),
            ListTile(
              leading: Icon(Icons.photo_album,
                  color: Color.fromARGB(255, 161, 155, 148)),
              title: const Text('Galeri'),
              onTap: () => onItemTapped(4),
              selected: selectedIndex == 4,
            ),
            ListTile(
              leading:
                  Icon(Icons.info, color: Color.fromARGB(255, 161, 155, 148)),
              title: const Text('Bilgiler'),
              onTap: () => onItemTapped(5),
              selected: selectedIndex == 5,
            ),
            // Destek Bölümü
            const Divider(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Destek',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 161, 155, 148),
                ),
              ),
            ),
            const ListTile(
              leading:
                  Icon(Icons.email, color: Color.fromARGB(255, 161, 155, 148)),
              title: Text('E-posta: support@tarim.com'),
            ),
            const ListTile(
              leading:
                  Icon(Icons.phone, color: Color.fromARGB(255, 161, 155, 148)),
              title: Text('Telefon: +90 123 456 78 90'),
            ),
            const ListTile(
              leading: Icon(Icons.help_outline,
                  color: Color.fromARGB(255, 161, 155, 148)),
              title: Text('Yardım & SSS'),
            ),
          ],
        ),
      ),
    );
  }
}
