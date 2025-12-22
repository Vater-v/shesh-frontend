import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _onboardingKey = 'hasSeenOnboarding';
  static const String _accessTokenKey = 'accessToken';
  static const String _refreshTokenKey = 'refreshToken';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // --- Онбординг ---
  bool get hasSeenOnboarding => _prefs?.getBool(_onboardingKey) ?? false;

  Future<void> setOnboardingSeen() async {
    await _prefs?.setBool(_onboardingKey, true);
  }

  // --- Авторизация ---
  // Проверяем наличие токена доступа
  bool get isLoggedIn => _prefs?.getString(_accessTokenKey) != null;

  String? get accessToken => _prefs?.getString(_accessTokenKey);
  String? get refreshToken => _prefs?.getString(_refreshTokenKey);

  Future<void> saveTokens(String access, String refresh) async {
    await _prefs?.setString(_accessTokenKey, access);
    await _prefs?.setString(_refreshTokenKey, refresh);
  }

  Future<void> clearSession() async {
    await _prefs?.remove(_accessTokenKey);
    await _prefs?.remove(_refreshTokenKey);
  }
}
