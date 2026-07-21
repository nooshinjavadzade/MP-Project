import '../user_content/watch_status.dart';
import 'cast_member.dart';
import 'media_type.dart';

class MediaBase {
  final int id;
  final MediaType mediaType;
  final String imdbId;
  final String title;
  final String? originalTitle;
  final String? posterUrl;
  final String? backdropUrl;
  final String? overview;
  final int? releaseYear;
  final double? imdbRating;
  final double? communityRating;
  final String? originalLanguage;
  final String? country;
  final List<CastMember> cast;
  final List<String> genres;
  final WatchStatus? watchStatus;

  const MediaBase({
    required this.id,
    required this.mediaType,
    required this.imdbId,
    required this.title,
    this.originalTitle,
    this.posterUrl,
    this.backdropUrl,
    this.overview,
    this.releaseYear,
    this.imdbRating,
    this.communityRating,
    this.originalLanguage,
    this.country,
    this.cast = const [],
    this.genres = const [],
    this.watchStatus,
  });

  factory MediaBase.fromJson(Map<String, dynamic> json) {
    return MediaBase(
      id: json['id'],
      mediaType: MediaTypeExtension.fromString(json['media_type']),
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'media_type': mediaType.value,
      'imdb_id': imdbId,
      'title': title,
      'original_title': originalTitle,
      'poster_url': posterUrl,
      'backdrop_url': backdropUrl,
      'overview': overview,
      'release_year': releaseYear,
      'imdb_rating': imdbRating,
      'community_rating': communityRating,
      'original_language': originalLanguage,
      'country': country,
      'cast': cast.map((e) => e.toJson()).toList(),
      'genres': genres,
      'watch_status': watchStatus?.value,
    };
  }
}
