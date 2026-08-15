import 'package:flutter/material.dart';
import '../../models/user_content.dart';

abstract class IProgressPresenter {
  bool get isLoading;
  String? get errorMessage;

  MovieProgressResponse? get movieProgress;
  SeriesProgressResponse? get seriesProgress;
  EpisodeProgressUpdateResponse? get episodeProgress;

  Future<void> upsertMovieProgress({
    required int tmdbId,
    required WatchStatus status,
    double progress = 0.0,
  });

  Future<void> getMovieProgress(int tmdbId);

  Future<void> upsertEpisodeProgress({
    required int tmdbId,
    required int seasonNumber,
    required int episodeNumber,
    required WatchStatus status,
  });

  Future<void> getSeriesProgress(int tmdbId);

  Future<void> updateEpisodeProgress({
    required int tmdbId,
    required int seasonNumber,
    required int episodeNumber,
    WatchStatus? status,
  });

  Future<void> getEpisodeProgress({
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