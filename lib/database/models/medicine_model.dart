import 'package:healthli/database/models/drug_component_model.dart';

class Medicine {
  final String id; // rxcui
  final String name; // RxNorm concept name
  final String? synonym; // RxNorm synonym
  final String? tty; // Term type
  final String? language;
  final String? suppress;
  final String? umlscui;
  final String? psn; // Prescribable Name
  final String uses;
  final String sideEffects;
  final String dosage;
  final String? imageUrl;
  final Map<String, String>? codes; // e.g. ATC, DRUGBANK, etc.
  late final DrugDetails drugDetails;

  Medicine({
    required this.id,
    required this.name,
    this.synonym,
    this.tty,
    this.language,
    this.suppress,
    this.umlscui,
    this.psn,
    this.codes,
    required this.uses,
    required this.sideEffects,
    required this.dosage,
    required this.imageUrl,
  }) {
    drugDetails = DrugDetails.fromString(name);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'synonym': synonym,
      'tty': tty,
      'language': language,
      'suppress': suppress,
      'umlscui': umlscui,
      'psn': psn,
      'codes': codes,
      'uses': uses,
      'side_effects': sideEffects,
      'dosage': dosage,
      'image_url': imageUrl,
    };
  }

  factory Medicine.fromMap(Map<String, dynamic> map) {
    return Medicine(
      id: map['id'],
      name: map['name'],
      synonym: map['synonym'],
      tty: map['tty'],
      language: map['language'],
      suppress: map['suppress'],
      umlscui: map['umlscui'],
      psn: map['psn'],
      codes:
          map['codes'] != null ? Map<String, String>.from(map['codes']) : null,
      uses: map['uses'],
      sideEffects: map['side_effects'],
      dosage: map['dosage'],
      imageUrl: map['image_url'],
    );
  }
}
