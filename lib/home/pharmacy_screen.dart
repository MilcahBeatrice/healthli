import 'package:flutter/material.dart';
import 'package:healthli/home/home_screen.dart';
import 'package:healthli/widgets/bottom_navbar.dart';

class PharmacyScreen extends StatefulWidget {
  const PharmacyScreen({super.key});

  @override
  State<PharmacyScreen> createState() => _PharmacyScreenState();
}

class _PharmacyScreenState extends State<PharmacyScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<DrugItem> _allDrugs = [];
  List<DrugItem> _filteredDrugs = [];

  @override
  void initState() {
    super.initState();
    _initializeDrugs();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _initializeDrugs() {
    // Sample drug data - replace with your actual data source
    _allDrugs = [
      DrugItem(name: 'Paracetamol 500mg', price: '\$12.50'),
      DrugItem(name: 'Ibuprofen 400mg', price: '\$8.75'),
      DrugItem(name: 'Amoxicillin 250mg', price: '\$15.20'),
      DrugItem(name: 'Aspirin 100mg', price: '\$6.30'),
      DrugItem(name: 'Omeprazole 20mg', price: '\$22.10'),
    ];
    _filteredDrugs = List.from(_allDrugs);
  }

  void _onSearchChanged() {
    String query = _searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        _filteredDrugs = List.from(_allDrugs);
      } else {
        _filteredDrugs =
            _allDrugs
                .where((drug) => drug.name.toLowerCase().contains(query))
                .toList();
      }
    });
  }

  void _onFilterTapped() {
    // Implement filter functionality
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            height: 200,
            padding: const EdgeInsets.all(20),
            child: const Column(
              children: [
                Text(
                  'Filter Options',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                Text('Filter functionality coming soon...'),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      bottomNavigationBar: HealthBottomNavBar(
        currentIndex: 0,
        onTap: (index) {
          return Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) {
                return HomeScreen();
              },
            ),
          );
        },
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,

        elevation: 0,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Color(0xFF00A86B),
                size: 24,
              ),
              onPressed: () => Navigator.pop(context),
            );
          },
        ),
        title: const Text(
          'Pharmacy',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Bar Section
          Container(
            padding: const EdgeInsets.all(20),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF008B56), width: 2),
              ),
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 15, right: 10),
                    child: Icon(
                      Icons.search_rounded,
                      color: Color(0xFF008B56),
                      size: 24,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Search for medicines...',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 15),
                      ),
                      style: const TextStyle(color: Colors.black, fontSize: 16),
                    ),
                  ),
                  GestureDetector(
                    onTap: _onFilterTapped,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.only(right: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF008B56),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.tune,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Drug List Section
          Expanded(
            child:
                _filteredDrugs.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _filteredDrugs.length,
                      itemBuilder: (context, index) {
                        return _buildDrugItem(_filteredDrugs[index], index);
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrugItem(DrugItem drug, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          // Drug Image Placeholder
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.medication, color: Colors.grey[500], size: 40),
          ),
          const SizedBox(width: 15),
          // Drug Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  drug.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  drug.price,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Add to Cart Button (Optional)
          // GestureDetector(
          //   onTap: () => _onDrugTapped(drug),
          //   child: Container(
          //     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          //     decoration: BoxDecoration(
          //       color: const Color(0xFF008B56),
          //       borderRadius: BorderRadius.circular(15),
          //     ),
          //     child: const Text(
          //       'Add',
          //       style: TextStyle(
          //         color: Colors.white,
          //         fontSize: 12,
          //         fontWeight: FontWeight.w600,
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            _searchController.text.isEmpty
                ? 'No medicines available'
                : 'No medicines found for "${_searchController.text}"',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          if (_searchController.text.isNotEmpty) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                _searchController.clear();
              },
              child: const Text(
                'Clear search',
                style: TextStyle(
                  color: Color(0xFF00A86B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _onDrugTapped(DrugItem drug) {
    // Handle drug item tap (e.g., add to cart, show details)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${drug.name} added to cart'),
        backgroundColor: const Color(0xFF00A86B),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

// Drug Model Class
class DrugItem {
  final String name;
  final String price;
  final String? imageUrl;
  final String? description;

  DrugItem({
    required this.name,
    required this.price,
    this.imageUrl,
    this.description,
  });

  // Convert from JSON (useful for API integration)
  factory DrugItem.fromJson(Map<String, dynamic> json) {
    return DrugItem(
      name: json['name'] ?? '',
      price: json['price'] ?? '',
      imageUrl: json['imageUrl'],
      description: json['description'],
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
      'description': description,
    };
  }
}

// Usage Example with Navigation
class PharmacyNavigationExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PharmacyScreen()),
        );
      },
      child: const Text('Go to Pharmacy'),
    );
  }
}
