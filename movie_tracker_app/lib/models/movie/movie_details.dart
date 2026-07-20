import 'movie_model.dart';
import '../common/cast_member.dart';

class MovieDetails extends MovieModel {
  final String? country;
  final List<CastMember> cast;
  final bool isFinished;

  const MovieDetails({
    required super.id,
    required super.imdbId,
    required super.title,
    super.posterUrl,
    super.backdropUrl,
    super.overview,
    super.releaseYear,
    super.imdbRating,
    super.genres,
    this.country,
    this.cast = const [],
    this.isFinished = false,
  });

  factory MovieDetails.fromJson(Map<String, dynamic> json) {
    return MovieDetails(
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
      country: json['country'],
      cast: (json['cast'] as List<dynamic>?)
          ?.map((e) => CastMember.fromJson(e as Map<String, dynamic>))
          .toList() ??
          const [],
      isFinished: json['is_adult'] ?? false,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'country': country,
    'cast': cast.map((e) => e.toJson()).toList(),
    'is_adult': isFinished,
  };
}