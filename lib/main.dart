import 'package:flutter/material.dart';
// Импорты наших экранов.
// Обрати внимание: если файлы в папках, пути будут зависеть от структуры.
// Предполагаю, что ты создашь файлы как описано выше.
// Если ты пока всё держишь в одной папке, просто убери "features/.../".
import 'features/onboarding/presentation_screen.dart';
import 'features/auth/screens/auth_selection_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';

void main() {
  runApp(const SheshApp());
}

class SheshApp extends StatelessWidget {
  const SheshApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shesh',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      // Начальный маршрут - презентация
      initialRoute: '/',

      // Таблица маршрутов
      routes: {
        '/': (context) => const PresentationScreen(),
        '/auth_selection': (context) => const AuthSelectionScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
      },
    );
  }
}
