import 'package:dio/dio.dart';

import '../../../../models/user_content/movie_progress_create.dart';
import '../../../../models/user_content/movie_progress_response.dart';
import '../../../../models/user_content/episode_progress_create.dart';
import '../../../../models/user_content/episode_progress_update.dart';
import '../../../../models/user_content/episode_progress_update_response.dart';
import '../../../../models/user_content/series_progress_response.dart';

import 'api_client.dart';
import 'error_handler.dart';


class ProgressService {
  final ApiClient _apiClient;
  final _baseEndpoint = '/progress';

  ProgressService(this._apiClient);

  /// Movie progress endpoints

  /// Create or update movie watch progress (status + progress 0-100%)
  Future<MovieProgressResponse> upsertMovieProgress({
    required int tmdbId,
    required MovieProgressCreate progressCreate,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '$_baseEndpoint/movies/$tmdbId',
        data: progressCreate.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return MovieProgressResponse.fromJson(response.data);
      }
      throw ErrorHandler.handleError(response);
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// Get movie progress for current user
  Future<MovieProgressResponse> getMovieProgress(int tmdbId) async {
    try {
      final response = await _apiClient.dio.get('$_baseEndpoint/movies/$tmdbId');

      if (response.statusCode == 200) {
        return MovieProgressResponse.fromJson(response.data);
      }
      throw ErrorHandler.handleError(response);
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// Series progress endpoints

  /// Create or update single episode progress
  Future<EpisodeProgressUpdateResponse> upsertEpisodeProgress({
    required int tmdbId,
    required EpisodeProgressCreate progressCreate,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '$_baseEndpoint/series/$tmdbId/episodes',
        data: progressCreate.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return EpisodeProgressUpdateResponse.fromJson(response.data);
      }
      throw ErrorHandler.handleError(response);
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// Get aggregated series progress for current user
  Future<SeriesProgressResponse> getSeriesProgress(int tmdbId) async {
    try {
      final response = await _apiClient.dio.get('$_baseEndpoint/series/$tmdbId');

      if (response.statusCode == 200) {
        return SeriesProgressResponse.fromJson(response.data);
      }
      throw ErrorHandler.handleError(response);
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// Update single episode progress
  Future<EpisodeProgressUpdateResponse> updateEpisodeProgress({
    required int tmdbId,
    required int seasonNumber,
    required int episodeNumber,
    required EpisodeProgressUpdate progressUpdate,
  }) async {
    try {
      final response = await _apiClient.dio.patch(
        '$_baseEndpoint/series/$tmdbId/episodes/$seasonNumber/$episodeNumber',
        data: progressUpdate.toJson(),
      );

      if (response.statusCode == 200) {
        return EpisodeProgressUpdateResponse.fromJson(response.data);
      }
      throw ErrorHandler.handleError(response);
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// Get single episode progress
  Future<EpisodeProgressUpdateResponse> getEpisodeProgress({
    required int tmdbId,
    required int seasonNumber,
    required int episodeNumber,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        '$_baseEndpoint/series/$tmdbId/episodes/$seasonNumber/$episodeNumber',
      );

      if (response.statusCode == 200) {
        return EpisodeProgressUpdateResponse.fromJson(response.data);
      }
      throw ErrorHandler.handleError(response);
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }
}