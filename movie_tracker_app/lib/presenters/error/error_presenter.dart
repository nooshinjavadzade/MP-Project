import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../models/common/exceptions.dart';
import '../../services/api/error_handler.dart';
import 'i_error_presenter.dart';

class ErrorPresenter extends ChangeNotifier implements IErrorPresenter {
  String? _errorMessage;
  Exception? _lastException;

  @override
  String? get errorMessage => _errorMessage;

  @override
  Exception? get lastException => _lastException;

  @override
  void processError(Object error) {
    _lastException = _parseError(error);
    _errorMessage = getErrorMessage(error);
    notifyListeners();
  }

  @override
  String getErrorMessage(Object error) {
    final parsedException = _parseError(error);

    if (parsedException is ApiException) {
      return parsedException.message;
    } else if (parsedException is NetworkException) {
      return parsedException.message;
    } else if (parsedException is AuthException) {
      return parsedException.message;
    }

    return error.toString();
  }

  @override
  void clearError() {
    _errorMessage = null;
    _lastException = null;
    notifyListeners();
  }

  Exception _parseError(Object error) {
    if (error is DioException) {
      return ErrorHandler.handleDioError(error);
    } else if (error is Response) {
      return ErrorHandler.handleError(error);
    } else if (error is Exception) {
      return error;
    }
    return Exception(error.toString());
  }
}