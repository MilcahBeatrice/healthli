import 'package:healthli/services/sync_service.dart';
import 'package:sqflite/sqflite.dart';
import '../db_helper.dart';
import '../models/record_model.dart';

class RecordDao {
  Future<int> insertRecord(Record record) async {
    final db = await DatabaseHelper().database;
    final result = await db.insert(
      'records',
      record.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await SyncService.syncAllPendingToFirestore(record.id);
    return result;
  }

  Future<List<Record>> getAllRecords(String userId) async {
    final db = await DatabaseHelper().database;
    final maps = await db.query(
      'records',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return maps.map((e) => Record.fromMap(e)).toList();
  }

  Future<Record?> getRecordById(String id) async {
    final db = await DatabaseHelper().database;
    final maps = await db.query('records', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return Record.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateRecord(Record record) async {
    final db = await DatabaseHelper().database;
    final result = await db.update(
      'records',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
    await SyncService.syncAllPendingToFirestore(record.id);
    return result;
  }

  Future<int> deleteRecord(String id) async {
    final db = await DatabaseHelper().database;
    final result = await db.delete('records', where: 'id = ?', whereArgs: [id]);
    await SyncService.syncAllPendingToFirestore(id);
    return result;
  }
}
