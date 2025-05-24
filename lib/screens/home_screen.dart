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
import 'girisekrani_screen.dart';
import 'package:tarim_proje/widgets/drawer_menu.dart';
import 'package:tarim_proje/screens/ai_chat_screen.dart';

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
    TakvimScreen(),
    const HesabimScreen(),
    const DerslerScreen(),
    const TarimKredisiApp(),
    const MalzemelerScreen(),
    const YapilacaklarScreen(),
    const GaleriScreen(),
    const BilgilerScreen(),
  ];

  final List<String> _titles = [
    'Bitkilerim',
    'Hava Durumu',
    'Takvim',
    'Hesabım',
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
    const Color mainGreen = Color(0xFF2E7D32); // Canlı koyu yeşil
    const Color darkGreenStart = Color(0xFF1B5E20);
    const Color darkGreenEnd = Color(0xFF388E3C);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [darkGreenStart, darkGreenEnd],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: Text(
              _titles[_selectedIndex],
              style: const TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w600,
                fontSize: 24,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Çıkış Yap',
                onPressed: _signOut,
                color: Colors.white,
                splashRadius: 24,
              ),
            ],
          ),
        ),
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              offset: const Offset(0, -3),
              blurRadius: 12,
            ),
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex < 4 ? _selectedIndex : 0,
          onTap: _onTabSelected,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.local_florist_outlined),
              label: 'Bitkilerim',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.wb_sunny_outlined),
              label: 'Hava Durumu',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined),
              label: 'Takvim',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'Hesabım',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AiChatScreen()),
          );
        },
        backgroundColor: mainGreen,
        elevation: 12,
        tooltip: 'Yapay Zeka',
        child: const Icon(
          Icons.smart_toy_outlined,
          color: Colors.white,
          size: 32,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      drawer: DrawerMenu(
        onItemTapped: _onDrawerItemTapped,
        selectedIndex: _selectedIndex - 4,
      ),
    );
  }
}
