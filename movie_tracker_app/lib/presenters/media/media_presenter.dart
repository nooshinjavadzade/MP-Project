import 'package:flutter/foundation.dart';
import '../../models/common.dart';
import '../../models/movie.dart';
import '../../models/series.dart';
import '../../models/user_content.dart';
import '../../services/api/media_service.dart';
import 'i_media_presenter.dart';

class MediaPresenter extends ChangeNotifier implements IMediaPresenter {
  final MediaService _mediaService;

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

  MediaPresenter(this._mediaService);

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

  @override
  Future<void> searchMedia(String query, {int page = 1}) async {
    _setLoading(true);
    try {
      _searchResult = await _mediaService.searchMedia(query: query, page: page);
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
    try {
      _trendingItems = await _mediaService.getTrending(mediaType: mediaType, timeWindow: timeWindow);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  @override
  Future<void> getPopularMovies({int page = 1}) async {
    _setLoading(true);
    try {
      _popularMovies = await _mediaService.getPopularMovies(page: page);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  @override
  Future<void> getPopularSeries({int page = 1}) async {
    _setLoading(true);
    try {
      _popularSeries = await _mediaService.getPopularSeries(page: page);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  @override
  Future<void> getMovieDetails(int tmdbId) async {
    _setLoading(true);
    try {
      _movieDetails = await _mediaService.getMovieDetails(tmdbId);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  @override
  Future<void> getSeriesDetails(int tmdbId) async {
    _setLoading(true);
    try {
      _seriesDetails = await _mediaService.getSeriesDetails(tmdbId);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  @override
  Future<void> getSeasonDetails(int tmdbId, int seasonNumber) async {
    _setLoading(true);
    try {
      _seasonDetails = await _mediaService.getSeasonDetails(tmdbId, seasonNumber);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  @override
  Future<void> getEpisodeDetails(int tmdbId, int seasonNumber, int episodeNumber) async {
    _setLoading(true);
    try {
      _episodeDetails = await _mediaService.getEpisodeDetails(tmdbId, seasonNumber, episodeNumber);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
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
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  @override
  Future<void> rateMedia(String tmdbId, String mediaType, double rating) async {
    _setLoading(true);
    try {
      _lastRatingResponse = await _mediaService.rateMedia(tmdbId: tmdbId, mediaType: mediaType, rating: rating);
      _errorMessage = null;
    } catch (e) {
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
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  @override
  Future<void> getReviews(String tmdbId, String mediaType, {int page = 1, int perPage = 20}) async {
    _setLoading(true);
    try {
      _reviews = await _mediaService.getReviews(
        tmdbId: tmdbId,
        mediaType: mediaType,
        page: page,
        perPage: perPage,
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