class MovieModel {
  final int id;
  final String imdbId;
  final String title;
  final String? posterUrl;
  final String? backdropUrl;
  final String? overview;
  final int? releaseYear;
  final double? imdbRating;
  final List<String> genres;

  const MovieModel({
    required this.id,
    required this.imdbId,
    required this.title,
    this.posterUrl,
    this.backdropUrl,
    this.overview,
    this.releaseYear,
    this.imdbRating,
    this.genres = const [],
  });

  factory MovieModel.fromJson(Map<String, dynamic> json) {
    return MovieModel(
      id: json['id'],
      imdbId: json['imdb_id'],
      title: json['title'],
      posterUrl: json['poster_url'],
      backdropUrl: json['backdrop_url'],
      overview: json['overview'],
      releaseYear: json['release_year'],
      imdbRating: (json['imdb_rating'] as num?)?.toDouble(),
      genres: json['genres'] != null
          ? List<String>.from(json['genres'])
          : const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imdb_id': imdbId,
      'title': title,
      'poster_url': posterUrl,
      'backdrop_url': backdropUrl,
      'overview': overview,
      'release_year': releaseYear,
      'imdb_rating': imdbRating,
      'genres': genres,
    };
  }

  MovieModel copyWith({
    int? id,
    String? imdbId,
    String? title,
    String? posterUrl,
    String? backdropUrl,
    String? overview,
    int? releaseYear,
    double? imdbRating,
    List<String>? genres,
    int? runtime,
  }) {
    return MovieModel(
      id: id ?? this.id,
      imdbId: imdbId ?? this.imdbId,
      title: title ?? this.title,
      posterUrl: posterUrl ?? this.posterUrl,
      backdropUrl: backdropUrl ?? this.backdropUrl,
      overview: overview ?? this.overview,
      releaseYear: releaseYear ?? this.releaseYear,
      imdbRating: imdbRating ?? this.imdbRating,
      genres: genres ?? this.genres,
    );
  }
}