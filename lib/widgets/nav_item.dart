// lib/widgets/nav_item.dart
import 'package:flutter/material.dart';

class NavItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  NavItem({required this.icon, required this.label, required this.onTap});
}
