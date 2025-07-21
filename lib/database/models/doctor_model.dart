class CachedDoctor {
  final String id;
  final String name;
  final String specialization;
  final String location;
  final String contact;
  final String lastViewed;
  final String interactionType;

  CachedDoctor({
    required this.id,
    required this.name,
    required this.specialization,
    required this.location,
    required this.contact,
    required this.lastViewed,
    required this.interactionType,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'specialization': specialization,
      'location': location,
      'contact': contact,
      'last_viewed': lastViewed,
      'interaction_type': interactionType,
    };
  }

  factory CachedDoctor.fromMap(Map<String, dynamic> map) {
    return CachedDoctor(
      id: map['id'],
      name: map['name'],
      specialization: map['specialization'],
      location: map['location'],
      contact: map['contact'],
      lastViewed: map['last_viewed'],
      interactionType: map['interaction_type'],
    );
  }
}
