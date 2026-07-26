import '../common/media_details.dart';
import '../common/media_type.dart';
import '../common/cast_member.dart';


class MovieDetails extends MediaDetails {
  final int? runtime;


  const MovieDetails({
    required super.id,
    required super.tmdbId,
    required super.title,

    super.posterUrl,
    super.backdropUrl,
    super.releaseYear,
    super.tmdbRating,
    super.communityRating,

    super.originalTitle,
    super.overview,
    super.originalLanguage,
    super.country,
    super.cast,
    super.genres,

    this.runtime,
  }) : super(
    mediaType: MediaType.movie,
  );


  factory MovieDetails.fromJson(Map<String, dynamic> json) {
    return MovieDetails(
      id: json['id'],
      tmdbId: json['tmdb_id'],
      title: json['title'],

      posterUrl: json['poster_url'],
      backdropUrl: json['backdrop_url'],
      releaseYear: json['release_year'],

      tmdbRating:
      (json['tmdb_rating'] as num?)?.toDouble(),

      communityRating:
      (json['community_rating'] as num?)?.toDouble(),

      originalTitle: json['original_title'],
      overview: json['overview'],
      originalLanguage: json['original_language'],
      country: json['country'],

      cast: (json['cast'] as List<dynamic>?)
          ?.map((e) => CastMember.fromJson(e))
          .toList() ??
          const [],

      genres: (json['genres'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          const [],

      runtime: json['runtime'],
    );
  }


  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'runtime': runtime,
    };
  }
}