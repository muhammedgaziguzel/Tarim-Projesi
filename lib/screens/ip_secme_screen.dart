import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IpSecmeScreen extends StatefulWidget {
  const IpSecmeScreen({Key? key}) : super(key: key);

  @override
  State<IpSecmeScreen> createState() => _IpSecmeScreenState();
}

class _IpSecmeScreenState extends State<IpSecmeScreen> {
  final TextEditingController _controller = TextEditingController();
  String savedIp = '';

  @override
  void initState() {
    super.initState();
    _loadSavedIp();
  }

  Future<void> _loadSavedIp() async {
    final prefs = await SharedPreferences.getInstance();
    final ip = prefs.getString('ip_adresi') ?? '';
    setState(() {
      savedIp = ip;
      _controller.text = ip;
    });
  }

  Future<void> _saveIp() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ip_adresi', _controller.text);
    setState(() {
      savedIp = _controller.text;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('IP adresi kaydedildi!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('IP Adresi Seç')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'API Sunucu IP Adresi:',
              style: TextStyle(fontSize: 16),
            ),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Örn: 10.20.70.223',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveIp,
              child: const Text('Kaydet'),
            ),
            const SizedBox(height: 20),
            Text('Kayıtlı IP: $savedIp'),
          ],
        ),
      ),
    );
  }
}
