import 'dart:convert';

class Post {
  final String id;
  final String userId;
  final String content;
  final int likes;
  final List<String> comments; // List of comment IDs or comment texts
  final List<String> savedBy; // List of user IDs who saved this post
  final bool isSynced;
  final String createdAt;

  Post({
    required this.id,
    required this.userId,
    required this.content,
    required this.likes,
    required this.comments,
    required this.savedBy,
    required this.isSynced,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'user_id': userId,
    'content': content,
    'likes': likes,
    'comments': jsonEncode(comments),
    'saved_by': jsonEncode(savedBy),
    'is_synced': isSynced ? 1 : 0,
    'created_at': createdAt,
  };

  factory Post.fromMap(Map<String, dynamic> map) => Post(
    id: map['id'],
    userId: map['user_id'],
    content: map['content'],
    likes: map['likes'],
    comments:
        map['comments'] is String
            ? List<String>.from(jsonDecode(map['comments'] ?? '[]'))
            : (map['comments'] is List
                ? List<String>.from(map['comments'])
                : <String>[]),
    savedBy:
        map['saved_by'] is String
            ? List<String>.from(jsonDecode(map['saved_by'] ?? '[]'))
            : (map['saved_by'] is List
                ? List<String>.from(map['saved_by'])
                : <String>[]),
    isSynced: map['is_synced'] == 1 || map['is_synced'] == true,
    createdAt: map['created_at'],
  );

  Map<String, dynamic> toFirestore() => {
    'id': id,
    'user_id': userId,
    'content': content,
    'likes': likes,
    'saved_by': savedBy,
    'is_synced': isSynced,
    'created_at': createdAt,
    // comments are not included, handled as subcollection
  };

  factory Post.fromFirestore(Map<String, dynamic> map) => Post(
    id: map['id'],
    userId: map['user_id'],
    content: map['content'],
    likes: map['likes'],
    comments: const [], // comments handled as subcollection
    savedBy:
        map['saved_by'] is List
            ? List<String>.from(map['saved_by'])
            : <String>[],
    isSynced: map['is_synced'] == true || map['is_synced'] == 1,
    createdAt: map['created_at'],
  );
}
