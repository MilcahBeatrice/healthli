import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healthli/auth/login.dart';
import 'package:healthli/home/home_screen.dart';
import 'package:healthli/onboarding/onboarding_screen.dart';
import 'package:healthli/profiile/profile_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyDioTMLSIOwEe4kLE2FcEghD3P89Wo9cto",
          appId: "1:609070628140:android:78f29b0a0cc5ea66318089",
          messagingSenderId: "609070628140",
          projectId: "healthli-dc360",
        ),
      )
      .then((value) {
        runApp(ProviderScope(child: const MyApp()));
        log("Firebase initialized");
      })
      .catchError((error) {
        log("Error initializing Firebase: $error");
      });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Healthli',
      theme: ThemeData(),
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}
