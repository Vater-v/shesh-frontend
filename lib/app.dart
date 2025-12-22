import 'package:flutter/material.dart';
import 'features/welcome/presentation/welcome_screen.dart';

class SheshApp extends StatelessWidget {
  const SheshApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Название берем из вашего pubspec.yaml
      title: 'Shesh',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Настройки темы. Можно использовать Material 3
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      // Указываем WelcomeScreen как домашнюю страницу
      home: const WelcomeScreen(),
    );
  }
}
