import '../common/media_base.dart';

class ProfileStats {
  final int watchedMoviesCount;
  final int watchedSeriesCount;
  final int likedMediaCount;
  final int ratingsCount;
  final int reviewsCount;
  final int listsCount;

  const ProfileStats({
    this.watchedMoviesCount = 0,
    this.watchedSeriesCount = 0,
    this.likedMediaCount = 0,
    this.ratingsCount = 0,
    this.reviewsCount = 0,
    this.listsCount = 0,
  });

  factory ProfileStats.fromJson(Map<String, dynamic> json) {
    return ProfileStats(
      watchedMoviesCount: json['watched_movies_count'] ?? 0,
      watchedSeriesCount: json['watched_series_count'] ?? 0,
      likedMediaCount: json['liked_media_count'] ?? 0,
      ratingsCount: json['ratings_count'] ?? 0,
      reviewsCount: json['reviews_count'] ?? 0,
      listsCount: json['lists_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'watched_movies_count': watchedMoviesCount,
    'watched_series_count': watchedSeriesCount,
    'liked_media_count': likedMediaCount,
    'ratings_count': ratingsCount,
    'reviews_count': reviewsCount,
    'lists_count': listsCount,
  };
}

class PublicUser {
  final int id;
  final String username;
  final String? fullName;
  final String? avatarUrl;
  final String? bio;
  final DateTime createdAt;

  const PublicUser({
    required this.id,
    required this.username,
    this.fullName,
    this.avatarUrl,
    this.bio,
    required this.createdAt,
  });

  factory PublicUser.fromJson(Map<String, dynamic> json) {
    return PublicUser(
      id: json['id'],
      username: json['username'],
      fullName: json['full_name'],
      avatarUrl: json['avatar_url'],
      bio: json['bio'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'full_name': fullName,
    'avatar_url': avatarUrl,
    'bio': bio,
    'created_at': createdAt.toIso8601String(),
  };
}

class ProfileResponse extends PublicUser {
  final int watchedMoviesCount;
  final int watchedSeriesCount;
  final List<MediaBase> likedMedia;
  final int ratingsCount;
  final int reviewsCount;
  final int listsCount;

  const ProfileResponse({
    required super.id,
    required super.username,
    super.fullName,
    super.avatarUrl,
    super.bio,
    required super.createdAt,
    this.watchedMoviesCount = 0,
    this.watchedSeriesCount = 0,
    this.likedMedia = const [],
    this.ratingsCount = 0,
    this.reviewsCount = 0,
    this.listsCount = 0,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      id: json['id'],
      username: json['username'],
      fullName: json['full_name'],
      avatarUrl: json['avatar_url'],
      bio: json['bio'],
      createdAt: DateTime.parse(json['created_at']),
      watchedMoviesCount: json['watched_movies_count'] ?? 0,
      watchedSeriesCount: json['watched_series_count'] ?? 0,
      likedMedia: (json['liked_media'] as List<dynamic>?)
              ?.map((e) => MediaBase.fromJson(e))
              .toList() ??
          const [],
      ratingsCount: json['ratings_count'] ?? 0,
      reviewsCount: json['reviews_count'] ?? 0,
      listsCount: json['lists_count'] ?? 0,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'watched_movies_count': watchedMoviesCount,
    'watched_series_count': watchedSeriesCount,
    'liked_media': likedMedia.map((e) => e.toJson()).toList(),
    'ratings_count': ratingsCount,
    'reviews_count': reviewsCount,
    'lists_count': listsCount,
  };
}

class PublicProfileResponse extends PublicUser {
  final int watchedMoviesCount;
  final int watchedSeriesCount;
  final List<MediaBase> likedMedia;
  final int ratingsCount;
  final int reviewsCount;
  final int listsCount;

  const PublicProfileResponse({
    required super.id,
    required super.username,
    super.fullName,
    super.avatarUrl,
    super.bio,
    required super.createdAt,
    this.watchedMoviesCount = 0,
    this.watchedSeriesCount = 0,
    this.likedMedia = const [],
    this.ratingsCount = 0,
    this.reviewsCount = 0,
    this.listsCount = 0,
  });

  factory PublicProfileResponse.fromJson(Map<String, dynamic> json) {
    return PublicProfileResponse(
      id: json['id'],
      username: json['username'],
      fullName: json['full_name'],
      avatarUrl: json['avatar_url'],
      bio: json['bio'],
      createdAt: DateTime.parse(json['created_at']),
      watchedMoviesCount: json['watched_movies_count'] ?? 0,
      watchedSeriesCount: json['watched_series_count'] ?? 0,
      likedMedia: (json['liked_media'] as List<dynamic>?)
              ?.map((e) => MediaBase.fromJson(e))
              .toList() ??
          const [],
      ratingsCount: json['ratings_count'] ?? 0,
      reviewsCount: json['reviews_count'] ?? 0,
      listsCount: json['lists_count'] ?? 0,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'watched_movies_count': watchedMoviesCount,
    'watched_series_count': watchedSeriesCount,
    'liked_media': likedMedia.map((e) => e.toJson()).toList(),
    'ratings_count': ratingsCount,
    'reviews_count': reviewsCount,
    'lists_count': listsCount,
  };
}

class UserLogin {
  final String email;
  final String password;

  const UserLogin({
    required this.email,
    required this.password,
  });

  factory UserLogin.fromJson(Map<String, dynamic> json) {
    return UserLogin(
      email: json['email'],
      password: json['password'],
    );
  }

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
  };
}