import 'package:flutter/material.dart';

import '../../controllers/auth_controller.dart';
import '../../models/subject.dart';
import '../../models/user.dart';
import '../detail/detail_screen.dart';
import '../login/login_screen.dart';

class DashboardScreen extends StatelessWidget {
  final User user;

  const DashboardScreen({super.key, required this.user});

  static const List<Subject> _subjects = [
    Subject(
      name: 'Mathematics',
      description: 'Algebra, geometry, and calculus fundamentals.',
      schedule: 'Mon & Wed, 9:00 AM - 10:30 AM',
      icon: Icons.functions,
    ),
    Subject(
      name: 'Computer Science',
      description: 'Programming basics, data structures, and algorithms.',
      schedule: 'Tue & Thu, 11:00 AM - 12:30 PM',
      icon: Icons.computer,
    ),
    Subject(
      name: 'English Literature',
      description: 'Reading comprehension, essay writing, and analysis.',
      schedule: 'Fri, 1:00 PM - 3:00 PM',
      icon: Icons.menu_book,
    ),
  ];

  Future<void> _logout(BuildContext context) async {
    await AuthController.instance.logout();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.6)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: colorScheme.primaryContainer,
                  child: Text(
                    user.initials,
                    style: TextStyle(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.fullName, style: textTheme.titleLarge),
                      const SizedBox(height: 2),
                      Text(
                        user.email,
                        style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Text('Subjects', style: textTheme.titleMedium),
          const SizedBox(height: 10),
          ..._subjects.map(
            (subject) => Card(
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  backgroundColor: colorScheme.secondaryContainer,
                  foregroundColor: colorScheme.onSecondaryContainer,
                  child: Icon(subject.icon),
                ),
                title: Text(subject.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(subject.schedule),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => DetailScreen(subject: subject)),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
