import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gelişmiş Fotoğraf Galerisi',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        brightness: Brightness.light,
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.indigo,
        brightness: Brightness.dark,
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      themeMode: ThemeMode.system,
      home: const GaleriScreen(),
    );
  }
}

class ImageCategory {
  final String name;
  final List<String> images;
  final IconData icon;

  const ImageCategory({
    required this.name,
    required this.images,
    required this.icon,
  });
}

class GaleriScreen extends StatefulWidget {
  const GaleriScreen({super.key});

  @override
  State<GaleriScreen> createState() => _GaleriScreenState();
}

class _GaleriScreenState extends State<GaleriScreen>
    with SingleTickerProviderStateMixin {
  bool _isListView = false;
  int _currentCrossAxisCount = 3;
  late TabController _tabController;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  // Image categories
  final List<ImageCategory> _categories = [
    ImageCategory(
      name: 'Doğa',
      icon: Icons.landscape,
      images: [
        "https://picsum.photos/id/10/800",
        "https://picsum.photos/id/11/800",
        "https://picsum.photos/id/12/800",
        "https://picsum.photos/id/13/800",
        "https://picsum.photos/id/14/800",
        "https://picsum.photos/id/15/800",
      ],
    ),
    ImageCategory(
      name: 'Şehir',
      icon: Icons.location_city,
      images: [
        "https://picsum.photos/id/16/800",
        "https://picsum.photos/id/17/800",
        "https://picsum.photos/id/18/800",
        "https://picsum.photos/id/19/800",
        "https://picsum.photos/id/20/800",
      ],
    ),
    ImageCategory(
      name: 'Hayvanlar',
      icon: Icons.pets,
      images: [
        "https://picsum.photos/id/21/800",
        "https://picsum.photos/id/22/800",
        "https://picsum.photos/id/23/800",
        "https://picsum.photos/id/24/800",
        "https://picsum.photos/id/25/800",
      ],
    ),
    ImageCategory(
      name: 'Teknoloji',
      icon: Icons.devices,
      images: [
        "https://picsum.photos/id/26/800",
        "https://picsum.photos/id/27/800",
        "https://picsum.photos/id/28/800",
        "https://picsum.photos/id/29/800",
        "https://picsum.photos/id/30/800",
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _toggleViewMode() {
    setState(() {
      _isListView = !_isListView;
    });
  }

  void _changeCrossAxisCount(int count) {
    setState(() {
      _currentCrossAxisCount = count;
    });
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
      }
    });
  }

  List<String> _filterImages(List<String> images) {
    if (!_isSearching || _searchController.text.isEmpty) {
      return images;
    }
    final query = _searchController.text.toLowerCase();
    return images.where((image) {
      final id = image.split('/id/')[1].split('/')[0];
      return id.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Fotoğraf ID\'sine göre ara...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
                onChanged: (_) => setState(() {}),
                autofocus: true,
              )
            : const Text("Fotoğraf Galerisi"),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: _toggleSearch,
            tooltip: _isSearching ? 'Aramayı Kapat' : 'Ara',
          ),
          IconButton(
            icon: Icon(_isListView ? Icons.grid_view : Icons.view_list),
            onPressed: _toggleViewMode,
            tooltip: _isListView ? 'Izgara Görünümü' : 'Liste Görünümü',
          ),
          if (!_isListView)
            PopupMenuButton<int>(
              tooltip: 'Izgara Boyutunu Değiştir',
              icon: const Icon(Icons.grid_3x3),
              onSelected: _changeCrossAxisCount,
              itemBuilder: (context) => [
                const PopupMenuItem<int>(
                  value: 2,
                  child: Text('2 Sütun'),
                ),
                const PopupMenuItem<int>(
                  value: 3,
                  child: Text('3 Sütun'),
                ),
                const PopupMenuItem<int>(
                  value: 4,
                  child: Text('4 Sütun'),
                ),
              ],
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _categories.map((category) {
            return Tab(
              text: category.name,
              icon: Icon(category.icon),
            );
          }).toList(),
        ),
        elevation: 4,
      ),
      body: TabBarView(
        controller: _tabController,
        children: _categories.map((category) {
          final filteredImages = _filterImages(category.images);

          return filteredImages.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image_not_supported,
                          size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        'Arama sonucu bulunamadı',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _isListView
                      ? ListView.builder(
                          itemCount: filteredImages.length,
                          itemBuilder: (context, index) {
                            return _buildListItem(
                                context, filteredImages, index, category);
                          },
                        )
                      : GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: _currentCrossAxisCount,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 1.0,
                          ),
                          itemCount: filteredImages.length,
                          itemBuilder: (context, index) {
                            return _buildGridItem(
                                context, filteredImages, index, category);
                          },
                        ),
                );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Başka bir özellik eklenebilir (örn: favori fotoğrafları gösterme)
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Favoriler özelliği yakında!')));
        },
        tooltip: 'Favoriler',
        child: const Icon(Icons.favorite),
      ),
    );
  }

  Widget _buildGridItem(BuildContext context, List<String> images, int index,
      ImageCategory category) {
    final String imageUrl = images[index];

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BuyukResimScreen(
              resimUrl: imageUrl,
              resimIndex: index,
              tumResimler: images,
              kategoriAdi: category.name,
            ),
          ),
        );
      },
      child: Hero(
        tag: imageUrl,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 5,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.error),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                    child: Text(
                      'ID: ${_getImageId(imageUrl)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListItem(BuildContext context, List<String> images, int index,
      ImageCategory category) {
    final String imageUrl = images[index];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BuyukResimScreen(
                resimUrl: imageUrl,
                resimIndex: index,
                tumResimler: images,
                kategoriAdi: category.name,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            Hero(
              tag: imageUrl,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
                child: SizedBox(
                  width: 100,
                  height: 100,
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.error),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fotoğraf ID: ${_getImageId(imageUrl)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Kategori: ${category.name}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.high_quality, size: 16),
                        const SizedBox(width: 4),
                        Text('800 x 800'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {
                _showImageOptions(context, imageUrl);
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getImageId(String imageUrl) {
    final idMatch = RegExp(r'id/(\d+)/').firstMatch(imageUrl);
    return idMatch?.group(1) ?? 'Bilinmiyor';
  }

  void _showImageOptions(BuildContext context, String imageUrl) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.favorite_border),
                title: const Text('Favorilere Ekle'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Favorilere eklendi!')));
                },
              ),
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text('Paylaş'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Paylaşım özelliği yakında!')));
                },
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Fotoğraf Bilgisi'),
                onTap: () {
                  Navigator.pop(context);
                  _showImageInfo(context, imageUrl);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showImageInfo(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Fotoğraf Bilgisi'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ID: ${_getImageId(imageUrl)}'),
              const SizedBox(height: 8),
              const Text('Boyut: 800 x 800 piksel'),
              const SizedBox(height: 8),
              const Text('Format: JPEG'),
              const SizedBox(height: 8),
              Text('URL: $imageUrl'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Kapat'),
            ),
          ],
        );
      },
    );
  }
}

