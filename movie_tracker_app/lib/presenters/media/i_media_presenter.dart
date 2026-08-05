import '../../models/common.dart';
import '../../models/movie.dart';
import '../../models/series.dart';
import '../../models/user_content.dart';

abstract class IMediaPresenter {
  bool get isLoading;
  String? get errorMessage;

  MediaSearchResult? get searchResult;
  List<MediaBase> get trendingItems;
  List<MediaBase> get popularMovies;
  List<MediaBase> get popularSeries;
  MovieDetails? get movieDetails;
  SeriesDetails? get seriesDetails;
  Season? get seasonDetails;
  Episode? get episodeDetails;
  LikeToggleResponse? get lastLikeResponse;
  RatingResponse? get lastRatingResponse;
  ReviewResponse? get lastCreatedReview;
  List<ReviewResponse> get reviews;

  Future<void> searchMedia(String query, {int page = 1});
  Future<void> getTrending({String mediaType = 'all', String timeWindow = 'week'});
  Future<void> getPopularMovies({int page = 1});
  Future<void> getPopularSeries({int page = 1});
  Future<void> getMovieDetails(int tmdbId);
  Future<void> getSeriesDetails(int tmdbId);
  Future<void> getSeasonDetails(int tmdbId, int seasonNumber);
  Future<void> getEpisodeDetails(int tmdbId, int seasonNumber, int episodeNumber);
  Future<void> toggleLike(String tmdbId, String mediaType);
  Future<void> rateMedia(String tmdbId, String mediaType, double rating);
  Future<void> createReview(String tmdbId, String mediaType, String review, bool containsSpoiler);
  Future<void> getReviews(String tmdbId, String mediaType, {int page = 1, int perPage = 20});
}