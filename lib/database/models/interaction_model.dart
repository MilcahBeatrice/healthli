class Interaction {
  final int? id;
  final String userId;
  final String interactionType;
  final String value;
  final String timestamp;

  Interaction({
    this.id,
    required this.userId,
    required this.interactionType,
    required this.value,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'interaction_type': interactionType,
      'value': value,
      'timestamp': timestamp,
    };
  }

  factory Interaction.fromMap(Map<String, dynamic> map) {
    return Interaction(
      id: map['id'],
      userId: map['user_id'],
      interactionType: map['interaction_type'],
      value: map['value'],
      timestamp: map['timestamp'],
    );
  }
}