// Büyük resmi göstermek için geliştirilmiş ekran
class BuyukResimScreen extends StatefulWidget {
  final String resimUrl;
  final int resimIndex;
  final List<String> tumResimler;
  final String kategoriAdi;

  const BuyukResimScreen({
    super.key,
    required this.resimUrl,
    required this.resimIndex,
    required this.tumResimler,
    required this.kategoriAdi,
  });

  @override
  State<BuyukResimScreen> createState() => _BuyukResimScreenState();
}

class _BuyukResimScreenState extends State<BuyukResimScreen>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late int _currentIndex;
  bool _isFullScreen = false;
  bool _isInfoVisible = true;
  bool _isFavorite = false;

  // Basit bir animasyon kontrolcüsü
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.resimIndex;
    _pageController = PageController(initialPage: _currentIndex);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    if (_isFullScreen) {
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
      _isInfoVisible = !_isFullScreen;

      if (_isFullScreen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            _isFavorite ? 'Favorilere eklendi!' : 'Favorilerden çıkarıldı!'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  String _getImageId(String imageUrl) {
    final idMatch = RegExp(r'id/(\d+)/').firstMatch(imageUrl);
    return idMatch?.group(1) ?? 'Bilinmiyor';
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final currentImage = widget.tumResimler[_currentIndex];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _isFullScreen
          ? null
          : AppBar(
              title: Text(
                  "${widget.kategoriAdi} - ${_currentIndex + 1}/${widget.tumResimler.length}"),
              backgroundColor: Colors.black.withOpacity(0.7),
              elevation: 0,
              actions: [
                IconButton(
                  icon: Icon(
                      _isFavorite ? Icons.favorite : Icons.favorite_border),
                  onPressed: _toggleFavorite,
                  tooltip: 'Favorilere Ekle/Çıkar',
                ),
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Paylaşım özelliği yakında!')));
                  },
                  tooltip: 'Paylaş',
                ),
                IconButton(
                  icon: const Icon(Icons.fullscreen),
                  onPressed: _toggleFullScreen,
                  tooltip: 'Tam Ekran',
                ),
              ],
            ),
      body: Stack(
        children: [
          // Ana içerik - PageView
          GestureDetector(
            onTap: _toggleFullScreen,
            child: Container(
              color: Colors.black,
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.tumResimler.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  return InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: Center(
                      child: Hero(
                        tag: widget.tumResimler[index],
                        child: CachedNetworkImage(
                          imageUrl: widget.tumResimler[index],
                          fit: BoxFit.contain,
                          placeholder: (context, url) => const Center(
                            child:
                                CircularProgressIndicator(color: Colors.white),
                          ),
                          errorWidget: (context, url, error) => Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error,
                                  color: Colors.white, size: 48),
                              const SizedBox(height: 8),
                              Text('Resim yüklenemedi: $error',
                                  style: const TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Resim bilgisi kartı - Animasyonlu göster/gizle
          if (_isInfoVisible)
            Positioned(
              top: MediaQuery.of(context).padding.top +
                  (AppBar().preferredSize.height * 1.1),
              right: 16,
              child: FadeTransition(
                opacity: _opacityAnimation,
                child: Card(
                  color: (isDarkMode
                          ? const Color.fromARGB(255, 34, 33, 33)
                          : Colors.white)
                      .withOpacity(0.8),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fotoğraf Bilgisi',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'ID: ${_getImageId(currentImage)}',
                          style: TextStyle(
                            color: isDarkMode ? Colors.white70 : Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Boyut: 800 x 800',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Kategori: ${widget.kategoriAdi}',
                          style: TextStyle(
                            color: isDarkMode ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Kaydırma indikatörü
          Positioned(
            top: MediaQuery.of(context).size.height / 2,
            left: 8,
            child: FadeTransition(
              opacity: _opacityAnimation,
              child: _currentIndex > 0
                  ? IconButton(
                      icon: Container(
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          shape: BoxShape.circle,
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(4.0),
                          child:
                              Icon(Icons.arrow_back_ios, color: Colors.white),
                        ),
                      ),
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                    )
                  : const SizedBox.shrink(),
            ),
          ),

          Positioned(
            top: MediaQuery.of(context).size.height / 2,
            right: 8,
            child: FadeTransition(
              opacity: _opacityAnimation,
              child: _currentIndex < widget.tumResimler.length - 1
                  ? IconButton(
                      icon: Container(
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          shape: BoxShape.circle,
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Icon(Icons.arrow_forward_ios,
                              color: Colors.white),
                        ),
                      ),
                      onPressed: () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _isFullScreen
          ? null
          : BottomAppBar(
              color: Colors.black.withOpacity(0.8),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon:
                          const Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: _currentIndex > 0
                          ? () {
                              _pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                          : null,
                      color: _currentIndex > 0 ? Colors.white : Colors.white38,
                    ),
                    Text(
                      '${_currentIndex + 1} / ${widget.tumResimler.length}',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios,
                          color: Colors.white),
                      onPressed: _currentIndex < widget.tumResimler.length - 1
                          ? () {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                          : null,
                      color: _currentIndex < widget.tumResimler.length - 1
                          ? Colors.white
                          : Colors.white38,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
