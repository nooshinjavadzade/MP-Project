import 'episode.dart';

class Season {
  final int seasonNumber;
  final String? title;
  final String? overview;
  final DateTime? releaseDate;
  final double? tmdbRating;
  final List<Episode> episodes;

  const Season({
    required this.seasonNumber,
    this.title,
    this.overview,
    this.releaseDate,
    this.tmdbRating,
    this.episodes = const [],
  });

  factory Season.fromJson(Map<String, dynamic> json) {
    return Season(
      seasonNumber: json['season_number'],
      title: json['title'],
      overview: json['overview'],
      releaseDate: json['release_date'] != null
          ? DateTime.parse(json['release_date'])
          : null,
      tmdbRating: (json['tmdb_rating'] as num?)?.toDouble(),
      episodes: (json['episodes'] as List<dynamic>?)
              ?.map((e) => Episode.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
    'season_number': seasonNumber,
    'title': title,
    'overview': overview,
    'release_date': releaseDate?.toIso8601String(),
    'tmdb_rating': tmdbRating,
    'episodes': episodes.map((e) => e.toJson()).toList(),
  };

  Season copyWith({
    int? seasonNumber,
    String? title,
    String? overview,
    DateTime? releaseDate,
    double? tmdbRating,
    List<Episode>? episodes,
  }) {
    return Season(
      seasonNumber: seasonNumber ?? this.seasonNumber,
      title: title ?? this.title,
      overview: overview ?? this.overview,
      releaseDate: releaseDate ?? this.releaseDate,
      tmdbRating: tmdbRating ?? this.tmdbRating,
      episodes: episodes ?? this.episodes,
    );
  }
}