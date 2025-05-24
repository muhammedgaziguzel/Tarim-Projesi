import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdreslerScreen extends StatefulWidget {
  const AdreslerScreen({super.key});

  @override
  State<AdreslerScreen> createState() => _AdreslerScreenState();
}

class _AdreslerScreenState extends State<AdreslerScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  TextEditingController _baslikController = TextEditingController();
  TextEditingController _adSoyadController = TextEditingController();
  TextEditingController _telefonController = TextEditingController();
  TextEditingController _adresController = TextEditingController();
  TextEditingController _ilController = TextEditingController();
  TextEditingController _ilceController = TextEditingController();
  TextEditingController _postaKoduController = TextEditingController();

  @override
  void dispose() {
    _baslikController.dispose();
    _adSoyadController.dispose();
    _telefonController.dispose();
    _adresController.dispose();
    _ilController.dispose();
    _ilceController.dispose();
    _postaKoduController.dispose();
    super.dispose();
  }

  Future<void> _addAddress() async {
    if (_formKey.currentState!.validate()) {
      try {
        final user = _auth.currentUser;
        if (user != null) {
          await _firestore
              .collection('users')
              .doc(user.uid)
              .collection('adresler')
              .add({
            'baslik': _baslikController.text.trim(),
            'adSoyad': _adSoyadController.text.trim(),
            'telefon': _telefonController.text.trim(),
            'adres': _adresController.text.trim(),
            'il': _ilController.text.trim(),
            'ilce': _ilceController.text.trim(),
            'postaKodu': _postaKoduController.text.trim(),
            'varsayilan': false,
            'olusturmaTarihi': FieldValue.serverTimestamp(),
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Adres başarıyla eklendi')),
          );

          // Form alanlarını temizle
          _baslikController.clear();
          _adSoyadController.clear();
          _telefonController.clear();
          _adresController.clear();
          _ilController.clear();
          _ilceController.clear();
          _postaKoduController.clear();
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata oluştu: $e')),
        );
      }
    }
  }

  Future<void> _deleteAddress(String addressId) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('adresler')
            .doc(addressId)
            .delete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Adres silindi')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata oluştu: $e')),
      );
    }
  }

  Future<void> _setDefaultAddress(String addressId) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Önce tüm adreslerin varsayılan durumunu false yap
        final addresses = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('adresler')
            .get();

        for (var doc in addresses.docs) {
          await doc.reference.update({'varsayilan': false});
        }

        // Seçilen adresi varsayılan yap
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('adresler')
            .doc(addressId)
            .update({'varsayilan': true});

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Varsayılan adres güncellendi')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata oluştu: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adreslerim'),
        backgroundColor: const Color(0xFF2C6E49),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('users')
            .doc(_auth.currentUser?.uid)
            .collection('adresler')
            .orderBy('olusturmaTarihi', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Bir hata oluştu: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: snapshot.data?.docs.length ?? 0,
                  itemBuilder: (context, index) {
                    final doc = snapshot.data!.docs[index];
                    final data = doc.data() as Map<String, dynamic>;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  data['baslik'],
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (data['varsayilan'] == true)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green[100],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      'Varsayılan',
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(data['adSoyad']),
                            Text(data['telefon']),
                            const SizedBox(height: 8),
                            Text(data['adres']),
                            Text('${data['ilce']} / ${data['il']}'),
                            Text('Posta Kodu: ${data['postaKodu']}'),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (data['varsayilan'] != true)
                                  TextButton(
                                    onPressed: () => _setDefaultAddress(doc.id),
                                    child: const Text('Varsayılan Yap'),
                                  ),
                                TextButton(
                                  onPressed: () => _deleteAddress(doc.id),
                                  child: const Text(
                                    'Sil',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) => Padding(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Text(
                                  'Yeni Adres Ekle',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _baslikController,
                                  decoration: const InputDecoration(
                                    labelText: 'Adres Başlığı',
                                    hintText: 'Örn: Ev, İş',
                                  ),
                                  validator: (value) =>
                                      value!.isEmpty ? 'Başlık gerekli' : null,
                                ),
                                TextFormField(
                                  controller: _adSoyadController,
                                  decoration: const InputDecoration(
                                    labelText: 'Ad Soyad',
                                  ),
                                  validator: (value) => value!.isEmpty
                                      ? 'Ad Soyad gerekli'
                                      : null,
                                ),
                                TextFormField(
                                  controller: _telefonController,
                                  decoration: const InputDecoration(
                                    labelText: 'Telefon',
                                  ),
                                  keyboardType: TextInputType.phone,
                                  validator: (value) =>
                                      value!.isEmpty ? 'Telefon gerekli' : null,
                                ),
                                TextFormField(
                                  controller: _adresController,
                                  decoration: const InputDecoration(
                                    labelText: 'Adres',
                                  ),
                                  maxLines: 2,
                                  validator: (value) =>
                                      value!.isEmpty ? 'Adres gerekli' : null,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: _ilController,
                                        decoration: const InputDecoration(
                                          labelText: 'İl',
                                        ),
                                        validator: (value) => value!.isEmpty
                                            ? 'İl gerekli'
                                            : null,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: TextFormField(
                                        controller: _ilceController,
                                        decoration: const InputDecoration(
                                          labelText: 'İlçe',
                                        ),
                                        validator: (value) => value!.isEmpty
                                            ? 'İlçe gerekli'
                                            : null,
                                      ),
                                    ),
                                  ],
                                ),
                                TextFormField(
                                  controller: _postaKoduController,
                                  decoration: const InputDecoration(
                                    labelText: 'Posta Kodu',
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (value) => value!.isEmpty
                                      ? 'Posta kodu gerekli'
                                      : null,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    _addAddress();
                                    Navigator.pop(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2C6E49),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                  ),
                                  child: const Text(
                                    'Adresi Kaydet',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2C6E49),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Yeni Adres Ekle',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
