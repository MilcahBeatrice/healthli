import 'package:flutter/material.dart';
import 'package:healthli/home/home_screen.dart';
import 'package:healthli/widgets/bottom_navbar.dart';

class SymptomCheckerScreen extends StatefulWidget {
  const SymptomCheckerScreen({super.key});

  @override
  State<SymptomCheckerScreen> createState() => _SymptomCheckerScreenState();
}

class _SymptomCheckerScreenState extends State<SymptomCheckerScreen> {
  final TextEditingController _symptomController = TextEditingController();
  List<String> _suggestedSymptoms = [
    'Fever',
    'Headache',
    'Cough',
    'Nausea',
    'Fatigue',
    'Rash',
    'Chest Pain',
    'Sore Throat',
    'Runny Nose',
    'Dizziness',
  ];

  List<String> _selectedSymptoms = [];
  List<String> _possibleIllnesses = [];

  @override
  void initState() {
    super.initState();
  }

  void _onSymptomSubmitted(String input) {
    String cleaned = input.trim().toLowerCase();
    if (cleaned.isNotEmpty && !_selectedSymptoms.contains(cleaned)) {
      setState(() {
        _selectedSymptoms.add(cleaned);
        _generateMockIllnesses();
        _symptomController.clear();
      });
    }
  }

  void _generateMockIllnesses() {
    // Mocked logic – in real life, use API/AI model
    Map<String, List<String>> mockDatabase = {
      'fever': ['Malaria', 'Flu', 'COVID-19'],
      'cough': ['Bronchitis', 'COVID-19', 'Tuberculosis'],
      'fatigue': ['Anemia', 'Depression', 'Diabetes'],
      'headache': ['Migraine', 'Tension Headache', 'Sinusitis'],
      'nausea': ['Food Poisoning', 'Pregnancy', 'Gastritis'],
    };

    Set<String> illnesses = {};

    for (var symptom in _selectedSymptoms) {
      if (mockDatabase.containsKey(symptom)) {
        illnesses.addAll(mockDatabase[symptom]!);
      }
    }

    setState(() {
      _possibleIllnesses = illnesses.toList();
    });
  }

  void _removeSymptom(String symptom) {
    setState(() {
      _selectedSymptoms.remove(symptom);
      _generateMockIllnesses();
    });
  }

  void _addSuggestedSymptom(String symptom) {
    _onSymptomSubmitted(symptom.toLowerCase());
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
          'Symptom Checker',
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
          // Input Field
          Padding(
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
                      Icons.medical_services,
                      color: Color(0xFF008B56),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _symptomController,
                      onSubmitted: _onSymptomSubmitted,
                      decoration: const InputDecoration(
                        hintText: 'Enter a symptom...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 15),
                      ),
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Suggested Symptoms
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children:
                  _suggestedSymptoms.map((symptom) {
                    return ActionChip(
                      label: Text(symptom),
                      backgroundColor: const Color(0xFFE9F9F1),
                      labelStyle: const TextStyle(color: Color(0xFF008B56)),
                      onPressed: () => _addSuggestedSymptom(symptom),
                    );
                  }).toList(),
            ),
          ),

          const SizedBox(height: 20),

          // Selected Symptoms
          if (_selectedSymptoms.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Symptoms:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children:
                        _selectedSymptoms.map((symptom) {
                          return Chip(
                            label: Text(symptom),
                            backgroundColor: Colors.green[100],
                            onDeleted: () => _removeSymptom(symptom),
                          );
                        }).toList(),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 20),

          // Results
          Expanded(
            child:
                _possibleIllnesses.isEmpty
                    ? Center(
                      child: Text(
                        _selectedSymptoms.isEmpty
                            ? 'Start by entering your symptoms...'
                            : 'Analyzing symptoms...',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                    : ListView.builder(
                      itemCount: _possibleIllnesses.length,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 15),
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF00A86B),
                              width: 1.2,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.info_outline,
                                color: Color(0xFF008B56),
                                size: 28,
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Text(
                                  _possibleIllnesses[index],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
