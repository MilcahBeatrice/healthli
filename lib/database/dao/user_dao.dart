import 'package:healthli/services/sync_service.dart';
import 'package:sqflite/sqflite.dart';
import '../db_helper.dart';
import '../models/user_model.dart';

class UserDao {
  Future<int> insertUser(UserLocal user) async {
    final db = await DatabaseHelper().database;
    final result = await db.insert(
      'users_local',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await SyncService.syncAllPendingToFirestore(user.id);
    return result;
  }

  Future<UserLocal?> getUserById(String id) async {
    final db = await DatabaseHelper().database;
    final maps = await db.query(
      'users_local',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return UserLocal.fromMap(maps.first);
    }
    return null;
  }

  Future<List<UserLocal>> getAllUsers() async {
    final db = await DatabaseHelper().database;
    final maps = await db.query('users_local');
    return maps.map((e) => UserLocal.fromMap(e)).toList();
  }

  Future<int> updateUser(UserLocal user) async {
    final db = await DatabaseHelper().database;
    final result = await db.update(
      'users_local',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
    await SyncService.syncAllPendingToFirestore(user.id);
    return result;
  }

  Future<int> deleteUser(String id) async {
    final db = await DatabaseHelper().database;
    final result = await db.delete(
      'users_local',
      where: 'id = ?',
      whereArgs: [id],
    );
    await SyncService.syncAllPendingToFirestore(id);
    return result;
  }
}
