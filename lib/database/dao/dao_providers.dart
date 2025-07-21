import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'user_dao.dart';
import 'symptom_dao.dart';
import 'medicine_dao.dart';
import 'record_dao.dart';

final userDaoProvider = Provider((ref) => UserDao());
final symptomDaoProvider = Provider((ref) => SymptomDao());
final medicineDaoProvider = Provider((ref) => MedicineDao());
final recordDaoProvider = Provider((ref) => RecordDao());
