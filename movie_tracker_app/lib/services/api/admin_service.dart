import 'package:dio/dio.dart';

import '../../../models/admin.dart';
import '../../../models/common/pagination.dart';

import 'api_client.dart';
import 'error_handler.dart';

class AdminService {
  final ApiClient _apiClient;
  final _baseEndpoint = '/admin';

  AdminService(this._apiClient);

  // User Management
  Future<AdminUserListResponse> getUsers({
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        '$_baseEndpoint/users',
        queryParameters: {
          'page': page,
          'per_page': perPage,
        },
      );

      if (response.statusCode == 200) {
        return AdminUserListResponse.fromJson(response.data);
      }
      throw ErrorHandler.handleError(response);
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  Future<AdminUserResponse> updateUser({
    required int userId,
    required AdminUserUpdate request,
  }) async {
    try {
      final response = await _apiClient.dio.patch(
        '$_baseEndpoint/users/$userId',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        return AdminUserResponse.fromJson(response.data);
      }
      throw ErrorHandler.handleError(response);
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  Future<AdminActionResponse> deleteUser(int userId) async {
    try {
      final response = await _apiClient.dio.delete('$_baseEndpoint/users/$userId');

      if (response.statusCode == 200) {
        return AdminActionResponse.fromJson(response.data);
      }
      throw ErrorHandler.handleError(response);
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  // Review Moderation
  Future<AdminReviewListResponse> getReviews({
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
        return AdminReviewListResponse.fromJson(response.data);
      }
      throw ErrorHandler.handleError(response);
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  Future<AdminActionResponse> deleteReview(int reviewId) async {
    try {
      final response = await _apiClient.dio.delete('$_baseEndpoint/reviews/$reviewId');

      if (response.statusCode == 200) {
        return AdminActionResponse.fromJson(response.data);
      }
      throw ErrorHandler.handleError(response);
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  // Report Moderation
  Future<AdminReportListResponse> getReports({
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
        return AdminReportListResponse.fromJson(response.data);
      }
      throw ErrorHandler.handleError(response);
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  Future<AdminReportResponse> updateReport({
    required int reportId,
    required AdminReportUpdate request,
  }) async {
    try {
      final response = await _apiClient.dio.patch(
        '$_baseEndpoint/reports/$reportId',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        return AdminReportResponse.fromJson(response.data);
      }
      throw ErrorHandler.handleError(response);
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  // Media Cache Management
  Future<CachedMediaListResponse> getCachedMedia({
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        '$_baseEndpoint/media',
        queryParameters: {
          'page': page,
          'per_page': perPage,
        },
      );

      if (response.statusCode == 200) {
        return CachedMediaListResponse.fromJson(response.data);
      }
      throw ErrorHandler.handleError(response);
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  Future<CachedMediaResponse> refreshMedia(int mediaId) async {
    try {
      final response = await _apiClient.dio.post('$_baseEndpoint/media/$mediaId/refresh');

      if (response.statusCode == 200) {
        return CachedMediaResponse.fromJson(response.data);
      }
      throw ErrorHandler.handleError(response);
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  Future<AdminActionResponse> deleteCachedMedia(int mediaId) async {
    try {
      final response = await _apiClient.dio.delete('$_baseEndpoint/media/$mediaId');

      if (response.statusCode == 200) {
        return AdminActionResponse.fromJson(response.data);
      }
      throw ErrorHandler.handleError(response);
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  // Dashboard Stats
  Future<AdminStats> getStats() async {
    try {
      final response = await _apiClient.dio.get('$_baseEndpoint/stats');

      if (response.statusCode == 200) {
        return AdminStats.fromJson(response.data);
      }
      throw ErrorHandler.handleError(response);
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }
}