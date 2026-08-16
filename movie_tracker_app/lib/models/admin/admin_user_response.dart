import '../common/pagination.dart';
import '../auth/user.dart';

class AdminUserResponse {
  final int id;
  final String username;
  final String email;
  final String? fullName;
  final String? avatarUrl;
  final bool isAdmin;
  final bool isActive;
  final bool isVerified;
  final DateTime createdAt;
  final int watchedMoviesCount;
  final int watchedSeriesCount;

  const AdminUserResponse({
    required this.id,
    required this.username,
    required this.email,
    this.fullName,
    this.avatarUrl,
    required this.isAdmin,
    required this.isActive,
    required this.isVerified,
    required this.createdAt,
    required this.watchedMoviesCount,
    required this.watchedSeriesCount,
  });

  factory AdminUserResponse.fromJson(Map<String, dynamic> json) {
    return AdminUserResponse(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      fullName: json['full_name'],
      avatarUrl: json['avatar_url'],
      isAdmin: json['is_admin'] ?? false,
      isActive: json['is_active'] ?? true,
      isVerified: json['is_verified'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      watchedMoviesCount: json['watched_movies_count'] ?? 0,
      watchedSeriesCount: json['watched_series_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'email': email,
    'full_name': fullName,
    'avatar_url': avatarUrl,
    'is_admin': isAdmin,
    'is_active': isActive,
    'is_verified': isVerified,
    'created_at': createdAt.toIso8601String(),
    'watched_movies_count': watchedMoviesCount,
    'watched_series_count': watchedSeriesCount,
  };

  // ✅ اینجا، داخل همین کلاس، درست جاشه
  User toUser() {
    return User(
      id: id,
      username: username,
      email: email,
      fullName: fullName,
      avatarUrl: avatarUrl,
      isAdmin: isAdmin,
      isVerified: isVerified,
      createdAt: createdAt,
    );
  }
} // ← کلاس AdminUserResponse اینجا بسته میشه

class AdminUserListResponse {
  final List<AdminUserResponse> items;
  final Pagination pagination;

  const AdminUserListResponse({
    required this.items,
    required this.pagination,
  });

  factory AdminUserListResponse.fromJson(Map<String, dynamic> json) {
    return AdminUserListResponse(
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => AdminUserResponse.fromJson(e))
              .toList() ??
          const [],
      pagination: Pagination.fromJson(json['pagination']),
    );
  }

  Map<String, dynamic> toJson() => {
    'items': items.map((e) => e.toJson()).toList(),
    'pagination': pagination.toJson(),
  };
} // ← دیگه توی این کلاس هیچی اضافه نیست، toUser() اینجا نباید باشه