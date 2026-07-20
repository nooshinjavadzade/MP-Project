class User {
  final int id;
  final String username;
  final String email;
  final String? fullName;
  final String? avatarUrl;
  final String? bio;
  final bool isAdmin;

  const User({
    required this.id,
    required this.username,
    required this.email,
    this.fullName,
    this.avatarUrl,
    this.bio,
    this.isAdmin = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      fullName: json['full_name'],
      avatarUrl: json['avatar_url'],
      bio: json['bio'],
      isAdmin: json['is_admin'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'email': email,
    'full_name': fullName,
    'avatar_url': avatarUrl,
    'bio': bio,
    'is_admin': isAdmin,
  };

  User copyWith({
    int? id,
    String? username,
    String? email,
    String? fullName,
    String? avatarUrl,
    String? bio,
    bool? isAdmin,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }
}