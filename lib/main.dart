import 'package:flutter/material.dart';
import 'features/onboarding/presentation/pages/onboarding_screen.dart';
import 'features/home/presentation/home_screen.dart';
import 'core/services/local_storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shesh',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      // Используем FutureBuilder для проверки флага перед загрузкой UI
      home: FutureBuilder<bool>(
        future: LocalStorageService().hasSeenOnboarding(),
        builder: (context, snapshot) {
          // Пока грузится - показываем крутилку (или Splash Screen)
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // Если видели презентацию -> Главная, иначе -> Презентация
          if (snapshot.data == true) {
            return const HomeScreen();
          } else {
            return const OnboardingScreen();
          }
        },
      ),
    );
  }
}
