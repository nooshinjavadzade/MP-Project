import 'package:flutter_test/flutter_test.dart';
import 'package:movie_tracker_app/models/auth.dart';
import 'package:movie_tracker_app/presenters/auth/auth_presenter.dart';
import 'package:movie_tracker_app/services/api/auth_service.dart';

class FakeAuthService implements AuthService {
  bool shouldThrowError = false;

  @override
  Future<AuthResponse> login(LoginRequest request) async {
    if (shouldThrowError) throw Exception('Login failed');
    return AuthResponse(
      tokens: Token(accessToken: 'access', refreshToken: 'refresh'),
      user: User(
        id: 1,
        username: 'testuser',
        email: request.email,
        createdAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<AuthResponse> register(RegisterRequest request) async {
    if (shouldThrowError) throw Exception('Register failed');
    return AuthResponse(
      tokens: Token(accessToken: 'access', refreshToken: 'refresh'),
      user: User(
        id: 1,
        username: request.username,
        email: request.email,
        createdAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (shouldThrowError) throw Exception('Change password failed');
  }

  @override
  Future<void> requestEmailVerification() async {
    if (shouldThrowError) throw Exception('Email verification request failed');
  }

  @override
  Future<AuthResponse> confirmEmailVerification(VerifyEmailConfirm request) async {
    if (shouldThrowError) throw Exception('Verification failed');
    return AuthResponse(
      tokens: Token(accessToken: 'access', refreshToken: 'refresh'),
      user: User(
        id: 1,
        username: 'verified',
        email: 'test@test.com',
        createdAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<void> requestPasswordReset(String email) async {
    if (shouldThrowError) throw Exception('Password reset failed');
  }

  @override
  Future<AuthResponse> confirmPasswordReset(ResetPasswordConfirm request) async {
    if (shouldThrowError) throw Exception('Reset confirm failed');
    return AuthResponse(
      tokens: Token(accessToken: 'access', refreshToken: 'refresh'),
      user: User(
        id: 1,
        username: 'reset',
        email: request.email,
        createdAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<Token> refreshToken() async {
    if (shouldThrowError) throw Exception('Refresh token failed');
    return Token(accessToken: 'new_access', refreshToken: 'new_refresh');
  }

  @override
  Future<void> logout() async {
    if (shouldThrowError) throw Exception('Logout failed');
  }
}

void main() {
  late FakeAuthService fakeService;
  late AuthPresenter presenter;

  setUp(() {
    fakeService = FakeAuthService();
    presenter = AuthPresenter(fakeService);
  });

  group('AuthPresenter Tests', () {
    test('login success updates state correctly', () async {
      expect(presenter.isLoading, false);
      expect(presenter.authResponse, isNull);

      final future = presenter.login('test@email.com', 'password123');
      expect(presenter.isLoading, true);

      await future;

      expect(presenter.isLoading, false);
      expect(presenter.errorMessage, isNull);
      expect(presenter.authResponse, isNotNull);
      expect(presenter.authResponse?.user.email, 'test@email.com');
    });

    test('login failure sets errorMessage', () async {
      fakeService.shouldThrowError = true;

      await presenter.login('test@email.com', 'wrong');

      expect(presenter.isLoading, false);
      expect(presenter.authResponse, isNull);
      expect(presenter.errorMessage, contains('Login failed'));
    });

    test('register success updates authResponse', () async {
      await presenter.register('john', 'john@test.com', '123456');

      expect(presenter.isLoading, false);
      expect(presenter.errorMessage, isNull);
      expect(presenter.authResponse?.user.username, 'john');
    });

    test('changePassword success clears errorMessage', () async {
      await presenter.changePassword('oldPass', 'newPass');

      expect(presenter.isLoading, false);
      expect(presenter.errorMessage, isNull);
    });

    test('confirmEmailVerification sets authResponse on success', () async {
      await presenter.confirmEmailVerification('123456');

      expect(presenter.isLoading, false);
      expect(presenter.errorMessage, isNull);
      expect(presenter.authResponse?.user.username, 'verified');
    });

    test('logout clears authResponse on success', () async {
      await presenter.login('test@email.com', 'pass');
      expect(presenter.authResponse, isNotNull);

      await presenter.logout();

      expect(presenter.isLoading, false);
      expect(presenter.authResponse, isNull);
      expect(presenter.errorMessage, isNull);
    });
  });
}