import 'package:flutter/material.dart';
import '../../home/presentation/home_screen.dart';
import '../../../core/services/local_storage_service.dart';
// Импортируем новые экраны
import '../../auth/presentation/pages/login_screen.dart';
import '../../auth/presentation/pages/registration_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  // Метод для гостевого входа (оставляем быструю логику)
  Future<void> _loginAsGuest(BuildContext context) async {
    // Можно сохранить флаг isGuest = true, если нужно
    await LocalStorageService().setLoggedIn(true);

    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const HomeScreen(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Фон: Градиент (тот же, что и был)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0F2027),
                  Color(0xFF203A43),
                  Color(0xFF2C5364)
                ],
              ),
            ),
          ),

          // 2. Контент
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(flex: 2),
                  // Логотип (тот же)
                  Center(
                    child: Container(
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
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    "SHESH",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 8,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Искусство стратегии",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.7),
                      letterSpacing: 1.5,
                    ),
                  ),
                  const Spacer(flex: 3),

                  // ОБНОВЛЕННЫЕ КНОПКИ

                  // Кнопка ВОЙТИ -> Ведет на LoginScreen
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginScreen())
                      );
                    },
                    child: const Text("ВОЙТИ"),
                  ),
                  const SizedBox(height: 16),

                  // Кнопка СОЗДАТЬ АККАУНТ -> Ведет на RegistrationScreen
                  OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const RegistrationScreen())
                      );
                    },
                    child: const Text("СОЗДАТЬ АККАУНТ"),
                  ),
                  const SizedBox(height: 24),

                  // Кнопка ГОСТЬ -> Ведет сразу в игру
                  TextButton(
                    onPressed: () => _loginAsGuest(context),
                    child: Text(
                      "Играть как Гость",
                      style: TextStyle(color: Colors.white.withOpacity(0.5)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
