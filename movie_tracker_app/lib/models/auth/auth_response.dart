import 'login_response.dart';
import 'user.dart';

class AuthResponse {
  final LoginResponse tokens;
  final User user;

  const AuthResponse({
    required this.tokens,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      tokens: LoginResponse.fromJson(json),
      user: User.fromJson(json['user']),
    );
  }

  Map<String, dynamic> toJson() => {
    ...tokens.toJson(),
    'user': user.toJson(),
  };

  AuthResponse copyWith({
    LoginResponse? tokens,
    User? user,
  }) {
    return AuthResponse(
      tokens: tokens ?? this.tokens,
      user: user ?? this.user,
    );
  }
}