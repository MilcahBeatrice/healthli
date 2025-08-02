import 'dart:math';
import 'package:healthli/data/diagnoses.dart' as diagnoses_data;
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

class SymptomCheckerScreen extends StatefulWidget {
  const SymptomCheckerScreen({super.key});

  @override
  State<SymptomCheckerScreen> createState() => _SymptomCheckerScreenState();
}

class _SymptomCheckerScreenState extends State<SymptomCheckerScreen> {
  final TextEditingController _symptomController = TextEditingController();
  final FocusNode _symptomFocusNode = FocusNode();
  final _symptomTrie = <String, String>{};
  final Set<String> _selectedSymptoms = {};
  List<DiagnosisResult> _possibleDiagnoses = [];
  bool _isLoading = false;
  String? _inputError;
  late final SymptomAnalyzer _symptomAnalyzer;

  static const _primaryColor = Color(0xFF00A86B);
  static const _cardColor = Color(0xFFE9F9F1);

  @override
  void initState() {
    super.initState();
    // Initialize in background to avoid jank
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAnalyzer();
    });
  }

  Future<void> _initializeAnalyzer() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 300)); // Simulate loading

    // Generate massive mock database
    final database = _generateMassiveSymptomDatabase();
    _symptomAnalyzer = SymptomAnalyzer(database);

    // Build prefix tree for symptom suggestions
    for (final condition in database) {
      for (final symptom in condition.symptoms) {
        _symptomTrie[symptom.toLowerCase()] = symptom;
      }
    }

    setState(() => _isLoading = false);
  }

  void _validateAndSubmit() {
    final input = _symptomController.text.trim();

    if (input.isEmpty) {
      setState(() => _inputError = 'Please enter a symptom');
      return;
    }

    final normalized = input.toLowerCase();
    final matchedSymptom =
        _symptomTrie[normalized] ??
        _symptomTrie.values.firstWhereOrNull(
          (s) => s.toLowerCase().contains(normalized),
        );

    if (matchedSymptom == null) {
      setState(() => _inputError = 'Symptom not recognized');
      return;
    }

    _addSymptom(matchedSymptom);
  }

  void _addSymptom(String symptom) {
    final normalized = symptom.toLowerCase();

    if (_selectedSymptoms.add(normalized)) {
      _symptomController.clear();
      _inputError = null;
      _symptomFocusNode.unfocus();
      _analyzeSymptoms();
    }
  }

  Future<void> _analyzeSymptoms() async {
    if (_selectedSymptoms.isEmpty) {
      setState(() => _possibleDiagnoses = []);
      return;
    }

    setState(() => _isLoading = true);

    // Run analysis in chunks to avoid UI jank
    final results = await Future(
      () => _symptomAnalyzer.analyze(_selectedSymptoms.toList()),
    );

    setState(() {
      _possibleDiagnoses = results;
      _isLoading = false;
    });
  }

  void _removeSymptom(String symptom) {
    setState(() {
      _selectedSymptoms.remove(symptom);
      _analyzeSymptoms();
    });
  }

  void _clearAll() {
    setState(() {
      _selectedSymptoms.clear();
      _possibleDiagnoses = [];
      _symptomController.clear();
      _inputError = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        surfaceTintColor: Colors.white,
        title: const Text(
          'Symptom Checker',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        actions: [
          if (_selectedSymptoms.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_all, color: Colors.black),
              onPressed: _clearAll,
              tooltip: 'Clear all',
            ),
        ],
      ),
      body:
          _isLoading && _possibleDiagnoses.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  // Input Section
                  _buildInputSection(),

                  // Suggestions
                  _buildSuggestions(),

                  // Selected Symptoms
                  if (_selectedSymptoms.isNotEmpty) _buildSelectedSymptoms(),

                  // Results
                  Expanded(child: _buildResultsSection()),
                ],
              ),
    );
  }

  Widget _buildInputSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _symptomController,
            focusNode: _symptomFocusNode,
            decoration: InputDecoration(
              hintText: 'Enter symptom (e.g. headache)',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.add_circle),
                onPressed: _validateAndSubmit,
              ),
              errorText: _inputError,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onSubmitted: (_) => _validateAndSubmit(),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions() {
    final suggestions = _symptomTrie.values.take(20).toList();

    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          final symptom = suggestions[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(symptom),
              selected: _selectedSymptoms.contains(symptom.toLowerCase()),
              onSelected: (selected) => _addSymptom(symptom),
              selectedColor: _primaryColor.withOpacity(0.2),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSelectedSymptoms() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children:
            _selectedSymptoms.map((symptom) {
              final display = _symptomTrie[symptom] ?? symptom;
              return Chip(
                label: Text(display),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () => _removeSymptom(symptom),
                backgroundColor: _primaryColor.withOpacity(0.1),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildResultsSection() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_selectedSymptoms.isEmpty) {
      return const Center(
        child: Text('Add symptoms to check possible conditions'),
      );
    }

    // Only show results with real disease names (not 'Condition 00021' style)
    final realResults =
        _possibleDiagnoses
            .where((r) => !r.condition.name.startsWith('Condition '))
            .toList();

    if (realResults.isEmpty) {
      return const Center(child: Text('No matching conditions found'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: realResults.length,
      itemBuilder: (context, index) {
        return _buildDiagnosisCard(realResults[index]);
      },
    );
  }

  Widget _buildDiagnosisCard(DiagnosisResult result) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: _cardColor,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _primaryColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.medical_services,
                    color: _primaryColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    result.condition.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _primaryColor,
                    ),
                  ),
                ),
                Chip(
                  label: Text(
                    '${(result.confidence * 100).toStringAsFixed(1)}%',
                    style: const TextStyle(
                      color: _primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Matching symptoms: ${result.matchedSymptoms.join(', ')}',
              style: TextStyle(
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
            if (result.condition.description != null) ...[
              const SizedBox(height: 8),
              Text(
                result.condition.description!,
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.black87,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Generate massive mock database (10,000 conditions)
  List<HealthCondition> _generateMassiveSymptomDatabase() {
    // Use the large real diagnoses list for the first N conditions
    final realDiagnoses = diagnoses_data.diagnoses;

    const symptomPool = [
      'fever',
      'headache',
      'cough',
      'nausea',
      'fatigue',
      'rash',
      'chest pain',
      'sore throat',
      'runny nose',
      'dizziness',
      'abdominal pain',
      'joint pain',
      'muscle weakness',
      'shortness of breath',
      'vomiting',
      'diarrhea',
      'constipation',
      'blurred vision',
      'heart palpitations',
      'weight loss',
      'weight gain',
      'loss of appetite',
      'excessive thirst',
      'frequent urination',
      'back pain',
      'neck stiffness',
      'swollen lymph nodes',
      'chills',
      'sweating',
      'light sensitivity',
      'tinnitus',
      'nosebleeds',
      'bruising',
      'numbness',
      'tingling',
      'seizures',
      'tremors',
      'memory loss',
      'confusion',
      'anxiety',
      'depression',
      'insomnia',
      'drowsiness',
      'jaundice',
      'pale skin',
      'skin lesions',
      'hair loss',
      'brittle nails',
      'dry skin',
      'excessive hunger',
      'food cravings',
      'difficulty swallowing',
      'hoarseness',
      'wheezing',
      'snoring',
      'bad breath',
      'mouth ulcers',
      'toothache',
      'ear pain',
      'hearing loss',
      'eye pain',
      'red eyes',
      'double vision',
      'lightheadedness',
      'fainting',
      'leg swelling',
      'varicose veins',
      'cold hands',
      'hot flashes',
      'irregular periods',
      'vaginal discharge',
      'erectile dysfunction',
      'testicular pain',
      'breast lump',
      'nipple discharge',
      'blood in urine',
      'painful urination',
      'incontinence',
    ];

    final random = Random(42); // Fixed seed for consistency
    final conditions = <HealthCondition>[];

    // Add real diagnoses first (with random symptoms)
    for (final diagnosisName in realDiagnoses) {
      final symptomCount = 3 + random.nextInt(8);
      final symptoms = <String>{};
      while (symptoms.length < symptomCount) {
        symptoms.add(symptomPool[random.nextInt(symptomPool.length)]);
      }
      conditions.add(
        HealthCondition(
          name: diagnosisName,
          symptoms: symptoms.toList(),
          description: null,
        ),
      );
    }

    // Generate the rest as mock
    for (int i = realDiagnoses.length + 1; i <= 10000; i++) {
      final conditionName = 'Condition ${i.toString().padLeft(5, '0')}';
      final symptomCount = 3 + random.nextInt(8); // 3-10 symptoms
      final symptoms = <String>{};
      while (symptoms.length < symptomCount) {
        symptoms.add(symptomPool[random.nextInt(symptomPool.length)]);
      }
      conditions.add(
        HealthCondition(
          name: conditionName,
          symptoms: symptoms.toList(),
          description:
              i % 5 == 0 ? 'Common condition affecting multiple systems' : null,
        ),
      );
    }
    return conditions;
  }
}

class SymptomAnalyzer {
  final List<HealthCondition> _database;
  late final Map<String, double> _idfCache;
  late final Map<String, List<double>> _tfIdfVectors;
  late final List<String> _allSymptoms;

  SymptomAnalyzer(this._database) {
    _precomputeTfIdf();
  }

  void _precomputeTfIdf() {
    // Step 1: Extract all unique symptoms
    _allSymptoms = _database.expand((c) => c.symptoms).toSet().toList();

    // Step 2: Precompute IDF (Inverse Document Frequency)
    _idfCache = {};
    final totalConditions = _database.length;

    for (final symptom in _allSymptoms) {
      final conditionCount =
          _database.where((c) => c.symptoms.contains(symptom)).length;
      _idfCache[symptom] = log(totalConditions / (1 + conditionCount));
    }

    // Step 3: Precompute TF-IDF vectors for all conditions
    _tfIdfVectors = {};

    for (final condition in _database) {
      final vector = List<double>.filled(_allSymptoms.length, 0);

      // Compute TF (Term Frequency)
      for (final symptom in condition.symptoms) {
        final index = _allSymptoms.indexOf(symptom);
        if (index != -1) {
          vector[index] = 1.0 / condition.symptoms.length;
        }
      }

      // Apply IDF
      for (int i = 0; i < vector.length; i++) {
        vector[i] *= _idfCache[_allSymptoms[i]]!;
      }

      _tfIdfVectors[condition.name] = vector;
    }
  }

  List<DiagnosisResult> analyze(List<String> userSymptoms) {
    // Create user symptom vector
    final userVector = List<double>.filled(_allSymptoms.length, 0);
    final matchedSymptoms = <String>{};

    // Compute TF for user symptoms
    for (final symptom in userSymptoms) {
      final index = _allSymptoms.indexOf(symptom);
      if (index != -1) {
        userVector[index] = 1.0 / userSymptoms.length;
        matchedSymptoms.add(symptom);
      }
    }

    // Apply IDF to user vector
    for (int i = 0; i < userVector.length; i++) {
      userVector[i] *= _idfCache[_allSymptoms[i]]!;
    }

    // Compute cosine similarity with all conditions
    final results = <DiagnosisResult>[];

    for (final condition in _database) {
      final conditionVector = _tfIdfVectors[condition.name]!;
      final similarity = _cosineSimilarity(userVector, conditionVector);

      if (similarity > 0.1) {
        // Threshold to filter irrelevant results
        results.add(
          DiagnosisResult(
            condition: condition,
            confidence: similarity,
            matchedSymptoms:
                matchedSymptoms
                    .intersection(condition.symptoms.toSet())
                    .toList(),
          ),
        );
      }
    }

    // Sort by confidence and take top 10
    results.sort((a, b) => b.confidence.compareTo(a.confidence));
    return results.take(10).toList();
  }

  double _cosineSimilarity(List<double> vectorA, List<double> vectorB) {
    double dotProduct = 0;
    double normA = 0;
    double normB = 0;

    for (int i = 0; i < vectorA.length; i++) {
      dotProduct += vectorA[i] * vectorB[i];
      normA += vectorA[i] * vectorA[i];
      normB += vectorB[i] * vectorB[i];
    }

    if (normA == 0 || normB == 0) return 0;
    return dotProduct / (sqrt(normA) * sqrt(normB));
  }
}

class HealthCondition {
  final String name;
  final List<String> symptoms;
  final String? description;

  HealthCondition({
    required this.name,
    required this.symptoms,
    this.description,
  });
}

class DiagnosisResult {
  final HealthCondition condition;
  final double confidence;
  final List<String> matchedSymptoms;

  DiagnosisResult({
    required this.condition,
    required this.confidence,
    required this.matchedSymptoms,
  });
}
