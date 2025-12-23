import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shesh/core/services/api_service.dart';
import 'package:shesh/core/services/local_storage_service.dart';
import 'package:shesh/core/services/user_service.dart';
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
    final minDisplayTime = Future.delayed(const Duration(milliseconds: 1500));

    final storage = LocalStorageService();
    final apiService = ApiService();

    if (!storage.hasSeenOnboarding) {
      await minDisplayTime;
      if (!mounted) return;
      _navigate(const OnboardingScreen());
      return;
    }

    if (!storage.isLoggedIn) {
      await minDisplayTime;
      if (!mounted) return;
      _navigate(const WelcomeScreen());
      return;
    }

    try {
      final user = await apiService.getMe();
      UserService().setUser(user);

      await minDisplayTime;
      if (!mounted) return;

      _navigate(const HomeLayout());

    } on DioException catch (e) {
      await minDisplayTime;
      if (!mounted) return;

      if (e.response?.statusCode == 401) {
        await storage.clearSession();
        UserService().clear();
        _navigate(const WelcomeScreen());
      } else {
        _navigate(const HomeLayout());
      }
    } catch (e) {
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
              child: const Icon(Icons.dashboard_customize, size: 60, color: Color(0xFFD4AF37)),
            ),
            const SizedBox(height: 32),
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
