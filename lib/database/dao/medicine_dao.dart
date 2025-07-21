import 'package:healthli/services/sync_service.dart';
import 'package:sqflite/sqflite.dart';
import '../db_helper.dart';
import '../models/medicine_model.dart';

class MedicineDao {
  Future<int> insertMedicine(Medicine med) async {
    final db = await DatabaseHelper().database;
    final result = await db.insert(
      'medicines',
      med.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await SyncService.syncAllPendingToFirestore(med.id);
    return result;
  }

  Future<List<Medicine>> getAllMedicines() async {
    final db = await DatabaseHelper().database;
    final maps = await db.query('medicines');
    return maps.map((e) => Medicine.fromMap(e)).toList();
  }

  Future<Medicine?> getMedicineById(String id) async {
    final db = await DatabaseHelper().database;
    final maps = await db.query('medicines', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return Medicine.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateMedicine(Medicine med) async {
    final db = await DatabaseHelper().database;
    final result = await db.update(
      'medicines',
      med.toMap(),
      where: 'id = ?',
      whereArgs: [med.id],
    );
    await SyncService.syncAllPendingToFirestore(med.id);
    return result;
  }

  Future<int> deleteMedicine(String id) async {
    final db = await DatabaseHelper().database;
    final result = await db.delete(
      'medicines',
      where: 'id = ?',
      whereArgs: [id],
    );
    await SyncService.syncAllPendingToFirestore(id);
    return result;
  }

  Future<List<Medicine>> searchMedicines(String keyword) async {
    final db = await DatabaseHelper().database;
    final maps = await db.query(
      'medicines',
      where: 'name LIKE ?',
      whereArgs: ['%$keyword%'],
    );
    return maps.map((e) => Medicine.fromMap(e)).toList();
  }
}
