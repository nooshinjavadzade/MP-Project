import '../../models/common/exceptions.dart';

abstract class IErrorPresenter {
  String? get errorMessage;
  Exception? get lastException;

  void processError(Object error);
  String getErrorMessage(Object error);
  void clearError();
}