import '../../models/report.dart';
import '../../models/auth/user.dart';
import '../../models/common/media_base.dart';

abstract class IReportPresenter {
  bool get isLoading;
  String? get errorMessage;

  ReportResponse? get lastSubmittedReport;
  ReportListResponse? get myReportsResponse;

  Future<void> submitReport({
    required String mediaType,
    required int tmdbId,
    required ReportReason reason,
    String? description,
  });

  Future<void> getMyReports({int page = 1, int perPage = 20});

  User? getUserForReport(int reportId);
  MediaBase? getMediaForReport(int reportId);
  String getUserNameForReport(int reportId);
  String getUserEmailForReport(int reportId);
  String getMediaTitleForReport(int reportId);
}