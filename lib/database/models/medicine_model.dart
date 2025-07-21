class Medicine {
  final String id;
  final String name;
  final String uses;
  final String sideEffects;
  final String dosage;

  Medicine({
    required this.id,
    required this.name,
    required this.uses,
    required this.sideEffects,
    required this.dosage,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'uses': uses,
      'side_effects': sideEffects,
      'dosage': dosage,
    };
  }

  factory Medicine.fromMap(Map<String, dynamic> map) {
    return Medicine(
      id: map['id'],
      name: map['name'],
      uses: map['uses'],
      sideEffects: map['side_effects'],
      dosage: map['dosage'],
    );
  }
}
