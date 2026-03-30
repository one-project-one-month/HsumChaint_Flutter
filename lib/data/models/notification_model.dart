import 'package:flutter/widgets.dart';

class AppNotification {
  final String title;
  final String subtitle;
  final String time;
  final DateTime date;
  final IconData icon;

  AppNotification({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.date,
    required this.icon,
  });
}
