import 'package:flutter/material.dart';
import 'features/onboarding/presentation/pages/onboarding_screen.dart';
import 'features/home/presentation/home_screen.dart';
// Не забудьте импортировать WelcomeScreen
import 'features/welcome/presentation/welcome_screen.dart';
import 'core/services/local_storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Создадим метод для определения начального экрана
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
      title: 'Shesh',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: FutureBuilder<Widget>(
        future: _getInitialScreen(), // Используем нашу новую логику
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          // Если возникла ошибка или нет данных, по умолчанию можно показать WelcomeScreen
          return snapshot.data ?? const WelcomeScreen();
        },
      ),
    );
  }
}
