import 'package:dio/dio.dart';

import '../../models/common.dart';
import '../../models/movie.dart';
import '../../models/series.dart';
import '../../models/user_content.dart';
import '../../models/report.dart';
import '../local/local_storage_service.dart';

import 'api_client.dart';
import 'error_handler.dart';

class MediaService {
  final ApiClient _apiClient;
  final LocalStorageService? _localStorageService;
  final _baseEndpoint = '/media';

  MediaService(this._apiClient, [this._localStorageService]);

  Future<MediaSearchResult> searchMedia({
    required String query,
    int page = 1,
  }) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isNotEmpty) {
      await _localStorageService?.addSearchQuery(trimmedQuery);
    }
    try {
      final response = await _apiClient.dio.get(
        '$_baseEndpoint/search',
        queryParameters: {
          'query': query,
          'page': page,
        },
      );

      if (response.statusCode == 200) {
        final result = MediaSearchResult.fromJson(response.data);
        for (final item in result.items) {
          if (item.posterUrl != null) {
            _localStorageService?.prefetchImage(item.posterUrl!);
          }
        }
        return result;
      }
      throw ErrorHandler.handleError(response);
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  Future<List<MediaBase>> getTrending({
    String mediaType = 'all',
    String timeWindow = 'week',
  }) async {
    try {
      final response = await _apiClient.dio.get(
        '$_baseEndpoint/trending',
        queryParameters: {
          'media_type': mediaType,
          'time_window': timeWindow,
        },
      );

      if (response.statusCode == 200) {
        final items = (response.data as List)
            .map((e) => MediaBase.fromJson(e as Map<String, dynamic>))
            .toList();
        for (final item in items) {
          if (item.posterUrl != null) {
            _localStorageService?.prefetchImage(item.posterUrl!);
          }
        }
        return items;
      }
      throw ErrorHandler.handleError(response);
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  Future<List<MediaBase>> getPopularMovies({int page = 1}) async {
    try {
      final response = await _apiClient.dio.get(
        '$_baseEndpoint/popular/movies',
        queryParameters: {'page': page},
      );

      if (response.statusCode == 200) {
        final items = (response.data as List)
            .map((e) => MediaBase.fromJson(e as Map<String, dynamic>))
            .toList();
        for (final item in items) {
          if (item.posterUrl != null) {
            _localStorageService?.prefetchImage(item.posterUrl!);
          }
        }
        return items;
      }
      throw ErrorHandler.handleError(response);
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  Future<List<MediaBase>> getPopularSeries({int page = 1}) async {
    try {
      final response = await _apiClient.dio.get(
        '$_baseEndpoint/popular/series',
        queryParameters: {'page': page},
      );

      if (response.statusCode == 200) {
        final items = (response.data as List)
            .map((e) => MediaBase.fromJson(e as Map<String, dynamic>))
            .toList();
        for (final item in items) {
          if (item.posterUrl != null) {
            _localStorageService?.prefetchImage(item.posterUrl!);
          }
        }
        return items;
      }
      throw ErrorHandler.handleError(response);
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  Future<TopMediaListResponse> getTopMovies({
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        '$_baseEndpoint/movies/top',
        queryParameters: {
          'page': page,
          'per_page': perPage,
        },
      );

      if (response.statusCode == 200) {
        final result = TopMediaListResponse.fromJson(response.data);
        if (page == 1) {
          await _localStorageService?.saveHomeSection('top_movies', result.items);
        }
        for (final item in result.items) {
          if (item.media.posterUrl != null) {
            _localStorageService?.prefetchImage(item.media.posterUrl!);
          }
        }
        return result;
      }
      throw ErrorHandler.handleError(response);
    } on DioException catch (e) {
      if (page == 1) {
        final cachedItems = _localStorageService?.getHomeSection('top_movies');
        if (cachedItems != null && cachedItems.isNotEmpty) {
          return TopMediaListResponse(
            items: cachedItems,
            pagination: Pagination(
              page: 1,
              perPage: perPage,
              totalItems: cachedItems.length,
              totalPages: 1,
              hasNextPage: false,
              hasPreviousPage: false,
            ),
            timeWindow: 'week',
            generatedAt: DateTime.now(),
          );
        }
      }
      throw ErrorHandler.handleDioError(e);
    }
  }

  Future<TopMediaListResponse> getTopSeries({
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        '$_baseEndpoint/series/top',
        queryParameters: {
          'page': page,
          'per_page': perPage,
        },
      );

      if (response.statusCode == 200) {
        final result = TopMediaListResponse.fromJson(response.data);
        if (page == 1) {
          await _localStorageService?.saveHomeSection('top_series', result.items);
        }
        for (final item in result.items) {
          if (item.media.posterUrl != null) {
            _localStorageService?.prefetchImage(item.media.posterUrl!);
          }
        }
        return result;
      }
      throw ErrorHandler.handleError(response);
    } on DioException catch (e) {
      if (page == 1) {
        final cachedItems = _localStorageService?.getHomeSection('top_series');
        if (cachedItems != null && cachedItems.isNotEmpty) {
          return TopMediaListResponse(
            items: cachedItems,
            pagination: Pagination(
              page: 1,
              perPage: perPage,
              totalItems: cachedItems.length,
              totalPages: 1,
              hasNextPage: false,
              hasPreviousPage: false,
            ),
            timeWindow: 'week',
            generatedAt: DateTime.now(),
          );
        }
      }
      throw ErrorHandler.handleDioError(e);
    }
  }

  Future<MovieDetails> getMovieDetails(int tmdbId) async {
    final cached = _localStorageService?.getMovieDetails(tmdbId.toString());
    try {
      final response = await _apiClient.dio.get('$_baseEndpoint/movies/$tmdbId');

      if (response.statusCode == 200) {
        final details = MovieDetails.fromJson(response.data);
        await _localStorageService?.saveMovieDetails(tmdbId.toString(), details);
        if (details.posterUrl != null) {
          _localStorageService?.prefetchImage(details.posterUrl!);
        }
        if (details.backdropUrl != null) {
          _localStorageService?.prefetchImage(details.backdropUrl!);
        }
        return details;
      }
      throw ErrorHandler.handleError(response);
    } on DioException catch (e) {
      if (cached != null) return cached;
      throw ErrorHandler.handleDioError(e);
    } catch (e) {
      if (cached != null) return cached;
      rethrow;
    }
  }

  Future<SeriesDetails> getSeriesDetails(int tmdbId) async {
    final cached = _localStorageService?.getSeriesDetails(tmdbId.toString());
    try {
      final response = await _apiClient.dio.get('$_baseEndpoint/series/$tmdbId');

      if (response.statusCode == 200) {
        final details = SeriesDetails.fromJson(response.data);
        await _localStorageService?.saveSeriesDetails(tmdbId.toString(), details);
        if (details.posterUrl != null) {
          _localStorageService?.prefetchImage(details.posterUrl!);
        }
        if (details.backdropUrl != null) {
          _localStorageService?.prefetchImage(details.backdropUrl!);
        }
        return details;
      }
      throw ErrorHandler.handleError(response);
    } on DioException catch (e) {
      if (cached != null) return cached;
      throw ErrorHandler.handleDioError(e);
    } catch (e) {
      if (cached != null) return cached;
      rethrow;
    }
  }

  Future<Season> getSeasonDetails(int tmdbId, int seasonNumber) async {
    final cachedEpisodes = _localStorageService?.getSeasonEpisodes(tmdbId.toString(), seasonNumber);
    try {
      final response = await _apiClient.dio.get(
        '$_baseEndpoint/series/$tmdbId/season/$seasonNumber',
      );

      if (response.statusCode == 200) {
        final season = Season.fromJson(response.data);
        final episodeJsonList = season.episodes.map((e) => e.toJson()).toList();
        await _localStorageService?.saveSeasonEpisodes(tmdbId.toString(), seasonNumber, episodeJsonList);
        return season;
      }
      throw ErrorHandler.handleError(response);
    } on DioException catch (e) {
      if (cachedEpisodes != null && cachedEpisodes.isNotEmpty) {
        final episodes = cachedEpisodes.map((e) => Episode.fromJson(e)).toList();
        return Season(seasonNumber: seasonNumber, episodes: episodes);
      }
      throw ErrorHandler.handleDioError(e);
    } catch (e) {
      if (cachedEpisodes != null && cachedEpisodes.isNotEmpty) {
        final episodes = cachedEpisodes.map((e) => Episode.fromJson(e)).toList();
        return Season(seasonNumber: seasonNumber, episodes: episodes);
      }
      rethrow;
    }
  }

  Future<Episode> getEpisodeDetails(
      int tmdbId,
      int seasonNumber,
      int episodeNumber,
      ) async {
    try {
      final response = await _apiClient.dio.get(
        '$_baseEndpoint/series/$tmdbId/season/$seasonNumber/episode/$episodeNumber',
      );

      if (response.statusCode == 200) {
        return Episode.fromJson(response.data);
      }
      throw ErrorHandler.handleError(response);
    } on DioException catch (e) {
      final cachedEpisodes = _localStorageService?.getSeasonEpisodes(tmdbId.toString(), seasonNumber);
      if (cachedEpisodes != null && cachedEpisodes.isNotEmpty) {
        final matching = cachedEpisodes.firstWhere(
              (e) => e['episode_number'] == episodeNumber,
          orElse: () => <String, dynamic>{},
        );
        if (matching.isNotEmpty) {
          return Episode.fromJson(matching);
        }
      }
      throw ErrorHandler.handleDioError(e);
    }
  }

  Future<LikeToggleResponse> toggleLike({
    required String tmdbId,
    required String mediaType,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '$_baseEndpoint/$mediaType/$tmdbId/like',
      );

      if (response.statusCode == 200) {
        return LikeToggleResponse.fromJson(response.data);
      }
      throw ErrorHandler.handleError(response);
    } on DioException catch (e) {
      await _localStorageService?.addOrUpdatePendingAction({
        'action_type': 'toggle_like',
        'target_id': tmdbId,
        'media_type': mediaType,
      });
      throw ErrorHandler.handleDioError(e);
    }
  }

  Future<RatingResponse> rateMedia({
    required String tmdbId,
    required String mediaType,
    required double rating,
  }) async {
    try {
      final request = RatingCreate(rating: rating);
      final response = await _apiClient.dio.post(
        '$_baseEndpoint/$mediaType/$tmdbId/rating',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        final result = RatingResponse.fromJson(response.data);
        final currentRatings = _localStorageService?.getUserRatings(checkTtl: false) ?? {};
        currentRatings[tmdbId] = rating;
        await _localStorageService?.saveUserRatings(currentRatings);
        return result;
      }
      throw ErrorHandler.handleError(response);
    } on DioException catch (e) {
      final currentRatings = _localStorageService?.getUserRatings(checkTtl: false) ?? {};
      currentRatings[tmdbId] = rating;
      await _localStorageService?.saveUserRatings(currentRatings);
      await _localStorageService?.addOrUpdatePendingAction({
        'action_type': 'rate_media',
        'target_id': tmdbId,
        'media_type': mediaType,
        'rating': rating,
      });
      throw ErrorHandler.handleDioError(e);
    }
  }

  Future<ReviewResponse> createReview({
    required String tmdbId,
    required String mediaType,
    required String review,
    required bool containsSpoiler,
  }) async {
    try {
      final request = ReviewCreate(
        review: review,
        containsSpoiler: containsSpoiler,
      );
      final response = await _apiClient.dio.post(
        '$_baseEndpoint/$mediaType/$tmdbId/reviews',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        return ReviewResponse.fromJson(response.data);
      }
      throw ErrorHandler.handleError(response);
    } on DioException catch (e) {
      await _localStorageService?.addOrUpdatePendingAction({
        'action_type': 'create_review',
        'target_id': tmdbId,
        'media_type': mediaType,
        'review': review,
        'contains_spoiler': containsSpoiler,
      });
      throw ErrorHandler.handleDioError(e);
    }
  }

  Future<List<ReviewResponse>> getReviews({
    required String tmdbId,
    required String mediaType,
    int page = 1,
    int perPage = 20,
  }) async {
    final cachedReviews = _localStorageService?.getMediaReviews(tmdbId);
    try {
      final response = await _apiClient.dio.get(
        '$_baseEndpoint/$mediaType/$tmdbId/reviews',
        queryParameters: {
          'page': page,
          'per_page': perPage,
        },
      );

      if (response.statusCode == 200) {
        final rawList = response.data as List;
        final reviews = rawList
            .map((e) => ReviewResponse.fromJson(e as Map<String, dynamic>))
            .toList();
        final jsonList = rawList.map((e) => e as Map<String, dynamic>).toList();
        await _localStorageService?.saveMediaReviews(tmdbId, jsonList);
        return reviews;
      }
      throw ErrorHandler.handleError(response);
    } on DioException catch (e) {
      if (cachedReviews != null && cachedReviews.isNotEmpty) {
        return cachedReviews.map((e) => ReviewResponse.fromJson(e)).toList();
      }
      throw ErrorHandler.handleDioError(e);
    } catch (e) {
      if (cachedReviews != null && cachedReviews.isNotEmpty) {
        return cachedReviews.map((e) => ReviewResponse.fromJson(e)).toList();
      }
      rethrow;
    }
  }

  Future<ReportResponse> reportMedia({
    required String tmdbId,
    required String mediaType,
    required ReportCreate request,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '$_baseEndpoint/$mediaType/$tmdbId/report',
        data: request.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ReportResponse.fromJson(response.data);
      }
      throw ErrorHandler.handleError(response);
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }
}