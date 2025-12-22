import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'features/welcome/presentation/welcome_screen.dart';
import 'features/home/presentation/home_screen.dart';
import 'core/services/local_storage_service.dart';
import 'features/onboarding/presentation/pages/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Инициализируем локальное хранилище до запуска приложения
  // Это позволяет получать данные (например, вошел ли юзер) мгновенно и синхронно.
  await LocalStorageService.init();

  // 2. Фиксируем портретную ориентацию
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
    // Получаем экземпляр сервиса (он уже инициализирован)
    final localStorage = LocalStorageService();

    // 3. Определяем стартовый экран синхронно (без FutureBuilder)
    Widget initialScreen;
    if (!localStorage.hasSeenOnboarding) {
      initialScreen = const OnboardingScreen();
    } else if (localStorage.isLoggedIn) {
      initialScreen = const HomeScreen();
    } else {
      initialScreen = const WelcomeScreen();
    }

    return MaterialApp(
      title: 'Shesh Backgammon',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,

      // Темная тема
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

      // Передаем вычисленный экран сразу
      home: initialScreen,
    );
  }
}
