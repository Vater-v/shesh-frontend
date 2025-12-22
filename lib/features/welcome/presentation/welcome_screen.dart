import 'package:flutter/material.dart';
import '../../home/presentation/home_screen.dart';
import '../../../core/services/local_storage_service.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  // Временная функция для эмуляции входа
  Future<void> _login(BuildContext context) async {
    // Сохраняем, что пользователь вошел
    await LocalStorageService().setLoggedIn(true);

    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.waving_hand, size: 100, color: Colors.blue),
              const SizedBox(height: 40),
              const Text(
                "Добро пожаловать в Shesh!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "Войдите или создайте аккаунт, чтобы продолжить.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => _login(context), // Тут будет навигация на экран логина
                child: const Text("Войти"),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => _login(context), // Тут будет навигация на регистрацию
                child: const Text("Зарегистрироваться"),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
