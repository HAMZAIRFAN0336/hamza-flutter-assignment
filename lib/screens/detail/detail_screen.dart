import 'package:flutter/material.dart';

import '../../models/subject.dart';

class DetailScreen extends StatelessWidget {
  final Subject subject;

  const DetailScreen({super.key, required this.subject});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(subject.name)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.primary,
                  colorScheme.primary.withValues(alpha: 0.65)
                ],
              ),
            ),
            child: Center(
              child: Icon(subject.icon, size: 64, color: Colors.white),
            ),
          ),
          const SizedBox(height: 24),
          Text(subject.name, style: textTheme.headlineSmall),
          const SizedBox(height: 10),
          Text(
            subject.description,
            style: textTheme.bodyMedium
                ?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.schedule,
                    size: 18, color: colorScheme.onSecondaryContainer),
                const SizedBox(width: 8),
                Text(
                  subject.schedule,
                  style: TextStyle(
                      color: colorScheme.onSecondaryContainer,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
