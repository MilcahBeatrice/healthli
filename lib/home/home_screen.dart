import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:healthli/auth/login.dart';
import 'package:healthli/database/db_helper.dart';
import 'package:healthli/home/find_doctor_screen.dart';
import 'package:healthli/home/my_records_screen.dart';
// import 'package:healthli/home/pharmacy_screen.dart';
import 'package:healthli/home/symptom_screen.dart';
import 'package:healthli/services/sync_service.dart';
import 'package:healthli/widgets/bottom_navbar.dart';
import 'package:healthli/services/doctor_service.dart';
import 'package:healthli/services/news_service.dart';
import 'package:healthli/pharmacy/pharmacy_tab.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  final String userId;
  const HomeScreen({super.key, required this.userId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _newsArticles = [];
  bool _loadingNews = false;
  String? _newsError;
  bool _uploadingDoctors = false;
  String? _firstName;

  @override
  void initState() {
    super.initState();
    fetchLatestNews();
    log("HomeScreen initialized for user: ${widget.userId}");
    fetchAndSetFirstName();
    // Trigger Firestore sync on navigation to HomeScreen
    SyncService.syncAllPendingToFirestore(widget.userId);
  }

  void fetchLatestNews() async {
    setState(() {
      _loadingNews = true;
      _newsError = null;
    });
    try {
      final news = await NewsService.fetchLatestHealthNews();
      setState(() {
        _newsArticles = news ?? [];
        _loadingNews = false;
      });
    } catch (e) {
      setState(() {
        _newsError = e.toString();
        _loadingNews = false;
      });
    }
  }

  Future<Map<String, dynamic>?> getUserById(String userId) async {
    final db = await DatabaseHelper().database;
    try {
      final List<Map<String, dynamic>> results = await db.query(
        'users_local',
        where: 'id = ?',
        whereArgs: [userId],
      );
      if (results.isNotEmpty) {
        return results.first;
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching user: $e');
      return null;
    }
  }

  void _pushDoctorsToFirestore() async {
    setState(() {
      _uploadingDoctors = true;
    });
    try {
      await DoctorService.pushDoctorsJsonToFirestore();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Doctors uploaded to Firestore!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    } finally {
      setState(() {
        _uploadingDoctors = false;
      });
    }
  }

  void fetchAndSetFirstName() async {
    final user = await getUserById(widget.userId);
    if (user != null && user['name'] != null) {
      // Extract first name (assume space-separated)
      final name = user['name'] as String;
      final firstName = name.split(' ').first;
      setState(() {
        _firstName = firstName;
      });
    } else {
      setState(() {
        _firstName = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    log(widget.userId);
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
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _firstName != null
                                      ? 'Hello $_firstName'
                                      : 'Hello',
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // ElevatedButton.icon(
                                //   icon: const Icon(
                                //     Icons.cloud_upload,
                                //     size: 18,
                                //   ),
                                //   label: Text(
                                //     _uploadingDoctors
                                //         ? 'Uploading...'
                                //         : 'Push Doctors to Cloud',
                                //   ),
                                //   style: ElevatedButton.styleFrom(
                                //     backgroundColor: const Color(0xFF008B56),
                                //     foregroundColor: Colors.white,
                                //     minimumSize: const Size(120, 36),
                                //   ),
                                //   onPressed:
                                //       _uploadingDoctors
                                //           ? null
                                //           : _pushDoctorsToFirestore,
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
                                        builder: (_) => const PharmacyTab(),
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
                              // _buildActionButton(
                              //   icon: Icons.description,
                              //   label: 'My\nRecords',
                              //   color: const Color(0xFF008B56),
                              //   onTap:
                              //       () => Navigator.push(
                              //         context,
                              //         MaterialPageRoute(
                              //           builder: (_) {
                              //             return MyRecordsScreen(
                              //               userId: widget.userId,
                              //             );
                              //           },
                              //         ),
                              //       ),
                              // ),
                            ],
                          ),

                          const SizedBox(height: 60),

                          // Daily Insights Section with Refresh Button
                          Padding(
                            padding: const EdgeInsets.only(bottom: 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Daily Insights',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.refresh,
                                    color: Colors.black,
                                  ),
                                  tooltip: 'Refresh News',
                                  onPressed:
                                      _loadingNews ? null : fetchLatestNews,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          const SizedBox(height: 10),
                          if (_loadingNews)
                            const Center(child: CircularProgressIndicator())
                          else if (_newsError != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                'Error: $_newsError',
                                style: const TextStyle(color: Colors.red),
                              ),
                            )
                          else if (_newsArticles.isEmpty)
                            const Text('No news found.')
                          else
                            Expanded(
                              child: ListView.builder(
                                padding: EdgeInsets.zero,
                                itemCount: _newsArticles.length,
                                itemBuilder: (context, index) {
                                  final article = _newsArticles[index];
                                  final title =
                                      article['title'] ??
                                      article['headline'] ??
                                      'No title';
                                  final description =
                                      article['description'] ??
                                      article['summary'] ??
                                      '';
                                  final url = article['url'] ?? article['link'];
                                  final imageUrl =
                                      article['image'] ??
                                      article['imageUrl'] ??
                                      article['urlToImage'];
                                  return Container(
                                    width: double.infinity,
                                    margin: const EdgeInsets.only(bottom: 16),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.1),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (imageUrl != null &&
                                            imageUrl.toString().isNotEmpty)
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child: Image.network(
                                              imageUrl,
                                              height: 160,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) => Container(
                                                    height: 160,
                                                    color: Colors.grey[200],
                                                    child: const Center(
                                                      child: Icon(
                                                        Icons
                                                            .image_not_supported,
                                                      ),
                                                    ),
                                                  ),
                                            ),
                                          ),
                                        const SizedBox(height: 8),
                                        Text(
                                          title,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          description,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey,
                                          ),
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 8),
                                        if (url != null &&
                                            url.toString().isNotEmpty)
                                          Align(
                                            alignment: Alignment.bottomRight,
                                            child: TextButton(
                                              onPressed: () async {
                                                final uri = Uri.parse(url);
                                                if (await canLaunchUrl(uri)) {
                                                  await launchUrl(uri);
                                                } else {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        'Could not open news link',
                                                      ),
                                                    ),
                                                  );
                                                }
                                              },
                                              child: const Text('Read More'),
                                            ),
                                          ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
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
      // bottomNavigationBar: HealthBottomNavBar(
      //   currentIndex: 0,
      //   onTap: (index) {
      //     // Handle navigation here
      //     log('Tapped on tab $index');
      //   },
      // ),
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
            width: 85,
            height: 85,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 35),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
