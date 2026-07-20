import '../common/media_base.dart';
import '../common/cast_member.dart';

import 'season_model.dart';

class SeriesDetails extends MediaBase {
  final int? seasonCount;
  final int? episodeCount;
  final List<SeasonModel> seasons;
  final int? endYear;
  final String status;

  const SeriesDetails({
    required super.id,
    required super.imdbId,
    required super.title,
    super.posterUrl,
    super.backdropUrl,
    super.overview,
    super.releaseYear,
    super.imdbRating,
    super.genres,
    super.country,
    super.cast = const [],
    this.seasonCount,
    this.episodeCount,
    this.seasons = const [],
    this.endYear,
    required this.status
  }) : super(mediaType: MediaType.series);

  factory SeriesDetails.fromJson(Map<String, dynamic> json) {
    return SeriesDetails(
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
      seasonCount: json['season_count'],
      episodeCount: json['episode_count'],
      seasons: (json['seasons'] as List<dynamic>?)
          ?.map((e) => SeasonModel.fromJson(e))
          .toList() ??
          const [],
      endYear: json['end_year'],
      status: json['status'] ?? false,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'season_count': seasonCount,
    'episode_count': episodeCount,
    'seasons': seasons.map((e) => e.toJson()).toList(),
    'end_year': endYear,
    'status': status,
  };
}