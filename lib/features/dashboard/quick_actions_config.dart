// lib/features/dashboard/quick_actions_config.dart
import 'package:flutter/material.dart';

class QuickActionConfig {
  final String id;
  final String title;
  final IconData icon;
  final Color color;
  final bool enabledByDefault;

  QuickActionConfig({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
    required this.enabledByDefault,
  });
}