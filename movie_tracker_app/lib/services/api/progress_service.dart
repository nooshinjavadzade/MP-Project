import 'package:dio/dio.dart';

import '../../../../models/user_content/movie_progress_create.dart';
import '../../../../models/user_content/movie_progress_response.dart';
import '../../../../models/user_content/episode_progress_create.dart';
import '../../../../models/user_content/episode_progress_update.dart';
import '../../../../models/user_content/episode_progress_update_response.dart';
import '../../../../models/user_content/series_progress_response.dart';
import '../../../../models/user_content/watch_status.dart';
import '../local/local_storage_service.dart';

import 'api_client.dart';
import 'error_handler.dart';


class ProgressService {
  final ApiClient _apiClient;
  final LocalStorageService? _localStorageService;
  final _baseEndpoint = '/progress';

  ProgressService(this._apiClient, [this._localStorageService]);

  /// Movie progress endpoints

  /// Create or update movie watch progress (status + progress 0-100%)
  Future<MovieProgressResponse> upsertMovieProgress({
    required int tmdbId,
    required MovieProgressCreate progressCreate,
  }) async {
    await _localStorageService?.setMediaWatchStatus(
      tmdbId.toString(),
      progressCreate.status.value,
    );

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
      await _localStorageService?.addOrUpdatePendingAction({
        'action_type': 'upsert_movie_progress',
        'target_id': tmdbId.toString(),
        'payload': progressCreate.toJson(),
      });
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// Get movie progress for current user
  Future<MovieProgressResponse> getMovieProgress(int tmdbId) async {
    try {
      final response = await _apiClient.dio.get('$_baseEndpoint/movies/$tmdbId');

      if (response.statusCode == 200) {
        final result = MovieProgressResponse.fromJson(response.data);
        if (result.status != null) {
          await _localStorageService?.setMediaWatchStatus(
            tmdbId.toString(),
            result.status!.value,
          );
        }
        return result;
      }
      throw ErrorHandler.handleError(response);
    } on DioException catch (e) {
      final cachedStatusStr = _localStorageService?.getMediaWatchStatus(tmdbId.toString());
      if (cachedStatusStr != null) {
        final cachedStatus = WatchStatusExtension.fromString(cachedStatusStr);
        return MovieProgressResponse(
          id: 0,
          userId: 0,
          mediaId: tmdbId,
          status: cachedStatus,
          progress: cachedStatus == WatchStatus.completed ? 100.0 : 0.0,
          watchedEpisodes: 0,
          createdAt: DateTime.now(),
        );
      }
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// Series progress endpoints

  /// Create or update single episode progress
  Future<EpisodeProgressUpdateResponse> upsertEpisodeProgress({
    required int tmdbId,
    required EpisodeProgressCreate progressCreate,
  }) async {
    final episodeKey = '${progressCreate.seasonNumber}_${progressCreate.episodeNumber}';
    final isWatched = progressCreate.status == WatchStatus.completed;
    await _localStorageService?.setEpisodeWatched(
      tmdbId.toString(),
      episodeKey,
      isWatched,
    );

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
      await _localStorageService?.addOrUpdatePendingAction({
        'action_type': 'upsert_episode_progress',
        'target_id': tmdbId.toString(),
        'payload': progressCreate.toJson(),
      });
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// Get aggregated series progress for current user
  Future<SeriesProgressResponse> getSeriesProgress(int tmdbId) async {
    try {
      final response = await _apiClient.dio.get('$_baseEndpoint/series/$tmdbId');

      if (response.statusCode == 200) {
        final result = SeriesProgressResponse.fromJson(response.data);
        await _localStorageService?.setMediaWatchStatus(
          tmdbId.toString(),
          result.status.value,
        );
        return result;
      }
      throw ErrorHandler.handleError(response);
    } on DioException catch (e) {
      final cachedWatched = _localStorageService?.getWatchedEpisodes(tmdbId.toString()) ?? [];
      final cachedStatusStr = _localStorageService?.getMediaWatchStatus(tmdbId.toString());
      if (cachedStatusStr != null || cachedWatched.isNotEmpty) {
        final status = cachedStatusStr != null
            ? WatchStatusExtension.fromString(cachedStatusStr)
            : WatchStatus.watching;
        return SeriesProgressResponse(
          mediaId: tmdbId,
          title: '',
          totalEpisodes: cachedWatched.length,
          watchedEpisodes: cachedWatched.length,
          completionPct: 0.0,
          status: status,
        );
      }
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
    if (progressUpdate.status != null) {
      final episodeKey = '${seasonNumber}_$episodeNumber';
      final isWatched = progressUpdate.status == WatchStatus.completed;
      await _localStorageService?.setEpisodeWatched(
        tmdbId.toString(),
        episodeKey,
        isWatched,
      );
    }

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
      await _localStorageService?.addOrUpdatePendingAction({
        'action_type': 'update_episode_progress',
        'target_id': tmdbId.toString(),
        'season_number': seasonNumber,
        'episode_number': episodeNumber,
        'payload': progressUpdate.toJson(),
      });
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