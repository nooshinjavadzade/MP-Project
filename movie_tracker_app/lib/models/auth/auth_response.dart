import 'token.dart';
import 'user.dart';

class AuthResponse {
  final Token tokens;
  final User user;

  const AuthResponse({required this.tokens, required this.user});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      tokens: Token.fromJson(json['tokens']),
      user: User.fromJson(json['user']),
    );
  }

  Map<String, dynamic> toJson() => {
    'tokens': tokens.toJson(),
    'user': user.toJson(),
  };

  AuthResponse copyWith({Token? tokens, User? user}) {
    return AuthResponse(
      tokens: tokens ?? this.tokens,
      user: user ?? this.user,
    );
  }
}