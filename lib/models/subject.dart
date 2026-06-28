import 'package:flutter/material.dart';

/// Simple value object for the hardcoded subjects shown on the dashboard
/// and passed through to the detail screen. `icon` drives the colored
/// avatar on the dashboard list and the header on the detail screen.
class Subject {
  final String name;
  final String description;
  final String schedule;
  final IconData icon;

  const Subject({
    required this.name,
    required this.description,
    required this.schedule,
    required this.icon,
  });
}
