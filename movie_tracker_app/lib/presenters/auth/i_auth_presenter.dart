import '../../models/auth.dart';

abstract class IAuthPresenter {
  bool get isLoading;
  String? get errorMessage;
  AuthResponse? get authResponse;

  Future<void> login(String email, String password);
  Future<void> register(String username, String email, String password, {String? fullName});
  Future<void> changePassword(String currentPassword, String newPassword);
  Future<void> requestEmailVerification();
  Future<void> confirmEmailVerification(String otp);
  Future<void> requestPasswordReset(String email);
  Future<void> confirmPasswordReset(String email, String otp, String newPassword, String confirmPassword);
  Future<void> logout();
}