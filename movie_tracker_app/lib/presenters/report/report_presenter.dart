import 'package:flutter/foundation.dart';
import '../../models/report.dart';
import '../../services/api/report_service.dart';
import 'i_report_presenter.dart';

class ReportPresenter extends ChangeNotifier implements IReportPresenter {
  final ReportService _reportService;

  bool _isLoading = false;
  String? _errorMessage;

  ReportResponse? _lastSubmittedReport;
  ReportListResponse? _myReportsResponse;

  ReportPresenter(this._reportService);

  @override
  bool get isLoading => _isLoading;

  @override
  String? get errorMessage => _errorMessage;

  @override
  ReportResponse? get lastSubmittedReport => _lastSubmittedReport;

  @override
  ReportListResponse? get myReportsResponse => _myReportsResponse;

  @override
  Future<void> submitReport({
    required String mediaType,
    required int tmdbId,
    required ReportReason reason,
    String? description,
  }) async {
    _setLoading(true);
    try {
      final request = ReportCreate(reason: reason, description: description);
      _lastSubmittedReport = await _reportService.submitReport(
        mediaType: mediaType,
        tmdbId: tmdbId,
        request: request,
      );
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  @override
  Future<void> getMyReports({int page = 1, int perPage = 20}) async {
    _setLoading(true);
    try {
      _myReportsResponse = await _reportService.getMyReports(
        page: page,
        perPage: perPage,
      );
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}