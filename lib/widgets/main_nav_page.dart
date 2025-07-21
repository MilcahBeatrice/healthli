import 'package:flutter/material.dart';
import 'package:healthli/community/community_screen.dart';
import 'package:healthli/emergency/emergency_screen.dart';
import 'package:healthli/home/home_screen.dart';
import 'package:healthli/profiile/profile_screen.dart';
import 'package:healthli/widgets/bottom_navbar.dart';

class MainNavigationPage extends StatefulWidget {
  final String userId;
  const MainNavigationPage({super.key, required this.userId});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage>
    with TickerProviderStateMixin {
  int _currentIndex = 0;

  final PageStorageBucket _bucket = PageStorageBucket();

  late final List<Widget> _pages = [
    HomeScreen(key: const PageStorageKey('home'), userId: widget.userId),
    const CommunityScreen(key: PageStorageKey('community')),
    const EmergencyScreen(key: PageStorageKey('emergency')),
    ProfileScreen(key: const PageStorageKey('profile'), userId: widget.userId),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageStorage(
        bucket: _bucket,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeIn,
          switchOutCurve: Curves.easeOut,
          child: _pages[_currentIndex],
        ),
      ),
      bottomNavigationBar: HealthBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index != _currentIndex) {
            setState(() {
              _currentIndex = index;
            });
          }
        },
      ),
    );
  }
}
