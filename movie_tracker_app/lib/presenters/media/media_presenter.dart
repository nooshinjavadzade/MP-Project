import 'package:flutter/foundation.dart';
import '../../models/common.dart';
import '../../models/movie.dart';
import '../../models/series.dart';
import '../../models/user_content.dart';
import '../../services/api/media_service.dart';
import '../../services/local/local_storage_service.dart';
import 'i_media_presenter.dart';

class MediaPresenter extends ChangeNotifier implements IMediaPresenter {
  final MediaService _mediaService;
  final LocalStorageService? _localStorageService;

  bool _isLoading = false;
  String? _errorMessage;

  MediaSearchResult? _searchResult;
  List<MediaBase> _trendingItems = [];
  List<MediaBase> _popularMovies = [];
  List<MediaBase> _popularSeries = [];
  MovieDetails? _movieDetails;
  SeriesDetails? _seriesDetails;
  Season? _seasonDetails;
  Episode? _episodeDetails;
  LikeToggleResponse? _lastLikeResponse;
  RatingResponse? _lastRatingResponse;
  ReviewResponse? _lastCreatedReview;
  List<ReviewResponse> _reviews = [];

  MediaPresenter(this._mediaService, [this._localStorageService]);

  @override
  bool get isLoading => _isLoading;

  @override
  String? get errorMessage => _errorMessage;

  @override
  MediaSearchResult? get searchResult => _searchResult;

  @override
  List<MediaBase> get trendingItems => _trendingItems;

  @override
  List<MediaBase> get popularMovies => _popularMovies;

  @override
  List<MediaBase> get popularSeries => _popularSeries;

  @override
  MovieDetails? get movieDetails => _movieDetails;

  @override
  SeriesDetails? get seriesDetails => _seriesDetails;

  @override
  Season? get seasonDetails => _seasonDetails;

  @override
  Episode? get episodeDetails => _episodeDetails;

  @override
  LikeToggleResponse? get lastLikeResponse => _lastLikeResponse;

  @override
  RatingResponse? get lastRatingResponse => _lastRatingResponse;

  @override
  ReviewResponse? get lastCreatedReview => _lastCreatedReview;

  @override
  List<ReviewResponse> get reviews => _reviews;

  void _prefetchPosters(List<MediaBase> items) {
    for (final item in items) {
      if (item.posterUrl != null) {
        _localStorageService?.prefetchImage(item.posterUrl!);
      }
    }
  }

