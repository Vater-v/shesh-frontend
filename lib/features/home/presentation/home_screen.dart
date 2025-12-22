import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../features/onboarding/presentation/pages/onboarding_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  /// Метод для сброса флага 'hasSeenOnboarding'.
  /// Полезно для отладки, чтобы снова увидеть экран презентации.
  Future<void> _resetOnboarding(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    // Удаляем запись, чтобы при следующем запуске приложение думало, что это первый вход
    await prefs.remove('hasSeenOnboarding');

    if (!context.mounted) return;

    // Показываем уведомление
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Онбординг сброшен! Перезапустите приложение или нажмите кнопку обновления."),
        duration: Duration(seconds: 2),
      ),
    );

    // Опционально: сразу перекидываем пользователя обратно на онбординг
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const OnboardingScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Главная"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Сбросить онбординг",
            onPressed: () => _resetOnboarding(context),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 100, color: Colors.green),
            const SizedBox(height: 20),
            const Text(
              "Вы на главном экране!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                "Здесь будет основная функциональность вашего приложения 'Shesh'.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
