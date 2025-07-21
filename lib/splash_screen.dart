import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healthli/auth/login.dart';
import 'package:healthli/database/dao/dao_providers.dart';
import 'package:healthli/widgets/main_nav_page.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    final user = FirebaseAuth.instance.currentUser;
    await Future.delayed(
      const Duration(milliseconds: 600),
    ); // For splash effect
    if (user != null) {
      // User is signed in, check if exists in local DB
      final userDao = ref.read(userDaoProvider);
      final localUser = await userDao.getUserById(user.uid);
      if (localUser != null) {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => MainNavigationPage(userId: user.uid),
          ),
        );
      } else {
        // User not in local DB, sign out and go to login
        await FirebaseAuth.instance.signOut();
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    } else {
      // Not signed in
      if (!mounted) return;
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(child: CircularProgressIndicator(color: Colors.teal)),
    );
  }
}
