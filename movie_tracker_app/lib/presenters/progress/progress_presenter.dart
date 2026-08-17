import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../models/user_content.dart';
import '../../services/api/progress_service.dart';
import '../../services/local/local_storage_service.dart';
import 'i_progress_presenter.dart';

class ProgressPresenter extends ChangeNotifier implements IProgressPresenter {
  final ProgressService _progressService;
  final LocalStorageService? _localStorageService;

  bool _isLoading = false;
  String? _errorMessage;

  MovieProgressResponse? _movieProgress;
  SeriesProgressResponse? _seriesProgress;
  EpisodeProgressUpdateResponse? _episodeProgress;

  ProgressPresenter(this._progressService, [this._localStorageService]);

  @override
  bool get isLoading => _isLoading;

  @override
  String? get errorMessage => _errorMessage;

  @override
  MovieProgressResponse? get movieProgress => _movieProgress;

  @override
  SeriesProgressResponse? get seriesProgress => _seriesProgress;

  @override
  EpisodeProgressUpdateResponse? get episodeProgress => _episodeProgress;

  @override
  Future<MovieProgressResponse?> upsertMovieProgress({
    required int tmdbId,
    required WatchStatus status,
    double progress = 0.0,
  }) async {
    _setLoading(true);
    final request = MovieProgressCreate(status: status, progress: progress);

    await _localStorageService?.setMediaWatchStatus(
      tmdbId.toString(),
      status.value,
    );

    try {
      _movieProgress = await _progressService.upsertMovieProgress(
        tmdbId: tmdbId,
        progressCreate: request,
      );
      _errorMessage = null;
      return _movieProgress;
    } catch (e) {
      if (e is DioException) {
        await _localStorageService?.addOrUpdatePendingAction({
          'action_type': 'upsert_movie_progress',
          'target_id': tmdbId.toString(),
          'payload': request.toJson(),
        });
      }
      _errorMessage = e.toString();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  @override
  Future<MovieProgressResponse?> getMovieProgress(int tmdbId) async {
    _setLoading(true);
    try {
      final result = await _progressService.getMovieProgress(tmdbId);
      if (result.status != null) {
        await _localStorageService?.setMediaWatchStatus(
          tmdbId.toString(),
          result.status!.value,
        );
      }
      _movieProgress = result;
      _errorMessage = null;
      return result;
    } catch (e) {
      final cachedStatusStr = _localStorageService?.getMediaWatchStatus(tmdbId.toString());
      if (cachedStatusStr != null) {
        final cachedStatus = WatchStatusExtension.fromString(cachedStatusStr);
        _movieProgress = MovieProgressResponse(
          id: 0,
          userId: 0,
          mediaId: tmdbId,
          status: cachedStatus,
          progress: cachedStatus == WatchStatus.completed ? 100.0 : 0.0,
          watchedEpisodes: 0,
          createdAt: DateTime.now(),
        );
        _errorMessage = null;
        return _movieProgress;
      } else {
        _errorMessage = e.toString();
        return null;
      }
    } finally {
      _setLoading(false);
    }
  }

  @override
  Future<EpisodeProgressUpdateResponse?> upsertEpisodeProgress({
    required int tmdbId,
    required int seasonNumber,
    required int episodeNumber,
    required WatchStatus status,
  }) async {
    _setLoading(true);
    final request = EpisodeProgressCreate(
      seasonNumber: seasonNumber,
      episodeNumber: episodeNumber,
      status: status,
    );
    final episodeKey = '${seasonNumber}_$episodeNumber';
    final isWatched = status == WatchStatus.completed;

    await _localStorageService?.setEpisodeWatched(
      tmdbId.toString(),
      episodeKey,
      isWatched,
    );

    try {
      _episodeProgress = await _progressService.upsertEpisodeProgress(
        tmdbId: tmdbId,
        progressCreate: request,
      );
      _errorMessage = null;
      return _episodeProgress;
    } catch (e) {
      if (e is DioException) {
        await _localStorageService?.addOrUpdatePendingAction({
          'action_type': 'upsert_episode_progress',
          'target_id': tmdbId.toString(),
          'payload': request.toJson(),
        });
      }
      _errorMessage = e.toString();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  @override
  Future<SeriesProgressResponse?> getSeriesProgress(int tmdbId) async {
    _setLoading(true);
    try {
      final result = await _progressService.getSeriesProgress(tmdbId);
      await _localStorageService?.setMediaWatchStatus(
        tmdbId.toString(),
        result.status.value,
      );
      _seriesProgress = result;
      _errorMessage = null;
      return result;
    } catch (e) {
      final cachedWatched = _localStorageService?.getWatchedEpisodes(tmdbId.toString()) ?? [];
      final cachedStatusStr = _localStorageService?.getMediaWatchStatus(tmdbId.toString());
      if (cachedStatusStr != null || cachedWatched.isNotEmpty) {
        final status = cachedStatusStr != null
            ? WatchStatusExtension.fromString(cachedStatusStr)
            : WatchStatus.watching;
        _seriesProgress = SeriesProgressResponse(
          mediaId: tmdbId,
          title: '',
          totalEpisodes: cachedWatched.length, // Not completely accurate but best fallback
          watchedEpisodes: cachedWatched.length,
          completionPct: 0.0,
          status: status,
        );
        _errorMessage = null;
        return _seriesProgress;
      } else {
        _errorMessage = e.toString();
        return null;
      }
    } finally {
      _setLoading(false);
    }
  }

  @override
  Future<EpisodeProgressUpdateResponse?> updateEpisodeProgress({
    required int tmdbId,
    required int seasonNumber,
    required int episodeNumber,
    WatchStatus? status,
  }) async {
    _setLoading(true);
    final request = EpisodeProgressUpdate(status: status);

    if (status != null) {
      final episodeKey = '${seasonNumber}_$episodeNumber';
      final isWatched = status == WatchStatus.completed;
      await _localStorageService?.setEpisodeWatched(
        tmdbId.toString(),
        episodeKey,
        isWatched,
      );
    }

    try {
      _episodeProgress = await _progressService.updateEpisodeProgress(
        tmdbId: tmdbId,
        seasonNumber: seasonNumber,
        episodeNumber: episodeNumber,
        progressUpdate: request,
      );
      _errorMessage = null;
      return _episodeProgress;
    } catch (e) {
      if (e is DioException) {
        await _localStorageService?.addOrUpdatePendingAction({
          'action_type': 'update_episode_progress',
          'target_id': tmdbId.toString(),
          'season_number': seasonNumber,
          'episode_number': episodeNumber,
          'payload': request.toJson(),
        });
      }
      _errorMessage = e.toString();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  @override
  Future<EpisodeProgressUpdateResponse?> getEpisodeProgress({
    required int tmdbId,
    required int seasonNumber,
    required int episodeNumber,
  }) async {
    _setLoading(true);
    try {
      _episodeProgress = await _progressService.getEpisodeProgress(
        tmdbId: tmdbId,
        seasonNumber: seasonNumber,
        episodeNumber: episodeNumber,
      );
      _errorMessage = null;
      return _episodeProgress;
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  @override
  double calculateCompletionPercentage(int watchedEpisodes, int totalEpisodes) {
    if (totalEpisodes <= 0) return 0.0;
    final pct = (watchedEpisodes / totalEpisodes) * 100.0;
    return pct.clamp(0.0, 100.0);
  }

  @override
  Color getProgressColor({
    required WatchStatus status,
    required int watchedEpisodes,
    required int totalEpisodes,
    bool isSeriesEnded = false,
  }) {
    if (status == WatchStatus.dropped) {
      return const Color(0xFFE53935);
    }

    if (totalEpisodes > 0 && watchedEpisodes >= totalEpisodes) {
      if (isSeriesEnded) {
        return const Color(0xFF8E24AA);
      }
      return const Color(0xFF4CAF50); // Green
    }

    if (watchedEpisodes > 0 && watchedEpisodes < totalEpisodes) {
      return const Color(0xFFFFB300); // Yellow
    }

    return Colors.transparent;
  }

  void _setLoading(bool value) {
    // Avoid notifying during build
    _isLoading = value;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }
}
