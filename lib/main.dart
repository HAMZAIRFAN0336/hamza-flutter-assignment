import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/login/login_screen.dart';
import 'screens/course_list_screen.dart';
import 'theme/app_theme.dart';
import 'providers/course_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CourseProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Auth Demo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const LoginScreen(), // ← app still starts at login
      routes: {
        '/courses': (_) => const CourseListScreen(), // ← new CRUD route
      },
    );
  }
}
