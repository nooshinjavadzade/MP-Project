import '../common/media_details.dart';
import '../common/media_type.dart';
import '../common/cast_member.dart';
import 'season.dart';


class SeriesDetails extends MediaDetails {
  final int? seasonCount;
  final int? episodeCount;
  final List<Season> seasons;
  final int? endYear;
  final String status;


  const SeriesDetails({
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

    this.seasonCount,
    this.episodeCount,
    this.seasons = const [],
    this.endYear,
    required this.status,

  }) : super(
    mediaType: MediaType.series,
  );


  factory SeriesDetails.fromJson(Map<String, dynamic> json) {
    return SeriesDetails(
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


      seasonCount: json['season_count'],
      episodeCount: json['episode_count'],

      seasons: (json['seasons'] as List<dynamic>?)
          ?.map((e) => Season.fromJson(e))
          .toList() ??
          const [],

      endYear: json['end_year'],
      status: json['status'] ?? '',
    );
  }


  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'season_count': seasonCount,
      'episode_count': episodeCount,
      'seasons': seasons.map((e) => e.toJson()).toList(),
      'end_year': endYear,
      'status': status,
    };
  }

  SeriesDetails copyWithSeriesDetails({
    int? id,
    String? tmdbId,
    String? title,
    String? posterUrl,
    String? backdropUrl,
    int? releaseYear,
    double? tmdbRating,
    double? communityRating,
    String? originalTitle,
    String? overview,
    String? originalLanguage,
    String? country,
    List<CastMember>? cast,
    List<String>? genres,
    int? seasonCount,
    int? episodeCount,
    List<Season>? seasons,
    int? endYear,
    String? status,
  }) {
    return SeriesDetails(
      id: id ?? this.id,
      tmdbId: tmdbId ?? this.tmdbId,
      title: title ?? this.title,
      posterUrl: posterUrl ?? this.posterUrl,
      backdropUrl: backdropUrl ?? this.backdropUrl,
      releaseYear: releaseYear ?? this.releaseYear,
      tmdbRating: tmdbRating ?? this.tmdbRating,
      communityRating: communityRating ?? this.communityRating,
      originalTitle: originalTitle ?? this.originalTitle,
      overview: overview ?? this.overview,
      originalLanguage: originalLanguage ?? this.originalLanguage,
      country: country ?? this.country,
      cast: cast ?? this.cast,
      genres: genres ?? this.genres,
      seasonCount: seasonCount ?? this.seasonCount,
      episodeCount: episodeCount ?? this.episodeCount,
      seasons: seasons ?? this.seasons,
      endYear: endYear ?? this.endYear,
      status: status ?? this.status,
    );
  }
}