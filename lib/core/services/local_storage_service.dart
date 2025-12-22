import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _onboardingKey = 'hasSeenOnboarding';
  static const String _authKey = 'isLoggedIn';

  // Статическая переменная для хранения экземпляра SharedPreferences
  static SharedPreferences? _prefs;

  // Метод инициализации. Вызывается один раз в main.dart перед запуском UI.
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // --- Онбординг ---

  // Теперь это синхронное свойство (геттер), данные доступны мгновенно
  bool get hasSeenOnboarding => _prefs?.getBool(_onboardingKey) ?? false;

  Future<void> setOnboardingSeen() async {
    await _prefs?.setBool(_onboardingKey, true);
  }

  // --- Авторизация ---

  // Синхронная проверка статуса входа
  bool get isLoggedIn => _prefs?.getBool(_authKey) ?? false;

  Future<void> setLoggedIn(bool value) async {
    await _prefs?.setBool(_authKey, value);
  }
}
