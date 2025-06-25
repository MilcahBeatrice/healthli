import 'package:flutter/material.dart';
import 'package:healthli/auth/signup.dart';
import 'package:healthli/home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
              Text('Email', style: textTheme.bodyLarge?.copyWith()),
              SizedBox(height: 10),
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text('Password', style: textTheme.bodyLarge?.copyWith()),
              SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Forgot Password?',
                  style: textTheme.bodyLarge?.copyWith(
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),

              InkWell(
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => HomeScreen()),
                    ),
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 30),
                  height: 56,
                  width: MediaQuery.sizeOf(context).width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Color(0xFF008B56),
                  ),
                  child: Center(
                    child: Text(
                      'Log In',
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
                    "Don't have an account?",
                    style: textTheme.bodyLarge?.copyWith(),
                  ),

                  SizedBox(width: 10),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) {
                            return SignUpScreen();
                          },
                        ),
                      );
                    },
                    child: Text(
                      "Sign Up",
                      style: textTheme.bodyLarge?.copyWith(
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
