class Episode {
  final int episodeNumber;
  final String title;
  final String? overview;
  final DateTime? releaseDate;
  final int? runtime;
  final double? tmdbRating;

  const Episode({
    required this.episodeNumber,
    required this.title,
    this.overview,
    this.releaseDate,
    this.runtime,
    this.tmdbRating,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      episodeNumber: json['episode_number'],
      title: json['title'],
      overview: json['overview'],
      releaseDate: json['release_date'] != null
          ? DateTime.parse(json['release_date'])
          : null,
      runtime: json['runtime'],
      tmdbRating: (json['tmdb_rating'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'episode_number': episodeNumber,
    'title': title,
    'overview': overview,
    'release_date': releaseDate?.toIso8601String(),
    'runtime': runtime,
    'tmdb_rating': tmdbRating,
  };

  Episode copyWith({
    int? episodeNumber,
    String? title,
    String? overview,
    DateTime? releaseDate,
    int? runtime,
    double? tmdbRating,
  }) {
    return Episode(
      episodeNumber: episodeNumber ?? this.episodeNumber,
      title: title ?? this.title,
      overview: overview ?? this.overview,
      releaseDate: releaseDate ?? this.releaseDate,
      runtime: runtime ?? this.runtime,
      tmdbRating: tmdbRating ?? this.tmdbRating,
    );
  }
}