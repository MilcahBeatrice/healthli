class Comment {
  final String id;
  final String postId;
  final String userId;
  // final String username;
  final String text;
  final String createdAt;
  final bool isSynced;

  Comment({
    required this.id,
    required this.postId,
    required this.userId,
    //  required this.username,
    required this.text,
    required this.createdAt,
    required this.isSynced,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'post_id': postId,
    'user_id': userId,
    //   'username': username,
    'text': text,
    'created_at': createdAt,
    'is_synced': isSynced ? 1 : 0,
  };

  factory Comment.fromMap(Map<String, dynamic> map) => Comment(
    id: map['id'],
    postId: map['post_id'],
    userId: map['user_id'],
    //  username: map['username'],
    text: map['text'],
    createdAt: map['created_at'],
    isSynced: map['is_synced'] == 1 || map['is_synced'] == true,
  );

  // Firestore sync helpers
  factory Comment.fromFirestore(Map<String, dynamic> map) => Comment(
    id: map['id'],
    postId: map['post_id'],
    userId: map['user_id'],
    //  username: map['username'],
    text: map['text'],
    createdAt: map['created_at'],
    isSynced: true,
  );

  Map<String, dynamic> toFirestore() => {
    'id': id,
    'post_id': postId,
    'user_id': userId,
    // 'username': username,
    'text': text,
    'created_at': createdAt,
  };
}
