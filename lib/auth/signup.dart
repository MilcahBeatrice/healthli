import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healthli/auth/login.dart';
import 'package:healthli/database/dao/dao_providers.dart';
import 'package:healthli/home/home_screen.dart';
import 'package:healthli/services/auth_service.dart';
import 'package:healthli/widgets/user_nav_gate.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _genderController = TextEditingController();
  final _ageController = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _signUp() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _error = "Passwords do not match";
        _loading = false;
      });
      return;
    }
    try {
      final auth = ref.read(authServiceProvider);
      final userDao = ref.read(userDaoProvider);
      await auth.signUp(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        name: _nameController.text.trim(),
        gender: _genderController.text.trim(),
        age: int.tryParse(_ageController.text.trim()),
        userDao: userDao,
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const UserNavGate()),
      );
    } on Exception catch (e) {
      setState(() {
        _error = e.toString();
        log(_error ?? 'Unknown error');
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 120),
              Center(child: Image.asset('assets/images/logo.png')),
              //   Text('Welcome back', style: textTheme.headlineSmall?.copyWith()),
              SizedBox(height: 30),

              Text('Full Name', style: textTheme.bodyLarge?.copyWith()),
              SizedBox(height: 10),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Text('Gender', style: textTheme.bodyLarge?.copyWith()),
              SizedBox(height: 10),
              TextFormField(
                controller: _genderController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Text('Age', style: textTheme.bodyLarge?.copyWith()),
              SizedBox(height: 10),
              TextFormField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 10),

              Text('Email', style: textTheme.bodyLarge?.copyWith()),
              SizedBox(height: 10),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Text('Password', style: textTheme.bodyLarge?.copyWith()),
              SizedBox(height: 10),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Text('Confirm Password', style: textTheme.bodyLarge?.copyWith()),
              SizedBox(height: 10),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 10),

              if (_error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(_error!, style: TextStyle(color: Colors.red)),
                ),
              InkWell(
                onTap: _loading ? null : _signUp,
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 30),
                  height: 56,
                  width: MediaQuery.sizeOf(context).width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Color(0xFF008B56),
                  ),
                  child: Center(
                    child:
                        _loading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text(
                              'Sign Up',
                              style: textTheme.bodyLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                  ),
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account?",
                    style: textTheme.bodyLarge?.copyWith(),
                  ),

                  SizedBox(width: 10),
                  SizedBox(width: 10),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) {
                            return LoginScreen();
                          },
                        ),
                      );
                    },
                    child: Text(
                      "Log In",
                      style: textTheme.bodyLarge?.copyWith(
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
