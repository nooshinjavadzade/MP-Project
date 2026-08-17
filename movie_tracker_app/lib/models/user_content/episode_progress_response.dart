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

  EpisodeProgressResponse copyWith({
    int? userId,
    int? mediaId,
    int? seasonNumber,
    int? episodeNumber,
    WatchStatus? status,
    DateTime? watchedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EpisodeProgressResponse(
      userId: userId ?? this.userId,
      mediaId: mediaId ?? this.mediaId,
      seasonNumber: seasonNumber ?? this.seasonNumber,
      episodeNumber: episodeNumber ?? this.episodeNumber,
      status: status ?? this.status,
      watchedAt: watchedAt ?? this.watchedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}