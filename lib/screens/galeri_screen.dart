import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

void main() => runApp(const MyApp());

class AppColors {
  static const Color primary = Color(0xFF2C6E49);
  static const Color secondary = Color(0xFFEAE1C8);
  static const Color background = Color(0xFFEAE1C8);
  static const Color darkPrimary = Color(0xFF1C4E29);
  static const Color darkSecondary = Color(0xFFCCC5AE);
  static const Color darkBackground = Color(0xFFEAE1C8);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fotoğraf Galerisi',
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.secondary,
          background: AppColors.background,
        ),
        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.dark(
          primary: AppColors.darkPrimary,
          secondary: AppColors.darkSecondary,
          surface: AppColors.darkSecondary,
          background: AppColors.darkBackground,
        ),
        scaffoldBackgroundColor: AppColors.darkBackground,
        useMaterial3: true,
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
  final bool isUserCreated;

  const ImageCategory({
    required this.name,
    required this.images,
    required this.icon,
    this.isUserCreated = false,
  });
}

class GaleriScreen extends StatefulWidget {
  const GaleriScreen({super.key});

  @override
  State<GaleriScreen> createState() => _GaleriScreenState();
}

class _GaleriScreenState extends State<GaleriScreen> {
  bool _isListView = false;
  int _gridColumns = 3;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

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
      ],
    ),
  ];

  List<ImageCategory> _userAlbums = [];
  ImageCategory? _selectedAlbum;

  List<ImageCategory> get _allAlbums => [..._categories, ..._userAlbums];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  ImageCategory get _currentAlbum => _selectedAlbum ?? _categories[0];

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

  String _getImageId(String imageUrl) {
    final idMatch = RegExp(r'id/(\d+)/').firstMatch(imageUrl);
    return idMatch?.group(1) ?? 'Bilinmiyor';
  }

  void _showCreateAlbumDialog() {
    String albumName = '';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Yeni Albüm Oluştur'),
          content: TextField(
            decoration: const InputDecoration(hintText: 'Albüm adı'),
            onChanged: (value) => albumName = value,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (albumName.trim().isNotEmpty) {
                  setState(() {
                    _userAlbums.add(ImageCategory(
                      name: albumName,
                      icon: Icons.photo_album,
                      images: [],
                      isUserCreated: true,
                    ));
                    _selectedAlbum = _userAlbums.last;
                  });
                }
                Navigator.pop(context);
              },
              child: const Text('Oluştur'),
            ),
          ],
        );
      },
    );
  }

  void _showAddImageDialog() {
    if (_currentAlbum.isUserCreated == false) return;
    String imageUrl = '';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Fotoğraf Ekle'),
          content: TextField(
            decoration: const InputDecoration(hintText: 'Fotoğraf URL\'si'),
            onChanged: (value) => imageUrl = value,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (imageUrl.trim().isNotEmpty) {
                  setState(() {
                    _currentAlbum.images.add(imageUrl);
                  });
                }
                Navigator.pop(context);
              },
              child: const Text('Ekle'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final filteredImages = _filterImages(_currentAlbum.images);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              color: isDark ? AppColors.darkPrimary : AppColors.primary,
              child: Row(
                children: [
                  _isSearching
                      ? Expanded(
                          child: Container(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.grey[800]
                                  : Colors.white.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TextField(
                              controller: _searchController,
                              decoration: const InputDecoration(
                                hintText: 'Fotoğraf ID\'sine göre ara...',
                                border: InputBorder.none,
                              ),
                              onChanged: (_) => setState(() {}),
                              autofocus: true,
                            ),
                          ),
                        )
                      : Expanded(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<ImageCategory>(
                              value: _currentAlbum,
                              dropdownColor:
                                  isDark ? Colors.grey[800] : Colors.white,
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 16),
                              iconEnabledColor: Colors.black,
                              onChanged: (newAlbum) =>
                                  setState(() => _selectedAlbum = newAlbum),
                              items: _allAlbums
                                  .map((album) => DropdownMenuItem(
                                        value: album,
                                        child: Row(
                                          children: [
                                            Icon(album.icon,
                                                color: Colors.black),
                                            const SizedBox(width: 8),
                                            Text(album.name,
                                                style: const TextStyle(
                                                    color: Colors.black)),
                                          ],
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ),
                        ),
                  IconButton(
                    icon: Icon(_isSearching ? Icons.close : Icons.search,
                        color: Colors.white),
                    onPressed: () =>
                        setState(() => _isSearching = !_isSearching),
                  ),
                  IconButton(
                    icon: Icon(_isListView ? Icons.grid_view : Icons.view_list,
                        color: Colors.white),
                    onPressed: () => setState(() => _isListView = !_isListView),
                  ),
                ],
              ),
            ),
            Expanded(
              child: filteredImages.isEmpty
                  ? const Center(child: Text('Arama sonucu bulunamadı'))
                  : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: _isListView
                          ? _buildListView(filteredImages)
                          : _buildGridView(filteredImages),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: "addAlbum",
            onPressed: _showCreateAlbumDialog,
            child: const Icon(Icons.create_new_folder),
          ),
          const SizedBox(height: 10),
          if (_currentAlbum.isUserCreated)
            FloatingActionButton(
              heroTag: "addPhoto",
              onPressed: _showAddImageDialog,
              child: const Icon(Icons.add),
            ),
        ],
      ),
    );
  }

  Widget _buildGridView(List<String> images) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _gridColumns,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: images.length,
      itemBuilder: (context, index) => _buildGridItem(context, images, index),
    );
  }

  Widget _buildListView(List<String> images) {
    return ListView.builder(
      itemCount: images.length,
      itemBuilder: (context, index) => _buildListItem(context, images, index),
    );
  }

  Widget _buildGridItem(BuildContext context, List<String> images, int index) {
    final imageUrl = images[index];
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => _openDetailScreen(context, imageUrl, index, images),
      child: Hero(
        tag: imageUrl,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black26 : Colors.black12,
                blurRadius: 5,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: isDark
                    ? Colors.grey[800]
                    : AppColors.secondary.withOpacity(0.5),
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                color: isDark
                    ? Colors.grey[800]
                    : AppColors.secondary.withOpacity(0.5),
                child: const Icon(Icons.error),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListItem(BuildContext context, List<String> images, int index) {
    final imageUrl = images[index];
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      child: ListTile(
        onTap: () => _openDetailScreen(context, imageUrl, index, images),
        leading: Hero(
          tag: imageUrl,
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            width: 50,
            height: 50,
            placeholder: (context, url) => Container(
              color: isDark
                  ? Colors.grey[800]
                  : AppColors.secondary.withOpacity(0.5),
              child: const Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (context, url, error) => Container(
              color: isDark
                  ? Colors.grey[800]
                  : AppColors.secondary.withOpacity(0.5),
              child: const Icon(Icons.error),
            ),
          ),
        ),
        title: Text(
          'Fotoğraf ${_getImageId(imageUrl)}',
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
        ),
      ),
    );
  }

  void _openDetailScreen(
      BuildContext context, String imageUrl, int index, List<String> images) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailScreen(imageUrl: imageUrl),
      ),
    );
  }
}

class DetailScreen extends StatelessWidget {
  final String imageUrl;

  const DetailScreen({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fotoğraf Detayı'),
        backgroundColor: isDark ? AppColors.darkPrimary : AppColors.primary,
      ),
      body: Center(
        child: Hero(
          tag: imageUrl,
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.contain,
            placeholder: (context, url) =>
                const Center(child: CircularProgressIndicator()),
            errorWidget: (context, url, error) =>
                const Icon(Icons.error_outline),
          ),
        ),
      ),
    );
  }
}