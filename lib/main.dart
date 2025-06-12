import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/task_service.dart';
import 'services/study_session_service.dart';
import 'services/attendance_service.dart';  // Updated import
import 'screens/login_page.dart';
import 'screens/home_page.dart';
import 'package:flutter/services.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final userEmail = prefs.getString('userEmail');

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<TaskService>(
            create: (_) => TaskService(),
          ),
          ChangeNotifierProvider<StudySessionService>(
            create: (_) => StudySessionService(),
          ),
          ChangeNotifierProvider<AttendanceService>(
            create: (_) => AttendanceService(),
          ),
        ],
        child: StudyBuddyApp(
          isLoggedIn: isLoggedIn,
          userEmail: userEmail,
        ),
      ),
    );
  } catch (e) {
    debugPrint('Initialization error: $e');
  }
}

class StudyBuddyApp extends StatelessWidget {
  final bool isLoggedIn;
  final String? userEmail;

  const StudyBuddyApp({
    Key? key,
    this.isLoggedIn = false,
    this.userEmail,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StudyBuddy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Poppins',
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          contentPadding: const EdgeInsets.all(16),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
      ),
      home: isLoggedIn && userEmail != null
          ? HomePage(userEmail: userEmail!)
          : const LoginPage(),
    );
  }
}