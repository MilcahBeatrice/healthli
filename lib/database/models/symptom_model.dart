class Symptom {
  final String id;
  final String name;
  final String description;

  Symptom({required this.id, required this.name, required this.description});

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'description': description};
  }

  factory Symptom.fromMap(Map<String, dynamic> map) {
    return Symptom(
      id: map['id'],
      name: map['name'],
      description: map['description'],
    );
  }
}
