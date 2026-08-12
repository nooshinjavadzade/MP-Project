import 'package:dio/dio.dart';

import '../../models/auth.dart';
import '../../models/common/exceptions.dart';
import '../local/local_storage_service.dart';

import 'api_client.dart';
import 'error_handler.dart';

class AuthService {
  final ApiClient _apiClient;
  final LocalStorageService _localStorageService;
  final _baseEndpoint = '/auth';

  AuthService(
      this._apiClient, {
        LocalStorageService? localStorageService,
      }) : _localStorageService = localStorageService ?? LocalStorageService();

  Future<AuthResponse> register(RegisterRequest request) async {
    try {
      final response = await _apiClient.dio.post(
        '$_baseEndpoint/register',
        data: request.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final authResponse = AuthResponse.fromJson(response.data);
        await _apiClient.storeTokens(
          accessToken: authResponse.tokens.accessToken,
          refreshToken: authResponse.tokens.refreshToken,
        );
        await _localStorageService.saveAuthToken(
          authResponse.tokens.accessToken,
        );
        await _localStorageService.saveRefreshToken(
          authResponse.tokens.refreshToken,
        );
        await _localStorageService.saveLoginTimestamp();
        return authResponse;
      }
      throw ErrorHandler.handleError(response);
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await _apiClient.dio.post(
        '$_baseEndpoint/login',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(response.data);
        await _apiClient.storeTokens(
          accessToken: authResponse.tokens.accessToken,
          refreshToken: authResponse.tokens.refreshToken,
        );
        await _localStorageService.saveAuthToken(
          authResponse.tokens.accessToken,
        );
        await _localStorageService.saveRefreshToken(
          authResponse.tokens.refreshToken,
        );
        await _localStorageService.saveLoginTimestamp();
        return authResponse;
      }
      throw ErrorHandler.handleError(response);
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  Future<Token> refreshToken() async {
    try {
      final token = await _apiClient.refreshToken();
      if (token == null) {
        throw AuthException('Refresh token is either missing or expired');
      }

      await _localStorageService.saveAuthToken(token.accessToken);
      await _localStorageService.saveRefreshToken(token.refreshToken);
      return token;
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '$_baseEndpoint/password/change',
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
      );

      if (response.statusCode != 200) {
        throw ErrorHandler.handleError(response);
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  Future<void> requestEmailVerification() async {
    try {
      final response = await _apiClient.dio.post(
        '$_baseEndpoint/verify-email/request',
      );
      if (response.statusCode != 200) {
        throw ErrorHandler.handleError(response);
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  Future<AuthResponse> confirmEmailVerification(
      VerifyEmailConfirm request,
      ) async {
    try {
      final response = await _apiClient.dio.post(
        '$_baseEndpoint/verify-email/confirm',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        final verifyResponse = VerifyEmailResponse.fromJson(response.data);
        if (verifyResponse.tokens != null) {
          await _apiClient.storeTokens(
            accessToken: verifyResponse.tokens!.accessToken,
            refreshToken: verifyResponse.tokens!.refreshToken,
          );
          await _localStorageService.saveAuthToken(
            verifyResponse.tokens!.accessToken,
          );
          await _localStorageService.saveRefreshToken(
            verifyResponse.tokens!.refreshToken,
          );
          await _localStorageService.saveLoginTimestamp();
          return AuthResponse(
            tokens: verifyResponse.tokens!,
            user: verifyResponse.user!,
          );
        }
      }
      throw ErrorHandler.handleError(response);
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  Future<void> requestPasswordReset(String email) async {
    try {
      final response = await _apiClient.dio.post(
        '$_baseEndpoint/password/reset/request',
        data: {'email': email},
      );
      if (response.statusCode != 200) {
        throw ErrorHandler.handleError(response);
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  Future<AuthResponse> confirmPasswordReset(
      ResetPasswordConfirm request,
      ) async {
    try {
      final response = await _apiClient.dio.post(
        '$_baseEndpoint/password/reset/confirm',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        final verifyResponse = VerifyEmailResponse.fromJson(response.data);
        if (verifyResponse.tokens != null) {
          await _apiClient.storeTokens(
            accessToken: verifyResponse.tokens!.accessToken,
            refreshToken: verifyResponse.tokens!.refreshToken,
          );
          await _localStorageService.saveAuthToken(
            verifyResponse.tokens!.accessToken,
          );
          await _localStorageService.saveRefreshToken(
            verifyResponse.tokens!.refreshToken,
          );
          await _localStorageService.saveLoginTimestamp();
          return AuthResponse(
            tokens: verifyResponse.tokens!,
            user: verifyResponse.user!,
          );
        }
      }
      throw ErrorHandler.handleError(response);
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  Future<void> logout() async {
    try {
      await _apiClient.logout();
    } finally {
      await _localStorageService.clearSessionData();
    }
  }

  Future<void> logoutAll() async {
    try {
      await _apiClient.logoutAll();
    } finally {
      await _localStorageService.clearSessionData();
    }
  }
}