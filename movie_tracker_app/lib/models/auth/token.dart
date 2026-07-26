class Token {
  final String accessToken;
  final String refreshToken;
  final String tokenType;

  const Token({
    required this.accessToken,
    required this.refreshToken,
    this.tokenType = 'bearer',
  });

  factory Token.fromJson(Map<String, dynamic> json) {
    return Token(
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
      tokenType: json['token_type'] ?? 'bearer',
    );
  }

  Map<String, dynamic> toJson() => {
    'access_token': accessToken,
    'refresh_token': refreshToken,
    'token_type': tokenType,
  };

  Token copyWith({
    String? accessToken,
    String? refreshToken,
    String? tokenType,
  }) {
    return Token(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      tokenType: tokenType ?? this.tokenType,
    );
  }
}