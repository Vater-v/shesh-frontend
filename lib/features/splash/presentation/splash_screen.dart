import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shesh/core/services/api_service.dart';
import 'package:shesh/core/services/local_storage_service.dart';
import 'package:shesh/core/services/user_service.dart'; // Не забудьте импортировать новый сервис
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
    // Запускаем таймер минимум на 1.5 секунды для красивого UI, чтобы экран не мелькнул.
    final minDisplayTime = Future.delayed(const Duration(milliseconds: 1500));

    final storage = LocalStorageService();
    final apiService = ApiService();

    // 1. Проверяем первый запуск (Onboarding)
    if (!storage.hasSeenOnboarding) {
      await minDisplayTime;
      if (!mounted) return;
      _navigate(const OnboardingScreen());
      return;
    }

    // 2. Если нет сохраненного токена — идем на экран приветствия/входа
    if (!storage.isLoggedIn) {
      await minDisplayTime;
      if (!mounted) return;
      _navigate(const WelcomeScreen());
      return;
    }

    // 3. Если токен есть, проверяем его валидность и загружаем профиль
    try {
      // Здесь магия ApiService: если AccessToken протух, он сам его обновит внутри getMe()
      final user = await apiService.getMe();

      // Сохраняем загруженного пользователя в память, чтобы не грузить снова в Lobby
      UserService().setUser(user);

      await minDisplayTime;
      if (!mounted) return;

      // Все отлично, идем в приложение
      _navigate(const HomeLayout());

    } on DioException catch (e) {
      await minDisplayTime;
      if (!mounted) return;

      // ВАЖНО: Разлогиниваем только если сервер явно отказал в доступе (401),
      // и даже Refresh Token не помог (интерцептор уже попытался бы его обновить).
      if (e.response?.statusCode == 401) {
        await storage.clearSession();
        UserService().clear();
        _navigate(const WelcomeScreen());
      } else {
        // Если ошибка сети (нет интернета, 500 и т.д.) - ПУСКАЕМ в приложение.
        // Пользователь увидит интерфейс, а данные догрузятся или покажут ошибку там.
        // Это лучше, чем выкидывать на логин из-за плохого интернета.
        _navigate(const HomeLayout());
      }
    } catch (e) {
      // Непредвиденная ошибка - на всякий случай на Welcome
      await storage.clearSession();
      _navigate(const WelcomeScreen());
    }
  }

  void _navigate(Widget screen) {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => screen,
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
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
            // Логотип
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
