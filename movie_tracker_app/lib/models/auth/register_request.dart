class RegisterRequest {
  final String username;
  final String email;
  final String password;
  final String? fullName;

  const RegisterRequest({
    required this.username,
    required this.email,
    required this.password,
    this.fullName,
  });

  factory RegisterRequest.fromJson(Map<String, dynamic> json) {
    return RegisterRequest(
      username: json['username'],
      email: json['email'],
      password: json['password'],
      fullName: json['full_name'],
    );
  }

  Map<String, dynamic> toJson() => {
    'username': username,
    'email': email,
    'password': password,
    'full_name': fullName,
  };

  RegisterRequest copyWith({
    String? username,
    String? email,
    String? password,
    String? fullName,
  }) {
    return RegisterRequest(
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      fullName: fullName ?? this.fullName,
    );
  }
}