import 'package:flutter/material.dart';
import 'openfda_service.dart';
import 'openfda_drug_model.dart';

class OpenFdaSearchScreen extends StatefulWidget {
  const OpenFdaSearchScreen({super.key});

  @override
  State<OpenFdaSearchScreen> createState() => _OpenFdaSearchScreenState();
}

class _OpenFdaSearchScreenState extends State<OpenFdaSearchScreen>
    with TickerProviderStateMixin {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  List<OpenFdaDrug> _results = [];
  bool _loading = false;
  String? _error;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Quick search suggestions
  final List<String> _quickSearches = [
    'Aspirin',
    'Ibuprofen',
    'Acetaminophen',
    'Metformin',
    'Lisinopril',
    'Omeprazole',
    'Simvastatin',
    'Amoxicillin',
    'Prednisone',
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
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _search([String? query]) async {
    final searchQuery = query ?? _controller.text.trim();
    if (searchQuery.isEmpty) return;

    setState(() {
      _loading = true;
      _error = null;
      _results = [];
    });

    _animationController.reset();

    try {
      final results = await OpenFdaService.searchDrugs(searchQuery);
      setState(() => _results = results);
      if (results.isNotEmpty) {
        _animationController.forward();
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  void _onQuickSearch(String drug) {
    _controller.text = drug;
    _search(drug);
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF00A86B);
    const primaryDark = Color(0xFF008B56);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Drug Search',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Colors.grey[200]),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: primaryColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Section
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Input
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _focusNode.hasFocus ? primaryColor : primaryDark,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Icon(Icons.medical_services, color: primaryDark),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          decoration: InputDecoration(
                            hintText: 'Enter drug name...',
                            hintStyle: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 16,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 15,
                            ),
                            suffixIcon:
                                _loading
                                    ? Container(
                                      padding: const EdgeInsets.all(14),
                                      child: const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                primaryDark,
                                              ),
                                        ),
                                      ),
                                    )
                                    : IconButton(
                                      icon: const Icon(
                                        Icons.search,
                                        color: primaryDark,
                                      ),
                                      onPressed:
                                          _loading ? null : () => _search(),
                                    ),
                          ),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                          onSubmitted: (_) => _search(),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Quick Search Tags
                if (_results.isEmpty && !_loading)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quick Search',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children:
                            _quickSearches.map((drug) {
                              return ActionChip(
                                label: Text(drug),
                                backgroundColor: const Color(0xFFE9F9F1),
                                labelStyle: const TextStyle(
                                  color: primaryDark,
                                  fontWeight: FontWeight.w500,
                                ),
                                onPressed: () => _onQuickSearch(drug),
                              );
                            }).toList(),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          // Results Section
          Expanded(
            child: Container(
              color: Colors.white,
              child: _buildResultsSection(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsSection() {
    if (_loading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Searching drugs...',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.red[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red[300]!),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: Colors.red[400], size: 48),
              const SizedBox(height: 12),
              Text(
                'Search Error',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.red[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                style: TextStyle(color: Colors.red[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (_results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Start by entering your drug name...',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _results.length,
        itemBuilder: (context, index) {
          final drug = _results[index];
          return TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 200 + (index * 50)),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: Opacity(opacity: value, child: child),
              );
            },
            child: _buildDrugCard(drug),
          );
        },
      ),
    );
  }

  Widget _buildDrugCard(OpenFdaDrug drug) {
    const primaryColor = Color(0xFF00A86B);
    const primaryDark = Color(0xFF008B56);

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor, width: 1.2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // Handle tap - could navigate to detail screen
            },
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: primaryDark,
                        size: 28,
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              drug.brandName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Generic: ${drug.genericName}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Drug Info
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow('Dosage Form', drug.dosageForm),
                      const SizedBox(height: 8),
                      _buildInfoRow('Route', drug.route),
                      const SizedBox(height: 8),
                      _buildInfoRow('Manufacturer', drug.labelerName),
                    ],
                  ),

                  // Active Ingredients
                  if (drug.activeIngredients.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Active Ingredients:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...drug.activeIngredients.map((ingredient) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          '• ${ingredient.name} - ${ingredient.strength}',
                          style: const TextStyle(
                            color: primaryDark,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
