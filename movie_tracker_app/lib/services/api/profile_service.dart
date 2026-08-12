import 'package:dio/dio.dart';

import '../../models/common/media_base.dart';
import '../../models/user_content/rating_response.dart';
import '../../models/user_content/review_response.dart';
import '../../models/auth/user.dart';
import '../../models/auth/profile_response.dart';
import '../../models/report.dart';
import '../local/local_storage_service.dart';

import 'api_client.dart';
import 'error_handler.dart';

class ProfileService {
  final ApiClient _apiClient;
  final LocalStorageService? _localStorageService;
  final _baseEndpoint = '/profile';

  ProfileService(this._apiClient, [this._localStorageService]);

  Future<User> getProfile() async {
    try {
      final response = await _apiClient.dio.get(_baseEndpoint);

      if (response.statusCode == 200) {
        return User.fromJson(response.data);
      }
      throw ErrorHandler.handleError(response);
    } on DioException catch (e) {
      final cachedProfile = _localStorageService?.getUserProfile(checkTtl: false);
      if (cachedProfile != null) {
        return User.fromJson(cachedProfile.toJson());
      }
      throw ErrorHandler.handleDioError(e);
    }
  }

  Future<User> updateProfile({
    String? fullName,
    String? bio,
    String? avatarUrl,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (fullName != null) data['full_name'] = fullName;
      if (bio != null) data['bio'] = bio;
      if (avatarUrl != null) data['avatar_url'] = avatarUrl;

      final response = await _apiClient.dio.patch(
        _baseEndpoint,
        data: data,
      );

      if (response.statusCode == 200) {
        final updatedUser = User.fromJson(response.data);
        final cachedProfile = _localStorageService?.getUserProfile(checkTtl: false);
        if (cachedProfile != null) {
          final updatedJson = cachedProfile.toJson();
          if (fullName != null) updatedJson['full_name'] = fullName;
          if (bio != null) updatedJson['bio'] = bio;
          if (avatarUrl != null) updatedJson['avatar_url'] = avatarUrl;
          await _localStorageService?.saveUserProfile(ProfileResponse.fromJson(updatedJson));
        }
        return updatedUser;
      }
      throw ErrorHandler.handleError(response);
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  Future<List<MediaBase>> getLikedMedia({
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        '$_baseEndpoint/likes',
        queryParameters: {
          'page': page,
          'per_page': perPage,
        },
      );

      if (response.statusCode == 200) {
        return (response.data as List)
            .map((e) => MediaBase.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw ErrorHandler.handleError(response);
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  Future<List<RatingResponse>> getRatings({
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        '$_baseEndpoint/ratings',
        queryParameters: {
          'page': page,
          'per_page': perPage,
        },
      );

      if (response.statusCode == 200) {
        return (response.data as List)
            .map((e) => RatingResponse.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw ErrorHandler.handleError(response);
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  Future<List<ReviewResponse>> getReviews({
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        '$_baseEndpoint/reviews',
        queryParameters: {
          'page': page,
          'per_page': perPage,
        },
      );

      if (response.statusCode == 200) {
        return (response.data as List)
            .map((e) => ReviewResponse.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw ErrorHandler.handleError(response);
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  Future<ReviewResponse> updateReview({
    required int reviewId,
    String? review,
    bool? containsSpoiler,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (review != null) data['review'] = review;
      if (containsSpoiler != null) data['contains_spoiler'] = containsSpoiler;

      final response = await _apiClient.dio.patch(
        '$_baseEndpoint/reviews/$reviewId',
        data: data,
      );

      if (response.statusCode == 200) {
        await _localStorageService?.invalidateUserStats();
        return ReviewResponse.fromJson(response.data);
      }
      throw ErrorHandler.handleError(response);
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  Future<void> deleteReview(int reviewId) async {
    try {
      final response = await _apiClient.dio.delete('$_baseEndpoint/reviews/$reviewId');

      if (response.statusCode != 204) {
        throw ErrorHandler.handleError(response);
      }
      await _localStorageService?.invalidateUserStats();
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  Future<ProfileResponse> getProfileFull({bool checkTtl = true}) async {
    if (checkTtl) {
      final cached = _localStorageService?.getUserProfile(checkTtl: true);
      if (cached != null) {
        return cached;
      }
    }

    try {
      final response = await _apiClient.dio.get(_baseEndpoint);

      if (response.statusCode == 200) {
        final profile = ProfileResponse.fromJson(response.data);
        await _localStorageService?.saveUserProfile(profile);
        return profile;
      }
      throw ErrorHandler.handleError(response);
    } on DioException catch (e) {
      final cached = _localStorageService?.getUserProfile(checkTtl: false);
      if (cached != null) {
        return cached;
      }
      throw ErrorHandler.handleDioError(e);
    }
  }

  Future<PublicProfileResponse> getPublicProfile(int userId) async {
    try {
      final response = await _apiClient.dio.get('$_baseEndpoint/$userId');

      if (response.statusCode == 200) {
        return PublicProfileResponse.fromJson(response.data);
      }
      throw ErrorHandler.handleError(response);
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  Future<ReportListResponse> getMyReports({
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        '$_baseEndpoint/reports',
        queryParameters: {
          'page': page,
          'per_page': perPage,
        },
      );

      if (response.statusCode == 200) {
        return ReportListResponse.fromJson(response.data);
      }
      throw ErrorHandler.handleError(response);
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }
}