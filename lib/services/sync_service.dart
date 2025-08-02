import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;
import '../database/db_helper.dart';
import '../database/models/user_model.dart';
import '../database/models/symptom_model.dart';
import '../database/models/medicine_model.dart';

/// Riverpod FutureProvider for drug search
final searchDrugProvider = FutureProvider.family<List<Medicine>, String>((
  ref,
  query,
) async {
  return await SyncService.searchDrug(query);
});

class SyncService {
  // 1. Sync user profile on login
  static Future<void> syncUserProfile({
    required String uid,
    required String email,
    required String name,
    String? profileImage,
    int? age,
    String? gender,
  }) async {
    final userDoc = FirebaseFirestore.instance.collection('users').doc(uid);
    final docSnap = await userDoc.get();
    final userMap = {
      'id': uid,
      'name': name,
      'email': email,
      'profile_image': profileImage,
      'age': age,
      'gender': gender,
      'is_synced': 1,
    };
    if (!docSnap.exists) {
      await userDoc.set(userMap);
    } else {
      await userDoc.update(userMap);
    }
    final db = await DatabaseHelper().database;
    await db.insert(
      'users_local',
      userMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // 2. Upload static doctors from JSON (one-time)
  static Future<void> uploadDoctorsFromJson() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('hasSyncedFakeDoctors') == true) return;
    final String jsonString = await rootBundle.loadString(
      'assets/doctors.json',
    );
    final List doctors = json.decode(jsonString);
    final batch = FirebaseFirestore.instance.batch();
    for (final doc in doctors) {
      final ref = FirebaseFirestore.instance
          .collection('doctors')
          .doc(doc['id']);
      batch.set(ref, doc);
    }
    await batch.commit();
    await prefs.setBool('hasSyncedFakeDoctors', true);
  }

