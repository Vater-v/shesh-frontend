import 'package:flutter/material.dart';
import 'package:shesh/core/services/api_service.dart';
import 'package:shesh/core/services/local_storage_service.dart';
import 'package:shesh/features/home/presentation/pages/home_layout.dart';
import 'package:shesh/features/onboarding/presentation/pages/onboarding_screen.dart';
import 'package:shesh/features/welcome/presentation/welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Даем небольшую задержку, чтобы юзер успел увидеть логотип, а не просто моргание экрана
    await Future.delayed(const Duration(seconds: 1));

    final storage = LocalStorageService();
    final apiService = ApiService();

    // 1. Если это первый запуск — показываем онбординг
    if (!storage.hasSeenOnboarding) {
      _navigate(const OnboardingScreen());
      return;
    }

    // 2. Если нет сохраненного токена — идем на экран приветствия
    if (!storage.isLoggedIn) {
      _navigate(const WelcomeScreen());
      return;
    }

    // 3. Если токен есть, проверяем его валидность запросом к серверу
    try {
      await apiService.getMe();
      // Если запрос прошел успешно (200 OK) — пускаем в приложение
      _navigate(const HomeLayout());
    } catch (e) {
      // Если ошибка (например, 401 Unauthorized или сервер недоступен)
      // Сбрасываем сессию и отправляем логиниться заново
      await storage.clearSession();
      _navigate(const WelcomeScreen());
    }
  }

  void _navigate(Widget screen) {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Анимированный или статичный логотип
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
                border: Border.all(color: const Color(0xFFD4AF37), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD4AF37).withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 5,
                  )
                ],
              ),
              child: const Icon(Icons.casino, size: 60, color: Color(0xFFD4AF37)),
            ),
            const SizedBox(height: 32),
            // Индикатор загрузки
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Color(0xFFD4AF37),
                strokeWidth: 2.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
