class EmergencyContact {
  final String id;
  final String userId;
  final String name;
  final String phone;
  final String relationship;
  final int isSynced;

  EmergencyContact({
    required this.id,
    required this.userId,
    required this.name,
    required this.phone,
    required this.relationship,
    required this.isSynced,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'phone': phone,
      'relationship': relationship,
      'is_synced': isSynced,
    };
  }

  factory EmergencyContact.fromMap(Map<String, dynamic> map) {
    return EmergencyContact(
      id: map['id'],
      userId: map['user_id'],
      name: map['name'],
      phone: map['phone'],
      relationship: map['relationship'],
      isSynced: map['is_synced'],
    );
  }

  Map<String, dynamic> toFirestore() => {
    'id': id,
    'user_id': userId,
    'name': name,
    'phone': phone,
    'relationship': relationship,
    'is_synced': isSynced == 1,
  };

  factory EmergencyContact.fromFirestore(Map<String, dynamic> map) =>
      EmergencyContact(
        id: map['id'],
        userId: map['user_id'],
        name: map['name'],
        phone: map['phone'],
        relationship: map['relationship'],
        isSynced: map['is_synced'] == true || map['is_synced'] == 1 ? 1 : 0,
      );
}
