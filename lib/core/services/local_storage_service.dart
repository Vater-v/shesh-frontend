import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _onboardingKey = 'hasSeenOnboarding';
  static const String _authKey = 'isLoggedIn'; // Ключ для хранения статуса входа

  // --- Онбординг ---

  Future<void> setOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, true);
  }

  Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingKey) ?? false;
  }

  // --- Авторизация (Методы, которые вызывает main.dart) ---

  Future<void> setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_authKey, value);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    // Если ключа нет, считаем, что пользователь не вошел (false)
    return prefs.getBool(_authKey) ?? false;
  }
}
