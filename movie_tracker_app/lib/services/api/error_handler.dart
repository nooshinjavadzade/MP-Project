import 'package:dio/dio.dart';

import '../../models/common/exceptions.dart';

class ErrorHandler {
  static Exception handleError(Response response) {
    final statusCode = response.statusCode;
    String message = '';
    if (statusCode == 422) {
      message = 'Fields ';
      for (var error in response.data.get('details')) {
        message += '${error['loc'][1]}, ';
      }
      message = message.substring(0, message.length - 2);
      message += ' are missing';
    } else if (statusCode == 401) {
      message = 'You are not the owner of this thing.';
    } else {
      message = response.data is Map
          ? response.data['detail'] ?? response.data['message'] ??
          'Unknown error'
          : 'Request failed with status ${response.statusCode}';
    }

    return ApiException(message, statusCode);

  }

  static Exception handleDioError(DioException e) {
    if (e.response != null) {
      return handleError(e.response!);
    }
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException('Connection timeout');
      case DioExceptionType.connectionError:
        return NetworkException('Network connection error');
      default:
        return NetworkException(e.message ?? 'Network error');
    }
  }
}