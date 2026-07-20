import '../common/pagination.dart';
import 'movie_model.dart';

class MovieSearchResult {
  final List<MovieModel> movies;
  final Pagination pagination;

  const MovieSearchResult({
    required this.movies,
    required this.pagination,
  });

  factory MovieSearchResult.fromJson(Map<String, dynamic> json) {
    return MovieSearchResult(
      movies: (json['results'] as List<dynamic>)
          .map((e) => MovieModel.fromJson(e))
          .toList(),
      pagination: Pagination.fromJson(json['pagination']),
    );
  }

  Map<String, dynamic> toJson() => {
    'results': movies.map((e) => e.toJson()).toList(),
    'pagination': pagination.toJson(),
  };
}