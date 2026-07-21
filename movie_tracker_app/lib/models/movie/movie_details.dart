import '../common/media_base.dart';
import '../common/cast_member.dart';
import '../common/media_type.dart';
import '../user_content/watch_status.dart';

class MovieDetails extends MediaBase {
  final int? runtime;

  const MovieDetails({
    required super.id,
    required super.imdbId,
    required super.title,
    super.originalTitle,
    super.posterUrl,
    super.backdropUrl,
    super.overview,
    super.releaseYear,
    super.imdbRating,
    super.communityRating,
    super.genres,
    super.originalLanguage,
    super.country,
    super.cast = const [],
    super.watchStatus,
    this.runtime,
  }) : super(mediaType: MediaType.movie);

  factory MovieDetails.fromJson(Map<String, dynamic> json) {
    return MovieDetails(
      id: json['id'],
      imdbId: json['imdb_id'],
      title: json['title'],
      originalTitle: json['original_title'],
      posterUrl: json['poster_url'],
      backdropUrl: json['backdrop_url'],
      overview: json['overview'],
      releaseYear: json['release_year'],
      imdbRating: (json['imdb_rating'] as num?)?.toDouble(),
      communityRating: (json['community_rating'] as num?)?.toDouble(),
      genres: json['genres'] != null
          ? List<String>.from(json['genres'])
          : const [],
      originalLanguage: json['original_language'],
      country: json['country'],
      cast: (json['cast'] as List<dynamic>?)
          ?.map((e) => CastMember.fromJson(e as Map<String, dynamic>))
          .toList() ??
          const [],
      watchStatus: json['watch_status'] != null
          ? WatchStatusExtension.fromString(json['watch_status'])
          : null,
      runtime: json['runtime'],
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'runtime': runtime,
  };
}
