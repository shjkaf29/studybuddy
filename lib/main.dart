import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/login_page.dart';
import 'services/task_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        Provider<TaskService>(
          create: (_) => TaskService(),
        ),
      ],
      child: const StudyBuddyApp(),
    ),
  );
}

class StudyBuddyApp extends StatelessWidget {
  const StudyBuddyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StudyBuddy',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Poppins',
      ),
      home: const LoginPage(),
    );
  }
}