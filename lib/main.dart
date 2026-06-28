import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'screens/login/login_screen.dart';
import 'screens/course_list_screen.dart';
import 'theme/app_theme.dart';
import 'providers/course_provider.dart';
import 'models/course_model.dart';
import 'services/course_local_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(CourseAdapter());
  await Hive.openBox<Course>(CourseLocalService.boxName);

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
      home: const LoginScreen(), // app still starts at login
      routes: {
        '/courses': (_) => const CourseListScreen(), // CRUD route
      },
    );
  }
}
