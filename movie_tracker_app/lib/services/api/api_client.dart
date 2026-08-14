import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/auth/token.dart';
import '../../models/common/exceptions.dart';

class ApiClient {
  static const String _baseUrl = 'https://mp-project.fastapicloud.dev/api/v1';

  final Dio _dio;
  final FlutterSecureStorage _storage;

  ApiClient({
    Dio? dio,
    FlutterSecureStorage? storage,
  })  : _dio = dio ?? Dio(),
        _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(
                encryptedSharedPreferences: true,
                resetOnError: true,
              ),
            ) {
    _configureDio();
  }

  Dio get dio => _dio;

  void _configureDio() {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.options.headers['Content-Type'] = 'application/json';
    _dio.options.headers['Accept'] = 'application/json';

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final accessToken = await getAccessToken();
        if (accessToken != null) {
          options.headers['Authorization'] = 'Bearer $accessToken';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401 &&
            error.requestOptions.path != '/auth/refresh' &&
            error.requestOptions.path != '/auth/login' &&
            error.requestOptions.path != '/auth/register') {

          final refreshed = await refreshToken();
          if (refreshed != null) {
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
            await _clearTokens();
          }
        }
        handler.next(error);
      },
    ));

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
  }) async {
    await _storage.write(key: 'auth_token', value: accessToken);
    await _storage.write(key: 'refresh_token', value: refreshToken);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('login_timestamp', DateTime.now().millisecondsSinceEpoch);
  }

  Future<String?> getAccessToken() async {
    try {
      return await _storage.read(key: 'auth_token');
    } catch (_) {
      return null;
    }
  }

  Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: 'refresh_token');
    } catch (_) {
      return null;
    }
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
            refreshToken: data['refresh_token']
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
    try {
      await _storage.delete(key: 'auth_token');
      await _storage.delete(key: 'refresh_token');
    } catch (_) {}

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('login_timestamp');
  }
}