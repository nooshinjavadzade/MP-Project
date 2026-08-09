import 'watch_status.dart';

/// Request model for creating/updating episode watch progress
class EpisodeProgressCreate {
  final int seasonNumber;
  final int episodeNumber;
  final WatchStatus status;

  const EpisodeProgressCreate({
    required this.seasonNumber,
    required this.episodeNumber,
    required this.status,
  });

  factory EpisodeProgressCreate.fromJson(Map<String, dynamic> json) {
    return EpisodeProgressCreate(
      seasonNumber: json['season_number'],
      episodeNumber: json['episode_number'],
      status: WatchStatusExtension.fromString(json['status']),
    );
  }

  Map<String, dynamic> toJson() => {
    'season_number': seasonNumber,
    'episode_number': episodeNumber,
    'status': status.value,
  };
}