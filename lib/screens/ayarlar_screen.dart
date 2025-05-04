import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AyarlarScreen extends StatefulWidget {
  const AyarlarScreen({super.key});

  @override
  State<AyarlarScreen> createState() => _AyarlarScreenState();
}

class _AyarlarScreenState extends State<AyarlarScreen> {
  bool _bildirimler = true;
  bool _karanlikMod = false;
  String _dil = 'Türkçe';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _bildirimler = prefs.getBool('bildirimler') ?? true;
      _karanlikMod = prefs.getBool('karanlikMod') ?? false;
      _dil = prefs.getString('dil') ?? 'Türkçe';
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('bildirimler', _bildirimler);
    await prefs.setBool('karanlikMod', _karanlikMod);
    await prefs.setString('dil', _dil);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
        backgroundColor: const Color(0xFF2C6E49),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          _buildSection('Bildirimler', [
            SwitchListTile(
              title: const Text('Bildirimleri Aç'),
              subtitle: const Text('Uygulama bildirimlerini al'),
              value: _bildirimler,
              onChanged: (value) {
                setState(() {
                  _bildirimler = value;
                });
                _saveSettings();
              },
              activeColor: const Color(0xFF2C6E49),
            ),
          ]),
          _buildSection('Görünüm', [
            SwitchListTile(
              title: const Text('Karanlık Mod'),
              subtitle: const Text('Uygulamayı karanlık temada kullan'),
              value: _karanlikMod,
              onChanged: (value) {
                setState(() {
                  _karanlikMod = value;
                });
                _saveSettings();
              },
              activeColor: const Color(0xFF2C6E49),
            ),
          ]),
          _buildSection('Dil', [
            ListTile(
              title: const Text('Dil Seçimi'),
              subtitle: Text(_dil),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Dil seçimi için dialog göster
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Dil Seçin'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          title: const Text('Türkçe'),
                          onTap: () {
                            setState(() {
                              _dil = 'Türkçe';
                            });
                            _saveSettings();
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          title: const Text('English'),
                          onTap: () {
                            setState(() {
                              _dil = 'English';
                            });
                            _saveSettings();
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ]),
          _buildSection('Hakkında', [
            ListTile(
              title: const Text('Uygulama Versiyonu'),
              subtitle: const Text('1.0.0'),
            ),
            ListTile(
              title: const Text('Gizlilik Politikası'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Gizlilik politikası sayfasına yönlendir
              },
            ),
            ListTile(
              title: const Text('Kullanım Koşulları'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Kullanım koşulları sayfasına yönlendir
              },
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C6E49),
            ),
          ),
        ),
        ...children,
        const Divider(),
      ],
    );
  }
}
