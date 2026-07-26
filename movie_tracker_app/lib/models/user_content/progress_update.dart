class ProgressUpdate {
  final int mediaId;
  final int watchedEpisodes;

  const ProgressUpdate({
    required this.mediaId,
    required this.watchedEpisodes,
  });

  factory ProgressUpdate.fromJson(Map<String, dynamic> json) {
    return ProgressUpdate(
      mediaId: json['media_id'],
      watchedEpisodes: json['watched_episodes'],
    );
  }

  Map<String, dynamic> toJson() => {
    'media_id': mediaId,
    'watched_episodes': watchedEpisodes,
  };
}