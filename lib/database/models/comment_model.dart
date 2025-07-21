class Comment {
  final String id;
  final String postId;
  final String userId;
  final String text;
  final String createdAt;
  final int isSynced;

  Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.text,
    required this.createdAt,
    required this.isSynced,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'post_id': postId,
      'user_id': userId,
      'text': text,
      'created_at': createdAt,
      'is_synced': isSynced,
    };
  }

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'],
      postId: map['post_id'],
      userId: map['user_id'],
      text: map['text'],
      createdAt: map['created_at'],
      isSynced: map['is_synced'],
    );
  }
}
