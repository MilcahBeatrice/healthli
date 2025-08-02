import 'package:uuid/uuid.dart';

class NotificationItem {
  final String id;
  final String userId; // Who receives the notification
  final String type; // 'like' or 'comment'
  final String postId;
  final String? commentId;
  final String actorId; // Who performed the action
  final String actorName;
  final String message;
  final DateTime createdAt;
  final bool isRead;

  NotificationItem({
    String? id,
    required this.userId,
    required this.type,
    required this.postId,
    this.commentId,
    required this.actorId,
    required this.actorName,
    required this.message,
    DateTime? createdAt,
    this.isRead = false,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'type': type,
    'postId': postId,
    'commentId': commentId,
    'actorId': actorId,
    'actorName': actorName,
    'message': message,
    'createdAt': createdAt.toIso8601String(),
    'isRead': isRead ? 1 : 0,
  };

  factory NotificationItem.fromMap(Map<String, dynamic> map) =>
      NotificationItem(
        id: map['id'],
        userId: map['userId'],
        type: map['type'],
        postId: map['postId'],
        commentId: map['commentId'],
        actorId: map['actorId'],
        actorName: map['actorName'],
        message: map['message'],
        createdAt: DateTime.parse(map['createdAt']),
        isRead: map['isRead'] == 1,
      );
}
