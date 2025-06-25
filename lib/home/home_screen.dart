import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:healthli/home/find_doctor_screen.dart';
import 'package:healthli/home/my_records_screen.dart';
import 'package:healthli/home/pharmacy_screen.dart';
import 'package:healthli/home/symptom_screen.dart';
import 'package:healthli/widgets/bottom_navbar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [Image.asset('assets/images/logo.png', scale: 1.5)],
            ),
            Expanded(
              child: Column(
                children: [
                  // Header Section
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            // Profile Avatar
                            Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                color: Colors.grey[500],
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 50,
                              ),
                            ),
                            const SizedBox(width: 15),
                            // Greeting Text
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hello Beatrice',
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                                // Text(
                                //   'Beatrice',
                                //   style: TextStyle(
                                //     fontSize: 26,
                                //     fontWeight: FontWeight.w600,
                                //     color: Colors.black,
                                //   ),
                                // ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Main Content
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          //   const SizedBox(height: 40),

                          // Action Buttons Grid
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildActionButton(
                                icon: Icons.healing_rounded,

                                label: 'Pharmacy',
                                color: const Color(0xFF008B56),
                                onTap:
                                    () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) {
                                          return PharmacyScreen();
                                        },
                                      ),
                                    ),
                              ),
                              _buildActionButton(
                                icon: Icons.medical_services,

                                label: 'Symptom\nChecker',
                                color: const Color(0xFF008B56),
                                onTap:
                                    () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) {
                                          return SymptomCheckerScreen();
                                        },
                                      ),
                                    ),
                              ),
                              _buildActionButton(
                                icon: Icons.person_rounded,
                                label: 'Find\nDoctor',
                                color: const Color(0xFF008B56),
                                onTap:
                                    () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) {
                                          return FindDoctorScreen();
                                        },
                                      ),
                                    ),
                              ),
                              _buildActionButton(
                                icon: Icons.description,
                                label: 'My\nRecords',
                                color: const Color(0xFF008B56),
                                onTap:
                                    () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) {
                                          return MyRecordsScreen();
                                        },
                                      ),
                                    ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 60),

                          // Daily Insights Section
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'My Daily insights',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Empty space for insights content
                          Expanded(child: Container()),
                        ],
                      ),
                    ),
                  ),

                  // // Bottom Navigation
                  // Container(
                  //   height: 80,
                  //   decoration: BoxDecoration(
                  //     color: Colors.white,
                  //     boxShadow: [
                  //       BoxShadow(
                  //         color: Colors.grey.withOpacity(0.1),
                  //         spreadRadius: 1,
                  //         blurRadius: 10,
                  //         offset: const Offset(0, -5),
                  //       ),
                  //     ],
                  //   ),
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  //     children: [
                  //       _buildBottomNavItem(
                  //         icon: Icons.home,
                  //         label: 'Home',
                  //         isActive: true,
                  //       ),
                  //       _buildBottomNavItem(
                  //         icon: Icons.people,
                  //         label: 'Community',
                  //         isActive: false,
                  //       ),
                  //       _buildBottomNavItem(
                  //         icon: Icons.local_hospital,
                  //         label: 'Emergency',
                  //         isActive: false,
                  //       ),
                  //       _buildBottomNavItem(
                  //         icon: Icons.person,
                  //         label: 'Profile',
                  //         isActive: false,
                  //       ),
                  //     ],
                  //   ),
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: HealthBottomNavBar(
        currentIndex: 0,
        onTap: (index) {
          // Handle navigation here
          log('Tapped on tab $index');
        },
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 35),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
