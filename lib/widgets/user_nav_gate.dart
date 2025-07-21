import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:healthli/widgets/main_nav_page.dart';

/// Usage: After successful login/signup, call
///   Navigator.pushReplacement(context, MaterialPageRoute(
///     builder: (_) => UserNavGate(),
///   ));
/// This widget will auto-fetch the userId from FirebaseAuth and pass it to MainNavigationPage.
class UserNavGate extends StatelessWidget {
  const UserNavGate({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Should not happen, fallback to empty nav
      return const Scaffold(
        body: Center(child: Text('No user found. Please login.')),
      );
    }
    return MainNavigationPage(userId: user.uid);
  }
}
