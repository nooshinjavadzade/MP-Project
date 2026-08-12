import 'package:dio/dio.dart';

import '../../models/auth/token.dart';
import '../../models/common/exceptions.dart';
import '../local/local_storage_service.dart';

class ApiClient {
  static const String _baseUrl = 'http://10.0.2.2:8000/api/v1'; // Android emulator localhost

  final Dio _dio;
  final LocalStorageService _localStorage;

  ApiClient({
    Dio? dio,
    LocalStorageService? localStorage,
  })  : _dio = dio ?? Dio(),
        _localStorage = localStorage ?? LocalStorageService() {
    _configureDio();
  }

  Dio get dio => _dio;

  void _configureDio() {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.options.headers['Content-Type'] = 'application/json';
    _dio.options.headers['Accept'] = 'application/json';

    // Add request interceptor for authentication
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final accessToken = await getAccessToken();
        if (accessToken != null) {
          options.headers['Authorization'] = 'Bearer $accessToken';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        // Handle 401 errors - try to refresh token
        if (error.response?.statusCode == 401 &&
            error.requestOptions.path != '/auth/refresh' &&
            error.requestOptions.path != '/auth/login' &&
            error.requestOptions.path != '/auth/register') {

          final refreshed = await refreshToken();
          if (refreshed != null) {
            // Retry the original request with new token
            final accessToken = await getAccessToken();
            error.requestOptions.headers['Authorization'] = 'Bearer $accessToken';

            try {
              final response = await _dio.fetch(error.requestOptions);
              handler.resolve(response);
              return;
            } catch (e) {
              handler.next(error);
              return;
            }
          } else {
            // Refresh failed, clear tokens and redirect to login
            await _clearTokens();
          }
        }
        handler.next(error);
      },
    ));

    // Add logging interceptor in debug mode
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      requestHeader: false,
      responseHeader: false,
    ));
  }

  Future<void> storeTokens({
    required String accessToken,
    required String refreshToken,
    int? expiresInSeconds,
  }) async {
    await _localStorage.saveAuthToken(accessToken, expiresInSeconds: expiresInSeconds);
    await _localStorage.saveRefreshToken(refreshToken);
    await _localStorage.saveLoginTimestamp();
  }

  Future<String?> getAccessToken() async {
    return await _localStorage.getAuthToken();
  }

  Future<String?> getRefreshToken() async {
    return await _localStorage.getRefreshToken();
  }

  Future<bool> isLoggedIn() async {
    try {
      return (await refreshToken() != null);
    } on AuthException {
      return false;
    }
  }

  Future<Token?> refreshToken() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) return null;

      final response = await _dio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        await storeTokens(
          accessToken: data['access_token'],
          refreshToken: data['refresh_token'],
          expiresInSeconds: data['expires_in'],
        );
        return Token.fromJson(data);
      }

      return null;
    } catch (e) {
      throw AuthException("Refresh access token failed");
    }
  }

  Future<void> logout() async {
    final refreshToken = await getRefreshToken();
    await _dio.post(
        '/auth/logout',
        data: {'refresh_token': refreshToken},
        options: Options(headers: {'Content-Type': 'application/json'})
    );
    await _clearTokens();
  }

  Future<void> logoutAll() async {
    await _dio.post(
        '/auth/logout/all',
        options: Options(headers: {'Content-Type': 'application/json'})
    );
    await _clearTokens();
  }

  Future<void> _clearTokens() async {
    await _localStorage.clearSessionData();
  }
}