import 'package:dio/dio.dart';

import '../../models/common.dart';
import '../../models/movie.dart';
import '../../models/series.dart';
import '../../models/user_content.dart';
import '../../models/report.dart';
// import '../../models/common/top_media_list_response.dart';
// import '../../models/common/top_media_query.dart';

import 'api_client.dart';
import 'error_handler.dart';


class MediaService {
  final ApiClient _apiClient;
  final _baseEndpoint = '/media';

  MediaService(this._apiClient);

  Future<MediaSearchResult> searchMedia({
    required String query,
    int page = 1,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        '$_baseEndpoint/search',
        queryParameters: {
          'query': query,
          'page': page,
        },
      );

      if (response.statusCode == 200) {
        return MediaSearchResult.fromJson(response.data);
      }
      throw ErrorHandler.handleError(response);
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  Future<List<MediaBase>> getTrending({
    String mediaType = 'all',
    String timeWindow = 'week',
  }) async {
    try {
      final response = await _apiClient.dio.get(
        '$_baseEndpoint/trending',
        queryParameters: {
          'media_type': mediaType,
          'time_window': timeWindow,
        },
      );

      if (response.statusCode == 200) {
        return (response.data as List)
            .map((e) => MediaBase.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw ErrorHandler.handleError(response);
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  Future<List<MediaBase>> getPopularMovies({int page = 1}) async {
    try {
      final response = await _apiClient.dio.get(
        '$_baseEndpoint/popular/movies',
        queryParameters: {'page': page},
      );

      if (response.statusCode == 200) {
        return (response.data as List)
            .map((e) => MediaBase.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw ErrorHandler.handleError(response);
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  Future<List<MediaBase>> getPopularSeries({int page = 1}) async {
    try {
      final response = await _apiClient.dio.get(
        '$_baseEndpoint/popular/series',
        queryParameters: {'page': page},
      );

      if (response.statusCode == 200) {
        return (response.data as List)
            .map((e) => MediaBase.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw ErrorHandler.handleError(response);
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// Get top-rated movies (paginated)
  Future<TopMediaListResponse> getTopMovies({
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        '$_baseEndpoint/movies/top',
        queryParameters: {
          'page': page,
          'per_page': perPage,
        },
      );

      if (response.statusCode == 200) {
        return TopMediaListResponse.fromJson(response.data);
      }
      throw ErrorHandler.handleError(response);
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// Get top-rated series (paginated)
  Future<TopMediaListResponse> getTopSeries({
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        '$_baseEndpoint/series/top',
        queryParameters: {
          'page': page,
          'per_page': perPage,
        },
      );

      if (response.statusCode == 200) {
        return TopMediaListResponse.fromJson(response.data);
      }
      throw ErrorHandler.handleError(response);
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  Future<MovieDetails> getMovieDetails(int tmdbId) async {
    try {
      final response = await _apiClient.dio.get('$_baseEndpoint/movies/$tmdbId');

      if (response.statusCode == 200) {
        return MovieDetails.fromJson(response.data);
      }
      throw ErrorHandler.handleError(response);
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  Future<SeriesDetails> getSeriesDetails(int tmdbId) async {
    try {
      final response = await _apiClient.dio.get('$_baseEndpoint/series/$tmdbId');

      if (response.statusCode == 200) {
        return SeriesDetails.fromJson(response.data);
      }
      throw ErrorHandler.handleError(response);
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  Future<Season> getSeasonDetails(int tmdbId, int seasonNumber) async {
    try {
      final response = await _apiClient.dio.get(
        '$_baseEndpoint/series/$tmdbId/season/$seasonNumber',
      );

      if (response.statusCode == 200) {
        return Season.fromJson(response.data);
      }
      throw ErrorHandler.handleError(response);
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  Future<Episode> getEpisodeDetails(
    int tmdbId,
    int seasonNumber,
    int episodeNumber,
  ) async {
    try {
      final response = await _apiClient.dio.get(
        '$_baseEndpoint/series/$tmdbId/season/$seasonNumber/episode/$episodeNumber',
      );

      if (response.statusCode == 200) {
        return Episode.fromJson(response.data);
      }
      throw ErrorHandler.handleError(response);
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  Future<LikeToggleResponse> toggleLike({
    required String tmdbId,
    required String mediaType,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '$_baseEndpoint/$mediaType/$tmdbId/like',
      );

      if (response.statusCode == 200) {
        return LikeToggleResponse.fromJson(response.data);
      }
      throw ErrorHandler.handleError(response);
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  Future<RatingResponse> rateMedia({
    required String tmdbId,
    required String mediaType,
    required double rating,
  }) async {
    try {
      final request = RatingCreate(rating: rating);
      final response = await _apiClient.dio.post(
        '$_baseEndpoint/$mediaType/$tmdbId/rating',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        return RatingResponse.fromJson(response.data);
      }
      throw ErrorHandler.handleError(response);
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  Future<ReviewResponse> createReview({
    required String tmdbId,
    required String mediaType,
    required String review,
    required bool containsSpoiler,
  }) async {
    try {
      final request = ReviewCreate(
        review: review,
        containsSpoiler: containsSpoiler,
      );
      final response = await _apiClient.dio.post(
        '$_baseEndpoint/$mediaType/$tmdbId/reviews',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        return ReviewResponse.fromJson(response.data);
      }
      throw ErrorHandler.handleError(response);
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  Future<List<ReviewResponse>> getReviews({
    required String tmdbId,
    required String mediaType,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        '$_baseEndpoint/$mediaType/$tmdbId/reviews',
        queryParameters: {
          'page': page,
          'per_page': perPage,
        },
      );

      if (response.statusCode == 200) {
        return (response.data as List)
            .map((e) => ReviewResponse.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw ErrorHandler.handleError(response);
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  Future<ReportResponse> reportMedia({
    required String tmdbId,
    required String mediaType,
    required ReportCreate request,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '$_baseEndpoint/$mediaType/$tmdbId/report',
        data: request.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ReportResponse.fromJson(response.data);
      }
      throw ErrorHandler.handleError(response);
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }
}