abstract class MediaBase {
  final int id;
  final String imdbId;
  final String title;
  final String? posterUrl;
  final String? backdropUrl;
  final String? overview;
  final int? releaseYear;
  final double? imdbRating;
  final List<String> genres;

  const MediaBase({
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
}