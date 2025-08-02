import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../database/dao/user_dao.dart';
import '../database/models/user_model.dart';
import 'user_sync_service.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.watch(firebaseAuthProvider));
});

class AuthService {
  final FirebaseAuth _auth;
  AuthService(this._auth);
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  // Google Sign-In
  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate();
    if (googleUser == null) {
      throw Exception('Google sign in aborted');
    }
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );
    return await _auth.signInWithCredential(credential);
  }

  Future<UserCredential> signIn(
    String email,
    String password,
    UserDao userDao,
  ) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = cred.user;
    if (user != null) {
      await UserSyncService.fetchAndCacheUserIfNeeded(user.uid, userDao);
    }
    return cred;
  }

  Future<UserCredential> signUp(
    String email,
    String password, {
    String? name,
    int? age,
    String? gender,
    UserDao? userDao,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = cred.user;
    if (user != null) {
      final userLocal = UserLocal(
        id: user.uid,
        name: name ?? '',
        email: user.email ?? '',
        age: age,
        gender: gender ?? '',
        isSynced: 1,
      );
      await UserSyncService.uploadUserToFirestore(userLocal);
      if (userDao != null) {
        await userDao.insertUser(userLocal);
      }
    }
    return cred;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
