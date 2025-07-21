import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class DoctorService {
  static const String collectionName = 'doctors';

  /// Pushes local doctors.json to Firestore (one-time setup or admin action)
  static Future<void> pushDoctorsJsonToFirestore() async {
    final String jsonString = await rootBundle.loadString(
      'assets/doctors.json',
    );
    final List<dynamic> doctors = json.decode(jsonString);
    final CollectionReference ref = FirebaseFirestore.instance.collection(
      collectionName,
    );
    for (final doctor in doctors) {
      await ref.add(doctor);
    }
  }

  /// Fetches all doctors from Firestore
  static Future<List<Map<String, dynamic>>> fetchDoctorsFromFirestore() async {
    final QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection(collectionName).get();
    return snapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }
}
