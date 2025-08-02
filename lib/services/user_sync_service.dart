import 'package:cloud_firestore/cloud_firestore.dart';
import '../database/models/user_model.dart';
import '../database/dao/user_dao.dart';

class UserSyncService {
  /// Uploads user details to Firestore 'users' collection
  static Future<void> uploadUserToFirestore(UserLocal user) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.id)
        .set(user.toMap());
  }

  /// Fetches user details from Firestore and caches locally if not present or incomplete
  static Future<void> fetchAndCacheUserIfNeeded(
    String userId,
    UserDao userDao,
  ) async {
    final localUser = await userDao.getUserById(userId);
    if (localUser == null ||
        localUser.name.isEmpty ||
        localUser.email.isEmpty) {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get();
      if (doc.exists) {
        final user = UserLocal.fromMap(doc.data()!);
        await userDao.insertUser(user);
      }
    }
  }
}
