import 'package:healthli/services/sync_service.dart';
import 'package:sqflite/sqflite.dart';
import '../db_helper.dart';
import '../models/symptom_model.dart';

class SymptomDao {
  Future<int> insertSymptom(Symptom symptom) async {
    final db = await DatabaseHelper().database;
    final result = await db.insert(
      'symptoms',
      symptom.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await SyncService.syncAllPendingToFirestore(symptom.id);
    return result;
  }

  Future<List<Symptom>> getAllSymptoms() async {
    final db = await DatabaseHelper().database;
    final maps = await db.query('symptoms');
    return maps.map((e) => Symptom.fromMap(e)).toList();
  }

  Future<Symptom?> getSymptomById(String id) async {
    final db = await DatabaseHelper().database;
    final maps = await db.query('symptoms', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return Symptom.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateSymptom(Symptom symptom) async {
    final db = await DatabaseHelper().database;
    final result = await db.update(
      'symptoms',
      symptom.toMap(),
      where: 'id = ?',
      whereArgs: [symptom.id],
    );
    await SyncService.syncAllPendingToFirestore(symptom.id);
    return result;
  }

  Future<int> deleteSymptom(String id) async {
    final db = await DatabaseHelper().database;
    final result = await db.delete(
      'symptoms',
      where: 'id = ?',
      whereArgs: [id],
    );
    await SyncService.syncAllPendingToFirestore(id);
    return result;
  }

  Future<List<Symptom>> searchSymptoms(String keyword) async {
    final db = await DatabaseHelper().database;
    final maps = await db.query(
      'symptoms',
      where: 'name LIKE ?',
      whereArgs: ['%$keyword%'],
    );
    return maps.map((e) => Symptom.fromMap(e)).toList();
  }
}
