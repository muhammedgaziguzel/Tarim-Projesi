import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilDuzenleScreen extends StatefulWidget {
  const ProfilDuzenleScreen({super.key});

  @override
  State<ProfilDuzenleScreen> createState() => _ProfilDuzenleScreenState();
}

class _ProfilDuzenleScreenState extends State<ProfilDuzenleScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();

  TextEditingController _isimController = TextEditingController();
  TextEditingController _soyisimController = TextEditingController();
  TextEditingController _telefonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        setState(() {
          _isimController.text = doc['isim'] ?? '';
          _soyisimController.text = doc['soyisim'] ?? '';
          _telefonController.text = doc['telefon'] ?? '';
        });
      }
    }
  }

  Future<void> _saveChanges() async {
    final user = _auth.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'isim': _isimController.text.trim(),
        'soyisim': _soyisimController.text.trim(),
        'telefon': _telefonController.text.trim(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profil başarıyla güncellendi")),
      );
      Navigator.pop(context); // geri dön
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profili Düzenle"),
        backgroundColor: const Color(0xFF2C6E49),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _isimController,
                decoration: const InputDecoration(labelText: "İsim"),
                validator: (value) => value!.isEmpty ? 'İsim boş olamaz' : null,
              ),
              TextFormField(
                controller: _soyisimController,
                decoration: const InputDecoration(labelText: "Soyisim"),
                validator: (value) =>
                    value!.isEmpty ? 'Soyisim boş olamaz' : null,
              ),
              TextFormField(
                controller: _telefonController,
                decoration: const InputDecoration(labelText: "Telefon"),
                keyboardType: TextInputType.phone,
                validator: (value) =>
                    value!.isEmpty ? 'Telefon boş olamaz' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _saveChanges();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2C6E49),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child:
                    const Text("Kaydet", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