  @override
  Future<void> searchMedia(String query, {int page = 1}) async {
    _setLoading(true);
    final trimmedQuery = query.trim();
    if (trimmedQuery.isNotEmpty) {
      await _localStorageService?.addSearchQuery(trimmedQuery);
    }
    try {
      final result = await _mediaService.searchMedia(query: query, page: page);
      _prefetchPosters(result.items);
      _searchResult = result;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  @override
  Future<void> getTrending({String mediaType = 'all', String timeWindow = 'week'}) async {
    _setLoading(true);
    final cacheKey = 'cached_trending_${mediaType}_$timeWindow';

    final freshCachedItems = _localStorageService?.getMediaList(cacheKey, checkTtl: true) ?? [];
    if (freshCachedItems.isNotEmpty) {
      _trendingItems = freshCachedItems;
      _errorMessage = null;
      _setLoading(false);
      return;
    }

    try {
      final items = await _mediaService.getTrending(mediaType: mediaType, timeWindow: timeWindow);
      _prefetchPosters(items);
      await _localStorageService?.saveMediaList(cacheKey, items);
      _trendingItems = items;
      _errorMessage = null;
    } catch (e) {
      final staleItems = _localStorageService?.getMediaList(cacheKey, checkTtl: false) ?? [];
      if (staleItems.isNotEmpty) {
        _trendingItems = staleItems;
        _errorMessage = null;
      } else {
        _errorMessage = e.toString();
      }
    } finally {
      _setLoading(false);
    }
  }

  @override
  Future<void> getPopularMovies({int page = 1}) async {
    _setLoading(true);
    final cacheKey = 'cached_popular_movies_page_$page';

    if (page == 1) {
      final freshCachedItems = _localStorageService?.getMediaList(cacheKey, checkTtl: true) ?? [];
      if (freshCachedItems.isNotEmpty) {
        _popularMovies = freshCachedItems;
        _errorMessage = null;
        _setLoading(false);
        return;
      }
    }

    try {
      final items = await _mediaService.getPopularMovies(page: page);
      _prefetchPosters(items);
      if (page == 1) {
        await _localStorageService?.saveMediaList(cacheKey, items);
      }
      _popularMovies = items;
      _errorMessage = null;
    } catch (e) {
      if (page == 1) {
        final staleItems = _localStorageService?.getMediaList(cacheKey, checkTtl: false) ?? [];
        if (staleItems.isNotEmpty) {
          _popularMovies = staleItems;
          _errorMessage = null;
          _setLoading(false);
          return;
        }
      }
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  @override
  Future<void> getPopularSeries({int page = 1}) async {
    _setLoading(true);
    final cacheKey = 'cached_popular_series_page_$page';

    if (page == 1) {
      final freshCachedItems = _localStorageService?.getMediaList(cacheKey, checkTtl: true) ?? [];
      if (freshCachedItems.isNotEmpty) {
        _popularSeries = freshCachedItems;
        _errorMessage = null;
        _setLoading(false);
        return;
      }
    }

    try {
      final items = await _mediaService.getPopularSeries(page: page);
      _prefetchPosters(items);
      if (page == 1) {
        await _localStorageService?.saveMediaList(cacheKey, items);
      }
      _popularSeries = items;
      _errorMessage = null;
    } catch (e) {
      if (page == 1) {
        final staleItems = _localStorageService?.getMediaList(cacheKey, checkTtl: false) ?? [];
        if (staleItems.isNotEmpty) {
          _popularSeries = staleItems;
          _errorMessage = null;
          _setLoading(false);
          return;
        }
      }
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> getTopMovies({int page = 1, int perPage = 20}) async {
    _setLoading(true);

    if (page == 1) {
      final freshCachedItems = _localStorageService?.getHomeSection('top_movies', checkTtl: true) ?? [];
      if (freshCachedItems.isNotEmpty) {
        _errorMessage = null;
        _setLoading(false);
        return;
      }
    }

    try {
      final result = await _mediaService.getTopMovies(page: page, perPage: perPage);
      if (page == 1) {
        await _localStorageService?.saveHomeSection('top_movies', result.items);
      }
      for (final item in result.items) {
        if (item.media.posterUrl != null) {
          _localStorageService?.prefetchImage(item.media.posterUrl!);
        }
      }
      _errorMessage = null;
    } catch (e) {
      if (page == 1) {
        final staleItems = _localStorageService?.getHomeSection('top_movies', checkTtl: false);
        if (staleItems != null && staleItems.isNotEmpty) {
          _errorMessage = null;
          _setLoading(false);
          return;
        }
      }
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> getTopSeries({int page = 1, int perPage = 20}) async {
    _setLoading(true);

    if (page == 1) {
      final freshCachedItems = _localStorageService?.getHomeSection('top_series', checkTtl: true) ?? [];
      if (freshCachedItems.isNotEmpty) {
        _errorMessage = null;
        _setLoading(false);
        return;
      }
    }

    try {
      final result = await _mediaService.getTopSeries(page: page, perPage: perPage);
      if (page == 1) {
        await _localStorageService?.saveHomeSection('top_series', result.items);
      }
      for (final item in result.items) {
        if (item.media.posterUrl != null) {
          _localStorageService?.prefetchImage(item.media.posterUrl!);
        }
      }
      _errorMessage = null;
    } catch (e) {
      if (page == 1) {
        final staleItems = _localStorageService?.getHomeSection('top_series', checkTtl: false);
        if (staleItems != null && staleItems.isNotEmpty) {
          _errorMessage = null;
          _setLoading(false);
          return;
        }
      }
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  @override
  Future<void> getMovieDetails(int tmdbId) async {
    _setLoading(true);

    final freshCached = _localStorageService?.getMovieDetails(tmdbId.toString(), checkTtl: true);
    if (freshCached != null) {
      _movieDetails = freshCached;
      _errorMessage = null;
      _setLoading(false);
      return;
    }

    try {
      final details = await _mediaService.getMovieDetails(tmdbId);
      await _localStorageService?.saveMovieDetails(tmdbId.toString(), details);
      if (details.posterUrl != null) {
        _localStorageService?.prefetchImage(details.posterUrl!);
      }
      if (details.backdropUrl != null) {
        _localStorageService?.prefetchImage(details.backdropUrl!);
      }
      _movieDetails = details;
      _errorMessage = null;
    } catch (e) {
      final staleCached = _localStorageService?.getMovieDetails(tmdbId.toString(), checkTtl: false);
      if (staleCached != null) {
        _movieDetails = staleCached;
        _errorMessage = null;
      } else {
        _errorMessage = e.toString();
      }
    } finally {
      _setLoading(false);
    }
  }

  @override
  Future<void> getSeriesDetails(int tmdbId) async {
    _setLoading(true);

    final freshCached = _localStorageService?.getSeriesDetails(tmdbId.toString(), checkTtl: true);
    if (freshCached != null) {
      _seriesDetails = freshCached;
      _errorMessage = null;
      _setLoading(false);
      return;
    }

    try {
      final details = await _mediaService.getSeriesDetails(tmdbId);
      await _localStorageService?.saveSeriesDetails(tmdbId.toString(), details);
      if (details.posterUrl != null) {
        _localStorageService?.prefetchImage(details.posterUrl!);
      }
      if (details.backdropUrl != null) {
        _localStorageService?.prefetchImage(details.backdropUrl!);
      }
      _seriesDetails = details;
      _errorMessage = null;

      debugPrint('=== [Presenter.getSeriesDetails] seasons parsed: ${details.seasons.length} ===');
      for (final s in details.seasons) {
        debugPrint('  -> season ${s.seasonNumber} "${s.title}" episodes: ${s.episodes.length}');
      }
    } catch (e, stack) {
      debugPrint('=== [Presenter.getSeriesDetails] ERROR: $e ===');
      debugPrint(stack.toString());

      final staleCached = _localStorageService?.getSeriesDetails(tmdbId.toString(), checkTtl: false);
      if (staleCached != null) {
        _seriesDetails = staleCached;
        _errorMessage = null;
      } else {
        _errorMessage = e.toString();
      }
    } finally {
      _setLoading(false);
    }
  }

  @override
  Future<void> getSeasonDetails(int tmdbId, int seasonNumber) async {
    _setLoading(true);

    final freshCachedEpisodes = _localStorageService?.getSeasonEpisodes(tmdbId.toString(), seasonNumber, checkTtl: true);
    if (freshCachedEpisodes != null && freshCachedEpisodes.isNotEmpty) {
      final episodes = freshCachedEpisodes.map((e) => Episode.fromJson(e)).toList();
      _seasonDetails = Season(seasonNumber: seasonNumber, episodes: episodes);
      _errorMessage = null;
      _setLoading(false);
      return;
    }

    try {
      final season = await _mediaService.getSeasonDetails(tmdbId, seasonNumber);
      final episodeJsonList = season.episodes.map((e) => e.toJson()).toList();
      await _localStorageService?.saveSeasonEpisodes(tmdbId.toString(), seasonNumber, episodeJsonList);
      _seasonDetails = season;
      _errorMessage = null;

      debugPrint('=== [Presenter.getSeasonDetails] tmdbId=$tmdbId season=$seasonNumber -> episodes: ${season.episodes.length} ===');
    } catch (e, stack) {
      debugPrint('=== [Presenter.getSeasonDetails] ERROR for tmdbId=$tmdbId season=$seasonNumber: $e ===');
      debugPrint(stack.toString());

      final staleCachedEpisodes = _localStorageService?.getSeasonEpisodes(tmdbId.toString(), seasonNumber, checkTtl: false);
      if (staleCachedEpisodes != null && staleCachedEpisodes.isNotEmpty) {
        final episodes = staleCachedEpisodes.map((e) => Episode.fromJson(e)).toList();
        _seasonDetails = Season(seasonNumber: seasonNumber, episodes: episodes);
        _errorMessage = null;
      } else {
        _errorMessage = e.toString();
      }
    } finally {
      _setLoading(false);
    }
  }

  @override
  Future<void> getEpisodeDetails(int tmdbId, int seasonNumber, int episodeNumber) async {
    _setLoading(true);

    final freshCachedEpisodes = _localStorageService?.getSeasonEpisodes(tmdbId.toString(), seasonNumber, checkTtl: true);
    if (freshCachedEpisodes != null && freshCachedEpisodes.isNotEmpty) {
      final matching = freshCachedEpisodes.firstWhere(
            (e) => e['episode_number'] == episodeNumber,
        orElse: () => <String, dynamic>{},
      );
      if (matching.isNotEmpty) {
        _episodeDetails = Episode.fromJson(matching);
        _errorMessage = null;
        _setLoading(false);
        return;
      }
    }

    try {
      _episodeDetails = await _mediaService.getEpisodeDetails(tmdbId, seasonNumber, episodeNumber);
      _errorMessage = null;
    } catch (e) {
      final staleCachedEpisodes = _localStorageService?.getSeasonEpisodes(tmdbId.toString(), seasonNumber, checkTtl: false);
      if (staleCachedEpisodes != null && staleCachedEpisodes.isNotEmpty) {
        final matching = staleCachedEpisodes.firstWhere(
              (e) => e['episode_number'] == episodeNumber,
          orElse: () => <String, dynamic>{},
        );
        if (matching.isNotEmpty) {
          _episodeDetails = Episode.fromJson(matching);
          _errorMessage = null;
        } else {
          _errorMessage = e.toString();
        }
      } else {
        _errorMessage = e.toString();
      }
    } finally {
      _setLoading(false);
    }
  }

  @override
  Future<void> toggleLike(String tmdbId, String mediaType) async {
    _setLoading(true);
    try {
      _lastLikeResponse = await _mediaService.toggleLike(tmdbId: tmdbId, mediaType: mediaType);
      _errorMessage = null;
    } catch (e) {
      await _localStorageService?.addOrUpdatePendingAction({
        'action_type': 'toggle_like',
        'target_id': tmdbId,
        'media_type': mediaType,
      });
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  @override
  Future<void> rateMedia(String tmdbId, String mediaType, double rating) async {
    _setLoading(true);
    try {
      final result = await _mediaService.rateMedia(tmdbId: tmdbId, mediaType: mediaType, rating: rating);
      final currentRatings = _localStorageService?.getUserRatings(checkTtl: false) ?? {};
      currentRatings[tmdbId] = rating;
      await _localStorageService?.saveUserRatings(currentRatings);
      _lastRatingResponse = result;
      _errorMessage = null;
    } catch (e) {
      final currentRatings = _localStorageService?.getUserRatings(checkTtl: false) ?? {};
      currentRatings[tmdbId] = rating;
      await _localStorageService?.saveUserRatings(currentRatings);
      await _localStorageService?.addOrUpdatePendingAction({
        'action_type': 'rate_media',
        'target_id': tmdbId,
        'media_type': mediaType,
        'rating': rating,
      });
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  @override
  Future<void> createReview(String tmdbId, String mediaType, String review, bool containsSpoiler) async {
    _setLoading(true);
    try {
      _lastCreatedReview = await _mediaService.createReview(
        tmdbId: tmdbId,
        mediaType: mediaType,
        review: review,
        containsSpoiler: containsSpoiler,
      );
      _errorMessage = null;
    } catch (e) {
      await _localStorageService?.addOrUpdatePendingAction({
        'action_type': 'create_review',
        'target_id': tmdbId,
        'media_type': mediaType,
        'review': review,
        'contains_spoiler': containsSpoiler,
      });
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  @override
  Future<void> getReviews(String tmdbId, String mediaType, {int page = 1, int perPage = 20}) async {
    _setLoading(true);

    final freshCachedReviews = _localStorageService?.getMediaReviews(tmdbId, checkTtl: true);
    if (freshCachedReviews != null && freshCachedReviews.isNotEmpty) {
      _reviews = freshCachedReviews.map((e) => ReviewResponse.fromJson(e)).toList();
      _errorMessage = null;
      _setLoading(false);
      return;
    }

    try {
      final reviews = await _mediaService.getReviews(
        tmdbId: tmdbId,
        mediaType: mediaType,
        page: page,
        perPage: perPage,
      );
      final jsonList = reviews.map((e) => e.toJson()).toList();
      await _localStorageService?.saveMediaReviews(tmdbId, jsonList);
      _reviews = reviews;
      _errorMessage = null;
    } catch (e) {
      final staleCachedReviews = _localStorageService?.getMediaReviews(tmdbId, checkTtl: false);
      if (staleCachedReviews != null && staleCachedReviews.isNotEmpty) {
        _reviews = staleCachedReviews.map((e) => ReviewResponse.fromJson(e)).toList();
        _errorMessage = null;
      } else {
        _errorMessage = e.toString();
      }
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}