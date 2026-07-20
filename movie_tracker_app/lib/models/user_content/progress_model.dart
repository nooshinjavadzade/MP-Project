class ProgressModel {
  final double progress;
  final int? watchedEpisodes;
  final int? totalEpisodes;
  final bool finished;

  const ProgressModel({
    required this.progress,
    this.watchedEpisodes,
    this.totalEpisodes,
    this.finished = false,
  });

  factory ProgressModel.fromJson(Map<String, dynamic> json) {
    return ProgressModel(
      progress: (json['progress'] as num).toDouble(),
      watchedEpisodes: json['watched_episodes'],
      totalEpisodes: json['total_episodes'],
      finished: json['finished'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'progress': progress,
    'watched_episodes': watchedEpisodes,
    'total_episodes': totalEpisodes,
    'finished': finished,
  };
}