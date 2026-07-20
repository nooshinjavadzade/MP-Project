class EpisodeModel {
  final int episodeNumber;
  final String title;
  final String? overview;
  final DateTime? releaseDate;
  final int? runtime;
  final bool watched;

  const EpisodeModel({
    required this.episodeNumber,
    required this.title,
    this.overview,
    this.releaseDate,
    this.runtime,
    this.watched = false,
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
      watched: json['watched'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'episode_number': episodeNumber,
    'title': title,
    'overview': overview,
    'release_date': releaseDate?.toIso8601String(),
    'runtime': runtime,
    'watched': watched,
  };

  EpisodeModel copyWith({
    int? episodeNumber,
    String? title,
    String? overview,
    DateTime? releaseDate,
    int? runtime,
    bool? watched,
  }) {
    return EpisodeModel(
      episodeNumber: episodeNumber ?? this.episodeNumber,
      title: title ?? this.title,
      overview: overview ?? this.overview,
      releaseDate: releaseDate ?? this.releaseDate,
      runtime: runtime ?? this.runtime,
      watched: watched ?? this.watched,
    );
  }
}