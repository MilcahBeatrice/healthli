class Record {
  final String id;
  final String userId;
  final String title;
  final String value;
  final String unit;
  final String timestamp;
  final int isSynced;

  Record({
    required this.id,
    required this.userId,
    required this.title,
    required this.value,
    required this.unit,
    required this.timestamp,
    required this.isSynced,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'value': value,
      'unit': unit,
      'timestamp': timestamp,
      'is_synced': isSynced,
    };
  }

  factory Record.fromMap(Map<String, dynamic> map) {
    return Record(
      id: map['id'],
      userId: map['user_id'],
      title: map['title'],
      value: map['value'],
      unit: map['unit'],
      timestamp: map['timestamp'],
      isSynced: map['is_synced'],
    );
  }
}
