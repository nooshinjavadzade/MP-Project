import 'dart:ui';
import '../../models/user_content.dart';

abstract class IProgressPresenter {
  bool get isLoading;
  String? get errorMessage;
  MovieProgressResponse? get movieProgress;
  SeriesProgressResponse? get seriesProgress;
  EpisodeProgressUpdateResponse? get episodeProgress;

  Future<MovieProgressResponse?> upsertMovieProgress({
    required int tmdbId,
    required WatchStatus status,
    double progress = 0.0,
  });

  Future<MovieProgressResponse?> getMovieProgress(int tmdbId);

  Future<EpisodeProgressUpdateResponse?> upsertEpisodeProgress({
    required int tmdbId,
    required int seasonNumber,
    required int episodeNumber,
    required WatchStatus status,
  });

  Future<SeriesProgressResponse?> getSeriesProgress(int tmdbId);

  Future<EpisodeProgressUpdateResponse?> updateEpisodeProgress({
    required int tmdbId,
    required int seasonNumber,
    required int episodeNumber,
    WatchStatus? status,
  });

  Future<EpisodeProgressUpdateResponse?> getEpisodeProgress({
    required int tmdbId,
    required int seasonNumber,
    required int episodeNumber,
  });

  double calculateCompletionPercentage(int watchedEpisodes, int totalEpisodes);

  Color getProgressColor({
    required WatchStatus status,
    required int watchedEpisodes,
    required int totalEpisodes,
    bool isSeriesEnded = false,
  });
}
