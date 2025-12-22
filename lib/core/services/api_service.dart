import 'package:dio/dio.dart';
import '../models/auth_models.dart';
import 'local_storage_service.dart';

class ApiService {
  // Для эмулятора Android: http://10.0.2.2:8000
  // Для iOS симулятора: http://127.0.0.1:8000
  // Для реального устройства: ваш локальный IP
  static const String baseUrl = 'https://sheshgame.ru';

  final Dio _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  ApiService() {
    // Интерцептор для добавления токена к каждому запросу
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = LocalStorageService().accessToken;
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        // Здесь можно обработать 401 Unauthorized и попробовать обновить токен
        return handler.next(e);
      },
    ));
  }

  // --- Методы Auth ---

  Future<Token> register(String login, String email, String password) async {
    try {
      final response = await _dio.post('/auth/register', data: {
        'login': login,
        'email': email,
        'password': password,
      });
      return Token.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Token> login(String credential, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'credential': credential,
        'password': password,
      });
      return Token.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Token> playAsGuest() async {
    try {
      final response = await _dio.post('/auth/guest');
      return Token.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> logout() async {
    try {
      final refreshToken = LocalStorageService().refreshToken;
      if (refreshToken != null) {
        await _dio.post('/auth/logout', data: {
          'refresh_token': refreshToken,
        });
      }
    } catch (e) {
      // Игнорируем ошибки при выходе, просто чистим сессию
    } finally {
      await LocalStorageService().clearSession();
    }
  }

  Future<UserRead> getMe() async {
    try {
      final response = await _dio.get('/auth/me');
      return UserRead.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Вспомогательный метод для обработки ошибок
  String _handleError(dynamic error) {
    if (error is DioException) {
      if (error.response != null) {
        final data = error.response?.data;
        // Пытаемся достать сообщение из валидации OpenAPI
        if (data is Map && data.containsKey('detail')) {
          if (data['detail'] is List) {
            return (data['detail'] as List).map((e) => e['msg']).join('\n');
          }
          return data['detail'].toString();
        }
      }
      return error.message ?? 'Ошибка сети';
    }
    return error.toString();
  }
}
