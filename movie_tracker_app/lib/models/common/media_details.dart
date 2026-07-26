import 'media_base.dart';
import 'cast_member.dart';


abstract class MediaDetails extends MediaBase {
  final String? originalTitle;
  final String? overview;
  final String? originalLanguage;
  final String? country;
  final List<CastMember> cast;
  final List<String> genres;


  const MediaDetails({
    required super.id,
    required super.mediaType,
    required super.tmdbId,
    required super.title,
    super.posterUrl,
    super.backdropUrl,
    super.releaseYear,
    super.tmdbRating,
    super.communityRating,

    this.originalTitle,
    this.overview,
    this.originalLanguage,
    this.country,
    this.cast = const [],
    this.genres = const [],
  });


  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'original_title': originalTitle,
      'overview': overview,
      'original_language': originalLanguage,
      'country': country,
      'cast': cast.map((e) => e.toJson()).toList(),
      'genres': genres,
    };
  }
}