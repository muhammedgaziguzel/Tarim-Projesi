import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'bitkilerim_screen.dart';
import 'hesabim_screen.dart';
import 'hava_durumu_screen.dart';
import 'takvim_screen.dart';
import 'dersler_screen.dart';
import 'tarim_kredisi_screen.dart';
import 'malzemeler_screen.dart';
import 'yapilacaklar_screen.dart';
import 'galeri_screen.dart';
import 'bilgiler_screen.dart';
import 'package:tarim_proje/widgets/drawer_menu.dart';
import 'girisekrani_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final List<Widget> _screens = [
    const BitkilerimApp(),
    const WeatherApp(),
    const HesabimScreen(),
    TakvimScreen(), // const kaldırıldı
    const DerslerScreen(),
    const TarimKredisiScreen(),
    const MalzemelerScreen(),
    const YapilacaklarScreen(),
    const GaleriScreen(),
    const BilgilerScreen(),
  ];

  final List<String> _titles = [
    'Bitkilerim',
    'Hava Durumu',
    'Hesabım',
    'Takvim',
    'Dersler',
    'Tarım Kredisi',
    'Malzemeler',
    'Yapılacaklar',
    'Galeri',
    'Bilgiler',
  ];

  void _onTabSelected(int index) {
    if (index >= 0 && index <= 3) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _onDrawerItemTapped(int index) {
    setState(() {
      _selectedIndex = index + 4;
    });
    Navigator.pop(context);
  }

  void _signOut() async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const GirisekraniScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        backgroundColor: const Color.fromARGB(255, 156, 97, 20),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex < 4 ? _selectedIndex : 0,
        onTap: _onTabSelected,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color.fromARGB(255, 156, 97, 20),
        selectedItemColor: const Color.fromARGB(255, 9, 77, 0),
        unselectedItemColor: Colors.white,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.local_florist),
            label: 'Bitkilerim',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.wb_sunny),
            label: 'Hava Durumu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Hesabım',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Takvim',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => print('Kamera açılıyor...'),
        child: const Icon(Icons.camera),
        backgroundColor: const Color(0xFF388E3C),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      drawer: DrawerMenu(
        onItemTapped: _onDrawerItemTapped,
        selectedIndex: _selectedIndex - 4,
      ),
    );
  }
}
