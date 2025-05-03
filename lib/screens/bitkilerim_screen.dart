import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const BitkilerimApp());
}

class BitkilerimApp extends StatelessWidget {
  const BitkilerimApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF2C6E49),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2C6E49),
          secondary: const Color(0xFFFF7D00),
        ),
        textTheme: GoogleFonts.nunitoTextTheme(),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 3,
            backgroundColor: const Color(0xFF2C6E49),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        useMaterial3: true,
      ),
      home: const BitkilerimPage(),
    );
  }
}

class BitkilerimPage extends StatefulWidget {
  const BitkilerimPage({super.key});

  @override
  State<BitkilerimPage> createState() => _BitkilerimPageState();
}

class _BitkilerimPageState extends State<BitkilerimPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  final List<Plant> _selectedPlants = []; // User's selected plants
  final List<Plant> _allPlants = [
    Plant(name: "Domates", image: "assets/images/domates.jpg", category: "Sebze"),
    Plant(name: "Biber", image: "assets/images/yeşil.jpg", category: "Sebze"),
    Plant(name: "Patlıcan", image: "assets/images/patlıcan.jpg", category: "Sebze"),
    Plant(name: "Gül", image: "assets/images/gül.jpg", category: "Çiçek"),
    Plant(name: "Lale", image: "assets/images/lale.jpg", category: "Çiçek"),
    Plant(name: "Papatya", image: "assets/images/papatya.jpg", category: "Çiçek"),
    Plant(name: "Menekşe", image: "assets/images/bitki.png", category: "Çiçek"),
    Plant(name: "Elma", image: "assets/images/bitki.png", category: "Meyve"),
    Plant(name: "Armut", image: "assets/images/bitki.png", category: "Meyve"),
  ];

  List<String> get _categories => _allPlants.map((p) => p.category).toSet().toList();
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length + 1, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addPlant(Plant plant) {
    if (!_selectedPlants.contains(plant)) {
      setState(() {
        _selectedPlants.add(plant);
      });
      _showSuccessMessage("${plant.name} bahçenize eklendi");
    } else {
      _showErrorMessage("${plant.name} zaten bahçenizde mevcut");
    }
  }

  void _removePlant(Plant plant) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("${plant.name} Kaldırılsın mı?"),
        content: const Text("Bu bitkiyi bahçenizden kaldırmak istediğinize emin misiniz?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("İptal", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _selectedPlants.remove(plant);
              });
              Navigator.pop(context);
              _showSuccessMessage("${plant.name} bahçenizden kaldırıldı");
            },
            child: const Text("Kaldır", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: const Color(0xFF2C6E49),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showAddPlantDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Color(0xFFEAE1C8),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Handle indicator
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            
                  
            const Divider(),
            
            // Category tabs
            TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              dividerColor: Colors.transparent,
              indicatorColor: const Color(0xFF2C6E49),
              labelColor: const Color(0xFF2C6E49),
              unselectedLabelColor: Colors.grey[600],
              tabs: [
                const Tab(text: "Tümü"),
                ..._categories.map((category) => Tab(text: category)).toList(),
              ],
            ),
            
            // Plants grid
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // All plants tab
                  _buildPlantsGrid(_allPlants),
                  // Category specific tabs
                  ..._categories.map((category) => 
                    _buildPlantsGrid(_allPlants.where((p) => p.category == category).toList())
                  ).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlantsGrid(List<Plant> plants) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: plants.length,
      itemBuilder: (context, index) {
        final plant = plants[index];
        final bool isSelected = _selectedPlants.contains(plant);

        return PlantCard(
          plant: plant,
          isSelected: isSelected,
          onTap: () {
            if (!isSelected) {
              _addPlant(plant);
            }
            Navigator.pop(context);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F2E8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Row(
          children: [
            const Icon(Icons.eco, color: Color(0xFF2C6E49)),
            const SizedBox(width: 8),
            
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFF2C6E49)),
            onPressed: () {/* Search functionality */},
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Color(0xFF2C6E49)),
            onPressed: () {/* Notifications */},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Refresh logic would go here
          await Future.delayed(const Duration(milliseconds: 800));
        },
        color: const Color(0xFF2C6E49),
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Header section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Text(
                  "Bahçenizi sağlıklı ve güzel tutmak için bitkilerinizi takip edin",
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ),
            
            // Selected plants section
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      spreadRadius: 0,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Bahçemdeki Bitkiler",
                          style: GoogleFonts.nunito(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          "${_selectedPlants.length} bitki",
                          style: GoogleFonts.nunito(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _selectedPlants.isEmpty
                        ? Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 30),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.spa_outlined,
                                    size: 48,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    "Henüz hiç bitki eklenmedi",
                                    style: GoogleFonts.nunito(
                                      color: Colors.grey[600],
                                      fontSize: 16,
                                    ),
                                  ),
                                  
                                ],
                              ),
                            ),
                          )
                        : Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            children: _selectedPlants.map((plant) {
                              return GestureDetector(
                                onTap: () {
                                  // Show plant detail screen
                                },
                                onLongPress: () => _removePlant(plant),
                                child: Tooltip(
                                  message: "Kaldırmak için uzun basın",
                                  child: Container(
                                    width: 90,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.grey[200]!,
                                        width: 1,
                                      ),
                                    ),
                                    padding: const EdgeInsets.all(8),
                                    child: Column(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFEAE1C8).withOpacity(0.5),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          padding: const EdgeInsets.all(8),
                                          child: Image.asset(
                                            plant.image,
                                            width: 60,
                                            height: 60,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          plant.name,
                                          style: GoogleFonts.nunito(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          plant.category,
                                          style: GoogleFonts.nunito(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                  ],
                ),
              ),
            ),

            // Add New Plant Button
           

            // All plants section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Popüler Bitkiler",
                      style: GoogleFonts.nunito(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    TextButton(
                      onPressed: _showAddPlantDialog,
                      child: Text(
                        "Tümünü Gör",
                        style: GoogleFonts.nunito(
                          color: const Color(0xFF2C6E49),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.75,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index >= _allPlants.length) return null;
                    final plant = _allPlants[index];
                    final bool isSelected = _selectedPlants.contains(plant);

                    return PlantCard(
                      plant: plant,
                      isSelected: isSelected,
                      onTap: () => _addPlant(plant),
                    );
                  },
                  childCount: _allPlants.length > 6 ? 6 : _allPlants.length,
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPlantDialog,
        backgroundColor: const Color(0xFF2C6E49),
        foregroundColor: Colors.white,
        elevation: 4,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class Plant {
  final String name;
  final String image;
  final String category;

  const Plant({
    required this.name, 
    required this.image, 
    required this.category,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Plant && runtimeType == other.runtimeType && name == other.name;

  @override
  int get hashCode => name.hashCode;
}

class PlantCard extends StatelessWidget {
  final Plant plant;
  final bool isSelected;
  final VoidCallback onTap;

  const PlantCard({
    super.key,
    required this.plant,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: const Color(0xFF2C6E49).withOpacity(0.1),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF2C6E49).withOpacity(0.1)
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? const Color(0xFF2C6E49) : Colors.grey.shade200,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                spreadRadius: 0,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.topRight,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAE1C8).withOpacity(0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        plant.image,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFF2C6E49),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                plant.name,
                style: GoogleFonts.nunito(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected ? const Color(0xFF2C6E49) : Colors.black87,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                plant.category,
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}