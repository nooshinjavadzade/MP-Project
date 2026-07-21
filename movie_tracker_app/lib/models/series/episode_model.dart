import '../user_content/watch_status.dart';

class EpisodeModel {
  final int episodeNumber;
  final String title;
  final String? overview;
  final DateTime? releaseDate;
  final int? runtime;
  final WatchStatus? watchStatus;

  const EpisodeModel({
    required this.episodeNumber,
    required this.title,
    this.overview,
    this.releaseDate,
    this.runtime,
    this.watchStatus
  });

  factory EpisodeModel.fromJson(Map<String, dynamic> json) {
    return EpisodeModel(
      episodeNumber: json['episode_number'],
      title: json['title'],
      overview: json['overview'],
      releaseDate: json['release_date'] != null
          ? DateTime.parse(json['release_date'])
          : null,
      runtime: json['runtime'],
      watchStatus: json['watch_status'] != null
          ? WatchStatusExtension.fromString(json['watch_status'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'episode_number': episodeNumber,
    'title': title,
    'overview': overview,
    'release_date': releaseDate?.toIso8601String(),
    'runtime': runtime,
    'watch_status': watchStatus?.value,
  };

  EpisodeModel copyWith({
    int? episodeNumber,
    String? title,
    String? overview,
    DateTime? releaseDate,
    int? runtime,
    WatchStatus? watchStatus
  }) {
    return EpisodeModel(
      episodeNumber: episodeNumber ?? this.episodeNumber,
      title: title ?? this.title,
      overview: overview ?? this.overview,
      releaseDate: releaseDate ?? this.releaseDate,
      runtime: runtime ?? this.runtime,
      watchStatus: watchStatus ?? this.watchStatus
    );
  }
}