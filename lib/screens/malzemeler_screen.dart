import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MalzemelerScreen extends StatefulWidget {
  const MalzemelerScreen({super.key});

  @override
  State<MalzemelerScreen> createState() => _MalzemelerScreenState();
}

class _MalzemelerScreenState extends State<MalzemelerScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<Map<String, dynamic>> malzemeler = const [
    {
      'name': 'Traktör',
      'image':
          'https://www.deere.com.tr/assets/images/6m180_r2g079731_large_large_10b025e32822ce8d12dabace57a94c1e7e18a8c7.png',
      'description': 'Tarımda kullanılan güçlü bir motorlu araç.',
      'price': '150,000 TL',
      'categories': ['Motorlu Araçlar', 'Büyük Ekipmanlar'],
    },
    {
      'name': 'Sulama Sistemi',
      'image':
          'https://cdn.wikifarmer.com/images/detailed/2024/09/Sulama-Sistemi-Secerken-Dikkat-Edilmesi-Gereken-Faktorler.jpg',
      'description': 'Bitkilerin düzenli sulanmasını sağlayan sistem.',
      'price': '25,000 TL',
      'categories': ['Sulama', 'Altyapı Sistemleri'],
    },
    {
      'name': 'Tırmık',
      'image':
          'https://cdn.tekzen.com.tr/images/product/agromak/820405/dirgen-4-disli-f-6321_330x330_1.jpg',
      'description': 'Toprağı düzeltmek ve havalandırmak için kullanılır.',
      'price': '850 TL',
      'categories': ['El Aletleri', 'Toprak İşleme'],
    },
    {
      'name': 'Çapa Makinesi',
      'image':
          'https://ideacdn.net/idea/nc/83/myassets/products/012/wwwww.jpg?revision=1742375123',
      'description': 'Hassas toprak işlemesi için ideal elektrikli makine.',
      'price': '12,500 TL',
      'categories': ['Motorlu Araçlar', 'Toprak İşleme'],
    },
  ];

  List<Map<String, dynamic>> filteredMalzemeler = [];
  String selectedCategory = 'Tümü';
  final List<String> categories = [
    'Tümü',
    'Motorlu Araçlar',
    'Sulama',
    'El Aletleri',
    'Toprak İşleme',
    'Altyapı Sistemleri',
    'Büyük Ekipmanlar'
  ];

  @override
  void initState() {
    super.initState();
    filteredMalzemeler = List.from(malzemeler);
  }

  void filterByCategory(String category) {
    setState(() {
      selectedCategory = category;
      if (category == 'Tümü') {
        filteredMalzemeler = List.from(malzemeler);
      } else {
        filteredMalzemeler = malzemeler
            .where((element) => element['categories'].contains(category))
            .toList();
      }
    });
  }

  Future<void> _addToFavorites(Map<String, dynamic> malzeme) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('favoriler')
            .doc(malzeme['name'])
            .set({
          'isim': malzeme['name'],
          'resim': malzeme['image'],
          'fiyat': malzeme['price'],
          'aciklama': malzeme['description'],
          'kategoriler': malzeme['categories'],
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Favorilere eklendi!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata oluştu: $e')),
      );
    }
  }

  Future<void> _removeFromFavorites(String malzemeAdi) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('favoriler')
            .doc(malzemeAdi)
            .delete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Favorilerden kaldırıldı!')),
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
      backgroundColor: const Color(0xFFF5F2E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F2E8),
        title: const Text('Tarım Malzemeleri'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: MalzemeArama(malzemeler: malzemeler),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(categories[index]),
                    selected: selectedCategory == categories[index],
                    onSelected: (selected) {
                      if (selected) {
                        filterByCategory(categories[index]);
                      }
                    },
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: filteredMalzemeler.isEmpty
                ? const Center(child: Text('Bu kategoride malzeme bulunamadı.'))
                : ListView.builder(
                    itemCount: filteredMalzemeler.length,
                    itemBuilder: (context, index) {
                      final malzeme = filteredMalzemeler[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        elevation: 3,
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    MalzemeDetayScreen(malzeme: malzeme),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: SizedBox(
                                    width: 100,
                                    height: 100,
                                    child: Image.network(
                                      malzeme['image']!,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Container(
                                          color: Colors.grey[300],
                                          child: const Icon(
                                              Icons.image_not_supported,
                                              size: 40),
                                        );
                                      },
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    (loadingProgress
                                                            .expectedTotalBytes ??
                                                        1)
                                                : null,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        malzeme['name']!,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        malzeme['description']!,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        malzeme['price']!,
                                        style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Wrap(
                                        spacing: 4,
                                        children: [
                                          for (var category
                                              in malzeme['categories'])
                                            Chip(
                                              label: Text(
                                                category,
                                                style: const TextStyle(
                                                    fontSize: 10),
                                              ),
                                              padding: EdgeInsets.zero,
                                              materialTapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                              visualDensity:
                                                  VisualDensity.compact,
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: StreamBuilder<DocumentSnapshot>(
        stream: _firestore
            .collection('users')
            .doc(_auth.currentUser?.uid)
            .collection('favoriler')
            .doc('Traktör') // Örnek olarak Traktör'ü kontrol ediyoruz
            .snapshots(),
        builder: (context, snapshot) {
          final isFavorite = snapshot.hasData && snapshot.data!.exists;
          return FloatingActionButton(
            onPressed: () {
              if (isFavorite) {
                _removeFromFavorites('Traktör');
              } else {
                _addToFavorites(
                    malzemeler[0]); // Örnek olarak ilk malzemeyi ekliyoruz
              }
            },
            child: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
          );
        },
      ),
    );
  }
}

class MalzemeDetayScreen extends StatelessWidget {
  final Map<String, dynamic> malzeme;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  MalzemeDetayScreen({super.key, required this.malzeme});

  Future<void> _toggleFavorite() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final favRef = _firestore
            .collection('users')
            .doc(user.uid)
            .collection('favoriler')
            .doc(malzeme['name']);

        final doc = await favRef.get();
        if (doc.exists) {
          await favRef.delete();
        } else {
          await favRef.set({
            'isim': malzeme['name'],
            'resim': malzeme['image'],
            'fiyat': malzeme['price'],
            'aciklama': malzeme['description'],
            'kategoriler': malzeme['categories'],
          });
        }
      }
    } catch (e) {
      print('Hata: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F2E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F2E8),
        title: Text(malzeme['name']!),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Paylaşım özelliği yakında eklenecek')),
              );
            },
          ),
          StreamBuilder<DocumentSnapshot>(
            stream: _firestore
                .collection('users')
                .doc(_auth.currentUser?.uid)
                .collection('favoriler')
                .doc(malzeme['name'])
                .snapshots(),
            builder: (context, snapshot) {
              final isFavorite = snapshot.hasData && snapshot.data!.exists;
              return IconButton(
                icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
                onPressed: _toggleFavorite,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              height: 250,
              child: Image.network(
                malzeme['image']!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.image_not_supported, size: 80),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          malzeme['name']!,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                      ),
                      Text(
                        malzeme['price']!,
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (var category in malzeme['categories'])
                        Chip(
                          label: Text(category),
                          backgroundColor: Colors.green[100],
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Açıklama',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${malzeme['description']!}\n\nBu tarım malzemesi modern çiftçilik için tasarlanmıştır. Yüksek kaliteli malzemelerden üretilmiş olup, uzun ömürlü kullanım için idealdir. Düzenli bakım yapıldığında yıllarca sorunsuz çalışması garanti edilir.',
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Özellikler',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildFeature(Icons.check_circle_outline, 'Dayanıklı yapı'),
                  _buildFeature(Icons.check_circle_outline, 'Kolay kullanım'),
                  _buildFeature(Icons.check_circle_outline, '2 yıl garanti'),
                  _buildFeature(Icons.check_circle_outline, 'Servis desteği'),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (context) => Container(
                padding: const EdgeInsets.all(16),
                height: 200,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'İletişim Bilgileri',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      leading: const Icon(Icons.phone),
                      title: const Text('Telefon'),
                      subtitle: const Text('+90 555 123 4567'),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.email),
                      title: const Text('E-posta'),
                      subtitle: const Text('info@tarimmalzemeleri.com'),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Colors.green,
          ),
          child: const Text(
            'İletişime Geç',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeature(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.green),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class MalzemeArama extends SearchDelegate<String> {
  final List<Map<String, dynamic>> malzemeler;

  MalzemeArama({required this.malzemeler});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = malzemeler
        .where((malzeme) =>
            malzeme['name']!.toLowerCase().contains(query.toLowerCase()) ||
            malzeme['description']!.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return _buildSearchResults(context, results);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return const Center(
        child: Text('Malzeme aramak için yazın...'),
      );
    }

    final suggestions = malzemeler
        .where((malzeme) =>
            malzeme['name']!.toLowerCase().contains(query.toLowerCase()) ||
            malzeme['description']!.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return _buildSearchResults(context, suggestions);
  }

  Widget _buildSearchResults(
      BuildContext context, List<Map<String, dynamic>> results) {
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final malzeme = results[index];
        return ListTile(
          leading: SizedBox(
            width: 50,
            height: 50,
            child: Image.network(
              malzeme['image']!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.error);
              },
            ),
          ),
          title: Text(malzeme['name']!),
          subtitle: Text(malzeme['description']!),
          trailing: Text(
            malzeme['price']!,
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MalzemeDetayScreen(malzeme: malzeme),
              ),
            );
            close(context, malzeme['name']!);
          },
        );
      },
    );
  }
}
