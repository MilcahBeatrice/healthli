import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:healthli/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healthli/database/models/medicine_model.dart';
import 'package:healthli/services/sync_service.dart';

class PharmacyScreen extends ConsumerStatefulWidget {
  const PharmacyScreen({super.key});

  @override
  ConsumerState<PharmacyScreen> createState() => _PharmacyScreenState();
}

class _PharmacyScreenState extends ConsumerState<PharmacyScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onFilterTapped() {
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
    final query = _searchController.text.trim();
    final drugsAsync = ref.watch(searchDrugProvider(query));
    return Scaffold(
      backgroundColor: Colors.white,
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
                      onSubmitted: (_) => setState(() {}),
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
            child: drugsAsync.when(
              data: (drugs) {
                if (drugs.isEmpty) {
                  return _buildEmptyState(query);
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: drugs.length,
                  itemBuilder: (context, index) {
                    return _buildDrugItem(drugs[index], index);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (err, stack) => Center(
                    child: Text(
                      'Error: $err',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrugItem(Medicine drug, int index) {
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
                // Text(
                //   drug.id,
                //   style: const TextStyle(
                //     fontSize: 14,
                //     color: Colors.grey,
                //     fontWeight: FontWeight.w500,
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String query) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            query.isEmpty
                ? 'No medicines available'
                : 'No medicines found for "$query"',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          if (query.isNotEmpty) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                _searchController.clear();
                setState(() {});
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

  void _onDrugTapped(Medicine drug) async {
    // Save to Firestore drug_history for the current user
    final user = ref.read(firebaseAuthProvider).currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('drug_history')
          .doc(drug.id)
          .set({
            'id': drug.id,
            'name': drug.name,
            'timestamp': DateTime.now().toIso8601String(),
          });
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${drug.name} saved to history'),
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
