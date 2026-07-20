import 'movie_details.dart';
import '../common/cast_member.dart';

class SeriesDetails extends MovieDetails {
  final int? nSeasons;
  final int? nEpisodes;

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
    super.isFinished = false,
    this.nSeasons,
    this.nEpisodes
  });

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
      isFinished: json['is_adult'] ?? false,
      nSeasons: json['nSeasons'],
      nEpisodes: json['nEpisodes']
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'nSeasons': nSeasons,
    'nEpisodes': nEpisodes
  };
}