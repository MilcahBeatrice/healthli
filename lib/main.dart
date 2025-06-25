import 'package:flutter/material.dart';
import 'package:healthli/auth/login.dart';
import 'package:healthli/home/home_screen.dart';
import 'package:healthli/onboarding/onboarding_screen.dart';

void main() {
  runApp(const MyApp());
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
      home: OnboardingScreen(),
    );
  }
}
