import 'package:dio/dio.dart';
import '../models/auth_models.dart';
import 'local_storage_service.dart';

class ApiService {
  // Для эмулятора Android: http://10.0.2.2:8000
  // Для iOS симулятора: http://127.0.0.1:8000
  // Для реального устройства: ваш локальный IP или домен
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
    // Интерцептор для добавления токена и обработки ошибок (401)
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = LocalStorageService().accessToken;
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401) {
          final RequestOptions options = e.requestOptions;

          if (options.path.contains('/auth/refresh') ||
              options.path.contains('/auth/login')) {
            return handler.next(e);
          }

          try {
            final newToken = await _refreshToken();
            options.headers['Authorization'] = 'Bearer ${newToken.accessToken}';
            final cloneReq = await _dio.fetch(options);
            return handler.resolve(cloneReq);
          } catch (refreshError) {
            return handler.next(e);
          }
        }
        return handler.next(e);
      },
    ));
  }

  Future<Token> _refreshToken() async {
    final refreshToken = LocalStorageService().refreshToken;
    if (refreshToken == null) {
      throw DioException(
        requestOptions: RequestOptions(path: '/auth/refresh'),
        error: "No refresh token available",
      );
    }

    final response = await Dio(BaseOptions(baseUrl: baseUrl)).post(
      '/auth/refresh',
      data: {'refresh_token': refreshToken},
    );

    final token = Token.fromJson(response.data);
    await LocalStorageService().saveTokens(token.accessToken, token.refreshToken);
    return token;
  }

  // --- Auth Methods ---

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
      data.removeWhere((key, value) => value == null);

      final response = await _dio.post('/auth/guest/upgrade', data: data);
      return UserRead.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

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
      // Ignore logout errors
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
