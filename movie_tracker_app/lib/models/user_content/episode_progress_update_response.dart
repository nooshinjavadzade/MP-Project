import 'episode_progress_response.dart';

/// Response wrapper for episode progress updates
class EpisodeProgressUpdateResponse {
  final String message;
  final EpisodeProgressResponse episode;

  const EpisodeProgressUpdateResponse({
    required this.message,
    required this.episode,
  });

  factory EpisodeProgressUpdateResponse.fromJson(Map<String, dynamic> json) {
    return EpisodeProgressUpdateResponse(
      message: json['message'],
      episode: EpisodeProgressResponse.fromJson(json['episode']),
    );
  }

  Map<String, dynamic> toJson() => {
    'message': message,
    'episode': episode.toJson(),
  };

  EpisodeProgressUpdateResponse copyWith({
    String? message,
    EpisodeProgressResponse? episode,
  }) {
    return EpisodeProgressUpdateResponse(
      message: message ?? this.message,
      episode: episode ?? this.episode,
    );
  }
}