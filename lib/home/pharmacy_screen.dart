import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:healthli/services/auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healthli/database/models/medicine_model.dart';
import 'package:healthli/services/sync_service.dart';

class PharmacyScreen extends ConsumerStatefulWidget {
  const PharmacyScreen({super.key});

  @override
  ConsumerState<PharmacyScreen> createState() => _PharmacyScreenState();
}

class _PharmacyScreenState extends ConsumerState<PharmacyScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String _selectedCategory = 'All';
  bool _isSearchFocused = false;
  final FocusNode _searchFocusNode = FocusNode();

  final List<String> _categories = [
    'All',
    'Pain Relief',
    'Antibiotics',
    'Vitamins',
    'Heart',
    'Diabetes',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();

    _searchFocusNode.addListener(() {
      setState(() {
        _isSearchFocused = _searchFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onFilterTapped() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildFilterBottomSheet(),
    );
  }

  Widget _buildFilterBottomSheet() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Filter & Sort',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Categories
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Categories',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                  child: Container(
                    width: 80,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? const Color(0xFF00A86B)
                              : Colors.grey[100],
                      borderRadius: BorderRadius.circular(16),
                      border:
                          isSelected
                              ? null
                              : Border.all(color: Colors.grey[300]!, width: 1),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _getCategoryIcon(category),
                          color: isSelected ? Colors.white : Colors.grey[600],
                          size: 24,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          category,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isSelected ? Colors.white : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const Spacer(),
          // Apply button
          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {});
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00A86B),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Apply Filters',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Pain Relief':
        return Icons.healing;
      case 'Antibiotics':
        return Icons.biotech;
      case 'Vitamins':
        return Icons.eco;
      case 'Heart':
        return Icons.favorite;
      case 'Diabetes':
        return Icons.bloodtype;
      default:
        return Icons.medication;
    }
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim();
    final drugsAsync = ref.watch(searchDrugProvider(query));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchSection(),
            _buildCategoryTabs(),
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: drugsAsync.when(
                  data: (drugs) {
                    if (drugs.isEmpty) {
                      return _buildEmptyState(query);
                    }
                    return _buildDrugsList(drugs);
                  },
                  loading: () => _buildLoadingState(),
                  error: (err, stack) => _buildErrorState(err.toString()),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Color(0xFF00A86B),
                size: 18,
              ),
            ),
          ),
          const Expanded(
            child: Text(
              'Pharmacy',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.notifications_outlined,
              color: Colors.grey,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color:
                      _isSearchFocused
                          ? const Color(0xFF00A86B)
                          : Colors.grey[300]!,
                  width: _isSearchFocused ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 16, right: 12),
                    child: Icon(
                      Icons.search_rounded,
                      color: Color(0xFF00A86B),
                      size: 24,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      decoration: const InputDecoration(
                        hintText: 'Search medicines, brands...',
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 16),
                      ),
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      onSubmitted: (_) => setState(() {}),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  if (_searchController.text.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        setState(() {});
                      },
                      child: const Padding(
                        padding: EdgeInsets.only(right: 16),
                        child: Icon(Icons.close, color: Colors.grey, size: 20),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _onFilterTapped,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00A86B), Color(0xFF00C878)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00A86B).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.tune, color: Colors.white, size: 24),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(top: 8, bottom: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = category;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF00A86B) : Colors.white,
                borderRadius: BorderRadius.circular(25),
                border:
                    isSelected
                        ? null
                        : Border.all(color: Colors.grey[300]!, width: 1),
                boxShadow:
                    isSelected
                        ? [
                          BoxShadow(
                            color: const Color(0xFF00A86B).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                        : null,
              ),
              child: Text(
                category,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[600],
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDrugsList(List<Medicine> drugs) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: drugs.length,
      itemBuilder: (context, index) {
        final drug = drugs[index];
        return _buildDrugItem(drug, index);
      },
    );
  }

  Widget _buildDrugItem(Medicine drug, int index) {
    return GestureDetector(
      onTap: () => _showDrugDetails(drug),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Medicine Image/Icon
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF00A86B).withOpacity(0.1),
                    const Color(0xFF00C878).withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child:
                  drug.imageUrl != null && drug.imageUrl!.isNotEmpty
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          drug.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) =>
                                  _buildDefaultMedicineIcon(),
                        ),
                      )
                      : _buildDefaultMedicineIcon(),
            ),
            const SizedBox(width: 16),
            // Medicine Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    drug.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (drug.dosage.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00A86B).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        drug.dosage,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF00A86B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  if (drug.uses.isNotEmpty)
                    Text(
                      drug.uses,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            // Arrow Icon
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF00A86B).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.arrow_forward_ios,
                color: Color(0xFF00A86B),
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultMedicineIcon() {
    return const Icon(
      Icons.medication_liquid,
      color: Color(0xFF00A86B),
      size: 32,
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF00A86B).withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
            ),
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00A86B)),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Searching medicines...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(Icons.error_outline, color: Colors.red, size: 40),
          ),
          const SizedBox(height: 16),
          const Text(
            'Something went wrong',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please try again later',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => setState(() {}),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00A86B),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Try Again'),
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
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFF00A86B).withOpacity(0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(
              Icons.search_off,
              color: Color(0xFF00A86B),
              size: 50,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            query.isEmpty ? 'No medicines available' : 'No results found',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            query.isEmpty
                ? 'Start typing to search for medicines'
                : 'Try different keywords or check spelling',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          if (query.isNotEmpty) ...[
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                _searchController.clear();
                setState(() {});
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00A86B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Clear Search',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showDrugDetails(Medicine drug) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(top: 12, bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header with image and basic info
                          // ...existing header code...
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(16),
                                  image:
                                      drug.imageUrl != null &&
                                              drug.imageUrl!.isNotEmpty
                                          ? DecorationImage(
                                            image: NetworkImage(drug.imageUrl!),
                                            fit: BoxFit.cover,
                                          )
                                          : null,
                                ),
                                child:
                                    drug.imageUrl == null ||
                                            drug.imageUrl!.isEmpty
                                        ? const Icon(
                                          Icons.medication,
                                          size: 40,
                                          color: Color(0xFF00A86B),
                                        )
                                        : null,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      drug.name,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    if (drug.synonym != null &&
                                        drug.synonym!.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 4.0,
                                        ),
                                        child: Text(
                                          drug.synonym!,
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.grey[700],
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                    if (drug.dosage.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 8.0,
                                        ),
                                        child: Chip(
                                          label: Text(drug.dosage),
                                          backgroundColor: const Color(
                                            0xFF00A86B,
                                          ).withOpacity(0.1),
                                          labelStyle: const TextStyle(
                                            color: Color(0xFF00A86B),
                                          ),
                                        ),
                                      ),
                                    // RxNav Details Section

                                    // ...existing RxNav details code...

                                    // Ingredients Section
                                    if (drug.drugDetails.ingredients.isNotEmpty)
                                      _buildInfoSection(
                                        'Ingredients',
                                        drug.drugDetails.ingredients.join(', '),
                                        Icons.local_pharmacy,
                                        const Color(0xFF2196F3),
                                      ),
                                    // ...existing ingredients code...

                                    // Uses Section
                                    if (drug.uses.isNotEmpty) ...[
                                      _buildInfoSection(
                                        'Uses',
                                        drug.uses,
                                        Icons.medical_services,
                                        const Color(0xFF4CAF50),
                                      ),
                                      const SizedBox(height: 24),
                                    ],
                                    // Side Effects Section
                                    if (drug.sideEffects.isNotEmpty) ...[
                                      _buildInfoSection(
                                        'Side Effects',
                                        drug.sideEffects,
                                        Icons.warning_amber,
                                        const Color(0xFFFF9800),
                                      ),
                                      const SizedBox(height: 24),
                                    ],
                                    // Action Buttons
                                    // ...existing action buttons code...
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed:
                                                () => _onDrugTapped(drug),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(
                                                0xFF00A86B,
                                              ),
                                              foregroundColor: Colors.white,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 16,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                              elevation: 0,
                                            ),
                                            child: const Text(
                                              'Save to History',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Container(
                                          width: 56,
                                          height: 56,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[100],
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                          child: IconButton(
                                            onPressed: () {
                                              // Add to favorites functionality
                                            },
                                            icon: const Icon(
                                              Icons.favorite_outline,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 32),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  //           end: Alignment.bottomRight,
  //         ),
  //         borderRadius: BorderRadius.circular(20),
  //         boxShadow: [
  //           BoxShadow(
  //             color: const Color(0xFF00A86B).withOpacity(0.1),
  //             blurRadius: 10,
  //             offset: const Offset(0, 4),
  //           ),
  //         ],
  //       ),
  //       child: drug.imageUrl != null && drug.imageUrl!.isNotEmpty
  //           ? ClipRRect(
  //               borderRadius: BorderRadius.circular(20),
  //               child: Image.network(
  //                 drug.imageUrl!,
  //                 fit: BoxFit.cover,
  //                 errorBuilder: (context, error, stackTrace) => _buildDefaultMedicineIcon(),
  //               ),
  //             )
  //           : _buildDefaultMedicineIcon(),
  //     ),
  //     const SizedBox(width: 20),
  //     Expanded(
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text(
  //             drug.name,
  //             style: const TextStyle(
  //               fontSize: 24,
  //               fontWeight: FontWeight.bold,
  //               color: Colors.black87,
  //               height: 1.2,
  //             ),
  //           ),
  //           if (drug.synonym != null && drug.synonym!.isNotEmpty)
  //             Padding(
  //               padding: const EdgeInsets.only(top: 4.0),
  //               child: Text(
  //                 drug.synonym!,
  //                 style: TextStyle(
  //                   fontSize: 15,
  //                   color: Colors.grey[700],
  //                   fontWeight: FontWeight.w400,
  //                 ),
  //               ),
  //             ),
  //           const SizedBox(height: 8),
  //           // Dosage Form Chip
  //           if (drug.dosage.isNotEmpty)
  //             Container(
  //               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  //               decoration: BoxDecoration(
  //                 color: const Color(0xFF00A86B).withOpacity(0.1),
  //                 borderRadius: BorderRadius.circular(20),
  //                 border: Border.all(color: const Color(0xFF00A86B).withOpacity(0.2)),
  //               ),
  //               child: Row(
  //                 mainAxisSize: MainAxisSize.min,
  //                 children: [
  //                   const Icon(Icons.medication, size: 16, color: Color(0xFF00A86B)),
  //                   const SizedBox(width: 6),
  //                   Text(
  //                     drug.dosage,
  //                     style: const TextStyle(fontSize: 14, color: Color(0xFF00A86B), fontWeight: FontWeight.w600),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //         ],
  //       ),
  //     );

  // const SizedBox(height: 24),
  // // RxNav Details Section
  // Card(
  //   elevation: 0,
  //   color: Colors.grey[50],
  //   shape: RoundedRectangleBorder(
  //     borderRadius: BorderRadius.circular(16),
  //     side: BorderSide(color: Colors.grey[200]!),
  //   ),
  //   child: Padding(
  //     padding: const EdgeInsets.all(16),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Row(
  //           children: [
  //             const Icon(Icons.info_outline, color: Color(0xFF00A86B), size: 18),
  //             const SizedBox(width: 8),
  //             Text('RxNorm Details', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00A86B))),
  //           ],
  //         ),
  //         const SizedBox(height: 12),
  //         Wrap(
  //           spacing: 12,
  //           runSpacing: 8,
  //           children: [
  //             if (drug.tty != null) Chip(label: Text('Type: ${drug.tty}')),
  //             if (drug.language != null) Chip(label: Text('Lang: ${drug.language}')),
  //             if (drug.suppress != null) Chip(label: Text('Suppress: ${drug.suppress}')),
  //             if (drug.psn != null) Chip(label: Text('PSN: ${drug.psn}')),
  //             Chip(label: Text('RxCUI: ${drug.id}')),
  //           ],
  //         ),
  //         if (drug.codes != null && drug.codes!.isNotEmpty) ...[
  //           const SizedBox(height: 12),
  //           Text('Codes:', style: TextStyle(fontWeight: FontWeight.w600)),
  //           ...drug.codes!.entries.map((e) => Padding(
  //             padding: const EdgeInsets.only(left: 8, top: 2),
  //             child: Text('${e.key}: ${e.value}', style: TextStyle(color: Colors.grey[800], fontSize: 13)),
  //           )),
  //         ],
  //       ],
  //     ),
  //   ),
  // );
  // const SizedBox(height: 24),

  Widget _buildInfoSection(
    String title,
    String content,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
  //    ],
  //                                   ),
  //                                 );
  //                               },
  //                             ),
  //                           ],
  //                         ),
  //                       ),
  //                     ),
  //                     const SizedBox(height: 24),
  //                     // Uses Section
  //                     if (drug.uses.isNotEmpty) ...[
  //                       _buildInfoSection('Uses', drug.uses, Icons.medical_services, const Color(0xFF4CAF50)),
  //                       const SizedBox(height: 24),
  //                     ],
  //                     // Side Effects Section
  //                     if (drug.sideEffects.isNotEmpty) ...[
  //                       _buildInfoSection('Side Effects', drug.sideEffects, Icons.warning_amber, const Color(0xFFFF9800)),
  //                       const SizedBox(height: 24),
  //                     ],
  //                     // Action Buttons
  //                     Row(
  //                       children: [
  //                         Expanded(
  //                           child: ElevatedButton(
  //                             onPressed: () => _onDrugTapped(drug),
  //                             style: ElevatedButton.styleFrom(
  //                               backgroundColor: const Color(0xFF00A86B),
  //                               foregroundColor: Colors.white,
  //                               padding: const EdgeInsets.symmetric(vertical: 16),
  //                               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  //                               elevation: 0,
  //                             ),
  //                             child: const Text('Save to History', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
  //                           ),
  //                         ),
  //                         const SizedBox(width: 16),
  //                         Container(
  //                           width: 56,
  //                           height: 56,
  //                           decoration: BoxDecoration(
  //                             color: Colors.grey[100],
  //                             borderRadius: BorderRadius.circular(16),
  //                           ),
  //                           child: IconButton(
  //                             onPressed: () {
  //                               // Add to favorites functionality
  //                             },
  //                             icon: const Icon(Icons.favorite_outline, color: Colors.grey),
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                     const SizedBox(height: 32),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   ),
  // );

  // ...existing code for _buildInfoSection...

  void _onDrugTapped(Medicine drug) async {
    // Save to Firestore drug_history for the current user
    final auth = ref.read(firebaseAuthProvider);
    final user = auth.currentUser;

    if (user != null) {
      try {
        final drugHistoryRef = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('drug_history');

        await drugHistoryRef.add({
          'drugId': drug.id,
          'name': drug.name,
          'dosage': drug.dosage,
          'uses': drug.uses,
          'sideEffects': drug.sideEffects,
          'imageUrl': drug.imageUrl,
          'timestamp': FieldValue.serverTimestamp(),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Added to history'),
              backgroundColor: Color(0xFF00A86B),
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to save to history'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );
        }
        Navigator.pop(context); // Close the bottom sheet
      }
    }
  }
}
