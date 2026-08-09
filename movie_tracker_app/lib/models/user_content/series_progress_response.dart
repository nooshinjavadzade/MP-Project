import 'watch_status.dart';

/// Aggregated series progress response
class SeriesProgressResponse {
  final int mediaId;
  final String title;
  final int totalEpisodes;
  final int watchedEpisodes;
  final double completionPct;
  final WatchStatus status;
  final Map<String, dynamic>? nextEpisode;

  const SeriesProgressResponse({
    required this.mediaId,
    required this.title,
    required this.totalEpisodes,
    required this.watchedEpisodes,
    required this.completionPct,
    required this.status,
    this.nextEpisode,
  });

  factory SeriesProgressResponse.fromJson(Map<String, dynamic> json) {
    return SeriesProgressResponse(
      mediaId: json['media_id'],
      title: json['title'],
      totalEpisodes: json['total_episodes'],
      watchedEpisodes: json['watched_episodes'],
      completionPct: (json['completion_pct'] as num).toDouble(),
      status: WatchStatusExtension.fromString(json['status']),
      nextEpisode: json['next_episode'],
    );
  }

  Map<String, dynamic> toJson() => {
    'media_id': mediaId,
    'title': title,
    'total_episodes': totalEpisodes,
    'watched_episodes': watchedEpisodes,
    'completion_pct': completionPct,
    'status': status.value,
    'next_episode': nextEpisode,
  };
}