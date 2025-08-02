import 'package:sqflite/sqflite.dart';
import '../models/emergency_contact_model.dart';
import '../db_helper.dart';

class EmergencyContactDao {
  Future<Database> get _db async => await DatabaseHelper().database;

  Future<List<EmergencyContact>> getAllContacts(String userId) async {
    final db = await _db;
    final maps = await db.query(
      'emergency_contacts',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return maps.map((e) => EmergencyContact.fromMap(e)).toList();
  }

  Future<void> insertContact(EmergencyContact contact) async {
    final db = await _db;
    await db.insert(
      'emergency_contacts',
      contact.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateContact(EmergencyContact contact) async {
    final db = await _db;
    await db.update(
      'emergency_contacts',
      contact.toMap(),
      where: 'id = ?',
      whereArgs: [contact.id],
    );
  }

  Future<void> deleteContact(String id) async {
    final db = await _db;
    await db.delete('emergency_contacts', where: 'id = ?', whereArgs: [id]);
  }
}
