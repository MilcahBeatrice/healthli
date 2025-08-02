import 'package:sqflite/sqflite.dart';
import '../models/notification_model.dart';

class NotificationDao {
  final Database db;
  NotificationDao(this.db);

  Future<void> insertNotification(NotificationItem notification) async {
    await db.insert(
      'notifications',
      notification.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<NotificationItem>> getNotificationsForUser(String userId) async {
    final maps = await db.query(
      'notifications',
      where: 'userId = ?',
      orderBy: 'createdAt DESC',
      whereArgs: [userId],
    );
    return maps.map((m) => NotificationItem.fromMap(m)).toList();
  }

  Future<void> markAllAsRead(String userId) async {
    await db.update(
      'notifications',
      {'isRead': 1},
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }

  Future<void> deleteNotification(String id) async {
    await db.delete('notifications', where: 'id = ?', whereArgs: [id]);
  }
}
