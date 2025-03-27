import 'package:flutter/material.dart';

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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2C6E49)),
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

class _BitkilerimPageState extends State<BitkilerimPage> {
  final List<Plant> _selectedPlants = []; // User's selected plants
  final List<Plant> _allPlants = [
    Plant(name: "Domates", image: "assets/images/bitki.png"),
    Plant(name: "Biber", image: "assets/images/bitki.png"),
    Plant(name: "Patlıcan", image: "assets/images/bitki.png"),
    Plant(name: "Bitki 1", image: "assets/images/bitki.png"),
    Plant(name: "Bitki 2", image: "assets/images/bitki.png"),
    Plant(name: "Bitki 3", image: "assets/images/bitki.png"),
    Plant(name: "Bitki 4", image: "assets/images/bitki.png"),
    Plant(name: "Bitki 5", image: "assets/images/bitki.png"),
    Plant(name: "Bitki 6", image: "assets/images/bitki.png"),
  ];

  void _addPlant(Plant plant) {
    if (!_selectedPlants.contains(plant)) {
      setState(() {
        _selectedPlants.add(plant);
      });
    } else {
      _showPlantAlreadyAddedMessage();
    }
  }

  void _removePlant(Plant plant) {
    setState(() {
      _selectedPlants.remove(plant);
    });
  }

  void _showPlantAlreadyAddedMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bu bitki zaten eklenmiş'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showAddPlantDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Color(0xFFEAE1C8),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Yeni Bitki Ekle',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.75,
                ),
                itemCount: _allPlants.length,
                itemBuilder: (context, index) {
                  final plant = _allPlants[index];
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAE1C8),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16), // Add some space at the top
            // Selected plants section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                  ),
                ],
              ),
              margin: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Text(
                      "Bitkilerim",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _selectedPlants.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              "Henüz hiç bitki eklenmedi",
                              style: TextStyle(
                                color: Colors.grey,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        )
                      : Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: _selectedPlants.map((plant) {
                            return GestureDetector(
                              onLongPress: () => _removePlant(plant),
                              child: Tooltip(
                                message: "Kaldırmak için uzun basın",
                                child: Column(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.asset(
                                        plant.image,
                                        width: 70,
                                        height: 70,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      plant.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                ],
              ),
            ),

            // Add New Plant Button
            Center(
              child: ElevatedButton.icon(
                onPressed: _showAddPlantDialog,
                icon: const Icon(Icons.add),
                label: const Text("Yeni Bitki Ekle"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2C6E49),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),

            // All plants grid
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        "Tüm Bitkiler",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: _allPlants.length,
                        itemBuilder: (context, index) {
                          final plant = _allPlants[index];
                          final bool isSelected =
                              _selectedPlants.contains(plant);

                          return PlantCard(
                            plant: plant,
                            isSelected: isSelected,
                            onTap: () => _addPlant(plant),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Plant {
  final String name;
  final String image;

  const Plant({required this.name, required this.image});

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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF2C6E49).withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF2C6E49) : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.topRight,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    plant.image,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                ),
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C6E49),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              plant.name,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
} 