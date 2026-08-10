import '../../models/report.dart';

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
}