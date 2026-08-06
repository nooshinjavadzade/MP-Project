import 'package:dio/dio.dart';

import '../../../models/report.dart';
import '../../../models/common/pagination.dart';

import 'api_client.dart';
import 'error_handler.dart';

class ReportService {
  final ApiClient _apiClient;
  final _baseEndpoint = '/media';

  ReportService(this._apiClient);

  // User submits a report on media
  Future<ReportResponse> submitReport({
    required String mediaType,
    required int tmdbId,
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

  // User gets their own reports
  Future<ReportListResponse> getMyReports({
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        '$_baseEndpoint/../../profile/reports',
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