import 'watch_status.dart';

/// Response model for movie watch progress
class MovieProgressResponse {
  final int id;
  final int userId;
  final int mediaId;
  final WatchStatus? status;
  final double progress;
  final int watchedEpisodes;
  final DateTime? lastWatchedAt;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const MovieProgressResponse({
    required this.id,
    required this.userId,
    required this.mediaId,
    this.status,
    required this.progress,
    required this.watchedEpisodes,
    this.lastWatchedAt,
    required this.createdAt,
    this.updatedAt,
  });

  factory MovieProgressResponse.fromJson(Map<String, dynamic> json) {
    return MovieProgressResponse(
      id: json['id'],
      userId: json['user_id'],
      mediaId: json['media_id'],
      status: json['status'] != null
          ? WatchStatusExtension.fromString(json['status'])
          : null,
      progress: (json['progress'] as num).toDouble(),
      watchedEpisodes: json['watched_episodes'] ?? 0,
      lastWatchedAt: json['last_watched_at'] != null
          ? DateTime.parse(json['last_watched_at'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'media_id': mediaId,
    'status': status?.value,
    'progress': progress,
    'watched_episodes': watchedEpisodes,
    'last_watched_at': lastWatchedAt?.toIso8601String(),
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  };
}