  // 2b. Preload symptoms/medicines to SQLite (one-time)
  static Future<void> preloadSymptoms(List<Symptom> symptoms) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('hasPreloadedSymptoms') == true) return;
    final db = await DatabaseHelper().database;
    for (final s in symptoms) {
      await db.insert(
        'symptoms',
        s.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await prefs.setBool('hasPreloadedSymptoms', true);
  }

  static Future<void> preloadMedicines(List<Medicine> medicines) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('hasPreloadedMedicines') == true) return;
    final db = await DatabaseHelper().database;
    for (final m in medicines) {
      await db.insert(
        'medicines',
        m.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await prefs.setBool('hasPreloadedMedicines', true);
  }

  // 3. Symptom API search (Infermedica example)
  static Future<List<Symptom>> searchSymptom(String query) async {
    // Replace with your real API credentials and endpoint
    final response = await http.get(
      Uri.parse('https://api.infermedica.com/v3/symptoms?name=$query'),
      headers: {'App-Id': 'YOUR_APP_ID', 'App-Key': 'YOUR_APP_KEY'},
    );
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => Symptom.fromMap(e)).toList();
    }
    return [];
  }

  // 3b. Drug API search (RxNorm example)
  static Future<List<Medicine>> searchDrug(String query) async {
    final response = await http.get(
      Uri.parse('https://rxnav.nlm.nih.gov/REST/drugs.json?name=$query'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<Medicine> medicines = [];
      final drugGroup = data['drugGroup'];
      if (drugGroup != null && drugGroup['conceptGroup'] != null) {
        for (final group in drugGroup['conceptGroup']) {
          final conceptProperties = group['conceptProperties'];
          if (conceptProperties != null) {
            for (final prop in conceptProperties) {
              final rxcui = prop['rxcui']?.toString() ?? '';
              final name = prop['name']?.toString() ?? '';
              final synonym = prop['synonym']?.toString();
              final tty = prop['tty']?.toString();
              final language = prop['language']?.toString();
              final suppress = prop['suppress']?.toString();
              final umlscui = prop['umlscui']?.toString();
              final psn = prop['psn']?.toString();

              String dosage = '';
              String uses = '';
              String sideEffects = '';
              String? imageUrl;
              Map<String, String> codes = {};

              try {
                final detailsResp = await http.get(
                  Uri.parse(
                    'https://rxnav.nlm.nih.gov/REST/rxcui/$rxcui/allProperties.json',
                  ),
                );
                if (detailsResp.statusCode == 200) {
                  final detailsData = json.decode(detailsResp.body);
                  final properties =
                      detailsData['propConceptGroup']?['propConcept'] ?? [];
                  for (final propItem in properties) {
                    final category = propItem['propCategory']?.toString() ?? '';
                    final propName = propItem['propName']?.toString() ?? '';
                    final value = propItem['propValue']?.toString() ?? '';
                    if (category.toLowerCase().contains('dose') &&
                        dosage.isEmpty)
                      dosage = value;
                    if (category.toLowerCase().contains('use') && uses.isEmpty)
                      uses = value;
                    if (category.toLowerCase().contains('side effect') &&
                        sideEffects.isEmpty)
                      sideEffects = value;
                    if (category.toLowerCase().contains('image') &&
                        imageUrl == null)
                      imageUrl = value;
                    if (category == 'CODES' && propName.isNotEmpty) {
                      codes[propName] = value;
                    }
                  }
                }
              } catch (_) {}

              medicines.add(
                Medicine(
                  id: rxcui,
                  name: name,
                  synonym: synonym,
                  tty: tty,
                  language: language,
                  suppress: suppress,
                  umlscui: umlscui,
                  psn: psn,
                  codes: codes.isNotEmpty ? codes : null,
                  dosage: dosage,
                  uses: uses,
                  sideEffects: sideEffects,
                  imageUrl: imageUrl,
                ),
              );
            }
          }
        }
      }
      return medicines;
    }
    return [];
  }

  // 4. Save search history (symptom/medicine)
  static Future<void> saveSymptomSearchHistory(
    String userId,
    Symptom symptom,
  ) async {
    final db = await DatabaseHelper().database;
    final existing = await db.query(
      'symptom_history',
      where: 'id = ? AND user_id = ?',
      whereArgs: [symptom.id, userId],
    );
    if (existing.isEmpty) {
      await db.insert('symptom_history', {
        'id': symptom.id,
        'user_id': userId,
        'name': symptom.name,
        'description': symptom.description,
        'timestamp': DateTime.now().toIso8601String(),
        'is_synced': 0,
      });
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('symptom_history')
          .doc(symptom.id)
          .set(symptom.toMap());
      await syncAllPendingToFirestore(userId);
    }
  }

  static Future<void> saveMedicineSearchHistory(
    String userId,
    Medicine med,
  ) async {
    final db = await DatabaseHelper().database;
    final existing = await db.query(
      'medicine_history',
      where: 'id = ? AND user_id = ?',
      whereArgs: [med.id, userId],
    );
    if (existing.isEmpty) {
      await db.insert('medicine_history', {
        'id': med.id,
        'user_id': userId,
        'name': med.name,
        'uses': med.uses,
        'side_effects': med.sideEffects,
        'dosage': med.dosage,
        'timestamp': DateTime.now().toIso8601String(),
        'is_synced': 0,
      });
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('drug_history')
          .doc(med.id)
          .set(med.toMap());
      await syncAllPendingToFirestore(userId);
    }
  }

  // 5. Insert and sync health record
  static Future<void> insertRecord(
    Map<String, dynamic> record,
    String userId,
  ) async {
    final db = await DatabaseHelper().database;
    await db.insert('records', record);
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('records')
        .doc(record['id'])
        .set(record);
    await syncAllPendingToFirestore(userId);
  }

  // 6. General sync: push unsynced rows to Firestore
  static Future<void> syncAllPendingToFirestore(String userId) async {
    final db = await DatabaseHelper().database;
    // Posts
    final unsyncedPosts = await db.query('posts', where: 'is_synced = 0');
    for (final post in unsyncedPosts) {
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(post['id'] as String?)
          .set(post);
      await db.update(
        'posts',
        {'is_synced': 1},
        where: 'id = ?',
        whereArgs: [post['id']],
      );
    }
    // Records
    final unsyncedRecords = await db.query('records', where: 'is_synced = 0');
    for (final record in unsyncedRecords) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('records')
          .doc(record['id'] as String?)
          .set(record);
      await db.update(
        'records',
        {'is_synced': 1},
        where: 'id = ?',
        whereArgs: [record['id']],
      );
    }
    // Medicines
    final unsyncedMedicines = await db.query(
      'medicines',
      where: 'is_synced = 0',
    );
    for (final med in unsyncedMedicines) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('medicines')
          .doc(med['id'] as String?)
          .set(med);
      await db.update(
        'medicines',
        {'is_synced': 1},
        where: 'id = ?',
        whereArgs: [med['id']],
      );
    }
    // Symptoms
    final unsyncedSymptoms = await db.query('symptoms', where: 'is_synced = 0');
    for (final sym in unsyncedSymptoms) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('symptoms')
          .doc(sym['id'] as String?)
          .set(sym);
      await db.update(
        'symptoms',
        {'is_synced': 1},
        where: 'id = ?',
        whereArgs: [sym['id']],
      );
    }
    // Comments
    final unsyncedComments = await db.query('comments', where: 'is_synced = 0');
    for (final comment in unsyncedComments) {
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(comment['post_id'] as String?)
          .collection('comments')
          .doc(comment['id'] as String?)
          .set(comment);
      await db.update(
        'comments',
        {'is_synced': 1},
        where: 'id = ?',
        whereArgs: [comment['id']],
      );
    }
    // Interactions
    final unsyncedInteractions = await db.query(
      'interactions',
      where: 'is_synced = 0',
    );
    for (final interaction in unsyncedInteractions) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('interactions')
          .doc(interaction['id'].toString())
          .set(interaction);
      await db.update(
        'interactions',
        {'is_synced': 1},
        where: 'id = ?',
        whereArgs: [interaction['id']],
      );
    }
    // Emergency Contacts
    final unsyncedContacts = await db.query(
      'emergency_contacts',
      where: 'is_synced = 0',
    );
    for (final contact in unsyncedContacts) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('emergency_contacts')
          .doc(contact['id'] as String?)
          .set(contact);
      await db.update(
        'emergency_contacts',
        {'is_synced': 1},
        where: 'id = ?',
        whereArgs: [contact['id']],
      );
    }
  }
}
