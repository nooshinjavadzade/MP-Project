import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_tracker_app/models/common/exceptions.dart';
import 'package:movie_tracker_app/presenters/error/error_presenter.dart';

void main() {
  late ErrorPresenter presenter;

  setUp(() {
    presenter = ErrorPresenter();
  });

  group('ErrorPresenter Tests', () {
    test('processError parses ApiException correctly', () {
      final apiException = ApiException('Custom API Error', 404);

      presenter.processError(apiException);

      expect(presenter.errorMessage, 'Custom API Error');
      expect(presenter.lastException, isA<ApiException>());
    });

    test('processError parses NetworkException correctly', () {
      final networkException = NetworkException('No Internet');

      presenter.processError(networkException);

      expect(presenter.errorMessage, 'No Internet');
      expect(presenter.lastException, isA<NetworkException>());
    });

    test('processError parses AuthException correctly', () {
      final authException = AuthException('Unauthorized');

      presenter.processError(authException);

      expect(presenter.errorMessage, 'Unauthorized');
      expect(presenter.lastException, isA<AuthException>());
    });

    test('processError converts DioException to NetworkException', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionTimeout,
      );

      presenter.processError(dioException);

      expect(presenter.errorMessage, 'Connection timeout');
      expect(presenter.lastException, isA<NetworkException>());
    });

    test('clearError resets state', () {
      presenter.processError(ApiException('Error', 500));
      expect(presenter.errorMessage, isNotNull);

      presenter.clearError();

      expect(presenter.errorMessage, isNull);
      expect(presenter.lastException, isNull);
    });
  });
}