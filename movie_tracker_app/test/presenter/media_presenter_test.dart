import 'package:flutter_test/flutter_test.dart';
import 'package:movie_tracker_app/models/common/media_base.dart';
import 'package:movie_tracker_app/models/common/media_search_result.dart';
import 'package:movie_tracker_app/models/common/pagination.dart';
import 'package:movie_tracker_app/models/movie/movie_details.dart';
import 'package:movie_tracker_app/models/series/episode.dart';
import 'package:movie_tracker_app/models/series/season.dart';
import 'package:movie_tracker_app/models/series/series_details.dart';
import 'package:movie_tracker_app/models/user_content/like_toggle_response.dart';
import 'package:movie_tracker_app/models/user_content/rating_response.dart';
import 'package:movie_tracker_app/models/user_content/review_response.dart';
import 'package:movie_tracker_app/presenters/media/media_presenter.dart';
import 'package:movie_tracker_app/services/api/media_service.dart';

class FakeMediaService implements MediaService {
  bool shouldThrowError = false;
  final DateTime _dummyDate = DateTime(2026, 1, 1);

  @override
  Future<MediaSearchResult> searchMedia({required String query, int page = 1}) async {
    if (shouldThrowError) throw Exception('Search failed');
    return MediaSearchResult(
      items: <MediaBase>[],
      pagination: Pagination(
        page: page,
        perPage: 20,
        totalItems: 0,
        totalPages: 1,
        hasNextPage: false,
        hasPreviousPage: false,
      ),
    );
  }

  @override
  Future<List<MediaBase>> getTrending({String mediaType = 'all', String timeWindow = 'week'}) async {
    if (shouldThrowError) throw Exception('Trending failed');
    return [];
  }

  @override
  Future<List<MediaBase>> getPopularMovies({int page = 1}) async {
    if (shouldThrowError) throw Exception('Popular movies failed');
    return [];
  }

  @override
  Future<List<MediaBase>> getPopularSeries({int page = 1}) async {
    if (shouldThrowError) throw Exception('Popular series failed');
    return [];
  }

  @override
  Future<MovieDetails> getMovieDetails(int tmdbId) async {
    if (shouldThrowError) throw Exception('Movie details failed');
    return MovieDetails(id: 1, tmdbId: tmdbId.toString(), title: 'Inception');
  }

  @override
  Future<SeriesDetails> getSeriesDetails(int tmdbId) async {
    if (shouldThrowError) throw Exception('Series details failed');
    return SeriesDetails(
      id: 1,
      tmdbId: tmdbId.toString(),
      title: 'Breaking Bad',
      status: 'Ended',
    );
  }

  @override
  Future<Season> getSeasonDetails(int tmdbId, int seasonNumber) async {
    if (shouldThrowError) throw Exception('Season details failed');
    return Season(seasonNumber: seasonNumber);
  }

  @override
  Future<Episode> getEpisodeDetails(int tmdbId, int seasonNumber, int episodeNumber) async {
    if (shouldThrowError) throw Exception('Episode details failed');
    return Episode(episodeNumber: episodeNumber, title: 'Pilot');
  }

  @override
  Future<LikeToggleResponse> toggleLike({required String tmdbId, required String mediaType}) async {
    if (shouldThrowError) throw Exception('Toggle like failed');
    return const LikeToggleResponse(liked: true);
  }

  @override
  Future<RatingResponse> rateMedia({
    required String tmdbId,
    required String mediaType,
    required double rating,
  }) async {
    if (shouldThrowError) throw Exception('Rating failed');
    return RatingResponse(
      id: 1,
      mediaId: 100,
      userId: 10,
      rating: rating,
      ratedAt: _dummyDate,
    );
  }

  @override
  Future<ReviewResponse> createReview({
    required String tmdbId,
    required String mediaType,
    required String review,
    required bool containsSpoiler,
  }) async {
    if (shouldThrowError) throw Exception('Review failed');
    return ReviewResponse(
      id: 1,
      mediaId: 100,
      userId: 10,
      review: review,
      containsSpoiler: containsSpoiler,
      createdAt: _dummyDate,
    );
  }

  @override
  Future<List<ReviewResponse>> getReviews({
    required String tmdbId,
    required String mediaType,
    int page = 1,
    int perPage = 20,
  }) async {
    if (shouldThrowError) throw Exception('Fetch reviews failed');
    return [
      ReviewResponse(
        id: 1,
        mediaId: 100,
        userId: 10,
        review: 'Amazing movie!',
        containsSpoiler: false,
        createdAt: _dummyDate,
      ),
    ];
  }
}

void main() {
  late FakeMediaService fakeService;
  late MediaPresenter presenter;

  setUp(() {
    fakeService = FakeMediaService();
    presenter = MediaPresenter(fakeService);
  });

  group('MediaPresenter Tests', () {
    test('getMovieDetails populates movieDetails state', () async {
      await presenter.getMovieDetails(550);

      expect(presenter.isLoading, false);
      expect(presenter.errorMessage, isNull);
      expect(presenter.movieDetails?.title, 'Inception');
    });

    test('getSeriesDetails populates seriesDetails state', () async {
      await presenter.getSeriesDetails(100);

      expect(presenter.isLoading, false);
      expect(presenter.errorMessage, isNull);
      expect(presenter.seriesDetails?.title, 'Breaking Bad');
    });

    test('toggleLike updates lastLikeResponse', () async {
      await presenter.toggleLike('550', 'movie');

      expect(presenter.isLoading, false);
      expect(presenter.errorMessage, isNull);
      expect(presenter.lastLikeResponse?.liked, true);
    });

    test('rateMedia updates lastRatingResponse', () async {
      await presenter.rateMedia('550', 'movie', 8.5);

      expect(presenter.isLoading, false);
      expect(presenter.errorMessage, isNull);
      expect(presenter.lastRatingResponse?.rating, 8.5);
    });

    test('searchMedia sets searchResult state', () async {
      await presenter.searchMedia('Batman');

      expect(presenter.isLoading, false);
      expect(presenter.errorMessage, isNull);
      expect(presenter.searchResult, isNotNull);
    });

    test('createReview and getReviews update state correctly', () async {
      await presenter.createReview('550', 'movie', 'Great film!', false);
      expect(presenter.isLoading, false);
      expect(presenter.errorMessage, isNull);

      await presenter.getReviews('550', 'movie');
      expect(presenter.isLoading, false);
      expect(presenter.errorMessage, isNull);
      expect(presenter.reviews.isNotEmpty, true);
    });

    test('handles service errors gracefully', () async {
      fakeService.shouldThrowError = true;

      await presenter.getMovieDetails(1);

      expect(presenter.isLoading, false);
      expect(presenter.movieDetails, isNull);
      expect(presenter.errorMessage, contains('Movie details failed'));
    });
  });
}