import 'package:flutter/material.dart';
import 'package:healthli/home/home_screen.dart';
import 'package:healthli/widgets/bottom_navbar.dart';
import 'package:healthli/services/doctor_service.dart';

class FindDoctorScreen extends StatefulWidget {
  const FindDoctorScreen({super.key});

  @override
  State<FindDoctorScreen> createState() => _FindDoctorScreenState();
}

class _FindDoctorScreenState extends State<FindDoctorScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<DoctorItem> _allDoctors = [];
  List<DoctorItem> _filteredDoctors = [];
  bool _loadingDoctors = false;

  @override
  void initState() {
    super.initState();
    fetchDoctorsFromCloud();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _initializeDoctors() {
    // Deprecated: now fetching from Firestore
    _allDoctors = [];
    _filteredDoctors = [];
  }

  void fetchDoctorsFromCloud() async {
    setState(() {
      _loadingDoctors = true;
    });
    final doctorMaps = await DoctorService.fetchDoctorsFromFirestore();
    final doctors = doctorMaps.map((e) => DoctorItem.fromJson(e)).toList();
    setState(() {
      _allDoctors = doctors;
      _filteredDoctors = List.from(doctors);
      _loadingDoctors = false;
    });
  }

  void _onSearchChanged() {
    String query = _searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        _filteredDoctors = List.from(_allDoctors);
      } else {
        _filteredDoctors =
            _allDoctors
                .where(
                  (doc) =>
                      doc.name.toLowerCase().contains(query) ||
                      doc.specialty.toLowerCase().contains(query),
                )
                .toList();
      }
    });
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
    return Scaffold(
      backgroundColor: Colors.white,
      // bottomNavigationBar: HealthBottomNavBar(
      //   currentIndex: 0,
      //   onTap: (index) {
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(builder: (_) => HomeScreen()),
      //     );
      //   },
      // ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF00A86B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Find Doctor',
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
          // Search Bar
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
                    padding: EdgeInsets.symmetric(horizontal: 10),
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
                        hintText: 'Search for doctors...',
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

          // Doctor List
          Expanded(
            child:
                _loadingDoctors
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredDoctors.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _filteredDoctors.length,
                      itemBuilder: (context, index) {
                        return _buildDoctorItem(_filteredDoctors[index]);
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorItem(DoctorItem doctor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.person, color: Colors.grey[600], size: 40),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctor.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  doctor.specialty,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
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
                ? 'No doctors available'
                : 'No doctors found for "${_searchController.text}"',
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
}

// Doctor Model
class DoctorItem {
  final String name;
  final String specialty;
  final String? imageUrl;
  final String? description;

  DoctorItem({
    required this.name,
    required this.specialty,
    this.imageUrl,
    this.description,
  });

  factory DoctorItem.fromJson(Map<String, dynamic> json) {
    return DoctorItem(
      name: json['name'] ?? '',
      specialty: json['specialty'] ?? '',
      imageUrl: json['imageUrl'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'specialty': specialty,
      'imageUrl': imageUrl,
      'description': description,
    };
  }
}

// Navigation Example
class FindDoctorNavigationExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const FindDoctorScreen()),
        );
      },
      child: const Text('Find a Doctor'),
    );
  }
}
