import 'package:flutter/foundation.dart';

import '../../models/user_content.dart';
import '../../services/api/progress_service.dart';
import 'i_progress_presenter.dart';

class ProgressPresenter extends ChangeNotifier implements IProgressPresenter {
  final ProgressService _progressService;

  bool _isLoading = false;
  String? _errorMessage;

  MovieProgressResponse? _movieProgress;
  SeriesProgressResponse? _seriesProgress;
  EpisodeProgressUpdateResponse? _episodeProgress;

  ProgressPresenter(this._progressService);

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
  Future<void> upsertMovieProgress({
    required int tmdbId,
    required WatchStatus status,
    double progress = 0.0,
  }) async {
    _setLoading(true);
    try {
      final request = MovieProgressCreate(
        status: status,
        progress: progress,
      );
      _movieProgress = await _progressService.upsertMovieProgress(
        tmdbId: tmdbId,
        progressCreate: request,
      );
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  @override
  Future<void> getMovieProgress(int tmdbId) async {
    _setLoading(true);
    try {
      _movieProgress = await _progressService.getMovieProgress(tmdbId);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  @override
  Future<void> upsertEpisodeProgress({
    required int tmdbId,
    required int seasonNumber,
    required int episodeNumber,
    required WatchStatus status,
  }) async {
    _setLoading(true);
    try {
      final request = EpisodeProgressCreate(
        seasonNumber: seasonNumber,
        episodeNumber: episodeNumber,
        status: status,
      );
      _episodeProgress = await _progressService.upsertEpisodeProgress(
        tmdbId: tmdbId,
        progressCreate: request,
      );
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  @override
  Future<void> getSeriesProgress(int tmdbId) async {
    _setLoading(true);
    try {
      _seriesProgress = await _progressService.getSeriesProgress(tmdbId);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  @override
  Future<void> updateEpisodeProgress({
    required int tmdbId,
    required int seasonNumber,
    required int episodeNumber,
    WatchStatus? status,
  }) async {
    _setLoading(true);
    try {
      final request = EpisodeProgressUpdate(status: status);
      _episodeProgress = await _progressService.updateEpisodeProgress(
        tmdbId: tmdbId,
        seasonNumber: seasonNumber,
        episodeNumber: episodeNumber,
        progressUpdate: request,
      );
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  @override
  Future<void> getEpisodeProgress({
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
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}