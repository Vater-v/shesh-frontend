import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shesh/core/services/local_storage_service.dart';
import 'package:shesh/features/home/presentation/pages/home_layout.dart'; // Изменен импорт
import 'package:shesh/features/onboarding/presentation/pages/onboarding_screen.dart';
import 'package:shesh/features/welcome/presentation/welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorageService.init();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localStorage = LocalStorageService();

    Widget initialScreen;
    if (!localStorage.hasSeenOnboarding) {
      initialScreen = const OnboardingScreen();
    } else if (localStorage.isLoggedIn) {
      // Здесь теперь используем HomeLayout
      initialScreen = const HomeLayout();
    } else {
      initialScreen = const WelcomeScreen();
    }

    return MaterialApp(
      title: 'Shesh Backgammon',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFD4AF37),
          secondary: Color(0xFFC0C0C0),
          surface: Color(0xFF1E1E1E),
          onPrimary: Colors.black,
          onSurface: Colors.white,
        ),
        fontFamily: 'Roboto',
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD4AF37),
            foregroundColor: Colors.black,
            elevation: 4,
            textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFFD4AF37),
            side: const BorderSide(color: Color(0xFFD4AF37), width: 1.5),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
      home: initialScreen,
    );
  }
}
