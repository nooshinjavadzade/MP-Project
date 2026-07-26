import 'media_type.dart';

class MediaBase {
  final int id;
  final MediaType mediaType;
  final String tmdbId;
  final String title;
  final String? posterUrl;
  final String? backdropUrl;
  final int? releaseYear;
  final double? tmdbRating;
  final double? communityRating;

  const MediaBase({
    required this.id,
    required this.mediaType,
    required this.tmdbId,
    required this.title,
    this.posterUrl,
    this.backdropUrl,
    this.releaseYear,
    this.tmdbRating,
    this.communityRating,
  });

  factory MediaBase.fromJson(Map<String, dynamic> json) {
    return MediaBase(
      id: json['id'],
      mediaType: MediaTypeExtension.fromString(json['media_type']),
      tmdbId: json['tmdb_id'],
      title: json['title'],
      posterUrl: json['poster_url'],
      backdropUrl: json['backdrop_url'],
      releaseYear: json['release_year'],
      tmdbRating: (json['tmdb_rating'] as num?)?.toDouble(),
      communityRating: (json['community_rating'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'media_type': mediaType.value,
      'tmdb_id': tmdbId,
      'title': title,
      'poster_url': posterUrl,
      'backdrop_url': backdropUrl,
      'release_year': releaseYear,
      'tmdb_rating': tmdbRating,
      'community_rating': communityRating,
    };
  }
}