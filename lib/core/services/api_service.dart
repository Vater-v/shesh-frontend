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
    // Интерцептор для добавления токена и обработки ошибок
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = LocalStorageService().accessToken;
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        // Если получили 401 Unauthorized
        if (e.response?.statusCode == 401) {
          final RequestOptions options = e.requestOptions;

          // Если ошибка произошла уже при попытке обновить токен — значит, всё плохо, разлогиниваемся.
          // Или если это запрос логина/регистрации (там 401 означает неверный пароль).
          if (options.path.contains('/auth/refresh') ||
              options.path.contains('/auth/login')) {
            return handler.next(e);
          }

          try {
            // 1. Пытаемся получить новый токен, используя Refresh Token
            final newToken = await _refreshToken();

            // 2. Если успешно, обновляем заголовок в упавшем запросе
            options.headers['Authorization'] = 'Bearer ${newToken.accessToken}';

            // 3. Повторяем оригинальный запрос с новым токеном
            final cloneReq = await _dio.fetch(options);
            return handler.resolve(cloneReq);
          } catch (refreshError) {
            // Если обновить токен не удалось (например, Refresh Token протух),
            // пробрасываем ошибку дальше. UI должен будет перекинуть на экран входа.
            return handler.next(e);
          }
        }
        return handler.next(e);
      },
    ));
  }

  // --- Внутренний метод для обновления токена ---
  Future<Token> _refreshToken() async {
    final refreshToken = LocalStorageService().refreshToken;
    if (refreshToken == null) {
      throw DioException(
        requestOptions: RequestOptions(path: '/auth/refresh'),
        error: "No refresh token available",
      );
    }

    // Делаем "чистый" запрос через новый экземпляр Dio, чтобы избежать зацикливания интерцепторов
    final response = await Dio(BaseOptions(baseUrl: baseUrl)).post(
      '/auth/refresh',
      data: {'refresh_token': refreshToken},
    );

    final token = Token.fromJson(response.data);
    // Сохраняем новые токены локально
    await LocalStorageService().saveTokens(token.accessToken, token.refreshToken);
    return token;
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

  Future<UserRead> upgradeGuest(String login, String password, {String? email}) async {
    try {
      final data = {
        'login': login,
        'password': password,
        'email': email,
      };
      // Удаляем null значения, чтобы не слать лишнее
      data.removeWhere((key, value) => value == null);

      final response = await _dio.post('/auth/guest/upgrade', data: data);
      return UserRead.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Обновление профиля
  Future<UserRead> updateMe({String? login, String? email}) async {
    try {
      final data = <String, dynamic>{};
      if (login != null) data['login'] = login;
      if (email != null) data['email'] = email;

      final response = await _dio.patch('/auth/me', data: data);
      return UserRead.fromJson(response.data);
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
