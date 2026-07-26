class User {
  final int id;
  final String username;
  final String email;
  final String? fullName;
  final String? avatarUrl;
  final String? bio;
  final bool isAdmin;
  final bool isVerified;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.username,
    required this.email,
    this.fullName,
    this.avatarUrl,
    this.bio,
    this.isAdmin = false,
    this.isVerified = false,
    required this.createdAt,
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
      isVerified: json['is_verified'] ?? false,
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : DateTime.now(),
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
    'is_verified': isVerified,
    'created_at': createdAt.toIso8601String(),
  };

  User copyWith({
    int? id,
    String? username,
    String? email,
    String? fullName,
    String? avatarUrl,
    String? bio,
    bool? isAdmin,
    bool? isVerified,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      isAdmin: isAdmin ?? this.isAdmin,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}