class Post {
  final String id;
  final String userId;
  final String content;
  final String tags;
  final int likes;
  final int isSynced;
  final String createdAt;

  Post({
    required this.id,
    required this.userId,
    required this.content,
    required this.tags,
    required this.likes,
    required this.isSynced,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'content': content,
      'tags': tags,
      'likes': likes,
      'is_synced': isSynced,
      'created_at': createdAt,
    };
  }

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      id: map['id'],
      userId: map['user_id'],
      content: map['content'],
      tags: map['tags'],
      likes: map['likes'],
      isSynced: map['is_synced'],
      createdAt: map['created_at'],
    );
  }
}
