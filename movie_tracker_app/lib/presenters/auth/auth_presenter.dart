import 'package:flutter/foundation.dart';
import '../../models/auth.dart';
import '../../services/api/auth_service.dart';
import '../../services/local/biometric_service.dart';
import '../../services/local/local_storage_service.dart';
import 'i_auth_presenter.dart';

class AuthPresenter extends ChangeNotifier implements IAuthPresenter {
  final AuthService _authService;
  final LocalStorageService _localStorageService;
  final BiometricService _biometricService;

  bool _isLoading = false;
  String? _errorMessage;
  AuthResponse? _authResponse;
  bool _isBiometricEnabled = false;

  AuthPresenter(
      this._authService, {
        LocalStorageService? localStorageService,
        BiometricService? biometricService,
      })  : _localStorageService = localStorageService ?? LocalStorageService(),
        _biometricService = biometricService ?? BiometricService();

  @override
  bool get isLoading => _isLoading;

  @override
  String? get errorMessage => _errorMessage;

  @override
  AuthResponse? get authResponse => _authResponse;

  @override
  bool get isBiometricEnabled => _isBiometricEnabled;

  @override
  Future<void> login(String email, String password) async {
    _setLoading(true);
    try {
      final request = LoginRequest(email: email, password: password);
      _authResponse = await _authService.login(request);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  @override
  Future<void> register(String username, String email, String password, {String? fullName}) async {
    _setLoading(true);
    try {
      final request = RegisterRequest(
        username: username,
        email: email,
        password: password,
        fullName: fullName,
      );
      _authResponse = await _authService.register(request);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  @override
  Future<void> changePassword(String currentPassword, String newPassword) async {
    _setLoading(true);
    try {
      await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  @override
  Future<void> requestEmailVerification() async {
    _setLoading(true);
    try {
      await _authService.requestEmailVerification();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  @override
  Future<void> confirmEmailVerification(String otp) async {
    _setLoading(true);
    try {
      final request = VerifyEmailConfirm(otp: otp);
      _authResponse = await _authService.confirmEmailVerification(request);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  @override
  Future<void> requestPasswordReset(String email) async {
    _setLoading(true);
    try {
      await _authService.requestPasswordReset(email);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  @override
  Future<void> confirmPasswordReset(
      String email,
      String otp,
      String newPassword,
      String confirmPassword,
      ) async {
    _setLoading(true);
    try {
      final request = ResetPasswordConfirm(
        email: email,
        otp: otp,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
      _authResponse = await _authService.confirmPasswordReset(request);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  @override
  Future<void> logout() async {
    _setLoading(true);
    try {
      await _authService.logout();
      await _localStorageService.clearSessionData();
      _authResponse = null;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  @override
  Future<bool> checkAutoLogin() async {
    _setLoading(true);
    try {
      final isValid = await _localStorageService.isSessionValid();
      if (!isValid) {
        await logout();
        return false;
      }

      final isBiometricOn = await _localStorageService.isBiometricEnabled();
      if (isBiometricOn) {
        final authenticated = await _biometricService.authenticate();
        return authenticated;
      }

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  @override
  Future<bool> authenticateWithBiometric() async {
    _setLoading(true);
    try {
      final result = await _biometricService.authenticate();
      _errorMessage = null;
      return result;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  @override
  Future<void> setBiometricEnabled(bool enabled) async {
    await _localStorageService.setBiometricEnabled(enabled);
    _isBiometricEnabled = enabled;
    notifyListeners();
  }

  @override
  Future<void> loadBiometricStatus() async {
    _isBiometricEnabled = await _localStorageService.isBiometricEnabled();
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}