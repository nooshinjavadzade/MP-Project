import 'watch_status.dart';

/// Response model for individual episode watch progress
class EpisodeProgressResponse {
  final int userId;
  final int mediaId;
  final int seasonNumber;
  final int episodeNumber;
  final WatchStatus status;
  final DateTime? watchedAt;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const EpisodeProgressResponse({
    required this.userId,
    required this.mediaId,
    required this.seasonNumber,
    required this.episodeNumber,
    required this.status,
    this.watchedAt,
    required this.createdAt,
    this.updatedAt,
  });

  factory EpisodeProgressResponse.fromJson(Map<String, dynamic> json) {
    return EpisodeProgressResponse(
      userId: json['user_id'],
      mediaId: json['media_id'],
      seasonNumber: json['season_number'],
      episodeNumber: json['episode_number'],
      status: WatchStatusExtension.fromString(json['status']),
      watchedAt: json['watched_at'] != null
          ? DateTime.parse(json['watched_at'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'media_id': mediaId,
    'season_number': seasonNumber,
    'episode_number': episodeNumber,
    'status': status.value,
    'watched_at': watchedAt?.toIso8601String(),
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  };
}