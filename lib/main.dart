import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'features/welcome/presentation/welcome_screen.dart';
import 'features/home/presentation/home_screen.dart';
import 'core/services/local_storage_service.dart';
import 'features/onboarding/presentation/pages/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Фиксируем ориентацию для лучшего UX на мобильных
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Логика выбора начального экрана
  Future<Widget> _getInitialScreen() async {
    final localStorage = LocalStorageService();
    final hasSeenOnboarding = await localStorage.hasSeenOnboarding();
    final isLoggedIn = await localStorage.isLoggedIn();

    if (!hasSeenOnboarding) {
      return const OnboardingScreen();
    } else if (isLoggedIn) {
      return const HomeScreen();
    } else {
      return const WelcomeScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shesh Backgammon',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark, // Принудительная темная тема для стиля "Премиум"

      // Темная тема (основная)
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212), // Глубокий черный фон
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFD4AF37), // Золотой (Gold)
          secondary: Color(0xFFC0C0C0), // Серебряный
          surface: Color(0xFF1E1E1E), // Чуть светлее для карточек
          onPrimary: Colors.black,
          onSurface: Colors.white,
        ),
        fontFamily: 'Roboto', // Можно заменить на более стильный шрифт позже
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

      home: FutureBuilder<Widget>(
        future: _getInitialScreen(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: Color(0xFF121212),
              body: Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37))),
            );
          }
          return snapshot.data ?? const WelcomeScreen();
        },
      ),
    );
  }
}
